#import <CoreData/CoreData.h>
#import "XMPPJID.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPMessageBaseNode, XMPPJID, XMPPMessage;

typedef NS_ENUM(int16_t, XMPPMessageDirection) {
    XMPPMessageDirectionUnspecified,
    XMPPMessageDirectionIncoming,
    XMPPMessageDirectionOutgoing
};

typedef NS_ENUM(int16_t, XMPPMessageType) {
    XMPPMessageTypeNormal,
    XMPPMessageTypeChat,
    XMPPMessageTypeError,
    XMPPMessageTypeGroupchat,
    XMPPMessageTypeHeadline
};

@protocol XMPPMessageContextFetchRequestResult <NSFetchRequestResult>

@property (nonatomic, strong, readonly) XMPPMessageBaseNode *relevantMessageNode;

@end

@interface XMPPMessageBaseNode : NSManagedObject

@property (nonatomic, strong, nullable) XMPPJID *fromJID;
@property (nonatomic, strong, nullable) XMPPJID *toJID;

@property (nonatomic, copy, nullable) NSString *body;
@property (nonatomic, copy, nullable) NSString *stanzaID;
@property (nonatomic, copy, nullable) NSString *subject;
@property (nonatomic, copy, nullable) NSString *thread;

@property (nonatomic, assign) XMPPMessageDirection direction;
@property (nonatomic, assign) XMPPMessageType type;

+ (XMPPMessageBaseNode *)findOrCreateForIncomingMessageStreamEventID:(NSString *)incomingMessageStreamEventID
                                                           streamJID:(XMPPJID *)streamJID
                                                         withMessage:(XMPPMessage *)incomingMessage
                                                           timestamp:(NSDate *)timestamp
                                              inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)insertForOutgoingMessageInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable XMPPMessageBaseNode *)findForOutgoingMessageStreamEventID:(NSString *)outgoingMessageStreamEventID
                                               inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSFetchRequest<id<XMPPMessageContextFetchRequestResult>> *)requestTimestampContextWithPredicate:(NSPredicate *)predicate
                                                                              inAscendingOrder:(BOOL)isInAscendingOrder
                                                                      fromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSPredicate *)streamTimestampContextPredicate;
+ (NSPredicate *)relevantMessageFromJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)relevantMessageToJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)relevantMessageRemotePartyJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)contextTimestampRangePredicateWithStartValue:(nullable NSDate *)startValue endValue:(nullable NSDate *)endValue;

- (XMPPMessage *)baseMessage;

- (void)registerOutgoingMessageStreamEventID:(NSString *)outgoingMessageStreamEventID;
- (void)registerSentMessageWithStreamJID:(XMPPJID *)streamJID timestamp:(NSDate *)timestamp;

- (nullable XMPPJID *)streamJID;
- (nullable NSDate *)streamTimestamp;

@end

NS_ASSUME_NONNULL_END
