//
//  CPReadMapViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPReadMapViewController.h"

@interface CPReadMapViewController ()

@end

@implementation CPReadMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MAPointAnnotation *pa = [[MAPointAnnotation alloc] init];
    pa.coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    pa.title      = self.name;
    [self.mapView addAnnotation:pa];
    [self.mapView setCenterCoordinate:[pa coordinate] animated:NO];
    [self.mapView selectAnnotation:pa animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // 删除 map
    [self.mapView removeFromSuperview];
}
#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
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
@end
