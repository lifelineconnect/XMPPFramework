//
//  XMPPRoomLightCoreDataStorage.h
//  Mangosta
//
//  Created by Andres Canal on 6/8/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

#import "XMPP.h"
#import "XMPPCoreDataStorage.h"
#import "XMPPRoomLight.h"

@interface XMPPRoomLightCoreDataStorage : XMPPCoreDataStorage <XMPPRoomLightStorage>

- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoomLight *)room event:(XMPPElementEvent *)event;
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoomLight *)room event:(XMPPElementEvent *)event;

@end
