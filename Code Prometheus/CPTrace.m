//
//  CPTrace.m
//  Code Prometheus
//
//  Created by mirror on 13-11-25.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPTrace.h"
#import "CPImage.h"

@implementation CPTrace
// 表名
+(NSString *)getTableName
{
    return @"cp_trace";
}
+(void) dbWillDelete:(NSObject *)entity{
    CPTrace* trace = (CPTrace*)entity;
    // 删除文件
    NSMutableArray* images = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":trace.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPImage* image in images) {
        [[CPDB getLKDBHelperByUser] deleteToDB:image];
    }
}
@end