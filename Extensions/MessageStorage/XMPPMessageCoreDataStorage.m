#import "XMPPMessageCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPStream.h"

@class XMPPStreamEventStorageActionsDelegate;

@interface XMPPMessageCoreDataStorage ()

@property (nonatomic, copy, readonly) NSMutableDictionary<NSString *, XMPPStreamEventStorageActionsDelegate *> *streamEventStorageActionsDelegateIndex;
@property (nonatomic, strong, readonly) dispatch_queue_t streamEventStorageActionsDelegateQueue;

@end

@interface XMPPStreamEventStorageActionsDelegate : NSObject <XMPPStreamDelegate>

@property (nonatomic, unsafe_unretained, readonly) XMPPMessageCoreDataStorage *parentStorage;
@property (nonatomic, copy, readonly) NSMutableArray<dispatch_block_t> *actionBlocks;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithParentStorage:(XMPPMessageCoreDataStorage *)parentStorage actionBlocks:(NSArray<dispatch_block_t> *)actionBlocks;
- (void)xmppStream:(XMPPStream *)sender didFinishProcessingElementEvent:(XMPPElementEvent *)event;

@end

@implementation XMPPMessageCoreDataStorage

- (id)initWithDatabaseFilename:(NSString *)aDatabaseFileName storeOptions:(NSDictionary *)theStoreOptions
{
    self = [super initWithDatabaseFilename:aDatabaseFileName storeOptions:theStoreOptions];
    if (self) {
        [self commonMessageStorageInit];
    }
    return self;
}

- (id)initWithInMemoryStore
{
    self = [super initWithInMemoryStore];
    if (self) {
        [self commonMessageStorageInit];
    }
    return self;
}

- (void)commonMessageStorageInit
{
    _streamEventStorageActionsDelegateIndex = [[NSMutableDictionary alloc] init];
    _streamEventStorageActionsDelegateQueue = dispatch_queue_create("XMPPMessageCoreDataStorage.streamEventStorageActionsDelegateQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)scheduleStorageActionForEventWithID:(NSString *)streamEventID inStream:(XMPPStream *)xmppStream withBlock:(dispatch_block_t)block
{
    // The delegate needs to be created and assigned before it is determined whether another one existed for a given stream event,
    // this is because a relevant callback may be fired immediately upon returning from this method and has to be enqueued
    XMPPStreamEventStorageActionsDelegate *delegate =
    [[XMPPStreamEventStorageActionsDelegate alloc] initWithParentStorage:self actionBlocks:@[block]];
    
    [xmppStream addDelegate:delegate delegateQueue:self.streamEventStorageActionsDelegateQueue];
    
    dispatch_async(self.streamEventStorageActionsDelegateQueue, ^{
        XMPPStreamEventStorageActionsDelegate *existingDelegate = self.streamEventStorageActionsDelegateIndex[streamEventID];
        if (existingDelegate) {
            [existingDelegate.actionBlocks addObject:block];
        } else {
            self.streamEventStorageActionsDelegateIndex[streamEventID] = delegate;
        }
    });
}

@end

@implementation XMPPStreamEventStorageActionsDelegate

- (instancetype)initWithParentStorage:(XMPPMessageCoreDataStorage *)parentStorage actionBlocks:(NSArray<dispatch_block_t> *)actionBlocks
{
    self = [super init];
    if (self) {
        _parentStorage = parentStorage;
        _actionBlocks = [[NSMutableArray alloc] initWithArray:actionBlocks];
    }
    return self;
}

- (void)xmppStream:(XMPPStream *)sender didFinishProcessingElementEvent:(XMPPElementEvent *)event
{
    if (self != self.parentStorage.streamEventStorageActionsDelegateIndex[event.uniqueID]) {
        return;
    }
    
    [self.parentStorage scheduleBlock:^{
        for (dispatch_block_t actionBlock in self.actionBlocks) {
            actionBlock();
        }
    }];
    
    [self.parentStorage.streamEventStorageActionsDelegateIndex removeObjectForKey:event.uniqueID];
}

@end
