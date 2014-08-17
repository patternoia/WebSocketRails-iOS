//
//  WebSocketRailsEvent.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsEvent.h"

@interface WebSocketRailsEvent()

@property (nonatomic, copy) EventCompletionBlock successCallback;
@property (nonatomic, copy) EventCompletionBlock failureCallback;

@end

@implementation WebSocketRailsEvent

- (id)initWithData:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure
{
    self = [super init];
    if (self) {
        _name = data[0];
        _attr = data[1];
        
        if (_attr)
        {
            if (_attr[@"id"] && _attr[@"id"] != [NSNull null])
                _id = _attr[@"id"];
            else
                _id = [NSNumber numberWithInt:rand()];
            
            if (_attr[@"channel"] && _attr[@"channel"] != [NSNull null])
                _channel = _attr[@"channel"];
            
            if (_attr[@"data"] && _attr[@"data"] != [NSNull null])
                _data = _attr[@"data"];
            
            if (_attr[@"token"] && _attr[@"token"] != [NSNull null])
                _token = _attr[@"token"];
            
            if ([data count] > 2 && data[2] && data[2] != [NSNull null])
                _connectionId = data[2];
            else
                _connectionId = @0;
            
            if (_attr[@"success"] && _attr[@"success"] != [NSNull null])
            {
                _result = YES;
                _success = (BOOL) _attr[@"success"];
            }
        }
        
        self.successCallback = success;
        self.failureCallback = failure;
    }
    return self;
}

- (id)initWithData:(id)data{
    return [self initWithData:data success:nil failure:nil];
}

- (BOOL)isChannel
{
    return [_channel length];
}

- (BOOL)isResult
{
    return _result;
}

- (BOOL)isPing
{
    return [_name isEqualToString:@"websocket_rails.ping"];
}

- (NSString *)serialize
{
    NSArray *array =
            @[_name,
             [self attributes]
              ];
    
    return [NSString.alloc initWithData:[NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (id)attributes
{
    return @{@"id": _id ? _id : [NSNull null],
             @"channel": _channel ? _channel : [NSNull null],
             @"data": _data ? _data : [NSNull null],
             @"token": _token ? _token : [NSNull null]
             };
}

- (void)runCallbacks:(BOOL)success eventData:(id)eventData
{
    if (success && _successCallback)
        _successCallback(eventData);
    else {
    
    if (_failureCallback)
        _failureCallback(eventData);
    }
}

@end
