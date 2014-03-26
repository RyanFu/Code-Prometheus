//
//  AMapCommonObj.h
//  searchKitV3
//
//  Created by yin cai on 13-7-3.
//  Copyright (c) 2013年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

/*!
 @brief 经纬度
 */
@interface AMapGeoPoint : NSObject

@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

+ (AMapGeoPoint *)locationWithLatitude:(CGFloat)lat longitude:(CGFloat)lon;

@end

/*!
 @brief 多边形 矩形:左下-右上两个顶点，其他情况需要首尾坐标相同，当做闭合图形处理
 */
@interface AMapGeoPolygon : NSObject

@property (nonatomic, assign) NSInteger type; // 0:多边形 1:圆
@property (nonatomic, strong) NSArray* points;// 坐标集:AMapGeoPoint数组

+ (AMapGeoPolygon *)polygonWithPoints:(NSArray *)points;

@end

/*!
 @brief 查询建议中的城市
 */
@interface AMapCity : NSObject

@property (nonatomic, strong) NSString* city;  // 城市名称
@property (nonatomic, assign) NSInteger num;   // 此区域的建议结果数目
@property (nonatomic, strong) NSString* citycode; // 城市编码
@property (nonatomic, strong) NSString* adcode; // 区域编码

+ (AMapCity *)cityWithName:(NSString *)city num:(NSInteger)num citycode:(NSString *)citycode adcode:(NSString *)adcode;

@end

/*!
 @brief 查询建议
 */
@interface AMapSuggestion : NSObject

@property (nonatomic, strong) NSArray* keywords; //NSString数组
@property (nonatomic, strong) NSArray* cities;   //AMapCity数组

@end

/*!
 @brief 图片信息
 */
@interface AMapPhoto : NSObject

@property (nonatomic, strong) NSString* title; // 标题
@property (nonatomic, strong) NSString* url; // URL地址
@property (nonatomic, strong) NSString* provider; // 来源

+ (AMapPhoto *)photoWithTitle:(NSString *)title url:(NSString *)url provider:(NSString *)provider;

@end

/*!
 @brief 团购信息
 */
@interface AMapGroupBuy : NSObject

@property (nonatomic, strong) NSString* typeCode; // 团购分类代码
@property (nonatomic, strong) NSString* type; // 团购分类
@property (nonatomic, strong) NSString* detail; // 团购详情
@property (nonatomic, strong) NSString* startTime; // 团购开始时间
@property (nonatomic, strong) NSString* endTime; // 团购结束时间
@property (nonatomic, assign) NSInteger num; // 团购总量
@property (nonatomic, assign) NSInteger soldNum; // 已卖出数量
@property (nonatomic, assign) CGFloat originalPrice; // 原价
@property (nonatomic, assign) CGFloat groupbuyPrice; // 团购价
@property (nonatomic, assign) CGFloat discount; // 折扣
@property (nonatomic, strong) NSString* ticketAddress; // 取票地址
@property (nonatomic, strong) NSString* ticketTel; // 取票电话
@property (nonatomic, strong) NSArray* photos; //图片信息 : AMapPhoto数组
@property (nonatomic, strong) NSString* url; // 来源URL
@property (nonatomic, strong) NSString* provider; // 来源标识

@end

/*!
 @brief 打折信息
 */
@interface AMapDiscount : NSObject

@property (nonatomic,strong) NSString* title; // 标题
@property (nonatomic,strong) NSString* detail; // 优惠详情
@property (nonatomic,strong) NSString* startTime; // 开始时间
@property (nonatomic,strong) NSString* endTime; // 结束时间
@property (nonatomic,assign) NSInteger soldNum; // 已卖出数量
@property (nonatomic,strong) NSArray* photos; //图片信息 : AMapPhoto数组
@property (nonatomic,strong) NSString* url; // 来源URL
@property (nonatomic,strong) NSString* provider; // 来源标识

@end

/*!
 @brief 动态市场信息
 */
@interface AMapRichContent : NSObject

@property (nonatomic,strong) NSArray* groupbuys; //团购信息 : AMapGroupBuy数组
@property (nonatomic,strong) NSArray* discounts; //优惠信息 : AMapDiscount数组

@end

/*!
 @brief POI
 */
@interface AMapPOI : NSObject

// 基础POI信息:
@property (nonatomic,strong) NSString* uid; // POI全局唯一ID
@property (nonatomic,strong) NSString* name; // 名称
@property (nonatomic,strong) NSString* type; // 兴趣点类型
@property (nonatomic,strong) AMapGeoPoint* location; // 经纬度
@property (nonatomic,strong) NSString* address;  // 地址
@property (nonatomic,strong) NSString* tel;  // 电话
@property (nonatomic,assign) NSInteger distance; // 距中心点距离

//extensions:
@property (nonatomic,strong) NSString* postcode; // 邮编
@property (nonatomic,strong) NSString* website; // 网址
@property (nonatomic,strong) NSString* email;    // 电子邮件
@property (nonatomic,strong) NSString* citycode; // 城市编码
@property (nonatomic,strong) NSString* adcode;   // 区域编码
@property (nonatomic,strong) NSString* gridcode; // 地理格ID /* 暂未开通 */
@property (nonatomic,strong) NSString* navipoiid; // 导航点ID/* 暂未开通 */
@property (nonatomic,strong) AMapGeoPoint* enterLocation; // 入口经纬度
@property (nonatomic,strong) AMapGeoPoint* exitLocation; // 出口经纬度
@property (nonatomic,assign) CGFloat weight; // 权重 /* 暂未开通 */
@property (nonatomic,assign) CGFloat match;  // 匹配 /* 暂未开通 */
@property (nonatomic,assign) NSInteger recommend; // 推荐标识 /* 暂未开通 */
@property (nonatomic,assign) NSString* timestamp; // 时间戳 /* 暂未开通 */
@property (nonatomic,assign) NSInteger groupbuyNum; // 团购信息数目
@property (nonatomic,assign) NSInteger discountNum; // 优惠信息数目
@property (nonatomic,strong) AMapRichContent* richContent; // 动态市场信息
@property (nonatomic,strong) NSString *direction; // 方向

@end

/*!
 @brief 公交站
 */
@interface AMapBusStop : NSObject

@property (nonatomic, strong) NSString *uid; // 公交站ID
@property (nonatomic, strong) NSString *name; // 站名
@property (nonatomic, assign) NSInteger sequence; // 公交站序号
@property (nonatomic, strong) NSString *citycode; // 城市编码
@property (nonatomic, strong) NSString *adcode; // 区域编码
@property (nonatomic, strong) NSString *gridcode; // 地理格ID /* 暂未开通 */
@property (nonatomic, strong) AMapGeoPoint *location; // 经纬度
@property (nonatomic, strong) NSString *timestamp; // 时间戳 /* 暂未开通 */
@property (nonatomic, strong) NSArray *buslines; // 途径此站的公交路线 AMapBusLine 数组 

@end

/*!
 @brief 公交线路
 */
@interface AMapBusLine : NSObject

// 基础信息:
@property (nonatomic, strong) NSString *uid; // 公交线路ID
@property (nonatomic, strong) NSString *name; // 线路名称
@property (nonatomic, strong) NSString *type; // 公交类型
@property (nonatomic, strong) NSString *polyline; // 坐标串定义
@property (nonatomic, strong) NSString *citycode; // 城市编码
@property (nonatomic, strong) NSString *gridcode; // 地理格ID /* 暂未开通 */
@property (nonatomic, strong) AMapBusStop *startStop; // 首发站
@property (nonatomic, strong) AMapBusStop *endStop; // 终点站

// extensions:
@property (nonatomic, strong) NSString *startTime; // 首班车时间
@property (nonatomic, strong) NSString *endTime; // 末班车时间
@property (nonatomic, strong) NSString *company; // 所属公交公司
@property (nonatomic, assign) float distance; // 全程里程（单位：千米）
@property (nonatomic, assign) NSInteger duration; // 预计行驶时间（单位：秒）
@property (nonatomic, assign) float basicPrice; // 起步价
@property (nonatomic, assign) float totalPrice; // 全程票价
@property (nonatomic, strong) NSArray *bounds; // 矩形区域左下、右上顶点坐标 AMapGeoPoint 数组
@property (nonatomic, assign) NSInteger busStopsNum; // 途径公交站数
@property (nonatomic, strong) NSArray *busStops; // 途经公交站 AMapBusStop数组
@property (nonatomic, strong) AMapBusStop *departureStop; // 起程站
@property (nonatomic, strong) AMapBusStop *arrivalStop; // 下车站

@end

/*!
 @brief 输入提示
 */
@interface AMapTip : NSObject

@property (nonatomic, strong) NSString *name; // 名称
@property (nonatomic, strong) NSString *adcode; // 区域编码
@property (nonatomic, strong) NSString *district; // 所属区域

+ (AMapTip *)tipWithName:(NSString *)name adcode:(NSString *)adcode district:(NSString *)district;

@end

/*!
 @brief 地理编码
 */
@interface AMapGeocode : NSObject

@property (nonatomic, strong) NSString *formattedAddress; // 格式化地址
@property (nonatomic, strong) NSString *province; // 所在省
@property (nonatomic, strong) NSString *city; // 城市名
@property (nonatomic, strong) NSString *district; // 区域名称
@property (nonatomic, strong) NSString *township; // 所在乡镇
@property (nonatomic, strong) NSString *neighborhood; // 社区
@property (nonatomic, strong) NSString *building; // 楼
@property (nonatomic, strong) NSString *adcode; // 区域编码
@property (nonatomic, strong) AMapGeoPoint *location; // 坐标点
@property (nonatomic, strong) NSArray *level; // 匹配的等级 NSString 数组

@end

/*!
 @brief 道路
 */
@interface AMapRoad : NSObject

@property (nonatomic, strong) NSString *uid; // 道路ID
@property (nonatomic, strong) NSString *name; // 道路名称
@property (nonatomic, assign) NSInteger distance; // 距离（单位：米）
@property (nonatomic, strong) NSString *direction; // 方向
@property (nonatomic, strong) AMapGeoPoint *location; // 坐标点
@property (nonatomic, strong) NSString *citycode; // 城市编码
@property (nonatomic, strong) NSString *width; // 道路宽度
@property (nonatomic, strong) NSString *type; // 道路分类

@end

/*!
 @brief 道路交叉口
 */
@interface AMapRoadInter : NSObject

@property (nonatomic, assign) NSInteger distance; // 距离（单位：米）
@property (nonatomic, strong) NSString *direction; // 方向
@property (nonatomic, strong) AMapGeoPoint *location; // 经纬度
@property (nonatomic, strong) NSString *firstId; // 第一条道路ID
@property (nonatomic, strong) NSString *firstName; // 第一条道路名称
@property (nonatomic, strong) NSString *secondId; // 第二条道路ID
@property (nonatomic, strong) NSString *secondName; // 第二条道路名称

@end

/*!
 @brief 门牌信息
 */
@interface AMapStreetNumber : NSObject

@property (nonatomic, strong) NSString *street; // 街道名称
@property (nonatomic, strong) NSString *number; // 门牌号
@property (nonatomic, strong) AMapGeoPoint *location; //  坐标点
@property (nonatomic, assign) NSInteger distance; // 距离（单位：米）
@property (nonatomic, strong) NSString *direction; //  方向

@end

/*!
 @brief 地址组成要素
 */
@interface AMapAddressComponent : NSObject

@property (nonatomic, strong) NSString *province; // 省
@property (nonatomic, strong) NSString *city; // 市
@property (nonatomic, strong) NSString *district; // 区
@property (nonatomic, strong) NSString *township; // 乡镇
@property (nonatomic, strong) NSString *neighborhood; // 社区
@property (nonatomic, strong) NSString *building; // 建筑
@property (nonatomic, strong) AMapStreetNumber *streetNumber; // 门牌信息

@end

/*!
 @brief 逆地理编码
 */
@interface AMapReGeocode : NSObject

@property (nonatomic, strong) NSString *formattedAddress; // 格式化地址
@property (nonatomic, strong) AMapAddressComponent *addressComponent; // 地址组成要素

// extensions:
@property (nonatomic, strong) NSArray *roads; // 道路信息 AMapRoad数组
@property (nonatomic, strong) NSArray *roadinters; // 道路路口信息 AMapRoadInter 数组
@property (nonatomic, strong) NSArray *pois; // 兴趣点信息 AMapPOI数组

@end

// -----步行、驾车导航-----

/*!
 @brief 实时路况信息
 */
@interface AMapTMC : NSObject

@property (nonatomic, strong) NSString *lcode; // 路况信息对应的locationcode
@property (nonatomic, assign) NSInteger distance; // 路段长度（单位：米）
@property (nonatomic, assign) NSInteger status; // 路况状态：0-未知；1-畅通；2-缓行；3-拥堵

+ (AMapTMC *)TMCWithLCode:(NSString *)lcode distance:(NSInteger)distance status:(NSInteger)status;

@end

/*!
 @brief 导航路段
 */
@interface AMapStep : NSObject

// 基础信息:
@property (nonatomic, strong) NSString *instruction; // 行走指示
@property (nonatomic, strong) NSString *orientation; // 方向
@property (nonatomic, strong) NSString *road; // 道路名称
@property (nonatomic, assign) NSInteger distance; // 此路段长度（单位：米）
@property (nonatomic, assign) NSInteger duration; // 此路段预计耗时（单位：秒）
@property (nonatomic, strong) NSString *polyline; // 此路段坐标点串
@property (nonatomic, strong) NSString *action; // 导航主要动作
@property (nonatomic, strong) NSString *assistantAction; // 导航辅助动作
@property (nonatomic, assign) float tolls; // 此段收费（单位：元）
@property (nonatomic, assign) NSInteger tollDistance; // 收费路段长度（单位：米）
@property (nonatomic, strong) NSString *tollRoad; // 主要收费路段

// extensions:
@property (nonatomic, strong) NSArray *tmcs; // 路况信息 AMapTMC 数组

@end

/*!
 @brief 步行、驾车方案
 */
@interface AMapPath : NSObject

@property (nonatomic, assign) NSInteger distance; // 起点和终点的距离
@property (nonatomic, assign) NSInteger duration; // 预计耗时（单位：秒）
@property (nonatomic, strong) NSString *strategy; // 导航策略
@property (nonatomic, strong) NSArray *steps; // 导航路段 AMapStep数组
@property (nonatomic, assign) float tolls; // 此方案费用（单位：元）
@property (nonatomic, assign) NSInteger tollDistance; // 此方案收费路段长度（单位：米）

@end

/*!
 @brief 导航方案
 */
@class AMapTransit;
@interface AMapRoute : NSObject

@property (nonatomic, strong) AMapGeoPoint *origin; // 起点坐标
@property (nonatomic, strong) AMapGeoPoint *destination; // 终点坐标
@property (nonatomic, assign) float taxiCost; // 出租车费用（单位：元）
@property (nonatomic, strong) NSArray *paths; // 步行、驾车方案列表 AMapPath 数组
@property (nonatomic, strong) NSArray *transits; // 公交换乘方案列表 AMapTransit 数组

@end

// -----公交换乘-----

/*!
 @brief 步行导航信息
 */
@interface AMapWalking : NSObject

@property (nonatomic, strong) AMapGeoPoint *origin; // 起点坐标
@property (nonatomic, strong) AMapGeoPoint *destination; // 终点坐标
@property (nonatomic, assign) NSInteger distance; // 起点和终点的步行距离
@property (nonatomic, assign) NSInteger duration; // 步行预计时间
@property (nonatomic, strong) NSArray *steps; // 步行路段 AMapStep数组

@end

/*!
 @brief 公交换乘路段
 */
@interface AMapSegment : NSObject

@property (nonatomic, strong) AMapWalking *walking; // 此路段步行导航信息
@property (nonatomic, strong) AMapBusLine *busline; // 此路段公交导航信息
@property (nonatomic, strong) NSString *enterName; // 入口名称
@property (nonatomic, strong) AMapGeoPoint *enterLocation; // 入口经纬度
@property (nonatomic, strong) NSString *exitName; // 出口名称
@property (nonatomic, strong) AMapGeoPoint *exitLocation; // 出口经纬度

@end

/*!
 @brief 公交方案
 */
@interface AMapTransit : NSObject

@property (nonatomic, assign) float cost; // 此公交方案价格（单位：元）
@property (nonatomic, assign) NSInteger duration; // 此换乘方案预期时间（单位：秒）
@property (nonatomic, assign) BOOL nightflag; // 是否是夜班车
@property (nonatomic, assign) NSInteger walkingDistance; // 此方案总步行距离（单位：米）
@property (nonatomic, strong) NSArray  *segments; // 换乘路段 AMapSegment数组

@end





