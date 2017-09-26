#import <XCTest/XCTest.h>
#import "XMPPMockStream.h"

@interface XMPPLastMessageCorrectionTests : XCTestCase <XMPPLastMessageCorrectionStorage, XMPPLastMessageCorrectionDelegate>

@property (nonatomic, strong) XMPPMockStream *mockStream;
@property (nonatomic, strong) XMPPLastMessageCorrection *lastMessageCorrection;
@property (nonatomic, strong) XCTestExpectation *storageCallbackExpectation;
@property (nonatomic, strong) XCTestExpectation *delegateCallbackExpectation;

@end

@implementation XMPPLastMessageCorrectionTests

- (void)setUp
{
    [super setUp];
    
    self.mockStream = [[XMPPMockStream alloc] init];
    self.mockStream.myJID = [XMPPJID jidWithString:@"romeo@montague.net/home"];
    self.lastMessageCorrection = [[XMPPLastMessageCorrection alloc] initWithStorage:self dispatchQueue:nil];
    [self.lastMessageCorrection addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.lastMessageCorrection activate:self.mockStream];
}

- (void)testStorageCallback
{
    self.storageCallbackExpectation = [self expectationWithDescription:@"Storage callback expectation"];
    
    [self fakeIncomingMessageWithID:@"bad" body:@"O Romeo, Romeo! wherefore art thee Romeo?" correctedMessageID:nil senderJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony"]];
    [self fakeIncomingMessageWithID:@"good" body:@"O Romeo, Romeo! wherefore art thou Romeo?" correctedMessageID:@"bad" senderJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony"]];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (BOOL)configureWithParent:(XMPPLastMessageCorrection *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

- (void)storeIncomingCorrectedMessage:(XMPPMessage *)correctedMessage forMessageWithID:(NSString *)originalMessageID withEvent:(XMPPElementEvent *)event
{
    if ([[correctedMessage elementID] isEqualToString:@"good"] && [originalMessageID isEqualToString:@"bad"]) {
        [self.storageCallbackExpectation fulfill];
    }
}

- (void)testOutgoingMessageCorrectionEligibilty
{
    [self fakeSendingMessageWithID:@"bad1" recipientJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony1"]];
    [self fakeSendingMessageWithID:@"bad2" recipientJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony2"]];
    [self fakeSendingMessageWithID:@"bad3" recipientJID:[XMPPJID jidWithString:@"nurse@capulet.net/balcony"]];
    
    XCTAssertFalse([self.lastMessageCorrection canCorrectSentMessageWithID:@"bad1"]);
    XCTAssertTrue([self.lastMessageCorrection canCorrectSentMessageWithID:@"bad2"]);
    XCTAssertTrue([self.lastMessageCorrection canCorrectSentMessageWithID:@"bad3"]);
}

- (void)testMUCPostRejoinOutgoingMessageCorrectionEligibilty
{
    [self fakeSendingMessageWithID:@"bad1" recipientJID:[XMPPJID jidWithString:@"coven@chat.shakespeare.lit"]];
    [self fakeRejoiningMUCRoomWithJID:[XMPPJID jidWithString:@"coven@chat.shakespeare.lit"] occupantJID:nil];
    
    XCTAssertFalse([self.lastMessageCorrection canCorrectSentMessageWithID:@"bad1"]);
}

- (void)testMUCLightPostRejoinOutgoingMessageCorrectionEligibilty
{
    [self fakeSendingMessageWithID:@"bad1" recipientJID:[XMPPJID jidWithString:@"coven@muclight.shakespeare.lit"]];
    [self fakeRejoiningMUCLightRoomWithJID:[XMPPJID jidWithString:@"coven@muclight.shakespeare.lit"] occupantJID:nil];
    
    XCTAssertFalse([self.lastMessageCorrection canCorrectSentMessageWithID:@"bad1"]);
}

- (void)testIncomingMessageCorrectionFiltering
{
    self.delegateCallbackExpectation = [self expectationWithDescription:@"Incoming message correction filtering delegate callback expectation"];
    
    [self fakeIncomingMessageWithID:@"bad1" body:@"O Romeo, Romeo! wherefore art thee Romeo?" correctedMessageID:nil senderJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony1"]];
    [self fakeIncomingMessageWithID:@"bad2" body:@"O Romeo, Romeo! wherefore art thee Romeo?" correctedMessageID:nil senderJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony2"]];
    
    [self fakeIncomingMessageWithID:@"good1" body:@"O Romeo, Romeo! wherefore art thou Romeo?" correctedMessageID:@"bad1" senderJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony1"]];
    [self fakeIncomingMessageWithID:@"filtered1" body:@"O Romeo, Romeo! wherefore art thou Romeo?" correctedMessageID:@"bad1" senderJID:[XMPPJID jidWithString:@"juliet@capulet.net/balcony1"]];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testMUCPostRejoinIncomingMessageCorrectionFiltering
{
    self.delegateCallbackExpectation = [self expectationWithDescription:@"MUC post-rejoin incoming message correction filtering delegate callback expectation"];
    self.delegateCallbackExpectation.inverted = YES;
    
    [self fakeIncomingMessageWithID:@"bad1"
                               body:@"Harpier cries: `tis time, `tis time."
                 correctedMessageID:nil
                          senderJID:[XMPPJID jidWithString:@"coven@chat.shakespeare.lit/thirdwitch"]];
    
    [self fakeRejoiningMUCRoomWithJID:[XMPPJID jidWithString:@"coven@chat.shakespeare.lit"]
                          occupantJID:[XMPPJID jidWithString:@"coven@chat.shakespeare.lit/thirdwitch"]];
    
    [self fakeIncomingMessageWithID:@"good1"
                               body:@"Harpier cries: 'tis time, 'tis time."
                 correctedMessageID:@"bad1"
                          senderJID:[XMPPJID jidWithString:@"coven@chat.shakespeare.lit/thirdwitch"]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testMUCLightPostRejoinIncomingMessageCorrectionFiltering
{
    self.delegateCallbackExpectation = [self expectationWithDescription:@"MUC Light post-rejoin incoming message correction filtering delegate callback expectation"];
    self.delegateCallbackExpectation.inverted = YES;
    
    [self fakeIncomingMessageWithID:@"bad1"
                               body:@"Harpier cries: `tis time, `tis time."
                 correctedMessageID:nil
                          senderJID:[XMPPJID jidWithString:@"coven@muclight.shakespeare.lit/hag66@shakespeare.lit"]];
    
    [self fakeRejoiningMUCLightRoomWithJID:[XMPPJID jidWithString:@"coven@muclight.shakespeare.lit"]
                               occupantJID:[XMPPJID jidWithString:@"hag66@shakespeare.lit"]];
    
    [self fakeIncomingMessageWithID:@"good1"
                               body:@"Harpier cries: 'tis time, 'tis time."
                 correctedMessageID:@"bad1"
                          senderJID:[XMPPJID jidWithString:@"coven@muclight.shakespeare.lit/hag66@shakespeare.lit"]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)xmppLastMessageCorrection:(XMPPLastMessageCorrection *)xmppLastMessageCorrection didReceiveCorrectedMessage:(XMPPMessage *)correctedMessage
{
    if ([[correctedMessage elementID] hasPrefix:@"good"]) {
        [self.delegateCallbackExpectation fulfill];
    }
}

- (void)testCapabilitiesReporting
{
    NSXMLElement *capabilitiesQuery = [self fakeCapabilitiesQuery];
    
    NSInteger messageCorrectionFeatureElementCount = 0;
    for (NSXMLElement *child in capabilitiesQuery.children) {
        if ([child.name isEqualToString:@"feature"] &&
            [[child attributeForName:@"var"].stringValue isEqualToString:@"urn:xmpp:message-correct:0"]) {
            ++messageCorrectionFeatureElementCount;
        }
    }
    
    XCTAssertEqual(messageCorrectionFeatureElementCount, 1);
}

- (void)fakeSendingMessageWithID:(NSString *)messageID recipientJID:(XMPPJID *)toJID
{
    dispatch_sync(self.mockStream.xmppQueue, ^{
        [self.mockStream sendElement:
         [[XMPPMessage alloc] initWithXMLString:
          [NSString stringWithFormat:
           @"<message to='%@' id='%@'>"
           @"  <body>But soft, what light through yonder airlock breaks?</body>"
           @"</message>", [toJID full], messageID]
                                          error:nil]];
    });
}

- (void)fakeIncomingMessageWithID:(NSString *)messageID body:(NSString *)body correctedMessageID:(NSString *)correctedMessageID senderJID:(XMPPJID *)senderJID
{
    dispatch_sync(self.mockStream.xmppQueue, ^{
        XMPPMessage *fakeMessage = [[XMPPMessage alloc] initWithXMLString:
                                    [NSString stringWithFormat:
                                     @"<message from='%@' to='romeo@montague.net/home' id='%@'>"
                                     @"  <body>O Romeo, Romeo! wherefore art thou Romeo?</body>"
                                     @"</message>", [senderJID full], messageID]
                                                                    error:nil];
        if (correctedMessageID) {
            [fakeMessage addChild:[[NSXMLElement alloc] initWithXMLString:
                                   [NSString stringWithFormat:
                                    @"<replace id='%@' xmlns='urn:xmpp:message-correct:0'/>", correctedMessageID]
                                                                    error:nil]];
        }
        [self.mockStream fakeMessageResponse:fakeMessage];
    });
}

- (void)fakeRejoiningMUCRoomWithJID:(XMPPJID *)roomJID occupantJID:(XMPPJID *)occupantJID
{
    XMPPRoom *fakeRoom = [[XMPPRoom alloc] initWithRoomStorage:[[XMPPRoomMemoryStorage alloc] init] jid:roomJID];
    [fakeRoom activate:self.mockStream];
    dispatch_sync(self.mockStream.xmppQueue, ^{
        if (occupantJID) {
            [(id)fakeRoom.multicastDelegate xmppRoom:fakeRoom occupantDidJoin:occupantJID withPresence:[[XMPPPresence alloc] init]];
        } else {
            [(id)fakeRoom.multicastDelegate xmppRoomDidJoin:fakeRoom];
        }
    });
}

- (void)fakeRejoiningMUCLightRoomWithJID:(XMPPJID *)roomJID occupantJID:(XMPPJID *)occupantJID
{
    XMPPMUCLight *fakeMUCLight = [[XMPPMUCLight alloc] init];
    [fakeMUCLight activate:self.mockStream];
    dispatch_sync(self.mockStream.xmppQueue, ^{
        [[fakeMUCLight valueForKey:@"multicastDelegate"] xmppMUCLight:fakeMUCLight
                                                   changedAffiliation:@"member"
                                                              userJID:occupantJID ?: [self.mockStream.myJID bareJID]
                                                              roomJID:roomJID];
    });
}

- (NSXMLElement *)fakeCapabilitiesQuery
{
    XMPPCapabilities *testCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:[[XMPPCapabilitiesCoreDataStorage alloc] initWithInMemoryStore]];
    [testCapabilities activate:self.mockStream];
    
    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='http://jabber.org/protocol/disco#info'/>" error:nil];
    
    dispatch_sync(self.mockStream.xmppQueue, ^{
        GCDMulticastDelegateEnumerator *delegateEnumerator = [[testCapabilities valueForKey:@"multicastDelegate"] delegateEnumerator];
        id delegate;
        dispatch_queue_t delegateQueue;
        while ([delegateEnumerator getNextDelegate:&delegate delegateQueue:&delegateQueue forSelector:@selector(xmppCapabilities:collectingMyCapabilities:)]) {
            dispatch_sync(delegateQueue, ^{
                [delegate xmppCapabilities:testCapabilities collectingMyCapabilities:query];
            });
        }
    });
    
    return query;
}

@end
