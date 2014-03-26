//
//  CPCalendarPickerStyleProvider.m
//  Code Prometheus
//
//  Created by mirror on 13-12-14.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPCalendarPickerStyleProvider.h"
#import <Masonry.h>

static NSInteger decorateWidth = 10;
static NSInteger decorateHeight = 10;

@implementation CPCalendarPickerStyleProvider



- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
 postUpdateForCellView:(UIControl*)control
        onControlState:(UIControlState)controlState
            withEvents:(NSInteger)eventsCount
              andState:(ABCalendarPickerState)state
{
    // -----------------------------------------------------
    // 自定义修饰
    // 删除约束
    [control removeConstraints:control.constraints];
    // 删除以前加的view,（可能存在）
    for (UIView* view in control.subviews) {
        [view removeFromSuperview];
    }
    
    CP_CELL_TYPE type = eventsCount;
    if (type != CP_CELL_TYPE_NORMAL) {
        UIImageView* decorate = nil;
        switch (type) {
            case CP_CELL_TYPE_MULTIPLE:{
                decorate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp_schedule_all"]];
                break;
            }
            case CP_CELL_TYPE_TRACE:{
                decorate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp_schedule_blue"]];
                break;
            }
            case CP_CELL_TYPE_PAY_REMIND:{
                decorate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp_schedule_red"]];
                break;
            }
            case CP_CELL_TYPE_BIRTHDAY:{
                decorate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp_schedule_yellow"]];
                break;
            }
            default:
                break;
        }
        [control addSubview:decorate];
        // 布局
        [decorate mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-1));
            make.bottom.equalTo(@(-1));
            make.width.equalTo(@(decorateWidth));
            make.height.equalTo(@(decorateHeight));
        }];
    }
    // -----------------------------------------------------
}
@end
