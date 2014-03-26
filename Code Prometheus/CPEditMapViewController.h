//
//  CPEditMapViewController.h
//  Code Prometheus
//
//  Created by mirror on 13-12-6.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMapViewController.h"

//// 保存地址 通知 NAME
//static NSString*const CP_NOTIFICATION_NAME_MAP_SAVE_ADDRESS = @"CP_NOTIFICATION_NAME_MAP_SAVE_ADDRESS";
//
//// KEY
//static NSString*const CP_MAP_ADDRESS_KEY_NAME = @"CP_MAP_ADDRESS_KEY_NAME";
//static NSString*const CP_MAP_ADDRESS_KEY_LONGITUDE = @"CP_MAP_ADDRESS_KEY_LONGITUDE";
//static NSString*const CP_MAP_ADDRESS_KEY_LATITUDE = @"CP_MAP_ADDRESS_KEY_LATITUDE";

@class CPEditMapViewController;

@protocol CPEditMapDelegate <NSObject>
-(void) saveAddress:(CPEditMapViewController*)controller name:(NSString*)name longitude:(NSString*)longitude latitude:(NSString*)latitude;
@end


@interface CPEditMapViewController : BaseMapViewController
//@property(nonatomic) NSString* tag;
@property(nonatomic) NSNumber* invain;
@property(nonatomic) NSString* name;
@property(nonatomic) NSString* longitude;
@property(nonatomic) NSString* latitude;
@property(nonatomic,weak) id<CPEditMapDelegate> delegate;
@end
