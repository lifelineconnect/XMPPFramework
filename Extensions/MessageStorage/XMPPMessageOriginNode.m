#import "XMPPMessageOriginNode.h"

@interface XMPPMessageOriginNode (CoreDataGeneratedPrimitiveAccessors)

- (void)setPrimitiveTimestamp:(NSDate *)value;

@end

@implementation XMPPMessageOriginNode

@dynamic timestamp;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveTimestamp:[NSDate date]];
}

@end
