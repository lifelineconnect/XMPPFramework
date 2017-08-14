#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class XMPPMessageBaseNode, XMPPMessage;

@interface XMPPMessageContextNode : NSManagedObject

@property (nonatomic, strong, nullable) XMPPMessageBaseNode *parentMessageNode;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageBaseNode *> *childMessageNodes;

- (void)applyContextToOutgoingMessage:(XMPPMessage *)message fromNode:(XMPPMessageBaseNode *)messageNode;

@end

@interface XMPPMessageContextNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addChildMessageNodesObject:(XMPPMessageBaseNode *)value;
- (void)removeChildMessageNodesObject:(XMPPMessageBaseNode *)value;
- (void)addChildMessageNodes:(NSSet<XMPPMessageBaseNode *> *)value;
- (void)removeChildMessageNodes:(NSSet<XMPPMessageBaseNode *> *)value;

@end

NS_ASSUME_NONNULL_END
