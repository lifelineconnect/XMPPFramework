#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class XMPPJID, XMPPMessage, XMPPMessageContextNode;

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

+ (XMPPMessageBaseNode *)findOrCreateForIncomingMessage:(XMPPMessage *)message
                                          withStreamJID:(XMPPJID *)streamJID
                                          streamEventID:(NSString *)streamEventID
                                 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (XMPPMessageBaseNode *)insertForOutgoingMessageToRecipientWithJID:(XMPPJID *)toJID
                                             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (XMPPMessage *)outgoingMessage;
- (void)registerOutgoingMessageInStreamWithJID:(XMPPJID *)streamJID streamEventID:(NSString *)streamEventID;

@end

@interface XMPPMessageBaseNode (CoreDataGeneratedRelationshipAccesssors)

- (void)addChildContextNodesObject:(XMPPMessageContextNode *)value;
- (void)removeChildContextNodesObject:(XMPPMessageContextNode *)value;
- (void)addChildContextNodes:(NSSet<XMPPMessageContextNode *> *)value;
- (void)removeChildContextNodes:(NSSet<XMPPMessageContextNode *> *)value;

@end

NS_ASSUME_NONNULL_END
