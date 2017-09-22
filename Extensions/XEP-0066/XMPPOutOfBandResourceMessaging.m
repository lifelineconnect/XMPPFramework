#import "XMPPOutOfBandResourceMessaging.h"
#import "XMPPMessage+XEP_0066.h"
#import "XMPPStream.h"
#import "XMPPLogging.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface XMPPOutOfBandResourceMessaging ()

@property (strong, nonatomic, readonly) id<XMPPOutOfBandResourceMessagingStorage> storage;

@end

@implementation XMPPOutOfBandResourceMessaging

@synthesize relevantURLSchemes = _relevantURLSchemes;

- (NSSet<NSString *> *)relevantURLSchemes
{
    __block NSSet *result;
    dispatch_block_t block = ^{
        result = _relevantURLSchemes;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setRelevantURLSchemes:(NSSet<NSString *> *)relevantURLSchemes
{
    NSSet *newValue = [relevantURLSchemes copy];
    dispatch_block_t block = ^{
        _relevantURLSchemes = newValue;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (instancetype)initWithStorage:(id<XMPPOutOfBandResourceMessagingStorage>)storage dispatchQueue:(dispatch_queue_t)queue
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
    
    if (![message hasOutOfBandData]) {
        return;
    }
    
    NSString *resourceURIString = [message outOfBandURI];
    if (self.relevantURLSchemes) {
        NSURL *resourceURL = [NSURL URLWithString:resourceURIString];
        if (!resourceURL.scheme || ![self.relevantURLSchemes containsObject:resourceURL.scheme]) {
            return;
        }
    }
    NSString *resourceDescription = [message outOfBandDesc];
    
    XMPPLogInfo(@"Received out of band resource message with event ID: %@", event.uniqueID);
    
    [self.storage storeOutOfBandResourceURIString:resourceURIString description:resourceDescription forIncomingMessage:message withEvent:event];
    [multicastDelegate xmppOutOfBandResourceMessaging:self didReceiveOutOfBandResourceMessage:message];
}

@end
