#import "XMPPMessageCoreDataStorage+XEP_0308.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPStream.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

static XMPPMessageContextMarkerItemTag const XMPPMessageContextAssociatedCorrectionTag = @"XMPPMessageContextAssociatedCorrection";
static XMPPMessageContextStringItemTag const XMPPMessageContextCorrectionIDTag = @"XMPPMessageContextCorrectionID";

@implementation XMPPMessageCoreDataStorage (XEP_0308)

- (void)storeIncomingCorrectedMessage:(XMPPMessage *)correctedMessage forMessageWithID:(NSString *)originalMessageID withEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *correctedMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                                                                           streamJID:event.myJID
                                                                                                         withMessage:correctedMessage
                                                                                                           timestamp:event.timestamp
                                                                                              inManagedObjectContext:self.managedObjectContext];
        [correctedMessageNode assignMessageCorrectionID:originalMessageID forStreamEventID:event.uniqueID];
    }];
}

@end

@implementation XMPPMessageBaseNode (XEP_0308)

+ (XMPPMessageBaseNode *)findCorrectionForMessageWithID:(NSString *)originalMessageID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [XMPPMessageContextStringItem xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[[XMPPMessageContextStringItem stringPredicateWithValue:originalMessageID],
                                                         [XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextCorrectionIDTag]]];
    
    NSArray<XMPPMessageContextStringItem *> *result = [managedObjectContext xmpp_executeForcedSuccessFetchRequest:fetchRequest];
    NSAssert(result.count <= 1, @"Multiple correction context items for the given original ID");
    return result.firstObject.contextNode.messageNode;
}

- (BOOL)hasAssociatedCorrectionMessage
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode hasMarkerItemForTag:XMPPMessageContextAssociatedCorrectionTag] ? contextNode : nil;
    }] != nil;
}

- (NSString *)messageCorrectionID
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextCorrectionIDTag];
    }];
}

- (void)assignMessageCorrectionID:(NSString *)originalMessageID forStreamEventID:(NSString *)streamEventID
{
    NSAssert(self.managedObjectContext, @"Attempted to assign a correction ID with no managed object context available");
    NSAssert(![self messageCorrectionID], @"Message correction ID is already assigned");
    
    [self retireStreamTimestamp];
    
    XMPPMessageContextNode *correctionContextNode = [self appendContextNodeWithStreamEventID:streamEventID];
    [correctionContextNode appendStringItemWithTag:XMPPMessageContextCorrectionIDTag value:originalMessageID];
    
    XMPPMessageBaseNode *originalMessageNode = [XMPPMessageBaseNode findWithUniqueStanzaID:originalMessageID inManagedObjectContext:self.managedObjectContext];
    XMPPMessageContextNode *correctionOriginContextNode = [originalMessageNode appendContextNodeWithStreamEventID:streamEventID];
    [correctionOriginContextNode appendMarkerItemWithTag:XMPPMessageContextAssociatedCorrectionTag];
}

@end
