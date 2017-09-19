#import "XMPPMessageCoreDataStorage+XEP_0203.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPMessageContextItem.h"

static XMPPMessageContextTimestampItemTag const XMPPMessageContextDelayedDeliveryTimestampTag = @"XMPPMessageContextDelayedDeliveryTimestamp";
static XMPPMessageContextJIDItemTag const XMPPMessageContextDelayedDeliveryOriginJIDTag = @"XMPPMessageContextDelayedDeliveryOriginJID";
static XMPPMessageContextStringItemTag const XMPPMessageContextDelayedDeliveryReasonDescriptionTag = @"XMPPMessageContextDelayedDeliveryReasonDescription";

@implementation XMPPMessageCoreDataStorage (XEP_0203)

- (void)storeDelayedDeliveryDate:(NSDate *)delayedDeliveryDate delayOriginJID:(XMPPJID *)delayOriginJID delayReasonDescription:(NSString *)delayReasonDescription forIncomingMessage:(XMPPMessage *)message withEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                                                                  streamJID:event.myJID
                                                                                                withMessage:message
                                                                                                  timestamp:event.timestamp
                                                                                     inManagedObjectContext:self.managedObjectContext];
        [messageNode setDelayedDeliveryDate:delayedDeliveryDate
                              withOriginJID:delayOriginJID
                          reasonDescription:delayReasonDescription
                           forStreamEventID:event.uniqueID];
    }];
}

@end

@implementation XMPPMessageBaseNode (XEP_0203)

+ (NSPredicate *)delayedDeliveryContextPredicate
{
    return [XMPPMessageContextTimestampItem tagPredicateWithValue:XMPPMessageContextDelayedDeliveryTimestampTag];
}

- (NSDate *)delayedDeliveryDate
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode timestampItemValueForTag:XMPPMessageContextDelayedDeliveryTimestampTag];
    }];
}

- (XMPPJID *)delayedDeliveryOriginJID
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode jidItemValueForTag:XMPPMessageContextDelayedDeliveryOriginJIDTag];
    }];
}

- (NSString *)delayedDeliveryReasonDescription
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextDelayedDeliveryReasonDescriptionTag];
    }];
}

- (void)setDelayedDeliveryDate:(NSDate *)delayedDeliveryDate withOriginJID:(XMPPJID *)delayedDeliveryOriginJID reasonDescription:(NSString *)delayedDeliveryReasonDescription forStreamEventID:(NSString *)streamEventID
{
    NSAssert(![self delayedDeliveryDate], @"Delayed delivery information is already present");
    
    [self retireStreamTimestamp];
    
    XMPPMessageContextNode *delayedDeliveryContextNode = [self appendContextNodeWithStreamEventID:streamEventID];
    
    [delayedDeliveryContextNode appendTimestampItemWithTag:XMPPMessageContextDelayedDeliveryTimestampTag value:delayedDeliveryDate];
    if (delayedDeliveryOriginJID) {
        [delayedDeliveryContextNode appendJIDItemWithTag:XMPPMessageContextDelayedDeliveryOriginJIDTag value:delayedDeliveryOriginJID];
    }
    if (delayedDeliveryReasonDescription) {
        [delayedDeliveryContextNode appendStringItemWithTag:XMPPMessageContextDelayedDeliveryReasonDescriptionTag value:delayedDeliveryReasonDescription];
    }
}

@end
