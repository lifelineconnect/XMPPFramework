#import <CoreData/CoreData.h>

@interface NSManagedObject (XMPPCoreDataStorage)

+ (instancetype)xmpp_insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSFetchRequest *)xmpp_fetchRequestInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface NSManagedObjectContext (XMPPCoreDataStorage)

- (NSArray *)xmpp_executeForcedSuccessFetchRequest:(NSFetchRequest *)fetchRequest;

@end
