#import "XMPPLastMessageCorrection.h"
#import "XMPPCapabilities.h"
#import "XMPPRoom.h"
#import "XMPPMUCLight.h"
#import "XMPPMessage+XEP_0308.h"
#import "XMPPJID.h"
#import "XMPPLogging.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

static NSString * const XMPPLastMessageCorrectionNamespace = @"urn:xmpp:message-correct:0";

@interface XMPPLastMessageCorrection ()

@property (nonatomic, strong, readonly) id<XMPPLastMessageCorrectionStorage> storage;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSString *> *outgoingMessageIDIndex;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSString *> *incomingMessageIDIndex;

@end

@implementation XMPPLastMessageCorrection

- (instancetype)initWithStorage:(id<XMPPLastMessageCorrectionStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    self = [super initWithDispatchQueue:queue];
    if (self) {
        _storage = storage;
        _outgoingMessageIDIndex = [[NSMutableDictionary alloc] init];
        _incomingMessageIDIndex = [[NSMutableDictionary alloc] init];
        if (_storage && ![_storage configureWithParent:self queue:moduleQueue]) {
            self = nil;
        }
    }
    return self;
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    return [self initWithStorage:nil dispatchQueue:queue];
}

- (BOOL)canCorrectSentMessageWithID:(NSString *)messageID
{
    __block BOOL result;
    dispatch_block_t block = ^{
        result =  [self.outgoingMessageIDIndex.allValues containsObject:messageID];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)didActivate
{
    XMPPLogTrace();
    [self.xmppStream autoAddDelegate:self delegateQueue:self.moduleQueue toModulesOfClass:[XMPPCapabilities class]];
    [self.xmppStream autoAddDelegate:self delegateQueue:self.moduleQueue toModulesOfClass:[XMPPRoom class]];
    [self.xmppStream autoAddDelegate:self delegateQueue:self.moduleQueue toModulesOfClass:[XMPPMUCLight class]];
}

- (void)willDeactivate
{
    XMPPLogTrace();
    
    [self.outgoingMessageIDIndex removeAllObjects];
    [self.incomingMessageIDIndex removeAllObjects];
    [self.xmppStream removeAutoDelegate:self delegateQueue:self.moduleQueue fromModulesOfClass:[XMPPCapabilities class]];
    [self.xmppStream removeAutoDelegate:self delegateQueue:self.moduleQueue fromModulesOfClass:[XMPPRoom class]];
    [self.xmppStream removeAutoDelegate:self delegateQueue:self.moduleQueue fromModulesOfClass:[XMPPMUCLight class]];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event
{
    XMPPLogTrace();
    
    BOOL isValidCorrection = [message isMessageCorrection] && [self.incomingMessageIDIndex[[message fromStr]] isEqualToString:[message correctedMessageID]];
    self.incomingMessageIDIndex[[message fromStr]] = [message elementID];
    XMPPLogInfo(@"Updated last incoming message ID for %@", [message fromStr]);
    
    if (!isValidCorrection) {
        return;
    }
    
    XMPPLogInfo(@"Received correction for message with ID: %@", [message correctedMessageID]);
    [self.storage storeIncomingCorrectedMessage:message forMessageWithID:[message correctedMessageID] withEvent:event];
    [multicastDelegate xmppLastMessageCorrection:self didReceiveCorrectedMessage:message];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    self.outgoingMessageIDIndex[[[message to] bare]] = [message elementID];
    XMPPLogInfo(@"Updated last sent message ID for %@", [[message to] bare]);
}

- (void)xmppCapabilities:(XMPPCapabilities *)sender collectingMyCapabilities:(NSXMLElement *)query
{
    XMPPLogTrace();
    NSXMLElement *lastMessageCorrectionFeatureElement = [NSXMLElement elementWithName:@"feature"];
    [lastMessageCorrectionFeatureElement addAttributeWithName:@"var" stringValue:XMPPLastMessageCorrectionNamespace];
    [query addChild:lastMessageCorrectionFeatureElement];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    XMPPLogTrace();
    [self.outgoingMessageIDIndex removeObjectForKey:[sender.roomJID bare]];
    XMPPLogInfo(@"Reset last sent message ID for MUC room %@", [sender.roomJID bare]);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    XMPPLogTrace();
    [self.incomingMessageIDIndex removeObjectForKey:[occupantJID full]];
    XMPPLogInfo(@"Reset last incoming message ID for MUC room occupant %@", [occupantJID full]);
}

- (void)xmppMUCLight:(XMPPMUCLight *)sender changedAffiliation:(NSString *)affiliation userJID:(XMPPJID *)userJID roomJID:(XMPPJID *)roomJID
{
    XMPPLogTrace();
    
    if ([affiliation isEqualToString:@"none"]) {
        return;
    }
    
    // TODO: member->owner and owner->member transitions should not break message correction continuity
    
    if ([userJID isEqualToJID:sender.xmppStream.myJID options:XMPPJIDCompareBare]) {
        [self.outgoingMessageIDIndex removeObjectForKey:[roomJID bare]];
        XMPPLogInfo(@"Reset last sent message ID for MUC Light room %@", [roomJID bare]);
    } else {
        XMPPJID *userRoomJID = [roomJID jidWithNewResource:[userJID bare]];
        [self.incomingMessageIDIndex removeObjectForKey:[userRoomJID full]];
        XMPPLogInfo(@"Reset last incoming message ID for MUC Light room occupant %@", [userRoomJID full]);
    }
}

@end
