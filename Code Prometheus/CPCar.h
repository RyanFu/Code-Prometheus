//
//  CPCar.h
//  Code Prometheus
//
//  Created by mirror on 13-12-11.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPCar : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSString* cp_name;
@property(nonatomic)NSString* cp_plate_number;
@property(nonatomic)NSString* cp_contact_uuid;

@property(nonatomic)NSNumber* cp_maturity_date;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
