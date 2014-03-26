//
//  CPCar.m
//  Code Prometheus
//
//  Created by mirror on 13-12-11.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPCar.h"

@implementation CPCar
// 表名
+(NSString *)getTableName
{
    return @"cp_car";
}

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID{
    CPCar* car = [self newAdaptDB];
    car.cp_contact_uuid = contactsUUID;
    return car;
}
@end
