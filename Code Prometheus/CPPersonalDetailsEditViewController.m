//
//  CPPersonalDetailsEditViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPersonalDetailsEditViewController.h"
#import "CPContacts.h"
#import <TDDatePickerController.h>
#import <PopoverView.h>

static char CPAssociatedKeyIndexPath;

// cell标题
static NSString* const CP_CONTACTS_CELL_TITLE_NAME = @"姓名";
static NSString* const CP_CONTACTS_CELL_TITLE_SEX = @"性别";
static NSString* const CP_CONTACTS_CELL_TITLE_PHONE_NUMBER = @"手机";
static NSString* const CP_CONTACTS_CELL_TITLE_BIRTHDAY = @"生日";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE = @"线索来源";
static NSString* const CP_CONTACTS_CELL_TITLE_WECHAT = @"微信";
static NSString* const CP_CONTACTS_CELL_TITLE_QQ = @"QQ";
static NSString* const CP_CONTACTS_CELL_TITLE_EMAIL = @"邮箱";
static NSString* const CP_CONTACTS_CELL_TITLE_BLOOD_TYPE = @"血型";
static NSString* const CP_CONTACTS_CELL_TITLE_HEIGHT = @"身高";
static NSString* const CP_CONTACTS_CELL_TITLE_WEIGHT = @"体重";
static NSString* const CP_CONTACTS_CELL_TITLE_HOBBY = @"爱好";
static NSString* const CP_CONTACTS_CELL_TITLE_NATIVE_PLACE = @"籍贯";
// 性别
static NSString* const CP_CONTACTS_CELL_TITLE_SEX_MAN = @"男";
static NSString* const CP_CONTACTS_CELL_TITLE_SEX_WOMAN = @"女";
// 线索来源
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_NULL = @"-无-";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_QUESTIONNAIRE = @"陌生问卷";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_LOT = @"陌生随缘";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_PHONE = @"陌生电话";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_BAZAAR_LOT = @"缘故市场";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_INTRODUCTION = @"被转介绍";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_NETWORK = @"网络来源";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_BAZAAR_TALENT = @"人才市场";
static NSString* const CP_CONTACTS_CELL_TITLE_SOURCE_PEER = @"保险同业";
#define CP_CONTACTS_CELL_TITLE_SOURCE_ITEM @[CP_CONTACTS_CELL_TITLE_SOURCE_NULL,CP_CONTACTS_CELL_TITLE_SOURCE_QUESTIONNAIRE,CP_CONTACTS_CELL_TITLE_SOURCE_LOT,CP_CONTACTS_CELL_TITLE_SOURCE_PHONE,CP_CONTACTS_CELL_TITLE_SOURCE_BAZAAR_LOT,CP_CONTACTS_CELL_TITLE_SOURCE_INTRODUCTION,CP_CONTACTS_CELL_TITLE_SOURCE_NETWORK,CP_CONTACTS_CELL_TITLE_SOURCE_BAZAAR_TALENT,CP_CONTACTS_CELL_TITLE_SOURCE_PEER]
// 生日
static NSString* const CP_CONTACTS_CELL_TITLE_BIRTHDAY_NULL = @"未定义";
// 血型
static NSString* const CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_A = @"A型";
static NSString* const CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_B = @"B型";
static NSString* const CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_AB = @"AB型";
static NSString* const CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_O = @"O型";
#define CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_ITEM @[CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_A,CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_B,CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_AB,CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_O]

@interface CPPersonalDetailsEditViewController ()<PopoverViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) CPContacts* contacts;
@property(nonatomic) NSMutableArray* phoneNumbers;

// 生日选择器
@property(nonatomic) TDDatePickerController* datePickerView;
// 弹窗
@property (nonatomic) PopoverView* popoverView;
@end

@implementation CPPersonalDetailsEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadContacts];
    [self initPhoneNumbers];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_info_edit_2_refer"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contacts forKey:@"contacts"];
    }
}

#pragma mark - private
-(void) loadContacts{
    if (!self.contactsUUID) {
        self.contacts = [CPContacts newAdaptDB];
    }else {
        self.contacts = [[CPDB getLKDBHelperByUser] searchSingle:[CPContacts class] where:@{@"cp_uuid":self.contactsUUID} orderBy:nil];
    }
}

-(void) initPhoneNumbers{
    if (self.contacts && self.contacts.cp_phone_number) {
        NSArray* numbers = [self.contacts.cp_phone_number componentsSeparatedByString:@" "];
        if (numbers && numbers.count>0) {
            self.phoneNumbers = [NSMutableArray arrayWithArray:numbers];
            return;
        }
    }
    self.phoneNumbers = [NSMutableArray array];
    [self.phoneNumbers addObject:@""];
}
-(NSMutableString*) phoneNumbersStringWithArray:(NSArray*)array{
    NSMutableString* phoneNumber = [NSMutableString string];
    for (NSString * num in self.phoneNumbers) {
        [phoneNumber appendFormat:@"%@ ",num];
    }
    if (![phoneNumber isEqualToString:@""]) {
        NSRange range;
        range.length=1;
        range.location=phoneNumber.length-1;
        [phoneNumber deleteCharactersInRange:range];
    }
    return phoneNumber;
}

#pragma mark - Action
-(void) editContactsName:(UITextField*)sender{
    self.contacts.cp_name = sender.text;
}
-(void) editContactsSex:(UISwitch*)sender{
    self.contacts.cp_sex = sender.on?@(0):@(1);
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
-(void) editContactsPhoneNumber:(UITextField*)sender{
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    NSInteger index = indexPath.row-2;
    self.phoneNumbers[index]=sender.text;
    NSString* phoneNumber = [self phoneNumbersStringWithArray:self.phoneNumbers];
    CPLogVerbose(@"电话 from:%@ to:%@",self.contacts.cp_phone_number,phoneNumber);
    self.contacts.cp_phone_number = phoneNumber;
}
-(void) addContactsPhoneNumber:(UIButton*)sender{
    [self.view endEditing:YES];
    [self.phoneNumbers addObject:@""];
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    NSInteger index = indexPath.row+self.phoneNumbers.count-1;
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    
    NSString* phoneNumber = [self phoneNumbersStringWithArray:self.phoneNumbers];
    CPLogVerbose(@"电话 from:%@ to:%@",self.contacts.cp_phone_number,phoneNumber);
    self.contacts.cp_phone_number = phoneNumber;
}
-(void) deleteContactsPhoneNumber:(UIButton*)sender{
    [self.view endEditing:YES];
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    NSInteger index = indexPath.row-2;
    [self.phoneNumbers removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSString* phoneNumber = [self phoneNumbersStringWithArray:self.phoneNumbers];
    CPLogVerbose(@"电话 from:%@ to:%@",self.contacts.cp_phone_number,phoneNumber);
    self.contacts.cp_phone_number = phoneNumber;
}
-(void) editContactsBirthday:(UIButton*)sender{
    [self.view endEditing:YES];
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
    if (!self.datePickerView) {
        // 初始化生日选择器
        self.datePickerView = [[TDDatePickerController alloc]initWithNibName:CP_RESOURCE_XIB_DATE_PICKER_DATE bundle:nil];
        if (self.contacts.cp_birthday) {
            static NSDateFormatter* df = nil;
            if (!df) {
                df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd";
            }
            self.datePickerView.date = [df dateFromString:self.contacts.cp_birthday];
        }
        self.datePickerView.delegate = self;
    }
    objc_setAssociatedObject(self.datePickerView, &CPAssociatedKeyIndexPath, indexPath, OBJC_ASSOCIATION_RETAIN);
    [self presentSemiModalViewController:self.datePickerView];
}
-(void) editContactsSource:(UIButton*)sender{
    [self.view endEditing:YES];
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
#warning 这里的tableview滚动不合理,有闪屏的感觉\
解决方案,让弹出框尽量居中,tableview滚动到合适位置
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.popoverView = [PopoverView showPopoverAtPoint:sender.center inView:sender.superview withStringArray:CP_CONTACTS_CELL_TITLE_SOURCE_ITEM delegate:self];
    self.popoverView.tag = 10000;
    objc_setAssociatedObject(self.popoverView, &CPAssociatedKeyIndexPath, indexPath, OBJC_ASSOCIATION_RETAIN);
}
-(void) editContactsIntroduction:(UIButton*)sender{
    [self.view endEditing:YES];
    // 选取被转介绍人
}
-(void) editContactsWechat:(UITextField*)sender{
    self.contacts.cp_weixin = sender.text;
}
-(void) editContactsQQ:(UITextField*)sender{
    self.contacts.cp_im = sender.text;
}
-(void) editContactsEmail:(UITextField*)sender{
#warning TPKeyboard BUG 当点击这个textfield时,布局不正确
    self.contacts.cp_email = sender.text;
}
-(void) editContactsBloodType:(UIButton*)sender{
    [self.view endEditing:YES];
    NSIndexPath* indexPath = [self.tableView indexPathForSender:sender];
#warning 这里的tableview滚动不合理,有闪屏的感觉\
解决方案,让弹出框尽量居中,tableview滚动到合适位置
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.popoverView = [PopoverView showPopoverAtPoint:sender.center inView:sender.superview withStringArray:CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_ITEM delegate:self];
    self.popoverView.tag = 10001;
    objc_setAssociatedObject(self.popoverView, &CPAssociatedKeyIndexPath, indexPath, OBJC_ASSOCIATION_RETAIN);
}
-(void) editContactsHeightBefore:(UITextField*)sender{
    sender.text = [sender.text substringToIndex:sender.text.length-2];
}
-(void) editContactsHeight:(UITextField*)sender{
    self.contacts.cp_height = sender.text;
    sender.text = [NSString stringWithFormat:@"%@cm",sender.text];
}
-(void) editContactsWeightBefore:(UITextField*)sender{
    sender.text = [sender.text substringToIndex:sender.text.length-2];
}
-(void) editContactsWeight:(UITextField*)sender{
    self.contacts.cp_weight = sender.text;
    sender.text = [NSString stringWithFormat:@"%@kg",sender.text];
}
-(void) editContactsHobby:(UITextField*)sender{
    self.contacts.cp_hobby = sender.text;
}
-(void) editContactsNativePlace:(UITextField*)sender{
    self.contacts.cp_hometown = sender.text;
}
#pragma mark - IBAction
- (IBAction)saveContacts:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    self.contacts.cp_timestamp = @([CPServer getServerTimeByDelta_t]);
    if (!self.contactsUUID) {
        // 新增
        [[CPDB getLKDBHelperByUser] insertToDB:self.contacts];
        [self.navigationController popViewControllerAnimated:YES];
    } else{
        // 修改
        [[CPDB getLKDBHelperByUser] updateToDB:self.contacts where:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    // 同步
    [CPServer sync];
}
-(IBAction)cancelButtonClick:(id)sender{
    // 返回上个视图
    [self.navigationController popViewControllerAnimated:self.contactsUUID?NO:YES];
}
#pragma mark - Date Picker Delegate

-(void)datePickerSetDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    static NSDateFormatter* CP_DF_BIRTHDAY = nil;
    if (!CP_DF_BIRTHDAY) {
        CP_DF_BIRTHDAY = [[NSDateFormatter alloc] init];
        [CP_DF_BIRTHDAY setDateFormat:@"yyyy-MM-dd"];
    }
    self.contacts.cp_birthday = [CP_DF_BIRTHDAY stringFromDate:viewController.datePicker.date];
    NSIndexPath* indexPath = objc_getAssociatedObject(viewController, &CPAssociatedKeyIndexPath);
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)datePickerClearDate:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
    self.contacts.cp_birthday = nil;
    NSIndexPath* indexPath = objc_getAssociatedObject(viewController, &CPAssociatedKeyIndexPath);
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)datePickerCancel:(TDDatePickerController*)viewController {
	[self dismissSemiModalViewController:viewController];
}
#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    if (popoverView.tag == 10000) {
        // 来源
        NSIndexPath* indexPath = objc_getAssociatedObject(popoverView, &CPAssociatedKeyIndexPath);
        NSInteger indexOld = self.contacts.cp_clues.integerValue;
        self.contacts.cp_clues = @(index);
        if (indexOld!=5 && index==5) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        if (indexOld==5 && index!=5) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (popoverView.tag == 10001) {
        // 血型
        NSIndexPath* indexPath = objc_getAssociatedObject(popoverView, &CPAssociatedKeyIndexPath);
        self.contacts.cp_blood_type = @(index);
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 13;
    if (self.phoneNumbers.count>=2) {
        result += self.phoneNumbers.count-1;
    }
    if (self.contacts.cp_clues.integerValue==5) {
        result += 1;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"cp_cell_type_1";
    static NSString *CellIdentifier2 = @"cp_cell_type_2";
    static NSString *CellIdentifier3 = @"cp_cell_type_3";
    static NSString *CellIdentifier4 = @"cp_cell_type_4";
    static NSString *CellIdentifier5 = @"cp_cell_type_5";
    static NSString *CellIdentifier7 = @"cp_cell_type_7";
    
    static NSInteger const CP_CONTACTS_CELL_SUB_TAG_1 = 10001;
    static NSInteger const CP_CONTACTS_CELL_SUB_TAG_2 = 10002;
    static NSInteger const CP_CONTACTS_CELL_SUB_TAG_3 = 10003;
    NSIndexPath* indexPathNormal = indexPath;
    if (indexPath.row==0) {
        // 姓名
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_NAME];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeDefault;
        [tf setText:self.contacts?self.contacts.cp_name:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsName:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==1) {
        // 性别
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_SEX];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_sex.integerValue==0?CP_CONTACTS_CELL_TITLE_SEX_MAN:CP_CONTACTS_CELL_TITLE_SEX_WOMAN:CP_CONTACTS_CELL_TITLE_SEX_MAN];
#warning 换成 男女分割器视图
        UISwitch* sexSwitch = (UISwitch*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_3];
        [sexSwitch setOn:self.contacts?self.contacts.cp_sex.integerValue==0?YES:NO:YES];
        [sexSwitch removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [sexSwitch addTarget:self action:@selector(editContactsSex:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    if (indexPath.row==2) {
        // 第一个手机号
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_PHONE_NUMBER];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [tf setText:self.phoneNumbers?self.phoneNumbers.count==0?@"":self.phoneNumbers[0]:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsPhoneNumber:) forControlEvents:UIControlEventEditingDidEnd];
        UIButton* button = (UIButton*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_3];
        [button setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_ADD_0] forState:UIControlStateNormal];
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(addContactsPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    if (indexPath.row>=3 && indexPath.row<=self.phoneNumbers.count+1) {
        // 其余手机号
        NSInteger phoneNumberIndex = indexPath.row-2;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPathNormal];
        // 分割线
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:@""];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [tf setText:self.phoneNumbers[phoneNumberIndex]];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsPhoneNumber:) forControlEvents:UIControlEventEditingDidEnd];
        UIButton* button = (UIButton*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_3];
        [button setBackgroundImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_CELL_DELETE] forState:UIControlStateNormal];
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(deleteContactsPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    // 根据手机号数,修改indexPath
    if (self.phoneNumbers && self.phoneNumbers.count>1) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - self.phoneNumbers.count + 1 inSection:indexPath.section];
    }
    
    if (indexPath.row==3) {
        // 生日
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_BIRTHDAY];
        static NSDateFormatter* CP_DF_BIRTHDAY_1 = nil;
        static NSDateFormatter* CP_DF_BIRTHDAY_2 = nil;
        if (!CP_DF_BIRTHDAY_1) {
            CP_DF_BIRTHDAY_1 = [[NSDateFormatter alloc] init];
            [CP_DF_BIRTHDAY_1 setDateFormat:@"yyyy-MM-dd"];
        }
        if (!CP_DF_BIRTHDAY_2) {
            CP_DF_BIRTHDAY_2 = [[NSDateFormatter alloc] init];
            [CP_DF_BIRTHDAY_2 setDateFormat:@"yyyy 年 MM 月 dd 日"];
        }
        UIButton* button = (UIButton*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        [button setTitle:self.contacts?self.contacts.cp_birthday?[CP_DF_BIRTHDAY_2 stringFromDate:[CP_DF_BIRTHDAY_1 dateFromString:self.contacts.cp_birthday]]:CP_CONTACTS_CELL_TITLE_BIRTHDAY_NULL:CP_CONTACTS_CELL_TITLE_BIRTHDAY_NULL forState:UIControlStateNormal];
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(editContactsBirthday:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    if (indexPath.row==4) {
        // 线索来源
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_SOURCE];
        UIButton* button = (UIButton*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        [button setTitle:self.contacts?self.contacts.cp_clues?CP_CONTACTS_CELL_TITLE_SOURCE_ITEM[self.contacts.cp_clues.integerValue]:CP_CONTACTS_CELL_TITLE_SOURCE_NULL :CP_CONTACTS_CELL_TITLE_SOURCE_NULL forState:UIControlStateNormal];
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(editContactsSource:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    if (indexPath.row==5 && self.contacts && self.contacts.cp_clues.integerValue == 5) {
        // 被转介绍人
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_SOURCE_INTRODUCTION];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:@""];
        // 异步加载介绍人数据
        if (self.contacts.cp_refer_contact) {
            [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:@{@"cp_uuid":self.contacts.cp_refer_contact} orderBy:nil offset:0 count:-1 callback:^(NSMutableArray *array) {
                CPContacts* referC = array.firstObject;
                if (referC) {
                    // 主线程执行：
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:referC.cp_name];
                    });
                }
            }];
        }
        UIButton* button = (UIButton*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_3];
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(editContactsIntroduction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    // 根据线索来源修改indexPath
    if (self.contacts && self.contacts.cp_clues.integerValue == 5) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }
    if (indexPath.row==5) {
        // 微信
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_WECHAT];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeDefault;
        [tf setText:self.contacts?self.contacts.cp_weixin:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsWechat:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==6) {
        // QQ
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_QQ];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeDefault;
        [tf setText:self.contacts?self.contacts.cp_im:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsQQ:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==7) {
        // 邮箱
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_EMAIL];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeDefault;
        [tf setText:self.contacts?self.contacts.cp_email:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsEmail:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==8) {
        // 血型
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_BLOOD_TYPE];
        UIButton* button = (UIButton*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        [button setTitle:self.contacts?self.contacts.cp_blood_type?CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_ITEM[self.contacts.cp_blood_type.integerValue]:CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_A :CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_A forState:UIControlStateNormal];
        [button removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(editContactsBloodType:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    if (indexPath.row==9) {
        // 身高
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_HEIGHT];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [tf setText:self.contacts&&self.contacts.cp_height?[NSString stringWithFormat:@"%@cm",self.contacts.cp_height]:@"cm"];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsHeightBefore:) forControlEvents:UIControlEventEditingDidBegin];
        [tf addTarget:self action:@selector(editContactsHeight:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==10) {
        // 体重
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_WEIGHT];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [tf setText:self.contacts&&self.contacts.cp_weight?[NSString stringWithFormat:@"%@kg",self.contacts.cp_weight]:@"kg"];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsWeightBefore:) forControlEvents:UIControlEventEditingDidBegin];
        [tf addTarget:self action:@selector(editContactsWeight:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==11) {
        // 爱好
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_HOBBY];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeDefault;
        [tf setText:self.contacts?self.contacts.cp_hobby:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsHobby:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    if (indexPath.row==12) {
        // 籍贯
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_NATIVE_PLACE];
        UITextField* tf = (UITextField*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2];
        tf.keyboardType = UIKeyboardTypeDefault;
        [tf setText:self.contacts?self.contacts.cp_hometown:@""];
        [tf removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [tf addTarget:self action:@selector(editContactsNativePlace:) forControlEvents:UIControlEventEditingDidEnd];
        return cell;
    }
    return nil;
}
@end
