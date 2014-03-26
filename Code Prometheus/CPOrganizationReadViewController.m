//
//  CPOrganizationReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPOrganizationReadViewController.h"
#import "CPOrganization.h"
#import "CPMeeting.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

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

@interface CPOrganizationReadViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *zengyuanLabel;
@property (weak, nonatomic) IBOutlet UILabel *graduatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingConditionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *toBeijingDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *intoClassDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *meetingLabel;
@property (weak, nonatomic) IBOutlet UIView *meetingLayoutView;

@property(nonatomic) CPOrganization* organization;
@property(nonatomic) NSMutableArray* meetingArray;

// 生日格式
@property (nonatomic) NSDateFormatter* df;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPOrganizationReadViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPOrganization class]) object:nil];
    // 日期格式化
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"yyyy-MM-dd"];
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
    if ([segue.identifier isEqualToString:@"cp_segue_organization_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
        [controller setValue:self.organization.cp_uuid forKey:@"organizationUUID"];
    }
}
#pragma mark - private
-(void) loadDB{
    if (self.contactsUUID) {
        self.organization = [[CPDB getLKDBHelperByUser] searchSingle:[CPOrganization class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil];
        self.meetingArray = [[CPDB getLKDBHelperByUser] search:[CPMeeting class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 是否适合增员
    if (self.organization.cp_zengyuan) {
        self.zengyuanLabel.text = self.organization.cp_zengyuan.boolValue ? @"是":@"否";
    }else{
        self.zengyuanLabel.text = @"是";
    }
    // 毕业院校
    if (self.organization.cp_graduated) {
        self.graduatedLabel.text = self.organization.cp_graduated;
    }else{
        self.graduatedLabel.text = @"";
    }
    // 学历
    if (self.organization.cp_education) {
        self.educationLabel.text = CP_ORGANIZATION_EDUCATION_TITLE_ITEM[self.organization.cp_education.integerValue];
    }else{
        self.educationLabel.text = CP_ORGANIZATION_EDUCATION_TITLE_ITEM[0];
    }
    // 工作现状
    if (self.organization.cp_working_conditions) {
        self.workingConditionsLabel.text = CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM[self.organization.cp_working_conditions.integerValue];
    }else{
        self.workingConditionsLabel.text = CP_ORGANIZATION_WORKING_CONDITIONS_TITLE_ITEM[0];
    }
    // 来京日期
    if (self.organization.cp_to_beijing_date) {
        self.toBeijingDateLabel.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.organization.cp_to_beijing_date.doubleValue]];
    }else{
        self.toBeijingDateLabel.text = CP_DATE_TITLE_NULL;
    }
    // 预计入班时间
    if (self.organization.cp_into_class_date) {
        self.intoClassDateLabel.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.organization.cp_into_class_date.doubleValue]];
    }else{
        self.intoClassDateLabel.text = CP_DATE_TITLE_NULL;
    }
    // 是否参加过创说会
    if (self.organization.cp_meeting) {
        self.meetingLabel.text = self.organization.cp_meeting.boolValue ? @"是":@"否";
    }else{
        self.meetingLabel.text = @"否";
    }
    // 会议
    [self updateMeetingUI];
}

-(void) updateMeetingUI{
    for(UIView *subv in [self.meetingLayoutView subviews])
    {
        [subv removeFromSuperview];
    }
    if (self.organization.cp_meeting && self.organization.cp_meeting.boolValue) {
        if (self.meetingArray && self.meetingArray.count>0) {
            for (CPMeeting* metting in self.meetingArray) {
                UIView* mv = [self mettingReadViewWithMetting:metting];
                [self.meetingLayoutView addSubview:mv];
            }
        }
    }
    [self layoutMettingLayoutView];
}

- (void)layoutMettingLayoutView{
    for (UIView* subview in self.meetingLayoutView.subviews) {
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            if (subview == self.meetingLayoutView.subviews.firstObject) {
                make.top.equalTo(@(0));
            }else{
                NSInteger index = [self.meetingLayoutView.subviews indexOfObject:subview];
                UIView* lastView = self.meetingLayoutView.subviews[index-1];
                make.top.equalTo(lastView.mas_bottom);
            }
            if (subview == self.meetingLayoutView.subviews.lastObject) {
                make.bottom.equalTo(@(0));
            }
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
        }];
    }
    [self.view setNeedsLayout];
}
-(UIView*) mettingReadViewWithMetting:(CPMeeting*)metting{
    // 根View
    UIView* rootView = UIView.new;
    // 日期标题
    UILabel* meetingDateLabelTitle = [UILabel new];
    meetingDateLabelTitle.text = @"日期";
    [rootView addSubview:meetingDateLabelTitle];
    // 日期
    UILabel* meetingDateLabel = [UILabel new];
    if (metting.cp_date) {
        meetingDateLabel.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:metting.cp_date.doubleValue]];
    }else{
        meetingDateLabel.text = CP_DATE_TITLE_NULL;
    }
    [rootView addSubview:meetingDateLabel];
    // 内容标题
    UILabel* meetingContentLabelTitle = [UILabel new];
    meetingContentLabelTitle.text = @"内容";
    [rootView addSubview:meetingContentLabelTitle];
    // 内容
    UILabel* meetingContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    if (metting.cp_description) {
        meetingContentLabel.text = metting.cp_description;
    }else{
        meetingContentLabel.text = @" ";
    }
    meetingContentLabel.numberOfLines = 0;
    [rootView addSubview:meetingContentLabel];
    // 分割线
    UIView* fenge = UIView.new;
    fenge.backgroundColor = [UIColor lightGrayColor];
    [rootView addSubview:fenge];
    // 约束
    [meetingDateLabelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@11);
        make.left.equalTo(@20);
        make.width.equalTo(@108);
        make.height.equalTo(@21);
    }];
    [meetingDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(meetingDateLabelTitle.mas_right).offset(20);
        make.right.equalTo(rootView.mas_right).offset(-20);
        make.height.equalTo(meetingDateLabelTitle.mas_height);
        make.centerY.equalTo(meetingDateLabelTitle.mas_centerY);
    }];
    [meetingContentLabelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(meetingDateLabelTitle.mas_bottom).offset(23);
        make.centerX.equalTo(meetingDateLabelTitle.mas_centerX);
        make.width.equalTo(meetingDateLabelTitle.mas_width);
        make.height.equalTo(meetingDateLabelTitle.mas_height);
    }];
    [meetingContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(meetingContentLabelTitle.mas_right).offset(20);
        make.right.equalTo(rootView.mas_right).offset(-20);
        make.top.equalTo(meetingContentLabelTitle.mas_top);
        make.height.greaterThanOrEqualTo(meetingContentLabelTitle.mas_height);
    }];
    [fenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.right.equalTo(@(0));
        make.height.equalTo(@(1));
        make.top.equalTo(meetingContentLabel.mas_bottom).offset(11);
        make.bottom.equalTo(@(0));
    }];
    return rootView;
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
@end
