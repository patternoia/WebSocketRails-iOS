//
//  WebSocketRailsChannel.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "WebSocketRailsEvent.h"
#import "WebSocketRailsDispatcher.h"
#import "WebSocketRailsTypes.h"

@class WebSocketRailsDispatcher;

@interface WebSocketRailsChannel : NSObject

@property (nonatomic, assign) BOOL isPrivate;

- (id)initWithName:(NSString *)name dispatcher:(WebSocketRailsDispatcher *)dispatcher private:(BOOL)private;

- (void)bind:(NSString *)eventName callback:(EventCompletionBlock)callback;
- (void)dispatch:(NSString *)eventName message:(id)message;
- (void)destroy;

- (void)trigger:(NSString *)eventName message:(id)message;

@end
