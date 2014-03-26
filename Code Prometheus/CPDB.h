//
//  CPDB.h
//  Code Prometheus
//
//  Created by mirror on 13-10-8.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"

// CP_DB_INFO KEY
// 数据库版本
static NSString* const CP_DB_INFO_VERSION = @"cp_db_version";

// 时间差不存放在数据库了,改为存在UserDefaault.(2013.12.23)
// 时间差 客户端时间-服务器时间
//static NSString* const CP_DB_INFO_DELTA_T = @"cp_db_delta-t";


// 离线数据库名
static NSString* const OFF_LINE_DB_Name = @"___cp_off_line_db";


@class LKDBHelper;

@interface CPDB : NSObject

+(LKDBHelper*) getLKDBHelperByUser;

// 强制创建当前用户的数据库
+(void) creatDB;
// 清除数据库
+(void) dropDB;
// 删除数据库
+(void) deleteDBFile;
// 如果当前用户的数据库不存在,则创建
+(void) creatDBIfNotExist;
// 将离线数据库修改为用户数据库,如果没有离线数据库,则返回, 如果用户数据库已经存在,则返回
+(void) creatDBFromOFFLineDB;


//// 从数据库获取服务器时间
//+(NSTimeInterval) guessServerTime;

@end
