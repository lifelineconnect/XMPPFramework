#import "XMPPMessageCoreDataStorage+XEP_0198.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPStream.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

typedef NS_OPTIONS(NSInteger, XMPPManagedMessagingMessageContextScope) {
    XMPPManagedMessagingMessageContextScopePendingAcknowledgement = 1 << 0,
    XMPPManagedMessagingMessageContextScopeAcknowledged = 1 << 1,
    XMPPManagedMessagingMessageContextScopeUnacknowledged = 1 << 2,
    
    XMPPManagedMessagingMessageContextScopeAll =
    XMPPManagedMessagingMessageContextScopePendingAcknowledgement |
    XMPPManagedMessagingMessageContextScopeAcknowledged |
    XMPPManagedMessagingMessageContextScopeUnacknowledged
};

static XMPPMessageContextMarkerItemTag const XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag = @"XMPPMessageContextManagedMessagingPendingAcknowledgementStatus";
static XMPPMessageContextMarkerItemTag const XMPPMessageContextManagedMessagingAcknowledgedStatusTag = @"XMPPMessageContextManagedMessagingAcknowledgedStatus";
static XMPPMessageContextMarkerItemTag const XMPPMessageContextManagedMessagingUnacknowledgedStatusTag = @"XMPPMessageContextManagedMessagingUnacknowledgedStatus";

@interface XMPPMessageBaseNode (XEP_0198_Private)

- (XMPPMessageContextNode *)lookupManagedMessagingContextNodeInScope:(XMPPManagedMessagingMessageContextScope)scope withBlock:(BOOL (^)(XMPPMessageContextNode *contextNode))lookupBlock;

@end

@implementation XMPPMessageCoreDataStorage (XEP_0198)

- (void)registerOutgoingManagedMessageID:(NSString *)messageID withEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findWithUniqueStanzaID:messageID inManagedObjectContext:self.managedObjectContext];
        NSAssert(messageNode.direction == XMPPMessageDirectionOutgoing, @"No outgoing message found");
        NSAssert(![messageNode lookupManagedMessagingContextNodeInScope:XMPPManagedMessagingMessageContextScopeAcknowledged withBlock:nil], @"Managed message already acknowledged");
        NSAssert(![messageNode lookupManagedMessagingContextNodeInScope:XMPPManagedMessagingMessageContextScopeAll withBlock:^BOOL(XMPPMessageContextNode *contextNode) {
            return [contextNode.streamEventID isEqualToString:event.uniqueID];
        }], @"Managed messaging context already registered");
        
        XMPPMessageContextNode *managedMessagingContextNode = [messageNode appendContextNodeWithStreamEventID:event.uniqueID];
        [managedMessagingContextNode appendMarkerItemWithTag:XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag];
    }];
}

- (void)registerManagedMessageConfirmationForSentMessageIDs:(NSArray<NSString *> *)messageIDs
{
    [self scheduleBlock:^{
        // TODO: a single fetch
        for (NSString *messageID in messageIDs) {
            XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findWithUniqueStanzaID:messageID inManagedObjectContext:self.managedObjectContext];
            XMPPMessageContextNode *managedMessagingContextNode = [messageNode lookupManagedMessagingContextNodeInScope:XMPPManagedMessagingMessageContextScopePendingAcknowledgement withBlock:nil];
            NSAssert(managedMessagingContextNode, @"No managed messaging context awaiting confirmation found");
            
            [managedMessagingContextNode removeMarkerItemsWithTag:XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag];
            [managedMessagingContextNode appendMarkerItemWithTag:XMPPMessageContextManagedMessagingAcknowledgedStatusTag];
        }
    }];
}

- (void)registerManagedMessageFailureForUnconfirmedMessages
{
    [self scheduleBlock:^{
        NSFetchRequest *fetchRequest = [XMPPMessageContextMarkerItem xmpp_fetchRequestInManagedObjectContext:self.managedObjectContext];
        fetchRequest.predicate = [XMPPMessageContextMarkerItem tagPredicateWithValue:XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag];
        
        for (XMPPMessageContextItem *markerItem in [self.managedObjectContext xmpp_executeForcedSuccessFetchRequest:fetchRequest]) {
            XMPPMessageContextNode *managedMessagingContextNode = markerItem.contextNode;
            [managedMessagingContextNode removeMarkerItemsWithTag:XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag];
            [managedMessagingContextNode appendMarkerItemWithTag:XMPPMessageContextManagedMessagingUnacknowledgedStatusTag];
        }
    }];
}

@end

@implementation XMPPMessageBaseNode (XEP_0198)

- (XMPPManagedMessagingStatus)managedMessagingStatus
{
    __block XMPPMessageContextNode *anyPendingStatusContextNode;
    __block XMPPMessageContextNode *anyUnackowledgedStatusContextNode;
    XMPPMessageContextNode *acknowledgedStatusContextNode = [self lookupManagedMessagingContextNodeInScope:XMPPManagedMessagingMessageContextScopeAll withBlock:^BOOL(XMPPMessageContextNode *contextNode) {
        if ([contextNode hasMarkerItemForTag:XMPPMessageContextManagedMessagingAcknowledgedStatusTag]) {
            return YES;
        }
        
        if ([contextNode hasMarkerItemForTag:XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag]) {
            anyPendingStatusContextNode = contextNode;
        }
        
        if ([contextNode hasMarkerItemForTag:XMPPMessageContextManagedMessagingUnacknowledgedStatusTag]) {
            anyUnackowledgedStatusContextNode = contextNode;
        }
        
        return NO;
    }];
    
    return
    acknowledgedStatusContextNode ? XMPPManagedMessagingStatusAcknowledged :
    anyPendingStatusContextNode ? XMPPManagedMessagingStatusPendingAcknowledgement :
    anyUnackowledgedStatusContextNode ? XMPPManagedMessagingStatusUnacknowledged :
    XMPPManagedMessagingStatusUnspecified;
}

- (XMPPMessageContextNode *)lookupManagedMessagingContextNodeInScope:(XMPPManagedMessagingMessageContextScope)scope withBlock:(BOOL (^)(XMPPMessageContextNode *))lookupBlock
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        BOOL isScopeMatched =
        ((scope & XMPPManagedMessagingMessageContextScopePendingAcknowledgement) && [contextNode hasMarkerItemForTag:XMPPMessageContextManagedMessagingPendingAcknowledgementStatusTag]) ||
        ((scope & XMPPManagedMessagingMessageContextScopeAcknowledged) && [contextNode hasMarkerItemForTag:XMPPMessageContextManagedMessagingAcknowledgedStatusTag]) ||
        ((scope & XMPPManagedMessagingMessageContextScopeUnacknowledged) && [contextNode hasMarkerItemForTag:XMPPMessageContextManagedMessagingUnacknowledgedStatusTag]);
        
        return isScopeMatched && (!lookupBlock || lookupBlock(contextNode)) ? contextNode : nil;
    }];
}

@end
