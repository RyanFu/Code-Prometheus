//
//  CPUserDefaults.m
//  Code Prometheus
//
//  Created by mirror on 13-11-21.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPUserDefaults.h"

@implementation CPUserDefaults
+ (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if ([key isEqualToString:CPDelta_T_Key]) {
            continue;
        }
        if ([key isEqualToString:CPLastSendSMSTimeIntervalKey]) {
            continue;
        }
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}
@end
