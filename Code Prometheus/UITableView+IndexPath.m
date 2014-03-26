//
//  UITableView+IndexPath.m
//  Code Prometheus
//
//  Created by mirror on 13-10-14.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "UITableView+IndexPath.h"

@implementation UITableView (IndexPath)
-(NSIndexPath*) indexPathForSender:(id) sender{
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:senderPosition];
    return indexPath;
}
@end
