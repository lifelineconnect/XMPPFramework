#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPMessageArchiveManagement.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, XMPPMAMTimestampContextOptions) {
    XMPPMAMTimestampContextIncludingPartialResultPages = 1 << 0,
    XMPPMAMTimestampContextIncludingDeletedResultItems = 1 << 1,
};

@interface XMPPMessageCoreDataStorage (XEP_0313) <XMPPMessageArchiveManagementLocalStorage>

- (void)storePayloadMessage:(nullable XMPPMessage *)payloadMessage
       withMessageArchiveID:(NSString *)archiveID
                  timestamp:(nullable NSDate *)timestamp
                      event:(XMPPElementEvent *)event;
- (void)finalizeResultSetPageWithMessageArchiveIDs:(NSArray<NSString *> *)archiveIDs;

@end

@interface XMPPMessageBaseNode (XEP_0313)

+ (NSPredicate *)messageArchiveTimestampContextPredicateWithOptions:(XMPPMAMTimestampContextOptions)options;
+ (NSPredicate *)relevantOwnJIDIncomingMessagePredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;

- (nullable NSString *)messageArchiveID;
- (nullable NSDate *)messageArchiveDate;
- (BOOL)isOwnIncomingMessageInContextOfJID:(XMPPJID *)jid withCompareOptions:(XMPPJIDCompareOptions)compareOptions;

@end

NS_ASSUME_NONNULL_END
