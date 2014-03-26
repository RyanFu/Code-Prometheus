//
//  CPOther.m
//  Code Prometheus
//
//  Created by mirror on 13-12-11.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPOther.h"

@implementation CPOther
// 表名
+(NSString *)getTableName
{
    return @"cp_other";
}
+(instancetype)newAdaptDB{
    CPOther* other = [super newAdaptDB];
    other.cp_travel_insurance = @(NO);
    other.cp_group_insurance = @(NO);
    other.cp_car_insurance = @(NO);
    return other;
}

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPOther* other = [self newAdaptDB];
    other.cp_contact_uuid = contactsUUID;
    return other;
}
@end
