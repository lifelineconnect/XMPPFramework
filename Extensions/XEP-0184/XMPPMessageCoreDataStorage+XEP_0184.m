#import "XMPPMessageCoreDataStorage+XEP_0184.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPStream.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"

static XMPPMessageContextMarkerItemTag const XMPPMessageContextAssociatedDeliveryReceiptResponseTag = @"XMPPMessageContextAssociatedDeliveryReceiptResponse";
static XMPPMessageContextStringItemTag const XMPPMessageContextDeliveryReceiptResponseIDTag = @"XMPPMessageContextDeliveryReceiptResponseID";

@implementation XMPPMessageCoreDataStorage (XEP_0184)

- (void)storeDeliveryReceiptForMessageID:(NSString *)deliveredMessageID receivedInMessage:(XMPPMessage *)receiptMessage withEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *receiptMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                                                                         streamJID:event.myJID
                                                                                                       withMessage:receiptMessage
                                                                                                         timestamp:event.timestamp
                                                                                            inManagedObjectContext:self.managedObjectContext];
        
        XMPPMessageContextNode *deliveryReceiptContextNode = [receiptMessageNode appendContextNodeWithStreamEventID:event.uniqueID];
        [deliveryReceiptContextNode appendStringItemWithTag:XMPPMessageContextDeliveryReceiptResponseIDTag value:deliveredMessageID];
        
        XMPPMessageBaseNode *sentMessageNode = [XMPPMessageBaseNode findWithUniqueStanzaID:deliveredMessageID
                                                                    inManagedObjectContext:self.managedObjectContext];
        XMPPMessageContextNode *deliveryConfirmationContextNode = [sentMessageNode appendContextNodeWithStreamEventID:event.uniqueID];
        [deliveryConfirmationContextNode appendMarkerItemWithTag:XMPPMessageContextAssociatedDeliveryReceiptResponseTag];
    }];
}

@end

@implementation XMPPMessageBaseNode (XEP_0184)

+ (XMPPMessageBaseNode *)findDeliveryReceiptResponseForMessageWithID:(NSString *)messageID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [XMPPMessageContextStringItem xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[[XMPPMessageContextStringItem stringPredicateWithValue:messageID],
                                                         [XMPPMessageContextStringItem tagPredicateWithValue:XMPPMessageContextDeliveryReceiptResponseIDTag]]];
    
    NSArray<XMPPMessageContextStringItem *> *result = [managedObjectContext xmpp_executeForcedSuccessFetchRequest:fetchRequest];
    NSAssert(result.count <= 1, @"Multiple delivery receipt context items for the given response ID");
    return result.firstObject.contextNode.messageNode;
}

- (BOOL)hasAssociatedDeliveryReceiptResponseMessage
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode hasMarkerItemForTag:XMPPMessageContextAssociatedDeliveryReceiptResponseTag] ? contextNode : nil;
    }] != nil;
}

- (NSString *)messageDeliveryReceiptResponseID
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextDeliveryReceiptResponseIDTag];
    }];
}

@end
