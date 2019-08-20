//
//  NYLWebSocketManager.m
//  GoodDoctorForDoctor
//
//  Created by nyl on 2019/8/18.
//  Copyright © 2019 JamBo. All rights reserved.
//

#import "NYLWebSocketManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <SocketRocket/SRWebSocket.h>

@interface NYLWebSocketManager()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
/** 是否主动关闭长链接*/
@property (nonatomic, assign) BOOL isActivelyClose;
@property (nonatomic, strong) NSTimer *networkCheckTimer;
@property (nonatomic, assign) NSInteger reConnectCount;
@property (nonatomic, strong) NSTimer *reConnectTimer;

@end

@implementation NYLWebSocketManager

static NYLWebSocketManager *instance = nil;

+ (NYLWebSocketManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NYLWebSocketManager alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return instance;
}

- (void)connectWebSocket
{
    self.isActivelyClose = NO;
    NSString *wsUrlStr = self.socketAddr;
    if (self.socketAddr.length == 0) {
        return;
    }
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:wsUrlStr]];
    self.socket.delegate = self;
    [self.socket open];
}

- (void)connectWebSocketWithSocketAddr:(NSString *)addr
{
    self.socketAddr = addr;
    [self connectWebSocket];
}


- (void)closeWebSocketActively
{
    self.isActivelyClose = YES;
    self.reConnectCount = 0;
    [self destoryNetWorkCheckingTimer];
    [self endReConnectTimer];
    [self closeWebSocket];
}

- (void)closeWebSocket
{
    if (self.socket) {
        [self.socket close];
        self.socket = nil;
    }
}

- (void)reConnectWebSocket
{
    if (self.socket.readyState == SR_OPEN) { return; }
    if (self.reConnectCount <= 5) {
        [self connectWebSocket];
        self.reConnectCount++;
    } else {
        // 重连5次失败则用定时器进行重连
        if (self.reConnectTimer) {
            return;
        }
        self.reConnectTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(actionReConnectTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.reConnectTimer forMode:NSDefaultRunLoopMode];
    }
}


// 网络监测
- (void)startNetWorkStartChekingTimer
{
    [self destoryNetWorkCheckingTimer];
    if (self.networkCheckTimer) {
        return;
    }
    self.networkCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(actionNetWorkChecking) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.networkCheckTimer forMode:NSDefaultRunLoopMode];
}

- (void)destoryNetWorkCheckingTimer
{
    if (self.networkCheckTimer) {
        [self.networkCheckTimer invalidate];
        self.networkCheckTimer = nil;
    }
}

- (void)actionNetWorkChecking
{
    //有网络
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        //关闭网络检测定时器
        [self destoryNetWorkCheckingTimer];
        //开始重连
        [self reConnectWebSocket];
    } else {
       // NSLog(@"⚠️⚠️没有网络");
    }
}

- (void)endReConnectTimer
{
    if (self.reConnectTimer) {
        [self.reConnectTimer invalidate];
        self.reConnectTimer = nil;
    }
}

- (void)actionReConnectTimer
{
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        [self connectWebSocket];
    }
}


// 发送一条消息
- (void)sendMsg:(NSString *)msg imgUrlStr:(NSString *)imgUrlStr detailID:(NSNumber *)detailID
{
    NSDictionary *requestDic = @{@"text": msg, @"detailID": [NSString stringWithFormat:@"%@", detailID]};
    [self sendData:requestDic];
}


- (void)sendData:(id)data
{
    if (!data) { return; }
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"您的网络已断开!"];
        [self startNetWorkStartChekingTimer];
        return;
    }
    if (!self.socket || self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CLOSING) {
        [self reConnectWebSocket];
        return;
    }
    
    if (self.socket.readyState == SR_OPEN) {
        [SVProgressHUD show];
        [self.socket send:data];
    }
}

#pragma mark - SRWebSocketDelegate
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [self endReConnectTimer];
    [self destoryNetWorkCheckingTimer];
    [SVProgressHUD showSuccessWithStatus:@"连接成功"];

    if (self.wsConnectSuccessedBlock) {
        self.wsConnectSuccessedBlock();
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"%@", message);
    if (self.wsReceivedMsgBlock) {
        self.wsReceivedMsgBlock(message);
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    if (self.wsDidFailWithError) {
        self.wsDidFailWithError(error);
    }
    
    if (self.isActivelyClose) {
        return;
    }
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self startNetWorkStartChekingTimer];//开启网络检测
    } else {
        [self reConnectWebSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [SVProgressHUD dismiss];
    if (self.wsDidCloseWithCodeAndReason) {
        self.wsDidCloseWithCodeAndReason(code, reason);
    }
    if (self.isActivelyClose) {
        return;
    }
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self startNetWorkStartChekingTimer];//开启网络检测
    } else {
        [self reConnectWebSocket];
    }
}


@end
