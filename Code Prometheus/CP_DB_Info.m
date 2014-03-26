//
//  CP_DB_Info.m
//  Code Prometheus
//
//  Created by mirror on 13-9-29.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CP_DB_Info.h"

@implementation CP_DB_Info

// 表名
+(NSString *)getTableName
{
    return @"dbinfo";
}
// 主键
+(NSString *)getPrimaryKey
{
    return @"cp_key";
}

@end