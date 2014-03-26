//
//  CPAccountViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-19.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPAccountViewController.h"
#import <Masonry.h>
#import "CPLoginViewController.h"
#import "CPBindSafetyPhoneNumberViewController.h"
#import <TWMessageBarManager.h>
#import "CPNavigationController.h"
#import "CPBindSafetyEmailViewController.h"
#import "CPResetPasswordViewController.h"

static NSString* CP_NOT_LOGIN_TITLE = @"未登录状态";
static NSString* CP_LOGIN_TITLE = @"用户名";
static NSString* CP_NOT_LOGIN_BUTTON_TITLE = @"登录";
static NSString* CP_LOGIN_BUTTON_TITLE = @"清除数据";

static NSString* CP_NO_PHONE_TITLE = @"无";
static NSString* CP_NO_EMAIL_TITLE = @"无";

@interface CPAccountViewController ()

@property (weak, nonatomic) IBOutlet UILabel *accountTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cleanDataWarningLabel;
@property (weak, nonatomic) IBOutlet UIButton *accountButton;
@property (weak, nonatomic) IBOutlet UIView *loginContentLayoutView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberSettingLayoutView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIView *emailSettingLayoutView;

@end

@implementation CPAccountViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self updateUI];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (CPUserName) {
        // 登录状态下,请求&刷新信息
        [CPServer requestSafetyPhoneNumberAndEmailWithBlock:^(BOOL success, NSString *phoneNumber, NSString *email, NSString *message) {
            if (success) {
                if (![CPSafetyPhoneNumber isEqualToString:phoneNumber] || ![CPSafetyEmail isEqualToString:email]) {
                    CPLogInfo(@"更新安全手机号:%@->%@,安全邮箱:%@->%@",CPSafetyPhoneNumber,phoneNumber,CPSafetyEmail,email);
                    CPSetSafetyPhoneNumber(phoneNumber);
                    CPSetSafetyEmail(email);
                    [self updateUI];
                }
            }
        }];
    }
}

#pragma mark - private
-(void) updateUI{
    if (CPUserName) {
        // 登录了
        self.accountTitleLabel.text = CP_LOGIN_TITLE;
        self.accountLabel.hidden = NO;
        self.accountLabel.text = CPUserName;
        self.cleanDataWarningLabel.hidden = NO;
        [self.accountButton setTitle:CP_LOGIN_BUTTON_TITLE forState:UIControlStateNormal];
        [self.accountButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.accountButton addTarget:self action:@selector(cleanData:) forControlEvents:UIControlEventTouchUpInside];
        self.loginContentLayoutView.hidden = NO;
        [self.loginContentLayoutView.subviews setValue:@NO forKeyPath:@"hidden"];
        if (CPSafetyPhoneNumber) {
            // 有电话
            self.phoneNumberLabel.text = CPSafetyPhoneNumber;
            self.phoneNumberSettingLayoutView.hidden = YES;
            [self.phoneNumberSettingLayoutView.subviews setValue:@YES forKeyPath:@"hidden"];
            [self.phoneNumberSettingLayoutView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(0));
            }];
        }else{
            // 无电话
            self.phoneNumberLabel.text = CP_NO_PHONE_TITLE;
            self.phoneNumberSettingLayoutView.hidden = NO;
            [self.phoneNumberSettingLayoutView.subviews setValue:@NO forKeyPath:@"hidden"];
            [self.phoneNumberSettingLayoutView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(44));
            }];
        }
        
        if (CPSafetyEmail) {
            // 有email
            self.emailLabel.text = CPSafetyEmail;
            self.emailSettingLayoutView.hidden = YES;
            [self.emailSettingLayoutView.subviews setValue:@YES forKeyPath:@"hidden"];
            [self.emailSettingLayoutView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(0));
            }];
        }else{
            // 无email
            self.emailLabel.text = CP_NO_EMAIL_TITLE;
            self.emailSettingLayoutView.hidden = NO;
            [self.emailSettingLayoutView.subviews setValue:@NO forKeyPath:@"hidden"];
            [self.emailSettingLayoutView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(44));
            }];
        }
        
    }else{
        // 未登录
        self.accountTitleLabel.text = CP_NOT_LOGIN_TITLE;
        self.accountLabel.hidden = YES;
        self.accountLabel.text = nil;
        self.cleanDataWarningLabel.hidden = YES;
        [self.accountButton setTitle:CP_NOT_LOGIN_BUTTON_TITLE forState:UIControlStateNormal];
        [self.accountButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.accountButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        self.loginContentLayoutView.hidden = YES;
        [self.loginContentLayoutView.subviews setValue:@YES forKeyPath:@"hidden"];
    }
}
#pragma mark - Action
- (void) login:(id)sender{
    CPLoginViewController* loginViewController = [[CPLoginViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:loginViewController animated:YES completion:nil];
}
- (void)cleanData:(id)sender {
    CPLogInfo(@"注销 & 清除数据");
    [CPServer logoutAndCleanData];
    // 取消现有提示
    [[TWMessageBarManager sharedInstance] hideAll];
    // 提示
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                   description:@"注销成功"
                                                          type:TWMessageBarMessageTypeSuccess];
    // 刷新页面
    [self updateUI];
}
#pragma mark - IBAction
- (IBAction)createPhoneNumber:(id)sender {
    CPBindSafetyPhoneNumberViewController* bindSafetyPhoneNumberViewController = [[CPBindSafetyPhoneNumberViewController alloc] initWithNibName:nil bundle:nil];
    CPNavigationController* navigationController = [[CPNavigationController alloc] initWithRootViewController:bindSafetyPhoneNumberViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
- (IBAction)createEmail:(id)sender {
    CPBindSafetyEmailViewController* bindSafetyEmailViewController = [[CPBindSafetyEmailViewController alloc] initWithNibName:nil bundle:nil];
    CPNavigationController* navigationController = [[CPNavigationController alloc] initWithRootViewController:bindSafetyEmailViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
- (IBAction)changePassword:(id)sender {
    CPResetPasswordViewController* resetPasswordViewController = [[CPResetPasswordViewController alloc] initWithNibName:nil bundle:nil];
    CPNavigationController* navigationController = [[CPNavigationController alloc] initWithRootViewController:resetPasswordViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
