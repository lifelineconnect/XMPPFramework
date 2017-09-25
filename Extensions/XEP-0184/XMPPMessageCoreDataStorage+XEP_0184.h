#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPMessageDeliveryReceipts.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageCoreDataStorage (XEP_0184) <XMPPMessageDeliveryReceiptsStorage>

- (void)storeDeliveryReceiptForMessageID:(NSString *)deliveredMessageID
                       receivedInMessage:(XMPPMessage *)receiptMessage
                               withEvent:(XMPPElementEvent *)event;

@end

@interface XMPPMessageBaseNode (XEP_0184)

+ (nullable XMPPMessageBaseNode *)findDeliveryReceiptResponseForMessageWithID:(NSString *)messageID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (BOOL)hasAssociatedDeliveryReceiptResponseMessage;
- (nullable NSString *)messageDeliveryReceiptResponseID;

@end

NS_ASSUME_NONNULL_END
