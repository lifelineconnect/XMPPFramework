#import "XMPPMessageBaseNode.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPJID.h"
#import "XMPPMessage.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

static XMPPMessageContextJIDItemTag const XMPPMessageContextStreamJIDTag = @"XMPPMessageContextStreamJID";
static XMPPMessageContextMarkerItemTag const XMPPMessageContextPendingStreamContextAssignmentTag = @"XMPPMessageContextPendingStreamContextAssignment";
static XMPPMessageContextMarkerItemTag const XMPPMessageContextLatestStreamTimestampRetirementTag = @"XMPPMessageContextLatestStreamTimestampRetirement";
static XMPPMessageContextTimestampItemTag const XMPPMessageContextActiveStreamTimestampTag = @"XMPPMessageContextActiveStreamTimestamp";
static XMPPMessageContextTimestampItemTag const XMPPMessageContextRetiredStreamTimestampTag = @"XMPPMessageContextRetiredStreamTimestamp";

@interface XMPPMessageBaseNode ()

@property (nonatomic, copy, nullable) NSString *fromDomain;
@property (nonatomic, copy, nullable) NSString *fromResource;
@property (nonatomic, copy, nullable) NSString *fromUser;
@property (nonatomic, copy, nullable) NSString *toDomain;
@property (nonatomic, copy, nullable) NSString *toResource;
@property (nonatomic, copy, nullable) NSString *toUser;

@property (nonatomic, copy, nullable) NSSet<XMPPMessageContextNode *> *contextNodes;

@end

@interface XMPPMessageBaseNode (CoreDataGeneratedPrimitiveAccessors)

- (XMPPJID *)primitiveFromJID;
- (void)setPrimitiveFromJID:(XMPPJID *)value;
- (void)setPrimitiveFromDomain:(NSString *)value;
- (void)setPrimitiveFromResource:(NSString *)value;
- (void)setPrimitiveFromUser:(NSString *)value;

- (XMPPJID *)primitiveToJID;
- (void)setPrimitiveToJID:(XMPPJID *)value;
- (void)setPrimitiveToDomain:(NSString *)value;
- (void)setPrimitiveToResource:(NSString *)value;
- (void)setPrimitiveToUser:(NSString *)value;

@end

@implementation XMPPMessageBaseNode

@dynamic fromDomain, fromResource, fromUser, toDomain, toResource, toUser, body, stanzaID, subject, thread, direction, type, contextNodes;

#pragma mark - fromJID transient property

- (XMPPJID *)fromJID
{
    [self willAccessValueForKey:NSStringFromSelector(@selector(fromJID))];
    XMPPJID *fromJID = [self primitiveFromJID];
    [self didAccessValueForKey:NSStringFromSelector(@selector(fromJID))];
    
    if (fromJID) {
        return fromJID;
    }
    
    XMPPJID *newFromJID = [XMPPJID jidWithUser:self.fromUser domain:self.fromDomain resource:self.fromResource];
    [self setPrimitiveFromJID:newFromJID];
    
    return newFromJID;
}

- (void)setFromJID:(XMPPJID *)fromJID
{
    if ([self.fromJID isEqualToJID:fromJID options:XMPPJIDCompareFull]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromUser))];
    [self setPrimitiveFromJID:fromJID];
    [self setPrimitiveFromDomain:fromJID.domain];
    [self setPrimitiveFromResource:fromJID.resource];
    [self setPrimitiveFromUser:fromJID.user];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromDomain))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromResource))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromUser))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
}

- (void)setFromDomain:(NSString *)fromDomain
{
    if ([self.fromDomain isEqualToString:fromDomain]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self setPrimitiveFromDomain:fromDomain];
    [self setPrimitiveFromJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromDomain))];
}

- (void)setFromResource:(NSString *)fromResource
{
    if ([self.fromResource isEqualToString:fromResource]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self setPrimitiveFromResource:fromResource];
    [self setPrimitiveFromJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromResource))];
}

- (void)setFromUser:(NSString *)fromUser
{
    if ([self.fromUser isEqualToString:fromUser]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromUser))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self setPrimitiveFromUser:fromUser];
    [self setPrimitiveFromJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(fromUser))];
}

#pragma mark - toJID transient property

- (XMPPJID *)toJID
{
    [self willAccessValueForKey:NSStringFromSelector(@selector(toJID))];
    XMPPJID *toJID = [self primitiveToJID];
    [self didAccessValueForKey:NSStringFromSelector(@selector(toJID))];
    
    if (toJID) {
        return toJID;
    }
    
    XMPPJID *newToJID = [XMPPJID jidWithUser:self.toUser domain:self.toDomain resource:self.toResource];
    [self setPrimitiveToJID:newToJID];
    
    return newToJID;
}

- (void)setToJID:(XMPPJID *)toJID
{
    if ([self.toJID isEqualToJID:toJID options:XMPPJIDCompareFull]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(toDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(toResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(toUser))];
    [self setPrimitiveToJID:toJID];
    [self setPrimitiveToDomain:toJID.domain];
    [self setPrimitiveToResource:toJID.resource];
    [self setPrimitiveToUser:toJID.user];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toDomain))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toResource))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toUser))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toJID))];
}

- (void)setToDomain:(NSString *)toDomain
{
    if ([self.toDomain isEqualToString:toDomain]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(toDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self setPrimitiveToDomain:toDomain];
    [self setPrimitiveToJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toDomain))];
}

- (void)setToResource:(NSString *)toResource
{
    if ([self.toResource isEqualToString:toResource]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(toResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self setPrimitiveToResource:toResource];
    [self setPrimitiveToJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toResource))];
}

- (void)setToUser:(NSString *)toUser
{
    if ([self.toUser isEqualToString:toUser]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(toUser))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self setPrimitiveToUser:toUser];
    [self setPrimitiveToJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(toUser))];
}

#pragma mark - Public

+ (XMPPMessageBaseNode *)findOrCreateForIncomingMessageStreamEventID:(NSString *)incomingMessageStreamEventID streamJID:(XMPPJID *)streamJID withMessage:(XMPPMessage *)incomingMessage timestamp:(NSDate *)timestamp inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [XMPPMessageContextJIDItem xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSCompoundPredicate
                              andPredicateWithSubpredicates:@[[XMPPMessageContextJIDItem streamEventIDPredicateWithValue:incomingMessageStreamEventID],
                                                              [XMPPMessageContextJIDItem tagPredicateWithValue:XMPPMessageContextStreamJIDTag],
                                                              [XMPPMessageContextJIDItem jidPredicateWithValue:streamJID compareOptions:XMPPJIDCompareFull]]];
    
    NSArray *fetchResult = [managedObjectContext xmpp_executeForcedSuccessFetchRequest:fetchRequest];
    NSAssert(fetchResult.count <= 1, @"Expected a single context node for any given stream event ID/stream JID");
    
    XMPPMessageContextJIDItem *existingStreamJIDItem = fetchResult.firstObject;
    if (existingStreamJIDItem) {
        NSAssert(existingStreamJIDItem.contextNode.messageNode.direction == XMPPMessageDirectionIncoming, @"Expected an incoming message node");
        NSAssert([[existingStreamJIDItem.contextNode.messageNode streamTimestamp] isEqualToDate:timestamp], @"Timestamp does not match the existing message");
        return existingStreamJIDItem.contextNode.messageNode;
    }
    
    XMPPMessageBaseNode *insertedMessageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:managedObjectContext];
    insertedMessageNode.fromJID = [incomingMessage from];
    insertedMessageNode.toJID = [incomingMessage to];
    insertedMessageNode.body = [incomingMessage body];
    insertedMessageNode.stanzaID = [incomingMessage elementID];
    insertedMessageNode.subject = [incomingMessage subject];
    insertedMessageNode.thread = [incomingMessage thread];
    insertedMessageNode.direction = XMPPMessageDirectionIncoming;
    
    if ([[incomingMessage type] isEqualToString:@"chat"]) {
        insertedMessageNode.type = XMPPMessageTypeChat;
    } else if ([[incomingMessage type] isEqualToString:@"error"]) {
        insertedMessageNode.type = XMPPMessageTypeError;
    } else if ([[incomingMessage type] isEqualToString:@"groupchat"]) {
        insertedMessageNode.type = XMPPMessageTypeGroupchat;
    } else if ([[incomingMessage type] isEqualToString:@"headline"]) {
        insertedMessageNode.type = XMPPMessageTypeHeadline;
    } else {
        insertedMessageNode.type = XMPPMessageTypeNormal;
    }
    
    XMPPMessageContextNode *insertedStreamContextNode = [insertedMessageNode appendContextNodeWithStreamEventID:incomingMessageStreamEventID];
    [insertedStreamContextNode appendJIDItemWithTag:XMPPMessageContextStreamJIDTag value:streamJID];
    [insertedStreamContextNode appendTimestampItemWithTag:XMPPMessageContextActiveStreamTimestampTag value:timestamp];
    
    return insertedMessageNode;
}

+ (instancetype)insertForOutgoingMessageInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    XMPPMessageBaseNode *messageNode = [self xmpp_insertNewObjectInManagedObjectContext:managedObjectContext];
    messageNode.direction = XMPPMessageDirectionOutgoing;
    return messageNode;
}

+ (XMPPMessageBaseNode *)findForOutgoingMessageStreamEventID:(NSString *)outgoingMessageStreamEventID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [XMPPMessageContextMarkerItem xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSCompoundPredicate
                              andPredicateWithSubpredicates:@[[XMPPMessageContextMarkerItem streamEventIDPredicateWithValue:outgoingMessageStreamEventID],
                                                              [XMPPMessageContextMarkerItem tagPredicateWithValue:XMPPMessageContextPendingStreamContextAssignmentTag]]];
    
    NSArray *fetchResult = [managedObjectContext xmpp_executeForcedSuccessFetchRequest:fetchRequest];
    NSAssert(fetchResult.count <= 1, @"Expected a single outgoing message context node for any given stream event ID");
    
    XMPPMessageContextMarkerItem *localInsertionItem = fetchResult.firstObject;
    return localInsertionItem.contextNode.messageNode;
}

+ (NSFetchRequest<id<XMPPMessageContextFetchRequestResult>> *)requestTimestampContextWithPredicate:(NSPredicate *)predicate inAscendingOrder:(BOOL)isInAscendingOrder fromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [XMPPMessageContextTimestampItem xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(value)) ascending:isInAscendingOrder]];
    return fetchRequest;
}

+ (NSPredicate *)streamTimestampContextPredicate
{
    return [XMPPMessageContextTimestampItem tagPredicateWithValue:XMPPMessageContextActiveStreamTimestampTag];
}

+ (NSPredicate *)relevantMessageFromJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions
{
    return [XMPPMessageContextItem messageJIDPredicateWithDomainKeyPath:NSStringFromSelector(@selector(fromDomain))
                                                        resourceKeyPath:NSStringFromSelector(@selector(fromResource))
                                                            userKeyPath:NSStringFromSelector(@selector(fromUser))
                                                                  value:value compareOptions:compareOptions];
}

+ (NSPredicate *)relevantMessageToJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions
{
    return [XMPPMessageContextItem messageJIDPredicateWithDomainKeyPath:NSStringFromSelector(@selector(toDomain))
                                                        resourceKeyPath:NSStringFromSelector(@selector(toResource))
                                                            userKeyPath:NSStringFromSelector(@selector(toUser))
                                                                  value:value compareOptions:compareOptions];
}

+ (NSPredicate *)relevantMessageRemotePartyJIDPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions
{
    NSPredicate *outgoingMessagePredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[[self relevantMessageToJIDPredicateWithValue:value compareOptions:compareOptions],
                                                         [XMPPMessageContextItem messageDirectionPredicateWithValue:XMPPMessageDirectionOutgoing]]];
    NSPredicate *incomingMessagePredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[[self relevantMessageFromJIDPredicateWithValue:value compareOptions:compareOptions],
                                                         [XMPPMessageContextItem messageDirectionPredicateWithValue:XMPPMessageDirectionIncoming]]];
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:@[outgoingMessagePredicate, incomingMessagePredicate]];
}

+ (NSPredicate *)contextTimestampRangePredicateWithStartValue:(nullable NSDate *)startValue endValue:(nullable NSDate *)endValue
{
    return [XMPPMessageContextTimestampItem timestampRangePredicateWithStartValue:startValue endValue:endValue];
}

- (XMPPMessage *)baseMessage
{
    NSString *typeString;
    switch (self.type) {
        case XMPPMessageTypeChat:
            typeString = @"chat";
            break;
            
        case XMPPMessageTypeError:
            typeString = @"error";
            break;
            
        case XMPPMessageTypeGroupchat:
            typeString = @"groupchat";
            break;
            
        case XMPPMessageTypeHeadline:
            typeString = @"headline";
            break;
            
        case XMPPMessageTypeNormal:
            typeString = @"normal";
            break;
    }
    
    XMPPMessage *message = [[XMPPMessage alloc] initWithType:typeString to:self.toJID elementID:self.stanzaID];
    
    if (self.body) {
        [message addBody:self.body];
    }
    if (self.subject) {
        [message addSubject:self.subject];
    }
    if (self.thread) {
        [message addThread:self.thread];
    }
    
    return message;
}

- (void)registerOutgoingMessageStreamEventID:(NSString *)outgoingMessageStreamEventID
{
    XMPPMessageContextNode *outgoingMessageNode = [self appendContextNodeWithStreamEventID:outgoingMessageStreamEventID];
    [outgoingMessageNode appendMarkerItemWithTag:XMPPMessageContextPendingStreamContextAssignmentTag];
}

- (void)registerSentMessageWithStreamJID:(XMPPJID *)streamJID timestamp:(NSDate *)timestamp
{
    NSAssert(self.direction == XMPPMessageDirectionOutgoing, @"Sent message registration is only applicable to outgoing message nodes");
    
    XMPPMessageContextNode *pendingOutgoingMessageNode = [self lookupPendingStreamContextNode];
    NSAssert(pendingOutgoingMessageNode, @"No pending stream context node found");
    
    XMPPMessageContextTimestampItemTag timestampTag;
    if ([self lookupActiveStreamContextNode]) {
        [self retireStreamTimestamp];
        timestampTag = XMPPMessageContextActiveStreamTimestampTag;
    } else if (![self lookupLatestRetiredStreamContextNode]) {
        timestampTag = XMPPMessageContextActiveStreamTimestampTag;
    } else {
        timestampTag = XMPPMessageContextRetiredStreamTimestampTag;
    }
    
    [pendingOutgoingMessageNode removeMarkerItemsWithTag:XMPPMessageContextPendingStreamContextAssignmentTag];
    [pendingOutgoingMessageNode appendJIDItemWithTag:XMPPMessageContextStreamJIDTag value:streamJID];
    [pendingOutgoingMessageNode appendTimestampItemWithTag:timestampTag value:timestamp];
}

- (XMPPJID *)streamJID
{
    return [[self lookupCurrentStreamContextNode] jidItemValueForTag:XMPPMessageContextStreamJIDTag];
}

- (NSDate *)streamTimestamp
{
    XMPPMessageContextNode *latestStreamContextNode = [self lookupCurrentStreamContextNode];
    return [latestStreamContextNode timestampItemValueForTag:XMPPMessageContextActiveStreamTimestampTag] ?: [latestStreamContextNode timestampItemValueForTag:XMPPMessageContextRetiredStreamTimestampTag];
}

- (void)retireStreamTimestamp
{
    XMPPMessageContextNode *previousRetiredStreamTimestampNode = [self lookupLatestRetiredStreamContextNode];
    XMPPMessageContextNode *activeStreamTimestampNode = [self lookupActiveStreamContextNode];
    
    if (activeStreamTimestampNode) {
        [previousRetiredStreamTimestampNode removeMarkerItemsWithTag:XMPPMessageContextLatestStreamTimestampRetirementTag];
        
        NSDate *retiredStreamTimestamp = [activeStreamTimestampNode timestampItemValueForTag:XMPPMessageContextActiveStreamTimestampTag];
        [activeStreamTimestampNode removeTimestampItemsWithTag:XMPPMessageContextActiveStreamTimestampTag];
        [activeStreamTimestampNode appendTimestampItemWithTag:XMPPMessageContextRetiredStreamTimestampTag value:retiredStreamTimestamp];
        [activeStreamTimestampNode appendMarkerItemWithTag:XMPPMessageContextLatestStreamTimestampRetirementTag];
    } else if (!previousRetiredStreamTimestampNode) {
        XMPPMessageContextNode *initialPendingStreamTimestampNode = [self lookupPendingStreamContextNode];
        [initialPendingStreamTimestampNode appendMarkerItemWithTag:XMPPMessageContextLatestStreamTimestampRetirementTag];
    } else {
        NSAssert(NO, @"No stream context node found for retiring");
    }
}

#pragma mark - Overridden

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags
{
    [super awakeFromSnapshotEvents:flags];
    
    [self setPrimitiveFromJID:nil];
    [self setPrimitiveToJID:nil];
}

#pragma mark - Private

- (XMPPMessageContextNode *)lookupPendingStreamContextNode
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode hasMarkerItemForTag:XMPPMessageContextPendingStreamContextAssignmentTag] ? contextNode : nil;
    }];
}

- (XMPPMessageContextNode *)lookupCurrentStreamContextNode
{
    return [self lookupActiveStreamContextNode] ?: [self lookupLatestRetiredStreamContextNode];
}

- (XMPPMessageContextNode *)lookupActiveStreamContextNode
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode timestampItemValueForTag:XMPPMessageContextActiveStreamTimestampTag] ? contextNode : nil;
    }];
}

- (XMPPMessageContextNode *)lookupLatestRetiredStreamContextNode
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode hasMarkerItemForTag:XMPPMessageContextLatestStreamTimestampRetirementTag] ? contextNode : nil;
    }];
}

@end
