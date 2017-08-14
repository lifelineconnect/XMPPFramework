#import "XMPPMessageBaseNode.h"
#import "XMPPJID.h"
#import "XMPPMessage.h"
#import "XMPPMessageStreamEventNode.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"
#import "XMPPMessageStreamEventNode.h"

@interface XMPPMessageBaseNode ()

@property (nonatomic, copy, nullable) NSString *fromDomain;
@property (nonatomic, copy, nullable) NSString *fromResource;
@property (nonatomic, copy, nullable) NSString *fromUser;
@property (nonatomic, copy, nullable) NSString *toDomain;
@property (nonatomic, copy, nullable) NSString *toResource;
@property (nonatomic, copy, nullable) NSString *toUser;

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

@dynamic fromDomain, fromResource, fromUser, toDomain, toResource, toUser, body, stanzaID, subject, thread, type, parentContextNode, childContextNodes;

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

+ (XMPPMessageBaseNode *)findOrCreateForIncomingMessage:(XMPPMessage *)message withStreamJID:(XMPPJID *)streamJID streamEventID:(NSString *)streamEventID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    XMPPMessageStreamEventNode *existingStreamEventNode = [XMPPMessageStreamEventNode findWithID:streamEventID inManagedObjectContext:managedObjectContext];
    if (existingStreamEventNode) {
        return existingStreamEventNode.parentMessageNode;
    }
    
    XMPPMessageStreamEventNode *newStreamEventNode = [XMPPMessageStreamEventNode xmpp_insertNewObjectInManagedObjectContext:managedObjectContext];
    newStreamEventNode.eventID = streamEventID;
    newStreamEventNode.kind = XMPPMessageStreamEventKindIncoming;
    newStreamEventNode.streamJID = streamJID;
    
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:managedObjectContext];
    messageNode.fromJID = [message from];
    messageNode.toJID = [message to];
    messageNode.body = [message body];
    messageNode.stanzaID = [message elementID];
    messageNode.subject = [message subject];
    messageNode.thread = [message thread];
    
    if ([[message type] isEqualToString:@"chat"]) {
        messageNode.type = XMPPMessageTypeChat;
    } else if ([[message type] isEqualToString:@"error"]) {
        messageNode.type = XMPPMessageTypeError;
    } else if ([[message type] isEqualToString:@"groupchat"]) {
        messageNode.type = XMPPMessageTypeGroupchat;
    } else if ([[message type] isEqualToString:@"headline"]) {
        messageNode.type = XMPPMessageTypeHeadline;
    } else {
        messageNode.type = XMPPMessageTypeNormal;
    }
    
    [messageNode addChildContextNodesObject:newStreamEventNode];
    
    return messageNode;
}

+ (XMPPMessageBaseNode *)insertForOutgoingMessageToRecipientWithJID:(XMPPJID *)toJID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:managedObjectContext];
    messageNode.stanzaID = [NSUUID UUID].UUIDString;
    messageNode.toJID = toJID;
    return messageNode;
}

- (XMPPMessage *)outgoingMessage
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
    
    [self.parentContextNode applyContextToOutgoingMessage:message fromNode:self];
    for (XMPPMessageContextNode *childContextNode in self.childContextNodes) {
        [childContextNode applyContextToOutgoingMessage:message fromNode:self];
    }
    
    return message;
}

- (void)registerOutgoingMessageInStreamWithJID:(XMPPJID *)streamJID streamEventID:(NSString *)streamEventID
{
    NSAssert(self.managedObjectContext, @"Attempted to register an outgoing message event for a message node not associated with any managed object context");
    
    [self obsoleteOutgoingStreamEvents];
    
    XMPPMessageStreamEventNode *streamEventNode = [XMPPMessageStreamEventNode xmpp_insertNewObjectInManagedObjectContext:self.managedObjectContext];
    streamEventNode.eventID = streamEventID;
    streamEventNode.kind = XMPPMessageStreamEventKindOutgoing;
    streamEventNode.streamJID = streamJID;
    
    [self addChildContextNodesObject:streamEventNode];
}

#pragma mark - Overridden

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags
{
    [super awakeFromSnapshotEvents:flags];
    
    [self setPrimitiveFromJID:nil];
    [self setPrimitiveToJID:nil];
}

@end
