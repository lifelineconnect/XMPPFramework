#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPRoomLight.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageCoreDataStorage (XMPPMUCLight) <XMPPRoomLightStorage>

- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoomLight *)room event:(XMPPElementEvent *)event;
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoomLight *)room event:(XMPPElementEvent *)event;

@end

@interface XMPPMessageBaseNode (XMPPMUCLight)

+ (NSPredicate *)relevantMessageRoomJIDPredicateWithValue:(XMPPJID *)value;

@end
   
NS_ASSUME_NONNULL_END
