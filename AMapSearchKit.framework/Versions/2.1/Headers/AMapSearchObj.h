//
//  AMapSearchObj.h
//  searchKitV3
//
//  Created by yin cai on 13-7-2.
//  Copyright (c) 2013年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMapCommonObj.h"

typedef enum {
    AMapSearchType_PlaceID = 1,
    AMapSearchType_PlaceKeyword = 2,
    AMapSearchType_PlaceAround = 3,
    AMapSearchType_PlacePolygon = 4,
    AMapSearchType_Geocode = 5,
    AMapSearchType_ReGeocode = 6,
    AMapSearchType_StopKeyword = 8,
    AMapSearchType_InputTips = 9,
    AMapSearchType_RoadID = 11,
    AMapSearchType_LineID = 13,
    AMapSearchType_LineKeyword = 14,
    AMapSearchType_NaviDrive = 16,
    AMapSearchType_NaviWalking = 17,
    AMapSearchType_NaviBus = 20,
    
}AMapSearchType;

#pragma mark - AMapPlaceSearchRequest

@interface AMapPlaceSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType; // 默认为keyword
@property (nonatomic, assign) BOOL requireExtension; // 是否返回扩展信息，默认为 NO，若设置了requireGroup/requireDiscount任意一个为YES，则该参数自动设置为YES。

// requireGroup/requireDiscount两个参数必须设置requireExtension为YES才能生效。两个参数为“或”的关系，都设置为YES则返回有团购或者有优惠或者都有的POI。
@property (nonatomic, assign) BOOL requireGroup; // 是否过滤带团购信息的结果，默认为 NO
@property (nonatomic, assign) BOOL requireDiscount; // 是否过滤带优惠信息的结果，默认为 NO

// ID查询参数
@property (nonatomic, strong) NSString* uid;          // POI全局唯一ID

// 周边查询参数：
@property (nonatomic, strong) AMapGeoPoint* location; // 中心点坐标
@property (nonatomic, assign) NSInteger radius;       // 查询半径，单位：米 [default = 3000]

// 多边形查询参数
@property (nonatomic, strong) AMapGeoPolygon* polygon;   // 坐标串定义

// 关键字查询参数
@property (nonatomic, strong) NSString* keywords;     // 查询关键字，多个关键字用“|”分割，“空格"表示与，“双引号”表示不可分割
@property (nonatomic, strong) NSArray* types;         // POI分类字符串数组
@property (nonatomic, strong) NSArray* city;          // 城市数组，可选值：cityname（中文或中文全拼）、citycode、adcode

@property (nonatomic, assign) NSInteger sortrule;     // 排序规则：0-混合排序；1-距离排序 [default = 0]
@property (nonatomic, assign) NSInteger offset;       // 每页记录数 [default = 20]
@property (nonatomic, assign) NSInteger page;         // 当前页数 [default = 1]
@end

@interface AMapPlaceSearchResponse : NSObject

@property (nonatomic, assign) NSInteger count;            // 返回的POI数目
@property (nonatomic, strong) AMapSuggestion* suggestion; // 关键字建议列表和城市建议列表
@property (nonatomic, strong) NSArray* pois;              // POI对象数组

@end

#pragma mark - AMapGeocodeSearchRequest

@interface AMapGeocodeSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType;
@property (nonatomic, strong) NSString *address; //地址
@property (nonatomic, strong) NSArray *city; // 城市，可选值：cityname（中文或中文全拼）、citycode、adcode NSString数组
@end

@interface AMapGeocodeSearchResponse : NSObject

@property (nonatomic, assign) NSInteger count;            // 返回数目
@property (nonatomic, strong) NSArray* geocodes;          // 地理编码结果 AMapGeocode数组
@end

#pragma mark - AMapReGeocodeSearchRequest

@interface AMapReGeocodeSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType;
@property (nonatomic, assign) BOOL requireExtension; // 是否返回扩展信息，默认为 NO
@property (nonatomic, strong) AMapGeoPoint *location; // 中心点坐标
@property (nonatomic, assign) NSInteger radius; //[default = 500]; // 查询半径，单位：米
@property (nonatomic, strong) NSString *poiIdFilter; // 返回结果屏蔽此ID的POI

@end

@interface AMapReGeocodeSearchResponse : NSObject

@property(nonatomic, strong) AMapReGeocode *regeocode; // 逆地理编码结果

@end

#pragma mark - AMapInputTipsSearchRequest

@interface AMapInputTipsSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType;
@property (nonatomic, strong) NSString *keywords; // 查询关键字，多个关键字用“|”分割，“空格"表示与，“双引号”表示不可分割
@property (nonatomic, strong) NSArray *types; // POI分类 NSString数组
@property (nonatomic, strong) NSArray *city; // 城市，可选值：cityname（中文或中文全拼）、citycode、adcode NSString数组

@end

@interface AMapInputTipsSearchResponse : NSObject

@property (nonatomic, assign) NSInteger count;            // 返回数目
@property (nonatomic, strong) NSArray *tips; // 提示列表 AMapTip数组

@end

#pragma mark - AMapBusLineSearchRequest

@interface AMapBusLineSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType; // 默认为keyword
@property (nonatomic, assign) BOOL requireExtension; // 是否返回扩展信息，默认为 NO
@property (nonatomic, strong) NSString *uid; // 公交路线ID
@property (nonatomic, strong) NSString *keywords; // 查询关键字，多个关键字用“|”分割，“空格"表示与，“双引号”表示不可分割
@property (nonatomic, strong) NSArray *city; // 城市，可选值：cityname（中文或中文全拼）、citycode、adcode NSString数组
@property (nonatomic, assign) NSInteger offset; // [default = 20]; // 每页记录数
@property (nonatomic, assign) NSInteger page; // [default = 1]; // 当前页数

@end

@interface AMapBusLineSearchResponse : NSObject

@property (nonatomic, assign) NSInteger count;            // 返回数目
@property (nonatomic, strong) AMapSuggestion *suggestion; // 关键字建议列表和城市建议列表
@property (nonatomic, strong) NSArray *buslines; // 公交路线 AMapBusLine 数组
@end

#pragma mark - AMapBusStopSearchRequest

@interface AMapBusStopSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType; // 默认为keyword
@property (nonatomic, strong) NSString *keywords; // 查询关键字，多个关键字用“|”分割，“空格"表示与，“双引号”表示不可分割
@property (nonatomic, strong) NSArray *city; // 城市，可选值：cityname（中文或中文全拼）、citycode、adcode NSString数组
@property (nonatomic, assign) NSInteger offset; // [default = 20]; // 每页记录数
@property (nonatomic, assign) NSInteger page; // [default = 1]; // 当前页数

@end

@interface AMapBusStopSearchResponse : NSObject

@property (nonatomic, assign) NSInteger count;            // 返回数目
@property (nonatomic, strong) AMapSuggestion *suggestion; // 关键字建议列表和城市建议列表
@property (nonatomic, strong) NSArray *busstops; // 公交站 AMapBusStop 数组

@end

#pragma mark - AMapNavigationSearchRequest

@interface AMapNavigationSearchRequest : NSObject

@property (nonatomic, assign) AMapSearchType searchType; // 默认为bus
// 步行导航参数：
@property (nonatomic, assign) NSInteger multipath; //[default = 0]; // 是否提供备选步行方案：0-只提供一条步行方案；1-提供备选步行方案（有可能无备选方案）

// 驾车导航参数：
@property (nonatomic, strong) NSArray *waypoints; // 途经点 AMapGeoPoint 数组
@property (nonatomic, strong) NSArray *avoidpolygons; // 避让区域 AMapGeoPolygon 数组
@property (nonatomic, strong) NSString *avoidroad; // 避让道路名
@property (nonatomic, strong) NSString *originId; // 出发点 POI ID
@property (nonatomic, strong) NSString *destinationId; // 目的地 POI ID

// 公交换乘参数：
@property (nonatomic, assign) BOOL nightflag; // 是否包含夜班车

// 策略：
// 驾车导航策略：0-速度优先（时间）；1-费用优先（不走收费路段的最快道路）；2-距离优先；3-不走快速路；4-结合实时交通（躲避拥堵）；5-多策略（同时使用速度优先、费用优先、距离优先三个策略）；6-不走高速；7-不走高速且避免收费；8-躲避收费和拥堵；9-不走高速且躲避收费和拥堵
// 公交换乘策略：0-最快捷模式；1-最经济模式；2-最少换乘模式；3-最少步行模式；4-最舒适模式；5-不乘地铁模式
@property (nonatomic, assign) NSInteger strategy; //[default = 0];

@property (nonatomic, strong) AMapGeoPoint *origin; // 出发点
@property (nonatomic, strong) AMapGeoPoint *destination; // 目的地
@property (nonatomic, strong) NSString *city; // 城市
@property (nonatomic, assign) BOOL requireExtension; // 是否返回扩展信息，默认为 NO

@end

@interface AMapNavigationSearchResponse : NSObject

@property (nonatomic, assign) NSInteger count;            // 返回数目
@property (nonatomic, strong) AMapRoute *route;           // 导航方案

@end





