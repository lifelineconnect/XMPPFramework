//
//  XMPPManagedMessagingTests.m
//  XMPPFrameworkTests
//
//  Created by Piotr Wegrzynek on 04/10/2017.
//

#import <XCTest/XCTest.h>
#import "XMPPMockStream.h"

@class XMPPFakeStreamManagement;

@interface XMPPManagedMessagingTests : XCTestCase <XMPPStreamDelegate, XMPPManagedMessagingStorage, XMPPManagedMessagingDelegate>

@property (nonatomic, strong) XMPPMockStream *mockStream;
@property (nonatomic, strong) XMPPFakeStreamManagement *fakeStreamManagement;
@property (nonatomic, strong) XMPPManagedMessaging *managedMessaging;
@property (nonatomic, strong) XCTestExpectation *storageCallbackExpectation;
@property (nonatomic, strong) XCTestExpectation *delegateCallbackExpectation;

@end

@interface XMPPFakeStreamManagement : XMPPStreamManagement

@property (nonatomic, copy) NSArray *resumeStanzaIDs;

- (void)fakeReceivingAckForStanzaIDs:(NSArray *)stanzaIDs;

@end

@implementation XMPPManagedMessagingTests

- (void)setUp
{
    [super setUp];
    
    self.mockStream = [[XMPPMockStream alloc] init];
    
    self.fakeStreamManagement = [[XMPPFakeStreamManagement alloc] initWithStorage:[[XMPPStreamManagementMemoryStorage alloc] init]];
    
    self.managedMessaging = [[XMPPManagedMessaging alloc] initWithStorage:self dispatchQueue:nil];
    [self.managedMessaging addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.managedMessaging activate:self.mockStream];
}

- (BOOL)configureWithParent:(XMPPManagedMessaging *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

- (void)testStreamManagementDependency
{
    [self.mockStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Stream management dependency setup expectation"];
    
    [self.fakeStreamManagement activate:self.mockStream];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)xmppStream:(XMPPStream *)sender didRegisterModule:(id)module
{
    if (module == self.fakeStreamManagement && [[module valueForKey:@"multicastDelegate"] countOfClass:[XMPPManagedMessaging class]] == 1) {
        [self.delegateCallbackExpectation fulfill];
    }
}

- (void)testMessageRegistration
{
    XMPPMessage *message = [[XMPPMessage alloc] initWithXMLString:@"<message id='elementID'/>" error:NULL];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Message registration storage callback expectation"];
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Message registration delegate callback expectation"];
    
    [self.mockStream sendElement:message inContextOfEventWithID:@"elementEventID" andGetReceipt:NULL];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testMessageWithoutIDHandling
{
    XMPPMessage *message = [[XMPPMessage alloc] initWithXMLString:@"<message/>" error:NULL];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Message without ID registration storage callback expectation"];
    self.storageCallbackExpectation.inverted = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Message without ID registration delegate callback expectation"];
    self.delegateCallbackExpectation.inverted = YES;
    
    [self.mockStream sendElement:message inContextOfEventWithID:@"elementEventID" andGetReceipt:NULL];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)registerOutgoingManagedMessageID:(NSString *)messageID withEvent:(XMPPElementEvent *)event
{
    if ([messageID isEqualToString:@"elementID"] && [event.uniqueID isEqualToString:@"elementEventID"]) {
        [self.storageCallbackExpectation fulfill];
    }
}

- (void)xmppManagedMessaging:(XMPPManagedMessaging *)sender didBeginMonitoringOutgoingMessage:(XMPPMessage *)message
{
    if ([[message elementID] isEqualToString:@"elementID"]) {
        [self.delegateCallbackExpectation fulfill];
    }
}

- (void)testStanzaIDAssignment
{
    XMPPMessage *message = [[XMPPMessage alloc] initWithXMLString:@"<message id='elementID'/>" error:NULL];
    
    __block id messageID;
    dispatch_sync(self.managedMessaging.moduleQueue, ^{
        messageID = [(id)self.managedMessaging xmppStreamManagement:self.fakeStreamManagement stanzaIdForSentElement:message];
    });
    
    XCTAssertEqualObjects(messageID, [NSURL URLWithString:@"xmppmanagedmessage:elementID"]);
}

- (void)testBasicMessageAcknowledgement
{
    NSURL *managedMessageURL = [NSURL URLWithString:@"xmppmanagedmessage:elementID"];
    [self.fakeStreamManagement activate:self.mockStream];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Basic message acknowledgement storage callback expectation"];
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Basic message acknowledgement delegate callback expectation"];
    
    [self.fakeStreamManagement fakeReceivingAckForStanzaIDs:@[managedMessageURL]];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testStreamResumptionMessageAcknowledgement
{
    self.fakeStreamManagement.resumeStanzaIDs = @[[NSURL URLWithString:@"xmppmanagedmessage:elementID"]];
    [self.fakeStreamManagement activate:self.mockStream];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Stream resumption message acknowledgement storage callback expectation"];
    self.storageCallbackExpectation.expectedFulfillmentCount = 2;
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Stream resumption message acknowledgement delegate callback expectation"];
    self.delegateCallbackExpectation.expectedFulfillmentCount = 2;
    
    [[self.mockStream valueForKey:@"multicastDelegate"] xmppStreamDidAuthenticate:self.mockStream];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testStreamResumptionDuplicateMessageAcknowledgementHandling
{
    self.fakeStreamManagement.resumeStanzaIDs = @[[NSURL URLWithString:@"xmppmanagedmessage:elementID"]];
    [self.fakeStreamManagement activate:self.mockStream];
    NSURL *managedMessageURL = [NSURL URLWithString:@"xmppmanagedmessage:elementID"];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Stream resumption duplicate message acknowledgement storage callback expectation"];
    self.storageCallbackExpectation.inverted = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Stream resumption duplicate message acknowledgement delegate callback expectation"];
    self.delegateCallbackExpectation.inverted = YES;
    
    [self.fakeStreamManagement fakeReceivingAckForStanzaIDs:@[managedMessageURL]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAuxiliaryIQHandling
{
    XMPPIQ *iq = [[XMPPIQ alloc] initWithXMLString:@"<iq type='get' id='elementID'/>" error:NULL];
    [self.fakeStreamManagement activate:self.mockStream];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Non-message registration storage callback expectation"];
    self.storageCallbackExpectation.inverted = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Non-message registration delegate callback expectation"];
    self.delegateCallbackExpectation.inverted = YES;
    
    [self.mockStream sendElement:iq inContextOfEventWithID:@"elementEventID" andGetReceipt:NULL];
    [self.fakeStreamManagement fakeReceivingAckForStanzaIDs:@[@"elementID"]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAuxiliaryPresenceHandling
{
    XMPPPresence *presence = [[XMPPPresence alloc] initWithXMLString:@"<presence id='elementID'/>" error:NULL];
    [self.fakeStreamManagement activate:self.mockStream];
    
    self.storageCallbackExpectation = [self expectationWithDescription:@"Non-message registration storage callback expectation"];
    self.storageCallbackExpectation.inverted = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Non-message registration delegate callback expectation"];
    self.delegateCallbackExpectation.inverted = YES;
    
    [self.mockStream sendElement:presence inContextOfEventWithID:@"elementEventID" andGetReceipt:NULL];
    [self.fakeStreamManagement fakeReceivingAckForStanzaIDs:@[@"elementID"]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)registerManagedMessageConfirmationForSentMessageIDs:(NSArray<NSString *> *)messageIDs
{
    if ([messageIDs isEqualToArray:@[@"elementID"]]) {
        [self.storageCallbackExpectation fulfill];
    }
}

- (void)xmppManagedMessaging:(XMPPManagedMessaging *)sender didConfirmSentMessagesWithIDs:(NSArray<NSString *> *)messageIDs
{
    if ([messageIDs isEqualToArray:@[@"elementID"]]) {
        [self.delegateCallbackExpectation fulfill];
    }
}

- (void)registerManagedMessageFailureForUnconfirmedMessages
{
    [self.storageCallbackExpectation fulfill];
}

- (void)xmppManagedMessagingDidFinishProcessingPreviousStreamConfirmations:(XMPPManagedMessaging *)sender
{
    [self.delegateCallbackExpectation fulfill];
}

- (void)fakeIncomingManagedMessagingDelegateCallbackWithBlock:(void (^)(id managedMessaging))block
{
    dispatch_async(self.managedMessaging.moduleQueue, ^{
        block(self.managedMessaging);
    });
}

@end

@implementation XMPPFakeStreamManagement

- (Class)class
{
    // Required by XMPPStream auto delegates feature
    return [XMPPStreamManagement class];
}

- (void)fakeReceivingAckForStanzaIDs:(NSArray *)stanzaIDs
{
    dispatch_async(self.moduleQueue, ^{
        [multicastDelegate xmppStreamManagement:self didReceiveAckForStanzaIds:stanzaIDs];
    });
}

- (BOOL)didResumeWithAckedStanzaIds:(NSArray *__autoreleasing *)stanzaIdsPtr serverResponse:(NSXMLElement *__autoreleasing *)responsePtr
{
    *stanzaIdsPtr = self.resumeStanzaIDs;
    return YES;
}

@end
