#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPOutOfBandResourceMessaging.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageCoreDataStorage (XEP_0066) <XMPPOutOfBandResourceMessagingStorage>

- (void)storeOutOfBandResourceURIString:(NSString *)resourceURIString
                            description:(nullable NSString *)resourceDescription
                     forIncomingMessage:(XMPPMessage *)message
                              withEvent:(XMPPElementEvent *)event;

@end

@interface XMPPMessageBaseNode (XEP_0066)

- (nullable NSString *)outOfBandResourceInternalID;
- (nullable NSString *)outOfBandResourceURIString;
- (nullable NSString *)outOfBandResourceDescription;

- (void)assignOutOfBandResourceWithDescription:(nullable NSString *)resourceDescription forStreamEventID:(NSString *)streamEventID;
- (void)setAssignedOutOfBandResourceURIString:(NSString *)resourceURIString;

@end

NS_ASSUME_NONNULL_END
