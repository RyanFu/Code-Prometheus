//
//  CPGlobalMapViewController.m
//  Code Prometheus
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "CPGlobalMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "CPContacts.h"
#import "CPFamily.h"
#import "CPCompany.h"
#import "CPCusAnnotationView.h"
#import <Masonry.h>
#import "CPContactsDetailViewController.h"
#import "CommonUtility.h"
#import "CPContactsInMapTableViewController.h"


// 地图模式
typedef NS_ENUM(NSInteger, CPGlobalMapModel) {
    CPGlobalMapModelContactsInRegion,
    CPGlobalMapModelSearchedContacts
};

@interface CPGlobalMapViewController ()<MAMapViewDelegate, AMapSearchDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>
// 地图模式
@property (nonatomic) CPGlobalMapModel model;
// 显示的标记
@property (nonatomic) NSMutableArray* annotationArray;
// 地图范围内人脉读取线程池
@property (nonatomic) NSOperationQueue* queue;



// UI
@property (nonatomic,weak) UIView* bottomView;
@property (nonatomic,weak) UILabel* nameLabel;
@property (nonatomic,weak) UILabel* addressLabel;


// 搜索table相关的model
@property (nonatomic) NSMutableArray* contactsArray;
@property (nonatomic) NSMutableDictionary* contactsForAlephSort;
@property (nonatomic) NSArray* contactsForAlephSortKeys;

// CPGlobalMapModelSearchedContacts 模式下对应的 人脉
@property (nonatomic) CPContacts* contacts;
@end

@implementation CPGlobalMapViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.model = CPGlobalMapModelContactsInRegion;
    // 队列
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
    // 底部的view
    UIView* bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor grayColor];
    bottomView.alpha = 0.9;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewClick:)];
    [bottomView addGestureRecognizer:tap];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
    self.bottomView = bottomView;
    
    UILabel* nameLabel = [[UILabel alloc] init];
    [bottomView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(20));
        make.top.equalTo(@(4));
    }];
    self.nameLabel = nameLabel;
    
    UILabel* addressLabel = [[UILabel alloc] init];
    [addressLabel setFont:[UIFont systemFontOfSize:12]];
    [bottomView addSubview:addressLabel];
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.top.equalTo(nameLabel.mas_bottom).offset(4);
        make.bottom.equalTo(@(0));
    }];
    self.addressLabel = addressLabel;
    
    bottomView.hidden = YES;
    
    // 右侧view
    UIButton* allContactsButton = [[UIButton alloc] init];
    [self.view addSubview:allContactsButton];
    [allContactsButton addTarget:self action:@selector(allContactsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [allContactsButton setImage:[UIImage imageNamed:@"cp_map_all_contacts"] forState:UIControlStateNormal];
    [allContactsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(64));
        make.right.equalTo(@(-8));
    }];
    
    UIButton* localButton = [[UIButton alloc] init];
    [self.view addSubview:localButton];
    [localButton addTarget:self action:@selector(localButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [localButton setImage:[UIImage imageNamed:@"cp_map_local"] forState:UIControlStateNormal];
    [localButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(allContactsButton.mas_bottom).offset(8);
        make.right.equalTo(@(-8));
    }];
    
    UIButton* listButton = [[UIButton alloc] init];
    [self.view addSubview:listButton];
    [listButton addTarget:self action:@selector(listButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [listButton setImage:[UIImage imageNamed:@"cp_map_list"] forState:UIControlStateNormal];
    [listButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(localButton.mas_bottom).offset(8);
        make.right.equalTo(@(-8));
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.model == CPGlobalMapModelContactsInRegion) {
        [self updateUIForModelContactsInRegion];
    }
    if (self.model == CPGlobalMapModelSearchedContacts) {
        [self updateUIForModelSearchedContactsUpdateRegion:NO];
    }
}

#pragma mark - Action
-(void) bottomViewClick:(id)sender{
    CPPointAnnotation* annotation = self.mapView.selectedAnnotations.firstObject;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CPContactsDetailViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"CPContactsDetailViewController"];
    controller.contactsUUID = annotation.uuid;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) allContactsButtonClick:(id)sender{
    self.model = CPGlobalMapModelContactsInRegion;
    [self updateUIForModelContactsInRegion];
}
-(void) localButtonClick:(id)sender{
    if ([self.mapView.userLocation location]) {
        [self.mapView setRegion:MACoordinateRegionMake(self.mapView.userLocation.coordinate, MACoordinateSpanMake(0.01, 0.01)) animated:YES];
    }
}
-(void) listButtonClick:(id)sender{
    CPContactsInMapTableViewController* controller = [[CPContactsInMapTableViewController alloc] initWithNibName:nil bundle:nil];
    controller.annotationArray = self.annotationArray;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - private
-(void) updateUIForModelContactsInRegion{
    [self doItInQueue:^{
        [self findAnnotationInMapViewRegion];
        [self performSelectorOnMainThread:@selector(updateMapView) withObject:nil waitUntilDone:YES];
    } cancelFrontBlock:YES];
}
-(void) updateUIForModelSearchedContactsUpdateRegion:(BOOL)updateRegion{
    [self doItInQueue:^{
        [self findAnnotationByContacts];
        [self performSelectorOnMainThread:@selector(updateMapView) withObject:nil waitUntilDone:YES];
        if (updateRegion) {
            [self performSelectorOnMainThread:@selector(updateRegion) withObject:nil waitUntilDone:YES];
        }
    } cancelFrontBlock:YES];
}
-(void) doItInQueue:(void (^)(void))block cancelFrontBlock:(BOOL)cancelBlock{
    if (cancelBlock) {
        // 取消以前的操作
        [self.queue cancelAllOperations];
    }
    // 创建最新的操作
    NSOperation* op = [NSBlockOperation blockOperationWithBlock:block];
    [self.queue addOperation:op];
}
#pragma mark - private load & init
-(void) findAnnotationInMapViewRegion{
    MAMapView* mapView = self.mapView;
    CLLocationCoordinate2D coordinate;
    coordinate = [mapView convertPoint:CGPointMake(-60, 0) toCoordinateFromView:mapView];
    double left = coordinate.longitude;
    double top = coordinate.latitude;
    coordinate = [mapView convertPoint:CGPointMake(mapView.frame.size.width+60, mapView.frame.size.height+80) toCoordinateFromView:mapView];
    double right = coordinate.longitude;
    double bottom = coordinate.latitude;
    CPLogVerbose(@"加载地图区域数据 left,right,top,bottom (%f,%f,%f,%f)",left,right,top,bottom);
    
    self.annotationArray = [NSMutableArray array];
    
    // 家庭地址
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name,f.cp_longitude,f.cp_latitude,f.cp_address_name FROM cp_contacts c INNER JOIN cp_family f ON f.cp_contact_uuid = c.cp_uuid WHERE f.cp_longitude NOTNULL AND f.cp_longitude != '' AND f.cp_latitude NOTNULL AND f.cp_latitude != '' AND CAST(f.cp_longitude AS NUMERIC)>=? AND CAST(f.cp_longitude AS NUMERIC) <=? AND CAST(f.cp_latitude AS NUMERIC)>=? AND CAST(f.cp_latitude AS NUMERIC)<=?" withArgumentsInArray:@[@(left),@(right),@(bottom),@(top)]];
        
        
        int columeCount = [set columnCount];
        while ([set next]) {
            CPPointAnnotation* annotation = [[CPPointAnnotation alloc] init];
            CLLocationDegrees longitude = 0;
            CLLocationDegrees latitude = 0;
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        annotation.uuid = sqlValue;
                        break;
                    }
                    case 1:{
                        annotation.title = sqlValue;
                        break;
                    }
                    case 2:{
                        longitude = sqlValue.doubleValue;
                        break;
                    }
                    case 3:{
                        latitude = sqlValue.doubleValue;
                        break;
                    }
                    case 4:{
                        annotation.subtitle = sqlValue;
                        break;
                    }
                    default:
                        break;
                }
            }
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            annotation.type = CPPointAnnotationTypeFamily;
            [self.annotationArray addObject:annotation];
        }
        [set close];
    }];
    
    // 公司地址
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name,f.cp_longitude,f.cp_latitude,f.cp_address_name FROM cp_contacts c INNER JOIN cp_company f ON f.cp_contact_uuid = c.cp_uuid WHERE f.cp_longitude NOTNULL AND f.cp_longitude != '' AND f.cp_latitude NOTNULL AND f.cp_latitude != '' AND CAST(f.cp_longitude AS NUMERIC)>=? AND CAST(f.cp_longitude AS NUMERIC) <=? AND CAST(f.cp_latitude AS NUMERIC)>=? AND CAST(f.cp_latitude AS NUMERIC)<=?" withArgumentsInArray:@[@(left),@(right),@(bottom),@(top)]];
        
        int columeCount = [set columnCount];
        while ([set next]) {
            CPPointAnnotation* annotation = [[CPPointAnnotation alloc] init];
            CLLocationDegrees longitude = 0;
            CLLocationDegrees latitude = 0;
            for (int i=0; i<columeCount; i++) {
                NSString* sqlValue = [set stringForColumnIndex:i];
                switch (i) {
                    case 0:{
                        annotation.uuid = sqlValue;
                        break;
                    }
                    case 1:{
                        annotation.title = sqlValue;
                        break;
                    }
                    case 2:{
                        longitude = sqlValue.doubleValue;
                        break;
                    }
                    case 3:{
                        latitude = sqlValue.doubleValue;
                        break;
                    }
                    case 4:{
                        annotation.subtitle = sqlValue;
                        break;
                    }
                    default:
                        break;
                }
            }
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            annotation.type = CPPointAnnotationTypeCompany;
            [self.annotationArray addObject:annotation];
        }
        [set close];
    }];
}

-(void) findAnnotationByContacts{
    CPContacts* contacts = self.contacts;
    self.annotationArray = [NSMutableArray array];
    CPFamily* family = [[CPDB getLKDBHelperByUser] searchSingle:[CPFamily class] where:[NSString stringWithFormat:@"cp_contact_uuid = '%@' AND cp_longitude NOTNULL AND cp_longitude != '' AND cp_latitude NOTNULL AND cp_latitude != ''",contacts.cp_uuid] orderBy:nil];
    if (family) {
        CPPointAnnotation* annotation = [[CPPointAnnotation alloc] init];
        annotation.uuid = contacts.cp_uuid;
        annotation.title = contacts.cp_name;
        annotation.subtitle = family.cp_address_name;
        annotation.coordinate = CLLocationCoordinate2DMake(family.cp_latitude.doubleValue, family.cp_longitude.doubleValue);
        annotation.type = CPPointAnnotationTypeFamily;
        [self.annotationArray addObject:annotation];
    }
    CPCompany* company = [[CPDB getLKDBHelperByUser] searchSingle:[CPCompany class] where:[NSString stringWithFormat:@"cp_contact_uuid = '%@' AND cp_longitude NOTNULL AND cp_longitude != '' AND cp_latitude NOTNULL AND cp_latitude != ''",contacts.cp_uuid] orderBy:nil];
    if (company) {
        CPPointAnnotation* annotation = [[CPPointAnnotation alloc] init];
        annotation.uuid = contacts.cp_uuid;
        annotation.title = contacts.cp_name;
        annotation.subtitle = company.cp_address_name;
        annotation.coordinate = CLLocationCoordinate2DMake(company.cp_latitude.doubleValue, company.cp_longitude.doubleValue);
        annotation.type = CPPointAnnotationTypeCompany;
        [self.annotationArray addObject:annotation];
    }
}
-(void) loadContactsWithSearchString:(NSString*)searchString{
    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT rowid,* FROM cp_contacts c WHERE c.cp_uuid IN(SELECT f.cp_contact_uuid FROM cp_family f LEFT OUTER JOIN cp_company com ON f.cp_contact_uuid = com.cp_contact_uuid WHERE f.cp_longitude NOTNULL AND f.cp_longitude != '' AND f.cp_latitude NOTNULL AND f.cp_latitude != '' UNION SELECT com.cp_contact_uuid FROM cp_company com LEFT OUTER JOIN  cp_family f ON f.cp_contact_uuid = com.cp_contact_uuid WHERE com.cp_longitude NOTNULL AND com.cp_longitude != '' AND com.cp_latitude NOTNULL AND com.cp_latitude != '')  AND c.cp_name LIKE ?" withArgumentsInArray:@[[NSString stringWithFormat:@"%%%@%%",searchString]]];
        self.contactsArray = [[CPDB getLKDBHelperByUser] executeResult:set Class:[CPContacts class]];
        [set close];
    }];
    //    self.contactsArray = [[CPDB getLKDBHelperByUser] search:[CPContacts class] where:[NSString stringWithFormat:@"cp_name like '%%%@%%'",searchString] orderBy:nil offset:0 count:-1];
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
#pragma mark - private ui
-(void) updateMapView{
//    CPLogVerbose(@"地图更新UI开始");
    // 清空大头针
    NSMutableArray* annotationForRemove = [@[] mutableCopy];
    for (id <MAAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
            [annotationForRemove addObject:annotation];
        }
    }
    [self.mapView removeAnnotations:annotationForRemove];
    
    // 添加大头针
    [self.mapView addAnnotations:self.annotationArray];
//    CPLogVerbose(@"地图更新UI结束");
}

-(void) updateRegion{
    // 调整地图可视范围
    if (self.annotationArray.count == 1){
        [self.mapView setVisibleMapRect:MAMapRectMake(220880104, 101476980, 272496, 466656) animated:NO];
        [self.mapView setCenterCoordinate:[self.annotationArray[0] coordinate] animated:YES];
    } else{
        [self.mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:self.annotationArray] edgePadding:UIEdgeInsetsMake(160, 60, 60, 60) animated:YES];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!searchText || [searchText isEqualToString:@""]) {
        return;
    }
    // 加载数据
    [self loadContactsWithSearchString:searchText];
    // 排序
    [self initContactsForSort];
    // 重载table
    [self.searchDisplayController.searchResultsTableView reloadData];
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    NSLog(@"%s",__FUNCTION__);
//}
//- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
//    NSLog(@"%s",__FUNCTION__);
//}
//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
//    NSLog(@"%s",__FUNCTION__);
//}
//- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
//    NSLog(@"%s",__FUNCTION__);
//}
//
//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
//    NSLog(@"%s",__FUNCTION__);
//}

#pragma mark - UISearchDisplayDelegate
//- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
//    if (self.searchDisplayController.searchBar.tag != 1) {
//        self.model = CPGlobalMapModelContactsInRegion;
//        [self updateUIForModelContactsInRegion];
//    }
//}
//- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
//    if (![controller.searchBar.text isEqual:@""]) {
////        [controller.searchResultsTableView reloadData];
////        [self.view addSubview:controller.searchResultsTableView];
//    }
//}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CPPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        CPCusAnnotationView *annotationView = (CPCusAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        if (annotationView == nil)
        {
#warning 这里每次都执行？ 影响效率
            annotationView = [[CPCusAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:customReuseIndetifier];
        }
        annotationView.cpAnnotation = annotation;
        
        return annotationView;
    }
    return nil;
}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (self.model == CPGlobalMapModelContactsInRegion) {
        [self updateUIForModelContactsInRegion];
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if (![view isKindOfClass:CPCusAnnotationView.class]) {
        return;
    }
    CPPointAnnotation* annotation = [(CPCusAnnotationView*)view cpAnnotation];
    self.nameLabel.text = annotation.title;
    self.addressLabel.text = annotation.subtitle;
    self.bottomView.hidden = NO;
    [self.view bringSubviewToFront:self.bottomView];
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view{
    self.bottomView.hidden = YES;
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
    self.model = CPGlobalMapModelSearchedContacts;
    NSString* aleph = self.contactsForAlephSortKeys[indexPath.section];
    self.contacts = self.contactsForAlephSort[aleph][indexPath.row];
    [self updateUIForModelSearchedContactsUpdateRegion:YES];
//    self.searchDisplayController.searchBar.tag = 1;
    [self.searchDisplayController setActive:NO animated:YES];
    self.searchDisplayController.searchBar.text = self.contacts.cp_name;
}
@end
