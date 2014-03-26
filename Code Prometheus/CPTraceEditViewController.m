//
//  CPTraceEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-30.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPTraceEditViewController.h"
#import <HPGrowingTextView.h>
#import <TDDatePickerController.h>
#import "CPTrace.h"
#import <PopoverView.h>
#import <FDTakeController.h>
#import <MWPhotoBrowser.h>
#import "CPFile.h"
#import <NYXImagesKit.h>
#import "CPImage.h"
#import <MBProgressHUD.h>

static char CPAssociatedKeyTag;

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

@interface CPTraceEditViewController ()<HPGrowingTextViewDelegate,PopoverViewDelegate,FDTakeDelegate,MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *stageButton;
@property (weak, nonatomic) IBOutlet UIView *photoLayoutView;
@property (weak, nonatomic) IBOutlet UIView *contentLayoutView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLayoutViewHeightConstraint;

// 添加图片button
@property (nonatomic)UIButton* addPhotoButton;
// 内容textview
@property (nonatomic)HPGrowingTextView* growingTextView;

// 日期选择器
@property(nonatomic) TDDatePickerController* datePickerView;
// 弹窗
@property (nonatomic) PopoverView* popoverView;
// 照片选择或拍摄
@property (nonatomic)FDTakeController *takeController;

@property (nonatomic)CPTrace* trace;
@property (nonatomic)NSMutableArray* files;

@end

@implementation CPTraceEditViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // 添加图片button
    self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addPhotoButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_TRACE_ADD_PHOTO] forState:UIControlStateNormal];
    [self.addPhotoButton addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoLayoutView addSubview:self.addPhotoButton];
    // 内容textview
    self.growingTextView = [[HPGrowingTextView alloc] initWithFrame:self.contentLayoutView.bounds];
//    self.growingTextView.isScrollable = NO;
//    self.growingTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
//	self.growingTextView.minNumberOfLines = 1;
//	self.growingTextView.maxNumberOfLines = MaxNumberOfLines;
    // you can also set the maximum height in points with maxHeight
    self.growingTextView.minHeight = 44;
    self.growingTextView.maxHeight = NSIntegerMax;
//	self.growingTextView.returnKeyType = UIReturnKeyGo;
//	self.growingTextView.font = [UIFont systemFontOfSize:15.0f];
	self.growingTextView.delegate = self;
    self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
//    self.growingTextView.backgroundColor = [UIColor whiteColor];
//    self.growingTextView.placeholder = @"Type to see the textView grow!";
    
    // self.growingTextView.text = @"test\n\ntest";
	// self.growingTextView.animateHeightChange = NO; //turns off animation
    [self.contentLayoutView addSubview:self.growingTextView];
    // 照片
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
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
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!CP_IS_IOS7_AND_UP) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // 删除uiimageview
    for(UIView *subv in [self.photoLayoutView subviews])
    {
        if (subv != self.addPhotoButton) {
            [subv removeFromSuperview];
        }
    }
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
        if (view == self.addPhotoButton) {
            continue;
        }
        view.frame = CGRectMake(kFramePadding+(i%3)*(width+kImageSpacing), kFramePadding+(i/3)*(height+kImageSpacing), width, height);
        i++;
    }
    // addButton
    self.addPhotoButton.frame = CGRectMake(kFramePadding+(i%3)*(width+kImageSpacing), kFramePadding+(i/3)*(height+kImageSpacing), width, height);
    // layoutview高度
    [self.photoLayoutView removeConstraint:self.photoLayoutViewHeightConstraint];
    self.photoLayoutViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.photoLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:2*kFramePadding+(i/3)*(height+kImageSpacing)+height];
    [self.photoLayoutView addConstraint:self.photoLayoutViewHeightConstraint];
    [self.view setNeedsLayout];
}
-(void) loadTrace{
    if (!self.traceUUID) {
        self.trace = [CPTrace newAdaptDB];
        self.trace.cp_contact_uuid = self.contactsUUID;
    }else {
        self.trace = [[CPDB getLKDBHelperByUser] searchSingle:[CPTrace class] where:@{@"cp_uuid":self.traceUUID} orderBy:nil];
    }
}
-(void) loadFiles{
    if (!self.traceUUID) {
        self.files = [NSMutableArray array];
    }else {
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
        [self.dateButton setTitle:[CP_DF_DATE stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]] forState:UIControlStateNormal];
        [self.timeButton setTitle:[CP_DF_TIME stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]] forState:UIControlStateNormal];
    }else{
        [self.dateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
        [self.timeButton setTitle:CP_TIME_TITLE_NULL forState:UIControlStateNormal];
    }
    // 阶段
    if (self.trace.cp_stage) {
        [self.stageButton setTitle:CP_TRACE_STAGE_TITLE_ITEM[self.trace.cp_stage.integerValue] forState:UIControlStateNormal];
    }else{
        [self.stageButton setTitle:CP_TRACE_STAGE_TITLE_ITEM[0] forState:UIControlStateNormal];
    }
    // 内容
    if (self.trace.cp_description) {
        self.growingTextView.text = self.trace.cp_description;
    }
    // 照片
    [self updatePhotoViews];
}
-(void)updatePhotoViews{
    // 删除uiimageview
    for(UIView *subv in [self.photoLayoutView subviews])
    {
        if (subv != self.addPhotoButton) {
            [subv removeFromSuperview];
        }
    }
    if (self.files && self.files.count>0) {
        for (CPImage* image in self.files) {
            UIImage* photo = image.image;
            
            // Button
            UIButton* buttonImage = [[UIButton alloc] initWithFrame:CGRectZero];
            [buttonImage setImage:[photo scaleToFitSize:CP_UI_PHOTO_SIZE_THUMBNAIL] forState:UIControlStateNormal];
            [buttonImage.imageView setContentMode:UIViewContentModeScaleAspectFit];
            buttonImage.tag = [self.files indexOfObject:image];
            // 长按手势
            UILongPressGestureRecognizer *btnLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonLongClick:)];
            btnLongTap.minimumPressDuration = 0.5;
            [buttonImage addGestureRecognizer:btnLongTap];
            
            // 单击
            [buttonImage addTarget:self action:@selector(photoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.photoLayoutView addSubview:buttonImage];
        }
    }
    // 布局
    [self layoutPhotoViews];
}
#pragma mark - IBAction
- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:self.traceUUID?NO:YES];
}
- (IBAction)save:(id)sender {
    [self.view endEditing:YES];
    self.trace.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.traceUUID) {
        // 新增
        // 图片
        for (CPImage* image in self.files) {
            [[CPDB getLKDBHelperByUser] insertToDB:image];
        }
        // 追踪
        [[CPDB getLKDBHelperByUser] insertToDB:self.trace];
        // 返回
        [self.navigationController popViewControllerAnimated:YES];
    } else{
        // 修改
        // 图片
        NSMutableArray* fileInDB = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":self.traceUUID} orderBy:nil offset:0 count:-1];
        // 添加图片
        for (CPImage* image in self.files) {
            if ([fileInDB containsObject:image]) {
                continue;
            }
            [[CPDB getLKDBHelperByUser] insertToDB:image];
        }
        // 删除图片
        for (CPImage* image in fileInDB) {
            if ([self.files containsObject:image]) {
                continue;
            }
            [[CPDB getLKDBHelperByUser] deleteToDB:image];
        }
        // 追踪
        [[CPDB getLKDBHelperByUser] updateToDB:self.trace where:nil];
        // 返回
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
- (IBAction)dateButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.trace.cp_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag, @(0), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)timeButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_TIME bundle:nil];
    self.datePickerView.delegate = self;
    if (self.trace.cp_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag, @(1), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)stageButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_TRACE_STAGE_TITLE_ITEM delegate:self];
}
#pragma mark - Action
- (void)addPictureButtonClick:(id)sender {
    [self.takeController takePhotoOrChooseFromLibrary];
}
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
-(void)photoButtonLongClick:(id)sender{
    // 长按删除
    UILongPressGestureRecognizer* lp = sender;
    if(UIGestureRecognizerStateBegan != lp.state) {
        return;
    }
    UIButton* button = (UIButton*)[lp view];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"确认删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = [self.photoLayoutView.subviews indexOfObject:button];
    [alert show];
}
#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
#warning 当输入多行内容时,布局不正确,可能是TPKeyboardAvoidingScrollView的BUG
    // layoutview高度
    float diff = (growingTextView.frame.size.height - height);
    float priorHeight = self.contentLayoutView.frame.size.height;
    priorHeight -= diff;
    [self.contentLayoutView removeConstraint:self.contentHeightConstraint];
    self.contentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contentLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:priorHeight];
    [self.contentLayoutView addConstraint:self.contentHeightConstraint];
    [self.view setNeedsLayout];
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    self.trace.cp_description = growingTextView.internalTextView.text;
}
#pragma mark - Date Picker Delegate
-(void)datePickerSetDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
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
    static NSCalendar *CP_CALENDAR = nil;
    if (!CP_CALENDAR) {
        CP_CALENDAR = [NSCalendar currentCalendar];
    }
    NSDate* date = viewController.datePicker.date;
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    switch (tag.integerValue) {
        case 0:{
            if (self.trace.cp_date) {
                NSDateComponents *componentsOld = [CP_CALENDAR components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]];
                NSDateComponents *componentsNew = [CP_CALENDAR components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
                componentsOld.year = componentsNew.year;
                componentsOld.month = componentsNew.month;
                componentsOld.day = componentsNew.day;
                self.trace.cp_date = @([[CP_CALENDAR dateFromComponents:componentsOld] timeIntervalSince1970]);
            }else{
                self.trace.cp_date = @([date timeIntervalSince1970]);
            }
            break;
        }
        case 1:{
            if (self.trace.cp_date) {
                NSDateComponents *componentsOld = [CP_CALENDAR components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]];
                NSDateComponents *componentsNew = [CP_CALENDAR components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
                componentsOld.hour = componentsNew.hour;
                componentsOld.minute = componentsNew.minute;
                self.trace.cp_date = @([[CP_CALENDAR dateFromComponents:componentsOld] timeIntervalSince1970]);
            }else{
                self.trace.cp_date = @([date timeIntervalSince1970]);
            }
            break;
        }
        default:
            break;
    }
    // UI
    [self.dateButton setTitle:[CP_DF_DATE stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]] forState:UIControlStateNormal];
    [self.timeButton setTitle:[CP_DF_TIME stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.trace.cp_date.doubleValue]] forState:UIControlStateNormal];
}

-(void)datePickerClearDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    switch (tag.integerValue) {
        case 0:{
            [self.dateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
            [self.timeButton setTitle:CP_TIME_TITLE_NULL forState:UIControlStateNormal];
            break;
        }
        case 1:{
            [self.dateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
            [self.timeButton setTitle:CP_TIME_TITLE_NULL forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    self.trace.cp_date = nil;
}

-(void)datePickerCancel:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
}
#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    self.trace.cp_stage = @(index);
    [self.stageButton setTitle:CP_TRACE_STAGE_TITLE_ITEM[index] forState:UIControlStateNormal];
    [self.popoverView dismiss];
    self.popoverView = nil;
}
#pragma mark - FDTakeDelegate
- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info{
    // 旋转
    photo = [photo fixOrientation];
    // 缩放
    photo = [photo scaleToFitSize:CP_UI_PHOTO_SIZE_BROWSE];
    CPImage* image = [CPImage newAdaptDB];
    image.cp_r_uuid = self.trace.cp_uuid;
    image.image = photo;
    [self.files addObject:image];
    // UI
    [self updatePhotoViews];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UIButton* button = [self.photoLayoutView.subviews objectAtIndex:alertView.tag];
        // file
        [self.files removeObjectAtIndex:button.tag];
        // 布局
        [self updatePhotoViews];
    }
}
#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.files.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    UIImage* image = [(CPImage*)[self.files objectAtIndex:index] image];
    MWPhoto *photo = [MWPhoto photoWithImage:[image scaleToFitSize:CP_UI_PHOTO_SIZE_BROWSE]];
    return photo;
}
@end
