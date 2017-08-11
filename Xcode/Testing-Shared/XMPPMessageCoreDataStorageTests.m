//
//  XMPPMessageCoreDataStorageTests.m
//  XMPPFrameworkTests
//
//  Created by Piotr Wegrzynek on 10/08/2017.
//
//

#import <XCTest/XCTest.h>
@import XMPPFramework;

static void *KeyValueObservingExpectationContext = &KeyValueObservingExpectationContext;

@interface XMPPMessageCoreDataStorageTests : XCTestCase

@property (nonatomic, strong) XMPPMessageCoreDataStorage *storage;
@property (nonatomic, strong) XMPPMessageBaseNode *messageNode;
@property (nonatomic, strong) XMPPMessageStreamEventNode *streamEventNode;

@property (nonatomic, strong) XCTestExpectation *keyValueObservingExpectation;

@end

@implementation XMPPMessageCoreDataStorageTests

- (void)setUp
{
    [super setUp];
    
    self.storage = [[XMPPMessageCoreDataStorage alloc] initWithDatabaseFilename:NSStringFromSelector(self.invocation.selector) storeOptions:nil];
    self.storage.autoRemovePreviousDatabaseFile = YES;
    
    self.messageNode = [[XMPPMessageBaseNode alloc] initWithContext:self.storage.mainThreadManagedObjectContext];
    self.streamEventNode = [[XMPPMessageStreamEventNode alloc] initWithContext:self.storage.mainThreadManagedObjectContext];
    self.streamEventNode.eventID = [NSUUID UUID].UUIDString;
    
    [self.messageNode addObserver:self forKeyPath:@"fromJID" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"fromDomain" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"fromResource" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"fromUser" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"toJID" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"toDomain" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"toResource" options:0 context:KeyValueObservingExpectationContext];
    [self.messageNode addObserver:self forKeyPath:@"toUser" options:0 context:KeyValueObservingExpectationContext];
    
    [self.streamEventNode addObserver:self forKeyPath:@"streamJID" options:0 context:KeyValueObservingExpectationContext];
    [self.streamEventNode addObserver:self forKeyPath:@"streamDomain" options:0 context:KeyValueObservingExpectationContext];
    [self.streamEventNode addObserver:self forKeyPath:@"streamResource" options:0 context:KeyValueObservingExpectationContext];
    [self.streamEventNode addObserver:self forKeyPath:@"streamUser" options:0 context:KeyValueObservingExpectationContext];
}

- (void)tearDown
{
    [super tearDown];
    
    [self.messageNode removeObserver:self forKeyPath:@"fromJID" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"fromDomain" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"fromResource" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"fromUser" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"toJID" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"toDomain" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"toResource" context:KeyValueObservingExpectationContext];
    [self.messageNode removeObserver:self forKeyPath:@"toUser" context:KeyValueObservingExpectationContext];
    
    [self.streamEventNode removeObserver:self forKeyPath:@"streamJID" context:KeyValueObservingExpectationContext];
    [self.streamEventNode removeObserver:self forKeyPath:@"streamDomain" context:KeyValueObservingExpectationContext];
    [self.streamEventNode removeObserver:self forKeyPath:@"streamResource" context:KeyValueObservingExpectationContext];
    [self.streamEventNode removeObserver:self forKeyPath:@"streamUser" context:KeyValueObservingExpectationContext];
}

- (void)testNodeTransientPropertyDirectUpdates
{
    self.messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    self.messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    self.streamEventNode.streamJID = [XMPPJID jidWithString:@"user3@domain3/resource3"];
    
    XCTAssertEqualObjects([self.messageNode valueForKey:@"fromDomain"], @"domain1");
    XCTAssertEqualObjects([self.messageNode valueForKey:@"fromResource"], @"resource1");
    XCTAssertEqualObjects([self.messageNode valueForKey:@"fromUser"], @"user1");
    
    XCTAssertEqualObjects([self.messageNode valueForKey:@"toDomain"], @"domain2");
    XCTAssertEqualObjects([self.messageNode valueForKey:@"toResource"], @"resource2");
    XCTAssertEqualObjects([self.messageNode valueForKey:@"toUser"], @"user2");
    
    XCTAssertEqualObjects([self.streamEventNode valueForKey:@"streamDomain"], @"domain3");
    XCTAssertEqualObjects([self.streamEventNode valueForKey:@"streamResource"], @"resource3");
    XCTAssertEqualObjects([self.streamEventNode valueForKey:@"streamUser"], @"user3");
    
    [self.messageNode setValue:@"domain1a" forKey:@"fromDomain"];
    [self.messageNode setValue:@"resource1a" forKey:@"fromResource"];
    [self.messageNode setValue:@"user1a" forKey:@"fromUser"];
    
    [self.messageNode setValue:@"domain2a" forKey:@"toDomain"];
    [self.messageNode setValue:@"resource2a" forKey:@"toResource"];
    [self.messageNode setValue:@"user2a" forKey:@"toUser"];
    
    [self.streamEventNode setValue:@"domain3a" forKey:@"streamDomain"];
    [self.streamEventNode setValue:@"resource3a" forKey:@"streamResource"];
    [self.streamEventNode setValue:@"user3a" forKey:@"streamUser"];
    
    XCTAssert([self.messageNode.fromJID isEqualToJID:[XMPPJID jidWithString:@"user1a@domain1a/resource1a"]]);
    XCTAssert([self.messageNode.toJID isEqualToJID:[XMPPJID jidWithString:@"user2a@domain2a/resource2a"]]);
    XCTAssert([self.streamEventNode.streamJID isEqualToJID:[XMPPJID jidWithString:@"user3a@domain3a/resource3a"]]);
}

- (void)testNodeTransientPropertyMergeUpdates
{
    self.messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    self.messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    self.streamEventNode.streamJID = [XMPPJID jidWithString:@"user3@domain3/resource3"];
    
    [self.storage.mainThreadManagedObjectContext save:NULL];
    
    [self expectationForNotification:NSManagedObjectContextObjectsDidChangeNotification object:self.storage.mainThreadManagedObjectContext handler:nil];
    
    [self.storage scheduleBlock:^{
        XMPPMessageBaseNode *storageContextMessageNode = [self.storage.managedObjectContext objectWithID:self.messageNode.objectID];
        XMPPMessageStreamEventNode *storageContextStreamEventNode = [self.storage.managedObjectContext objectWithID:self.streamEventNode.objectID];
        
        storageContextMessageNode.fromJID = [XMPPJID jidWithString:@"user1a@domain1a/resource1a"];
        storageContextMessageNode.toJID = [XMPPJID jidWithString:@"user2a@domain2a/resource2a"];
        storageContextStreamEventNode.streamJID = [XMPPJID jidWithString:@"user3a@domain3a/resource3a"];
        
        [self.storage save];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssert([self.messageNode.fromJID isEqualToJID:[XMPPJID jidWithString:@"user1a@domain1a/resource1a"]]);
        XCTAssert([self.messageNode.toJID isEqualToJID:[XMPPJID jidWithString:@"user2a@domain2a/resource2a"]]);
        XCTAssert([self.streamEventNode.streamJID isEqualToJID:[XMPPJID jidWithString:@"user3a@domain3a/resource3a"]]);
    }];
}

- (void)testNodeTransientToPersistentPropertyKeyValueObservingDependencies
{
    self.keyValueObservingExpectation = [self expectationWithDescription:@"Transient to persistent key-value observing dependencies expectation"];
    self.keyValueObservingExpectation.expectedFulfillmentCount = 12;    // 3 setter invocations generating 4 KVO notifications each
    
    self.messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    self.messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    self.streamEventNode.streamJID = [XMPPJID jidWithString:@"user3@domain3/resource3"];
    
    [self waitForExpectationsWithTimeout:0 handler:nil];
}

- (void)testNodePersistentToTransientPropertyKeyValueObservingDependencies
{
    self.keyValueObservingExpectation = [self expectationWithDescription:@"Persistent to transient key-value observing dependencies expectation"];
    self.keyValueObservingExpectation.expectedFulfillmentCount = 18;    // 9 setter invocations generating 2 KVO notifications each
    
    [self.messageNode setValue:@"domain1a" forKey:@"fromDomain"];
    [self.messageNode setValue:@"resource1a" forKey:@"fromResource"];
    [self.messageNode setValue:@"user1a" forKey:@"fromUser"];
    
    [self.messageNode setValue:@"domain2a" forKey:@"toDomain"];
    [self.messageNode setValue:@"resource2a" forKey:@"toResource"];
    [self.messageNode setValue:@"user2a" forKey:@"toUser"];

    [self.streamEventNode setValue:@"domain3a" forKey:@"streamDomain"];
    [self.streamEventNode setValue:@"resource3a" forKey:@"streamResource"];
    [self.streamEventNode setValue:@"user3a" forKey:@"streamUser"];
    
    [self waitForExpectationsWithTimeout:0 handler:nil];
}

- (void)testNodeTransientPropertySameValueSetting
{
    self.messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    self.messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    self.streamEventNode.streamJID = [XMPPJID jidWithString:@"user3@domain3/resource3"];
    
    self.keyValueObservingExpectation = [self expectationWithDescription:@"Same value setting key-value observing expectation"];
    self.keyValueObservingExpectation.inverted = YES;
    
    self.messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    self.messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    self.streamEventNode.streamJID = [XMPPJID jidWithString:@"user3@domain3/resource3"];
    
    [self.messageNode setValue:@"domain1" forKey:@"fromDomain"];
    [self.messageNode setValue:@"resource1" forKey:@"fromResource"];
    [self.messageNode setValue:@"user1" forKey:@"fromUser"];
    
    [self.messageNode setValue:@"domain2" forKey:@"toDomain"];
    [self.messageNode setValue:@"resource2" forKey:@"toResource"];
    [self.messageNode setValue:@"user2" forKey:@"toUser"];
    
    [self.streamEventNode setValue:@"domain3" forKey:@"streamDomain"];
    [self.streamEventNode setValue:@"resource3" forKey:@"streamResource"];
    [self.streamEventNode setValue:@"user3" forKey:@"streamUser"];
    
    [self waitForExpectationsWithTimeout:0 handler:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != KeyValueObservingExpectationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    [self.keyValueObservingExpectation fulfill];
}

@end
