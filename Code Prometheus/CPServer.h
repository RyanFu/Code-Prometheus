//
//  CPServer.h
//  Code Prometheus
//
//  Created by mirror on 13-11-7.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

static const double CP_SendSMSTimeInterval = 120;
// 通知
static NSString* const CPSyncDoneNotification = @"CPSyncDoneNotification";
static NSString* const CPLogoutNotification = @"CPLogoutNotification";

@interface CPServer : NSObject

// 进行同步
+(void) sync;


// 登录
+(void) loginWithUserName:(NSString*)userName password:(NSString*)password block:(void (^)(BOOL success,NSString* message))block;
// 注销 & 删除用户数据
+(void) logoutAndCleanData;
// 自动登录
+(void) loginAutoWithBlock:(void (^)(BOOL success,NSString* message))block;
// 注册
+(void) registerWithUserName:(NSString*)userName password:(NSString*)password referralInfoID:(NSString*)referralInfoID block:(void (^)(BOOL success,NSString* message))block;



// 上传 推送 token
+(void) pushToken:(NSString*)token withBlock:(void (^)(BOOL success))block;



// 获取安全手机和安全邮箱
+(void) requestSafetyPhoneNumberAndEmailWithBlock:(void (^)(BOOL success,NSString*phoneNumber,NSString*email,NSString* message))block;
    
// 发送验证码
+(void) sendSMSWithPhoneNumber:(NSString*)phoneNumber block:(void (^)(BOOL success,NSString* message))block;
// 校验验证码
+(void) validateSMSWithPhoneNumber:(NSString*)phoneNumber code:(NSString*)code block:(void (^)(BOOL success,NSString* message))block;
    
// 绑定邮箱
+(void) bindEmail:(NSString*)emailAddr block:(void (^)(BOOL success,NSString* message))block;
// 绑定手机
+(void) bindPhone:(NSString*)code block:(void (^)(BOOL success,NSString* message))block;

// 通过手机短信找回密码
+(void) resetPasswordBySMSCode:(NSString*)code newPassword:(NSString*)newPassword block:(void (^)(BOOL success,NSString* newPassword,NSString* message))block;
// 通过邮箱找回密码
+(void) resetPasswordByEmail:(NSString*)emailAddr block:(void (^)(BOOL success,NSString* message))block;

// 根据旧密码重设密码
+(void) resetPasswordWithOriginalPassword:(NSString*)originalPassword newPassword:(NSString*)newPassword block:(void (^)(BOOL success,NSString* newPassword, NSString* message))block;

// 获取系统消息
+(void) pushSearchWithBlock:(void (^)(BOOL success,NSMutableArray* results,NSString* message))block;

// 获取会员信息
+(void) requestMemberInfo:(void (^)(BOOL success,NSString* message,NSString* name,NSString* productId,NSNumber* price,NSString* room,NSNumber* memberTime,NSNumber* usage,NSString* usePercent,NSNumber* leftRoom,NSNumber* balance))block;

// 获取消费记录信息
+(void) requestOrderInfo:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block;

// 获取充值记录信息
+(void) requestRechargeInfo:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block;

// 获取产品列表
+(void) requestProduct:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block;

// 更改套餐
+(void) changeProduct:(NSString*)productId block:(void (^)(BOOL success,NSString* message))block;
// 获取充值方案
+(void) requestRechargeItem:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block;
// 充值
+(void) requestRechargeCreateWithItemID:(NSString*)itemId block:(void (^)(BOOL success,NSString* message,NSNumber* rechargeId,NSString* signInfo,NSString* sign))block;



// 通知替换对象
+(void) notifyReplaceEntity:(NSObject *)entity;
// 通知删除对象
+(void) notifyDeleteEntity:(NSObject *)entity;

// 获取服务器时间
+(double) getServerTimeByDelta_t;
@end
