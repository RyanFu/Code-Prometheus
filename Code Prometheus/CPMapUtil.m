//
//  CPMapUtil.m
//  Code Prometheus
//
//  Created by mirror on 13-12-6.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPMapUtil.h"

@implementation CPMapUtil
+ (MAMapView *)sharedMapView
{
    static dispatch_once_t once;
    static MAMapView* instance;
    dispatch_once(&once, ^{
        instance = MAMapView.new;
        instance.rotateEnabled = NO;
        instance.rotateCameraEnabled = NO;
//        instance.showsCompass = YES;
//        instance.compassOrigin = CGPointMake(320, 0);
//        instance.showsScale = YES;
//        instance.scaleOrigin = CGPointMake(0, 0);
    });
    return instance;
}

+ (AMapSearchAPI *)sharedMapSearchAPI
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];});
    return instance;
}
@end
