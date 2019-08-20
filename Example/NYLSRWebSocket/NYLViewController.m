//
//  NYLViewController.m
//  NYLSRWebSocket
//
//  Created by nieyinlong on 08/20/2019.
//  Copyright (c) 2019 nieyinlong. All rights reserved.
//

#import "NYLViewController.h"
#import <NYLSRWebSocket/NYLWebSocketManager.h>

@interface NYLViewController ()

@end

@implementation NYLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // 连接
    [[NYLWebSocketManager shareManager] connectWebSocketWithSocketAddr:@"ws://10.10.22"];
    
    // 连接成功
    [NYLWebSocketManager shareManager].wsConnectSuccessedBlock = ^{
        
    };
    
    
    // 收到消息的回调
    [NYLWebSocketManager shareManager].wsReceivedMsgBlock = ^(id  _Nonnull data) {
        
    };
    
    // 关闭回调
    [NYLWebSocketManager shareManager].wsDidCloseWithCodeAndReason = ^(NSInteger errCode, NSString * _Nonnull resson) {
        
    };
    
    // 连接失败回调
    [NYLWebSocketManager shareManager].wsDidFailWithError = ^(NSError * _Nonnull err) {
        
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
