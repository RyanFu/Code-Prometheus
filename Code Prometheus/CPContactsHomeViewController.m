//
//  CPContactsHomeViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-21.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPContactsHomeViewController.h"
#import "CPContacts.h"
#import <MBProgressHUD.h>

#warning 搜索结果的返回按钮字体为白色,与背景冲突

@interface CPContactsHomeViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) NSMutableArray* contactsArray;

@property (nonatomic) NSMutableDictionary* contactsForAlephSort;
@property (nonatomic) NSArray* contactsForAlephSortKeys;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@end

@implementation CPContactsHomeViewController
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
        if (self.searchDisplayController.active) {
            CPLogInfo(@"需重新加载数据,%@",self);
            NSString* searchString = self.searchDisplayController.searchBar.text;
            if (!searchString || [searchString isEqualToString:@""]) {
                return;
            }
            // 启动进度条
            MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.removeFromSuperViewOnHide = YES;
            [self.navigationController.view addSubview:hud];
            [hud showAnimated:YES whileExecutingBlock:^{
                // 加载数据
                [self loadContactsWithSearchString:searchString];
                // 排序
                [self initContactsForSort];
            } completionBlock:^{
                // 重载table
                [self.searchDisplayController.searchResultsTableView reloadData];
                // hud消失
                [hud removeFromSuperview];
            }];
        }
        self.dirty = NO;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_home_2_list"])
    {
        UIView* senderView = sender;
        id controller = segue.destinationViewController;
        [controller setValue:@(senderView.tag) forKey:@"groupType"];
    }
    if ([segue.identifier isEqualToString:@"cp_segue_home_2_detail"])
    {
        UITableView* tb = sender;
        // 获取点击的人脉
        NSIndexPath* indexPath = [tb indexPathForSelectedRow];
        NSString* aleph = self.contactsForAlephSortKeys[indexPath.section];
        CPContacts* contacts = contacts = self.contactsForAlephSort[aleph][indexPath.row];
        id controller = segue.destinationViewController;
        [controller setValue:contacts.cp_uuid forKey:@"contactsUUID"];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!CP_IS_IOS7_AND_UP) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
}
#pragma mark - IBAction
- (IBAction)contactsListButtonClick:(UIButton *)sender {
    [self performSegueWithIdentifier:@"cp_segue_home_2_list" sender:sender];
}
#pragma mark - private
-(void) loadContactsWithSearchString:(NSString*)searchString{
    self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:[NSString stringWithFormat:@"cp_name like '%%%@%%'",searchString] orderBy:nil offset:0 count:-1];
}
-(void) initContactsForSort{
    self.contactsForAlephSort = [NSMutableDictionary dictionary];
    
    // 首字母分组
    for (CPContacts* contact in self.contactsArray) {
        NSString* initial = [contact.cp_name aleph];
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
#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!searchText || [searchText isEqualToString:@""]) {
        return;
    }
//    // 启动进度条
//    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//	[self.navigationController.view addSubview:hud];
//    [hud showAnimated:YES whileExecutingBlock:^{
//        // 加载数据
//        [self loadContactsWithSearchString:searchText];
//        // 排序
//        [self initContactsForSort];
//    } completionBlock:^{
//        // 重载table
//        [self.searchDisplayController.searchResultsTableView reloadData];
//        // hud消失
//        [hud removeFromSuperview];
//    }];
    
    // 主线程进行  2014.03.25 修改
    // 加载数据
    [self loadContactsWithSearchString:searchText];
    // 排序
    [self initContactsForSort];
    // 重载table
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    self.contactsArray = nil;
    [self initContactsForSort];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
// 多Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.contactsForAlephSortKeys.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray*)self.contactsForAlephSort[self.contactsForAlephSortKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell_contacts";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    NSString* aleph = self.contactsForAlephSortKeys[indexPath.section];
    CPContacts* contacts = self.contactsForAlephSort[aleph][indexPath.row];
    cell.textLabel.text = contacts.cp_name;
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.contactsForAlephSortKeys[section];
}
// 索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.contactsForAlephSortKeys;
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"cp_segue_home_2_detail" sender:tableView];
}
@end
