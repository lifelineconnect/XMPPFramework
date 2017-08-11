#import "XMPPMessageCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"

@interface XMPPMessageCoreDataStorage ()

@property (nonatomic, copy, readonly) NSArray<id<XMPPMessageCoreDataStorageCustomContextNodeProvider>> *customContextNodeProviders;

@end

@implementation XMPPMessageCoreDataStorage

- (instancetype)initWithDatabaseFilename:(NSString *)aDatabaseFileName storeOptions:(NSDictionary *)theStoreOptions customContextNodeProviders:(NSArray<id<XMPPMessageCoreDataStorageCustomContextNodeProvider>> *)customContextNodeProviders
{
    self = [super initWithDatabaseFilename:aDatabaseFileName storeOptions:theStoreOptions];
    if (self) {
        _customContextNodeProviders = [customContextNodeProviders copy];
    }
    return self;
}

- (instancetype)initWithInMemoryStoreUsingCustomContextNodeProviders:(NSArray<id<XMPPMessageCoreDataStorageCustomContextNodeProvider>> *)customContextNodeProviders
{
    self = [super initWithInMemoryStore];
    if (self) {
        _customContextNodeProviders = [customContextNodeProviders copy];
    }
    return self;
}

- (id)initWithDatabaseFilename:(NSString *)aDatabaseFileName storeOptions:(NSDictionary *)theStoreOptions
{
    return [self initWithDatabaseFilename:aDatabaseFileName storeOptions:theStoreOptions customContextNodeProviders:nil];
}

- (id)initWithInMemoryStore
{
    return [self initWithInMemoryStoreUsingCustomContextNodeProviders:nil];
}

- (void)willCreatePersistentStoreCoordinator
{
    NSEntityDescription *baseContextNodeEntity = self.managedObjectModel.entitiesByName[@"XMPPMessageContextNode"];
    NSAssert(baseContextNodeEntity, @"XMPPMessageContextNode entity not found in managed object model");
    
    for (id<XMPPMessageCoreDataStorageCustomContextNodeProvider> customContextNodeProvider in self.customContextNodeProviders) {
        [customContextNodeProvider provideCustomContextNodeEntitiesForBaseEntity:baseContextNodeEntity inStorage:self];
    }
}

@end
