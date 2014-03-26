//
//  CPContactsDetailViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-28.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPContactsDetailViewController.h"
#import "CPContacts.h"
#import <PopoverView.h>

@interface CPContactsDetailViewController ()<PopoverViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *portraitButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;

@property(nonatomic) CPContacts* contacts;

// 弹窗
@property (nonatomic) PopoverView* popoverView;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end


#warning 程序外短信,email 可以换成程序内
@implementation CPContactsDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPContacts class]) object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self loadContacts];
        [self updateUI];
        self.dirty = NO;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_info"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_trace"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_policy"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_family"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_company"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_organization"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    //    if ([segue.identifier isEqualToString:@"cp_segue_detail_2_other"])
    //    {
    //        id controller = segue.destinationViewController;
    //        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    //    }
    id controller = segue.destinationViewController;
    [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - IBAction
#warning 如果电话号码里有非法符号，能否拨号,短信,email？
-(IBAction)telAction:(UIButton*)sender{
    NSString *number = self.contacts.cp_phone_number;
    if (number) {
        NSArray* numbers = [number componentsSeparatedByString:@" "];
        if (numbers.count>1) {
            self.popoverView = [PopoverView showPopoverAtPoint:[sender center] inView:[sender superview] withStringArray:numbers delegate:self];
            self.popoverView.tag = 0;
            return;
        }else if (numbers.count ==1){
            NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",numbers[0]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
            return;
        }
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请完善手机号" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alert show];
}
#warning 可以做成程序内发短信,邮件
-(IBAction)smsAction:(UIButton*)sender{
    NSString *number = self.contacts.cp_phone_number;
    if (number) {
        NSArray* numbers = [number componentsSeparatedByString:@" "];
        if (numbers.count>1) {
            self.popoverView = [PopoverView showPopoverAtPoint:[sender center] inView:[sender superview] withStringArray:numbers delegate:self];
            self.popoverView.tag = 1;
            return;
        }else if (numbers.count ==1){
            NSString *num = [[NSString alloc] initWithFormat:@"sms://%@",numbers[0]];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:num]];
            return;
        }
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请完善手机号" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alert show];
}
-(IBAction)emailAction:(UIButton*)sender{
    NSString *email = self.contacts.cp_email;
    if (!email) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请完善邮箱" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSMutableString *mailUrl = [[NSMutableString alloc]init];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject:email];
    [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
    NSString* emailString = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:emailString]];
}

#pragma mark - private
-(void) loadContacts{
    if (!self.contactsUUID) {
        self.contacts = [CPContacts newAdaptDB];
    }else {
        self.contacts = [[CPDB getLKDBHelperByUser] searchSingle:[CPContacts class] where:@{@"cp_uuid":self.contactsUUID} orderBy:nil];
    }
}
-(void) updateUI{
    self.nameLable.text = self.contacts.cp_name;
}
#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    switch (popoverView.tag) {
        case 0:{
            // 电话
            NSArray* numbers = [self.contacts.cp_phone_number componentsSeparatedByString:@" "];
            NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",numbers[index]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
            break;
        }
        case 1:{
            // 短信
            NSArray* numbers = [self.contacts.cp_phone_number componentsSeparatedByString:@" "];
            NSString *num = [[NSString alloc] initWithFormat:@"sms://%@",numbers[index]];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:num]];
            break;
        }
        default:
            break;
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}
@end
