//
//  CPFamilyMember.m
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFamilyMember.h"

@implementation CPFamilyMember
// 表名
+(NSString *)getTableName
{
    return @"cp_family_member";
}
+(instancetype)newAdaptDB{
    CPFamilyMember* fm = [super newAdaptDB];
    fm.cp_sex = @(0);
    return fm;
}
+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPFamilyMember* fm = [self newAdaptDB];
    fm.cp_contact_uuid = contactsUUID;
    return fm;
}
@end
