#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class XMPPMessageBaseNode, XMPPMessage;

@interface XMPPMessageContextNode : NSManagedObject


- (void)applyContextToOutgoingMessage:(XMPPMessage *)message fromNode:(XMPPMessageBaseNode *)messageNode;

@end

@interface XMPPMessageContextNode (CoreDataGeneratedRelationshipAccesssors)


@end

NS_ASSUME_NONNULL_END
