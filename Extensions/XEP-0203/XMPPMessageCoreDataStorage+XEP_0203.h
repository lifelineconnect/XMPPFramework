#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPDelayedDelivery.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageCoreDataStorage (XEP_0203) <XMPPDelayedDeliveryMessageStorage>

- (void)storeDelayedDeliveryDate:(NSDate *)delayedDeliveryDate
                  delayOriginJID:(nullable XMPPJID *)delayOriginJID
          delayReasonDescription:(nullable NSString *)delayReasonDescription
              forIncomingMessage:(XMPPMessage *)message
                       withEvent:(XMPPElementEvent *)event;

@end

@interface XMPPMessageBaseNode (XEP_0203)

+ (NSPredicate *)delayedDeliveryContextPredicate;

- (nullable NSDate *)delayedDeliveryDate;
- (nullable XMPPJID *)delayedDeliveryOriginJID;
- (nullable NSString *)delayedDeliveryReasonDescription;

- (void)setDelayedDeliveryDate:(NSDate *)delayedDeliveryDate
                 withOriginJID:(nullable XMPPJID *)delayedDeliveryOriginJID
             reasonDescription:(nullable NSString *)delayedDeliveryReasonDescription
              forStreamEventID:(NSString *)streamEventID;

@end

NS_ASSUME_NONNULL_END
