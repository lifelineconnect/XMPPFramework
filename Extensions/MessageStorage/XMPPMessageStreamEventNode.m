#import "XMPPMessageStreamEventNode.h"
#import "XMPPJID.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

@interface XMPPMessageStreamEventNode ()

@property (nonatomic, copy, nullable) NSString *streamDomain;
@property (nonatomic, copy, nullable) NSString *streamResource;
@property (nonatomic, copy, nullable) NSString *streamUser;

@end

@interface XMPPMessageStreamEventNode (CoreDataGeneratedPrimitiveAccessors)

- (XMPPJID *)primitiveStreamJID;
- (void)setPrimitiveStreamJID:(XMPPJID *)value;
- (void)setPrimitiveStreamDomain:(NSString *)value;
- (void)setPrimitiveStreamResource:(NSString *)value;
- (void)setPrimitiveStreamUser:(NSString *)value;

@end

@implementation XMPPMessageStreamEventNode

@dynamic eventID, kind, streamDomain, streamResource, streamUser;

#pragma mark - streamJID transient property

- (XMPPJID *)streamJID
{
    [self willAccessValueForKey:NSStringFromSelector(@selector(streamJID))];
    XMPPJID *streamJID = [self primitiveStreamJID];
    [self didAccessValueForKey:NSStringFromSelector(@selector(streamJID))];
    
    if (streamJID) {
        return streamJID;
    }
    
    XMPPJID *newStreamJID = [XMPPJID jidWithUser:self.streamUser domain:self.streamDomain resource:self.streamResource];
    [self setPrimitiveStreamJID:newStreamJID];
    
    return newStreamJID;
}

- (void)setStreamJID:(XMPPJID *)streamJID
{
    if ([self.streamJID isEqualToJID:streamJID options:XMPPJIDCompareFull]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamUser))];
    [self setPrimitiveStreamJID:streamJID];
    [self setPrimitiveStreamDomain:streamJID.domain];
    [self setPrimitiveStreamResource:streamJID.resource];
    [self setPrimitiveStreamUser:streamJID.user];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamDomain))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamResource))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamUser))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
}

- (void)setStreamDomain:(NSString *)streamDomain
{
    if ([self.streamDomain isEqualToString:streamDomain]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamDomain))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self setPrimitiveStreamDomain:streamDomain];
    [self setPrimitiveStreamJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamDomain))];
}

- (void)setStreamResource:(NSString *)streamResource
{
    if ([self.streamResource isEqualToString:streamResource]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamResource))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self setPrimitiveStreamResource:streamResource];
    [self setPrimitiveStreamJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamResource))];
}

- (void)setStreamUser:(NSString *)streamUser
{
    if ([self.streamUser isEqualToString:streamUser]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamUser))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self setPrimitiveStreamUser:streamUser];
    [self setPrimitiveStreamJID:nil];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamJID))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(streamUser))];
}

#pragma mark - Public

+ (XMPPMessageStreamEventNode *)findWithID:(NSString *)streamEventID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [self xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", NSStringFromSelector(@selector(eventID)), streamEventID];
    
    NSArray *fetchResult = [managedObjectContext xmpp_executeForcedSuccessFetchRequest:fetchRequest];
    NSAssert(fetchResult.count <= 1, @"Multiple XMPPMessageStreamEventNode instances found for ID");
    
    return fetchResult.firstObject;
}

#pragma mark - Overridden

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags
{
    [super awakeFromSnapshotEvents:flags];
    [self setPrimitiveStreamJID:nil];
}

@end

@implementation XMPPMessageBaseNode (XMPPMessageStreamEventNode)

- (void)obsoleteOutgoingStreamEvents
{
    for (__kindof XMPPMessageContextNode *childContextNode in self.childContextNodes) {
        if (![childContextNode isKindOfClass:[XMPPMessageStreamEventNode class]]) {
            continue;
        }
        XMPPMessageStreamEventNode *streamEventNode = childContextNode;
        if (streamEventNode.kind == XMPPMessageStreamEventKindOutgoing) {
            streamEventNode.obsoleted = YES;
        }
    }
}

@end
