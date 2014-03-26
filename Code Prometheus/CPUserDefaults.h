//
//  CPUserDefaults.h
//  Code Prometheus
//
//  Created by mirror on 13-11-21.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 用户
static NSString* const CPUserNameKey = @"use_name_key";
#define CPUserName [[NSUserDefaults standardUserDefaults] stringForKey:CPUserNameKey]
#define CPSetUserName(userName) [[NSUserDefaults standardUserDefaults] setObject:userName forKey:CPUserNameKey]


static NSString* const CPPasswordKey = @"password_key";
#define CPPassword [[NSUserDefaults standardUserDefaults] stringForKey:CPPasswordKey]
#define CPSetPassword(password) [[NSUserDefaults standardUserDefaults] setObject:password forKey:CPPasswordKey]


static NSString* const CPSafetyPhoneNumberKey = @"safety_phone_number_key";
#define CPSafetyPhoneNumber [[NSUserDefaults standardUserDefaults] stringForKey:CPSafetyPhoneNumberKey]
#define CPSetSafetyPhoneNumber(phoneNumber) [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:CPSafetyPhoneNumberKey]


static NSString* const CPSafetyEmailKey = @"safety_email_key";
#define CPSafetyEmail [[NSUserDefaults standardUserDefaults] stringForKey:CPSafetyEmailKey]
#define CPSetSafetyEmail(email) [[NSUserDefaults standardUserDefaults] setObject:email forKey:CPSafetyEmailKey]

#pragma mark - 会员
static NSString* const CPMemberNameKey = @"member_name";
#define CPMemberName [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberNameKey]
#define CPSetMemberName(name) [[NSUserDefaults standardUserDefaults] setObject:name forKey:CPMemberNameKey]

static NSString* const CPProductIdKey = @"product_id";
#define CPProductId [[NSUserDefaults standardUserDefaults] stringForKey:CPProductIdKey]
#define CPSetProductId(product_id) [[NSUserDefaults standardUserDefaults] setObject:product_id forKey:CPProductIdKey]

static NSString* const CPMemberPriceKey = @"member_price";
#define CPMemberPrice [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberPriceKey]
#define CPSetMemberPrice(price) [[NSUserDefaults standardUserDefaults] setObject:price forKey:CPMemberPriceKey]

static NSString* const CPMemberRoomKey = @"member_room";
#define CPMemberRoom [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberRoomKey]
#define CPSetMemberRoom(room) [[NSUserDefaults standardUserDefaults] setObject:room forKey:CPMemberRoomKey]

static NSString* const CPMemberTimeKey = @"member_time";
#define CPMemberTime [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberTimeKey]
#define CPSetMemberTime(time) [[NSUserDefaults standardUserDefaults] setObject:time forKey:CPMemberTimeKey]

static NSString* const CPMemberUsageKey = @"member_usage";
#define CPMemberUsage [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberUsageKey]
#define CPSetMemberUsage(member_usage) [[NSUserDefaults standardUserDefaults] setObject:member_usage forKey:CPMemberUsageKey]

static NSString* const CPMemberUsePercentKey = @"member_usePercent";
#define CPMemberUsePercent [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberUsePercentKey]
#define CPSetMemberUsePercent(member_usePercent) [[NSUserDefaults standardUserDefaults] setObject:member_usePercent forKey:CPMemberUsePercentKey]

static NSString* const CPMemberLeftRoomKey = @"member_leftRoom";
#define CPMemberLeftRoom [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberLeftRoomKey]
#define CPSetMemberLeftRoom(member_leftRoom) [[NSUserDefaults standardUserDefaults] setObject:member_leftRoom forKey:CPMemberLeftRoomKey]

static NSString* const CPMemberBalanceKey = @"member_balance";
#define CPMemberBalance [[NSUserDefaults standardUserDefaults] stringForKey:CPMemberBalanceKey]
#define CPSetMemberBalance(member_balance) [[NSUserDefaults standardUserDefaults] setObject:member_balance forKey:CPMemberBalanceKey]

#pragma mark - 用户设置
static NSString* const CPSyncOnlyWifiKey = @"sync_only_wifi_key";
#define CPSyncOnlyWifi [[NSUserDefaults standardUserDefaults] boolForKey:CPSyncOnlyWifiKey]
#define CPSetSyncOnlyWifi(syncOnlyWifi) [[NSUserDefaults standardUserDefaults] setBool:syncOnlyWifi forKey:CPSyncOnlyWifiKey]

#pragma mark - 系统
static NSString* const CPDelta_T_Key = @"delta_t_key";
#define CPDelta_T [[NSUserDefaults standardUserDefaults] doubleForKey:CPDelta_T_Key]
#define CPSetDelta_T(delta_t) [[NSUserDefaults standardUserDefaults] setDouble:delta_t forKey:CPDelta_T_Key]


static NSString* const CPLastSendSMSTimeIntervalKey = @"last_send_SMS_time_interval_key";
#define CPLastSendSMSTimeInterval [[NSUserDefaults standardUserDefaults] doubleForKey:CPLastSendSMSTimeIntervalKey]
#define CPSetLastSendSMSTimeInterval(timeInterval) [[NSUserDefaults standardUserDefaults] setDouble:timeInterval forKey:CPLastSendSMSTimeIntervalKey]



@interface CPUserDefaults : NSObject
// 清空
+ (void)resetDefaults;
@end
