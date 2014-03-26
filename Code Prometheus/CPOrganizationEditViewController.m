//
//  CPOrganizationEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPOrganizationEditViewController.h"
#import <TDDatePickerController.h>
#import <PopoverView.h>
#import "CPOrganization.h"
#import "CPMeeting.h"
#import "CPMettingEditViewController.h"

static char CPAssociatedKeyTag;

// 日期
static NSString* const CP_DATE_TITLE_NULL = @"未定义";

// 学历
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_0 = @"无";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_1 = @"高中";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_2 = @"中专";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_3 = @"大专";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_4 = @"本科";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_5 = @"硕士";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_6 = @"博士";
static NSString* const CP_ORGANIZATION_EDUCATION_TITLE_7 = @"留学生";
#define CP_ORGANIZATION_EDUCATION_TITLE_ITEM @[CP_ORGANIZATION_EDUCATION_TITLE_0,CP_ORGANIZATION_EDUCATION_TITLE_1,CP_ORGANIZATION_EDUCATION_TITLE_2,CP_ORGANIZATION_EDUCATION_TITLE_3,CP_ORGANIZATION_EDUCATION_TITLE_4,CP_ORGANIZATION_EDUCATION_TITLE_5,CP_ORGANIZATION_EDUCATION_TITLE_6,CP_ORGANIZATION_EDUCATION_TITLE_7]

// 工作现状
static NSString* const CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_0 = @"无";
static NSString* const CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_1 = @"自主创业";
static NSString* const CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_2 = @"企业管理层";
static NSString* const CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_3 = @"职员";
static NSString* const CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_4 = @"无工作";
#define CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM @[CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_0,CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_1,CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_2,CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_3,CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_4]

// 弹框tag
typedef NS_ENUM(NSInteger, CP_ORGANIZATION_POPOVER_TAG) {
    CP_ORGANIZATION_POPOVER_TAG_EDUCATION,
    CP_ORGANIZATION_POPOVER_TAG_WORKING_CONDITIONS
};

@interface CPOrganizationEditViewController ()<PopoverViewDelegate,CPMettingEditDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *zengyuanSwitch;
@property (weak, nonatomic) IBOutlet UITextField *graduatedTextField;
@property (weak, nonatomic) IBOutlet UIButton *educationButton;
@property (weak, nonatomic) IBOutlet UIButton *workingConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *toBeijingDateButton;
@property (weak, nonatomic) IBOutlet UIButton *intoClassDateButton;
@property (weak, nonatomic) IBOutlet UISwitch *meetingSwitch;
@property (weak, nonatomic) IBOutlet UIView *meetingLayoutView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *meetingLayoutViewHeight;

@property(nonatomic) CPOrganization* organization;
@property(nonatomic) NSMutableArray* meetingArray;

// 日期选择器
@property(nonatomic) TDDatePickerController* datePickerView;
// 弹窗
@property (nonatomic) PopoverView* popoverView;
// 日期格式
@property (nonatomic) NSDateFormatter* df;

// 会议模块ViewController的引用
@property(nonatomic) NSMutableArray* meetingControllerArray;
@end

@implementation CPOrganizationEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.meetingControllerArray = [NSMutableArray array];
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
    if (!self.organizationUUID) {
        self.organization = [CPOrganization newAdaptDBWith:self.contactsUUID];
        self.meetingArray = [NSMutableArray array];
    }else {
        self.organization = [[CPDB getLKDBHelperByUser] searchSingle:[CPOrganization class] where:@{@"cp_uuid":self.organizationUUID} orderBy:nil];
        self.meetingArray = [[CPDB getLKDBHelperByUser] search:[CPMeeting class] where:@{@"cp_contact_uuid":self.organization.cp_contact_uuid} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 是否适合增员
    if (self.organization.cp_zengyuan) {
        self.zengyuanSwitch.on = self.organization.cp_zengyuan.boolValue;
    }else{
        self.zengyuanSwitch.on = YES;
    }
    // 毕业院校
    if (self.organization.cp_graduated) {
        self.graduatedTextField.text = self.organization.cp_graduated;
    }else{
        self.graduatedTextField.text = @"";
    }
    // 学历
    if (self.organization.cp_education) {
        [self.educationButton setTitle:CP_ORGANIZATION_EDUCATION_TITLE_ITEM[self.organization.cp_education.integerValue] forState:UIControlStateNormal];
    }else{
        [self.educationButton setTitle:CP_ORGANIZATION_EDUCATION_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 工作现状
    if (self.organization.cp_working_conditions) {
        [self.workingConditionsButton setTitle:CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM[self.organization.cp_working_conditions.integerValue] forState:UIControlStateNormal];
    }else{
        [self.workingConditionsButton setTitle:CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 来京日期
    if (self.organization.cp_to_beijing_date) {
        [self.toBeijingDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.organization.cp_to_beijing_date.doubleValue]] forState:UIControlStateNormal];
    }else{
        [self.toBeijingDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    // 预计入班时间
    if (self.organization.cp_into_class_date) {
        [self.intoClassDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.organization.cp_into_class_date.doubleValue]] forState:UIControlStateNormal];
    }else{
        [self.intoClassDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    // 是否参加过创说会
    if (self.organization.cp_meeting) {
        self.meetingSwitch.on = self.organization.cp_meeting.boolValue;
    }else{
        self.meetingSwitch.on = NO;
    }
    // 会议
    [self updateMeetingUI];
}
-(void) updateMeetingUI{
    for(UIView *subv in [self.meetingLayoutView subviews])
    {
        [subv removeFromSuperview];
    }
    [self.meetingControllerArray removeAllObjects];
    if (self.organization.cp_meeting && self.organization.cp_meeting.boolValue) {
        if (self.meetingArray && self.meetingArray.count>0) {
            for (CPMeeting* metting in self.meetingArray) {
                NSUInteger index = [self.meetingArray indexOfObject:metting];
                CPMettingEditViewController* mc = [self mettingEditViewControllerWithIndex:index metting:metting];
                [self.meetingLayoutView addSubview:mc.view];
            }
        }
    }
    [self layoutMettingLayoutView];
}

- (void)layoutMettingLayoutView{
    CGFloat height = 0;
    for (UIView* view in self.meetingLayoutView.subviews) {
        CGRect frame = view.frame;
        frame.origin.y = height;
        height += frame.size.height;
        view.frame = frame;
    }
    // layoutview高度
    [self.meetingLayoutView removeConstraint:self.meetingLayoutViewHeight];
    self.meetingLayoutViewHeight = [NSLayoutConstraint constraintWithItem:self.meetingLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.meetingLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:height];
    [self.meetingLayoutView addConstraint:self.meetingLayoutViewHeight];
    [self.view setNeedsLayout];
}
-(CPMettingEditViewController*) mettingEditViewControllerWithIndex:(NSUInteger) index metting:(CPMeeting*)metting{
    CPMettingEditViewController* mc = [[CPMettingEditViewController alloc] initWithNibName:CP_RESOURCE_XIB_ORGANIZATION_METTING_EDIT bundle:nil];
    [self.meetingControllerArray insertObject:mc atIndex:index];
    mc.delegate = self;
    [mc loadView];
    [mc viewDidLoad];
    // 日期
    if (metting.cp_date) {
        [mc.mettingDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:metting.cp_date.doubleValue]] forState:UIControlStateNormal];
    }else{
        [mc.mettingDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    [mc.mettingDateButton addTarget:self action:@selector(meetingDateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    mc.mettingDateButton.tag = index;
    // 按钮
    if (self.meetingArray.firstObject==metting) {
        [mc.mettingButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_ADD_0] forState:UIControlStateNormal];
        [mc.mettingButton addTarget:self action:@selector(meetingAddButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [mc.mettingButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_DELETE_0] forState:UIControlStateNormal];
        [mc.mettingButton addTarget:self action:@selector(meetingDeleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    mc.mettingButton.tag = index;
    // 内容
    if (metting.cp_description) {
        mc.growingTextView.text = metting.cp_description;
    }
    mc.growingTextView.tag = index;
    return mc;
}

#pragma mark - IBAction
- (IBAction)saveOrganization:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    self.organization.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.organizationUUID) {
        // 新增会议
        if (self.organization.cp_meeting && self.organization.cp_meeting.boolValue) {
            for (CPMeeting* metting in self.meetingArray) {
                [[CPDB getLKDBHelperByUser] insertToDB:metting];
            }
        }
        // 新增家庭
        [[CPDB getLKDBHelperByUser] insertToDB:self.organization];
        [self.navigationController popViewControllerAnimated:NO];
    } else{
        // 修改会议
        NSMutableArray* meetingArrayInDB = [[CPDB getLKDBHelperByUser] search:[CPMeeting class] where:@{@"cp_contact_uuid":self.organization.cp_contact_uuid} orderBy:nil offset:0 count:-1];
        if (self.organization.cp_meeting && self.organization.cp_meeting.boolValue) {
            // 删除子女
            for (CPMeeting* metting in meetingArrayInDB) {
                if ([self.meetingArray containsObject:metting]) {
                    continue;
                }
                [[CPDB getLKDBHelperByUser] deleteToDB:metting];
            }
            // 添加,修改子女
            for (CPMeeting* metting in self.meetingArray) {
                [[CPDB getLKDBHelperByUser] insertToDB:metting];
            }
        }else{
            // 删除全部子女
            for (CPMeeting* metting in meetingArrayInDB) {
                [[CPDB getLKDBHelperByUser] deleteToDB:metting];
            }
        }
        // 修改家庭
        [[CPDB getLKDBHelperByUser] updateToDB:self.organization where:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
-(IBAction)cancelButtonClick:(id)sender{
    // 返回上个视图
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)zengyuanSwitchValueChange:(UISwitch*)sender {
    self.organization.cp_zengyuan = @(sender.on);
}
- (IBAction)graduatedTextFieldValueChange:(UITextField*)sender {
    self.organization.cp_graduated = sender.text;
}
- (IBAction)educationButtonClick:(UIButton*)sender {
    self.popoverView = [PopoverView showPopoverAtPoint:sender.center inView:sender.superview withStringArray:CP_ORGANIZATION_EDUCATION_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_ORGANIZATION_POPOVER_TAG_EDUCATION;
}
- (IBAction)workingConditionsButtonClick:(UIButton*)sender {
    self.popoverView = [PopoverView showPopoverAtPoint:sender.center inView:sender.superview withStringArray:CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM delegate:self];
    self.popoverView.tag = CP_ORGANIZATION_POPOVER_TAG_WORKING_CONDITIONS;
}
- (IBAction)toBeijingDateButtonClick:(UIButton*)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.organization.cp_to_beijing_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.organization.cp_to_beijing_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag,@(-1), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)intoClassDateButtonClick:(UIButton*)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.organization.cp_into_class_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.organization.cp_into_class_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag,@(-2), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)meetingSwitchValueChange:(UISwitch *)sender {
    self.organization.cp_meeting = @(sender.on);
    if (self.organization.cp_meeting && self.organization.cp_meeting.boolValue) {
        if (!self.meetingArray) {
            self.meetingArray = [NSMutableArray array];
        }
        if (self.meetingArray.count ==0) {
            CPMeeting* metting = [CPMeeting newAdaptDBWith:self.organization.cp_contact_uuid];
            [self.meetingArray addObject:metting];
        }
    }
    [self updateMeetingUI];
}

#pragma mark - Action
- (void)meetingDateButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];
    CPMeeting* metting = self.meetingArray[sender.tag];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (metting.cp_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:metting.cp_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag,@(sender.tag), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (void)meetingAddButtonClick:(UIButton *)sender {
    CPMeeting* meeting = [CPMeeting newAdaptDBWith:self.organization.cp_contact_uuid];
    [self.meetingArray addObject:meeting];
    [self updateMeetingUI];
}
- (void)meetingDeleteButtonClick:(UIButton *)sender {
    [self.meetingArray removeObjectAtIndex:sender.tag];
    [self updateMeetingUI];
}


#pragma mark - Date Picker Delegate

-(void)datePickerSetDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    if (tag.integerValue == -1) {
        // 来京日期
        self.organization.cp_to_beijing_date = @([viewController.datePicker.date timeIntervalSince1970]);
        [self.toBeijingDateButton setTitle:[self.df stringFromDate:viewController.datePicker.date] forState:UIControlStateNormal];
    }else if(tag.integerValue == -2){
        // 预计入班时间
        self.organization.cp_into_class_date = @([viewController.datePicker.date timeIntervalSince1970]);
        [self.intoClassDateButton setTitle:[self.df stringFromDate:viewController.datePicker.date] forState:UIControlStateNormal];
    }else{
        // 创说会时间
        CPMeeting* metting = self.meetingArray[tag.integerValue];
        metting.cp_date = @([viewController.datePicker.date timeIntervalSince1970]);
        [self updateMeetingUI];
    }
}

-(void)datePickerClearDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    if (tag.integerValue == -1) {
        // 来京日期
        self.organization.cp_to_beijing_date = nil;
        [self.toBeijingDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }else if(tag.integerValue == -2){
        // 预计入班时间
        self.organization.cp_into_class_date = nil;
        [self.intoClassDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }else{
        // 创说会时间
        CPMeeting* metting = self.meetingArray[tag.integerValue];
        metting.cp_date = nil;
        [self updateMeetingUI];
    }
}

-(void)datePickerCancel:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
}
#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    switch (popoverView.tag) {
        case CP_ORGANIZATION_POPOVER_TAG_EDUCATION:{
            self.organization.cp_education = @(index);
            [self.educationButton setTitle:CP_ORGANIZATION_EDUCATION_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        case CP_ORGANIZATION_POPOVER_TAG_WORKING_CONDITIONS:{
            self.organization.cp_working_conditions = @(index);
            [self.workingConditionsButton setTitle:CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}
#pragma mark - CPMettingEditDelegate
-(void) meetingContentTextViewDidEndEditing:(CPMettingEditViewController *)meetingC withText:(NSString *)text{
    NSInteger index = meetingC.growingTextView.tag;
    CPMeeting* metting = self.meetingArray[index];
    metting.cp_description = text;
}
-(void) meetingContentTextViewWillChangeHeight:(CPMettingEditViewController *)meeting withDiff:(float)diff{
    [self layoutMettingLayoutView];
}
@end
