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

typedef NS_ENUM(NSInteger, MapModelType) {
    MapModelTypeFamily,
    MapModelTypeCompany
};

@interface MapModel : NSObject
@property(nonatomic)NSString* cp_uuid;
@property(nonatomic)NSString* cp_name;
@property(nonatomic)MapModelType type;
@property(nonatomic)NSString* cp_longitude;
@property(nonatomic)NSString* cp_latitude;
@end
@implementation MapModel
@end

@interface CPGlobalMapViewController ()<MAMapViewDelegate, AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@property (nonatomic) NSMutableArray* models;
@end

@implementation CPGlobalMapViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPContacts class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPFamily class]) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPCompany class]) object:nil];
    self.mapView = [CPMapUtil sharedMapView];
    self.search  = [CPMapUtil sharedMapSearchAPI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initMapView];
    [self initSearch];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self loadDB];
        self.dirty = NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self clearMapView];
    [self clearSearch];
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // 删除 map
//    [self.mapView removeFromSuperview];
//}
#pragma mark - private
-(void)loadDB{
    self.models = [NSMutableArray array];
    // 家庭
//    [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
//        FMResultSet* set = [db executeQuery:@"SELECT c.cp_uuid,c.cp_name FROM cp_contacts c INNER JOIN cp_trace t ON c.cp_uuid=t.cp_contact_uuid WHERE t.cp_date>=? AND t.cp_date<?" withArgumentsInArray:@[@(min),@(max)]];
//        int columeCount = [set columnCount];
//        while ([set next]) {
//            CPContacts* contacts = CPContacts.new;
//            CPTrace* trace = CPTrace.new;
//            objc_setAssociatedObject(contacts, &CPAssociatedKeyTrace, trace, OBJC_ASSOCIATION_RETAIN);
//            objc_setAssociatedObject(contacts, &CPAssociatedKeyCellTag, @(CP_CELL_TAG_TRACE), OBJC_ASSOCIATION_RETAIN);
//            for (int i=0; i<columeCount; i++) {
//                NSString* sqlValue = [set stringForColumnIndex:i];
//                switch (i) {
//                    case 0:{
//                        contacts.cp_uuid = sqlValue;
//                        break;
//                    }
//                    case 1:{
//                        contacts.cp_name = sqlValue;
//                        break;
//                    }
//                    case 2:{
//                        trace.cp_uuid = sqlValue;
//                        break;
//                    }
//                    case 3:{
//                        if (sqlValue) {
//                            trace.cp_date = [NSNumber numberWithDouble:sqlValue.doubleValue];
//                        }else{
//                            trace.cp_date = nil;
//                        }
//                        break;
//                    }
//                    case 4:{
//                        trace.cp_description = sqlValue;
//                        break;
//                    }
//                    default:
//                        break;
//                }
//            }
//            [contactsArray addObject:contacts];
//        }
//        [set close];
//    }];
}
#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    self.dirty = YES;
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



- (void)initMapView
{
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    [self.view sendSubviewToBack:self.mapView];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}
- (void)initSearch
{
    self.search.delegate = self;
}
- (void)clearMapView
{
    [self.mapView removeFromSuperview];
    
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}
- (void)clearSearch
{
    self.search.delegate = nil;
}
@end
