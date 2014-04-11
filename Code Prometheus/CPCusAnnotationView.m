//
//  CPCusAnnotationView.m
//  Code Prometheus
//
//  Created by 管理员 on 14-4-1.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "CPCusAnnotationView.h"
#import <Masonry.h>

@implementation CPPointAnnotation
@end

@interface CPCusAnnotationView (){
    UIView* _title;
    UIImageView* _titleImage;
    UILabel* _titleName;
}
@end

@implementation CPCusAnnotationView

//#define kWidth  90
//#define kHeight 30
//#define cpTitleHeight 30

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        //        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        
        // must set to NO, so we can show the custom callout view.
        self.canShowCallout   = NO;
        self.draggable        = NO;
        
        self.image = [UIImage imageNamed:@"cp_map_3"];
        self.centerOffset = CGPointMake(0, -self.image.size.height/2);
        
        //        _title = [[UIView alloc] initWithFrame:CGRectMake((self.image.size.width - kWidth)/2, -kHeight, kWidth, kHeight)];
        //        _title.backgroundColor = [UIColor grayColor];
        //        [self addSubview:_title];
        //
        //        _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cpTitleHeight, cpTitleHeight)];
        //        [_title addSubview:_titleImage];
        //
        //        _titleName = [[UILabel alloc] initWithFrame:CGRectMake(kHeight, 0, kWidth - kHeight, kHeight)];
        //        _titleName.textColor = [UIColor whiteColor];
        //        [_title addSubview:_titleName];
        
        _title = [[UIView alloc] init];
        _title.backgroundColor = [UIColor grayColor];
        [self addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_top);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        _titleImage = [[UIImageView alloc] init];
        [_title addSubview:_titleImage];
        [_titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_title.mas_left);
            make.top.equalTo(_title.mas_top);
            make.bottom.equalTo(_title.mas_bottom);
            make.height.greaterThanOrEqualTo(@(30));
        }];
        
        _titleName = [[UILabel alloc] init];
        _titleName.textColor = [UIColor whiteColor];
        [_title addSubview:_titleName];
        [_titleName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleImage.mas_right);
            make.centerY.equalTo(_title.mas_centerY);
            make.right.equalTo(_title.mas_right);
            make.width.lessThanOrEqualTo(@(60));
        }];
    }
    return self;
}

-(void)setCpAnnotation:(CPPointAnnotation *)cpAnnotation{
    _cpAnnotation = cpAnnotation;
    if (cpAnnotation.type == CPPointAnnotationTypeFamily) {
        _titleImage.image = [UIImage imageNamed:@"cp_map_family"];
    }else if (cpAnnotation.type == CPPointAnnotationTypeCompany){
        _titleImage.image = [UIImage imageNamed:@"cp_map_company"];
    }else if (cpAnnotation.type == CPPointAnnotationTypeNone){
        _titleImage.image = nil;
    }
    if (cpAnnotation.type == CPPointAnnotationTypeNone) {
        [_titleName mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleImage.mas_right);
            make.centerY.equalTo(_title.mas_centerY);
            make.right.equalTo(_title.mas_right);
            make.width.lessThanOrEqualTo(@(320));
        }];
    }else{
        [_titleName mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleImage.mas_right);
            make.centerY.equalTo(_title.mas_centerY);
            make.right.equalTo(_title.mas_right);
            make.width.lessThanOrEqualTo(@(60));
        }];
    }
    _titleName.text = cpAnnotation.title;
}


- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        self.image = [UIImage imageNamed:@"cp_map_2"];
    }
    else
    {
        self.image = [UIImage imageNamed:@"cp_map_3"];
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside)
    {
        inside = [_title pointInside:[self convertPoint:point toView:_title] withEvent:event];
    }
    return inside;
}

#pragma mark - private


@end