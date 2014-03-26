//
//  UITableView+IndexPath.h
//  Code Prometheus
//
//  Created by mirror on 13-10-14.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (IndexPath)
// 根据事件源获取所在table的IndexPath
-(NSIndexPath*) indexPathForSender:(id) sender;
@end
