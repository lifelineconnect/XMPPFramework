#import <XCTest/XCTest.h>
#import "XMPPMockStream.h"

@interface XMPPMessageDeliveryReceiptsTests : XCTestCase <XMPPMessageDeliveryReceiptsStorage, XMPPMessageDeliveryReceiptsDelegate>

@property (strong, nonatomic) XMPPMockStream *mockStream;
@property (strong, nonatomic) XMPPMessageDeliveryReceipts *messageDeliveryReceipts;
@property (strong, nonatomic) XCTestExpectation *storageCallbackExpectation;
@property (strong, nonatomic) XCTestExpectation *delegateCallbackExpectation;

@end

@implementation XMPPMessageDeliveryReceiptsTests

- (void)setUp
{
    [super setUp];
    self.mockStream = [[XMPPMockStream alloc] init];
    self.messageDeliveryReceipts = [[XMPPMessageDeliveryReceipts alloc] initWithStorage:self dispatchQueue:nil];
    [self.messageDeliveryReceipts addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.messageDeliveryReceipts activate:self.mockStream];
}

- (void)testReceiptResponseStorageCallback
{
    self.storageCallbackExpectation = [self expectationWithDescription:@"Storage callback expectation"];
    
    [self fakeReceiptResponse];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (BOOL)configureWithParent:(XMPPMessageDeliveryReceipts *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

- (void)storeDeliveryReceiptForMessageID:(NSString *)deliveredMessageID receivedInMessage:(XMPPMessage *)receiptMessage withEvent:(XMPPElementEvent *)event
{
    if ([deliveredMessageID isEqualToString:@"richard2-4.1.247"]) {
        [self.storageCallbackExpectation fulfill];
    }
}

- (void)testReceiptResponseDelegateCallback
{
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Delegate callback expectation"];
    
    [self fakeReceiptResponse];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)xmppMessageDeliveryReceipts:(XMPPMessageDeliveryReceipts *)xmppMessageDeliveryReceipts didReceiveReceiptResponseMessage:(XMPPMessage *)message
{
    if ([message hasReceiptResponse]) {
        [self.delegateCallbackExpectation fulfill];
    }
}

- (void)fakeReceiptResponse
{
    [self.mockStream fakeMessageResponse:
     [[XMPPMessage alloc] initWithXMLString:
      @"<message"
      @"    from='kingrichard@royalty.england.lit/throne'"
      @"    id='bi29sg183b4v'"
      @"    to='northumberland@shakespeare.lit/westminster'>"
      @"  <received xmlns='urn:xmpp:receipts' id='richard2-4.1.247'/>"
      @"</message>"
                                      error:nil]];
}

@end
