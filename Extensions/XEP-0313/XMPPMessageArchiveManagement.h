//
//  XMPPMessageArchiveManagement.h
//
//  Created by Andres Canal on 4/8/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

#import "XMPPModule.h"
#import "XMPPResultSet.h"
#import "XMPPIQ.h"

@protocol XMPPMessageArchiveManagementLocalStorage;
@class XMPPIDTracker;
@class XMPPMessage;
@class XMPPElementEvent;

@interface XMPPMessageArchiveManagement : XMPPModule {
	XMPPIDTracker *xmppIDTracker;
}

/**
 When this is set to 0 (the default), the module will finish retrieving messages after receiving the first page IQ result.
 Setting it to a non-zero value will cause the module to automatically repeat the query for further pages of specified size until a "fin" result with "complete=true" attribute is received.
 Use NSNotFound to indicate that there is no client-side page size preference.
 */
@property (readwrite, assign) NSInteger resultAutomaticPagingPageSize;

/**
 When enabled, original messages unwrapped from query results will be injected back into the stream, exposing them to other modules.
 Disabled by default.
 */
@property (readwrite, assign) BOOL submitsPayloadMessagesForStreamProcessing;

- (instancetype)initWithLocalStorage:(id<XMPPMessageArchiveManagementLocalStorage>)localStorage dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)retrieveMessageArchiveWithFields:(NSArray *)fields withResultSet:(XMPPResultSet *)resultSet;
- (void)retrieveMessageArchiveAt:(XMPPJID *)archiveJID withFields:(NSArray *)fields withResultSet:(XMPPResultSet *)resultSet;
- (void)retrieveFormFields;
+ (NSXMLElement *)fieldWithVar:(NSString *)var type:(NSString *)type andValue:(NSString *)value;

@end

@protocol XMPPMessageArchiveManagementLocalStorage <NSObject>

- (BOOL)configureWithParent:(XMPPMessageArchiveManagement *)parent queue:(dispatch_queue_t)queue;

- (void)storePayloadMessage:(XMPPMessage *)payloadMessage
       withMessageArchiveID:(NSString *)archiveID
                  timestamp:(NSDate *)timestamp
                      event:(XMPPElementEvent *)event;
- (void)finalizeResultSetPageWithMessageArchiveIDs:(NSArray<NSString *> *)archiveIDs;

@end

@protocol XMPPMessageArchiveManagementDelegate
@optional
- (void)xmppMessageArchiveManagement:(XMPPMessageArchiveManagement *)xmppMessageArchiveManagement didFinishReceivingMessagesWithSet:(XMPPResultSet *)resultSet;
- (void)xmppMessageArchiveManagement:(XMPPMessageArchiveManagement *)xmppMessageArchiveManagement didReceiveMAMMessage:(XMPPMessage *)message;
- (void)xmppMessageArchiveManagement:(XMPPMessageArchiveManagement *)xmppMessageArchiveManagement didFailToReceiveMessages:(XMPPIQ *)error;

- (void)xmppMessageArchiveManagement:(XMPPMessageArchiveManagement *)xmppMessageArchiveManagement didReceiveFormFields:(XMPPIQ *)iq;
- (void)xmppMessageArchiveManagement:(XMPPMessageArchiveManagement *)xmppMessageArchiveManagement didFailToReceiveFormFields:(XMPPIQ *)iq;
@end
