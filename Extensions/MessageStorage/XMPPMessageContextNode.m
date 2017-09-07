#import "XMPPMessageContextNode.h"

@implementation XMPPMessageContextNode


- (void)applyContextToOutgoingMessage:(XMPPMessage *)message fromNode:(XMPPMessageBaseNode *)messageNode
{
    // base implementation does nothing
}
@dynamic streamEventID, messageNode, jidItems, markerItems, stringItems, timestampItems;

@end
