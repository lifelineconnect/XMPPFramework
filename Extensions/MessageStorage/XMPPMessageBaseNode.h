#import <CoreData/CoreData.h>

@class XMPPJID, XMPPMessageContextNode;

typedef NS_ENUM(int16_t, XMPPMessageType) {
    XMPPMessageTypeNormal,
    XMPPMessageTypeChat,
    XMPPMessageTypeError,
    XMPPMessageTypeGroupchat,
    XMPPMessageTypeHeadline
};

@interface XMPPMessageBaseNode : NSManagedObject

@property (nonatomic, strong, nullable) XMPPJID *fromJID;
@property (nonatomic, strong, nullable) XMPPJID *toJID;

@property (nonatomic, copy, nullable) NSString *body;
@property (nonatomic, copy, nullable) NSString *stanzaID;
@property (nonatomic, copy, nullable) NSString *subject;
@property (nonatomic, copy, nullable) NSString *thread;

@property (nonatomic, assign) XMPPMessageType type;

@property (nonatomic, strong, nullable) XMPPMessageContextNode *parentContextNode;
@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextNode *> *childContextNodes;

@end

@interface XMPPMessageBaseNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addChildContextNodesObject:(nonnull XMPPMessageContextNode *)value;
- (void)removeChildContextNodesObject:(nonnull XMPPMessageContextNode *)value;
- (void)addChildContextNodes:(nonnull NSSet<XMPPMessageContextNode *> *)value;
- (void)removeChildContextNodes:(nonnull NSSet<XMPPMessageContextNode *> *)value;

@end
