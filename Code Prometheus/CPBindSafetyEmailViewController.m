//
//  CPBindSafetyEmailViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPBindSafetyEmailViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>

@interface CPBindSafetyEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation CPBindSafetyEmailViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"设置安全邮箱";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back:)];
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)verify:(id)sender {
    // 取消现有提示
    [[TWMessageBarManager sharedInstance] hideAll];
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    
    [CPServer bindEmail:self.emailTextField.text block:^(BOOL success, NSString *message) {
        if (success) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                           description:@"请进入邮箱确认"
                                                                  type:TWMessageBarMessageTypeSuccess];
            [hud hide:YES];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
            [hud hide:YES];
        }
    }];
}
@end
