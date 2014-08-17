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
@property CGFloat yPosition;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.yPosition = 0.0;
    
    UIButton * (^createButton)(NSString *title, SEL selector) = ^UIButton *(NSString *title, SEL selector) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:(CGRect){.origin = (CGPoint){.x = 80.0, .y = self.yPosition += 50.0}, .size = (CGSize){.width = 160.0, .height = 36.0}}];
        [button.layer setCornerRadius:4.0];
        [button.layer setBorderColor:[UIColor blueColor].CGColor];
        [button.layer setBorderWidth:1.0];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        return button;
    };
    
    UIButton *connectButton = createButton(@"Connect", @selector(connect:));
    [self.view addSubview:connectButton];
    
    UIButton *disconnectButton = createButton(@"Disconnect", @selector(disconnect:));
    [self.view addSubview:disconnectButton];
    
    UIButton *globalEventButton = createButton(@"Global event", @selector(globalEvent:));
    [self.view addSubview:globalEventButton];
    
    UIButton *nameSpaceEventButton = createButton(@"Name space event", @selector(nameSpaceEvent:));
    [self.view addSubview:nameSpaceEventButton];
    
    UIButton *channelEventButton = createButton(@"Channel event", @selector(channelEvent:));
    [self.view addSubview:channelEventButton];
    
    UIButton *successfulEventButton = createButton(@"Successful event", @selector(successfulEvent:));
    [self.view addSubview:successfulEventButton];
    
    UIButton *failureEventButton = createButton(@"Failure event", @selector(failureEvent:));
    [self.view addSubview:failureEventButton];
    
}

- (id)eventDataWithString:(NSString *)string
{
    return @{@"name": @"sample_name", @"data": string};
}

- (IBAction)connect:(id)sender {
    _dispatcher = [WebSocketRailsDispatcher.alloc initWithUrl:[NSURL URLWithString:@"ws://127.0.0.1:3000/websocket"]];
    [_dispatcher bind:@"connection_opened" callback:^(id data) {
        NSLog(@"Yay! Connected!");
    }];
    [_dispatcher connect];
}
- (IBAction)disconnect:(id)sender {
    [_dispatcher bind:@"connection_closed" callback:^(id data) {
        NSLog(@"Disconnected!");
    }];
    [_dispatcher disconnect];
}

- (IBAction)globalEvent:(id)sender {
    [_dispatcher bind:@"global_event" callback:^(id data) {
        NSLog(@"Global event: %@", data);
    }];
    [_dispatcher trigger:@"global_event" data:[self eventDataWithString:@"global_event_test"] success:nil failure:nil];
}
- (IBAction)nameSpaceEvent:(id)sender {
    [_dispatcher bind:@"namespace.namespace_event" callback:^(id data) {
        NSLog(@"Namespace event: %@", data);
    }];
    [_dispatcher trigger:@"namespace.namespace_event" data:[self eventDataWithString:@"namespace.namespace_event_test"] success:nil failure:nil];
}
- (IBAction)channelEvent:(id)sender {
    WebSocketRailsChannel *testChannel = [_dispatcher subscribe:@"channel_event"];
    [testChannel bind:@"channel_event" callback:^(id data) {
        NSLog(@"Channel event: %@", data);
    }];
    
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [testChannel trigger:@"channel_event" message:@"channel_event_test"];
    });
}
- (IBAction)successfulEvent:(id)sender {
    [_dispatcher trigger:@"success_event" data:[self eventDataWithString:@"success_event_test"] success:^(id data) {
        NSLog(@"Success event: %@", data);
    } failure:nil];
}
- (IBAction)failureEvent:(id)sender {
    [_dispatcher trigger:@"failure_event" data:[self eventDataWithString:@"failure_event_test"] success:nil failure:^(id data) {
        NSLog(@"Failure event: %@", data);
    }];
}

@end
