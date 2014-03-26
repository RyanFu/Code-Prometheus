//
//  CPSearchBar.m
//  Code Prometheus
//
//  Created by mirror on 13-11-22.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPSearchBar.h"

@implementation CPSearchBar
-(id)init{
    self = [super init];
    if (self) {
        [self initStyle];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initStyle];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initStyle];
    }
    return self;
}

#pragma mark - private
-(void) initStyle{
    if (CP_IS_IOS7_AND_UP) {
        self.searchBarStyle = UISearchBarStyleMinimal;
    }else{
        self.tintColor = [UIColor whiteColor];
    }
//    //定义取消按钮
//    for (UIView *searchbuttons in self.subviews)
//    {
//        if ([searchbuttons isKindOfClass:[UIButton class]])
//        {
//            UIButton *cancelButton = (UIButton*)searchbuttons;
//            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            break;
//        }
//    }
}

@end
