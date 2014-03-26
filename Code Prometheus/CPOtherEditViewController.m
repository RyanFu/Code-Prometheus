//
//  CPOtherEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-11.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPOtherEditViewController.h"
#import "CPOther.h"
#import "CPCar.h"
#import <TDDatePickerController.h>
#import <Masonry.h>

static char CPAssociatedKeyTag;

// 日期
static NSString* const CP_DATE_TITLE_NULL = @"未定义";

@interface CPOtherEditViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *travelInsuranceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *groupInsuranceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *carInsuranceSwitch;
@property (weak, nonatomic) IBOutlet UIView *carLayoutView;

@property(nonatomic) CPOther* other;
@property(nonatomic) NSMutableArray* carArray;

// 日期选择器
@property(nonatomic) TDDatePickerController* datePickerView;
// 日期格式
@property (nonatomic) NSDateFormatter* df;
@end

@implementation CPOtherEditViewController
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
    if (!self.otherUUID) {
        self.other = [CPOther newAdaptDBWith:self.contactsUUID];
        self.carArray = [NSMutableArray array];
    }else {
        self.other = [[CPDB getLKDBHelperByUser] searchSingle:[CPOther class] where:@{@"cp_uuid":self.otherUUID} orderBy:nil];
        self.carArray = [[CPDB getLKDBHelperByUser] search:[CPCar class] where:@{@"cp_contact_uuid":self.other.cp_contact_uuid} orderBy:nil offset:0 count:-1];
    }
}
-(void) updateUI{
    // 是否买过旅行险
    if (self.other.cp_travel_insurance) {
        self.travelInsuranceSwitch.on = self.other.cp_travel_insurance.boolValue;
    }else{
        self.travelInsuranceSwitch.on = NO;
    }
    // 是否需要团险
    if (self.other.cp_group_insurance) {
        self.groupInsuranceSwitch.on = self.other.cp_group_insurance.boolValue;
    }else{
        self.groupInsuranceSwitch.on = NO;
    }
    // 是否需要车险
    if (self.other.cp_car_insurance) {
        self.carInsuranceSwitch.on = self.other.cp_car_insurance.boolValue;
    }else{
        self.carInsuranceSwitch.on = NO;
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
    NSInteger index = [self.carArray indexOfObject:car];
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
    // 按钮
    UIButton* carButton = [[UIButton alloc] initWithFrame:CGRectZero];
    carButton.tag = index;
    if (self.carArray.firstObject==car) {
        [carButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_ADD_0] forState:UIControlStateNormal];
        [carButton addTarget:self action:@selector(carAddButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [carButton setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_DELETE_0] forState:UIControlStateNormal];
        [carButton addTarget:self action:@selector(carDeleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [rootView addSubview:carButton];
    [carButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rootView.mas_right).offset(-20);
        make.width.equalTo(@(44));
        make.height.equalTo(@(44));
        make.centerY.equalTo(carTitleLabel.mas_centerY);
    }];
    // 车辆
    UITextField* carTextField = UITextField.new;
    carTextField.tag = index;
    [carTextField addTarget:self action:@selector(carNameTextFieldEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
    if (car.cp_name) {
        carTextField.text = car.cp_name;
    }
    [rootView addSubview:carTextField];
    [carTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(carTitleLabel.mas_right).offset(20);
        make.right.equalTo(carButton.mas_left).offset(-8);
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
    UITextField* carPlateNumberTextField = UITextField.new;
    carPlateNumberTextField.tag = index;
    [carPlateNumberTextField addTarget:self action:@selector(carPlateNumberTextFieldEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
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
    UIButton* carMaturityDateButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [carMaturityDateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    carMaturityDateButton.tag = index;
    if (car.cp_maturity_date) {
        [carMaturityDateButton setTitle:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:car.cp_maturity_date.doubleValue]] forState:UIControlStateNormal];
    }else{
        [carMaturityDateButton setTitle:CP_DATE_TITLE_NULL forState:UIControlStateNormal];
    }
    [carMaturityDateButton addTarget:self action:@selector(carMaturityDateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
#pragma mark - IBAction
- (IBAction)saveButtonClick:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    self.other.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.otherUUID) {
        // 新增车辆
        if (self.other.cp_car_insurance && self.other.cp_car_insurance.boolValue) {
            for (CPCar* car in self.carArray) {
                [[CPDB getLKDBHelperByUser] insertToDB:car];
            }
        }
        // 新增其他
        [[CPDB getLKDBHelperByUser] insertToDB:self.other];
        [self.navigationController popViewControllerAnimated:NO];
    } else{
        // 修改车辆
        NSMutableArray* carArrayInDB = [[CPDB getLKDBHelperByUser] search:[CPCar class] where:@{@"cp_contact_uuid":self.other.cp_contact_uuid} orderBy:nil offset:0 count:-1];
        if (self.other.cp_car_insurance && self.other.cp_car_insurance.boolValue) {
            // 删除车辆
            for (CPCar* car in carArrayInDB) {
                if ([self.carArray containsObject:car]) {
                    continue;
                }
                [[CPDB getLKDBHelperByUser] deleteToDB:car];
            }
            // 添加,修改车辆
            for (CPCar* car in self.carArray) {
                [[CPDB getLKDBHelperByUser] insertToDB:car];
            }
        }else{
            // 删除全部车辆
            for (CPCar* car in carArrayInDB) {
                [[CPDB getLKDBHelperByUser] deleteToDB:car];
            }
        }
        // 修改家庭
        [[CPDB getLKDBHelperByUser] updateToDB:self.other where:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
-(IBAction)cancelButtonClick:(id)sender{
    // 返回上个视图
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)travelInsuranceSwitchValueChange:(UISwitch*)sender {
    self.other.cp_travel_insurance = @(sender.on);
}
- (IBAction)groupInsuranceSwitchValueChange:(UISwitch*)sender {
    self.other.cp_group_insurance = @(sender.on);
}
- (IBAction)carInsuranceSwitchValueChange:(UISwitch*)sender {
    self.other.cp_car_insurance = @(sender.on);
    if (self.other.cp_car_insurance && self.other.cp_car_insurance.boolValue) {
        if (!self.carArray) {
            self.carArray = [NSMutableArray array];
        }
        if (self.carArray.count ==0) {
            CPCar* car = [CPCar newAdaptDBWith:self.other.cp_contact_uuid];
            [self.carArray addObject:car];
        }
    }
    [self updateCarUI];
}

#pragma mark - Action
- (void) carNameTextFieldEndEdit:(UITextField*)sender{
    CPCar* car = self.carArray[sender.tag];
    car.cp_name = sender.text;
}
- (void) carPlateNumberTextFieldEndEdit:(UITextField*)sender{
    CPCar* car = self.carArray[sender.tag];
    car.cp_plate_number = sender.text;
}
- (void) carAddButtonClick:(UIButton*)sender{
    CPCar* car = [CPCar newAdaptDBWith:self.other.cp_contact_uuid];
    [self.carArray addObject:car];
    [self updateCarUI];
}
- (void) carDeleteButtonClick:(UIButton*)sender{
    [self.carArray removeObjectAtIndex:sender.tag];
    [self updateCarUI];
}
- (void) carMaturityDateButtonClick:(UIButton*)sender{
    [self.view endEditing:YES];
    CPCar* car = self.carArray[sender.tag];
    self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
    self.datePickerView.delegate = self;
    if (car.cp_maturity_date) {
        self.datePickerView.date = [NSDate dateWithTimeIntervalSince1970:car.cp_maturity_date.doubleValue];
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyTag,@(sender.tag), OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
#pragma mark - Date Picker Delegate
-(void)datePickerSetDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    CPCar* car = self.carArray[tag.integerValue];
    car.cp_maturity_date = @([viewController.datePicker.date timeIntervalSince1970]);
    [self updateCarUI];
}
-(void)datePickerClearDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    NSNumber* tag = objc_getAssociatedObject(viewController, &CPAssociatedKeyTag);
    CPCar* car = self.carArray[tag.integerValue];
    car.cp_maturity_date = nil;
    [self updateCarUI];
}
-(void)datePickerCancel:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
}
@end
