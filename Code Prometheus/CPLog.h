//
//  CPLog.h
//  Code Prometheus
//
//  Created by mirror on 13-9-26.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDLog.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>

#define CPLogVerbose(...)   DDLogVerbose(__VA_ARGS__)
#define CPLogDebug(...)     DDLogDebug(__VA_ARGS__)
#define CPLogInfo(...)      DDLogInfo(__VA_ARGS__)
#define CPLogWarn(...)      DDLogWarn(__VA_ARGS__)
#define CPLogError(...)     DDLogError(__VA_ARGS__)
#define CPLogCrash(...)     DDLogError(__VA_ARGS__)


//#define CPLogVerbose(...)   NSLog(__VA_ARGS__)
//#define CPLogInfo(...)      NSLog(__VA_ARGS__)
//#define CPLogWarn(...)      NSLog(__VA_ARGS__)
//#define CPLogError(...)     NSLog(__VA_ARGS__)
//#define CPLogCrash(...)     NSLog(__VA_ARGS__)


#ifdef DEBUG
static int const ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static int const ddLogLevel = LOG_LEVEL_WARN;
#endif


static NSString* const CP_LOG_EMAIL_TO = @"623637646@qq.com";


@interface CPLog : NSObject
// 获取单例
+ (instancetype)sharedLog;
// 准备log
-(void) prepareLog;
// log数据
- (NSArray *)logFileInfos;
// 清空日志
- (void) cleanLog;
@end
