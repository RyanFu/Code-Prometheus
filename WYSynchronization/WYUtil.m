//
//  WYUtil.m
//  Code Prometheus
//
//  Created by mirror on 13-11-7.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "WYUtil.h"
#import "Reachability.h"
#import "WYConfig.h"

@implementation WYUtil
// 检查网络是否可用，应在非ui线程下运行
+(BOOL) networkIsOk{
    BOOL isExistenceNetwork = NO;
    Reachability *r = [Reachability reachabilityForInternetConnection];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=NO;
            WYLogVerbose(@"%s没有网络",__FUNCTION__);
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=YES;
            WYLogVerbose(@"%s正在使用3G网络",__FUNCTION__);
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=YES;
            WYLogVerbose(@"%s正在使用wifi网络",__FUNCTION__);
            break;
    }
    return isExistenceNetwork;
}
@end
