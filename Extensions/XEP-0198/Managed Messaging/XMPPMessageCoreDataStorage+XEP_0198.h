#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPManagedMessaging.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XMPPManagedMessagingStatus) {
    XMPPManagedMessagingStatusUnspecified,
    XMPPManagedMessagingStatusPendingAcknowledgement,
    XMPPManagedMessagingStatusAcknowledged,
    XMPPManagedMessagingStatusUnacknowledged
};

@interface XMPPMessageCoreDataStorage (XEP_0198) <XMPPManagedMessagingStorage>

- (void)registerOutgoingManagedMessageID:(NSString *)messageID withEvent:(XMPPElementEvent *)event;
- (void)registerManagedMessageConfirmationForSentMessageIDs:(NSArray<NSString *> *)messageIDs;
- (void)registerManagedMessageFailureForUnconfirmedMessages;

@end

@interface XMPPMessageBaseNode (XEP_0198)

- (XMPPManagedMessagingStatus)managedMessagingStatus;

@end

NS_ASSUME_NONNULL_END
