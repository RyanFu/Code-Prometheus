//
//  CPOther.h
//  Code Prometheus
//
//  Created by mirror on 13-12-11.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPOther : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSNumber* cp_travel_insurance;
@property(nonatomic)NSNumber* cp_group_insurance;
@property(nonatomic)NSNumber* cp_car_insurance;

@property(nonatomic)NSString* cp_contact_uuid;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
