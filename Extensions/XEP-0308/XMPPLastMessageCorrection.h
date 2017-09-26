#import "XMPPModule.h"

NS_ASSUME_NONNULL_BEGIN;

@protocol XMPPLastMessageCorrectionStorage;
@class XMPPMessage, XMPPElementEvent;

@interface XMPPLastMessageCorrection : XMPPModule

- (instancetype)initWithStorage:(nullable id<XMPPLastMessageCorrectionStorage>)storage dispatchQueue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;
- (BOOL)canCorrectSentMessageWithID:(NSString *)messageID;

@end

@protocol XMPPLastMessageCorrectionStorage <NSObject>

- (BOOL)configureWithParent:(XMPPLastMessageCorrection *)aParent queue:(dispatch_queue_t)queue;
- (void)storeIncomingCorrectedMessage:(XMPPMessage *)correctedMessage
                     forMessageWithID:(NSString *)originalMessageID
                            withEvent:(XMPPElementEvent *)event;

@end

@protocol XMPPLastMessageCorrectionDelegate <NSObject>

- (void)xmppLastMessageCorrection:(XMPPLastMessageCorrection *)xmppLastMessageCorrection didReceiveCorrectedMessage:(XMPPMessage *)correctedMessage;

@end

NS_ASSUME_NONNULL_END
