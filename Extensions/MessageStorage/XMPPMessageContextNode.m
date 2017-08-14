#import "XMPPMessageContextNode.h"

@implementation XMPPMessageContextNode

@dynamic parentMessageNode, childMessageNodes;

- (void)applyContextToOutgoingMessage:(XMPPMessage *)message fromNode:(XMPPMessageBaseNode *)messageNode
{
    // base implementation does nothing
}

@end
