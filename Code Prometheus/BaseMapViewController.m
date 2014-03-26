//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"

@implementation BaseMapViewController
@synthesize mapView = _mapView;
@synthesize search  = _search;

#pragma mark - AMapSearchDelegate

- (void)search:(id)searchRequest error:(NSString *)errInfo
{
    CPLogError(@"%s: searchRequest = %@, errInfo= %@", __func__, [searchRequest class], errInfo);
}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    [self.view sendSubviewToBack:self.mapView];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);

    self.mapView.showsUserLocation = YES;
    
    if (self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:NO];
    }
}

- (void)initSearch
{
    self.search.delegate = self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [CPMapUtil sharedMapView];
    self.search  = [CPMapUtil sharedMapSearchAPI];
    
//#warning 这里可能内存泄露
//    self.mapView = [[MAMapView alloc] initWithFrame:CGRectZero];
//    self.search  = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    
    [self initMapView];
    [self initSearch];
}
-(void)dealloc{
    [self clearMapView];
    [self clearSearch];
}

#pragma mark - Utility

- (void)clearMapView
{
//    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}
@end
