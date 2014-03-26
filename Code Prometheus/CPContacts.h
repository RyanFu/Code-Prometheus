//
//  CPContacts.h
//  Code Prometheus
//
//  Created by mirror on 13-11-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPContacts : CPBaseModel

@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSString* cp_name;
@property(nonatomic)NSNumber* cp_sex;
@property(nonatomic)NSString* cp_phone_number;
@property(nonatomic)NSString* cp_birthday;
@property(nonatomic)NSNumber* cp_clues;

@property(nonatomic)NSString* cp_refer_contact;
@property(nonatomic)NSString* cp_weixin;
@property(nonatomic)NSString* cp_im;
@property(nonatomic)NSString* cp_email;
@property(nonatomic)NSNumber* cp_blood_type;
@property(nonatomic)NSString* cp_height;
@property(nonatomic)NSString* cp_weight;
@property(nonatomic)NSString* cp_hobby;
@property(nonatomic)NSString* cp_hometown;
@property(nonatomic)NSNumber* cp_picture_name;

@end
