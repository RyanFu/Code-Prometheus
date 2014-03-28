//
//  CPTraceReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-3.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPTraceReadViewController.h"
#import "CPTrace.h"
#import "CPImage.h"
#import <NYXImagesKit.h>
#import <MWPhotoBrowser.h>
#import <MBProgressHUD.h>

static NSString* const CP_DATE_TITLE_NULL = @"未定义";
static NSString* const CP_TIME_TITLE_NULL = @"未定义";

// 阶段
static NSString* const CP_TRACE_STAGE_TITLE_NULL = @"-无-";
static NSString* const CP_TRACE_STAGE_TITLE_NO_BOND = @"未接洽";
static NSString* const CP_TRACE_STAGE_TITLE_CALL_BOND = @"电话接洽";
static NSString* const CP_TRACE_STAGE_TITLE_CALL_DEEP = @"电话深度沟通";
static NSString* const CP_TRACE_STAGE_TITLE_FIRST_FACE = @"初次面谈";
static NSString* const CP_TRACE_STAGE_TITLE_DEEP_FACE = @"深度面谈";
static NSString* const CP_TRACE_STAGE_TITLE_THINKING = @"考虑中";
static NSString* const CP_TRACE_STAGE_TITLE_TRANSACTION = @"成交";
static NSString* const CP_TRACE_STAGE_TITLE_ADD_INSURANCE = @"加保中";
#define CP_TRACE_STAGE_TITLE_ITEM @[CP_TRACE_STAGE_TITLE_NULL,CP_TRACE_STAGE_TITLE_NO_BOND,CP_TRACE_STAGE_TITLE_CALL_BOND,CP_TRACE_STAGE_TITLE_CALL_DEEP,CP_TRACE_STAGE_TITLE_FIRST_FACE,CP_TRACE_STAGE_TITLE_DEEP_FACE,CP_TRACE_STAGE_TITLE_THINKING,CP_TRACE_STAGE_TITLE_TRANSACTION,CP_TRACE_STAGE_TITLE_ADD_INSURANCE]

@interface CPTraceReadViewController ()<MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *photoLayoutView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLayoutViewHeightConstraint;

@property (nonatomic)CPTrace* trace;
@property (nonatomic)NSMutableArray* files;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPTraceReadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPTrace class]) object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        // 启动进度条
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            // 加载数据
            [self loadTrace];
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
    if ([segue.identifier isEqualToString:@"cp_segue_trace_read_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.traceUUID forKey:@"traceUUID"];
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
    [self.photoLayoutView removeConstraint:self.photoLayoutViewHeightConstraint];
    self.photoLayoutViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.photoLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:i==0?0:2*kFramePadding+(i/3)*(height+kImageSpacing)+height];
    [self.photoLayoutView addConstraint:self.photoLayoutViewHeightConstraint];
    [self.view setNeedsLayout];
}
-(void) loadTrace{
    if (self.traceUUID) {
        self.trace = [[CPDB getLKDBHelperByUser] searchSingle:[CPTrace class] where:@{@"cp_uuid":self.traceUUID} orderBy:nil];
    }
}
-(void) loadFiles{
    if (self.traceUUID) {
        self.files = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":self.traceUUID} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 日期
    if (self.trace.cp_date) {
        static NSDateFormatter* CP_DF_DATE = nil;
        if (!CP_DF_DATE) {
            CP_DF_DATE = [[NSDateFormatter alloc] init];
            [CP_DF_DATE setDateFormat:@"yyyy-MM-dd"];
        }
        static NSDateFormatter* CP_DF_TIME = nil;
        if (!CP_DF_TIME) {
            CP_DF_TIME = [[NSDateFormatter alloc] init];
            [CP_DF_TIME setDateFormat:@"HH:mm"];
        }
        self.dateLabel.text = [CP_DF_DATE stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]];
        self.timeLabel.text = [CP_DF_TIME stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]];
    }else{
        self.dateLabel.text = CP_DATE_TITLE_NULL;
        self.timeLabel.text = CP_TIME_TITLE_NULL;
    }
    // 阶段
    if (self.trace.cp_stage) {
        self.stageLabel.text = CP_TRACE_STAGE_TITLE_ITEM[self.trace.cp_stage.integerValue];
    }else{
        self.stageLabel.text = CP_TRACE_STAGE_TITLE_ITEM[0];
    }
    // 内容
    if (self.trace.cp_description) {
        self.descriptionLabel.text = self.trace.cp_description;
        CGSize size = [self.descriptionLabel sizeThatFits:CGSizeMake(self.descriptionLabel.bounds.size.width, CGFLOAT_MAX)];
        size.height = MAX(21, size.height);
        // layoutview高度
        [self.descriptionLabel removeConstraint:self.descriptionHeightConstraint];
        self.descriptionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.descriptionLabel.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:size.height];
        [self.descriptionLabel addConstraint:self.descriptionHeightConstraint];
        [self.view setNeedsLayout];
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
