//
//  CustomCalloutView.m
//  Category_demo2D
//
//  Created by xiaoming han on 13-5-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CustomCalloutView.h"
#import <QuartzCore/QuartzCore.h>

#define kCalloutMargin      10
#define kPortraitSize       40
#define kLabelWidth         70
#define kLabelHeight        30
#define kButtonSize         32

#define kCalloutWidth   200.0
#define kCalloutHeight  70.0
#define kArrorHeight    10

@interface CustomCalloutView ()

- (void)calloutAccessoryAction:(id)sender;
- (void)initContent;

@end

@implementation CustomCalloutView

@synthesize contentView = _contentView;
@synthesize delegate = _delegate;

- (CustomCalloutAnnotation *)customAnnotation
{
    return (CustomCalloutAnnotation *)self.annotation;
}

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.draggable = NO;
        self.canShowCallout = NO;//must be NO
        self.centerOffset = CGPointMake(0, -kCalloutHeight);
        self.bounds = CGRectMake(0, 0, kCalloutWidth, kCalloutHeight);
        
        [self initContent];
    }
    return self;
    
}

- (void)initContent
{
    if (_contentView != nil) {
        return;
    }
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    
    UIImageView *portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCalloutMargin, kCalloutMargin, kPortraitSize, kPortraitSize)];
    portraitImageView.image = [UIImage imageNamed:@"hema.png"];
    [_contentView addSubview:portraitImageView];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(kCalloutMargin * 2 + kPortraitSize, kCalloutMargin, kLabelWidth, kLabelHeight)];
    name.backgroundColor = [UIColor clearColor];
    name.textColor = [UIColor redColor];
    name.text = [self customAnnotation].name;
    [_contentView addSubview:name];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(calloutAccessoryAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(_contentView.bounds.size.width - kButtonSize - kCalloutMargin, kCalloutMargin, kButtonSize, kButtonSize);
    [_contentView addSubview:button];
    
    [self addSubview:_contentView];
    
}

- (void)calloutAccessoryAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(customCalloutAnnotation:didCustomCalloutControlTapped:)]) {
        [_delegate customCalloutAnnotation:[self customAnnotation] didCustomCalloutControlTapped:sender];
    }
}

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
