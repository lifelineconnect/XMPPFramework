#import "XMPPMessageBaseNode.h"
#import "XMPPMessageContextNode.h"
#import "XMPPMessageContextItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageBaseNode (ContextHelpers)

- (XMPPMessageContextNode *)appendContextNodeWithStreamEventID:(NSString *)streamEventID;
- (nullable id)lookupInContextWithBlock:(id __nullable (^)(XMPPMessageContextNode *contextNode))lookupBlock;

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

- (NSSet<XMPPJID *> *)jidItemValuesForTag:(XMPPMessageContextJIDItemTag)tag;
- (nullable XMPPJID *)jidItemValueForTag:(XMPPMessageContextJIDItemTag)tag;
- (NSInteger)markerItemCountForTag:(XMPPMessageContextMarkerItemTag)tag;
- (BOOL)hasMarkerItemForTag:(XMPPMessageContextMarkerItemTag)tag;
- (NSSet<NSString *> *)stringItemValuesForTag:(XMPPMessageContextStringItemTag)tag;
- (nullable NSString *)stringItemValueForTag:(XMPPMessageContextStringItemTag)tag;
- (NSSet<NSDate *> *)timestampItemValuesForTag:(XMPPMessageContextTimestampItemTag)tag;
- (nullable NSDate *)timestampItemValueForTag:(XMPPMessageContextTimestampItemTag)tag;

@end

NS_ASSUME_NONNULL_END
