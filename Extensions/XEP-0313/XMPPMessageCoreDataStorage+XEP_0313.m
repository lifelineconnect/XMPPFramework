#import "XMPPMessageCoreDataStorage+XEP_0313.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPStream.h"
#import "XMPPMessage.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

static XMPPMessageContextStringItemTag const XMPPMessageContextMAMArchiveIDTag = @"XMPPMessageContextMAMArchiveID";
static XMPPMessageContextTimestampItemTag const XMPPMessageContextMAMPartialResultPageTimestampTag = @"XMPPMessageContextMAMPartialResultPageTimestamp";
static XMPPMessageContextTimestampItemTag const XMPPMessageContextMAMCompleteResultPageTimestampTag = @"XMPPMessageContextMAMCompleteResultPageTimestamp";
static XMPPMessageContextTimestampItemTag const XMPPMessageContextMAMDeletedResultItemTimestampTag = @"XMPPMessageContextMAMDeletedResultItemTimestamp";

@implementation XMPPMessageCoreDataStorage (XEP_0313)

- (void)storePayloadMessage:(XMPPMessage *)payloadMessage withMessageArchiveID:(NSString *)archiveID timestamp:(NSDate *)timestamp event:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        NSFetchRequest *existingArchiveIDFetchRequest = [XMPPMessageContextStringItem xmpp_fetchRequestInManagedObjectContext:self.managedObjectContext];
        existingArchiveIDFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[XMPPMessageContextStringItem stringPredicateWithValue:archiveID],
                                                                                                       [XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextMAMArchiveIDTag]]];
        NSArray<XMPPMessageContextStringItem *> *existingArchiveIDResult = [self.managedObjectContext xmpp_executeForcedSuccessFetchRequest:existingArchiveIDFetchRequest];
        if (existingArchiveIDResult.count != 0) {
            NSAssert(existingArchiveIDResult.count == 1, @"Expected a single message matching the given archive ID");
            NSAssert([[existingArchiveIDResult.firstObject.contextNode.messageNode messageArchiveDate] isEqualToDate:timestamp], @"The timestamp on an existing message does not match");
            return;
        }
        
        XMPPMessageBaseNode *uniqueStanzaIDMessageNode;
        if ([payloadMessage elementID]) {
            uniqueStanzaIDMessageNode = [XMPPMessageBaseNode findWithUniqueStanzaID:[payloadMessage elementID] inManagedObjectContext:self.managedObjectContext];
        }
        
        XMPPMessageBaseNode *messageNode;
        if (uniqueStanzaIDMessageNode) {
            messageNode = uniqueStanzaIDMessageNode;
        } else {
            messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                                                 streamJID:event.myJID
                                                                               withMessage:payloadMessage ?: [[XMPPMessage alloc] init]
                                                                                 timestamp:event.timestamp
                                                                    inManagedObjectContext:self.managedObjectContext];
        }
        
        [messageNode retireStreamTimestamp];
        
        XMPPMessageContextNode *messageArchiveContextNode = [messageNode appendContextNodeWithStreamEventID:event.uniqueID];
        [messageArchiveContextNode appendStringItemWithTag:XMPPMessageContextMAMArchiveIDTag value:archiveID];
        [messageArchiveContextNode appendTimestampItemWithTag:payloadMessage ? XMPPMessageContextMAMPartialResultPageTimestampTag : XMPPMessageContextMAMDeletedResultItemTimestampTag
                                                        value:timestamp];
    }];
}

- (void)finalizeResultSetPageWithMessageArchiveIDs:(NSArray<NSString *> *)archiveIDs
{
    NSMutableArray *archiveIDSubpredicates = [[NSMutableArray alloc] init];
    for (NSString *archiveID in archiveIDs) {
        [archiveIDSubpredicates addObject:[XMPPMessageContextStringItem stringPredicateWithValue:archiveID]];
    }
    if (archiveIDSubpredicates.count == 0) {
        return;
    }
    
    [self scheduleBlock:^{
        NSFetchRequest *finalizedArchiveIDsFetchRequest = [XMPPMessageContextStringItem xmpp_fetchRequestInManagedObjectContext:self.managedObjectContext];
        finalizedArchiveIDsFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSCompoundPredicate orPredicateWithSubpredicates:archiveIDSubpredicates],
                                                                                                         [XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextMAMArchiveIDTag]]];
        
        for (XMPPMessageContextStringItem *archiveIDContextItem in [self.managedObjectContext xmpp_executeForcedSuccessFetchRequest:finalizedArchiveIDsFetchRequest]) {
            __block
            XMPPMessageContextNode *partialResultContextNode = [archiveIDContextItem.contextNode.messageNode lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
                return [contextNode timestampItemValueForTag:XMPPMessageContextMAMPartialResultPageTimestampTag] ? contextNode : nil;
            }];
            if (!partialResultContextNode) {
                continue;
            }
         
            NSDate *partialResultTimestamp = [partialResultContextNode timestampItemValueForTag:XMPPMessageContextMAMPartialResultPageTimestampTag];
            [partialResultContextNode removeTimestampItemsWithTag:XMPPMessageContextMAMPartialResultPageTimestampTag];
            [partialResultContextNode appendTimestampItemWithTag:XMPPMessageContextMAMCompleteResultPageTimestampTag value:partialResultTimestamp];
        }
    }];
}

@end

@implementation XMPPMessageBaseNode (XEP_0313)

+ (NSPredicate *)messageArchiveTimestampContextPredicateWithOptions:(XMPPMAMTimestampContextOptions)options
{
    NSMutableArray *subpredicates = [[NSMutableArray alloc] initWithObjects:
                                     [XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextMAMCompleteResultPageTimestampTag], nil];
    
    if (options & XMPPMAMTimestampContextIncludingPartialResultPages) {
        [subpredicates addObject:[XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextMAMPartialResultPageTimestampTag]];
    }
    
    if (options & XMPPMAMTimestampContextIncludingDeletedResultItems) {
        [subpredicates addObject:[XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextMAMDeletedResultItemTimestampTag]];
    }
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
}

+ (NSPredicate *)relevantOwnJIDIncomingMessagePredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions
{
    return [NSCompoundPredicate andPredicateWithSubpredicates:@[[XMPPMessageBaseNode relevantMessageFromJIDPredicateWithValue:value compareOptions:compareOptions],
                                                                [XMPPMessageContextItem messageDirectionPredicateWithValue:XMPPMessageDirectionIncoming]]];
}

- (NSString *)messageArchiveID
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextMAMArchiveIDTag];
    }];
}

- (NSDate *)messageArchiveDate
{
    NSArray *archiveTimestampTags = @[XMPPMessageContextMAMPartialResultPageTimestampTag,
                                      XMPPMessageContextMAMCompleteResultPageTimestampTag,
                                      XMPPMessageContextMAMDeletedResultItemTimestampTag];
    
    for (XMPPMessageContextTimestampItemTag archiveTimestampTag in archiveTimestampTags) {
        NSDate *archiveTimestamp = [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
            return [contextNode timestampItemValueForTag:archiveTimestampTag];
        }];
        if (archiveTimestamp) {
            return archiveTimestamp;
        }
    }
    
    return nil;
}

- (BOOL)isOwnIncomingMessageInContextOfJID:(XMPPJID *)jid withCompareOptions:(XMPPJIDCompareOptions)compareOptions
{
    return [self.fromJID isEqualToJID:jid options:compareOptions] && self.direction == XMPPMessageDirectionIncoming;
}

@end
