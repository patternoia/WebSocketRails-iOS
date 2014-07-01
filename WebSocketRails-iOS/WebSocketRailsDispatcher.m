//
//  WebSocketRailsDispatcher.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsDispatcher.h"
#import "WebSocketRailsConnection.h"

@interface WebSocketRailsDispatcher()

@property (nonatomic, strong) NSMutableDictionary *queue;
@property (nonatomic, strong) NSMutableDictionary *callbacks;
@property (nonatomic, strong) WebSocketRailsConnection *connection;
@property (nonatomic, strong) NSTimer *pingPongTimer;

@end

@implementation WebSocketRailsDispatcher

- (id)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        _state = @"connecting";
        _channels = [NSMutableDictionary dictionary];
        _queue = [NSMutableDictionary dictionary];
        _callbacks = [NSMutableDictionary dictionary];
        
        _connection = [WebSocketRailsConnection.alloc initWithUrl:url dispatcher:self];
        _connectionId = @0;
    }
    return self;
}

- (void)newMessage:(NSArray *)data
{
    for (id socket_message in data)
    {
        WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:socket_message];
        
        if ([event isResult])
        {
            if (_queue[event.id])
            {
                [_queue[event.id] runCallbacks:event.success eventData:event.data];
                [_queue removeObjectForKey:event.id];
            }
        } else if ([event isChannel]) {
            [self dispatchChannel:event];
        } else if ([event isPing]) {
            [self pong];
        } else {
            [self dispatch:event];
        }
        
        if ([_state isEqualToString:@"connecting"] && [event.name isEqualToString:@"client_connected"])
            [self connectionEstablished:event.data];
    }
}

- (void)connectionEstablished:(id)data
{
    _state = @"connected";
    _connectionId = data[@"connection_id"] ? data[@"connection_id"] : [NSNull null];
    [_connection flushQueue:data[@"connection_id"]];
    WebSocketRailsEvent *connectionEstablishedEvent = [WebSocketRailsEvent.alloc initWithData:@[@"connection_opened", @{}, _connectionId]];
    [self dispatch:connectionEstablishedEvent];
    _pingPongTimer = [NSTimer timerWithTimeInterval:12 target:self selector:@selector(handlePingPongFailure) userInfo:nil repeats:NO];
}

- (void)bind:(NSString *)eventName callback:(EventCompletionBlock)callback
{
    if (!_callbacks[eventName])
        _callbacks[eventName] = [NSMutableArray array];
    
    [_callbacks[eventName] addObject:[callback copy]];
}

- (void)trigger:(NSString *)eventName data:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure
{
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:@[eventName, data, _connectionId] success:success failure:failure];
    _queue[event.id] = event;
    [_connection trigger:event];
}
 
 - (void)triggerEvent:(WebSocketRailsEvent *)event
 {
     if (_queue[event.id] && _queue[event.id] == event)
         return;
     
     _queue[event.id] = event;
     [_connection trigger:event];
 }

- (void)dispatch:(WebSocketRailsEvent *)event
{
    if (!_callbacks[event.name])
        return;
    
    for (EventCompletionBlock callback in _callbacks[event.name])
    {
        callback(event.data);
    }
}

- (WebSocketRailsChannel *)subscribe:(NSString *)channelName
{
    if (_channels[channelName])
        return _channels[channelName];
    
    WebSocketRailsChannel *channel = [WebSocketRailsChannel.alloc initWithName:channelName dispatcher:self private:NO];
    _channels[channelName] = channel;
    return channel;
}

- (void)unsubscribe:(NSString *)channelName
{
    if (!_channels[channelName])
        return;
    
    [_channels[channelName] destroy];
    [_channels removeObjectForKey:channelName];
}

- (void)dispatchChannel:(WebSocketRailsEvent *)event
{
    if (!_channels[event.channel])
        return;
    
    [_channels[event.channel] dispatch:event.name message:event.data];
}

- (void)pong
{
    [_pingPongTimer invalidate];
    _pingPongTimer = [NSTimer timerWithTimeInterval:12 target:self selector:@selector(handlePingPongFailure) userInfo:nil repeats:NO];
    
    WebSocketRailsEvent *pong = [WebSocketRailsEvent.alloc initWithData:@[@"websocket_rails.pong", @{}, _connectionId ? _connectionId : [NSNull null]]];
    [_connection trigger:pong];
}

- (void)handlePingPongFailure
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPingPongFailureNotification object:self userInfo:nil];
}

- (void)connect
{
    [_connection connect];
}

- (void)disconnect
{
    [_connection disconnect];
}

@end
