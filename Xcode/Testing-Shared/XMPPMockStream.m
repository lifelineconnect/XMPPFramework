//
//  XMPPStreamTest.m
//  XMPPFrameworkTests
//
//  Created by Andres Canal on 5/26/16.
//
//

#import "XMPPMockStream.h"

@interface XMPPElementEvent (PrivateAPI)

- (instancetype)initWithStream:(XMPPStream *)xmppStream uniqueID:(NSString *)uniqueID myJID:(XMPPJID *)myJID timestamp:(NSDate *)timestamp;

@end

@implementation XMPPMockStream

- (id) init {
    if (self = [super init]) {
        [super setValue:@(STATE_XMPP_CONNECTED) forKey:@"state"];
        [super setValue:[XMPPJID jidWithString:@"user@domain/resource"] forKey:@"myJID"];
    }
    return self;
}

- (BOOL) isAuthenticated {
    return YES;
}

- (void)fakeResponse:(NSXMLElement*)element {
    [self injectElement:element];
}

- (void)fakeMessageResponse:(XMPPMessage *) message {
    [self injectElement:message];
}

- (void)fakeIQResponse:(XMPPIQ *) iq {
    [self injectElement:iq];
}

- (void)performActionInContextOfFakeEventWithID:(NSString *)fakeEventID timestamp:(NSDate *)fakeEventTimestamp block:(void (^)(XMPPElementEvent *))block
{
    dispatch_async(self.xmppQueue, ^{
        XMPPElementEvent *fakeEvent = [[XMPPElementEvent alloc] initWithStream:self uniqueID:fakeEventID myJID:self.myJID timestamp:fakeEventTimestamp];
        block(fakeEvent);
        [[self valueForKey:@"multicastDelegate"] xmppStream:self didFinishProcessingElementEvent:fakeEvent];
    });
}

- (void)sendElement:(XMPPElement *)element {
    [super sendElement:element];
	if(self.elementReceived) {
		self.elementReceived(element);
	}
}

@end
