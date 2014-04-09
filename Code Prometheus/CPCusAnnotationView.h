//
//  CPCusAnnotationView.h
//  Code Prometheus
//
//  Created by 管理员 on 14-4-1.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

typedef NS_ENUM(NSInteger, CPPointAnnotationType) {
    CPPointAnnotationTypeFamily,
    CPPointAnnotationTypeCompany
};

@interface CPPointAnnotation : MAPointAnnotation
@property(nonatomic)NSString* uuid;
@property(nonatomic)CPPointAnnotationType type;
@end


@interface CPCusAnnotationView : MAAnnotationView
@property (nonatomic) CPPointAnnotation *cpAnnotation;
@end
