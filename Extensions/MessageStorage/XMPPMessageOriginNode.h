#import "XMPPMessageContextNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageOriginNode : XMPPMessageContextNode

@property (nonatomic, assign, getter=isObsoleted) BOOL obsoleted;
@property (nonatomic, strong, nullable) NSDate *timestamp;

+ (NSFetchedResultsController<__kindof XMPPMessageOriginNode *> *)fetchMessageNodeRootsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                                                        filteredWithPredicate:(nullable NSPredicate *)userPredicate
                                                                                           sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                                                                                                    cacheName:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
