//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"
#import <TWMessageBarManager.h>

@implementation BaseMapViewController

@synthesize mapView = _mapView;
@synthesize search  = _search;

- (void)viewDidLoad{
    [super viewDidLoad];
    _goUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mapView = [CPMapUtil sharedMapView];
    self.search  = [CPMapUtil sharedMapSearchAPI];
    
    [self initMapView];
    [self initSearch];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self clearMapView];
    [self clearSearch];
}

#pragma mark - private

- (void)initMapView
{
    CGRect frame = self.view.bounds;
//    if (self.navigationController) {
//        CGFloat height = self.navigationController.toolbar.frame.size.height;
////        frame.origin.y += height;
//        frame.size.height -= height;
//    }
    if (self.tabBarController && !self.tabBarController.tabBar.hidden) {
        CGFloat height = self.tabBarController.tabBar.frame.size.height;
        frame.size.height -= height;
    }
    self.mapView.frame = frame;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
//    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
    self.mapView.showsUserLocation = YES;
//    if (self.mapView.userLocation.location) {
//        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:NO];
//    }
}

- (void)initSearch
{
    self.search.delegate = self;
}

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}

#pragma mark - MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (_goUserLocation && [self.mapView.userLocation location]) {
        [self.mapView setRegion:MACoordinateRegionMake(self.mapView.userLocation.coordinate, MACoordinateSpanMake(1, 1)) animated:YES];
        _goUserLocation = NO;
    }
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    [[TWMessageBarManager sharedInstance] hideAll];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                   description:@"定位失败"
                                                          type:TWMessageBarMessageTypeError];
    _goUserLocation = NO;
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

#pragma mark - AMapSearchDelegate
- (void)search:(id)searchRequest error:(NSString *)errInfo
{
    CPLogError(@"%s: searchRequest = %@, errInfo= %@", __func__, [searchRequest class], errInfo);
}
@end
