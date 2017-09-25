#import "XMPPModule.h"

#define _XMPP_MESSAGE_DELIVERY_RECEIPTS_H

@protocol XMPPMessageDeliveryReceiptsStorage;
@class XMPPMessage, XMPPElementEvent;

/**
 * XMPPMessageDeliveryReceipts can be configured to automatically send delivery receipts and requests in accordance to XEP-0184
**/

@interface XMPPMessageDeliveryReceipts : XMPPModule

/**
 * Automatically add message delivery requests to outgoing messages, in all situations that are permitted in XEP-0184
 *
 * - Message MUST NOT be of type 'error' or 'groupchat'
 * - Message MUST have an id
 * - Message MUST NOT have a delivery receipt or request
 * - To must either be a bare JID or a full JID that advertises the urn:xmpp:receipts capability
 *
 * Default NO
**/

@property (assign) BOOL autoSendMessageDeliveryRequests;

/**
 * Automatically send message delivery receipts when a message with a delivery request is received 
 *
 * Default NO
**/

@property (assign) BOOL autoSendMessageDeliveryReceipts;

- (instancetype)initWithStorage:(id<XMPPMessageDeliveryReceiptsStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

@end

@protocol XMPPMessageDeliveryReceiptsStorage <NSObject>

- (BOOL)configureWithParent:(XMPPMessageDeliveryReceipts *)aParent queue:(dispatch_queue_t)queue;
- (void)storeDeliveryReceiptForMessageID:(NSString *)deliveredMessageID
                       receivedInMessage:(XMPPMessage *)receiptMessage
                               withEvent:(XMPPElementEvent *)event;

@end

@protocol XMPPMessageDeliveryReceiptsDelegate <NSObject>

@optional
- (void)xmppMessageDeliveryReceipts:(XMPPMessageDeliveryReceipts *)xmppMessageDeliveryReceipts didReceiveReceiptResponseMessage:(XMPPMessage *)message;

@end
