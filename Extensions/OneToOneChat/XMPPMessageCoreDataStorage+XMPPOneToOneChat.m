#import "XMPPMessageCoreDataStorage+XMPPOneToOneChat.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPStream.h"

@implementation XMPPMessageCoreDataStorage (XMPPOneToOneChat)

- (void)storeIncomingChatMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                               streamJID:event.myJID
                                                             withMessage:message
                                                               timestamp:event.timestamp
                                                  inManagedObjectContext:self.managedObjectContext];
    }];
}

- (void)registerSentChatMessageEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *outgoingMessageNode = [XMPPMessageBaseNode findForOutgoingMessageStreamEventID:event.uniqueID
                                                                                     inManagedObjectContext:self.managedObjectContext];
        NSAssert(outgoingMessageNode, @"No matching outgoing message node found");
        
        [outgoingMessageNode registerSentMessageWithStreamJID:event.myJID timestamp:event.timestamp];
    }];
}

@end
