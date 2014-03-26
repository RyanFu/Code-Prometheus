//
//  CPCompany.h
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPCompany : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSNumber* cp_on_position;
@property(nonatomic)NSNumber* cp_income;
@property(nonatomic)NSNumber* cp_zoom;
@property(nonatomic)NSNumber* cp_invain;
@property(nonatomic)NSNumber* cp_worker_amount;

@property(nonatomic)NSString* cp_industry;
@property(nonatomic)NSString* cp_name;
@property(nonatomic)NSString* cp_post;
@property(nonatomic)NSString* cp_post_description;
@property(nonatomic)NSString* cp_address_name;
@property(nonatomic)NSString* cp_longitude;
@property(nonatomic)NSString* cp_latitude;
@property(nonatomic)NSString* cp_zip;
@property(nonatomic)NSString* cp_contact_uuid;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
