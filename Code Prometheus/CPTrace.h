//
//  CPTrace.h
//  Code Prometheus
//
//  Created by mirror on 13-11-25.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPTrace : CPBaseModel

@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSString* cp_contact_uuid;
@property(nonatomic)NSNumber* cp_date;
@property(nonatomic)NSNumber* cp_stage;
@property(nonatomic)NSString* cp_description;

@end
