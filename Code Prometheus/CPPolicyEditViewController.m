//
//  CPPolicyEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-4.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPolicyEditViewController.h"
#import "CPPolicy.h"
#import <HPGrowingTextView.h>
#import <FDTakeController.h>
#import "CPImage.h"
#import <MWPhotoBrowser.h>
#import <NYXImagesKit.h>
#import <TDDatePickerController.h>
#import <PopoverView.h>
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>

static char CPAssociatedKeyTag;

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

@interface CPPolicyEditViewController ()<HPGrowingTextViewDelegate,FDTakeDelegate,MWPhotoBrowserDelegate,PopoverViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *beginDateButton;
@property (weak, nonatomic) IBOutlet UIButton *endDateButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isMyPolicySwitch;
@property (weak, nonatomic) IBOutlet UIView *descriptionLayoutView;
@property (weak, nonatomic) IBOutlet UIButton *payTypeButton;
@property (weak, nonatomic) IBOutlet UITextField *payAmountTextField;
@property (weak, nonatomic) IBOutlet UIButton *payWayButton;
@property (weak, nonatomic) IBOutlet UIButton *remindDateButton;
@property (weak, nonatomic) IBOutlet UIView *photoLayoutView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLayoutViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLayoutViewHeight;

// 添加图片button
@property (nonatomic)UIButton* addPhotoButton;
// 内容textview
@property (nonatomic)HPGrowingTextView* growingTextView;
// 照片选择或拍摄
@property (nonatomic)FDTakeController *takeController;
// 日期格式化
@property (nonatomic)NSDateFormatter* df;
// 日期选择器
@property(nonatomic) TDDatePickerController* datePickerView;
// 弹窗
@property (nonatomic) PopoverView* popoverView;

@property (nonatomic)CPPolicy* policy;
@property (nonatomic)NSMutableArray* files;
@end

@implementation CPPolicyEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 日期格式化
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"yy-MM-dd"];
    // 添加图片button
    self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addPhotoButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_POLICY_ADD_PHOTO] forState:UIControlStateNormal];
    [self.addPhotoButton addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoLayoutView addSubview:self.addPhotoButton];
    // 内容textview
    self.growingTextView = [[HPGrowingTextView alloc] initWithFrame:self.descriptionLayoutView.bounds];
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
    [self.descriptionLayoutView addSubview:self.growingTextView];
    // 照片
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
    // 启动进度条
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
//        if (subv != self.addPhotoButton) {
//            [subv removeFromSuperview];
//        }
//    }
//}
#pragma mark - private
-(void) loadPolicy{
    if (!self.policyUUID) {
        self.policy = [CPPolicy newAdaptDB];
        self.policy.cp_contact_uuid = self.contactsUUID;
    }else {
        self.policy = [[CPDB getLKDBHelperByUser] searchSingle:[CPPolicy class] where:@{@"cp_uuid":self.policyUUID} orderBy:nil];
    }
}
-(void) loadFiles{
    if (!self.policyUUID) {
        self.files = [NSMutableArray array];
    }else {
        self.files = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":self.policyUUID} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 日期
    if (self.policy.cp_date_begin) {
        [self.beginDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_begin.doubleValue]] forState:UIControlStateNormal];
    }else{
        [self.beginDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    if (self.policy.cp_date_end) {
        [self.endDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_end.doubleValue]] forState:UIControlStateNormal];
    }else{
        [self.endDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    // 名称
    if (self.policy.cp_name) {
        self.nameTextField.text = self.policy.cp_name;
    }
    // 我的保单
    if (self.policy.cp_my_policy && self.policy.cp_my_policy.integerValue==0) {
        self.isMyPolicySwitch.on = NO;
    }else{
        self.isMyPolicySwitch.on = YES;
    }
    // 详情
    if (self.policy.cp_description) {
        self.growingTextView.text = self.policy.cp_description;
    }
    // 缴费方式
    if (self.policy.cp_pay_type) {
        [self.payTypeButton setTitle:CP_POLICY_PAY_TYPE_TITLE_ITEM[self.policy.cp_pay_type.integerValue] forState:UIControlStateNormal];
    }
    // 缴费金额
    if (self.policy.cp_pay_amount) {
        self.payAmountTextField.text = [NSString stringWithFormat:@"%@",self.policy.cp_pay_amount];
    }
    // 付款方式
    if (self.policy.cp_pay_way) {
        [self.payWayButton setTitle:CP_POLICY_PAY_WAY_TITLE_ITEM[self.policy.cp_pay_way.integerValue] forState:UIControlStateNormal];
    }
    if (self.policy.cp_remind_date) {
        [self.remindDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_remind_date.doubleValue]] forState:UIControlStateNormal];
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
            // Button
            UIButton* buttonImage = [[UIButton alloc] initWithFrame:CGRectZero];
            [buttonImage setImageWithCPImage:image];
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
    [self.photoLayoutView removeConstraint:self.photoLayoutViewHeight];
    self.photoLayoutViewHeight = [NSLayoutConstraint constraintWithItem:self.photoLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:2*kFramePadding+(i/3)*(height+kImageSpacing)+height];
    [self.photoLayoutView addConstraint:self.photoLayoutViewHeight];
    [self.view setNeedsLayout];
}
#pragma mark - IBAction
- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:self.policyUUID?NO:YES];
}
- (IBAction)save:(id)sender {
    [self.view endEditing:YES];
    self.policy.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.policyUUID) {
        // 新增
        // 图片
        for (CPImage* image in self.files) {
            [[CPDB getLKDBHelperByUser] insertToDB:image];
        }
        // 保单
        [[CPDB getLKDBHelperByUser] insertToDB:self.policy];
        // 返回
        [self.navigationController popViewControllerAnimated:YES];
    } else{
        // 修改
        // 图片
        NSMutableArray* fileInDB = [[CPDB getLKDBHelperByUser] search:[CPImage class] where:@{@"cp_r_uuid":self.policyUUID} orderBy:nil offset:0 count:-1];
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
        // 保单
        [[CPDB getLKDBHelperByUser] updateToDB:self.policy where:nil];
        // 返回
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
- (IBAction)beginDateButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.policy.cp_date_begin) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_begin.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag, @(0), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)endDateButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.policy.cp_date_end) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_end.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag, @(1), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
- (IBAction)nameTextFieldValueChange:(UITextField*)sender {
    self.policy.cp_name = sender.text;
}
- (IBAction)isMyPolicySwitchValueChange:(UISwitch*)sender {
    self.policy.cp_my_policy = @(sender.on);
}

- (IBAction)payTypeButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_POLICY_PAY_TYPE_TITLE_ITEM delegate:self];
    self.popoverView.tag = 0;
}
- (IBAction)payAmountTextFieldValueChange:(UITextField*)sender {
    self.policy.cp_pay_amount = @(sender.text.integerValue);
}
- (IBAction)payWayButtonClick:(id)sender {
    UIView* button = sender;
    self.popoverView = [PopoverView showPopoverAtPoint:button.center inView:button.superview withStringArray:CP_POLICY_PAY_WAY_TITLE_ITEM delegate:self];
    self.popoverView.tag = 1;
}
- (IBAction)remindDateButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (self.policy.cp_remind_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:self.policy.cp_remind_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag, @(2), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
#pragma mark - Action
#define CP_MAX_PICTURE 9
- (void)addPictureButtonClick:(id)sender {
    if (self.files.count>=CP_MAX_PICTURE) {
        [[TWMessageBarManager sharedInstance] hideAll];
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                       description:[NSString stringWithFormat:@"最多包含%d张图片",CP_MAX_PICTURE]
                                                              type:TWMessageBarMessageTypeInfo];
        return;
    }
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
    float priorHeight = self.descriptionLayoutView.frame.size.height;
    priorHeight -= diff;
    [self.descriptionLayoutView removeConstraint:self.descriptionLayoutViewHeight];
    self.descriptionLayoutViewHeight = [NSLayoutConstraint constraintWithItem:self.descriptionLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.descriptionLayoutView.superview attribute:NSLayoutAttributeHeight multiplier:0 constant:priorHeight];
    [self.descriptionLayoutView addConstraint:self.descriptionLayoutViewHeight];
    [self.view layoutIfNeeded];
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    self.policy.cp_description = growingTextView.internalTextView.text;
}
#pragma mark - Date Picker Delegate
-(void)datePickerSetDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSDate* date = viewController.datePicker.date;
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    switch (tag.integerValue) {
        case 0:{
            self.policy.cp_date_begin = @([date timeIntervalSince1970]);
            [self.beginDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_begin.doubleValue]] forState:UIControlStateNormal];
            break;
        }
        case 1:{
            self.policy.cp_date_end = @([date timeIntervalSince1970]);
            [self.endDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_date_end.doubleValue]] forState:UIControlStateNormal];
            break;
        }
        case 2:{
            self.policy.cp_remind_date = @([date timeIntervalSince1970]);
            [self.remindDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.policy.cp_remind_date.doubleValue]] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

-(void)datePickerClearDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    switch (tag.integerValue) {
        case 0:{
            self.policy.cp_date_begin = nil;
            [self.beginDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
            break;
        }
        case 1:{
            self.policy.cp_date_end = nil;
            [self.endDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
            break;
        }
        case 2:{
            self.policy.cp_remind_date = nil;
            [self.remindDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

-(void)datePickerCancel:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
}
#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    switch (popoverView.tag) {
        case 0:{
            self.policy.cp_pay_type = @(index);
            [self.payTypeButton setTitle:CP_POLICY_PAY_TYPE_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        case 1:{
            self.policy.cp_pay_way = @(index);
            [self.payWayButton setTitle:CP_POLICY_PAY_WAY_TITLE_ITEM[index] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}
#pragma mark - FDTakeDelegate
- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info{
    // 缩放
    photo = [photo scaleToFitSize:CP_UI_PHOTO_SIZE_BROWSE];
    // 旋转
    photo = [photo fixOrientation];
    CPImage* image = [CPImage newAdaptDB];
    image.cp_r_uuid = self.policy.cp_uuid;
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
