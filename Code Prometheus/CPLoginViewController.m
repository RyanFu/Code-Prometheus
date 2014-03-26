//
//  CPLoginViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-20.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPLoginViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>
#import "CPFindPasswordViewController.h"
#import "CPNavigationController.h"
#import "CPRegisterViewController.h"

@interface CPLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CPLoginViewController

- (IBAction)loginButtonClick:(id)sender {
    // 取消现有提示
    [[TWMessageBarManager sharedInstance] hideAll];
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];

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
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
            [hud hide:YES];
        }
    }];
}
- (IBAction)findPassword:(id)sender {
    CPFindPasswordViewController* findPasswordViewController = [[CPFindPasswordViewController alloc] initWithNibName:nil bundle:nil];
    
    CPNavigationController* navigationController = [[CPNavigationController alloc] initWithRootViewController:findPasswordViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
- (IBAction)register:(id)sender {
    CPRegisterViewController* registerViewController = [[CPRegisterViewController alloc] initWithNibName:nil bundle:nil];
    registerViewController.loginViewController = self;
    [self presentViewController:registerViewController animated:YES completion:nil];
}
- (IBAction)try:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
