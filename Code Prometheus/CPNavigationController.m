//
//  CPNavigationController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-21.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPNavigationController.h"

@interface CPNavigationController ()

@end

@implementation CPNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    self.navigationBar.titleTextAttributes = dict;
	if(CP_IS_IOS7_AND_UP)
    {
        // iOS7
        // 颜色
        self.navigationBar.translucent=NO;
        self.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];

//        [self.navigationItem.backBarButtonItem setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_NAVIGATION_BACK] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    else
    {
        // older
        // 颜色
        self.navigationBar.tintColor = [UIColor colorWithRed:0.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    }
}
@end
