//
//  CPTraceListViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-11-30.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPTraceListViewController.h"
#import "CPTrace.h"
#import <MBProgressHUD.h>

static char CPAssociatedKeyTrace;

@interface CPTraceListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) NSMutableArray* traceArray;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
// 应该位于中心的 trace
@property (nonatomic) CPTrace* centerTrace;
@end

@implementation CPTraceListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPTrace class]) object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        // 启动进度条
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            // 加载数据
            [self loadTrace];
            [self sortTracesByDate];
        } completionBlock:^{
            // 重载table
            [self.tableView reloadData];
            if (self.centerTrace) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.traceArray indexOfObject:self.centerTrace] inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                self.centerTrace = nil;
            }
            // hud消失
            [hud removeFromSuperview];
        }];
        self.dirty = NO;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_trace_2_read"])
    {
        UITableView* tb = sender;
        // 获取点击的追踪
        CPTrace* trace = self.traceArray[[tb indexPathForSelectedRow].row];
        id controller = segue.destinationViewController;
        [controller setValue:trace.cp_uuid forKey:@"traceUUID"];
    }
    if ([segue.identifier isEqualToString:@"cp_segue_trace_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    }
}
#pragma mark - Notification
//- (void) addTraceWithNotification:(NSNotification*) notification{
//    CPLogInfo(@"%@,收到通知,添加追踪",self);
//    CPTrace* newTrace = [notification object];
//    if ([self.contactsUUID isEqualToString:newTrace.cp_contact_uuid]) {
//        [self.traceArray addObject:newTrace];
//        [self sortTracesByDate];
//        [self.tableView reloadData];
//        self.centerIndexPath = [NSIndexPath indexPathForRow:[self.traceArray indexOfObject:newTrace] inSection:0];
//    }
//}
//- (void) deleteTraceWithNotification:(NSNotification*) notification{
//    CPLogInfo(@"%@,收到通知,删除追踪",self);
//    CPTrace* trace = [notification object];
//    if ([self.traceArray containsObject:trace]) {
//        // 计算IndexPath
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.traceArray indexOfObject:trace] inSection:0];
//        // 内存操作
//        [self.traceArray removeObject:trace];
//        [self sortTracesByDate];
//        // 更新UI
//        if (self.isViewLoaded && self.view.window && indexPath) {
//            // 用户可见,加动画
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        } else{
//            [self.tableView reloadData];
//        }
//    }
//}
//- (void) updateTraceWithNotification:(NSNotification*) notification{
//    CPTrace* newTrace = [notification object];
//    if ([self.contactsUUID isEqualToString:newTrace.cp_contact_uuid]) {
//        CPLogInfo(@"%@,收到通知,更新追踪",self);
//        // 普通table
//        [self.traceArray removeObject:newTrace];
//        [self.traceArray addObject:newTrace];
//        [self sortTracesByDate];
//        // 重载table
//        [self.tableView reloadData];
//    }
//}
- (void) receiveNotification:(NSNotification*) notification{
//    switch ([notification.userInfo[CP_ENTITY_OPERATION_KEY] integerValue]) {
//        case CP_ENTITY_OPERATION_ADD:{
//            [self addTraceWithNotification:notification];
//            break;
//        }
//        case CP_ENTITY_OPERATION_DELETE:{
//            [self deleteTraceWithNotification:notification];
//            break;
//        }
//        case CP_ENTITY_OPERATION_UPDATE:{
//            [self updateTraceWithNotification:notification];
//            break;
//        }
//        default:
//            break;
//    }
    self.dirty = YES;
    if ([[notification object] isKindOfClass:[CPTrace class]]) {
        if ([notification.userInfo[CP_ENTITY_OPERATION_KEY] integerValue]==CP_ENTITY_OPERATION_ADD) {
            CPLogInfo(@"%@,收到通知,添加追踪,设置需要显示在中心的追踪",self);
            CPTrace* trace = [notification object];
            self.centerTrace = trace;
        }
    }
}
#pragma mark - private
-(void) loadTrace{
    if (self.contactsUUID) {
        self.traceArray = [[CPDB getLKDBHelperByUser] search:[CPTrace class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil offset:0 count:-1];
    }
}
-(void) sortTracesByDate{
    self.traceArray = [NSMutableArray arrayWithArray:[self.traceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CPTrace* trace1 = obj1;
        CPTrace* trace2 = obj2;
        if (trace1.cp_date == nil && trace2.cp_date == nil) {
            return NSOrderedSame;
        }
        if (trace1.cp_date == nil && trace2.cp_date != nil) {
            return NSOrderedDescending;
        }
        if (trace1.cp_date != nil && trace2.cp_date == nil) {
            return NSOrderedAscending;
        }
        return -[trace1.cp_date compare:trace2.cp_date];
    }]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.traceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell_trace";
    
    static NSInteger const CP_TRACE_CELL_SUB_TAG_1 = 10001;
    static NSInteger const CP_TRACE_CELL_SUB_TAG_2 = 10002;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    CPTrace* trace = self.traceArray[indexPath.row];
    
    static NSDateFormatter* CP_DF_Trace = nil;
    if (!CP_DF_Trace) {
        CP_DF_Trace = [[NSDateFormatter alloc] init];
        [CP_DF_Trace setDateFormat:@"yyyy-MM-dd"];
    }
    if (trace.cp_date) {
        [(UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_1] setText:[CP_DF_Trace stringFromDate:[NSDate dateWithTimeIntervalSince1970:trace.cp_date.doubleValue]]];
    }else{
        [(UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_1] setText:@""];
    }
    if (trace.cp_description) {
        [(UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_2] setText:trace.cp_description];
    }else{
        [(UILabel*)[cell viewWithTag:CP_TRACE_CELL_SUB_TAG_2] setText:@""];
    }
    return cell;
}
// 删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"确认删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        CPTrace* traceToDelete = self.traceArray[indexPath.row];
        objc_setAssociatedObject(alert, &CPAssociatedKeyTrace, traceToDelete, OBJC_ASSOCIATION_RETAIN);
        [alert show];
    }
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"cp_segue_trace_2_read" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        CPTrace* trace = objc_getAssociatedObject(alertView,&CPAssociatedKeyTrace);
        // 数据库操作
        BOOL success = [[CPDB getLKDBHelperByUser] deleteToDB:trace];
        if (!success) {
            CPLogError(@"删除追踪失败:%@",trace);
            return;
        }
        CPLogInfo(@"%@,删除追踪,更新UI",self);
        if ([self.traceArray containsObject:trace]) {
            // 计算IndexPath
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.traceArray indexOfObject:trace] inSection:0];
            // 内存操作
            [self.traceArray removeObject:trace];
            [self sortTracesByDate];
            // 更新UI
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        // 同步
        [CPServer sync];
    }
}
@end
