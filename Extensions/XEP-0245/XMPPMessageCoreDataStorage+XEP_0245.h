#import "XMPPMessageBaseNode.h"

@interface XMPPMessageBaseNode (XEP_0245)

- (nullable NSString *)meCommandText;
- (nullable XMPPJID *)meCommandSubjectJID;

@end
