#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class XMPPMessageBaseNode, XMPPMessageContextJIDItem, XMPPMessageContextMarkerItem, XMPPMessageContextStringItem, XMPPMessageContextTimestampItem, XMPPMessage;

@interface XMPPMessageContextNode : NSManagedObject

@property (nonatomic, copy, nullable) NSString *streamEventID;

- (void)applyContextToOutgoingMessage:(XMPPMessage *)message fromNode:(XMPPMessageBaseNode *)messageNode;
@property (nonatomic, strong, nullable) XMPPMessageBaseNode *messageNode;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextJIDItem *> *jidItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextMarkerItem *> *markerItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextStringItem *> *stringItems;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextTimestampItem *> *timestampItems;

@end

@interface XMPPMessageContextNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addJidItemsObject:(XMPPMessageContextJIDItem *)value;
- (void)removeJidItemsObject:(XMPPMessageContextJIDItem *)value;
- (void)addJidItems:(NSSet<XMPPMessageContextJIDItem *> *)value;
- (void)removeJidItems:(NSSet<XMPPMessageContextJIDItem *> *)value;

- (void)addMarkerItemsObject:(XMPPMessageContextMarkerItem *)value;
- (void)removeMarkerItemsObject:(XMPPMessageContextMarkerItem *)value;
- (void)addMarkerItems:(NSSet<XMPPMessageContextMarkerItem *> *)value;
- (void)removeMarkerItems:(NSSet<XMPPMessageContextMarkerItem *> *)value;

- (void)addStringItemsObject:(XMPPMessageContextStringItem *)value;
- (void)removeStringItemsObject:(XMPPMessageContextStringItem *)value;
- (void)addStringItems:(NSSet<XMPPMessageContextStringItem *> *)value;
- (void)removeStringItems:(NSSet<XMPPMessageContextStringItem *> *)value;

- (void)addTimestampItemsObject:(XMPPMessageContextTimestampItem *)value;
- (void)removeTimestampItemsObject:(XMPPMessageContextTimestampItem *)value;
- (void)addTimestampItems:(NSSet<XMPPMessageContextTimestampItem *> *)value;
- (void)removeTimestampItems:(NSSet<XMPPMessageContextTimestampItem *> *)value;

@end

NS_ASSUME_NONNULL_END
