#import "XMPPCapabilities.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPJID;

@interface XMPPCapabilities (XEP_0308)

- (BOOL)isLastMessageCorrectionCapabilityConfirmedForJID:(XMPPJID *)jid;

@end

NS_ASSUME_NONNULL_END
