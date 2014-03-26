//
//  CPSyncSettingViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-26.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPSyncSettingViewController.h"

@interface CPSyncSettingViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *syncOnlyWifiSwitch;

@end

@implementation CPSyncSettingViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"通用设置";
    self.syncOnlyWifiSwitch.on = CPSyncOnlyWifi;
}

- (IBAction)syncOnlyWifiSwitchValueChange:(UISwitch*)sender {
    CPLogInfo(@"设置仅在wifi下同步:%@",sender.on?@"YES":@"NO");
    CPSetSyncOnlyWifi(sender.on);
}

@end
