#import <XCTest/XCTest.h>
#import "XMPPMockStream.h"

@interface XMPPOneToOneChatTests : XCTestCase <XMPPOneToOneChatStorage, XMPPOneToOneChatDelegate>

@property (nonatomic, strong) XMPPMockStream *mockStream;
@property (nonatomic, strong) XMPPOneToOneChat *oneToOneChat;
@property (nonatomic, strong) XCTestExpectation *storageCallbackExpectation;
@property (nonatomic, strong) XCTestExpectation *delegateCallbackExpectation;

@end

@implementation XMPPOneToOneChatTests

- (void)setUp
{
    [super setUp];
    self.mockStream = [[XMPPMockStream alloc] init];
    self.oneToOneChat = [[XMPPOneToOneChat alloc] initWithStorage:self dispatchQueue:nil];
    [self.oneToOneChat addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.oneToOneChat activate:self.mockStream];
}

- (void)testIncomingMessageHandling
{
    self.storageCallbackExpectation = [self expectationWithDescription:@"Incoming message storage callback expectation"];
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Incoming message delegate callback expectation"];
    
    XMPPMessage *chatMessage = [[XMPPMessage alloc] initWithXMLString:
                                @"<message from='juliet@example.com'"
                                @"         to='romeo@example.net'"
                                @"         type='chat'>"
                                @"  <body>Art thou not Romeo, and a Montague?</body>"
                                @"</message>"
                                                                error:nil];
    
    XMPPMessage *emptyMessage = [[XMPPMessage alloc] initWithXMLString:
                                 @"<message from='juliet@example.com' to='romeo@example.net'/>"
                                                                 error:nil];
    
    [self.mockStream fakeMessageResponse:chatMessage];
    [self.mockStream fakeMessageResponse:emptyMessage];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testOutgoingMessageHandling
{
    self.storageCallbackExpectation = [self expectationWithDescription:@"Sent message storage callback expectation"];
    
    XMPPMessage *chatMessage = [[XMPPMessage alloc] initWithXMLString:
                                @"<message to='romeo@example.net'"
                                @"         type='chat'>"
                                @"  <body>Art thou not Romeo, and a Montague?</body>"
                                @"</message>"
                                                                error:nil];
    
    XMPPMessage *emptyMessage = [[XMPPMessage alloc] initWithXMLString:
                                 @"<message to='romeo@example.net'/>"
                                                                 error:nil];
    
    [self.mockStream sendElement:chatMessage];
    [self.mockStream sendElement:emptyMessage];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (BOOL)configureWithParent:(XMPPOneToOneChat *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

- (void)storeIncomingChatMessage:(XMPPMessage *)message inContextOfEvent:(XMPPElementEvent *)event
{
    [self.storageCallbackExpectation fulfill];
}

- (void)registerSentChatMessageEvent:(XMPPElementEvent *)event
{
    [self.storageCallbackExpectation fulfill];
}

- (void)xmppOneToOneChat:(XMPPOneToOneChat *)xmppOneToOneChat didReceiveChatMessage:(XMPPMessage *)message
{
    [self.delegateCallbackExpectation fulfill];
}

@end
