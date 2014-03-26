//
//  CPFamilyReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFamilyReadViewController.h"
#import "CPFamily.h"
#import "CPFamilyMember.h"
#import "CPFamilyMemberReadViewController.h"
#import "CPReadMapViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>

// 生日
static NSString* const CP_DATE_TITLE_NULL = @"未定义";

// 车辆
static NSString* const CP_FAMILY_CAR_TITLE_0 = @"无";
static NSString* const CP_FAMILY_CAR_TITLE_1 = @"1辆";
static NSString* const CP_FAMILY_CAR_TITLE_2 = @"2辆";
static NSString* const CP_FAMILY_CAR_TITLE_3 = @"3辆";
static NSString* const CP_FAMILY_CAR_TITLE_4 = @"4辆及以上";
#define CP_FAMILY_CAR_TITLE_ITEM @[CP_FAMILY_CAR_TITLE_0,CP_FAMILY_CAR_TITLE_1,CP_FAMILY_CAR_TITLE_2,CP_FAMILY_CAR_TITLE_3,CP_FAMILY_CAR_TITLE_4]

// 房产
static NSString* const CP_FAMILY_ESTATE_TITLE_0 = @"无";
static NSString* const CP_FAMILY_ESTATE_TITLE_1 = @"1套";
static NSString* const CP_FAMILY_ESTATE_TITLE_2 = @"2套";
static NSString* const CP_FAMILY_ESTATE_TITLE_3 = @"3套";
static NSString* const CP_FAMILY_ESTATE_TITLE_4 = @"4套及以上";
#define CP_FAMILY_ESTATE_TITLE_ITEM @[CP_FAMILY_ESTATE_TITLE_0,CP_FAMILY_ESTATE_TITLE_1,CP_FAMILY_ESTATE_TITLE_2,CP_FAMILY_ESTATE_TITLE_3,CP_FAMILY_ESTATE_TITLE_4]

// 婚姻
static NSString* const CP_FAMILY_MARRIAGE_TITLE_NO = @"未婚";
static NSString* const CP_FAMILY_MARRIAGE_TITLE_YES = @"已婚";
static NSString* const CP_FAMILY_MARRIAGE_TITLE_DIVORCED = @"离异";
static NSString* const CP_FAMILY_MARRIAGE_TITLE_WIDOWED = @"丧偶";
#define CP_FAMILY_MARRIAGE_TITLE_ITEM @[CP_FAMILY_MARRIAGE_TITLE_NO,CP_FAMILY_MARRIAGE_TITLE_YES,CP_FAMILY_MARRIAGE_TITLE_DIVORCED,CP_FAMILY_MARRIAGE_TITLE_WIDOWED]


@interface CPFamilyReadViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *carLabel;
@property (weak, nonatomic) IBOutlet UILabel *estateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UILabel *marriageLabel;
@property (weak, nonatomic) IBOutlet UILabel *spouseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spousePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *spouseBirthdayLabel;
@property (weak, nonatomic) IBOutlet UIView *childLayoutView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *childLayoutViewHeight;

@property(nonatomic) CPFamily* family;
@property(nonatomic) NSMutableArray* familyMemberArray;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPFamilyReadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPFamily class]) object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            [self loadDB];
        } completionBlock:^{
            // 更新UI
            [self updateUI];
            // hud消失
            [hud removeFromSuperview];
        }];
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
    if ([segue.identifier isEqualToString:@"cp_segue_family_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
        [controller setValue:self.family.cp_uuid forKey:@"familyUUID"];
    }
}
#pragma mark - private
-(void) loadDB{
    if (self.contactsUUID) {
        self.family = [[CPDB getLKDBHelperByUser] searchSingle:[CPFamily class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil];
        self.familyMemberArray = [[CPDB getLKDBHelperByUser] search:[CPFamilyMember class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 车辆
    if (self.family.cp_car) {
        self.carLabel.text = CP_FAMILY_CAR_TITLE_ITEM[self.family.cp_car.integerValue];
    }else{
        self.carLabel.text = CP_FAMILY_CAR_TITLE_ITEM[0];
    }
    // 房产
    if (self.family.cp_estate) {
        self.estateLabel.text = CP_FAMILY_ESTATE_TITLE_ITEM[self.family.cp_estate.integerValue];
    }else{
        self.estateLabel.text = CP_FAMILY_ESTATE_TITLE_ITEM[0];
    }
    // 地址
    [self updateAddressUI];
    // 婚姻
    if (self.family.cp_marriage_status) {
        self.marriageLabel.text = CP_FAMILY_MARRIAGE_TITLE_ITEM[self.family.cp_marriage_status.integerValue];
    }else{
        self.marriageLabel.text = CP_FAMILY_MARRIAGE_TITLE_ITEM[0];
    }
    // 爱人姓名
    if (self.family.cp_spouse_name) {
        self.spouseNameLabel.text = self.family.cp_spouse_name;
    }else{
        self.spouseNameLabel.text = @"";
    }
    // 爱人电话
    if (self.family.cp_spouse_phone) {
        self.spousePhoneNumberLabel.text = self.family.cp_spouse_phone;
    }else{
        self.spousePhoneNumberLabel.text = @"";
    }
    // 爱人生日
    if (self.family.cp_spouse_birthday) {
        self.spouseBirthdayLabel.text = self.family.cp_spouse_birthday;
    }else{
        self.spouseBirthdayLabel.text = CP_DATE_TITLE_NULL;
    }
    // 孩子
    [self updateFamilyMemberUI];
}
-(void) updateAddressUI{
    if (self.family.cp_address_name) {
        self.addressLabel.text = self.family.cp_address_name;
    }else{
        self.addressLabel.text = @"";
    }
    if (self.family.cp_invain && self.family.cp_invain.boolValue) {
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_0] forState:UIControlStateNormal];
    }else{
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_1] forState:UIControlStateNormal];
    }
}
-(void) updateFamilyMemberUI{
    for(UIView *subv in [self.childLayoutView subviews])
    {
        [subv removeFromSuperview];
    }
    if (self.family.cp_member_status && self.family.cp_member_status.boolValue) {
        if (self.familyMemberArray && self.familyMemberArray.count>0) {
            for (CPFamilyMember* fm in self.familyMemberArray) {
                NSUInteger index = [self.familyMemberArray indexOfObject:fm];
                CPFamilyMemberReadViewController* fmrc = [self familyMemberReadViewControllerWithIndex:index familyMember:fm];
                [self.childLayoutView addSubview:fmrc.view];
            }
        }
    }
    [self layoutChildLayoutView];
}
-(CPFamilyMemberReadViewController*) familyMemberReadViewControllerWithIndex:(NSUInteger) index familyMember:(CPFamilyMember*)fm{
    CPFamilyMemberReadViewController * fmrc = [[CPFamilyMemberReadViewController alloc] initWithNibName:CP_RESOURCE_XIB_FAMILY_MEMBER_READ bundle:nil];
    [fmrc loadView];
    // 姓名
    if (fm.cp_name) {
        fmrc.familyMemberNameLabel.text = fm.cp_name;
    }else{
        fmrc.familyMemberNameLabel.text = @"";
    }
    // 性别
    if (fm.cp_sex && fm.cp_sex.boolValue) {
        fmrc.familySexLabel.text = @"男";
    }else{
        fmrc.familySexLabel.text = @"女";
    }
    // 生日
    if (fm.cp_birthday) {
        fmrc.familyBirthdayLabel.text = fm.cp_birthday;
    }else{
        fmrc.familyBirthdayLabel.text = CP_DATE_TITLE_NULL;
    }
    return fmrc;
}
- (void)layoutChildLayoutView{
    CGFloat height = 0;
    for (UIView* view in self.childLayoutView.subviews) {
        CGRect frame = view.frame;
        frame.origin.y = height;
        height += frame.size.height;
        view.frame = frame;
    }
    // layoutview高度
    [self.childLayoutView removeConstraint:self.childLayoutViewHeight];
    self.childLayoutViewHeight = [NSLayoutConstraint constraintWithItem:self.childLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.childLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:height];
    [self.childLayoutView addConstraint:self.childLayoutViewHeight];
    [self.view setNeedsLayout];
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - IBAction
- (IBAction)addressButtonClick:(id)sender {
    [[TWMessageBarManager sharedInstance] hideAll];
    if (!self.family.cp_invain || !self.family.cp_invain.boolValue) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                       description:@"请在编辑页面为地图选点"
                                                              type:TWMessageBarMessageTypeInfo];
        return;
    }
    CPReadMapViewController* map = [[CPReadMapViewController alloc] initWithNibName:nil bundle:nil];
    map.name = self.family.cp_address_name;
    map.longitude = self.family.cp_longitude;
    map.latitude = self.family.cp_latitude;
    [self.navigationController pushViewController:map animated:YES];
}
@end
