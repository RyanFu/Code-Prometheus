//
//  CPPersonalDetailsReadViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-28.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPersonalDetailsReadViewController.h"
#import "CPContacts.h"

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

@interface CPPersonalDetailsReadViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) CPContacts* contacts;
@property(nonatomic) NSMutableArray* phoneNumbers;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPPersonalDetailsReadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPContacts class]) object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self loadContacts];
        [self initPhoneNumbers];
        [self.tableView reloadData];
        self.dirty = NO;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_info_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    }
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - private
-(void) loadContacts{
    if (self.contactsUUID) {
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
    static NSString *CellIdentifier1 = @"cp_cell";
    
    static NSInteger const CP_CONTACTS_CELL_SUB_TAG_1 = 10001;
    static NSInteger const CP_CONTACTS_CELL_SUB_TAG_2 = 10002;
    
    NSIndexPath* indexPathNormal = indexPath;
    if (indexPath.row==0) {
        // 姓名
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_NAME];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts.cp_name];
        return cell;
    }
    if (indexPath.row==1) {
        // 性别
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_SEX];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_sex.integerValue==0?CP_CONTACTS_CELL_TITLE_SEX_MAN:CP_CONTACTS_CELL_TITLE_SEX_WOMAN:CP_CONTACTS_CELL_TITLE_SEX_MAN];
        return cell;
    }
    if (indexPath.row==2) {
        // 第一个手机号
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_PHONE_NUMBER];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.phoneNumbers?self.phoneNumbers.count==0?@"":self.phoneNumbers[0]:@""];
        return cell;
    }
    if (indexPath.row>=3 && indexPath.row<=self.phoneNumbers.count+1) {
        // 其余手机号
        NSInteger phoneNumberIndex = indexPath.row-2;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:@""];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.phoneNumbers[phoneNumberIndex]];
        return cell;
    }
    // 根据手机号数,修改indexPath
    if (self.phoneNumbers && self.phoneNumbers.count>1) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - self.phoneNumbers.count + 1 inSection:indexPath.section];
    }
    
    if (indexPath.row==3) {
        // 生日
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
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
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_birthday?[CP_DF_BIRTHDAY_2 stringFromDate:[CP_DF_BIRTHDAY_1 dateFromString:self.contacts.cp_birthday]]:CP_CONTACTS_CELL_TITLE_BIRTHDAY_NULL:CP_CONTACTS_CELL_TITLE_BIRTHDAY_NULL];
        return cell;
    }
    if (indexPath.row==4) {
        // 线索来源
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_SOURCE];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_clues?CP_CONTACTS_CELL_TITLE_SOURCE_ITEM[self.contacts.cp_clues.integerValue]:CP_CONTACTS_CELL_TITLE_SOURCE_NULL :CP_CONTACTS_CELL_TITLE_SOURCE_NULL];
        return cell;
    }
    if (indexPath.row==5 && self.contacts && self.contacts.cp_clues.integerValue == 5) {
        // 被转介绍人
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
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
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_weixin:@""];
        return cell;
    }
    if (indexPath.row==6) {
        // QQ
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_QQ];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_im:@""];
        return cell;
    }
    if (indexPath.row==7) {
        // 邮箱
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_EMAIL];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_email:@""];
        return cell;
    }
    if (indexPath.row==8) {
        // 血型
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_BLOOD_TYPE];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_blood_type?CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_ITEM[self.contacts.cp_blood_type.integerValue]:CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_A :CP_CONTACTS_CELL_TITLE_BLOOD_TYPE_A];
        return cell;
    }
    if (indexPath.row==9) {
        // 身高
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_HEIGHT];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts&&self.contacts.cp_height?[NSString stringWithFormat:@"%@cm",self.contacts.cp_height]:@"cm"];
        return cell;
    }
    if (indexPath.row==10) {
        // 体重
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_WEIGHT];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts&&self.contacts.cp_weight?[NSString stringWithFormat:@"%@kg",self.contacts.cp_weight]:@"kg"];
        return cell;
    }
    if (indexPath.row==11) {
        // 爱好
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_HOBBY];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_hobby:@""];
        return cell;
    }
    if (indexPath.row==12) {
        // 籍贯
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPathNormal];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_1] setText:CP_CONTACTS_CELL_TITLE_NATIVE_PLACE];
        [(UILabel*)[cell viewWithTag:CP_CONTACTS_CELL_SUB_TAG_2] setText:self.contacts?self.contacts.cp_hometown:@""];
        return cell;
    }
    return nil;
}
@end
