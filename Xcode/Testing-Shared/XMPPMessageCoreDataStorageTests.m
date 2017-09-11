//
//  XMPPMessageCoreDataStorageTests.m
//  XMPPFrameworkTests
//
//  Created by Piotr Wegrzynek on 10/08/2017.
//
//

#import <XCTest/XCTest.h>
@import XMPPFramework;

@interface XMPPMessageCoreDataStorageTests : XCTestCase

@property (nonatomic, strong) XMPPMessageCoreDataStorage *storage;

@end

@implementation XMPPMessageCoreDataStorageTests

- (void)setUp
{
    [super setUp];
    
    self.storage = [[XMPPMessageCoreDataStorage alloc] initWithDatabaseFilename:NSStringFromSelector(self.invocation.selector)
                                                                   storeOptions:nil];
    self.storage.autoRemovePreviousDatabaseFile = YES;
}

- (void)testBaseNodeTransientPropertyDirectUpdates
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    [self.storage.mainThreadManagedObjectContext save:NULL];
    [self.storage.mainThreadManagedObjectContext refreshObject:messageNode mergeChanges:NO];
    
    XCTAssertEqualObjects(messageNode.fromJID, [XMPPJID jidWithString:@"user1@domain1/resource1"]);
    XCTAssertEqualObjects(messageNode.toJID, [XMPPJID jidWithString:@"user2@domain2/resource2"]);
}

- (void)testBaseNodeTransientPropertyMergeUpdates
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    [self.storage.mainThreadManagedObjectContext save:NULL];
    
    [self expectationForNotification:NSManagedObjectContextObjectsDidChangeNotification object:self.storage.mainThreadManagedObjectContext handler:nil];
    
    [self.storage scheduleBlock:^{
        XMPPMessageBaseNode *storageContextMessageNode = [self.storage.managedObjectContext objectWithID:messageNode.objectID];
        storageContextMessageNode.fromJID = [XMPPJID jidWithString:@"user1a@domain1a/resource1a"];
        storageContextMessageNode.toJID = [XMPPJID jidWithString:@"user2a@domain2a/resource2a"];
        [self.storage save];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssert([messageNode.fromJID isEqualToJID:[XMPPJID jidWithString:@"user1a@domain1a/resource1a"]]);
        XCTAssert([messageNode.toJID isEqualToJID:[XMPPJID jidWithString:@"user2a@domain2a/resource2a"]]);
    }];
}

- (void)testBaseNodeTransientPropertyKeyValueObserving
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    [self keyValueObservingExpectationForObject:messageNode
                                        keyPath:NSStringFromSelector(@selector(fromJID))
                                  expectedValue:[XMPPJID jidWithString:@"user1@domain1/resource1"]];
    [self keyValueObservingExpectationForObject:messageNode
                                        keyPath:NSStringFromSelector(@selector(toJID))
                                  expectedValue:[XMPPJID jidWithString:@"user2@domain2/resource2"]];
    
    messageNode.fromJID = [XMPPJID jidWithString:@"user1@domain1/resource1"];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    [self waitForExpectationsWithTimeout:0 handler:nil];
}

- (void)testIncomingMessageStorage
{
    NSDictionary<NSString *, NSNumber *> *messageTypes = @{@"chat": @(XMPPMessageTypeChat),
                                                           @"error": @(XMPPMessageTypeError),
                                                           @"groupchat": @(XMPPMessageTypeGroupchat),
                                                           @"headline": @(XMPPMessageTypeHeadline),
                                                           @"normal": @(XMPPMessageTypeNormal)};
    
    for (NSString *typeString in messageTypes) {
        NSMutableString *messageString = [NSMutableString string];
        [messageString appendFormat: @"<message from='user1@domain1/resource1' to='user2@domain2/resource2' type='%@' id='messageID'>", typeString];
        [messageString appendString: @"	 <body>body</body>"];
        [messageString appendString: @"	 <subject>subject</subject>"];
        [messageString appendString: @"	 <thread>thread</thread>"];
        [messageString appendString: @"</message>"];
        
        NSDate *timestamp = [NSDate date];
        
        XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:[NSString stringWithFormat:@"eventID_%@", typeString]
                                                                                                  streamJID:[XMPPJID jidWithString:@"user2@domain2/resource2"]
                                                                                                withMessage:[[XMPPMessage alloc] initWithXMLString:messageString error:NULL]
                                                                                                  timestamp:timestamp
                                                                                     inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
        
        XCTAssertEqualObjects(messageNode.fromJID, [XMPPJID jidWithString:@"user1@domain1/resource1"]);
        XCTAssertEqualObjects(messageNode.toJID, [XMPPJID jidWithString:@"user2@domain2/resource2"]);
        XCTAssertEqualObjects(messageNode.body, @"body");
        XCTAssertEqual(messageNode.direction, XMPPMessageDirectionIncoming);
        XCTAssertEqualObjects(messageNode.stanzaID, @"messageID");
        XCTAssertEqualObjects(messageNode.subject, @"subject");
        XCTAssertEqualObjects(messageNode.thread, @"thread");
        XCTAssertEqual(messageNode.type, messageTypes[typeString].intValue);
        XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user2@domain2/resource2"]);
        XCTAssertEqualObjects([messageNode streamTimestamp], timestamp);
    }
}

- (void)testIncomingMessageExistingEventLookup
{
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    XMPPMessageBaseNode *existingNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:@"eventID"
                                                                                               streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                             withMessage:[[XMPPMessage alloc] init]
                                                                                               timestamp:timestamp
                                                                                  inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    XMPPMessageBaseNode *repeatedQueryNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:@"eventID"
                                                                                                    streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                                  withMessage:[[XMPPMessage alloc] init]
                                                                                                    timestamp:timestamp
                                                                                       inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    XCTAssertEqualObjects(existingNode, repeatedQueryNode);
}

- (void)testOutgoingMessageNodeInsertion
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerOutgoingMessageStreamEventID:@"outgoingMessageEventID"];
    XMPPMessageBaseNode *foundNode = [XMPPMessageBaseNode findForOutgoingMessageStreamEventID:@"outgoingMessageEventID"
                                                                       inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    XCTAssertEqual(messageNode.direction, XMPPMessageDirectionOutgoing);
    XCTAssertEqualObjects(messageNode, foundNode);
}

- (void)testSingleSentMessageRegistration
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerOutgoingMessageStreamEventID:@"outgoingMessageEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    
    XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user@domain/resource"]);
    XCTAssertEqualObjects([messageNode streamTimestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:0]);
}

- (void)testRepeatedSentMessageRegistration
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerOutgoingMessageStreamEventID:@"initialEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user1@domain1/resource1"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [messageNode registerOutgoingMessageStreamEventID:@"subsequentEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user2@domain2/resource2"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    
    XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user2@domain2/resource2"]);
    XCTAssertEqualObjects([messageNode streamTimestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:1]);
}

- (void)testRetiredSentMessageResitration
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerOutgoingMessageStreamEventID:@"eventID"];
    [messageNode retireStreamTimestamp];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    
    XCTAssertEqualObjects([messageNode streamJID], [XMPPJID jidWithString:@"user@domain/resource"]);
    XCTAssertEqualObjects([messageNode streamTimestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:0]);
}

- (void)testBasicStreamTimestampMessageContextFetch
{
    XMPPMessageBaseNode *firstMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:@"firstMessageEventID"
                                                                                                   streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                                 withMessage:[[XMPPMessage alloc] init]
                                                                                                   timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                      inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    XMPPMessageBaseNode *secondMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:@"secondMessageEventID"
                                                                                                    streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                                  withMessage:[[XMPPMessage alloc] init]
                                                                                                    timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                                       inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:[XMPPMessageBaseNode streamTimestampContextPredicate]
                                                                            inAscendingOrder:YES
                                                                    fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *result = [self.storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    XCTAssertEqual(result.count, 2);
    XCTAssertEqualObjects(result[0].relevantMessageNode, firstMessageNode);
    XCTAssertEqualObjects(result[1].relevantMessageNode, secondMessageNode);
}

- (void)testRetiredStreamTimestampMessageContextFetch
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    [messageNode registerOutgoingMessageStreamEventID:@"retiredMessageEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    [messageNode registerOutgoingMessageStreamEventID:@"retiringMessageEventID"];
    [messageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user@domain/resource"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    
    NSFetchRequest *fetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:[XMPPMessageBaseNode streamTimestampContextPredicate]
                                                                            inAscendingOrder:YES
                                                                    fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *result = [self.storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    XCTAssertEqual(result.count, 1);
    XCTAssertEqualObjects([result[0].relevantMessageNode streamTimestamp], [NSDate dateWithTimeIntervalSinceReferenceDate:1]);
}

- (void)testRelevantMessageJIDContextFetch
{
    XMPPMessageBaseNode *incomingMessageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:@"incomingMessageEventID"
                                                                                                      streamJID:[XMPPJID jidWithString:@"user1@domain1/resource1"]
                                                                                                    withMessage:[[XMPPMessage alloc] init]
                                                                                                      timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                         inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    incomingMessageNode.fromJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    
    XMPPMessageBaseNode *outgoingMessageNode = [XMPPMessageBaseNode insertForOutgoingMessageInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    outgoingMessageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    [outgoingMessageNode registerOutgoingMessageStreamEventID:@"outgoingMessageEventID"];
    [outgoingMessageNode registerSentMessageWithStreamJID:[XMPPJID jidWithString:@"user1@domain1/resource1"] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    
    NSPredicate *fromJIDPredicate = [XMPPMessageBaseNode relevantMessageFromJIDPredicateWithValue:[XMPPJID jidWithString:@"user2@domain2/resource2"]
                                                                                   compareOptions:XMPPJIDCompareFull];
    NSFetchRequest *fromJIDFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:fromJIDPredicate
                                                                                   inAscendingOrder:YES
                                                                           fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *fromJIDResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:fromJIDFetchRequest error:NULL];
    
    NSPredicate *toJIDPredicate = [XMPPMessageBaseNode relevantMessageToJIDPredicateWithValue:[XMPPJID jidWithString:@"user2@domain2/resource2"]
                                                                               compareOptions:XMPPJIDCompareFull];
    NSFetchRequest *toJIDFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:toJIDPredicate
                                                                                 inAscendingOrder:YES
                                                                         fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *toJIDResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:toJIDFetchRequest error:NULL];
    
    NSPredicate *remotePartyJIDPredicate = [XMPPMessageBaseNode relevantMessageRemotePartyJIDPredicateWithValue:[XMPPJID jidWithString:@"user2@domain2/resource2"]
                                                                                                 compareOptions:XMPPJIDCompareFull];
    NSFetchRequest *remotePartyJIDFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:remotePartyJIDPredicate
                                                                                          inAscendingOrder:YES
                                                                                  fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *remotePartyJIDResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:remotePartyJIDFetchRequest error:NULL];
    
    XCTAssertEqual(fromJIDResult.count, 1);
    XCTAssertEqualObjects(fromJIDResult[0].relevantMessageNode, incomingMessageNode);
    
    XCTAssertEqual(toJIDResult.count, 1);
    XCTAssertEqualObjects(toJIDResult[0].relevantMessageNode, outgoingMessageNode);
    
    XCTAssertEqual(remotePartyJIDResult.count, 2);
    XCTAssertEqualObjects(remotePartyJIDResult[0].relevantMessageNode, incomingMessageNode);
    XCTAssertEqualObjects(remotePartyJIDResult[1].relevantMessageNode, outgoingMessageNode);
}

- (void)testTimestampRangeContextFetch
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:@"eventID"
                                                                                              streamJID:[XMPPJID jidWithString:@"user@domain/resource"]
                                                                                            withMessage:[[XMPPMessage alloc] init]
                                                                                              timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                 inManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    
    NSPredicate *startEndPredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:-1]
                                                                                              endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    NSFetchRequest *startEndFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:startEndPredicate
                                                                                    inAscendingOrder:YES
                                                                            fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *startEndResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:startEndFetchRequest error:NULL];
    
    NSPredicate *startEndEdgeCasePredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                                      endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    NSFetchRequest *startEndEdgeCaseFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:startEndEdgeCasePredicate
                                                                                            inAscendingOrder:YES
                                                                                    fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *startEndEdgeCaseResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:startEndEdgeCaseFetchRequest error:NULL];
    
    NSPredicate *startPredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:-1]
                                                                                           endValue:nil];
    NSFetchRequest *startFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:startPredicate
                                                                                 inAscendingOrder:YES
                                                                         fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *startResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:startFetchRequest error:NULL];
    
    NSPredicate *startEdgeCasePredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                                                   endValue:nil];
    NSFetchRequest *startEdgeCaseFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:startEdgeCasePredicate
                                                                                         inAscendingOrder:YES
                                                                                 fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *startEdgeCaseResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:startEdgeCaseFetchRequest error:NULL];
    
    NSPredicate *endPredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:nil
                                                                                         endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
    NSFetchRequest *endFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:endPredicate
                                                                               inAscendingOrder:YES
                                                                       fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *endResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:endFetchRequest error:NULL];
    
    NSPredicate *endEdgeCasePredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:nil
                                                                                                 endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    NSFetchRequest *endEdgeCaseFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:endEdgeCasePredicate
                                                                                       inAscendingOrder:YES
                                                                               fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *endEdgeCaseResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:endEdgeCaseFetchRequest error:NULL];
    
    NSPredicate *missPredicate = [XMPPMessageBaseNode contextTimestampRangePredicateWithStartValue:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                                          endValue:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
    NSFetchRequest *missFetchRequest = [XMPPMessageBaseNode requestTimestampContextWithPredicate:missPredicate
                                                                                inAscendingOrder:YES
                                                                        fromManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    NSArray<id<XMPPMessageContextFetchRequestResult>> *missResult = [self.storage.mainThreadManagedObjectContext executeFetchRequest:missFetchRequest error:NULL];
    
    XCTAssertEqual(startEndResult.count, 1);
    XCTAssertEqualObjects(startEndResult[0].relevantMessageNode, messageNode);
    XCTAssertEqual(startEndEdgeCaseResult.count, 1);
    XCTAssertEqualObjects(startEndEdgeCaseResult[0].relevantMessageNode, messageNode);
    
    XCTAssertEqual(startResult.count, 1);
    XCTAssertEqualObjects(startResult[0].relevantMessageNode, messageNode);
    XCTAssertEqual(startEdgeCaseResult.count, 1);
    XCTAssertEqualObjects(startEdgeCaseResult[0].relevantMessageNode, messageNode);
    
    XCTAssertEqual(endResult.count, 1);
    XCTAssertEqualObjects(endResult[0].relevantMessageNode, messageNode);
    XCTAssertEqual(endEdgeCaseResult.count, 1);
    XCTAssertEqualObjects(endEdgeCaseResult[0].relevantMessageNode, messageNode);
    
    XCTAssertEqual(missResult.count, 0);
}

- (void)testBaseMessageCreation
{
    XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode xmpp_insertNewObjectInManagedObjectContext:self.storage.mainThreadManagedObjectContext];
    messageNode.toJID = [XMPPJID jidWithString:@"user2@domain2/resource2"];
    messageNode.body = @"body";
    messageNode.stanzaID = @"messageID";
    messageNode.subject = @"subject";
    messageNode.thread = @"thread";
    
    NSDictionary<NSString *, NSNumber *> *messageTypes = @{@"chat": @(XMPPMessageTypeChat),
                                                           @"error": @(XMPPMessageTypeError),
                                                           @"groupchat": @(XMPPMessageTypeGroupchat),
                                                           @"headline": @(XMPPMessageTypeHeadline),
                                                           @"normal": @(XMPPMessageTypeNormal)};
    
    for (NSString *typeString in messageTypes){
        messageNode.type = messageTypes[typeString].intValue;
        
        XMPPMessage *message = [messageNode baseMessage];
        
        XCTAssertEqualObjects([message to], [XMPPJID jidWithString:@"user2@domain2/resource2"]);
        XCTAssertEqualObjects([message body], @"body");
        XCTAssertEqualObjects([message elementID], @"messageID");
        XCTAssertEqualObjects([message subject], @"subject");
        XCTAssertEqualObjects([message thread], @"thread");
        XCTAssertEqualObjects([message type], typeString);
    }
}

@end
