#import "XMPPMessageCoreDataStorage.h"
#import "XMPPOneToOneChat.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageCoreDataStorage (XMPPOneToOneChat) <XMPPOneToOneChatStorage>

- (void)storeIncomingChatMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event;
- (void)registerSentChatMessageEvent:(XMPPElementEvent *)event;

@end

NS_ASSUME_NONNULL_END
