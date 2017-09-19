#import <XCTest/XCTest.h>
#import "XMPPMockStream.h"

@class XMPPDelayedDeliveryTestCallbackResult;

@interface XMPPDelayedDeliveryTests : XCTestCase

@property (nonatomic, strong) XMPPMockStream *mockStream;
@property (nonatomic, strong) XMPPDelayedDelivery *delayedDelivery;
@property (nonatomic, strong) XMPPDelayedDeliveryTestCallbackResult *storageCallbackResult;

@end

@interface XMPPDelayedDeliveryTestCallbackResult : NSObject <XMPPDelayedDeliveryMessageStorage, XMPPDelayedDeliveryDelegate>

@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSDate *delayedDeliveryDate;
@property (nonatomic, strong) XMPPJID *delayOriginJID;
@property (nonatomic, copy) NSString *delayReasonDescription;

@end

@implementation XMPPDelayedDeliveryTests

- (void)setUp {
    [super setUp];
    
    self.mockStream = [[XMPPMockStream alloc] init];
    self.storageCallbackResult = [[XMPPDelayedDeliveryTestCallbackResult alloc] init];
    self.delayedDelivery = [[XMPPDelayedDelivery alloc] initWithMessageStorage:self.storageCallbackResult dispatchQueue:nil];
    [self.delayedDelivery activate:self.mockStream];
}

- (void)testStorageCallback
{
    self.storageCallbackResult.expectation = [self expectationWithDescription:@"Test storage callback expectation"];
    
    [self fakeDelayedDeliveryMessage];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertEqualObjects(self.storageCallbackResult.delayedDeliveryDate, [NSDate dateWithXmppDateTimeString:@"2002-09-10T23:08:25Z"]);
        XCTAssertEqualObjects(self.storageCallbackResult.delayOriginJID, [XMPPJID jidWithString:@"capulet.com"]);
        XCTAssertEqualObjects(self.storageCallbackResult.delayReasonDescription, @"Offline Storage");
    }];
}

- (void)testMessageDelegateCallback
{
    XMPPDelayedDeliveryTestCallbackResult *delegateCallbackResult = [[XMPPDelayedDeliveryTestCallbackResult alloc] init];
    delegateCallbackResult.expectation = [self expectationWithDescription:@"Test message delegate callback expectation"];
    [self.delayedDelivery addDelegate:delegateCallbackResult delegateQueue:dispatch_get_main_queue()];
    
    [self fakeDelayedDeliveryMessage];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertEqualObjects(delegateCallbackResult.delayedDeliveryDate, [NSDate dateWithXmppDateTimeString:@"2002-09-10T23:08:25Z"]);
        XCTAssertEqualObjects(delegateCallbackResult.delayOriginJID, [XMPPJID jidWithString:@"capulet.com"]);
        XCTAssertEqualObjects(delegateCallbackResult.delayReasonDescription, @"Offline Storage");
    }];
}

- (void)testPresenceDelegateCallback
{
    XMPPDelayedDeliveryTestCallbackResult *delegateCallbackResult = [[XMPPDelayedDeliveryTestCallbackResult alloc] init];
    delegateCallbackResult.expectation = [self expectationWithDescription:@"Test presence delegate callback expectation"];
    [self.delayedDelivery addDelegate:delegateCallbackResult delegateQueue:dispatch_get_main_queue()];
    
    [self fakeDelayedDeliveryPresence];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertEqualObjects(delegateCallbackResult.delayedDeliveryDate, [NSDate dateWithXmppDateTimeString:@"2002-09-10T23:41:07Z"]);
        XCTAssertEqualObjects(delegateCallbackResult.delayOriginJID, [XMPPJID jidWithString:@"juliet@capulet.com/balcony"]);
        XCTAssertEqualObjects(delegateCallbackResult.delayReasonDescription, @"");
    }];
}

- (void)testStanzaSkipping
{
    self.storageCallbackResult.expectation = [self expectationWithDescription:@"Test skipped storage callback expectation"];
    self.storageCallbackResult.expectation.inverted = YES;
    
    XMPPDelayedDeliveryTestCallbackResult *delegateCallbackResult = [[XMPPDelayedDeliveryTestCallbackResult alloc] init];
    delegateCallbackResult.expectation = [self expectationWithDescription:@"Test skipped delegate callback expectation"];
    delegateCallbackResult.expectation.inverted = YES;
    
    [self fakePlainMessage];
    [self fakePlainPresence];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)fakeDelayedDeliveryMessage
{
    [self.mockStream fakeMessageResponse:
     [[XMPPMessage alloc] initWithXMLString:
      @"<message from='romeo@montague.net/orchard' to='juliet@capulet.com' type='chat'>"
      @"<body>"
      @"O blessed, blessed night! I am afeard."
      @"Being in night, all this is but a dream,"
      @"Too flattering-sweet to be substantial."
      @"</body>"
      @"<delay xmlns='urn:xmpp:delay' from='capulet.com' stamp='2002-09-10T23:08:25Z'>"
      @"Offline Storage"
      @"</delay>"
      @"</message>"
                                      error:nil]];
}

- (void)fakeDelayedDeliveryPresence
{
    [self.mockStream fakeResponse:
     [[XMPPPresence alloc] initWithXMLString:
      @"<presence from='juliet@capulet.com/balcony' to='romeo@montague.net'>"
      @"<status>anon!</status>"
      @"<show>xa</show>"
      @"<priority>1</priority>"
      @"<delay xmlns='urn:xmpp:delay' from='juliet@capulet.com/balcony' stamp='2002-09-10T23:41:07Z'/>"
      @"</presence>"
                                       error:nil]];
}

- (void)fakePlainMessage
{
    [self.mockStream fakeMessageResponse:
     [[XMPPMessage alloc] initWithXMLString:
      @"<message from='romeo@montague.net/orchard' to='juliet@capulet.com' type='chat'>"
      @"<body>"
      @"O blessed, blessed night! I am afeard."
      @"Being in night, all this is but a dream,"
      @"Too flattering-sweet to be substantial."
      @"</body>"
      @"</message>"
                                      error:nil]];
}

- (void)fakePlainPresence
{
    [self.mockStream fakeResponse:
     [[XMPPPresence alloc] initWithXMLString:
      @"<presence from='juliet@capulet.com/balcony' to='romeo@montague.net'>"
      @"<status>anon!</status>"
      @"<show>xa</show>"
      @"<priority>1</priority>"
      @"</presence>"
                                       error:nil]];
}

@end

@implementation XMPPDelayedDeliveryTestCallbackResult

- (BOOL)configureWithParent:(XMPPDelayedDelivery *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

- (void)storeDelayedDeliveryDate:(NSDate *)delayedDeliveryDate delayOriginJID:(XMPPJID *)delayOriginJID delayReasonDescription:(NSString *)delayReasonDescription forIncomingMessage:(XMPPMessage *)message withEvent:(XMPPElementEvent *)event
{
    self.delayedDeliveryDate = delayedDeliveryDate;
    self.delayOriginJID = delayOriginJID;
    self.delayReasonDescription = delayReasonDescription;
    
    [self.expectation fulfill];
}

- (void)xmppDelayedDelivery:(XMPPDelayedDelivery *)xmppDelayedDelivery didReceiveDelayedMessage:(XMPPMessage *)delayedMessage withDelayedDeliveryDate:(NSDate *)delayedDeliveryDate delayOriginJID:(XMPPJID *)delayOriginJID delayReasonDescription:(NSString *)delayReasonDescription
{
    self.delayedDeliveryDate = delayedDeliveryDate;
    self.delayOriginJID = delayOriginJID;
    self.delayReasonDescription = delayReasonDescription;
    
    [self.expectation fulfill];
}

- (void)xmppDelayedDelivery:(XMPPDelayedDelivery *)xmppDelayedDelivery didReceiveDelayedPresence:(XMPPPresence *)delayedPresence withDelayedDeliveryDate:(NSDate *)delayedDeliveryDate delayOriginJID:(XMPPJID *)delayOriginJID delayReasonDescription:(NSString *)delayReasonDescription
{
    self.delayedDeliveryDate = delayedDeliveryDate;
    self.delayOriginJID = delayOriginJID;
    self.delayReasonDescription = delayReasonDescription;
    
    [self.expectation fulfill];
}

@end
