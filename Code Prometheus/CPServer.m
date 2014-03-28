//
//  CPServer.m
//  Code Prometheus
//
//  Created by mirror on 13-11-7.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPServer.h"
#import "ASIHTTPRequest.h"
#import <OpenUDID.h>
#import "JSONKit.h"
#import "WYSyncSimple.h"
#import "CPDB.h"
#import "CP_DB_Info.h"
#import "WYSynchronization.h"
#import "CPImage.h"
#import <SDImageCache.h>
#import <SDWebImageDownloader.h>
#import "Reachability.h"

// 服务器地址
static NSString*const URL_SERVER_ROOT = @"http://red.mirror-networks.com";
static NSString*const URL_Register = @"/user/create";
static NSString*const URL_Login = @"/user/login";
static NSString*const URL_Upload = @"/sync/upload";
static NSString*const URL_Download = @"/sync/download";
static NSString*const URL_File_Upload = @"/sync/file/upload";
static NSString*const URL_ACK = @"/sync/ack";
static NSString*const URL_PUSH_TOKEN = @"/user/set/token";
static NSString*const URL_REQUEST_SAFETY_PHONE_NUMBER_AND_EMAIL = @"/user/check/email/and/phone";
static NSString*const URL_SEND_SMS = @"/user/send/sms";
static NSString*const URL_VALIDATE_SMS = @"/user/validate/sms/code";
static NSString*const URL_BIND_EMAIL = @"/user/bind/email";
static NSString*const URL_BIND_PHONE = @"/user/bind/phone";
static NSString*const URL_RESET_PASSWORD_BY_SMS_CODE = @"/user/reset/password/by/sms/code";
static NSString*const URL_RESET_PASSWORD_BY_EMAIL = @"/user/reset/password/by/email";
static NSString*const URL_RESET_PASSWORD_BY_ORIGINAL_PASSWORD = @"/user/change/password";
static NSString*const URL_GET_PUSH_SEARCH = @"/push/search";
static NSString*const URL_REQUEST_MEMBER_INFO = @"/member/info";
static NSString*const URL_REQUEST_ORDER_INFO = @"/order/info";
static NSString*const URL_REQUEST_RECHARGE_INFO = @"/recharge/info";
static NSString*const URL_REQUEST_PRODUCT = @"/product/search";
static NSString*const URL_UPDATE_PRODUCT = @"/order/create";
static NSString*const URL_UPDATE_PRODUCT_CONFIRM = @"/order/update";
static NSString*const URL_REQUEST_RECHARGE_ITEM = @"/recharge/item";
static NSString*const URL_REQUEST_RECHARGE_CREATE = @"/recharge/create";
// JSON KEY
static NSString* const JK_errno = @"errno";
static NSString* const Jk_errmsg = @"errmsg";
static NSString* const Jk_url = @"url";
static NSString* const Jk_md5 = @"md5";
static NSString* const Jk_serverTime = @"serverTime";
static NSString* const Jk_filename = @"filename";
static NSString* const Jk_deviceId = @"deviceId";
static NSString* const Jk_tableName = @"tableName";
static NSString* const Jk_resourceType = @"resourceType";
static NSString* const Jk_uuid = @"uuid";
static NSString* const Jk_action = @"action";
static NSString* const Jk_updatedAt = @"updatedAt";
static NSString* const Jk_content = @"content";
static NSString* const Jk_resourceType_DATA = @"DATA";
static NSString* const Jk_resourceType_FILE = @"FILE";
static NSString* const Jk_action_REPLACE = @"REPLACE";
static NSString* const Jk_action_DELETE = @"DELETE";
static NSString* const Jk_revisionHead = @"revisionHead";
static NSString* const Jk_download = @"download";
static NSString* const Jk_currentHead = @"currentHead";
static NSString* const Jk_fullcopy = @"fullcopy";
static NSString* const Jk_transactionId = @"transactionId";
static NSString* const Jk_data = @"data";
static NSString* const Jk_phoneNumber = @"phoneNumber";
static NSString* const Jk_emailAddr = @"emailAddr";
static NSString* const Jk_results = @"results";
// 充值
static NSString* const Jk_rechargeId = @"rechargeId";
static NSString* const Jk_signInfo = @"signInfo";
static NSString* const Jk_sign = @"sign";
static NSString* const Jk_orderId = @"orderId";

// 会员信息相关
static NSString* const Jk_member_name = @"name";
static NSString* const Jk_member_productId = @"productId";
static NSString* const Jk_member_price = @"price";
static NSString* const Jk_member_room = @"room";
static NSString* const Jk_member_memberTime = @"memberTime";
static NSString* const Jk_member_usage = @"usage";
static NSString* const Jk_member_usePercent = @"usePercent";
static NSString* const Jk_member_leftRoom = @"leftRoom";
static NSString* const Jk_member_balance = @"balance";



#define RegisterUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_Register]
#define LoginUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_Login]
#define S2CUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_Download]
#define C2SUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_Upload]
#define C2SFileUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_File_Upload]
#define S2CAckUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_ACK]
#define PushTokenUrl [NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_PUSH_TOKEN]

#warning 同步策略,应该先进行数据同步,让用户看到数据,后台再默默执行文件同步！

#warning 同步加入事务,文件上传不成功不upload,不同理,先download,然后再请求文件

#warning 同步数据应该限制每次最多N条,防止其他BUG,100-200条/次, simpleSync 应添加响应回调

static const NSInteger Tag_NeedLogin = 20401;
static const NSInteger Tag_ErrorUsernameOrPassword = 20404;

@interface CPServer ()

@end

@implementation CPServer
#pragma mark - 服务器交互 & 开放API
// 自动登录
+(void) loginAutoWithBlock:(void (^)(BOOL success,NSString* message))block{
    NSString* userName = CPUserName;
    NSString* password = CPPassword;
    if (userName) {
        CPLogInfo(@"有用户信息,自动登录");
        [CPServer loginWithUserName:userName password:password block:^(BOOL success,NSString* message) {
            block(success,message);
        }];
    }else{
        CPLogInfo(@"无用户信息,无法自动登录");
        block(NO,@"无用户信息,无法自动登录");
    }
}

+(void) loginWithUserName:(NSString*)userName password:(NSString*)password block:(void (^)(BOOL success,NSString* message))block{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:LoginUrl]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:userName?userName:@"" forKey:@"username"];
    [json setObject:password?password:@"" forKey:@"password"];
    [json setObject:[OpenUDID value] forKey:@"deviceId"];
    [json setObject:@"IPHONE" forKey:@"deviceType"];
    [json setObject:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"登录JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:nil]) {
            CPLogVerbose(@"登录成功:%@",weakRequest.responseString);
            CPLogInfo(@"添加用户信息,userName:%@,password:%@",userName,password);
            CPSetUserName(userName);
            CPSetPassword(password);
            block(YES,nil);
        }else{
            block(NO,[json objectForKey:Jk_errmsg]);
        }
    }];
    [request startAsynchronous];
}

// 注册
+(void) registerWithUserName:(NSString*)userName password:(NSString*)password referralInfoID:(NSString*)referralInfoID block:(void (^)(BOOL success,NSString* message))block{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:RegisterUrl]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:userName?userName:@"" forKey:@"username"];
    [json setObject:password?password:@"" forKey:@"password"];
    [json setObject:referralInfoID?referralInfoID:@"" forKey:@"referee"];
    [json setObject:[OpenUDID value] forKey:@"deviceId"];
    [json setObject:@"IPHONE" forKey:@"deviceType"];
    [json setObject:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"注册JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:nil]) {
            CPLogVerbose(@"注册成功:%@",weakRequest.responseString);
            block(YES,nil);
        }else{
            block(NO,[json objectForKey:Jk_errmsg]);
        }
    }];
    [request startAsynchronous];
}

// 注销
+(void) logoutNotCleanData{
    // 停止同步
    [wySyncSimple notifyCancelSync];
    // 清除session
    [ASIHTTPRequest clearSession];
    // 删除用户信息
    CPLogWarn(@"清除用户信息");
    [CPUserDefaults resetDefaults];
    [CPDB creatDBIfNotExist];
    // 通知
    CPLogInfo(@"注销成功,发出通知:CPLogoutNotification");
    [[NSNotificationCenter defaultCenter] postNotificationName:CPLogoutNotification object:nil];
}
// 注销 & 删除用户数据
+(void) logoutAndCleanData{
    NSString* userName = CPUserName;
    if (userName) {
        CPLogWarn(@"删除用户%@的数据库",userName);
        [CPDB deleteDBFile];
    }
    [self logoutNotCleanData];
}

// 上传 推送 token
+(void) pushToken:(NSString*)token withBlock:(void (^)(BOOL success))block{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:PushTokenUrl]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:token forKey:@"token"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"上传推送token,JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSASCIIStringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogError(@"请求失败:%@",weakRequest.responseString);
        block(NO);
    }];
    [request setCompletionBlock:^{
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        CPLogVerbose(@"上传推送token,成功:%@",weakRequest.responseString);
        block(YES);
    }];
    [request startAsynchronous];
}

// 发送验证码
+(void) sendSMSWithPhoneNumber:(NSString*)phoneNumber block:(void (^)(BOOL success,NSString* message))block{
    CPLogInfo(@"请求短信验证码");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_SEND_SMS]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:phoneNumber?phoneNumber:@"" forKey:@"number"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"请求短信验证码JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self sendSMSWithPhoneNumber:phoneNumber block:^(BOOL success, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"请求短信验证码成功:%@",weakRequest.responseString);
                        block(YES,nil);
                    }else{
                        block(NO,message);
                    }
                }];
            }else{
                block(NO,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"请求短信验证码成功:%@",weakRequest.responseString);
            block(YES,nil);
        }
    }];
    [request startAsynchronous];
}
+(void) validateSMSWithPhoneNumber:(NSString*)phoneNumber code:(NSString*)code block:(void (^)(BOOL success,NSString* message))block{
    CPLogInfo(@"验证短信验证码");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_VALIDATE_SMS]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:phoneNumber?phoneNumber:@"" forKey:@"number"];
    [json setObject:code?code:@"" forKey:@"code"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"验证短信验证码JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self validateSMSWithPhoneNumber:phoneNumber code:code block:^(BOOL success, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"验证短信验证码成功:%@",weakRequest.responseString);
                        block(YES,nil);
                    }else{
                        block(NO,message);
                    }
                }];
            }else{
                block(NO,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"验证短信验证码成功:%@",weakRequest.responseString);
            block(YES,nil);
        }
    }];
    [request startAsynchronous];
}
+(void) bindEmail:(NSString*)emailAddr block:(void (^)(BOOL success,NSString* message))block{
    CPLogInfo(@"绑定邮箱:%@",emailAddr);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_BIND_EMAIL]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:emailAddr?emailAddr:@"" forKey:@"emailAddr"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"绑定邮箱JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self bindEmail:emailAddr block:^(BOOL success, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"绑定邮箱成功:%@",weakRequest.responseString);
                        block(YES,nil);
                    }else{
                        block(NO,message);
                    }
                }];
            }else{
                block(NO,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"绑定邮箱成功:%@",weakRequest.responseString);
            block(YES,nil);
        }
    }];
    [request startAsynchronous];
}
// 绑定手机
+(void) bindPhone:(NSString*)code block:(void (^)(BOOL success,NSString* message))block{
    CPLogInfo(@"绑定手机,code:%@",code);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_BIND_PHONE]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:code?code:@"" forKey:@"code"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"绑定手机,JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self bindPhone:code block:^(BOOL success, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"绑定手机成功:%@",weakRequest.responseString);
                        block(YES,nil);
                    }else{
                        block(NO,message);
                    }
                }];
            }else{
                block(NO,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"绑定手机成功:%@",weakRequest.responseString);
            block(YES,nil);
        }
    }];
    [request startAsynchronous];
}
+(void) resetPasswordBySMSCode:(NSString*)code newPassword:(NSString*)newPassword block:(void (^)(BOOL success,NSString* newPassword,NSString* message))block{
    CPLogInfo(@"通过手机短信找回密码 code:%@ , newPassword:%@",code,newPassword);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_RESET_PASSWORD_BY_SMS_CODE]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:code?code:@"" forKey:@"code"];
    [json setObject:newPassword?newPassword:@"" forKey:@"newPasswd"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"通过手机短信找回密码,JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,nil,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self resetPasswordBySMSCode:code newPassword:newPassword block:^(BOOL success,NSString* newPassword,NSString* message) {
                    if (success) {
                        CPLogVerbose(@"通过手机短信找回密码成功:%@",weakRequest.responseString);
                        block(YES,newPassword,nil);
                    }else{
                        block(NO,nil,message);
                    }
                }];
            }else{
                block(NO,nil,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"通过手机短信找回密码成功:%@",weakRequest.responseString);
            block(YES,newPassword,nil);
        }
    }];
    [request startAsynchronous];
}
+(void) resetPasswordByEmail:(NSString*)emailAddr block:(void (^)(BOOL success,NSString* message))block{
    CPLogInfo(@"通过邮箱找回密码:%@",emailAddr);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_RESET_PASSWORD_BY_EMAIL]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:emailAddr?emailAddr:@"" forKey:@"emailAddr"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"通过邮箱找回密码,JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self resetPasswordByEmail:emailAddr block:^(BOOL success, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"通过邮箱找回密码成功:%@",weakRequest.responseString);
                        block(YES,nil);
                    }else{
                        block(NO,message);
                    }
                }];
            }else{
                block(NO,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"通过邮箱找回密码成功:%@",weakRequest.responseString);
            block(YES,nil);
        }
    }];
    [request startAsynchronous];
}
+(void) resetPasswordWithOriginalPassword:(NSString*)originalPassword newPassword:(NSString*)newPassword block:(void (^)(BOOL success,NSString* newPassword, NSString* message))block{
    CPLogInfo(@"通过旧密码重设密码 old:%@,new:%@",originalPassword,newPassword);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_RESET_PASSWORD_BY_ORIGINAL_PASSWORD]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:originalPassword?originalPassword:@"" forKey:@"oldPasswd"];
    [json setObject:newPassword?newPassword:@"" forKey:@"newPasswd"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"通过旧密码重设密码,JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,nil,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self resetPasswordWithOriginalPassword:originalPassword newPassword:newPassword block:^(BOOL success, NSString *newPassword, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"通过旧密码重设密码成功:%@",weakRequest.responseString);
                        block(YES,newPassword,nil);
                    }else{
                        block(NO,nil,message);
                    }
                }];
            }else{
                block(NO,nil,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"通过旧密码重设密码成功:%@",weakRequest.responseString);
            block(YES,newPassword,nil);
        }
    }];
    [request startAsynchronous];
}
// 获取系统消息
+(void) pushSearchWithBlock:(void (^)(BOOL success,NSMutableArray* results,NSString* message))block{
    CPLogInfo(@"获取系统消息");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_GET_PUSH_SEARCH]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,nil,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:nil]) {
            CPLogVerbose(@"获取系统消息成功:%@",weakRequest.responseString);
            block(YES,[json objectForKey:Jk_results],nil);
        }else{
            CPLogVerbose(@"获取系统消息失败:%@",weakRequest.responseString);
            block(NO,nil,@"获取系统消息失败,请稍后再试");
        }
    }];
    [request startAsynchronous];
}
// 获取安全手机和安全邮箱
+(void) requestSafetyPhoneNumberAndEmailWithBlock:(void (^)(BOOL success,NSString*phoneNumber,NSString*email,NSString* message))block{
    CPLogInfo(@"获取安全手机号和邮箱");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_SAFETY_PHONE_NUMBER_AND_EMAIL]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,nil,nil,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestSafetyPhoneNumberAndEmailWithBlock:^(BOOL success, NSString *phoneNumber, NSString *email, NSString *message) {
                    if (success) {
                        CPLogVerbose(@"获取安全手机号,邮箱成功:%@",weakRequest.responseString);
                        block(YES,phoneNumber,email,nil);
                    }else{
                        block(NO,nil,nil,message);
                    }
                }];
            }else{
                block(NO,nil,nil,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            CPLogVerbose(@"获取安全手机号,邮箱成功:%@",weakRequest.responseString);
            NSString* phoneNumber = [json objectForKey:Jk_phoneNumber];
            if ([phoneNumber isEqualToString:@""]) {
                phoneNumber = nil;
            }
            NSString* email = [json objectForKey:Jk_emailAddr];
            if ([email isEqualToString:@""]) {
                email = nil;
            }
            block(YES,phoneNumber,email,nil);
        }
    }];
    [request startAsynchronous];
}

+(void) requestMemberInfo:(void (^)(BOOL success,NSString* message,NSString* name,NSString* productId,NSNumber* price,NSString* room,NSNumber* memberTime,NSNumber* usage,NSString* usePercent,NSNumber* leftRoom,NSNumber* balance))block{
    CPLogInfo(@"获取会员信息");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_MEMBER_INFO]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络",nil,nil,nil,nil,nil,nil,nil,nil,nil);
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestMemberInfo:^(BOOL success, NSString *message, NSString *name,NSString* productId, NSNumber *price, NSString *room, NSNumber *memberTime, NSNumber *usage, NSString *usePercent, NSNumber *leftRoom, NSNumber *balance) {
                    block(success,message,name,productId,price,room,memberTime,usage,usePercent,leftRoom,balance);
                }];
            }else{
                CPLogVerbose(@"获取会员信息失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg],nil,nil,nil,nil,nil,nil,nil,nil,nil);
            }
        }]) {
            CPLogVerbose(@"获取会员信息成功:%@",weakRequest.responseString);
            block(YES,nil,[json objectForKey:Jk_member_name],[json objectForKey:Jk_member_productId],[json objectForKey:Jk_member_price],[json objectForKey:Jk_member_room],[json objectForKey:Jk_member_memberTime],[json objectForKey:Jk_member_usage],[json objectForKey:Jk_member_usePercent],[json objectForKey:Jk_member_leftRoom],[json objectForKey:Jk_member_balance]);
        }
    }];
    [request startAsynchronous];
}


// 获取消费记录信息
+(void) requestOrderInfo:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block{
    CPLogInfo(@"获取消费记录信息");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_ORDER_INFO]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络",nil);
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestOrderInfo:^(BOOL success, NSString *message, NSMutableArray *results) {
                    block(success,message,results);
                }];
            }else{
                CPLogVerbose(@"获取消费记录信息失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg],nil);
            }
        }]) {
            CPLogVerbose(@"获取消费记录信息成功:%@",weakRequest.responseString);
            block(YES,nil,[json objectForKey:Jk_results]);
        }
    }];
    [request startAsynchronous];
}

// 获取充值记录信息
+(void) requestRechargeInfo:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block{
    CPLogInfo(@"获取充值记录信息");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_RECHARGE_INFO]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络",nil);
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestRechargeInfo:^(BOOL success, NSString *message, NSMutableArray *results) {
                    block(success,message,results);
                }];
            }else{
                CPLogVerbose(@"获取充值记录信息失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg],nil);
            }
        }]) {
            CPLogVerbose(@"获取充值记录信息成功:%@",weakRequest.responseString);
            block(YES,nil,[json objectForKey:Jk_results]);
        }
    }];
    [request startAsynchronous];
}
// 获取产品列表
+(void) requestProduct:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block{
    CPLogInfo(@"获取产品列表");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_PRODUCT]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络",nil);
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestProduct:^(BOOL success, NSString *message, NSMutableArray *results) {
                    block(success,message,results);
                }];
            }else{
                CPLogVerbose(@"获取产品列表失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg],nil);
            }
        }]) {
            CPLogVerbose(@"获取产品列表成功:%@",weakRequest.responseString);
            block(YES,nil,[json objectForKey:Jk_results]);
        }
    }];
    [request startAsynchronous];
}
// 更改套餐
+(void) changeProduct:(NSString*)productId block:(void (^)(BOOL success,NSString* message))block{
    CPLogInfo(@"请求更改产品(套餐)");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_UPDATE_PRODUCT]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:productId?productId:@"" forKey:@"productId"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"请求更改产品(套餐)JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络");
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self changeProduct:productId block:^(BOOL success, NSString *message) {
                    block(success,message);
                }];
            }else{
                CPLogVerbose(@"请求更改产品(套餐)失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg]);
            }
        }]) {
            id orderId = [json objectForKey:Jk_orderId];
            CPLogInfo(@"获取到 orderId : %@",orderId);
            CPLogInfo(@"确认更改产品(套餐)");
            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_UPDATE_PRODUCT_CONFIRM]]];
            NSMutableDictionary* json = [NSMutableDictionary dictionary];
            [json setObject:orderId?orderId:@"" forKey:@"orderId"];
            NSString* jsonString = [json JSONString];
            CPLogVerbose(@"确认更改产品(套餐)JSON:%@",jsonString);
            [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
            __weak ASIHTTPRequest* weakRequest = request;
            // 同步请求
            [request setFailedBlock:^{
                CPLogWarn(@"请求失败:%@",weakRequest.responseString);
                block(NO,@"请检查网络");
            }];
            [request setCompletionBlock:^{
                NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
                // 更新时间差
                [self updateDelta_t:[json objectForKey:Jk_serverTime]];
                
                if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
                    if (success) {
                        [self changeProduct:productId block:^(BOOL success, NSString *message) {
                            block(success,message);
                        }];
                    }else{
                        CPLogVerbose(@"确认更改产品(套餐)失败:%@",weakRequest.responseString);
                        block(NO,[json objectForKey:Jk_errmsg]);
                    }
                }]) {
                    CPLogVerbose(@"确认更改产品(套餐)成功:%@",weakRequest.responseString);
                    block(YES,nil);
                }
            }];
            [request startAsynchronous];
        }
    }];
    [request startAsynchronous];
}
// 获取充值方案
+(void) requestRechargeItem:(void (^)(BOOL success,NSString* message,NSMutableArray* results))block{
    CPLogInfo(@"获取充值方案");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_RECHARGE_ITEM]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络",nil);
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestRechargeItem:^(BOOL success, NSString *message, NSMutableArray *results) {
                    block(success,message,results);
                }];
            }else{
                CPLogVerbose(@"获取充值方案失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg],nil);
            }
        }]) {
            CPLogVerbose(@"获取充值方案成功:%@",weakRequest.responseString);
            block(YES,nil,[json objectForKey:Jk_results]);
        }
    }];
    [request startAsynchronous];
}
// 充值
+(void) requestRechargeCreateWithItemID:(NSString*)itemId block:(void (^)(BOOL success,NSString* message,NSNumber* rechargeId,NSString* signInfo,NSString* sign))block{
    CPLogInfo(@"获取充值签名");
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,URL_REQUEST_RECHARGE_CREATE]]];
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [json setObject:itemId?itemId:@"" forKey:@"itemId"];
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"获取充值签名JSON:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest* weakRequest = request;
    // 同步请求
    [request setFailedBlock:^{
        CPLogWarn(@"请求失败:%@",weakRequest.responseString);
        block(NO,@"请检查网络",nil,nil,nil);
    }];
    [request setCompletionBlock:^{
        NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[json objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:json completeBlock:^(BOOL success) {
            if (success) {
                [self requestRechargeCreateWithItemID:itemId block:^(BOOL success, NSString *message, NSNumber *rechargeId, NSString *signInfo, NSString *sign) {
                    block(success,message,rechargeId,signInfo,sign);
                }];
            }else{
                CPLogVerbose(@"获取充值签名失败:%@",weakRequest.responseString);
                block(NO,[json objectForKey:Jk_errmsg],nil,nil,nil);
            }
        }]) {
            CPLogVerbose(@"获取充值签名成功:%@",weakRequest.responseString);
            block(YES,nil,[json objectForKey:Jk_rechargeId],[json objectForKey:Jk_signInfo],[json objectForKey:Jk_sign]);
        }
    }];
    [request startAsynchronous];
}



static WYSyncSimple* wySyncSimple;
// 同步
+(void) sync{
    @synchronized(self){
        if (!wySyncSimple){
            wySyncSimple = [WYSyncSimple sharedWYSyncSimple];
            wySyncSimple.delegate = (id)self;
            wySyncSimple.url_download = S2CUrl;
            wySyncSimple.url_upload = C2SUrl;
#warning 他期望一个合理的数值
            wySyncSimple.intervalForCheckNet = 3600;
            wySyncSimple.intervalForJsonRequest = 3600;
        }
    }
    // 用户限制
    if (!CPUserName) {
        CPLogWarn(@"非登录用户,不能进行同步");
        return;
    }
    // 网络限制
    Reachability * reach = [Reachability reachabilityWithHostname:URL_SERVER_ROOT];
    if ([reach currentReachabilityStatus] == NotReachable) {
        CPLogWarn(@"%s没有网络,不进行同步",__FUNCTION__);
        return;
    }
    if ([reach currentReachabilityStatus] == ReachableViaWWAN) {
        CPLogWarn(@"%s正在使用3G网络",__FUNCTION__);
        if (CPSyncOnlyWifi) {
            CPLogWarn(@"用户要求仅在Wifi下同步,SO 不进行同步");
            return;
        }
    }
    reach.reachableBlock = ^(Reachability * reachability)
    {
        [wySyncSimple notifyNeedSync];
    };
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        CPLogWarn(@"有网络,但是无法连接到服务器");
    };
    [reach startNotifier];
}
// 通知替换对象
+(void) notifyReplaceEntity:(NSObject *)entity{
    [WYSyncSimple sharedWYSyncSimple];
    [WYSynchronization notifyReplaceEntity:entity];
}

// 通知删除对象
+(void) notifyDeleteEntity:(NSObject *)entity{
    [WYSyncSimple sharedWYSyncSimple];
    [WYSynchronization notifyDeleteEntity:entity];
}

#pragma mark private
+(BOOL) uploadFileWithOP:(WYDatabaseOperation*)wydo{
    CPImage* file = [[CPDB getLKDBHelperByUser] searchSingle:[CPImage class] where:[NSString stringWithFormat:@"cp_uuid='%@'",wydo.wy_uuid] orderBy:nil];
    if (file) {
        CPLogInfo(@"开始上传文件:%@",file.cp_uuid);
        // 获取照片
        UIImage* image = file.image;
        if (!image) {
            // 找不到文件 , 用默认图片代替
            CPLogError(@"找不到文件,file:%@",file.cp_uuid);
            image = [UIImage imageNamed:@"cp_null_photo"];
        }
        NSData* data = UIImageJPEGRepresentation(image, 1);
        // 上传文件 获取文件在服务器上的url
        NSDictionary* jsonDictionary = [[CPFile uploadFile:data url:C2SFileUrl key:Jk_filename] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
        // 更新时间差
        [self updateDelta_t:[jsonDictionary objectForKey:Jk_serverTime]];
        
        if ([self checkErrnoAndDeal:jsonDictionary completeBlock:nil]) {
            NSString* url = [jsonDictionary objectForKey:Jk_url];
            NSString* md5 = [jsonDictionary objectForKey:Jk_md5];
            if (!url) {
                CPLogWarn(@"文件上传失败!uuid:%@",file.cp_uuid);
                return NO;
            }
            // 更新
            file.cp_url = url;
            file.cp_md5 = md5;
            BOOL update = [[CPDB getLKDBHelperByUser] executeSQL:[NSString stringWithFormat:@"UPDATE %@ SET cp_url=?,cp_md5=? WHERE cp_uuid=?",[CPImage getTableName]] arguments:@[file.cp_url,file.cp_md5,file.cp_uuid]];
            if (!update) {
                CPLogError(@"文件获取到url,更新数据库失败,file:%@",file);
                return NO;
            }
            // 清除本地uuid为key的图片缓存,生成url为key的图片缓存
            [[SDImageCache sharedImageCache] storeImage:image forKey:file.cp_url];
            [[SDImageCache sharedImageCache] removeImageForKey:file.cp_uuid];
            
            CPLogInfo(@"上传文件成功 uuid:%@  url:%@",file.cp_uuid,file.cp_url);
            wydo.wy_data = [file syncDataContent];
            return YES;
        }else{
            CPLogWarn(@"上传文件,服务器返回标记为失败");
            return NO;
        }
    }
    return NO;
}

+(void) downloadFileWithOP:(WYDatabaseOperation*)wydo{
    NSMutableDictionary* dataDic = [NSMutableDictionary dictionaryWithDictionary:[wydo.wy_data objectFromJSONStringWithParseOptions:JKParseOptionStrict]];
    NSString* url = [dataDic objectForKey:@"cp_url"];
    NSString* cp_uuid = [dataDic objectForKey:@"cp_uuid"];
    
    if (!url) {
        return;
    }
    
    CPLogInfo(@"准备下载文件,url:%@,cp_uuid:%@",url,cp_uuid);
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,url]] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         
     }completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished){
             CPLogInfo(@"下载文件成功,url:%@,cp_uuid:%@",url,cp_uuid);
             [[SDImageCache sharedImageCache] storeImage:image forKey:url];
         }else{
             CPLogError(@"下载文件失败,url:%@,cp_uuid:%@",url,cp_uuid);
         }
     }];
}
// 更新客户端,服务器时间差 客户端时间-服务器时间
#warning 若操作队列处理时间很长,此处会有比较大的误差\
应该精简 更新时差操作, 只有同步开始时 调用
+(void) updateDelta_t:(NSNumber*)time{
    if (!time) {
        return;
    }
    double delta_t = [[NSDate date] timeIntervalSince1970] - [time doubleValue];
    CPLogInfo(@"更新时间差 %f->%f",CPDelta_T,delta_t);
    CPSetDelta_T(delta_t);
}
// 根据时间差，获取服务器时间
+(double) getServerTimeByDelta_t{
    return [[NSDate date] timeIntervalSince1970] - CPDelta_T;
}
// 更新数据库版本
+(void) updateVersion:(NSNumber*)version{
    if (!version) {
        return;
    }
    CP_DB_Info* info = [[CPDB getLKDBHelperByUser] searchSingle:[CP_DB_Info class] where:[NSString stringWithFormat:@"cp_key = '%@'",CP_DB_INFO_VERSION] orderBy:nil];
    if (info) {
        CPLogInfo(@"数据库版本修改为服务器数据库版本 %@->%@",info.cp_value,version);
        info.cp_value = [version stringValue];
    }else{
        info = [CP_DB_Info new];
        info.cp_key = CP_DB_INFO_VERSION;
        info.cp_value = [version stringValue];
        CPLogInfo(@"数据库版本修改为服务器数据库版本 无->%@",version);
    }
    [[CPDB getLKDBHelperByUser] insertToDB:info];
}
// 获取服务器版本号
+(NSNumber*) getVersion{
    CP_DB_Info* info = [[CPDB getLKDBHelperByUser] searchSingle:[CP_DB_Info class] where:[NSString stringWithFormat:@"cp_key = '%@'",CP_DB_INFO_VERSION] orderBy:nil];
    NSNumber* version;
    if (info) {
        version = [NSNumber numberWithInteger:[info.cp_value integerValue]];
    }
    return version;
}

// ack 告诉服务器,成功更新
+(void) ack:(NSString*)transactionId{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:S2CAckUrl]];
    NSDictionary* json = @{Jk_transactionId:transactionId};
    NSString* jsonString = [json JSONString];
    CPLogVerbose(@"ack请求json:%@",jsonString);
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    [request startSynchronous];
    NSError* error = [request error];
    if(!error){
        CPLogVerbose(@"ack,回应服务器成功.json:%@",request.responseString);
    }else{
        CPLogWarn(@"ack,回应服务器成功失败.json:%@,error:%@",request.responseString,error);
    }
}

+(BOOL) checkErrnoAndDeal:(NSDictionary*)responce completeBlock:(void (^)(BOOL success))completeBlock{
    id success = [responce objectForKey:JK_errno];
    if (!success || [success intValue] != 0) {
        CPLogWarn(@"服务器返回标志错误:%@",responce);
        id state = [responce objectForKey:JK_errno];
        // 重新登录
        if (state && [state intValue] == Tag_NeedLogin) {
            CPLogWarn(@"需要重新登录");
            [self loginAutoWithBlock:^(BOOL success,NSString* message) {
                if (completeBlock) {
                    completeBlock(success);
                }
            }];
            return NO;
        }
        // 密码错误
        if (state && [state intValue] == Tag_ErrorUsernameOrPassword) {
            CPLogWarn(@"密码错误,注销");
            [self logoutNotCleanData];
        }
        // 不能解决问题,下次线程执行block
//        [self bk_performBlock:^{
//            if (completeBlock) {
//                completeBlock(NO);
//            }
//        } afterDelay:0];
        double delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (completeBlock) {
                completeBlock(NO);
            }
        });
        return NO;
    }
    return YES;
}
#warning 如果登录比取消同步快,会不会有问题\
正确的解决方案是,每次同步的时候都先登录一次,确立连接

#pragma mark WYSyncSimpleDelegate


// 创建数据库
+(void) creatDB{
    [CPDB creatDB];
}
// 删除数据库
+(void) dropDB{
    [CPDB dropDB];
}

+(BOOL) downloadIsSuccessWithJson:(NSDictionary*)responce{
    if ([self checkErrnoAndDeal:responce completeBlock:^(BOOL success) {
        if (success) {
            [wySyncSimple notifyNeedSync];
        }
    }]) {
        return YES;
    }else{
        [wySyncSimple notifyCancelSync];
        return NO;
    }
}

+(NSArray*) downloadOperationsFromJson:(NSDictionary*)json{
    // JSON 转换成操作
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:100];
    NSArray* json0 = [json objectForKey:Jk_data];
    for(NSDictionary* operationJson in json0){
        WYDatabaseOperation* databaseOperation = [WYDatabaseOperation new];
        NSString* tbName = [operationJson objectForKey:Jk_tableName];
        //        Class c = NSClassFromString(tbName);
        //        databaseOperation.wy_dbName = [c syncOperationDBName];
        //        databaseOperation.wy_tbName = [c syncOperationTBName];
        //        databaseOperation.wy_primary_key = [c syncOperationPrimaryKey];
        databaseOperation.wy_dbName = [CPBaseModel syncOperationDBName];
        databaseOperation.wy_tbName = tbName;
        databaseOperation.wy_primary_key = [CPBaseModel syncOperationPrimaryKey];
        databaseOperation.wy_uuid = [operationJson objectForKey:Jk_uuid];
        NSString* action = [operationJson objectForKey:Jk_action];
        if ([action isEqualToString:Jk_action_DELETE]) {
            databaseOperation.wy_operation = SynchronizationOperationDelete;
        } else if([action isEqualToString:Jk_action_REPLACE]){
            databaseOperation.wy_operation = SynchronizationOperationAddOrUpdate;
        } else{
            databaseOperation.wy_operation = SynchronizationOperationAddOrUpdate;
        }
        databaseOperation.wy_timestamp = [[operationJson objectForKey:Jk_updatedAt] doubleValue];
        databaseOperation.wy_data = [operationJson objectForKey:Jk_content];
        // 如果是文件,则进行 删除或者下载
        NSString* resourceType = [operationJson objectForKey:Jk_resourceType];
        if ([resourceType isEqualToString:Jk_resourceType_FILE]) {
            switch (databaseOperation.wy_operation) {
                case SynchronizationOperationAddOrUpdate:{
                    // 下载
                    [self downloadFileWithOP:databaseOperation];
                    break;
                }
                case SynchronizationOperationDelete:{
                    break;
                }
                default:
                    break;
            }
        }
        [result addObject:databaseOperation];
    }
    return result;
}

+(NSString*) downloadRequestJson{
    NSMutableDictionary* json0 = [NSMutableDictionary dictionaryWithCapacity:3];
    [json0 setObject:[OpenUDID value] forKey:Jk_deviceId];
    NSNumber* version = [self getVersion];
    
    if (!version) {
        // 主动fullcopy
        CPLogWarn(@"找不到本地数据库版本,主动请求FullCopy");
        [json0 setObject:[NSNumber numberWithBool:YES] forKey:Jk_fullcopy];
    }else{
        CPLogWarn(@"本地数据库版本:%@,不主动请求FullCopy",version);
        [json0 setObject:version forKey:Jk_currentHead];
        [json0 setObject:[NSNumber numberWithBool:NO] forKey:Jk_fullcopy];
    }
    return [json0 JSONString];
}
#warning DO 这里需要,清空操作队列!
+(BOOL) downloadIsCleanDBWithJson:(NSDictionary*)json{
    id isClean = [json objectForKey:Jk_fullcopy];
    if (isClean && [isClean intValue]!=0) {
        return YES;
    }
    return NO;
}

// download完成
+(void) downloadFinishWithJson:(NSDictionary*)json{
    // 服务器版本号
    NSNumber* serverVersion = [json objectForKey:Jk_revisionHead];
    [self updateVersion:serverVersion];
    // 更新时间差
    NSNumber* delta_t = [json objectForKey:Jk_serverTime];
    [self.class updateDelta_t:delta_t];
    // ack 告诉服务器,成功更新
    NSString* transactionID = [json objectForKey:Jk_transactionId];
    if (transactionID && ![transactionID isEqualToString:@""]) {
        [self ack:transactionID];
    }
    CPLogInfo(@"下载完成");
}
+(NSString*) uploadRequestJsonWithOperations:(NSArray*)operations{
    // 0
    NSMutableDictionary* json0 = [NSMutableDictionary dictionaryWithCapacity:2];
    [json0 setObject:[OpenUDID value] forKey:Jk_deviceId];
    NSMutableArray* json1 = [NSMutableArray arrayWithCapacity:8];
    // 1
    for (WYDatabaseOperation* dbOperation in operations) {
        //        // 如果是离线状态下生成的操作队列,那么 tbName 为nil,此处转换成当前用户
        //        if (!dbOperation.wy_dbName) {
        //            dbOperation.wy_dbName = CPUserName;
        //        }
        NSAssert(dbOperation.wy_operation == SynchronizationOperationDelete || (dbOperation.wy_data != nil && ![dbOperation.wy_data isEqualToString:@""]), @"操作队列,数据字段为空:%@",self);
        NSAssert(dbOperation.wy_dbName != nil && ![dbOperation.wy_dbName isEqualToString:@""], @"操作队列,数据库名称字段为空:%@",self);
        NSAssert(dbOperation.wy_tbName != nil && ![dbOperation.wy_tbName isEqualToString:@""], @"操作队列,表名字段为空:%@",self);
        NSAssert(dbOperation.wy_uuid != nil && ![dbOperation.wy_uuid isEqualToString:@""], @"操作队列,uuid字段为空:%@",self);
        // 2
        NSMutableDictionary* json2 = [NSMutableDictionary dictionaryWithCapacity:6];
        [json2 setObject:dbOperation.wy_tbName forKey:Jk_tableName];
        if ([dbOperation.wy_tbName isEqualToString:[CPImage getTableName]]) {
            [json2 setObject:Jk_resourceType_FILE forKey:Jk_resourceType];
            // 上传文件
            if (dbOperation.wy_operation == SynchronizationOperationAddOrUpdate) {
                BOOL success = [self uploadFileWithOP:dbOperation];
                if (!success) {
                    [wySyncSimple notifyCancelSync];
                    return nil;
                }
                // 如果是上传文件,则添加 cp_url cp_md5 信息
                NSMutableDictionary* file = [dbOperation.wy_data objectFromJSONStringWithParseOptions:JKParseOptionStrict];
                [json2 setObject:[file objectForKey:@"cp_url"] forKey:Jk_url];
                [json2 setObject:[file objectForKey:@"cp_md5"] forKey:Jk_md5];
            }
        }else{
            [json2 setObject:Jk_resourceType_DATA forKey:Jk_resourceType];
        }
        [json2 setObject:dbOperation.wy_uuid forKey:Jk_uuid];
        switch (dbOperation.wy_operation) {
            case SynchronizationOperationAddOrUpdate:
                [json2 setObject:Jk_action_REPLACE forKey:Jk_action];
                break;
            case SynchronizationOperationDelete:
                [json2 setObject:Jk_action_DELETE forKey:Jk_action];
                break;
            default:
                break;
        }
        [json2 setObject:[NSNumber numberWithDouble:dbOperation.wy_timestamp] forKey:Jk_updatedAt];
        [json2 setObject:dbOperation.wy_data forKey:Jk_content];
        
        [json1 addObject:json2];
    }
    [json0 setObject:json1 forKey:Jk_data];
    return [json0 JSONString];
}

+(BOOL) uploadIsSuccessWithJson:(NSDictionary*)responce{
    if ([self checkErrnoAndDeal:responce completeBlock:^(BOOL success) {
        if (success) {
            [wySyncSimple notifyNeedSync];
        }
    }]) {
        return YES;
    }else{
        [wySyncSimple notifyCancelSync];
        return NO;
    }
}

// upload完成
+(void) uploadFinishWithJson:(NSDictionary*)json{
    // 更新时间差
    NSNumber* delta_t = [json objectForKey:Jk_serverTime];
    [self updateDelta_t:delta_t];
    // 更新数据库版本
    BOOL needDownLoad = [self uploadNeedDownloadWithJson:json];
    if (!needDownLoad) {
        CPLogInfo(@"无需download,修改数据库版本");
        NSNumber* serverVersion = [json objectForKey:Jk_revisionHead];
        [self updateVersion:serverVersion];
    }else{
        CPLogInfo(@"需要download,放弃修改数据库版本。");
    }
    CPLogInfo(@"上传完成");
}

+(BOOL) uploadNeedDownloadWithJson:(NSDictionary*)json{
    NSNumber* version = [self getVersion];
    if (!version) {
        // 本地无版本,需要FullCopy
        CPLogWarn(@"判断upload后是否需要download,发现找不到本地数据库版本,需要download");
        return YES;
    }
    id needDown = [json objectForKey:Jk_download];
    if (needDown && [needDown boolValue]) {
        CPLogInfo(@"服务器通知,此Upload后需要Download");
        return YES;
    }
    return NO;
}
// 获取需要上传的操作队列的条件
+(void) uploadDatabaseOperationWhereDBName:(NSArray**)dbName table:(NSArray**)tableName uuid:(NSArray**)uuid{
    *dbName = @[CPUserName,OFF_LINE_DB_Name];
}
+(void) willDoSync{
    CPLogInfo(@"将要同步");
}
+(void) didDoSync{
    CPLogInfo(@"完成同步,发出通知:CPSyncDoneNotification");
    // 通知
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CPSyncDoneNotification object:nil];
    });
}

@end
