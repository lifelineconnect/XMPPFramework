#import <CoreData/CoreData.h>

@class XMPPMessageBaseNode;

@interface XMPPMessageContextNode : NSManagedObject

@property (nonatomic, strong, nullable) XMPPMessageBaseNode *parentMessageNode;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageBaseNode *> *childMessageNodes;

@end

@interface XMPPMessageContextNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addChildMessageNodesObject:(nonnull XMPPMessageBaseNode *)value;
- (void)removeChildMessageNodesObject:(nonnull XMPPMessageBaseNode *)value;
- (void)addChildMessageNodes:(nonnull NSSet<XMPPMessageBaseNode *> *)value;
- (void)removeChildMessageNodes:(nonnull NSSet<XMPPMessageBaseNode *> *)value;

@end
