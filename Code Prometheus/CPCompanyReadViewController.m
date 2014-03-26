//
//  CPCompanyReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPCompanyReadViewController.h"
#import "CPCompany.h"
#import "CPReadMapViewController.h"
#import <TWMessageBarManager.h>

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


@interface CPCompanyReadViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *isOnPositionLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *industryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;
@property (weak, nonatomic) IBOutlet UILabel *workerAmountLabel;


@property(nonatomic) CPCompany* company;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPCompanyReadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPCompany class]) object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self loadDB];
        [self updateUI];
        self.dirty = NO;
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!CP_IS_IOS7_AND_UP) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_company_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
        [controller setValue:self.company.cp_uuid forKey:@"companyUUID"];
    }
}
#pragma mark - private
-(void) loadDB{
    if (self.contactsUUID) {
        self.company = [[CPDB getLKDBHelperByUser] searchSingle:[CPCompany class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil];
    }
}
-(void) updateUI{
    // 是否在职
    if (self.company.cp_on_position && !self.company.cp_on_position.boolValue) {
        self.isOnPositionLabel.text = @"否";
    }else{
        self.isOnPositionLabel.text = @"是";
    }
    // 年收入
    if (self.company.cp_income) {
        self.incomeLabel.text = CP_COMPANY_INCOME_TITLE_ITEM[self.company.cp_income.integerValue];
    }else{
        self.incomeLabel.text = CP_COMPANY_INCOME_TITLE_ITEM[0];
    }
    // 行业
    if (self.company.cp_industry) {
        self.industryLabel.text = self.company.cp_industry;
    }else{
        self.industryLabel.text = @"";
    }
    // 公司名称
    if (self.company.cp_name) {
        self.nameLabel.text = self.company.cp_name;
    }else{
        self.nameLabel.text = @"";
    }
    // 职位
    if (self.company.cp_post) {
        self.postLabel.text = self.company.cp_post;
    }else{
        self.postLabel.text = @"";
    }
    // 职务内容
    if (self.company.cp_post_description) {
        self.postDescriptionLabel.text = self.company.cp_post_description;
    }else{
        self.postDescriptionLabel.text = @"";
    }
    // 地址
    [self updateAddressUI];
    
    // 邮编
    if (self.company.cp_zip) {
        self.zipLabel.text = self.company.cp_zip;
    }else{
        self.zipLabel.text = @"";
    }
    
    // 公司职员数
    if (self.company.cp_worker_amount) {
        self.workerAmountLabel.text = CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM[self.company.cp_worker_amount.integerValue];
    }else{
        self.workerAmountLabel.text = CP_COMPANY_WORKER_AMOUNT_TITLE_ITEM[0];
    }
    
}
-(void) updateAddressUI{
    if (self.company.cp_address_name) {
        self.addressNameLabel.text = self.company.cp_address_name;
    }else{
        self.addressNameLabel.text = @"";
    }
    if (self.company.cp_invain && self.company.cp_invain.boolValue) {
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_0] forState:UIControlStateNormal];
    }else{
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_1] forState:UIControlStateNormal];
    }
}

#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - IBAction
- (IBAction)addressButtonClick:(id)sender {
    [[TWMessageBarManager sharedInstance] hideAll];
    if (!self.company.cp_invain || !self.company.cp_invain.boolValue) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                       description:@"请在编辑页面为地图选点"
                                                              type:TWMessageBarMessageTypeInfo];
        return;
    }
    CPReadMapViewController* map = [[CPReadMapViewController alloc] initWithNibName:nil bundle:nil];
    map.name = self.company.cp_address_name;
    map.longitude = self.company.cp_longitude;
    map.latitude = self.company.cp_latitude;
    [self.navigationController pushViewController:map animated:YES];
}

@end
