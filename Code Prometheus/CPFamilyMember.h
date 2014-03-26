//
//  CPFamilyMember.h
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPFamilyMember : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSString* cp_name;
@property(nonatomic)NSString* cp_birthday;
@property(nonatomic)NSString* cp_contact_uuid;

@property(nonatomic)NSNumber* cp_sex;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
