//
//  CPOrganization.m
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPOrganization.h"

@implementation CPOrganization
// 表名
+(NSString *)getTableName
{
    return @"cp_organization";
}
+(instancetype)newAdaptDB{
    CPOrganization* organization = [super newAdaptDB];
    organization.cp_zengyuan = @(YES);
    organization.cp_education = @(0);
    organization.cp_working_conditions = @(0);
    organization.cp_meeting = @(NO);
    return organization;
}
+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPOrganization* organization = [self newAdaptDB];
    organization.cp_contact_uuid = contactsUUID;
    return organization;
}
@end
