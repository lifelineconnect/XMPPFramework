#import "XMPPMessageBaseNode.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPMessageContextNode, XMPPMessageContextJIDItem, XMPPMessageContextMarkerItem, XMPPMessageContextStringItem, XMPPMessageContextTimestampItem;

@interface XMPPMessageBaseNode (Protected)

@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextNode *> *contextNodes;

- (void)retireStreamTimestamp;

@end

@interface XMPPMessageBaseNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addContextNodesObject:(XMPPMessageContextNode *)value;
- (void)removeContextNodesObject:(XMPPMessageContextNode *)value;
- (void)addContextNodes:(NSSet<XMPPMessageContextNode *> *)value;
- (void)removeContextNodes:(NSSet<XMPPMessageContextNode *> *)value;

@end

NS_ASSUME_NONNULL_END
