//
//  ViewController.m
//  WebSocketRailsTest
//
//  Created by Evgeny Lavrik on 18.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//


#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "WebSocketRailsDispatcher.h"
#import "WebSocketRailsChannel.h"

@interface ViewController ()

@property (nonatomic, strong) WebSocketRailsDispatcher *dispatcher;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dispatcher = [WebSocketRailsDispatcher.alloc initWithUrl:[NSURL URLWithString:@"ws://localhost:3001/websocket"]];
    
    // 1) global_event
    [_dispatcher bind:@"global_event" callback:^(id data) {
        NSLog(@"1) Global event: %@", data);
    }];
    [_dispatcher trigger:@"global_event" data:[self eventDataWithString:@"global_event_test"] success:nil failure:nil];
    
    // 2) namespace_event
    [_dispatcher bind:@"namespace.namespace_event" callback:^(id data) {
        NSLog(@"2) Namespace event: %@", data);
    }];
    [_dispatcher trigger:@"namespace.namespace_event" data:[self eventDataWithString:@"namespace.namespace_event_test"] success:nil failure:nil];
    
    // 3) channel_event
    WebSocketRailsChannel *testChannel = [_dispatcher subscribe:@"channel_event"];
    [testChannel bind:@"channel_event" callback:^(id data) {
        NSLog(@"3) Channel event: %@", data);
    }];
    
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [testChannel trigger:@"channel_event" message:@"channel_event_test"];
    });
    
    
    // 4) successful_event
    [_dispatcher trigger:@"success_event" data:[self eventDataWithString:@"success_event_test"] success:^(id data) {
        NSLog(@"4) Success event: %@", data);
    } failure:nil];
    
    // 5) failure_event
    [_dispatcher trigger:@"failure_event" data:[self eventDataWithString:@"failure_event_test"] success:nil failure:^(id data) {
        NSLog(@"5) Failure event: %@", data);
    }];
}

- (id)eventDataWithString:(NSString *)string
{
    return @{@"name": @"sample_name", @"data": string};
}

@end
