#import "XMPPMessageOriginNode.h"

static NSString * const XMPPMessageOriginNodeObsoletedKey = @"obsoleted";

@interface XMPPMessageOriginNode (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveObsoleted;
- (void)setPrimitiveObsoleted:(NSNumber *)value;
- (void)setPrimitiveTimestamp:(NSDate *)value;

@end

@implementation XMPPMessageOriginNode

@dynamic timestamp;

- (BOOL)isObsoleted
{
    [self willAccessValueForKey:XMPPMessageOriginNodeObsoletedKey];
    BOOL isObsoleted = [self primitiveObsoleted].boolValue;
    [self didAccessValueForKey:XMPPMessageOriginNodeObsoletedKey];
    return isObsoleted;
}

- (void)setObsoleted:(BOOL)obsoleted
{
    [self willChangeValueForKey:XMPPMessageOriginNodeObsoletedKey];
    [self setPrimitiveObsoleted:[NSNumber numberWithBool:obsoleted]];
    [self didChangeValueForKey:XMPPMessageOriginNodeObsoletedKey];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveTimestamp:[NSDate date]];
}

@end
