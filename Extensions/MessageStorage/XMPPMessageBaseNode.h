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

+ (XMPPMessageBaseNode *)findOrCreateForIncomingMessage:(XMPPMessage *)message
                                          withStreamJID:(XMPPJID *)streamJID
                                          streamEventID:(NSString *)streamEventID
                                 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (XMPPMessageBaseNode *)insertForOutgoingMessageToRecipientWithJID:(XMPPJID *)toJID
                                             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (XMPPMessage *)outgoingMessage;
- (void)registerOutgoingMessageInStreamWithJID:(XMPPJID *)streamJID streamEventID:(NSString *)streamEventID;




@end

NS_ASSUME_NONNULL_END
