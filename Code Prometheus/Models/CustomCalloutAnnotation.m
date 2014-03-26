//
//  CustomCalloutAnnotation.m
//  Category_demo2D
//
//  Created by xiaoming han on 13-5-27.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CustomCalloutAnnotation.h"

@implementation CustomCalloutAnnotation
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize name =_name;

- (id)initWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lon
{
    if (self = [super init]) {
        self.latitude = lat;
        self.longitude = lon;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    return coordinate;
}
@end
