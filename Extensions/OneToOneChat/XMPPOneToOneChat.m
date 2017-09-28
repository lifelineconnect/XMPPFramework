#import "XMPPOneToOneChat.h"
#import "XMPPMessage.h"
#import "XMPPLogging.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface XMPPOneToOneChat ()

@property (nonatomic, strong, readonly) id<XMPPOneToOneChatStorage> storage;

@end

@implementation XMPPOneToOneChat

- (instancetype)initWithStorage:(id<XMPPOneToOneChatStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    self = [super initWithDispatchQueue:queue];
    if (self) {
        _storage = storage;
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

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event
{
    XMPPLogTrace();
    
    if (![message isChatMessage]) {
        return;
    }
    
    XMPPLogInfo(@"Received chat message from %@", [message from]);
    [self.storage storeIncomingChatMessage:message inContextOfEvent:event];
    [multicastDelegate xmppOneToOneChat:self didReceiveChatMessage:message];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event
{
    XMPPLogTrace();
    
    if (![message isChatMessage]) {
        return;
    }
    
    XMPPLogInfo(@"Sent chat message to %@", [message to]);
    [self.storage registerSentChatMessageEvent:event];
}

@end
