#import "XMPPModule.h"

@protocol XMPPOutOfBandResourceMessagingStorage;
@class XMPPMessage, XMPPPresence, XMPPElementEvent;

NS_ASSUME_NONNULL_BEGIN

@interface XMPPOutOfBandResourceMessaging : XMPPModule

@property (copy, nullable) NSSet<NSString *> *relevantURLSchemes;

- (instancetype)initWithStorage:(nullable id<XMPPOutOfBandResourceMessagingStorage>)storage dispatchQueue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

@end

@protocol XMPPOutOfBandResourceMessagingStorage <NSObject>

- (BOOL)configureWithParent:(XMPPOutOfBandResourceMessaging *)aParent queue:(dispatch_queue_t)queue;
- (void)storeOutOfBandResourceURIString:(NSString *)resourceURIString
                            description:(nullable NSString *)resourceDescription
                     forIncomingMessage:(XMPPMessage *)message
                              withEvent:(XMPPElementEvent *)event;

@end

@protocol XMPPOutOfBandResourceMessagingDelegate <NSObject>

@optional
- (void)xmppOutOfBandResourceMessaging:(XMPPOutOfBandResourceMessaging *)xmppOutOfBandResourceMessaging didReceiveOutOfBandResourceMessage:(XMPPMessage *)message;

@end

NS_ASSUME_NONNULL_END
