#import "XMPPMessageCoreDataStorage+XMPPMUCLight.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPStream.h"

@implementation XMPPMessageCoreDataStorage (XMPPMUCLight)

- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoomLight *)room event:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        if ([message elementID]) {
            XMPPMessageBaseNode *previouslySentMessageNode = [XMPPMessageBaseNode findWithUniqueStanzaID:[message elementID]
                                                                                  inManagedObjectContext:self.managedObjectContext];
            if (previouslySentMessageNode && previouslySentMessageNode.direction == XMPPMessageDirectionOutgoing) {
                return;
            }
        }
        
        [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                               streamJID:event.myJID
                                                             withMessage:message
                                                               timestamp:event.timestamp
                                                  inManagedObjectContext:self.managedObjectContext];
    }];
}

- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoomLight *)room event:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *outgoingMessageNode = [XMPPMessageBaseNode findForOutgoingMessageStreamEventID:event.uniqueID
                                                                                     inManagedObjectContext:self.managedObjectContext];
        NSAssert(outgoingMessageNode, @"No matching outgoing message node found");
        
        [outgoingMessageNode registerSentMessageWithStreamJID:event.myJID timestamp:event.timestamp];
    }];
}

@end

@implementation XMPPMessageBaseNode (XMPPMUCLight)

+ (NSPredicate *)relevantMessageRoomJIDPredicateWithValue:(XMPPJID *)value
{
    return [self relevantMessageRemotePartyJIDPredicateWithValue:value compareOptions:XMPPJIDCompareBare];
}

@end
