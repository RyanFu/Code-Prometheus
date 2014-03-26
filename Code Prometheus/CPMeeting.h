//
//  CPMeeting.h
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPMeeting : CPBaseModel
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSNumber* cp_timestamp;

@property(nonatomic)NSNumber* cp_date;

@property(nonatomic)NSString* cp_description;
@property(nonatomic)NSString* cp_contact_uuid;

+(instancetype)newAdaptDBWith:(NSString*)contactsUUID;
@end
