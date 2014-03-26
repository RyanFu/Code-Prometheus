//
//  CPMeeting.m
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPMeeting.h"

@implementation CPMeeting
// 表名
+(NSString *)getTableName
{
    return @"cp_meeting";
}

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPMeeting* metting = [self newAdaptDB];
    metting.cp_contact_uuid = contactsUUID;
    return metting;
}
@end
