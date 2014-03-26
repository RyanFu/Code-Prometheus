//
//  MAGeometry.h
//  MAMapKitDemo
//
//  Created by songjian on 12-12-21.
//  Copyright (c) 2012年 songjian. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    CLLocationDegrees latitudeDelta;
    CLLocationDegrees longitudeDelta;
} MACoordinateSpan;

typedef struct {
	CLLocationCoordinate2D center;
	MACoordinateSpan span;
} MACoordinateRegion;

static inline MACoordinateSpan MACoordinateSpanMake(CLLocationDegrees latitudeDelta, CLLocationDegrees longitudeDelta)
{
    return (MACoordinateSpan){latitudeDelta, longitudeDelta};
}

static inline MACoordinateRegion MACoordinateRegionMake(CLLocationCoordinate2D centerCoordinate, MACoordinateSpan span)
{
    return (MACoordinateRegion){centerCoordinate, span};
}

extern MACoordinateRegion MACoordinateRegionMakeWithDistance(CLLocationCoordinate2D centerCoordinate,
                                                             CLLocationDistance latitudinalMeters,
                                                             CLLocationDistance longitudinalMeters);


typedef struct {
    double x;
    double y;
} MAMapPoint;

typedef struct {
    double width;
    double height;
} MAMapSize;

typedef struct {
    MAMapPoint origin;
    MAMapSize size;
} MAMapRect;

/*!
 @brief 经纬度转投影
 */
extern MAMapPoint MAMapPointForCoordinate(CLLocationCoordinate2D coordinate);

/*!
 @brief 投影转经纬度
 */
extern CLLocationCoordinate2D MACoordinateForMapPoint(MAMapPoint mapPoint);

/*!
 @brief 投影Rect转经纬度Rect
 */
extern MACoordinateRegion MACoordinateRegionForMapRect(MAMapRect rect);

/*!
 @brief 经纬度Rect转投影Rect
 */
extern MAMapRect MAMapRectForCoordinateRegion(MACoordinateRegion region);

static inline MAMapPoint MAMapPointMake(double x, double y)
{
    return (MAMapPoint){x, y};
}

static inline MAMapSize MAMapSizeMake(double width, double height)
{
    return (MAMapSize){width, height};
}

static inline MAMapRect MAMapRectMake(double x, double y, double width, double height)
{
    return (MAMapRect){MAMapPointMake(x, y), MAMapSizeMake(width, height)};
}

static inline double MAMapRectGetMinX(MAMapRect rect)
{
    return rect.origin.x;
}

static inline double MAMapRectGetMinY(MAMapRect rect)
{
    return rect.origin.y;
}

static inline double MAMapRectGetMidX(MAMapRect rect)
{
    return rect.origin.x + rect.size.width / 2.0;
}

static inline double MAMapRectGetMidY(MAMapRect rect)
{
    return rect.origin.y + rect.size.height / 2.0;
}

static inline double MAMapRectGetMaxX(MAMapRect rect)
{
    return rect.origin.x + rect.size.width;
}

static inline double MAMapRectGetMaxY(MAMapRect rect)
{
    return rect.origin.y + rect.size.height;
}

static inline double MAMapRectGetWidth(MAMapRect rect)
{
    return rect.size.width;
}

static inline double MAMapRectGetHeight(MAMapRect rect)
{
    return rect.size.height;
}

extern BOOL MAMapRectContainsPoint(MAMapRect rect, MAMapPoint point);
    
extern BOOL MAMapRectIntersectsRect(MAMapRect rect1, MAMapRect rect2);

/*!
 @brief 单位投影的距离
 */
extern CLLocationDistance MAMetersPerMapPointAtLatitude(CLLocationDegrees latitude);
    
/*!
 @brief 1米对应的投影
 */
extern double MAMapPointsPerMeterAtLatitude(CLLocationDegrees latitude);

/*!
 @brief 投影两点之间的距离
 */
extern CLLocationDistance MAMetersBetweenMapPoints(MAMapPoint a, MAMapPoint b);

/*!
 @brief 经纬度间的面积(单位 平方米)
 */
extern double MAAreaBetweenCoordinates(CLLocationCoordinate2D leftTop, CLLocationCoordinate2D rightBottom);
    
#ifdef __cplusplus
}
#endif

