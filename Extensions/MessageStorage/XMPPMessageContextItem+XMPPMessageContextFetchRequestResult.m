#import "XMPPMessageContextItem+XMPPMessageContextFetchRequestResult.h"
#import "XMPPMessageContextNode.h"

@implementation XMPPMessageContextItem (XMPPMessageContextFetchRequestResult)

- (XMPPMessageBaseNode *)relevantMessageNode
{
    return self.contextNode.messageNode;
}

@end
