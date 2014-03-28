//
//  CPPolicyReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPolicyReadViewController.h"
#import "CPPolicy.h"
#import "CPImage.h"
#import <NYXImagesKit.h>
#import <MWPhotoBrowser.h>
#import <MBProgressHUD.h>


static NSString* const CP_DATE_TITLE_NULL = @"未定义";

// 缴费方式
static NSString* const CP_POLICY_PAY_TYPE_TITLE_MONTH = @"月缴";
static NSString* const CP_POLICY_PAY_TYPE_TITLE_QUARTER = @"季度缴";
static NSString* const CP_POLICY_PAY_TYPE_TITLE_YEAR = @"年缴";
#define CP_POLICY_PAY_TYPE_TITLE_ITEM @[CP_POLICY_PAY_TYPE_TITLE_MONTH,CP_POLICY_PAY_TYPE_TITLE_QUARTER,CP_POLICY_PAY_TYPE_TITLE_YEAR]
// 付款方式
static NSString* const CP_POLICY_PAY_WAY_TITLE_E_BANK = @"网银";
static NSString* const CP_POLICY_PAY_WAY_TITLE_CASH = @"现金";
#define CP_POLICY_PAY_WAY_TITLE_ITEM @[CP_POLICY_PAY_WAY_TITLE_E_BANK,CP_POLICY_PAY_WAY_TITLE_CASH]

@interface CPPolicyReadViewController ()<MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *beginDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isMyPolicyLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *payTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *payAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *payWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindDateLabel;
@property (weak, nonatomic) IBOutlet UIView *photoLayoutView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLayoutViewHeight;

@property (nonatomic)CPPolicy* policy;
@property (nonatomic)NSMutableArray* files;

// 日期格式化
@property (nonatomic)NSDateFormatter* df;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPPolicyReadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
	// 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPPolicy class]) object:nil];
    // 日期格式化
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"yy-MM-dd"];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            // 加载数据
            [self loadPolicy];
            [self loadFiles];
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
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // 删除uiimageview
//    for(UIView *subv in [self.photoLayoutView subviews])
//    {
//        [subv removeFromSuperview];
//    }
//}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_policy_read_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.policyUUID forKey:@"policyUUID"];
    }
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - private
// 布局计算
static const CGFloat kFramePadding = 10;
static const CGFloat kImageSpacing = 5;
- (void)layoutPhotoViews{
    CGFloat width = (self.photoLayoutView.frame.size.width-kFramePadding*2-kImageSpacing*2)/3;
    CGFloat height = width;
    int i=0;
    // 添加的图片
    for (UIView* view in self.photoLayoutView.subviews) {
        view.frame = CGRectMake(kFramePadding+(i%3)*(width+kImageSpacing), kFramePadding+(i/3)*(height+kImageSpacing), width, height);
        i++;
    }
    // layoutview高度
    [self.photoLayoutView removeConstraint:self.photoLayoutViewHeight];
    self.photoLayoutViewHeight = [NSLayoutConstraint constraintWithItem:self.photoLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:i==0?0:2*kFramePadding+(i/3)*(height+kImageSpacing)+height];
    [self.photoLayoutView addConstraint:self.photoLayoutViewHeight];
    [self.view setNeedsLayout];
}
-(void) loadPolicy{
    if (self.policyUUID) {
        self.policy = [[CPDB getLKDBHelperByUser] searchSingle:[CPPolicy class] where:@{@"cp_uuid":self.policyUUID} orderBy:nil];
    }
}
-(void) loadFiles{
    if (self.policyUUID) {
        self.files = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":self.policyUUID} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 日期
    if (self.policy.cp_date_begin) {
        self.beginDateLabel.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_begin.doubleValue]];
    }else{
        self.beginDateLabel.text = CP_DATE_TITLE_NULL;
    }
    if (self.policy.cp_date_end) {
        self.endDateLabel.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_end.doubleValue]];
    }else{
        self.endDateLabel.text = CP_DATE_TITLE_NULL;
    }
    // 名称
    if (self.policy.cp_name) {
        self.nameLabel.text = self.policy.cp_name;
    }
    // 我的保单
    if (self.policy.cp_my_policy && self.policy.cp_my_policy.integerValue==0) {
        self.isMyPolicyLabel.text = @"否";
    }else{
        self.isMyPolicyLabel.text = @"是";
    }
    // 详情
    if (self.policy.cp_description) {
        self.descriptionLabel.text = self.policy.cp_description;
        CGSize size = [self.descriptionLabel sizeThatFits:CGSizeMake(self.descriptionLabel.bounds.size.width, CGFLOAT_MAX)];
        // layoutview高度
        [self.descriptionLabel removeConstraint:self.descriptionLabelHeight];
        self.descriptionLabelHeight = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.descriptionLabel.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:size.height];
        [self.descriptionLabel addConstraint:self.descriptionLabelHeight];
        [self.view setNeedsLayout];
    }
    // 缴费方式
    if (self.policy.cp_pay_type) {
        self.payTypeLabel.text = CP_POLICY_PAY_TYPE_TITLE_ITEM[self.policy.cp_pay_type.integerValue];
    }
    // 缴费金额
    if (self.policy.cp_pay_amount) {
        self.payAmountLabel.text = [NSString stringWithFormat:@"%@",self.policy.cp_pay_amount];
    }
    // 付款方式
    if (self.policy.cp_pay_way) {
        self.payWayLabel.text = CP_POLICY_PAY_WAY_TITLE_ITEM[self.policy.cp_pay_way.integerValue];
    }
    if (self.policy.cp_remind_date) {
        self.remindDateLabel.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_remind_date.doubleValue]];
    }
    // 照片
    // 删除uiimageview
    for(UIView *subv in [self.photoLayoutView subviews])
    {
        [subv removeFromSuperview];
    }
    if (self.files && self.files.count>0) {
        for (CPImage* image in self.files) {
            // Button
            UIButton* buttonImage = [[UIButton alloc] initWithFrame:CGRectZero];
            [buttonImage setImageWithCPImage:image];
            [buttonImage.imageView setContentMode:UIViewContentModeScaleAspectFit];
            buttonImage.tag = [self.files indexOfObject:image];
            // 单击
            [buttonImage addTarget:self action:@selector(photoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.photoLayoutView addSubview:buttonImage];
        }
    }
    // 布局
    [self layoutPhotoViews];
}
#pragma mark - Action
-(void)photoButtonClick:(id)sender{
    UIButton* button = sender;
    // 单击查看
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;
    browser.wantsFullScreenLayout = YES;
    browser.zoomPhotosToFill = YES;
    [browser setCurrentPhotoIndex:button.tag];
    // Show
    [self.navigationController pushViewController:browser animated:YES];
}
#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.files.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    CPImage* cpImage = [self.files objectAtIndex:index];
    UIImage* image = cpImage.image;
    if (image) {
        return [MWPhoto photoWithImage:[image scaleToFitSize:CP_UI_PHOTO_SIZE_BROWSE]];
    }
    if (cpImage.cp_uuid) {
        return [MWPhoto photoWithURL:[NSURL URLWithString:cpImage.cp_uuid]];
    }
    CPLogError(@"找不到图片!");
    return [MWPhoto photoWithImage:[UIImage imageNamed:@"cp_null_photo"]];
}
@end
