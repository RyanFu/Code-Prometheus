//
//  CPCompanyEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPCompanyEditViewController.h"
#import "CPCompany.h"
#import <PopoverView.h>
#import "CPEditMapViewController.h"

// 年收入
static NSString* const CP_COMPANY_INCOME_TITLE_0 = @"10万以下";
static NSString* const CP_COMPANY_INCOME_TITLE_1 = @"10——20万";
static NSString* const CP_COMPANY_INCOME_TITLE_2 = @"20——50万";
static NSString* const CP_COMPANY_INCOME_TITLE_3 = @"50——100万";
static NSString* const CP_COMPANY_INCOME_TITLE_4 = @"100万以上";
#define CP_COMPANY_INCOME_TITLE_ITEM @[CP_COMPANY_INCOME_TITLE_0,CP_COMPANY_INCOME_TITLE_1,CP_COMPANY_INCOME_TITLE_2,CP_COMPANY_INCOME_TITLE_3,CP_COMPANY_INCOME_TITLE_4]

// 公司职员数
static NSString* const CP_COMPANY_WORKER_AMOUNT_TITLE_0 = @"50人以下";
static NSString* const CP_COMPANY_WORKER_AMOUNT_TITLE_1 = @"50——99人";
static NSString* const CP_COMPANY_WORKER_AMOUNT_TITLE_2 = @"100——499人";
static NSString* const CP_COMPANY_WORKER_AMOUNT_TITLE_3 = @"500——999人";
static NSString* const CP_COMPANY_WORKER_AMOUNT_TITLE_4 = @"1000——1999人";
static NSString* const CP_COMPANY_WORKER_AMOUNT_TITLE_5 = @"2000人以上";
#define CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM @[CP_COMPANY_WORKER_AMOUNT_TITLE_0,CP_COMPANY_WORKER_AMOUNT_TITLE_1,CP_COMPANY_WORKER_AMOUNT_TITLE_2,CP_COMPANY_WORKER_AMOUNT_TITLE_3,CP_COMPANY_WORKER_AMOUNT_TITLE_4,CP_COMPANY_WORKER_AMOUNT_TITLE_5]

// 弹框tag
typedef NS_ENUM(NSInteger, CP_COMPANY_POPOVER_TAG) {
    CP_COMPANY_POPOVER_TAG_INCOME,
    CP_COMPANY_POPOVER_TAG_WORKER_AMOUNT
};

@interface CPCompanyEditViewController ()<PopoverViewDelegate,CPEditMapDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *isOnPositionSwitch;
@property (weak, nonatomic) IBOutlet UIButton *incomeButton;
@property (weak, nonatomic) IBOutlet UITextField *industryTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *postTextField;
@property (weak, nonatomic) IBOutlet UITextField *postDescriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;
@property (weak, nonatomic) IBOutlet UIButton *workerAmountButton;

@property(nonatomic) CPCompany* company;
// 弹窗
@property (nonatomic) PopoverView* popoverView;
@end

@implementation CPCompanyEditViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self loadDB];
    // 更新UI
    [self updateUI];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!CP_IS_IOS7_AND_UP) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
#pragma mark - private
-(void) loadDB{
    if (!self.companyUUID) {
        self.company = [CPCompany newAdaptDBWith:self.contactsUUID];
    }else {
        self.company = [[CPDB getLKDBHelperByUser] searchSingle:[CPCompany class] where:@{@"cp_uuid":self.companyUUID} orderBy:nil];
    }
}
-(void) updateUI{
    // 是否在职
    if (self.company.cp_on_position && !self.company.cp_on_position.boolValue) {
        self.isOnPositionSwitch.on = NO;
    }else{
        self.isOnPositionSwitch.on = YES;
    }
    // 年收入
    if (self.company.cp_income) {
        [self.incomeButton setTitle:CP_COMPANY_INCOME_TITLE_ITEM[self.company.cp_income.integerValue] forState:UIControlStateNormal];
    }else{
        [self.incomeButton setTitle:CP_COMPANY_INCOME_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 行业
    if (self.company.cp_industry) {
        self.industryTextField.text = self.company.cp_industry;
    }else{
        self.industryTextField.text = @"";
    }
    // 公司名称
    if (self.company.cp_name) {
        self.nameTextField.text = self.company.cp_name;
    }else{
        self.nameTextField.text = @"";
    }
    // 职位
    if (self.company.cp_post) {
        self.postTextField.text = self.company.cp_post;
    }else{
        self.postTextField.text = @"";
    }
    // 职务内容
    if (self.company.cp_post_description) {
        self.postDescriptionTextField.text = self.company.cp_post_description;
    }else{
        self.postDescriptionTextField.text = @"";
    }
    // 地址
    [self updateAddressUI];
    
    // 邮编
    if (self.company.cp_zip) {
        self.zipTextField.text = self.company.cp_zip;
    }else{
        self.zipTextField.text = @"";
    }
    
    // 公司职员数
    if (self.company.cp_worker_amount) {
        [self.workerAmountButton setTitle:CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM[self.company.cp_worker_amount.integerValue] forState:UIControlStateNormal];
    }else{
        [self.workerAmountButton setTitle:CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    
}

-(void) updateAddressUI{
    if (self.company.cp_address_name) {
        self.addressNameTextField.text = self.company.cp_address_name;
    }else{
        self.addressNameTextField.text = @"";
    }
    if (self.company.cp_invain && self.company.cp_invain.boolValue) {
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_0] forState:UIControlStateNormal];
    }else{
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_1] forState:UIControlStateNormal];
    }
}

#pragma mark - IBAction
- (IBAction)saveCompany:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    self.company.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.companyUUID) {
        // 新增公司
        [[CPDB getLKDBHelperByUser] insertToDB:self.company];
        [self.navigationController popViewControllerAnimated:NO];
    } else{
        // 修改公司
        [[CPDB getLKDBHelperByUser] updateToDB:self.company where:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
-(IBAction)cancelButtonClick:(id)sender{
    // 返回上个视图
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)isOnPositionSwitchChange:(UISwitch *)sender {
    self.company.cp_on_position = @(sender.on);
}

- (IBAction)incomeButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_COMPANY_INCOME_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_COMPANY_POPOVER_TAG_INCOME;
}
- (IBAction)industryTextFieldChange:(UITextField*)sender {
    self.company.cp_industry = sender.text;
}
- (IBAction)nameTextFieldChange:(UITextField*)sender {
    self.company.cp_name = sender.text;
}
- (IBAction)postTextFieldChange:(UITextField*)sender {
    self.company.cp_post = sender.text;
}
- (IBAction)postDescriptionTextFieldChange:(UITextField*)sender {
    self.company.cp_post_description = sender.text;
}
- (IBAction)addressTextFieldChange:(UITextField*)sender {
    if ([self.company.cp_address_name isEqualToString:sender.text]) {
        return;
    }
    self.company.cp_address_name = sender.text;
    self.company.cp_longitude = nil;
    self.company.cp_latitude = nil;
    self.company.cp_zoom = nil;
    self.company.cp_invain = @(0);
    [self updateAddressUI];
}
- (IBAction)zipTextFieldChange:(UITextField*)sender {
    self.company.cp_zip = sender.text;
}
- (IBAction)workerAmountButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_COMPANY_POPOVER_TAG_WORKER_AMOUNT;
}

- (IBAction)addressButtonClick:(id)sender {
    CPEditMapViewController* map = [[CPEditMapViewController alloc] initWithNibName:CP_RESOURCE_XIB_MAP_EDIT bundle:nil];
    map.invain = self.company.cp_invain;
    map.name = self.company.cp_address_name;
    map.longitude = self.company.cp_longitude;
    map.latitude = self.company.cp_latitude;
    map.delegate = self;
    [self.navigationController pushViewController:map animated:YES];
}

#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    switch (popoverView.tag) {
        case CP_COMPANY_POPOVER_TAG_INCOME:{
            self.company.cp_income = @(index);
            [self.incomeButton setTitle:CP_COMPANY_INCOME_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        case CP_COMPANY_POPOVER_TAG_WORKER_AMOUNT:{
            self.company.cp_worker_amount = @(index);
            [self.workerAmountButton setTitle:CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}

#pragma mark - CPEditMapDelegate
-(void) saveAddress:(CPEditMapViewController*)controller name:(NSString*)name longitude:(NSString*)longitude latitude:(NSString*)latitude{
    CPLogInfo(@"%@,更新地址",self);
    self.company.cp_invain = @(1);
    self.company.cp_address_name = name;
    self.company.cp_longitude = longitude;
    self.company.cp_latitude = latitude;
    [self updateAddressUI];
}
@end
