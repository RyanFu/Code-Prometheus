//
//  CPPolicy.m
//  Code Prometheus
//
//  Created by mirror on 13-12-4.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPolicy.h"
#import "CPImage.h"

@implementation CPPolicy

+(instancetype)newAdaptDB{
    CPPolicy* policy = [super newAdaptDB];
    policy.cp_my_policy = @(YES);
    policy.cp_pay_type = @(0);
    policy.cp_pay_way = @(0);
    return policy;
}
// 表名
+(NSString *)getTableName
{
    return @"cp_insurance_policy";
}
+(void) dbWillDelete:(NSObject *)entity{
    CPPolicy* policy = (CPPolicy*)entity;
    // 删除文件
    NSMutableArray* images = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":policy.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPImage* image in images) {
        [[CPDB getLKDBHelperByUser] deleteToDB:image];
    }
}
@end
