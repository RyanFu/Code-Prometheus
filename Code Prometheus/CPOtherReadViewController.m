//
//  CPOtherReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-11.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPOtherReadViewController.h"
#import "CPOther.h"
#import "CPCar.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

// 日期
static NSString* const CP_DATE_TITLE_NULL = @"未定义";

@interface CPOtherReadViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *travelInsuranceLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupInsuranceLabel;
@property (weak, nonatomic) IBOutlet UILabel *carInsuranceLabel;
@property (weak, nonatomic) IBOutlet UIView *carLayoutView;

@property(nonatomic) CPOther* other;
@property(nonatomic) NSMutableArray* carArray;

// 日期格式
@property (nonatomic) NSDateFormatter* df;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPOtherReadViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPOther class]) object:nil];
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
    if ([segue.identifier isEqualToString:@"cp_segue_other_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
        [controller setValue:self.other.cp_uuid forKey:@"otherUUID"];
    }
}
#pragma mark - private
-(void) loadDB{
    self.other = [[CPDB getLKDBHelperByUser] searchSingle:[CPOther class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil];
    self.carArray = [[CPDB getLKDBHelperByUser] search:[CPCar class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil offset:0 count:-1];
}
-(void) updateUI{
    // 是否买过旅行险
    if (self.other.cp_travel_insurance) {
        self.travelInsuranceLabel.text = self.other.cp_travel_insurance.boolValue?@"是":@"否";
    }else{
        self.travelInsuranceLabel.text = @"否";
    }
    // 是否需要团险
    if (self.other.cp_group_insurance) {
        self.groupInsuranceLabel.text = self.other.cp_group_insurance.boolValue?@"是":@"否";
    }else{
        self.groupInsuranceLabel.text = @"否";
    }
    // 是否需要车险
    if (self.other.cp_car_insurance) {
        self.carInsuranceLabel.text = self.other.cp_car_insurance.boolValue?@"是":@"否";
    }else{
        self.carInsuranceLabel.text = @"否";
    }
    // 汽车
    [self updateCarUI];
}
-(void) updateCarUI{
    for(UIView *subv in [self.carLayoutView subviews])
    {
        [subv removeFromSuperview];
    }
    if (self.other.cp_car_insurance && self.other.cp_car_insurance.boolValue) {
        if (self.carArray && self.carArray.count>0) {
            for (CPCar* car in self.carArray) {
                UIView* cv = [self carEditViewWithCar:car];
                [self.carLayoutView addSubview:cv];
            }
        }
    }
    [self layoutCarLayoutView];
}
-(UIView*) carEditViewWithCar:(CPCar*)car{
    // 根View
    UIView* rootView = UIView.new;
    // 车辆标题
    UILabel* carTitleLabel = [UILabel new];
    carTitleLabel.text = @"车辆";
    [rootView addSubview:carTitleLabel];
    [carTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@11);
        make.left.equalTo(@20);
        make.width.equalTo(@120);
        make.height.equalTo(@21);
    }];
    // 车辆
    UILabel* carTextField = UILabel.new;
    if (car.cp_name) {
        carTextField.text = car.cp_name;
    }
    [rootView addSubview:carTextField];
    [carTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(carTitleLabel.mas_right).offset(20);
        make.right.equalTo(rootView.mas_right).offset(-20);
        make.height.equalTo(@(30));
        make.centerY.equalTo(carTitleLabel.mas_centerY);
    }];
    // 车牌号标题
    UILabel* carPlateNumberTitleLabel = [UILabel new];
    carPlateNumberTitleLabel.text = @"车牌号";
    [rootView addSubview:carPlateNumberTitleLabel];
    [carPlateNumberTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(carTitleLabel.mas_bottom).offset(23);
        make.centerX.equalTo(carTitleLabel.mas_centerX);
        make.width.equalTo(carTitleLabel.mas_width);
        make.height.equalTo(carTitleLabel.mas_height);
    }];
    // 车牌号
    UILabel* carPlateNumberTextField = UILabel.new;
    if (car.cp_plate_number) {
        carPlateNumberTextField.text = car.cp_plate_number;
    }
    [rootView addSubview:carPlateNumberTextField];
    [carPlateNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(carPlateNumberTitleLabel.mas_right).offset(20);
        make.right.equalTo(rootView.mas_right).offset(-20);
        make.height.equalTo(@(30));
        make.centerY.equalTo(carPlateNumberTitleLabel.mas_centerY);
    }];
    // 车险到期标题
    UILabel* carMaturityDateTitleLabel = [UILabel new];
    carMaturityDateTitleLabel.text = @"车险到期日";
    [rootView addSubview:carMaturityDateTitleLabel];
    [carMaturityDateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(carPlateNumberTitleLabel.mas_bottom).offset(23);
        make.centerX.equalTo(carTitleLabel.mas_centerX);
        make.width.equalTo(carTitleLabel.mas_width);
        make.height.equalTo(carTitleLabel.mas_height);
    }];
    // 车险到期
    UILabel* carMaturityDateButton = UILabel.new;
    if (car.cp_maturity_date) {
        carMaturityDateButton.text = [self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:car.cp_maturity_date.doubleValue]];
    }else{
        carMaturityDateButton.text = CP_DATE_TITLE_NULL;
    }
    [rootView addSubview:carMaturityDateButton];
    [carMaturityDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(carMaturityDateTitleLabel.mas_right).offset(20);
        make.right.equalTo(rootView.mas_right).offset(-20);
        make.height.equalTo(@(30));
        make.centerY.equalTo(carMaturityDateTitleLabel.mas_centerY);
    }];
    // 分割线
    UIView* fenge = UIView.new;
    fenge.backgroundColor = [UIColor lightGrayColor];
    [rootView addSubview:fenge];
    [fenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.right.equalTo(@(0));
        make.height.equalTo(@(1));
        make.top.equalTo(carMaturityDateTitleLabel.mas_bottom).offset(11);
        make.bottom.equalTo(@(0));
    }];
    return rootView;
}
- (void)layoutCarLayoutView{
    for (UIView* subview in self.carLayoutView.subviews) {
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            if (subview == self.carLayoutView.subviews.firstObject) {
                make.top.equalTo(@(0));
            }else{
                NSInteger index = [self.carLayoutView.subviews indexOfObject:subview];
                UIView* lastView = self.carLayoutView.subviews[index-1];
                make.top.equalTo(lastView.mas_bottom);
            }
            if (subview == self.carLayoutView.subviews.lastObject) {
                make.bottom.equalTo(@(0));
            }
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
        }];
    }
    [self.view setNeedsLayout];
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
@end
