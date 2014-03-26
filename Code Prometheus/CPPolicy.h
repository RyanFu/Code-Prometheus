//
//  CPPolicy.h
//  Code Prometheus
//
//  Created by mirror on 13-12-4.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPPolicy : CPBaseModel

@property (nonatomic)NSString* cp_uuid;
@property (nonatomic)NSNumber* cp_timestamp;

@property (nonatomic)NSNumber* cp_date_begin;
@property (nonatomic)NSNumber* cp_date_end;
@property (nonatomic)NSString* cp_name;
@property (nonatomic)NSNumber* cp_my_policy;
@property (nonatomic)NSString* cp_description;
@property (nonatomic)NSNumber* cp_pay_type;
@property (nonatomic)NSNumber* cp_pay_amount;
@property (nonatomic)NSNumber* cp_pay_way;
@property (nonatomic)NSNumber* cp_remind_date;
@property (nonatomic)NSString* cp_contact_uuid;

@end
