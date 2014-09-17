//
//  WebSocketRailsEvent.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSocketRailsTypes.h"

@interface WebSocketRailsEvent : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) id attr;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) id data;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong, readonly) NSNumber *connectionId;
@property (nonatomic, assign, readonly) BOOL success;
@property (nonatomic, assign, readonly) BOOL result;

- (id)initWithData:(id)data;
- (id)initWithData:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure;

- (BOOL)isChannel;
- (BOOL)isResult;
- (BOOL)isPing;
- (NSString *)serialize;
- (id)attributes;

- (void)runCallbacks:(BOOL)success eventData:(id)eventData;

@end
