//
//  CPFindPasswordByEmailViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-24.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFindPasswordByEmailViewController.h"
#import <TWMessageBarManager.h>
#import <MBProgressHUD.h>

@interface CPFindPasswordByEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation CPFindPasswordByEmailViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"返回"
                                style:UIBarButtonItemStyleBordered
                                target:nil
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem= btnBack;
    self.navigationItem.title = @"通过安全邮箱找回密码";
}
- (IBAction)confirm:(id)sender {
    // 取消现有提示
    [[TWMessageBarManager sharedInstance] hideAll];
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    
    [CPServer resetPasswordByEmail:self.emailTextField.text block:^(BOOL success, NSString *message) {
        if (success) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                           description:@"请进入邮箱重设密码"
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
