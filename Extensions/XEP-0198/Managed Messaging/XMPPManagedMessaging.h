#import "XMPPModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XMPPManagedMessagingStorage;
@class XMPPMessage, XMPPElementEvent;

@interface XMPPManagedMessaging : XMPPModule

- (instancetype)initWithStorage:(id<XMPPManagedMessagingStorage>)storage
                  dispatchQueue:(nullable dispatch_queue_t)dispatchQueue NS_DESIGNATED_INITIALIZER;

- (id)initWithDispatchQueue:(dispatch_queue_t)queue NS_UNAVAILABLE;
- (id)init NS_UNAVAILABLE;

@end

@protocol XMPPManagedMessagingStorage <NSObject>

- (BOOL)configureWithParent:(XMPPManagedMessaging *)aParent queue:(dispatch_queue_t)queue;

- (void)registerOutgoingManagedMessageID:(NSString *)messageID withEvent:(XMPPElementEvent *)event;
- (void)registerManagedMessageConfirmationForSentMessageIDs:(NSArray<NSString *> *)messageIDs;
- (void)registerManagedMessageFailureForUnconfirmedMessages;

@end

@protocol XMPPManagedMessagingDelegate <NSObject>

@optional
- (void)xmppManagedMessaging:(XMPPManagedMessaging *)sender didBeginMonitoringOutgoingMessage:(XMPPMessage *)message;
- (void)xmppManagedMessaging:(XMPPManagedMessaging *)sender didConfirmSentMessagesWithIDs:(NSArray<NSString *> *)messageIDs;
- (void)xmppManagedMessagingDidFinishProcessingPreviousStreamConfirmations:(XMPPManagedMessaging *)sender;

@end

NS_ASSUME_NONNULL_END
