//
//  CPRegisterViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPRegisterViewController.h"
#import <TWMessageBarManager.h>
#import <MBProgressHUD.h>

@interface CPRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;

@end

@implementation CPRegisterViewController
- (IBAction)registerUser:(id)sender {
    // 取消现有提示
    [[TWMessageBarManager sharedInstance] hideAll];
    // 确认密码
    if (![self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                       description:@"两次输入的密码不同,请确认"
                                                              type:TWMessageBarMessageTypeError];
        return;
    }
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];

    [CPServer registerWithUserName:self.userNameTextField.text password:self.passwordTextField.text referralInfoID:@"" block:^(BOOL success, NSString *message) {
        if (success) {
            // 提示
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK" description:@"注册成功" type:TWMessageBarMessageTypeSuccess];
            // 登录
            [CPServer loginWithUserName:self.userNameTextField.text password:self.passwordTextField.text block:^(BOOL success, NSString *message) {
                if (success) {
                    // 数据库操作
                    [CPDB creatDBFromOFFLineDB];
                    // 同步
                    [CPServer sync];
                    
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                                   description:@"登录成功"
                                                                          type:TWMessageBarMessageTypeSuccess];
                    [hud hide:YES];
                    // 返回
                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"下一步"             description:@"请登录"
                        type:TWMessageBarMessageTypeInfo];
                    [hud hide:YES];
                    // 返回
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }else{
            // 提示
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
            [hud hide:YES];
        }
    }];
}
- (IBAction)try:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
