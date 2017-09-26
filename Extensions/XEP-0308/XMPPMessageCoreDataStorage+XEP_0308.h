#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageBaseNode.h"
#import "XMPPLastMessageCorrection.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessageCoreDataStorage (XEP_0308) <XMPPLastMessageCorrectionStorage>

- (void)storeIncomingCorrectedMessage:(XMPPMessage *)correctedMessage
                     forMessageWithID:(NSString *)originalMessageID
                            withEvent:(XMPPElementEvent *)event;

@end

@interface XMPPMessageBaseNode (XEP_0308)

+ (nullable XMPPMessageBaseNode *)findCorrectionForMessageWithID:(NSString *)originalMessageID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (BOOL)hasAssociatedCorrectionMessage;
- (nullable NSString *)messageCorrectionID;

- (void)assignMessageCorrectionID:(NSString *)originalMessageID forStreamEventID:(NSString *)streamEventID;

@end

NS_ASSUME_NONNULL_END
