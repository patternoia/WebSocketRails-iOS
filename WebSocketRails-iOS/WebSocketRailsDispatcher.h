//
//  WebSocketRailsDispatcher.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "WebSocketRailsEvent.h"
#import "WebSocketRailsChannel.h"
#import "WebSocketRailsTypes.h"

#define kPingPongFailureNotification @"com.patternoia.WebSocketRails.kPingPongFailureNotification"

@class WebSocketRailsChannel;

@interface WebSocketRailsDispatcher : NSObject

@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableDictionary *channels;
@property (nonatomic, strong) id connectionId;

- (id)initWithUrl:(NSURL *)url;

- (void)dispatch:(WebSocketRailsEvent *)event;
- (void)newMessage:(NSArray *)data;
- (void)bind:(NSString *)eventName callback:(EventCompletionBlock)callback;
- (void)trigger:(NSString *)eventName data:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure;
- (void)triggerEvent:(WebSocketRailsEvent *)event;
- (WebSocketRailsChannel *)subscribe:(NSString *)channelName;
- (void)unsubscribe:(NSString *)channelName;

- (void)connect;
- (void)disconnect;

@end
