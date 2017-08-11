#import "XMPPCoreDataStorage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XMPPMessageCoreDataStorageCustomContextNodeProvider;

@interface XMPPMessageCoreDataStorage : XMPPCoreDataStorage

- (nullable instancetype)initWithDatabaseFilename:(nullable NSString *)databaseFileName
                                     storeOptions:(nullable NSDictionary *)storeOptions
                       customContextNodeProviders:(nullable NSArray<id<XMPPMessageCoreDataStorageCustomContextNodeProvider>> *)customContextNodeProviders NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithInMemoryStoreUsingCustomContextNodeProviders:(nullable NSArray<id<XMPPMessageCoreDataStorageCustomContextNodeProvider>> *)customContextNodeProviders NS_DESIGNATED_INITIALIZER;

@end

@protocol XMPPMessageCoreDataStorageCustomContextNodeProvider <NSObject>

- (void)provideCustomContextNodeEntitiesForBaseEntity:(NSEntityDescription *)baseContextNodeEntity inStorage:(XMPPMessageCoreDataStorage *)storage;

@end

NS_ASSUME_NONNULL_END
