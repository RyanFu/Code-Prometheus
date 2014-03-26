//
//  CPScheduleViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-13.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPScheduleViewController.h"
#import <Masonry.h>
#import <PopoverView.h>
#import "CPContacts.h"
#import "CPTrace.h"
#import "CPPolicy.h"
#import <NSDate-Utilities.h>
#import <ABCalendarPicker.h>
#import "CPCalendarPickerStyleProvider.h"
#import <MBProgressHUD.h>
#import <PopoverView_Configuration.h>

static char CPAssociatedKeyCellTag;
static char CPAssociatedKeyTrace;
static char CPAssociatedKeyPolicy;
static char CPAssociatedKeyContacts;

typedef NS_ENUM(NSInteger, CP_SCHEDULE_TYPE) {
    CP_SCHEDULE_TYPE_ALL,
    CP_SCHEDULE_TYPE_TRACE,
    CP_SCHEDULE_TYPE_PAY_REMIND,
    CP_SCHEDULE_TYPE_BIRTHDAY
};

typedef NS_ENUM(NSInteger, CP_CELL_TAG) {
    CP_CELL_TAG_TRACE,
    CP_CELL_TAG_PAY_REMIND,
    CP_CELL_TAG_BIRTHDAY
};

#define CP_SCHEDULE_TYPE_TITLE @[@"全部日程",@"跟进信息",@"缴费提醒",@"客户生日"]

@interface CPScheduleViewController ()<UITableViewDataSource,UITableViewDelegate,ABCalendarPickerDelegateProtocol,ABCalendarPickerDataSourceProtocol,PopoverViewDelegate>
// IBOutlet
@property (weak, nonatomic) IBOutlet ABCalendarPicker *calendarPicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
// 弹窗
@property (nonatomic,weak) PopoverView* popoverView;
// 日程类型
@property (nonatomic) CP_SCHEDULE_TYPE type;

// table显示的数据
@property (nonatomic) NSMutableArray* contactsForTable;
@end

@implementation CPScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPContacts class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPTrace class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPPolicy class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:CPSyncDoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:CPLogoutNotification object:nil];
    // 日历类型
    self.type = CP_SCHEDULE_TYPE_ALL;
    // 代理
    self.calendarPicker.delegate = self;
    self.calendarPicker.dataSource = self;
    // 自定义日历插件
    ABCalendarPickerDefaultStyleProvider* style = [[CPCalendarPickerStyleProvider alloc] init];
//    [style set]
    self.calendarPicker.styleProvider = style;
    // 导航栏标题更新
    [self updateNavigationTitle];
    // 日历高度
    [self calendarPicker:self.calendarPicker animateNewHeight:self.calendarPicker.bounds.size.height];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self.calendarPicker updateStateAnimated:YES];
        self.dirty = NO;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_schedule_2_trace"])
    {
        UITableViewCell* cell = sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        CPContacts* contacts = self.contactsForTable[indexPath.row];
        CPTrace* trace = objc_getAssociatedObject(contacts, &CPAssociatedKeyTrace);
        id controller = segue.destinationViewController;
        [controller setValue:trace.cp_uuid forKey:@"traceUUID"];
    }
    if ([segue.identifier isEqualToString:@"cp_segue_schedule_2_policy"])
    {
        UITableViewCell* cell = sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        CPContacts* contacts = self.contactsForTable[indexPath.row];
        CPPolicy* policy = objc_getAssociatedObject(contacts, &CPAssociatedKeyPolicy);
        id controller = segue.destinationViewController;
        [controller setValue:policy.cp_uuid forKey:@"policyUUID"];
    }
}
#pragma mark - private
- (void) updateNavigationTitle{
    if (!self.navigationItem.titleView) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
        [button setImage:sortImage forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
        [button addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = button;
    }
    
    UIButton* button = (UIButton*)self.navigationItem.titleView;
    [button setTitle:CP_SCHEDULE_TYPE_TITLE[self.type] forState:UIControlStateNormal];
    CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
    [button sizeToFit];
}

-(BOOL) hasTraceInDBCorrectToDayWithDate:(NSDate*)date{
    __block BOOL result = NO;
    NSTimeInterval min = [[date dateAtStartOfDay] timeIntervalSince1970];
    NSTimeInterval max = min+D_DAY;
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_trace WHERE cp_date>=? AND cp_date<?" withArgumentsInArray:@[@(min),@(max)]];
        int columeCount = [set columnCount];
        while ([set next]) {
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        result = sqlValue.integerValue>0;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        [set close];
    }];
    return result;
}
-(BOOL) hasPolicyInDBCorrectToDayWithDate:(NSDate*)date{
    __block BOOL result = NO;
    NSTimeInterval min = [[date dateAtStartOfDay] timeIntervalSince1970];
    NSTimeInterval max = min+D_DAY;
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_insurance_policy WHERE cp_remind_date>=? AND cp_remind_date<?" withArgumentsInArray:@[@(min),@(max)]];
        int columeCount = [set columnCount];
        while ([set next]) {
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        result = sqlValue.integerValue>0;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        [set close];
    }];
    return result;
}
-(BOOL) hasBirthdayInDBCorrectToDayWithDate:(NSDate*)date{
    __block BOOL result = NO;
    static NSDateFormatter* df = nil;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
    }
    NSString* birthdayLike = [df stringFromDate:date];
    NSRange range;
    range.location = 0;
    range.length = 4;
    birthdayLike = [birthdayLike stringByReplacingCharactersInRange:range withString:@"____"];
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_contacts WHERE cp_birthday LIKE ?" withArgumentsInArray:@[birthdayLike]];
        int columeCount = [set columnCount];
        while ([set next]) {
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        result = sqlValue.integerValue>0;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        [set close];
    }];
    return result;
}
-(NSMutableArray*) contactsWithTraceArryInDBCorrectToDayWithDate:(NSDate*)date{
    NSTimeInterval min = [[date dateAtStartOfDay] timeIntervalSince1970];
    NSTimeInterval max = min+D_DAY;
    NSMutableArray* contactsArray = [NSMutableArray array];
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name,t.cp_uuid,t.cp_date,t.cp_description FROM cp_contacts c INNER JOIN cp_trace t ON c.cp_uuid=t.cp_contact_uuid WHERE t.cp_date>=? AND t.cp_date<?" withArgumentsInArray:@[@(min),@(max)]];
        int columeCount = [set columnCount];
        while ([set next]) {
            CPContacts* contacts = CPContacts.new;
            CPTrace* trace = CPTrace.new;
            objc_setAssociatedObject(contacts, &CPAssociatedKeyTrace, trace, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(contacts, &CPAssociatedKeyCellTag, @(CP_CELL_TAG_TRACE), OBJC_ASSOCIATION_RETAIN);
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        contacts.cp_uuid = sqlValue;
                        break;
                    }
                    case 1:{
                        contacts.cp_name = sqlValue;
                        break;
                    }
                    case 2:{
                        trace.cp_uuid = sqlValue;
                        break;
                    }
                    case 3:{
                        if (sqlValue) {
                            trace.cp_date = [NSNumber numberWithDouble:sqlValue.doubleValue];
                        }else{
                            trace.cp_date = nil;
                        }
                        break;
                    }
                    case 4:{
                        trace.cp_description = sqlValue;
                        break;
                    }
                    default:
                        break;
                }
            }
            [contactsArray addObject:contacts];
        }
        [set close];
    }];
    return contactsArray;
}
-(NSMutableArray*) contactsWithPolicyArryInDBCorrectToDayWithDate:(NSDate*)date{
    NSTimeInterval min = [[date dateAtStartOfDay] timeIntervalSince1970];
    NSTimeInterval max = min+D_DAY;
    NSMutableArray* contactsArray = [NSMutableArray array];
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name,i.cp_uuid,i.cp_name FROM cp_contacts c INNER JOIN cp_insurance_policy i ON c.cp_uuid=i.cp_contact_uuid WHERE i.cp_remind_date>=? AND i.cp_remind_date<?" withArgumentsInArray:@[@(min),@(max)]];
        int columeCount = [set columnCount];
        while ([set next]) {
            CPContacts* contacts = CPContacts.new;
            CPPolicy* policy = CPPolicy.new;
            objc_setAssociatedObject(contacts, &CPAssociatedKeyPolicy, policy, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(contacts, &CPAssociatedKeyCellTag, @(CP_CELL_TAG_PAY_REMIND), OBJC_ASSOCIATION_RETAIN);
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        contacts.cp_uuid = sqlValue;
                        break;
                    }
                    case 1:{
                        contacts.cp_name = sqlValue;
                        break;
                    }
                    case 2:{
                        policy.cp_uuid = sqlValue;
                        break;
                    }
                    case 3:{
                        policy.cp_name = sqlValue;
                        break;
                    }
                    default:
                        break;
                }
            }
            [contactsArray addObject:contacts];
        }
        [set close];
    }];
    return contactsArray;
}
-(NSMutableArray*) contactsCaredBirthdayArryInDBWithDate:(NSDate*)date{
    static NSDateFormatter* df = nil;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
    }
    NSString* birthdayLike = [df stringFromDate:date];
    NSRange range;
    range.location = 0;
    range.length = 4;
    birthdayLike = [birthdayLike stringByReplacingCharactersInRange:range withString:@"____"];
    NSMutableArray* contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:[NSString stringWithFormat:@"cp_birthday LIKE '%@'",birthdayLike] orderBy:nil offset:0 count:-1];
    for (CPContacts* contacts in contactsArray) {
        objc_setAssociatedObject(contacts, &CPAssociatedKeyCellTag, @(CP_CELL_TAG_BIRTHDAY), OBJC_ASSOCIATION_RETAIN);
    }
    return contactsArray;
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - IBAction
#warning 如果电话号码里有非法符号，能否拨号,短信,email？
-(IBAction)telAction:(UIButton*)sender{
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    CPContacts* contacts = self.contactsForTable[indexPath.row];
    NSString *number = contacts.cp_phone_number;
    if (number) {
        NSArray* numbers = [number componentsSeparatedByString:@" "];
        if (numbers.count>1) {
            self.popoverView = [PopoverView showPopoverAtPoint:[sender center] inView:[sender superview] withStringArray:numbers delegate:self];
            objc_setAssociatedObject(self.popoverView, &CPAssociatedKeyContacts, contacts,OBJC_ASSOCIATION_RETAIN);
            self.popoverView.tag = 1;
            return;
        }else if (numbers.count ==1){
            NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",numbers[0]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
            return;
        }
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请完善手机号" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alert show];
}
#warning 可以做成程序内发短信
-(IBAction)smsAction:(UIButton*)sender{
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    CPContacts* contacts = self.contactsForTable[indexPath.row];
    NSString *number = contacts.cp_phone_number;
    if (number) {
        NSArray* numbers = [number componentsSeparatedByString:@" "];
        if (numbers.count>1) {
            self.popoverView = [PopoverView showPopoverAtPoint:[sender center] inView:[sender superview] withStringArray:numbers delegate:self];
            objc_setAssociatedObject(self.popoverView, &CPAssociatedKeyContacts, contacts,OBJC_ASSOCIATION_RETAIN);
            self.popoverView.tag = 2;
            return;
        }else if (numbers.count ==1){
            NSString *num = [[NSString alloc] initWithFormat:@"sms://%@",numbers[0]];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:num]];
            return;
        }
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请完善手机号" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alert show];
}
#pragma mark - Action
#define CP_SCHEDULE_TYPE_IMAGE @[@"cp_schedule_all",@"cp_schedule_blue",@"cp_schedule_red",@"cp_schedule_yellow"]
-(void) changeType:(UIButton*)sender{
    PopoverView *popoverView = [[PopoverView alloc] initWithFrame:CGRectZero];
    popoverView.delegate = self;
    self.popoverView = popoverView;
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] initWithCapacity:CP_SCHEDULE_TYPE_TITLE.count];
    UIFont *font = kTextFont;
    NSArray* typeArray = CP_SCHEDULE_TYPE_TITLE;
    for(NSString *string in typeArray) {
        CGSize textSize = [string sizeWithFont:font];
        UIButton *textButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 40, textSize.height)];
        textButton.backgroundColor = [UIColor clearColor];
        textButton.titleLabel.font = font;
        textButton.titleLabel.textAlignment = kTextAlignment;
        textButton.titleLabel.textColor = kTextColor;
        [textButton setTitle:string forState:UIControlStateNormal];
        [textButton setImage:[UIImage imageNamed:CP_SCHEDULE_TYPE_IMAGE[[typeArray indexOfObject:string]]] forState:UIControlStateNormal];
        [textButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        if ([typeArray indexOfObject:string] == self.type) {
            textButton.backgroundColor = [UIColor colorWithRed:0 green:205/255.0 blue:255/255.0 alpha:1];
        }
        textButton.layer.cornerRadius = 4.f;
        [textButton setTitleColor:kTextColor forState:UIControlStateNormal];
        [textButton setTitleColor:[UIColor colorWithRed:0.098 green:0.102 blue:0.106 alpha:1.000] forState:UIControlStateHighlighted];
        [textButton addTarget:popoverView action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [labelArray addObject:textButton];
    }
    
    [popoverView showAtPoint:CGPointMake(sender.frame.origin.x + sender.frame.size.width, sender.frame.origin.y + sender.frame.size.height) inView:sender.superview withViewArray:labelArray];
    
}
#pragma mark - ABCalendarPickerDataSourceProtocol
- (NSInteger)calendarPicker:(ABCalendarPicker*)calendarPicker numberOfEventsForDate:(NSDate*)date onState:(ABCalendarPickerState)state
{
    switch (self.type) {
        case CP_SCHEDULE_TYPE_ALL:{
            CP_CELL_TYPE cell_type = CP_CELL_TYPE_NORMAL;
            if ([self hasTraceInDBCorrectToDayWithDate:date]) {
                if (cell_type == CP_CELL_TYPE_NORMAL || cell_type == CP_CELL_TYPE_TRACE) {
                    cell_type = CP_CELL_TYPE_TRACE;
                }else{
                    cell_type = CP_CELL_TYPE_MULTIPLE;
                }
            }
            if ([self hasPolicyInDBCorrectToDayWithDate:date]) {
                if (cell_type == CP_CELL_TYPE_NORMAL || cell_type == CP_CELL_TYPE_PAY_REMIND) {
                    cell_type = CP_CELL_TYPE_PAY_REMIND;
                }else{
                    cell_type = CP_CELL_TYPE_MULTIPLE;
                }
            }
            if ([self hasBirthdayInDBCorrectToDayWithDate:date]) {
                if (cell_type == CP_CELL_TYPE_NORMAL || cell_type == CP_CELL_TYPE_BIRTHDAY) {
                    cell_type = CP_CELL_TYPE_BIRTHDAY;
                }else{
                    cell_type = CP_CELL_TYPE_MULTIPLE;
                }
            }
            return cell_type;
            break;
        }
        case CP_SCHEDULE_TYPE_TRACE:{
            if ([self hasTraceInDBCorrectToDayWithDate:date]) {
                return CP_CELL_TYPE_TRACE;
            }else{
                return CP_CELL_TYPE_NORMAL;
            }
            break;
        }
        case CP_SCHEDULE_TYPE_PAY_REMIND:{
            if ([self hasPolicyInDBCorrectToDayWithDate:date]) {
                return CP_CELL_TYPE_PAY_REMIND;
            }else{
                return CP_CELL_TYPE_NORMAL;
            }
            break;
        }
        case CP_SCHEDULE_TYPE_BIRTHDAY:{
            if ([self hasBirthdayInDBCorrectToDayWithDate:date]) {
                return CP_CELL_TYPE_BIRTHDAY;
            }else{
                return CP_CELL_TYPE_NORMAL;
            }
            break;
        }
        default:
            break;
    }
    return CP_CELL_TYPE_NORMAL;
}

#pragma mark - ABCalendarPickerDelegateProtocol
- (void)calendarPicker:(ABCalendarPicker *)calendarPicker animateNewHeight:(CGFloat)height
{
    [calendarPicker mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    [self.view layoutSubviews];
}
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker dateSelected:(NSDate*)date withState:(ABCalendarPickerState)state{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        // 清空table数据
        if (self.contactsForTable) {
            [self.contactsForTable removeAllObjects];
            self.contactsForTable = nil;
        }
        self.contactsForTable = [NSMutableArray array];
        // 如果不是 day Weekdays 模式,则返回
        if(state != ABCalendarPickerStateDays && state != ABCalendarPickerStateWeekdays){
            [self.tableView reloadData];
            return;
        }
        switch (self.type) {
            case CP_SCHEDULE_TYPE_ALL:{
                [self.contactsForTable addObjectsFromArray:[self contactsWithTraceArryInDBCorrectToDayWithDate:date]];
                [self.contactsForTable addObjectsFromArray:[self contactsWithPolicyArryInDBCorrectToDayWithDate:date]];
                [self.contactsForTable addObjectsFromArray:[self contactsCaredBirthdayArryInDBWithDate:date]];
                break;
            }
            case CP_SCHEDULE_TYPE_TRACE:{
                [self.contactsForTable addObjectsFromArray:[self contactsWithTraceArryInDBCorrectToDayWithDate:date]];
                break;
            }
            case CP_SCHEDULE_TYPE_PAY_REMIND:{
                [self.contactsForTable addObjectsFromArray:[self contactsWithPolicyArryInDBCorrectToDayWithDate:date]];
                break;
            }
            case CP_SCHEDULE_TYPE_BIRTHDAY:{
                [self.contactsForTable addObjectsFromArray:[self contactsCaredBirthdayArryInDBWithDate:date]];
                break;
            }
            default:
                break;
        }
    } completionBlock:^{
        [self.tableView reloadData];
        [hud removeFromSuperview];
    }];
}
- (BOOL)calendarPicker:(ABCalendarPicker*)calendarPicker
        shouldSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState{
    if (fromState == ABCalendarPickerStateDays && state == ABCalendarPickerStateWeekdays) {
        return YES;
    }
    if (fromState == ABCalendarPickerStateWeekdays && state == ABCalendarPickerStateDays) {
        return YES;
    }
    return NO;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contactsForTable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifierTrace = @"cell_trace";
    static NSString *identifierPayRemind = @"cell_pay_remind";
    static NSString *identifierBirthday = @"cell_birthday";
    
    static NSInteger const CP_TRACE_CELL_SUB_TAG_1 = 10001;
    static NSInteger const CP_TRACE_CELL_SUB_TAG_2 = 10002;
    static NSInteger const CP_TRACE_CELL_SUB_TAG_3 = 10003;
    
    CPContacts* contacts = self.contactsForTable[indexPath.row];
    UITableViewCell *cell = nil;
    NSNumber* tag = objc_getAssociatedObject(contacts, &CPAssociatedKeyCellTag);
    NSAssert(tag != nil, @"tag 为 nil ! %@",self);
    switch (tag.integerValue) {
        case CP_CELL_TAG_TRACE:{
            cell = [tableView dequeueReusableCellWithIdentifier:identifierTrace forIndexPath:indexPath];
            CPTrace* trace = objc_getAssociatedObject(contacts, &CPAssociatedKeyTrace);
            NSAssert(trace != nil, @"trace 为 nil ! %@",self);
            NSAssert(trace.cp_date != nil, @"trace.cp_date 为 nil ! %@",self);
            static NSDateFormatter* CP_DF_Trace = nil;
            if (!CP_DF_Trace) {
                CP_DF_Trace = [[NSDateFormatter alloc] init];
                [CP_DF_Trace setDateFormat:@"hh:mm"];
            }
            // 时间
            UILabel* dateLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_1];
            dateLabel.text = [CP_DF_Trace stringFromDate:[NSDate dateWithTimeIntervalSince1970:trace.cp_date.doubleValue]];
            // 姓名
            UILabel* nameLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_2];
            nameLabel.text = contacts.cp_name;
            // 内容
            UILabel* descriptionLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_3];
            descriptionLabel.text = trace.cp_description;
            break;
        }
        case CP_CELL_TAG_PAY_REMIND:{
            cell = [tableView dequeueReusableCellWithIdentifier:identifierPayRemind forIndexPath:indexPath];
            CPPolicy* policy = objc_getAssociatedObject(contacts, &CPAssociatedKeyPolicy);
            NSAssert(policy != nil, @"policy 为 nil ! %@",self);
            // 姓名
            UILabel* nameLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_1];
            nameLabel.text = contacts.cp_name;
            // 内容
            UILabel* descriptionLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_2];
            descriptionLabel.text = policy.cp_name;
            break;
        }
        case CP_CELL_TAG_BIRTHDAY:{
            cell = [tableView dequeueReusableCellWithIdentifier:identifierBirthday forIndexPath:indexPath];
            // 姓名
            UILabel* nameLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_1];
            nameLabel.text = contacts.cp_name;
            // 年龄
            UILabel* ageLabel = (UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_2];
            static NSDateFormatter* df = nil;
            if (!df) {
                df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd";
            }
            NSDate* dateBirthday = [df dateFromString:contacts.cp_birthday];
            ageLabel.text = [NSString stringWithFormat:@"%d岁",[NSDate date].year - dateBirthday.year];
            break;
        }
        default:
            break;
    }
    return cell;
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    switch (popoverView.tag) {
        case 0:{
            // 切换查看模式
            if (self.type != index) {
                self.type = index;
                [self updateNavigationTitle];
                [self.calendarPicker updateStateAnimated:YES];
            }
            break;
        }
        case 1:{
            // 电话
            CPContacts* contacts = objc_getAssociatedObject(popoverView, &CPAssociatedKeyContacts);
            NSArray* numbers = [contacts.cp_phone_number componentsSeparatedByString:@" "];
            NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",numbers[index]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
            break;
        }
        case 2:{
            // 短信
            CPContacts* contacts = objc_getAssociatedObject(popoverView, &CPAssociatedKeyContacts);
            NSArray* numbers = [contacts.cp_phone_number componentsSeparatedByString:@" "];
            NSString *num = [[NSString alloc] initWithFormat:@"sms://%@",numbers[index]];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:num]];
            break;
        }
        default:
            break;
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}
@end
