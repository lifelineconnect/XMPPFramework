#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * XMPPMessageContextJIDItemTag NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * XMPPMessageContextMarkerItemTag NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * XMPPMessageContextStringItemTag NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * XMPPMessageContextTimestampItemTag NS_EXTENSIBLE_STRING_ENUM;

@class XMPPMessageContextNode, XMPPMessageBaseNode, XMPPJID;

@interface XMPPMessageContextItem : NSManagedObject

@property (nonatomic, strong, nullable) XMPPMessageContextNode *contextNode;

@end

@interface XMPPMessageContextJIDItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextJIDItemTag tag;
@property (nonatomic, strong, nullable) XMPPJID *value;

@end

@interface XMPPMessageContextMarkerItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextMarkerItemTag tag;

@end

@interface XMPPMessageContextStringItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextStringItemTag tag;
@property (nonatomic, copy, nullable) NSString *value;

@end

@interface XMPPMessageContextTimestampItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextTimestampItemTag tag;
@property (nonatomic, strong, nullable) NSDate *value;

@end

NS_ASSUME_NONNULL_END
