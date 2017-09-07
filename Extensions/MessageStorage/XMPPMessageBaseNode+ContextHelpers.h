#import "XMPPMessageBaseNode.h"
#import "XMPPMessageContextNode.h"
#import "XMPPMessageContextItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageBaseNode (ContextHelpers)

- (XMPPMessageContextNode *)appendContextNodeWithStreamEventID:(NSString *)streamEventID;

@end

@interface XMPPMessageContextNode (ContextHelpers)

- (XMPPMessageContextJIDItem *)appendJIDItemWithTag:(XMPPMessageContextJIDItemTag)tag value:(XMPPJID *)value;
- (XMPPMessageContextMarkerItem *)appendMarkerItemWithTag:(XMPPMessageContextMarkerItemTag)tag;
- (XMPPMessageContextStringItem *)appendStringItemWithTag:(XMPPMessageContextStringItemTag)tag value:(NSString *)value;
- (XMPPMessageContextTimestampItem *)appendTimestampItemWithTag:(XMPPMessageContextTimestampItemTag)tag value:(NSDate *)value;

- (void)removeJIDItemsWithTag:(XMPPMessageContextJIDItemTag)tag;
- (void)removeMarkerItemsWithTag:(XMPPMessageContextMarkerItemTag)tag;
- (void)removeStringItemsWithTag:(XMPPMessageContextStringItemTag)tag;
- (void)removeTimestampItemsWithTag:(XMPPMessageContextTimestampItemTag)tag;

@end

NS_ASSUME_NONNULL_END
