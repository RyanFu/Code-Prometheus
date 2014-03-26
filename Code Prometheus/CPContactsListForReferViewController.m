//
//  CPContactsListForReferViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-17.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPContactsListForReferViewController.h"
#import <MBProgressHUD.h>

@interface CPContactsListForReferViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 人脉Array
@property (nonatomic) NSMutableArray* contactsArray;
// 过滤人脉Array
@property (nonatomic) NSMutableArray* contactsArrayFiltered;

// 人脉字母排序
@property (nonatomic) NSMutableDictionary* contactsForAlephSort;
@property (nonatomic) NSArray* contactsForAlephSortKeys;
// 过滤人脉字母排序
@property (nonatomic) NSMutableDictionary* contactsForAlephSortFiltered;
@property (nonatomic) NSArray* contactsForAlephSortKeysFiltered;

@end

@implementation CPContactsListForReferViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        // 加载数据
        [self loadContacts];
        // 排序
        [self contentSort];
    } completionBlock:^{
        // 重载table
        [self.tableView reloadData];
        // hud消失
        [hud removeFromSuperview];
    }];
}
#pragma mark - private
-(void) loadContacts{
    self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:[NSString stringWithFormat:@"cp_uuid != '%@'",self.contacts.cp_uuid] orderBy:nil offset:0 count:-1];
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
    [self initContactsForAlephSort];
}
-(void) contentSortFiltered{
    [self initContactsForAlephSortFiltered];
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
-(CPContacts*) contactsWithtTable:(UITableView*)tableView IndexPath:(NSIndexPath*)indexPath{
    CPContacts* contacts = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString* aleph = self.contactsForAlephSortKeysFiltered[indexPath.section];
        contacts = self.contactsForAlephSortFiltered[aleph][indexPath.row];
    } else {
        NSString* aleph = self.contactsForAlephSortKeys[indexPath.section];
        contacts = self.contactsForAlephSort[aleph][indexPath.row];
    }
    return contacts;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.contactsForAlephSortKeysFiltered.count;
    } else {
        return self.contactsForAlephSortKeys.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [(NSArray*)self.contactsForAlephSortFiltered[self.contactsForAlephSortKeysFiltered[section]] count];
    } else {
        return [(NSArray*)self.contactsForAlephSort[self.contactsForAlephSortKeys[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell_contacts";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // 当此table为过滤table时,cell可能为nil
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    CPContacts* contacts = [self contactsWithtTable:tableView IndexPath:indexPath];
    cell.textLabel.text = contacts.cp_name;
    cell.detailTextLabel.text = nil;
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.contactsForAlephSortKeysFiltered[section];
    }else{
        return self.contactsForAlephSortKeys[section];
    }
}

// 索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.contactsForAlephSortKeysFiltered;
    }else{
        return self.contactsForAlephSortKeys;
    }
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CPContacts* selectContacts = [self contactsWithtTable:tableView IndexPath:indexPath];
    self.contacts.cp_refer_contact = selectContacts.cp_uuid;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
@end
