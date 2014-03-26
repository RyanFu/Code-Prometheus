//
//  CPTabBarController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-22.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPTabBarController.h"

@interface CPTabBarController ()

@end

@implementation CPTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTintColor:[UIColor whiteColor]];
    // 人脉
    [self.tabBar.items[0] setFinishedSelectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_CONTACTS_H] withFinishedUnselectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_CONTACTS]];
    ((UITabBarItem*)self.tabBar.items[0]).imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    // 日程
    [self.tabBar.items[1] setFinishedSelectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_SCHEDULE_H] withFinishedUnselectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_SCHEDULE]];
    ((UITabBarItem*)self.tabBar.items[1]).imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    // 地图
    [self.tabBar.items[2] setFinishedSelectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_MAP_H] withFinishedUnselectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_MAP]];
    ((UITabBarItem*)self.tabBar.items[2]).imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    // 工具
    [self.tabBar.items[3] setFinishedSelectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_TOOLS_H] withFinishedUnselectedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TAB_TOOLS]];
    ((UITabBarItem*)self.tabBar.items[3]).imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    if (CP_IS_IOS7_AND_UP) {
        
    }else{
        
    }
}

@end
