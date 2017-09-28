#import "XMPPModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XMPPOneToOneChatStorage;
@class XMPPJID, XMPPMessage, XMPPElementEvent;

@interface XMPPOneToOneChat : XMPPModule

- (instancetype)initWithStorage:(nullable id<XMPPOneToOneChatStorage>)storage dispatchQueue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

@end

@protocol XMPPOneToOneChatStorage <NSObject>

- (BOOL)configureWithParent:(XMPPOneToOneChat *)aParent queue:(dispatch_queue_t)queue;
- (void)storeIncomingChatMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event;
- (void)registerSentChatMessageEvent:(XMPPElementEvent *)event;

@end

@protocol XMPPOneToOneChatDelegate <NSObject>

@optional
- (void)xmppOneToOneChat:(XMPPOneToOneChat *)xmppOneToOneChat didReceiveChatMessage:(XMPPMessage *)message;

@end

NS_ASSUME_NONNULL_END
