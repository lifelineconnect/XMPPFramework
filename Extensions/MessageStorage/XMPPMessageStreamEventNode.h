#import "XMPPMessageOriginNode.h"

@class XMPPJID;

typedef NS_ENUM(int16_t, XMPPMessageStreamEventKind) {
    XMPPMessageStreamEventKindUnspecified,
    XMPPMessageStreamEventKindIncoming,
    XMPPMessageStreamEventKindOutgoing
};

@interface XMPPMessageStreamEventNode : XMPPMessageOriginNode

@property (nonatomic, copy, nullable) NSString *eventID;
@property (nonatomic, assign) XMPPMessageStreamEventKind kind;
@property (nonatomic, strong, nullable) XMPPJID *streamJID;

@end
