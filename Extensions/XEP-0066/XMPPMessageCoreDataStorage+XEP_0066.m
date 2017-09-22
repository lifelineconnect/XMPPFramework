#import "XMPPMessageCoreDataStorage+XEP_0066.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorage+Protected.h"
#import "XMPPMessageBaseNode+ContextHelpers.h"
#import "XMPPStream.h"

static XMPPMessageContextStringItemTag const XMPPMessageContextOutOfBandResourceIDTag = @"XMPPMessageContextOutOfBandResourceID";
static XMPPMessageContextStringItemTag const XMPPMessageContextOutOfBandResourceURIStringTag = @"XMPPMessageContextOutOfBandResourceURIString";
static XMPPMessageContextStringItemTag const XMPPMessageContextOutOfBandResourceDescriptionTag = @"XMPPMessageContextOutOfBandResourceDescription";

@implementation XMPPMessageCoreDataStorage (XEP_0066)

- (void)storeOutOfBandResourceURIString:(NSString *)resourceURIString description:(NSString *)resourceDescription forIncomingMessage:(XMPPMessage *)message withEvent:(XMPPElementEvent *)event
{
    [self scheduleStorageActionForEventWithID:event.uniqueID inStream:event.xmppStream withBlock:^{
        XMPPMessageBaseNode *messageNode = [XMPPMessageBaseNode findOrCreateForIncomingMessageStreamEventID:event.uniqueID
                                                                                                  streamJID:event.myJID
                                                                                                withMessage:message
                                                                                                  timestamp:event.timestamp
                                                                                     inManagedObjectContext:self.managedObjectContext];
        [messageNode assignOutOfBandResourceWithDescription:resourceDescription forStreamEventID:event.uniqueID];
        [messageNode setAssignedOutOfBandResourceURIString:resourceURIString];
    }];
}

@end

@implementation XMPPMessageBaseNode (XEP_0066)

- (nullable NSString *)outOfBandResourceInternalID
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextOutOfBandResourceIDTag];
    }];
}

- (nullable NSString *)outOfBandResourceURIString
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextOutOfBandResourceURIStringTag];
    }];
}

- (nullable NSString *)outOfBandResourceDescription
{
    return [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextOutOfBandResourceDescriptionTag];
    }];
}

- (void)assignOutOfBandResourceWithDescription:(nullable NSString *)resourceDescription forStreamEventID:(NSString *)streamEventID
{
    NSAssert(![self outOfBandResourceInternalID], @"Out of band resource is already assigned");
    
    XMPPMessageContextNode *outOfBandResourceContextNode = [self appendContextNodeWithStreamEventID:streamEventID];
    [outOfBandResourceContextNode appendStringItemWithTag:XMPPMessageContextOutOfBandResourceIDTag value:[NSUUID UUID].UUIDString];
    if (resourceDescription) {
        [outOfBandResourceContextNode appendStringItemWithTag:XMPPMessageContextOutOfBandResourceDescriptionTag value:resourceDescription];
    }
}

- (void)setAssignedOutOfBandResourceURIString:(NSString *)resourceURIString
{
    XMPPMessageContextNode *outOfBandResourceContextNode = [self lookupInContextWithBlock:^id _Nullable(XMPPMessageContextNode * _Nonnull contextNode) {
        return [contextNode stringItemValueForTag:XMPPMessageContextOutOfBandResourceIDTag] ? contextNode : nil;
    }];
    NSAssert(outOfBandResourceContextNode, @"No out of band resource is assigned yet");
    NSAssert(![outOfBandResourceContextNode stringItemValueForTag:XMPPMessageContextOutOfBandResourceURIStringTag], @"Out of band resource URI is already set");
    
    [outOfBandResourceContextNode appendStringItemWithTag:XMPPMessageContextOutOfBandResourceURIStringTag value:resourceURIString];
}

@end
