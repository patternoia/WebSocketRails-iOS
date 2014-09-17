//
//  WebSocketRailsChannel.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsChannel.h"

@interface WebSocketRailsChannel()

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSMutableDictionary *callbacks;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) WebSocketRailsDispatcher *dispatcher;

@end

@implementation WebSocketRailsChannel

- (id)initWithName:(NSString *)channelName dispatcher:(WebSocketRailsDispatcher *)dispatcher private:(BOOL)private
{
    self = [super init];
    if (self) {
        NSString *eventName = nil;
        if (private)
            eventName = @"websocket_rails.subscribe_private";
        else
            eventName = @"websocket_rails.subscribe";
        
        _channelName = channelName;
        _dispatcher = dispatcher;
        
        WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:
                                      @[eventName,
                                        @{@"data":
                                              @{@"channel" : _channelName}
                                          },
                                        _dispatcher.connectionId ? _dispatcher.connectionId : [NSNull null]]
                                                                     success:nil failure:nil];
        
        // Mutable disctionary of mutable arrays
        _callbacks = [NSMutableDictionary dictionary];
    
        [dispatcher triggerEvent:event];
    }
    return self;
}

- (void)bind:(NSString *)eventName callback:(EventCompletionBlock)callback
{
    if (!_callbacks[eventName])
        _callbacks[eventName] = [NSMutableArray array];
    
    [_callbacks[eventName] addObject:[callback copy]];
}

- (void)trigger:(NSString *)eventName message:(id)message
{
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:
                                  @[eventName,
                                    @{@"channel": _channelName, @"data": message, @"token": _token ? _token : [NSNull null]},
                                    _dispatcher.connectionId]
                                                                 success:nil failure:nil];
    [_dispatcher triggerEvent:event];
}

- (void)dispatch:(NSString *)eventName message:(id)message
{
    if([eventName isEqualToString:@"websocket_rails.channel_token"]) {
        
        NSMutableDictionary* info = (NSMutableDictionary*) message;
        self.token = [info objectForKey:@"token"];
    }
    else {
        if (!_callbacks[eventName])
            return;
        
        for (EventCompletionBlock callback in _callbacks[eventName])
        {
            callback(message);
        }
    }
}

- (void)destroy
{
    NSString *eventName = @"websocket_rails.unsubscribe";
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:
                                  @[eventName,
                                    @{@"data":
                                          @{@"channel" : _channelName}
                                      },
                                    _dispatcher.connectionId]];
    
    [_dispatcher triggerEvent:event];
    [_callbacks removeAllObjects];
}

@end
