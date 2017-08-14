#import "XMPPMessageContextNode.h"

@interface XMPPMessageOriginNode : XMPPMessageContextNode

@property (nonatomic, assign, getter=isObsoleted) BOOL obsoleted;
@property (nonatomic, strong, nullable) NSDate *timestamp;

@end
