//
//  CustomCalloutView.h
//  Category_demo2D
//
//  Created by xiaoming han on 13-5-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCalloutAnnotation.h"

@protocol CustomCalloutViewDelegate <NSObject>
@optional
- (void)customCalloutAnnotation:(CustomCalloutAnnotation *)annotation didCustomCalloutControlTapped:(UIControl *)control;

@end

@interface CustomCalloutView : MAAnnotationView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) id<CustomCalloutViewDelegate> delegate;
@end
