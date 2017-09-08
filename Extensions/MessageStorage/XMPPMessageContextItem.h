#import <CoreData/CoreData.h>
#import "XMPPJID.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int16_t, XMPPMessageDirection);

typedef NSString * XMPPMessageContextJIDItemTag NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * XMPPMessageContextMarkerItemTag NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * XMPPMessageContextStringItemTag NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * XMPPMessageContextTimestampItemTag NS_EXTENSIBLE_STRING_ENUM;

@class XMPPMessageContextNode, XMPPMessageBaseNode, XMPPJID;

@interface XMPPMessageContextItem : NSManagedObject

@property (nonatomic, strong, nullable) XMPPMessageContextNode *contextNode;

+ (NSPredicate *)streamEventIDPredicateWithValue:(NSString *)value;
+ (NSPredicate *)messageJIDPredicateWithDomainKeyPath:(NSString *)domainKeyPath
                                      resourceKeyPath:(NSString *)resourceKeyPath
                                          userKeyPath:(NSString *)userKeyPath
                                                value:(XMPPJID *)value
                                       compareOptions:(XMPPJIDCompareOptions)compareOptions;
+ (NSPredicate *)messageDirectionPredicateWithValue:(XMPPMessageDirection)value;

@end

@interface XMPPMessageContextJIDItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextJIDItemTag tag;
@property (nonatomic, strong, nullable) XMPPJID *value;

+ (NSPredicate *)tagPredicateWithValue:(XMPPMessageContextJIDItemTag)value;
+ (NSPredicate *)jidPredicateWithValue:(XMPPJID *)value compareOptions:(XMPPJIDCompareOptions)compareOptions;

@end

@interface XMPPMessageContextMarkerItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextMarkerItemTag tag;

+ (NSPredicate *)tagPredicateWithValue:(XMPPMessageContextMarkerItemTag)value;

@end

@interface XMPPMessageContextStringItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextStringItemTag tag;
@property (nonatomic, copy, nullable) NSString *value;

+ (NSPredicate *)tagPredicateWithValue:(XMPPMessageContextStringItemTag)tag;

@end

@interface XMPPMessageContextTimestampItem : XMPPMessageContextItem

@property (nonatomic, copy, nullable) XMPPMessageContextTimestampItemTag tag;
@property (nonatomic, strong, nullable) NSDate *value;

+ (NSPredicate *)tagPredicateWithValue:(XMPPMessageContextTimestampItemTag)value;
+ (NSPredicate *)timestampRangePredicateWithStartValue:(nullable NSDate *)startValue endValue:(nullable NSDate *)endValue;

@end

NS_ASSUME_NONNULL_END
