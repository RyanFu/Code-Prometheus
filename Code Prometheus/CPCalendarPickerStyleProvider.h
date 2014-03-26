//
//  CPCalendarPickerStyleProvider.h
//  Code Prometheus
//
//  Created by mirror on 13-12-14.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "ABCalendarPickerDefaultStyleProvider.h"

typedef NS_ENUM(NSInteger, CP_CELL_TYPE) {
    CP_CELL_TYPE_NORMAL,
    CP_CELL_TYPE_MULTIPLE,
    CP_CELL_TYPE_TRACE,
    CP_CELL_TYPE_PAY_REMIND,
    CP_CELL_TYPE_BIRTHDAY
};

@interface CPCalendarPickerStyleProvider : ABCalendarPickerDefaultStyleProvider

@end
