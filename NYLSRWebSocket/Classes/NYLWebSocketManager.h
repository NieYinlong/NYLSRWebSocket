//
//  NYLWebSocketManager.h
//  GoodDoctorForDoctor
//
//  Created by nyl on 2019/8/18.
//  Copyright © 2019 JamBo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SRWebSocket;

NS_ASSUME_NONNULL_BEGIN

@interface NYLWebSocketManager : NSObject

@property (nonatomic, copy) void(^wsConnectSuccessedBlock)(void);
@property (nonatomic, copy) void(^wsDidFailWithError)(NSError *err);
@property (nonatomic, copy) void(^wsDidCloseWithCodeAndReason)(NSInteger errCode, NSString *resson);
@property (nonatomic, strong) void (^wsReceivedMsgBlock)(id data);

@property (nonatomic, strong, readonly) SRWebSocket *socket;
@property (nonatomic, copy) NSString *socketAddr;

/**
 单例
 */
+ (NYLWebSocketManager *)shareManager;
- (void)connectWebSocketWithSocketAddr:(NSString *)addr;
- (void)closeWebSocketActively;
- (void)sendMsg:(NSString *)msg imgUrlStr:(NSString *)imgUrlStr detailID:(NSNumber *)detailID;

@end

NS_ASSUME_NONNULL_END
