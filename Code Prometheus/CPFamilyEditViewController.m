//
//  CPFamilyEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFamilyEditViewController.h"
#import "CPFamily.h"
#import <TDDatePickerController.h>
#import <PopoverView.h>
#import "CPFamilyMember.h"
#import "CPFamilyMemberEditViewController.h"
#import "CPEditMapViewController.h"

static char CPAssociatedKeyTag;

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

// 弹框tag
typedef NS_ENUM(NSInteger, CP_FAMILY_POPOVER_TAG) {
    CP_FAMILY_POPOVER_TAG_CAR,
    CP_FAMILY_POPOVER_TAG_ESTATE,
    CP_FAMILY_POPOVER_TAG_MARRIAGE
};

@interface CPFamilyEditViewController ()<PopoverViewDelegate,CPEditMapDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *carButton;
@property (weak, nonatomic) IBOutlet UIButton *estateButton;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UIButton *marriageButton;
@property (weak, nonatomic) IBOutlet UITextField *spouseNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *spousePhoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *spouseBirthdayButton;
@property (weak, nonatomic) IBOutlet UISwitch *hasChildSwitch;
@property (weak, nonatomic) IBOutlet UIView *childLayoutView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *childLayoutViewHeight;

@property(nonatomic) CPFamily* family;
@property(nonatomic) NSMutableArray* familyMemberArray;

// 生日选择器
@property(nonatomic) TDDatePickerController* datePickerView;
// 弹窗
@property (nonatomic) PopoverView* popoverView;
// 生日格式
@property (nonatomic) NSDateFormatter* df;
@end

@implementation CPFamilyEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 日期格式化
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"yyyy-MM-dd"];

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
    if (!self.familyUUID) {
        self.family = [CPFamily newAdaptDBWith:self.contactsUUID];
        self.familyMemberArray = [NSMutableArray array];
    }else {
        self.family = [[CPDB getLKDBHelperByUser] searchSingle:[CPFamily class] where:@{@"cp_uuid":self.familyUUID} orderBy:nil];
        self.familyMemberArray = [[CPDB getLKDBHelperByUser] search:[CPFamilyMember class] where:@{@"cp_contact_uuid":self.family.cp_contact_uuid} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 车辆
    if (self.family.cp_car) {
        [self.carButton setTitle:CP_FAMILY_CAR_TITLE_ITEM[self.family.cp_car.integerValue] forState:UIControlStateNormal];
    }else{
        [self.carButton setTitle:CP_FAMILY_CAR_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 房产
    if (self.family.cp_estate) {
        [self.estateButton setTitle:CP_FAMILY_ESTATE_TITLE_ITEM[self.family.cp_estate.integerValue] forState:UIControlStateNormal];
    }else{
        [self.estateButton setTitle:CP_FAMILY_ESTATE_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 地址
    [self updateAddressUI];
    // 婚姻
    if (self.family.cp_marriage_status) {
        [self.marriageButton setTitle:CP_FAMILY_MARRIAGE_TITLE_ITEM[self.family.cp_marriage_status.integerValue] forState:UIControlStateNormal];
    }else{
        [self.marriageButton setTitle:CP_FAMILY_MARRIAGE_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 爱人姓名
    if (self.family.cp_spouse_name) {
        self.spouseNameTextField.text = self.family.cp_spouse_name;
    }else{
        self.spouseNameTextField.text = @"";
    }
    // 爱人电话
    if (self.family.cp_spouse_phone) {
        self.spousePhoneNumberTextField.text = self.family.cp_spouse_phone;
    }else{
        self.spousePhoneNumberTextField.text = @"";
    }
    // 爱人生日
    if (self.family.cp_spouse_birthday) {
        [self.spouseBirthdayButton setTitle:self.family.cp_spouse_birthday forState:UIControlStateNormal];
    }else{
        [self.spouseBirthdayButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    // 孩子
    [self updateFamilyMemberUI];
}
-(void) updateFamilyMemberUI{
    for(UIView *subv in [self.childLayoutView subviews])
    {
        [subv removeFromSuperview];
    }
    if (self.family.cp_member_status && self.family.cp_member_status.boolValue) {
        self.hasChildSwitch.on = YES;
        if (self.familyMemberArray && self.familyMemberArray.count>0) {
            for (CPFamilyMember* fm in self.familyMemberArray) {
                NSUInteger index = [self.familyMemberArray indexOfObject:fm];
                CPFamilyMemberEditViewController* fmec = [self familyMemberEditViewControllerWithIndex:index familyMember:fm];
                [self.childLayoutView addSubview:fmec.view];
            }
        }
    }else{
        self.hasChildSwitch.on = NO;
    }
    [self layoutChildLayoutView];
}
-(void) updateAddressUI{
    if (self.family.cp_address_name) {
        self.addressTextField.text = self.family.cp_address_name;
    }else{
        self.addressTextField.text = @"";
    }
    if (self.family.cp_invain && self.family.cp_invain.boolValue) {
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_0] forState:UIControlStateNormal];
    }else{
        [self.addressButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_1] forState:UIControlStateNormal];
    }
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
-(CPFamilyMemberEditViewController*) familyMemberEditViewControllerWithIndex:(NSUInteger) index familyMember:(CPFamilyMember*)fm{
    CPFamilyMemberEditViewController * fmec = [[CPFamilyMemberEditViewController alloc] initWithNibName:CP_RESOURCE_XIB_FAMILY_MEMBER_EDIT bundle:nil];
    [fmec loadView];
    // 姓名
    if (fm.cp_name) {
        fmec.familyMemberNameTextField.text = fm.cp_name;
    }else{
        fmec.familyMemberNameTextField.text = @"";
    }
    [fmec.familyMemberNameTextField addTarget:self action:@selector(familyMemberNameTextFieldChange:) forControlEvents:UIControlEventEditingDidEnd];
    fmec.familyMemberNameTextField.tag = index;
    // 按钮
    if (self.familyMemberArray.firstObject==fm) {
        [fmec.familyButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_ADD_0] forState:UIControlStateNormal];
        [fmec.familyButton addTarget:self action:@selector(familyMemberAddButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [fmec.familyButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_DELETE_0] forState:UIControlStateNormal];
        [fmec.familyButton addTarget:self action:@selector(familyMemberDeleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    fmec.familyButton.tag = index;
    // 性别
    if (fm.cp_sex && fm.cp_sex.boolValue) {
        fmec.familySegmentedControl.selectedSegmentIndex = 1;
    }else{
        fmec.familySegmentedControl.selectedSegmentIndex = 0;
    }
    [fmec.familySegmentedControl addTarget:self action:@selector(familyMemberSexSegmentedControlChange:) forControlEvents:UIControlEventValueChanged];
    fmec.familySegmentedControl.tag = index;
    // 生日
    if (fm.cp_birthday) {
        [fmec.familyBirthdayButton setTitle:fm.cp_birthday forState:UIControlStateNormal];
    }else{
        [fmec.familyBirthdayButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    [fmec.familyBirthdayButton addTarget:self action:@selector(familyMemberBirthdayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    fmec.familyBirthdayButton.tag = index;
    
    return fmec;
}

#pragma mark - IBAction
- (IBAction)saveFamily:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    self.family.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.familyUUID) {
        // 新增子女
        if (self.family.cp_member_status && self.family.cp_member_status.boolValue) {
            for (CPFamilyMember* fm in self.familyMemberArray) {
                [[CPDB getLKDBHelperByUser] insertToDB:fm];
            }
        }
        // 新增家庭
        [[CPDB getLKDBHelperByUser] insertToDB:self.family];
        [self.navigationController popViewControllerAnimated:NO];
    } else{
        // 修改子女
        NSMutableArray* familyMemberArrayInDB = [[CPDB getLKDBHelperByUser] search:[CPFamilyMember class] where:@{@"cp_contact_uuid":self.family.cp_contact_uuid} orderBy:nil offset:0 count:-1];
        if (self.family.cp_member_status && self.family.cp_member_status.boolValue) {
            // 删除子女
            for (CPFamilyMember* fm in familyMemberArrayInDB) {
                if ([self.familyMemberArray containsObject:fm]) {
                    continue;
                }
                [[CPDB getLKDBHelperByUser] deleteToDB:fm];
            }
            // 添加,修改子女
            for (CPFamilyMember* fm in self.familyMemberArray) {
                [[CPDB getLKDBHelperByUser] insertToDB:fm];
            }
        }else{
            // 删除全部子女
            for (CPFamilyMember* fm in familyMemberArrayInDB) {
                [[CPDB getLKDBHelperByUser] deleteToDB:fm];
            }
        }
        // 修改家庭
        [[CPDB getLKDBHelperByUser] updateToDB:self.family where:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
-(IBAction)cancelButtonClick:(id)sender{
    // 返回上个视图
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)carButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_FAMILY_CAR_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_FAMILY_POPOVER_TAG_CAR;
}
- (IBAction)estateButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_FAMILY_ESTATE_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_FAMILY_POPOVER_TAG_ESTATE;
}
- (IBAction)addressTextFieldChange:(UITextField*)sender {
    if ([self.family.cp_address_name isEqualToString:sender.text]) {
        return;
    }
    self.family.cp_address_name = sender.text;
    self.family.cp_longitude = nil;
    self.family.cp_latitude = nil;
    self.family.cp_zoom = nil;
    self.family.cp_invain = @(0);
    [self updateAddressUI];
}
- (IBAction)addressButtonClick:(id)sender {
    CPEditMapViewController* map = [[CPEditMapViewController alloc] initWithNibName:CP_RESOURCE_XIB_MAP_EDIT bundle:nil];
    map.delegate = self;
    map.invain = self.family.cp_invain;
    map.name = self.family.cp_address_name;
    map.longitude = self.family.cp_longitude;
    map.latitude = self.family.cp_latitude;
    [self.navigationController pushViewController:map animated:YES];
}
- (IBAction)marriageButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_FAMILY_MARRIAGE_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_FAMILY_POPOVER_TAG_MARRIAGE;
}
- (IBAction)spouseNameTextFieldChange:(UITextField*)sender {
    self.family.cp_spouse_name = sender.text;
}
- (IBAction)spousePhoneNumberTextFieldChange:(UITextField*)sender {
    self.family.cp_spouse_phone = sender.text;
}
- (IBAction)spouseBirthdayButtonClick:(id)sender {;
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.family.cp_spouse_birthday) {
        self.datePickerView.date = [self.df dateFromString:self.family.cp_spouse_birthday];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag,@(-1), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)memberStatusSwitchChange:(UISwitch *)sender {
    self.family.cp_member_status = @(sender.on);
    if (self.family.cp_member_status && self.family.cp_member_status.boolValue) {
        if (!self.familyMemberArray) {
            self.familyMemberArray = [NSMutableArray array];
        }
        if (self.familyMemberArray.count ==0) {
            CPFamilyMember* fm = [CPFamilyMember newAdaptDBWith:self.family.cp_contact_uuid];
            [self.familyMemberArray addObject:fm];
        }
        
    }
    [self updateFamilyMemberUI];
}
#pragma mark - Action
- (void)familyMemberNameTextFieldChange:(UITextField *)sender {
    CPFamilyMember*fm = self.familyMemberArray[sender.tag];
    fm.cp_name = sender.text;
}
- (void)familyMemberAddButtonClick:(UIButton *)sender {
    CPFamilyMember* fm = [CPFamilyMember newAdaptDBWith:self.family.cp_contact_uuid];
    [self.familyMemberArray addObject:fm];
    [self updateFamilyMemberUI];
}
- (void)familyMemberDeleteButtonClick:(UIButton *)sender {
    [self.familyMemberArray removeObjectAtIndex:sender.tag];
    [self updateFamilyMemberUI];
}
- (void)familyMemberSexSegmentedControlChange:(UISegmentedControl *)sender {
    CPFamilyMember*fm = self.familyMemberArray[sender.tag];
    fm.cp_sex = @(sender.selectedSegmentIndex);
}
- (void)familyMemberBirthdayButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];
    CPFamilyMember*fm = self.familyMemberArray[sender.tag];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (fm.cp_birthday) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:fm.cp_birthday.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag,@(sender.tag), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}


#pragma mark - Date Picker Delegate

-(void)datePickerSetDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    if (tag.integerValue == -1) {
        // 配偶生日
        self.family.cp_spouse_birthday = [self.df stringFromDate:viewController.datePicker.date];
        [self.spouseBirthdayButton setTitle:self.family.cp_spouse_birthday forState:UIControlStateNormal];
    }else{
        // 子女生日
        CPFamilyMember* fm = self.familyMemberArray[tag.integerValue];
        fm.cp_birthday = [self.df stringFromDate:viewController.datePicker.date];
        [self updateFamilyMemberUI];
    }
}

-(void)datePickerClearDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    if (tag.integerValue == -1) {
        // 配偶生日
        self.family.cp_spouse_birthday = nil;
        [self.spouseBirthdayButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }else{
        // 子女生日
        CPFamilyMember* fm = self.familyMemberArray[tag.integerValue];
        fm.cp_birthday = nil;
        [self updateFamilyMemberUI];
    }
}

-(void)datePickerCancel:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
}
#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    switch (popoverView.tag) {
        case CP_FAMILY_POPOVER_TAG_CAR:{
            self.family.cp_car = @(index);
            [self.carButton setTitle:CP_FAMILY_CAR_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        case CP_FAMILY_POPOVER_TAG_ESTATE:{
            self.family.cp_estate = @(index);
            [self.estateButton setTitle:CP_FAMILY_ESTATE_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        case CP_FAMILY_POPOVER_TAG_MARRIAGE:{
            self.family.cp_marriage_status = @(index);
            [self.marriageButton setTitle:CP_FAMILY_MARRIAGE_TITLE_ITEM[index] forState:UIControlStateNormal];
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
    self.family.cp_invain = @(1);
    self.family.cp_address_name = name;
    self.family.cp_longitude = longitude;
    self.family.cp_latitude = latitude;
    [self updateAddressUI];
}
@end
