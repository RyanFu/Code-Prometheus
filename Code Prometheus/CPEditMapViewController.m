//
//  CPEditMapViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-6.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPEditMapViewController.h"
#import "GeocodeAnnotation.h"
#import "CommonUtility.h"
#import "ReGeocodeAnnotation.h"
#import <MBProgressHUD.h>


@interface CPEditMapViewController ()<UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate>
@property(nonatomic) MBProgressHUD* hud;
@property (nonatomic, strong) NSMutableArray *tips;
@end

@implementation CPEditMapViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tips = [NSMutableArray array];
    // UI
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClick:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.searchDisplayController.searchBar.placeholder = self.name;
    
    // 长按手势
    UILongPressGestureRecognizer *btnLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    btnLongTap.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:btnLongTap];
    
    if (self.invain && self.invain.boolValue) {
        // 地址有效
        MAPointAnnotation *pa = [[MAPointAnnotation alloc] init];
        pa.coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
        pa.title      = self.name;
        [self.mapView addAnnotation:pa];
        [self.mapView setCenterCoordinate:[pa coordinate] animated:NO];
        [self.mapView selectAnnotation:pa animated:YES];
    }else{
        // 地址无效
        if (self.name) {
            NSString* addressName = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![addressName isEqualToString:@""]) {
                AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
                geo.address = addressName;
                [self.search AMapGeocodeSearch:geo];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // 删除 map
    [self.mapView removeFromSuperview];
}
#pragma mark - private
/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    [self.search AMapInputTipsSearch:tips];
}
/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    
    [self.search AMapGeocodeSearch:geo];
}
- (void)clearAndSearchGeocodeWithKey:(NSString *)key
{
    /* 清除annotation. */
    [self clear];
    
    [self searchGeocodeWithKey:key];
}
/* 清除annotation. */
- (void)clear
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}
#pragma mark - IBAction
-(IBAction) saveButtonClick:(UIButton*)sender{
    // 保存信息
    if (self.mapView.selectedAnnotations.count>0) {
        // 选点
        id<MAAnnotation> annotation = self.mapView.selectedAnnotations.lastObject;
        
        // 调用代理
        if (self.delegate) {
            [self.delegate saveAddress:self name:[annotation title] longitude:[NSString stringWithFormat:@"%f",annotation.coordinate.longitude] latitude:[NSString stringWithFormat:@"%f",annotation.coordinate.latitude]];
        }
        // 返回上个视图
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        // 没选点
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请选点" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}
-(IBAction)cancelButtonClick:(id)sender{
    // 返回上个视图
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Action
- (void)tapGesture:(id)sender
{
    UILongPressGestureRecognizer* lp = sender;
    if(UIGestureRecognizerStateBegan != lp.state) {
        return;
    }
    // 启动进度条
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    // 搜索逆向地理编码
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[lp locationInView:self.view] toCoordinateFromView:self.mapView];
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    [self.search AMapReGoecodeSearch:regeo];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:tipCellIdentifier];
    }
    
    AMapTip *tip = self.tips[indexPath.row];
    
    cell.textLabel.text = tip.name;
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapTip *tip = self.tips[indexPath.row];
    [self clearAndSearchGeocodeWithKey:tip.name];
    [self.searchDisplayController setActive:NO animated:NO];
    self.searchDisplayController.searchBar.placeholder = tip.name;
}
#pragma mark - AMapSearchDelegate
// 搜索异常
- (void)search:(id)searchRequest error:(NSString*)errInfo{
    [super search:searchRequest error:errInfo];
    if (self.hud) {
        // hud消失
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
}

/* 地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count == 0)
    {
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:obj];
        
        [annotations addObject:geocodeAnnotation];
    }];
    
    if (annotations.count == 1)
    {
        [self.mapView setVisibleMapRect:MAMapRectMake(220880104, 101476980, 272496, 466656) animated:YES];
        [self.mapView setCenterCoordinate:[annotations[0] coordinate] animated:YES];
    }
    else
    {
        [self.mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:annotations]
                               animated:YES];
    }
    
    [self.mapView addAnnotations:annotations];
}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    // hud消失
    [self.hud removeFromSuperview];
    self.hud = nil;
    if (response.regeocode != nil)
    {
        // 删除上个点击的大头针
        for (id<MAAnnotation> an in [self.mapView annotations]) {
            if ([an isKindOfClass:[ReGeocodeAnnotation class]]) {
                [self.mapView removeAnnotation:an];
            }
        }
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate reGeocode:response.regeocode];
        
        [self.mapView addAnnotation:reGeocodeAnnotation];
        [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];
    }
}
/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    [self.tips setArray:response.tips];
    [self.searchDisplayController.searchResultsTableView reloadData];
}
#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    // 用户点击的点
    if ([annotation isKindOfClass:[ReGeocodeAnnotation class]])
    {
        static NSString *invertGeoIdentifier = @"invertGeoIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:invertGeoIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:invertGeoIdentifier];
            poiAnnotationView.animatesDrop   = YES;
            poiAnnotationView.canShowCallout = YES;
//            poiAnnotationView.image = [UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_SELECT_0];
//            poiAnnotationView.centerOffset = CGPointMake(0, -22);
        }
        
        return poiAnnotationView;
    }
    // 地理搜索的点
    if ([annotation isKindOfClass:[GeocodeAnnotation class]])
    {
        static NSString *geoCellIdentifier = @"geoCellIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:geoCellIdentifier];
            poiAnnotationView.animatesDrop   = YES;
            poiAnnotationView.canShowCallout = YES;
        }
        
        return poiAnnotationView;
    }
    // 数据库保存经纬度的点
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            annotationView.canShowCallout            = YES;
            annotationView.animatesDrop              = NO;
//            annotationView.image = [UIImage imageNamed:CP_RESOURCE_IMAGE_MAP_SELECT_0];
//            annotationView.centerOffset = CGPointMake(0, -22);
        }
        return annotationView;
    }
    return nil;
}
#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchTipsWithKey:searchString];
    return NO;
}
#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *key = searchBar.text;
    [self clearAndSearchGeocodeWithKey:key];
    [self.searchDisplayController setActive:NO animated:NO];
    self.searchDisplayController.searchBar.placeholder = key;
}
@end
