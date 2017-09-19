#import "XMPPDelayedDelivery.h"
#import "XMPPLogging.h"
#import "NSXMLElement+XEP_0203.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface XMPPDelayedDelivery ()

@property (nonatomic, strong, readonly) id<XMPPDelayedDeliveryMessageStorage> messageStorage;

@end

@implementation XMPPDelayedDelivery

- (instancetype)initWithMessageStorage:(id<XMPPDelayedDeliveryMessageStorage>)messageStorage dispatchQueue:(dispatch_queue_t)queue
{
    self = [super initWithDispatchQueue:queue];
    if (self) {
        _messageStorage = messageStorage;
        if (_messageStorage && ![_messageStorage configureWithParent:self queue:moduleQueue]) {
            self = nil;
        }
    }
    return self;
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    return [self initWithMessageStorage:nil dispatchQueue:queue];
}

- (void)didActivate
{
    XMPPLogTrace();
}

- (void)willDeactivate
{
    XMPPLogTrace();
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event
{
    XMPPLogTrace();
    
    if (![message wasDelayed]) {
        return;
    }
    
    NSDate *delayedDeliveryDate = [message delayedDeliveryDate];
    XMPPJID *delayOriginJID = [message delayOriginJID];
    NSString *delayReasonDescription = [message delayReasonDescription];
    
    XMPPLogInfo(@"Received delayed delivery message with date: %@, origin: %@, reason description: %@",
                delayedDeliveryDate, delayOriginJID ?: @"unspecified", delayReasonDescription ?: @"unspecified");
    
    [self.messageStorage storeDelayedDeliveryDate:delayedDeliveryDate
                                   delayOriginJID:delayOriginJID
                           delayReasonDescription:delayReasonDescription
                               forIncomingMessage:message
                                        withEvent:event];
    
    [multicastDelegate xmppDelayedDelivery:self
                  didReceiveDelayedMessage:message
                   withDelayedDeliveryDate:delayedDeliveryDate
                            delayOriginJID:delayOriginJID
                    delayReasonDescription:delayReasonDescription];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    XMPPLogTrace();
    
    if (![presence wasDelayed]) {
        return;
    }
    
    NSDate *delayedDeliveryDate = [presence delayedDeliveryDate];
    XMPPJID *delayOriginJID = [presence delayOriginJID];
    NSString *delayReasonDescription = [presence delayReasonDescription];
    
    XMPPLogInfo(@"Received delayed delivery presence with date: %@, origin: %@, reason description: %@",
                delayedDeliveryDate, delayOriginJID ?: @"unspecified", delayReasonDescription ?: @"unspecified");
    
    [multicastDelegate xmppDelayedDelivery:self
                 didReceiveDelayedPresence:presence
                   withDelayedDeliveryDate:delayedDeliveryDate
                            delayOriginJID:delayOriginJID
                    delayReasonDescription:delayReasonDescription];
}

@end
