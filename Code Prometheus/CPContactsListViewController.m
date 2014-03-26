//
//  CPContactsListViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-22.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPContactsListViewController.h"
#import <PopoverView.h>
#import "CPContacts.h"
#import <MBProgressHUD.h>
#import "CPTrace.h"
#import "CPContactsHomeViewController.h"
#import "CPPolicy.h"
#import "CPOther.h"
#import "CPFamily.h"
#import <PopoverView_Configuration.h>

#define CP_ALL_CONTACTS_SORT @[@"按首字母排序",@"按跟进时间排序"]

static char CPAssociatedKeyTrace;
static char CPAssociatedKeyContacts;
static char CPAssociatedKeyPolicy;

@interface CPContactsListViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,PopoverViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 弹窗
@property (nonatomic) PopoverView* popoverView;


// 人脉Array
@property (nonatomic) NSMutableArray* contactsArray;
// 过滤人脉Array
@property (nonatomic) NSMutableArray* contactsArrayFiltered;


// 分类项
@property (nonatomic) NSInteger sortType;

// 人脉追踪排序
@property (nonatomic) NSMutableArray* contactsForTraceSort;
// 过滤人脉追踪排序
@property (nonatomic) NSMutableArray* contactsForTraceSortFiltered;



// 人脉字母排序
@property (nonatomic) NSMutableDictionary* contactsForAlephSort;
@property (nonatomic) NSArray* contactsForAlephSortKeys;
// 过滤人脉字母排序
@property (nonatomic) NSMutableDictionary* contactsForAlephSortFiltered;
@property (nonatomic) NSArray* contactsForAlephSortKeysFiltered;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
// 应该位于中心的 CPContacts
@property (nonatomic) CPContacts* centerContacts;
@end

@implementation CPContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPContacts class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPTrace class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPPolicy class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPOther class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPFamily class]) object:nil];
    
    [self updateViewStyle];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#warning 如果当前模式是保单查看,那么新增人脉后,无法看到新增的人脉\
解决方案是新增完人脉返回此页面时,直接到名称排序页面,中央显示新增人脉
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        // 启动进度条
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            // 加载数据
            [self loadContacts];
            // 排序
            [self contentSort];
            // 过滤
            if (self.searchDisplayController.active) {
                NSString* searchString = self.searchDisplayController.searchBar.text;
                if (!searchString || [searchString isEqualToString:@""]) {
                    return;
                }
                // 加载数据
                [self filterContactsWithSearchString:searchString];
                // 排序
                [self contentSortFiltered];
            }
        } completionBlock:^{
            // 重载table
            [self.tableView reloadData];
            if (self.searchDisplayController.active) {
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
            if (self.centerContacts) {
                NSIndexPath* indexPate = [self indexPathWithContacts:self.centerContacts tableView:self.tableView];
                [self.tableView scrollToRowAtIndexPath:indexPate atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                if (self.searchDisplayController.active) {
                    NSIndexPath* indexPateFiltered = [self indexPathWithContacts:self.centerContacts tableView:self.searchDisplayController.searchResultsTableView];
                    [self.searchDisplayController.searchResultsTableView scrollToRowAtIndexPath:indexPateFiltered atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                }
                self.centerContacts = nil;
            }
            // hud消失
            [hud removeFromSuperview];
        }];
        self.dirty = NO;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_list_2_detail"])
    {
        UITableView* tb = sender;
        // 获取点击的人脉
        CPContacts* contacts = [self contactsWithtTable:tb IndexPath:[tb indexPathForSelectedRow]];
        id controller = segue.destinationViewController;
        [controller setValue:contacts.cp_uuid forKey:@"contactsUUID"];
    }
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
    if ([[notification object] isKindOfClass:[CPContacts class]]) {
        if ([notification.userInfo[CP_ENTITY_OPERATION_KEY] integerValue]==CP_ENTITY_OPERATION_ADD) {
            CPLogInfo(@"%@,收到通知,添加人脉,设置需要显示在中心的人脉",self);
            CPContacts* newContacts = [notification object];
            self.centerContacts = newContacts;
        }
    }
}
#pragma mark - private
-(void) loadContacts{
    switch (self.groupType.integerValue) {
        case CP_CONTACTS_GROUP_TAG_ALL:{
            self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:nil orderBy:nil offset:0 count:-1];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_DONE:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name,i.cp_date_begin, max(i.cp_date_begin) FROM cp_contacts c INNER JOIN cp_insurance_policy i ON c.cp_uuid=i.cp_contact_uuid  WHERE i.cp_my_policy=1 GROUP BY c.cp_uuid" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
                    CPPolicy* policy = CPPolicy.new;
                    objc_setAssociatedObject(contacts, &CPAssociatedKeyPolicy, policy, OBJC_ASSOCIATION_RETAIN);
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
                                if (sqlValue) {
                                    policy.cp_date_begin = [NSNumber numberWithDouble:sqlValue.doubleValue];
                                }else{
                                    policy.cp_date_begin = nil;
                                }
                                
                                break;
                            }
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNDONE:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT cp_uuid,cp_name FROM cp_contacts WHERE cp_uuid NOT IN (SELECT DISTINCT cp_contact_uuid FROM cp_insurance_policy WHERE cp_my_policy = 1)" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
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
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_FOLLOWUP:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name, max(t.cp_date) FROM cp_contacts c INNER JOIN cp_trace t ON c.cp_uuid=t.cp_contact_uuid GROUP BY c.cp_uuid" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
                    CPTrace* trace = CPTrace.new;
                    objc_setAssociatedObject(contacts, &CPAssociatedKeyTrace, trace, OBJC_ASSOCIATION_RETAIN);
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
                                if (sqlValue) {
                                    trace.cp_date = [NSNumber numberWithDouble:sqlValue.doubleValue];
                                }else{
                                    trace.cp_date = nil;
                                }
                                
                                break;
                            }
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNFOLLOWUP:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT cp_uuid,cp_name FROM cp_contacts WHERE cp_uuid NOT IN (SELECT DISTINCT cp_contact_uuid FROM cp_trace)" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
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
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_BIRTHDAY:{
            self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:nil orderBy:nil offset:0 count:-1];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_ORGANIZATION:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name FROM cp_contacts c INNER JOIN cp_other o ON c.cp_uuid=o.cp_contact_uuid WHERE o.cp_group_insurance=1" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
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
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_TRAVEL:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name FROM cp_contacts c INNER JOIN cp_other o ON c.cp_uuid=o.cp_contact_uuid WHERE o.cp_travel_insurance=1" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
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
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CAR:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name FROM cp_contacts c INNER JOIN cp_other o ON c.cp_uuid=o.cp_contact_uuid WHERE o.cp_car_insurance=1" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
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
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_MAN:{
            self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:@"cp_sex != 1 OR cp_sex ISNULL" orderBy:nil offset:0 count:-1];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_WOMEN:{
            self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:@"cp_sex = 1" orderBy:nil offset:0 count:-1];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CHILD:{
            self.contactsArray = [NSMutableArray array];
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name FROM cp_contacts c INNER JOIN cp_family f ON c.cp_uuid=f.cp_contact_uuid WHERE f.cp_member_status=1" withArgumentsInArray:nil];
                int columeCount = [set columnCount];
                while ([set next]) {
                    CPContacts* contacts = CPContacts.new;
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
                            default:
                                break;
                        }
                    }
                    [self.contactsArray addObject:contacts];
                }
                [set close];
            }];
            break;
        }
        default:
            break;
    }
}
-(void) filterContactsWithSearchString:(NSString*)searchString{
    // 根据搜索栏内的字符串以及搜索范围来过滤数据。
	[self.contactsArrayFiltered removeAllObjects];
    self.contactsArrayFiltered = nil;
	// 用NSPredicate来过滤数组。
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cp_name contains[c] %@",searchString];
    NSArray *tempArray = [self.contactsArray filteredArrayUsingPredicate:predicate];
    self.contactsArrayFiltered = [NSMutableArray arrayWithArray:tempArray];
}
-(void) contentSort{
    switch (self.groupType.integerValue) {
        case CP_CONTACTS_GROUP_TAG_ALL:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_DONE:{
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNDONE:{
            [self initContactsForAlephSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_FOLLOWUP:{
            [self.contactsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                CPTrace* trace1 = objc_getAssociatedObject(obj1, &CPAssociatedKeyTrace);
                CPTrace* trace2 = objc_getAssociatedObject(obj2, &CPAssociatedKeyTrace);
                if (trace1.cp_date == nil && trace2.cp_date == nil) {
                    return NSOrderedSame;
                }
                if (trace1.cp_date == nil && trace2.cp_date != nil) {
                    return NSOrderedDescending;
                }
                if (trace1.cp_date != nil && trace2.cp_date == nil) {
                    return NSOrderedAscending;
                }
                return -[trace1.cp_date compare:trace2.cp_date];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNFOLLOWUP:{
            [self initContactsForAlephSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_BIRTHDAY:{
            [self.contactsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 cp_birthday] == nil && [obj2 cp_birthday] == nil) {
                    return NSOrderedSame;
                }
                if ([obj1 cp_birthday] == nil && [obj2 cp_birthday] != nil) {
                    return NSOrderedDescending;
                }
                if ([obj1 cp_birthday] != nil && [obj2 cp_birthday] == nil) {
                    return NSOrderedAscending;
                }
                NSDate* birthday1 = [self dateWiteBirthdayIgnore:[obj1 cp_birthday]];
                NSDate* birthday2 = [self dateWiteBirthdayIgnore:[obj2 cp_birthday]];
                NSDate* now = [self dateNowWithoutHMS];
                
                if (!birthday1 && !birthday2) {
                    return NSOrderedSame;
                }
                if (!birthday1 && birthday2) {
                    return NSOrderedDescending;
                }
                if (birthday1 && !birthday2) {
                    return NSOrderedAscending;
                }
                
                NSComparisonResult b1n = [birthday1 compare:now];
                NSComparisonResult b2n = [birthday2 compare:now];
                NSComparisonResult b1b2 = [birthday1 compare:birthday2];
                
                if (b1n==NSOrderedAscending) {
                    if (b2n==NSOrderedAscending) {
                        return b1b2;
                    }else if(b2n==NSOrderedDescending){
                        return NSOrderedDescending;
                    }else{
                        return NSOrderedDescending;
                    }
                }else if(b1n==NSOrderedDescending){
                    if (b2n==NSOrderedAscending) {
                        return NSOrderedAscending;
                    }else if(b2n==NSOrderedDescending){
                        return b1b2;
                    }else{
                        return NSOrderedDescending;
                    }
                }else{
                    if (b2n==NSOrderedAscending) {
                        return NSOrderedAscending;
                    }else if(b2n==NSOrderedDescending){
                        return NSOrderedAscending;
                    }else{
                        return NSOrderedSame;
                    }
                }
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_ORGANIZATION:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_TRAVEL:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CAR:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_MAN:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_WOMEN:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CHILD:{
            [self initContactsForAlephSort];
            [self initContactsForTraceSort];
            break;
        }
        default:
            break;
    }
}
-(void) contentSortFiltered{
    if (!self.searchDisplayController.active) {
        return;
    }
    switch (self.groupType.integerValue) {
        case CP_CONTACTS_GROUP_TAG_ALL:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_DONE:{
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNDONE:{
            [self initContactsForAlephSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_FOLLOWUP:{
            [self.contactsArrayFiltered sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                CPTrace* trace1 = objc_getAssociatedObject(obj1, &CPAssociatedKeyTrace);
                CPTrace* trace2 = objc_getAssociatedObject(obj2, &CPAssociatedKeyTrace);
                if (trace1.cp_date == nil && trace2.cp_date == nil) {
                    return NSOrderedSame;
                }
                if (trace1.cp_date == nil && trace2.cp_date != nil) {
                    return NSOrderedDescending;
                }
                if (trace1.cp_date != nil && trace2.cp_date == nil) {
                    return NSOrderedAscending;
                }
                return -[trace1.cp_date compare:trace2.cp_date];
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNFOLLOWUP:{
            [self initContactsForAlephSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_BIRTHDAY:{
            [self.contactsArrayFiltered sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 cp_birthday] == nil && [obj2 cp_birthday] == nil) {
                    return NSOrderedSame;
                }
                if ([obj1 cp_birthday] == nil && [obj2 cp_birthday] != nil) {
                    return NSOrderedDescending;
                }
                if ([obj1 cp_birthday] != nil && [obj2 cp_birthday] == nil) {
                    return NSOrderedAscending;
                }
                NSDate* birthday1 = [self dateWiteBirthdayIgnore:[obj1 cp_birthday]];
                NSDate* birthday2 = [self dateWiteBirthdayIgnore:[obj2 cp_birthday]];
                NSDate* now = [self dateNowWithoutHMS];
                
                NSComparisonResult b1n = [birthday1 compare:now];
                NSComparisonResult b2n = [birthday2 compare:now];
                NSComparisonResult b1b2 = [birthday1 compare:birthday2];
                
                if (b1n==NSOrderedAscending) {
                    if (b2n==NSOrderedAscending) {
                        return b1b2;
                    }else if(b2n==NSOrderedDescending){
                        return NSOrderedDescending;
                    }else{
                        return NSOrderedDescending;
                    }
                }else if(b1n==NSOrderedDescending){
                    if (b2n==NSOrderedAscending) {
                        return NSOrderedAscending;
                    }else if(b2n==NSOrderedDescending){
                        return b1b2;
                    }else{
                        return NSOrderedDescending;
                    }
                }else{
                    if (b2n==NSOrderedAscending) {
                        return NSOrderedAscending;
                    }else if(b2n==NSOrderedDescending){
                        return NSOrderedAscending;
                    }else{
                        return NSOrderedSame;
                    }
                }
            }];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_ORGANIZATION:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_TRAVEL:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CAR:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_MAN:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_WOMEN:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CHILD:{
            [self initContactsForAlephSortFiltered];
            [self initContactsForTraceSortFiltered];
            break;
        }
        default:
            break;
    }
}

-(void) initContactsForAlephSort{
    self.contactsForAlephSort = [NSMutableDictionary dictionary];
    // 首字母分组
    for (CPContacts* contact in self.contactsArray) {
        NSString* initial = contact.cp_name?[contact.cp_name aleph]:@"#";
        NSMutableArray* array = [self.contactsForAlephSort objectForKey:initial];
        if (array) {
            [array addObject:contact];
        }else{
            NSMutableArray* arrayNew = [NSMutableArray array];
            [arrayNew addObject:contact];
            [self.contactsForAlephSort setObject:arrayNew forKey:initial];
        }
    }
    // 每组自然排序
    for (NSString* key in self.contactsForAlephSort) {
        NSMutableArray* array = self.contactsForAlephSort[key];
        [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[(CPContacts*)obj1 cp_name] compare:[(CPContacts*)obj2 cp_name]];
        }];
    }
    // key排序
    self.contactsForAlephSortKeys = [self.contactsForAlephSort.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}
-(void) initContactsForAlephSortFiltered{
    self.contactsForAlephSortFiltered = [NSMutableDictionary dictionary];
    // 首字母分组
    for (CPContacts* contact in self.contactsArrayFiltered) {
        NSString* initial = contact.cp_name?[contact.cp_name aleph]:@"#";
        NSMutableArray* array = [self.contactsForAlephSortFiltered objectForKey:initial];
        if (array) {
            [array addObject:contact];
        }else{
            NSMutableArray* arrayNew = [NSMutableArray array];
            [arrayNew addObject:contact];
            [self.contactsForAlephSortFiltered setObject:arrayNew forKey:initial];
        }
    }
    // 每组自然排序
    for (NSString* key in self.contactsForAlephSortFiltered) {
        NSMutableArray* array = self.contactsForAlephSortFiltered[key];
        [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[(CPContacts*)obj1 cp_name] compare:[(CPContacts*)obj2 cp_name]];
        }];
    }
    // key排序
    self.contactsForAlephSortKeysFiltered = [self.contactsForAlephSortFiltered.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}
-(void) initContactsForTraceSort{
    self.contactsForTraceSort = [NSMutableArray array];
    // 追踪分组
    for (CPContacts* contact in self.contactsArray) {
        CPTrace* trace = [[CPDB getLKDBHelperByUser] searchSingle:[CPTrace class] where:@{@"cp_contact_uuid":contact.cp_uuid} orderBy:@"cp_date DESC"];
        objc_setAssociatedObject(contact, &CPAssociatedKeyTrace, trace, OBJC_ASSOCIATION_RETAIN);
        [self.contactsForTraceSort addObject:contact];
    }
    // 追踪时间排序
    [self.contactsForTraceSort sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        CPTrace* trace1 = objc_getAssociatedObject(obj1, &CPAssociatedKeyTrace);
        CPTrace* trace2 = objc_getAssociatedObject(obj2, &CPAssociatedKeyTrace);
        if (trace1.cp_date == nil && trace2.cp_date == nil) {
            return NSOrderedSame;
        }
        if (trace1.cp_date == nil && trace2.cp_date != nil) {
            return NSOrderedDescending;
        }
        if (trace1.cp_date != nil && trace2.cp_date == nil) {
            return NSOrderedAscending;
        }
        return -[trace1.cp_date compare:trace2.cp_date];
    }];
}
-(void) initContactsForTraceSortFiltered{
    self.contactsForTraceSortFiltered = [NSMutableArray array];
    // 追踪分组
    for (CPContacts* contact in self.contactsArrayFiltered) {
        CPTrace* trace = [[CPDB getLKDBHelperByUser] searchSingle:[CPTrace class] where:@{@"cp_contact_uuid":contact.cp_uuid} orderBy:@"cp_date DESC"];
        if (!trace) {
            continue;
        }
        objc_setAssociatedObject(contact, &CPAssociatedKeyTrace, trace, OBJC_ASSOCIATION_RETAIN);
        [self.contactsForTraceSortFiltered addObject:contact];
    }
    // 追踪时间排序
    [self.contactsForTraceSortFiltered sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        CPTrace* trace1 = objc_getAssociatedObject(obj1, &CPAssociatedKeyTrace);
        CPTrace* trace2 = objc_getAssociatedObject(obj2, &CPAssociatedKeyTrace);
        if (trace1.cp_date == nil && trace2.cp_date == nil) {
            return NSOrderedSame;
        }
        if (trace1.cp_date == nil && trace2.cp_date != nil) {
            return NSOrderedDescending;
        }
        if (trace1.cp_date != nil && trace2.cp_date == nil) {
            return NSOrderedAscending;
        }
        return -[trace1.cp_date compare:trace2.cp_date];
    }];
}
-(void) updateViewStyle{
    switch (self.groupType.integerValue) {
        case CP_CONTACTS_GROUP_TAG_ALL:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"总人脉" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            // 添加按钮
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContacts:)];
            break;
        }
        case CP_CONTACTS_GROUP_TAG_DONE:{
            self.navigationItem.title = @"已成交";
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNDONE:{
            self.navigationItem.title = @"未成交";
            break;
        }
        case CP_CONTACTS_GROUP_TAG_FOLLOWUP:{
            self.navigationItem.title = @"已跟进";
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNFOLLOWUP:{
            self.navigationItem.title = @"未跟进";
            break;
        }
        case CP_CONTACTS_GROUP_TAG_BIRTHDAY:{
            self.navigationItem.title = @"生日客户";
            break;
        }
        case CP_CONTACTS_GROUP_TAG_ORGANIZATION:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"团险" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_TRAVEL:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"旅行险" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CAR:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"车险" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_MAN:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"男性客户" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_WOMEN:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"女性客户" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CHILD:{
            // 分类按钮
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"儿童客户" forState:UIControlStateNormal];
            UIImage* sortImage = [UIImage imageNamed:CP_RESOURCE_IMAGE_SORT_0];
            [button setImage:sortImage forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -sortImage.size.width, 0, sortImage.size.width)];
            CGSize titleSize = [button.titleLabel sizeThatFits:CGSizeZero];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width, 0, -titleSize.width)];
            [button sizeToFit];
            [button addTarget:self action:@selector(changeSortType:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = button;
            break;
        }
        default:
            break;
    }
}
-(CPContacts*) contactsWithtTable:(UITableView*)tableView IndexPath:(NSIndexPath*)indexPath{
    CPContacts* contacts = nil;
    
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType == 0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                NSString* aleph = self.contactsForAlephSortKeysFiltered[indexPath.section];
                contacts = self.contactsForAlephSortFiltered[aleph][indexPath.row];
            } else {
                NSString* aleph = self.contactsForAlephSortKeys[indexPath.section];
                contacts = self.contactsForAlephSort[aleph][indexPath.row];
            }
        }else if(self.sortType == 1){
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                contacts = self.contactsForTraceSortFiltered[indexPath.row];
            } else {
                contacts = self.contactsForTraceSort[indexPath.row];
            }
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            contacts = self.contactsArrayFiltered[indexPath.row];
        } else {
            contacts = self.contactsArray[indexPath.row];
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSString* aleph = self.contactsForAlephSortKeysFiltered[indexPath.section];
            contacts = self.contactsForAlephSortFiltered[aleph][indexPath.row];
        } else {
            NSString* aleph = self.contactsForAlephSortKeys[indexPath.section];
            contacts = self.contactsForAlephSort[aleph][indexPath.row];
        }
    }
    return contacts;
}
-(BOOL) containItInSelfGroupTypeContacts:(CPContacts*)contacts{
    switch (self.groupType.integerValue) {
        case CP_CONTACTS_GROUP_TAG_ALL:{
            return YES;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_DONE:{
            __block BOOL hasPolicy = NO;
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_insurance_policy WHERE cp_my_policy!=0 AND cp_my_policy NOTNULL AND cp_contact_uuid=?" withArgumentsInArray:@[contacts.cp_uuid]];
                while ([set next]) {
                    NSString* sqlValue = [set stringForColumnIndex:0];
                    NSInteger count = sqlValue.integerValue;
                    if (count>0) {
                        hasPolicy = YES;
                    }
                }
                [set close];
            }];
            return hasPolicy;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNDONE:{
            __block BOOL hasPolicy = NO;
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_insurance_policy WHERE cp_my_policy!=0 AND cp_my_policy NOTNULL AND cp_contact_uuid=?" withArgumentsInArray:@[contacts.cp_uuid]];
                while ([set next]) {
                    NSString* sqlValue = [set stringForColumnIndex:0];
                    NSInteger count = sqlValue.integerValue;
                    if (count>0) {
                        hasPolicy = YES;
                    }
                }
                [set close];
            }];
            return !hasPolicy;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_FOLLOWUP:{
            __block BOOL hasTrace = NO;
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_trace WHERE cp_contact_uuid=?" withArgumentsInArray:@[contacts.cp_uuid]];
                while ([set next]) {
                    NSString* sqlValue = [set stringForColumnIndex:0];
                    NSInteger count = sqlValue.integerValue;
                    if (count>0) {
                        hasTrace = YES;
                    }
                }
                [set close];
            }];
            return hasTrace;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_UNFOLLOWUP:{
            __block BOOL hasTrace = NO;
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_trace WHERE cp_contact_uuid=?" withArgumentsInArray:@[contacts.cp_uuid]];
                while ([set next]) {
                    NSString* sqlValue = [set stringForColumnIndex:0];
                    NSInteger count = sqlValue.integerValue;
                    if (count>0) {
                        hasTrace = YES;
                    }
                }
                [set close];
            }];
            return !hasTrace;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_BIRTHDAY:{
            return YES;
            break;
        }
        case CP_CONTACTS_GROUP_TAG_ORGANIZATION:{
            CPOther* other = [[CPDB getLKDBHelperByUser] searchSingle:[CPOther class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil];
            if (other) {
                return other.cp_group_insurance.boolValue;
            }else{
                return NO;
            }
            break;
        }
        case CP_CONTACTS_GROUP_TAG_TRAVEL:{
            CPOther* other = [[CPDB getLKDBHelperByUser] searchSingle:[CPOther class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil];
            if (other) {
                return other.cp_travel_insurance.boolValue;
            }else{
                return NO;
            }
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CAR:{
            CPOther* other = [[CPDB getLKDBHelperByUser] searchSingle:[CPOther class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil];
            if (other) {
                return other.cp_car_insurance.boolValue;
            }else{
                return NO;
            }
            break;
        }
        case CP_CONTACTS_GROUP_TAG_MAN:{
            if (contacts.cp_sex) {
                return !contacts.cp_sex.boolValue;
            }else{
                return YES;
            }
            break;
        }
        case CP_CONTACTS_GROUP_TAG_WOMEN:{
            if (contacts.cp_sex) {
                return contacts.cp_sex.boolValue;
            }else{
                return NO;
            }
            break;
        }
        case CP_CONTACTS_GROUP_TAG_CHILD:{
            CPFamily* family = [[CPDB getLKDBHelperByUser] searchSingle:[CPFamily class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil];
            if (family) {
                return family.cp_member_status.boolValue;
            }else{
                return NO;
            }
            break;
        }
        default:
            break;
    }
    return NO;
}
-(NSIndexPath*)indexPathWithContacts:(CPContacts*)contacts tableView:(UITableView*)tableView{
    NSIndexPath* indexPath = nil;
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType == 0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                NSString* aleph = contacts.cp_name?[contacts.cp_name aleph]:@"#";
                NSInteger section = [self.contactsForAlephSortKeysFiltered indexOfObject:aleph];
                if (section == NSNotFound) {
                    return nil;
                }
                NSInteger row = [(NSMutableArray*)self.contactsForAlephSortFiltered[aleph] indexOfObject:contacts];
                if (row == NSNotFound) {
                    return nil;
                }
                indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            } else {
                NSString* aleph = contacts.cp_name?[contacts.cp_name aleph]:@"#";
                NSInteger section = [self.contactsForAlephSortKeys indexOfObject:aleph];
                if (section == NSNotFound) {
                    return nil;
                }
                NSInteger row = [(NSMutableArray*)self.contactsForAlephSort[aleph] indexOfObject:contacts];
                if (row == NSNotFound) {
                    return nil;
                }
                indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            }
        }else if(self.sortType == 1){
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                NSInteger row = [self.contactsForTraceSortFiltered indexOfObject:contacts];
                if (row == NSNotFound) {
                    return nil;
                }
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            } else {
                NSInteger row = [self.contactsForTraceSort indexOfObject:contacts];
                if (row == NSNotFound) {
                    return nil;
                }
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            }
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            indexPath = [NSIndexPath indexPathForRow:[self.contactsArrayFiltered indexOfObject:contacts] inSection:0];
        } else {
            indexPath = [NSIndexPath indexPathForRow:[self.contactsArray indexOfObject:contacts] inSection:0];
        }
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSString* aleph = contacts.cp_name?[contacts.cp_name aleph]:@"#";
            NSInteger section = [self.contactsForAlephSortKeysFiltered indexOfObject:aleph];
            if (section == NSNotFound) {
                return nil;
            }
            NSInteger row = [(NSMutableArray*)self.contactsForAlephSortFiltered[aleph] indexOfObject:contacts];
            if (row == NSNotFound) {
                return nil;
            }
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        } else {
            NSString* aleph = contacts.cp_name?[contacts.cp_name aleph]:@"#";
            NSInteger section = [self.contactsForAlephSortKeys indexOfObject:aleph];
            if (section == NSNotFound) {
                return nil;
            }
            NSInteger row = [(NSMutableArray*)self.contactsForAlephSort[aleph] indexOfObject:contacts];
            if (row == NSNotFound) {
                return nil;
            }
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    return indexPath;
}
-(NSDate*) dateNowWithoutHMS{
    static NSCalendar *calendar = nil;
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    return midnightUTC;
}
-(NSDate*) dateWiteBirthdayIgnore:(NSString*)birthday{
    static NSCalendar *calendar = nil;
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    if (!birthday || [birthday isEqualToString:@""]) {
        return nil;
    }
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    NSRange monthR;
    monthR.location = 5;
    monthR.length = 2;
    [dateComponents setMonth:[birthday substringWithRange:monthR].integerValue];
    NSRange monthD;
    monthD.location = 8;
    monthD.length = 2;
    [dateComponents setDay:[birthday substringWithRange:monthD].integerValue];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    return midnightUTC;
}
#pragma mark - Action
-(void) changeSortType:(UIButton*)sender{
    PopoverView *popoverView = [[PopoverView alloc] initWithFrame:CGRectZero];
    popoverView.delegate = self;
    self.popoverView = popoverView;
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] initWithCapacity:CP_ALL_CONTACTS_SORT.count];
    UIFont *font = kTextFont;
    NSArray* typeArray = CP_ALL_CONTACTS_SORT;
    for(NSString *string in typeArray) {
        CGSize textSize = [string sizeWithFont:font];
        UIButton *textButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 20, textSize.height)];
        textButton.backgroundColor = [UIColor clearColor];
        textButton.titleLabel.font = font;
        textButton.titleLabel.textAlignment = kTextAlignment;
        textButton.titleLabel.textColor = kTextColor;
        [textButton setTitle:string forState:UIControlStateNormal];
        if ([typeArray indexOfObject:string] == self.sortType) {
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
-(void) addContacts:(id)sender{
    [self performSegueWithIdentifier:@"cp_segue_list_2_edit" sender:sender];
}

#pragma mark - PopoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    if (self.sortType != index) {
        // 排序
        self.sortType = index;
        [self.tableView reloadData];
    }
    [self.popoverView dismiss];
    self.popoverView = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType==0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                return self.contactsForAlephSortKeysFiltered.count;
            } else {
                return self.contactsForAlephSortKeys.count;
            }
        }else if(self.sortType==1){
            return 1;
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        return 1;
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.contactsForAlephSortKeysFiltered.count;
        } else {
            return self.contactsForAlephSortKeys.count;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType==0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                return [(NSArray*)self.contactsForAlephSortFiltered[self.contactsForAlephSortKeysFiltered[section]] count];
            } else {
                return [(NSArray*)self.contactsForAlephSort[self.contactsForAlephSortKeys[section]] count];
            }
        }else if(self.sortType==1){
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                return self.contactsForTraceSortFiltered.count;
            } else {
                return self.contactsForTraceSort.count;
            }
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.contactsArrayFiltered.count;
        } else {
            return self.contactsArray.count;
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return [(NSArray*)self.contactsForAlephSortFiltered[self.contactsForAlephSortKeysFiltered[section]] count];
        } else {
            return [(NSArray*)self.contactsForAlephSort[self.contactsForAlephSortKeys[section]] count];
        }
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell_contacts";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // 当此table为过滤table时,cell可能为nil
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
    }
    CPContacts* contacts = [self contactsWithtTable:tableView IndexPath:indexPath];
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType == 0) {
            cell.textLabel.text = contacts.cp_name;
            cell.detailTextLabel.text = nil;
        }else if(self.sortType == 1){
            CPTrace* trace = objc_getAssociatedObject(contacts,&CPAssociatedKeyTrace);
            static NSDateFormatter* CP_DF_Trace = nil;
            if (!CP_DF_Trace) {
                CP_DF_Trace = [[NSDateFormatter alloc] init];
                [CP_DF_Trace setDateFormat:@"yyyy-MM-dd hh:mm"];
            }
            cell.textLabel.text = contacts.cp_name;
            if (trace.cp_date == nil) {
                cell.detailTextLabel.text = nil;
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }else{
                NSDate* traceDate = [NSDate dateWithTimeIntervalSince1970:trace.cp_date.doubleValue];
                NSDate* now = [NSDate date];
                NSComparisonResult compareResult = [traceDate compare:now];
                if (compareResult == NSOrderedDescending || compareResult == NSOrderedSame) {
                    cell.detailTextLabel.textColor = [UIColor blueColor];
                }else{
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                }
                cell.detailTextLabel.text = [CP_DF_Trace stringFromDate:traceDate];
            }
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE){
        CPPolicy* policy = objc_getAssociatedObject(contacts,&CPAssociatedKeyPolicy);
        static NSDateFormatter* CP_DF_Trace = nil;
        if (!CP_DF_Trace) {
            CP_DF_Trace = [[NSDateFormatter alloc] init];
            [CP_DF_Trace setDateFormat:@"yyyy-MM-dd hh:mm"];
        }
        cell.textLabel.text = contacts.cp_name;
        if (policy.cp_date_begin == nil) {
            cell.detailTextLabel.text = nil;
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }else{
            NSDate* policyBeginDate = [NSDate dateWithTimeIntervalSince1970:policy.cp_date_begin.doubleValue];
            NSDate* now = [NSDate date];
            NSComparisonResult compareResult = [policyBeginDate compare:now];
            if (compareResult == NSOrderedDescending || compareResult == NSOrderedSame) {
                cell.detailTextLabel.textColor = [UIColor blueColor];
            }else{
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
            cell.detailTextLabel.text = [CP_DF_Trace stringFromDate:policyBeginDate];
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        cell.textLabel.text = contacts.cp_name;
        cell.detailTextLabel.text = nil;
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP){
        CPTrace* trace = objc_getAssociatedObject(contacts,&CPAssociatedKeyTrace);
        static NSDateFormatter* CP_DF_Trace = nil;
        if (!CP_DF_Trace) {
            CP_DF_Trace = [[NSDateFormatter alloc] init];
            [CP_DF_Trace setDateFormat:@"yyyy-MM-dd hh:mm"];
        }
        cell.textLabel.text = contacts.cp_name;
        if (trace.cp_date == nil) {
            cell.detailTextLabel.text = nil;
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }else{
            NSDate* traceDate = [NSDate dateWithTimeIntervalSince1970:trace.cp_date.doubleValue];
            NSDate* now = [NSDate date];
            NSComparisonResult compareResult = [traceDate compare:now];
            if (compareResult == NSOrderedDescending || compareResult == NSOrderedSame) {
                cell.detailTextLabel.textColor = [UIColor blueColor];
            }else{
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
            cell.detailTextLabel.text = [CP_DF_Trace stringFromDate:traceDate];
        }
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        cell.textLabel.text = contacts.cp_name;
        if (contacts.cp_birthday == nil) {
            cell.detailTextLabel.text = nil;
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }else{
            cell.detailTextLabel.text = contacts.cp_birthday;
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType == 0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                return self.contactsForAlephSortKeysFiltered[section];
            }else{
                return self.contactsForAlephSortKeys[section];
            }
        }else if(self.sortType == 1){
            return @"跟进时间";
        }
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE){
        return @"保单最近成交日期";
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.contactsForAlephSortKeysFiltered[section];
        }else{
            return self.contactsForAlephSortKeys[section];
        }
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP){
        return @"跟进时间";
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        return @"生日";
    }
    return nil;
}
// 索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ALL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_ORGANIZATION || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_TRAVEL || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CAR || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_MAN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_WOMEN || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_CHILD) {
        if (self.sortType == 0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                return self.contactsForAlephSortKeysFiltered;
            }else{
                return self.contactsForAlephSortKeys;
            }
        }else if(self.sortType == 1){
            return nil;
        }
    }else if(self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_DONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_FOLLOWUP || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_BIRTHDAY){
        return nil;
    }else if (self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNDONE || self.groupType.integerValue == CP_CONTACTS_GROUP_TAG_UNFOLLOWUP){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.contactsForAlephSortKeysFiltered;
        }else{
            return self.contactsForAlephSortKeys;
        }
    }
    return nil;
}
// 删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"确认删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        CPContacts* contactsToDelete = [self contactsWithtTable:tableView IndexPath:indexPath];
        objc_setAssociatedObject(alert, &CPAssociatedKeyContacts, contactsToDelete, OBJC_ASSOCIATION_RETAIN);
        [alert show];
    }
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"cp_segue_list_2_detail" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!searchText || [searchText isEqualToString:@""]) {
        return;
    }
//    // 启动进度条
//    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//    hud.removeFromSuperViewOnHide = YES;
//	[self.navigationController.view addSubview:hud];
//    [hud showAnimated:YES whileExecutingBlock:^{
//        // 加载数据
//        [self filterContactsWithSearchString:searchText];
//        // 排序
//        [self contentSortFiltered];
//    } completionBlock:^{
//        // 重载table
//        [self.searchDisplayController.searchResultsTableView reloadData];
//        // hud消失
//        [hud removeFromSuperview];
//    }];
    
    // 主线程进行  2014.03.25 修改
    // 加载数据
    [self filterContactsWithSearchString:searchText];
    // 排序
    [self contentSortFiltered];
    // 重载table
    [self.searchDisplayController.searchResultsTableView reloadData];
}
#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    [self.contactsArrayFiltered removeAllObjects];
    self.contactsArrayFiltered = nil;
    // 排序
    [self contentSortFiltered];
    [tableView reloadData];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        CPContacts* contactsToDelete = objc_getAssociatedObject(alertView,&CPAssociatedKeyContacts);
        // 数据库操作
        BOOL success = [[CPDB getLKDBHelperByUser] deleteToDB:contactsToDelete];
        if (!success) {
            CPLogError(@"删除人脉失败:%@",contactsToDelete);
            return;
        }
        CPLogInfo(@"%@,删除人脉,更新UI",self);
        // 更新table
        if ([self.contactsArray containsObject:contactsToDelete]) {
            // 计算IndexPath
            NSIndexPath* indexPath = [self indexPathWithContacts:contactsToDelete tableView:self.tableView];
            // 计算此section里还有多少行
            NSInteger rowsNumber = [self.tableView numberOfRowsInSection:indexPath.section];
            // 内存操作
            [self.contactsArray removeObject:contactsToDelete];
            // 排序
            [self contentSort];
            // 更新UI
            if (rowsNumber > 1)
            {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        // 更新搜索table
        if (self.searchDisplayController.active) {
            if ([self.contactsArrayFiltered containsObject:contactsToDelete]) {
                // 计算IndexPath
                NSIndexPath* indexPath = [self indexPathWithContacts:contactsToDelete tableView:self.searchDisplayController.searchResultsTableView];
                // 计算此section里还有多少行
                NSInteger rowsNumber = [self.searchDisplayController.searchResultsTableView numberOfRowsInSection:indexPath.section];
                // 内存操作
                [self.contactsArrayFiltered removeObject:contactsToDelete];
                // 排序
                [self contentSortFiltered];
                // 更新UI
                if (rowsNumber > 1)
                {
                    [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                else
                {
                    [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
        // 同步
        [CPServer sync];
    }
}
@end
