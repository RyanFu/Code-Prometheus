//
//  CPCompany.m
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPCompany.h"

@implementation CPCompany
// 表名
+(NSString *)getTableName
{
    return @"cp_company";
}
+(instancetype)newAdaptDB{
    CPCompany* company = [super newAdaptDB];
    company.cp_on_position = @(YES);
    return company;
}
+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPCompany* company = [self newAdaptDB];
    company.cp_contact_uuid = contactsUUID;
    return company;
}
@end
