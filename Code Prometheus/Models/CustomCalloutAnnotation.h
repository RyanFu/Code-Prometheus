//
//  CustomCalloutAnnotation.h
//  Category_demo2D
//
//  Created by xiaoming han on 13-5-27.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface CustomCalloutAnnotation : NSObject<MAAnnotation>

//some user info
@property (nonatomic, copy) NSString *name;

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

- (id)initWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lon;

@end
