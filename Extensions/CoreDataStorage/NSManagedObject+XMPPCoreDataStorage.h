#import <CoreData/CoreData.h>
#import "XMPPJID.h"

@interface NSManagedObject (XMPPCoreDataStorage)

+ (instancetype)xmpp_insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSFetchRequest *)xmpp_fetchRequestInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSPredicate *)xmpp_jidPredicateWithDomainKeyPath:(NSString *)domainKeyPath
                                    resourceKeyPath:(NSString *)resourceKeyPath
                                        userKeyPath:(NSString *)userKeyPath
                                              value:(XMPPJID *)value
                                     compareOptions:(XMPPJIDCompareOptions)compareOptions;

@end

@interface NSManagedObjectContext (XMPPCoreDataStorage)

- (NSArray *)xmpp_executeForcedSuccessFetchRequest:(NSFetchRequest *)fetchRequest;

@end
