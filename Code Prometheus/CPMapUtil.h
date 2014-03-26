//
//  CPMapUtil.h
//  Code Prometheus
//
//  Created by mirror on 13-12-6.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

// 高德地图key
static NSString*const MapAPIKey = @"80365b2e271c11b37f3b82f85e0c53aa";

@interface CPMapUtil : NSObject
+ (MAMapView *)sharedMapView;
+ (AMapSearchAPI *)sharedMapSearchAPI;
@end
