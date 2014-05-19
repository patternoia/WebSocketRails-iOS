//
//  WebSocketRailsConnection.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSocketRailsDispatcher.h"
#import "WebSocketRailsEvent.h"

@interface WebSocketRailsConnection : NSObject

- (id)initWithUrl:(NSURL *)url dispatcher:(WebSocketRailsDispatcher *)dispatcher;

- (void)trigger:(WebSocketRailsEvent *)event;
- (void)flushQueue:(NSNumber *)id;

- (void)connect;
- (void)disconnect;

@end
