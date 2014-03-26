//
//  CPFamily.m
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFamily.h"

@implementation CPFamily
// 表名
+(NSString *)getTableName
{
    return @"cp_family";
}
+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPFamily* family = [self newAdaptDB];
    family.cp_contact_uuid = contactsUUID;
    return family;
}
@end
