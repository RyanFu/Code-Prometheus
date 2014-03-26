//
//  CPPushNoAnimation.m
//  Code Prometheus
//
//  Created by mirror on 13-11-29.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPushNoAnimation.h"

@implementation CPPushNoAnimation
- (void)perform{
    [[[self sourceViewController] navigationController] pushViewController:[self    destinationViewController] animated:NO];
}
@end
