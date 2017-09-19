#import "XMPP.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XMPPDelayedDeliveryMessageStorage, XMPPDelayedDeliveryDelegate;

@interface XMPPDelayedDelivery : XMPPModule

- (instancetype)initWithMessageStorage:(nullable id<XMPPDelayedDeliveryMessageStorage>)messageStorage dispatchQueue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

@end

@protocol XMPPDelayedDeliveryMessageStorage <NSObject>

- (BOOL)configureWithParent:(XMPPDelayedDelivery *)aParent queue:(dispatch_queue_t)queue;
- (void)storeDelayedDeliveryDate:(NSDate *)delayedDeliveryDate
                  delayOriginJID:(nullable XMPPJID *)delayOriginJID
          delayReasonDescription:(nullable NSString *)delayReasonDescription
              forIncomingMessage:(XMPPMessage *)message
                       withEvent:(XMPPElementEvent *)event;

@end

@protocol XMPPDelayedDeliveryDelegate <NSObject>

@optional

- (void)xmppDelayedDelivery:(XMPPDelayedDelivery *)xmppDelayedDelivery didReceiveDelayedMessage:(XMPPMessage *)delayedMessage withDelayedDeliveryDate:(NSDate *)delayedDeliveryDate delayOriginJID:(nullable XMPPJID *)delayOriginJID delayReasonDescription:(nullable NSString *)delayReasonDescription;
- (void)xmppDelayedDelivery:(XMPPDelayedDelivery *)xmppDelayedDelivery didReceiveDelayedPresence:(XMPPPresence *)delayedPresence withDelayedDeliveryDate:(NSDate *)delayedDeliveryDate delayOriginJID:(nullable XMPPJID *)delayOriginJID delayReasonDescription:(nullable NSString *)delayReasonDescription;

@end

NS_ASSUME_NONNULL_END
