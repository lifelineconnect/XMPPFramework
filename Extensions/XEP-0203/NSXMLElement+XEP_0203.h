#import <Foundation/Foundation.h>
@import KissXML;

@class XMPPJID;

@interface NSXMLElement (XEP_0203)

- (BOOL)wasDelayed;
- (NSDate *)delayedDeliveryDate;
- (XMPPJID *)delayOriginJID;
- (NSString *)delayReasonDescription;

@end
