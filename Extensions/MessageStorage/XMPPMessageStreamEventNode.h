#import "XMPPMessageOriginNode.h"
#import "XMPPMessageBaseNode.h"

NS_ASSUME_NONNULL_BEGIN

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

+ (nullable XMPPMessageStreamEventNode *)findWithID:(NSString *)streamEventID
                             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface XMPPMessageBaseNode (XMPPMessageStreamEventNode)

- (void)obsoleteOutgoingStreamEvents;

@end

NS_ASSUME_NONNULL_END
