//
//  CPFamily.h
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPFamily : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSNumber* cp_car;
@property(nonatomic)NSNumber* cp_estate;
@property(nonatomic)NSNumber* cp_zoom;
@property(nonatomic)NSNumber* cp_invain;
@property(nonatomic)NSNumber* cp_marriage_status;
@property(nonatomic)NSNumber* cp_member_status;

@property(nonatomic)NSString* cp_address_name;
@property(nonatomic)NSString* cp_longitude;
@property(nonatomic)NSString* cp_latitude;

@property(nonatomic)NSString* cp_spouse_name;
@property(nonatomic)NSString* cp_spouse_phone;
@property(nonatomic)NSString* cp_spouse_birthday;
@property(nonatomic)NSString* cp_contact_uuid;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
