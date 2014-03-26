//
//  CPImage.h
//  Code Prometheus
//
//  Created by mirror on 13-12-3.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBaseModel.h"

@interface CPImage : CPBaseModel
@property (copy,nonatomic)NSString* cp_uuid;
@property (nonatomic)NSNumber* cp_timestamp;

@property (copy,nonatomic)NSString* cp_r_uuid;
@property (copy,nonatomic)NSString* cp_url;
@property (copy,nonatomic)NSString* cp_md5;
@property (nonatomic)NSInteger cp_type;

@property (nonatomic)UIImage* image;
@end
