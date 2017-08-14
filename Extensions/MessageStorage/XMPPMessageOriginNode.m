#import "XMPPMessageOriginNode.h"
#import "NSManagedObject+XMPPCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"

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

+ (NSFetchedResultsController<XMPPMessageOriginNode *> *)fetchMessageNodeRootsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext filteredWithPredicate:(NSPredicate *)userPredicate sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name
{
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    if (userPredicate) {
        [subpredicates addObject:userPredicate];
    }
    
    NSPredicate *rootContextPredicate = [NSPredicate predicateWithFormat:@"%K.%K = nil",
                                         NSStringFromSelector(@selector(parentMessageNode)),
                                         NSStringFromSelector(@selector(parentContextNode))];
    [subpredicates addObject:rootContextPredicate];
    
    NSPredicate *nonObsoletedPredicate = [NSPredicate predicateWithFormat:@"%K = NO", XMPPMessageOriginNodeObsoletedKey];
    [subpredicates addObject:nonObsoletedPredicate];
    
    NSFetchRequest *fetchRequest = [XMPPMessageOriginNode xmpp_fetchRequestInManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(timestamp)) ascending:YES]];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:managedObjectContext
                                                 sectionNameKeyPath:sectionNameKeyPath
                                                          cacheName:name];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveTimestamp:[NSDate date]];
}

@end
