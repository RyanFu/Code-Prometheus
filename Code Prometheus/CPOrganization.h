//
//  CPOrganization.h
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPOrganization : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSNumber* cp_zengyuan;
@property(nonatomic)NSNumber* cp_education;
@property(nonatomic)NSNumber* cp_working_conditions;
@property(nonatomic)NSNumber* cp_to_beijing_date;
@property(nonatomic)NSNumber* cp_into_class_date;
@property(nonatomic)NSNumber* cp_meeting;

@property(nonatomic)NSString* cp_graduated;
@property(nonatomic)NSString* cp_contact_uuid;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
