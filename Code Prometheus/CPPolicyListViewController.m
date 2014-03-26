//
//  CPPolicyListViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPPolicyListViewController.h"
#import "CPPolicy.h"
#import <MBProgressHUD.h>

static char CPAssociatedKeyPolicy;

@interface CPPolicyListViewController ()
@property(nonatomic) NSMutableArray* policyArray;
// 日期格式化
@property (nonatomic)NSDateFormatter* df;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
// 应该位于中心的 policy
@property (nonatomic) CPPolicy* centerPolicy;
@end

@implementation CPPolicyListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NSStringFromClass([CPPolicy class]) object:nil];
    // 日期格式化
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"yy-MM-dd"];
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
            [self loadPolicy];
        } completionBlock:^{
            // 重载table
            [self.tableView reloadData];
            if (self.centerPolicy) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.policyArray indexOfObject:self.centerPolicy] inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                self.centerPolicy = nil;
            }
            // hud消失
            [hud removeFromSuperview];
        }];
        self.dirty = NO;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cp_segue_policy_2_read"])
    {
        NSIndexPath* indexpath = [self.tableView indexPathForCell:sender];
        // 获取点击的保单
        CPPolicy* polic = self.policyArray[indexpath.row];
        id controller = segue.destinationViewController;
        [controller setValue:polic.cp_uuid forKey:@"policyUUID"];
    }
    if ([segue.identifier isEqualToString:@"cp_segue_policy_2_edit"])
    {
        id controller = segue.destinationViewController;
        [controller setValue:self.contactsUUID forKey:@"contactsUUID"];
    }
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.policyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_policy";
    
    static NSInteger const CP_POLICY_CELL_SUB_TAG_1 = 10001;
    static NSInteger const CP_POLICY_CELL_SUB_TAG_2 = 10002;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    CPPolicy* policy = self.policyArray[indexPath.row];
    if (policy.cp_date_begin) {
        [(UILabel*)[cell viewWithTag:CP_POLICY_CELL_SUB_TAG_1] setText:[self.df stringFromDate:[NSDate dateWithTimeIntervalSince1970:policy.cp_date_begin.doubleValue]]];
    }else{
        [(UILabel*)[cell viewWithTag:CP_POLICY_CELL_SUB_TAG_1] setText:@""];
    }
    if (policy.cp_name) {
        [(UILabel*)[cell viewWithTag:CP_POLICY_CELL_SUB_TAG_2] setText:policy.cp_name];
    }else{
        [(UILabel*)[cell viewWithTag:CP_POLICY_CELL_SUB_TAG_2] setText:@""];
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
        CPPolicy* policy = self.policyArray[indexPath.row];
        objc_setAssociatedObject(alert, &CPAssociatedKeyPolicy, policy, OBJC_ASSOCIATION_RETAIN);
        [alert show];
    }
}
#pragma mark - Notification
//- (void) addPolicyWithNotification:(NSNotification*) notification{
//    CPLogInfo(@"%@,收到通知,添加保单",self);
//    CPPolicy* policy = [notification object];
//    if ([self.contactsUUID isEqualToString:policy.cp_contact_uuid]) {
//        [self.policyArray addObject:policy];
//        [self.tableView reloadData];
//        self.centerIndexPath = [NSIndexPath indexPathForRow:[self.policyArray indexOfObject:policy] inSection:0];
//    }
//}
//- (void) deletePolicyWithNotification:(NSNotification*) notification{
//    CPLogInfo(@"%@,收到通知,删除保单",self);
//    CPPolicy* policy = [notification object];
//    if ([self.policyArray containsObject:policy]) {
//        // 计算IndexPath
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.policyArray indexOfObject:policy] inSection:0];
//        // 内存操作
//        [self.policyArray removeObject:policy];
//        // 更新UI
//        if (self.isViewLoaded && self.view.window && indexPath) {
//            // 用户可见,加动画
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        } else{
//            [self.tableView reloadData];
//        }
//    }
//}
//- (void) updatePolicyWithNotification:(NSNotification*) notification{
//    CPPolicy* policy = [notification object];
//    if ([self.contactsUUID isEqualToString:policy.cp_contact_uuid]) {
//        CPLogInfo(@"%@,收到通知,更新保单",self);
//        // 普通table
//        [self.policyArray removeObject:policy];
//        [self.policyArray addObject:policy];
//        // 重载table
//        [self.tableView reloadData];
//    }
//}
- (void) receiveNotification:(NSNotification*) notification{
//    switch ([notification.userInfo[CP_ENTITY_OPERATION_KEY] integerValue]) {
//        case CP_ENTITY_OPERATION_ADD:{
//            [self addPolicyWithNotification:notification];
//            break;
//        }
//        case CP_ENTITY_OPERATION_DELETE:{
//            [self deletePolicyWithNotification:notification];
//            break;
//        }
//        case CP_ENTITY_OPERATION_UPDATE:{
//            [self updatePolicyWithNotification:notification];
//            break;
//        }
//        default:
//            break;
//    }
    self.dirty = YES;
    if ([[notification object] isKindOfClass:[CPPolicy class]]) {
        if ([notification.userInfo[CP_ENTITY_OPERATION_KEY] integerValue]==CP_ENTITY_OPERATION_ADD) {
            CPLogInfo(@"%@,收到通知,添加保单,设置需要显示在中心的保单",self);
            CPPolicy* policy = [notification object];
            self.centerPolicy = policy;
        }
    }
}
#pragma mark - private
-(void) loadPolicy{
    if (self.contactsUUID) {
        self.policyArray = [[CPDB getLKDBHelperByUser] search:[CPPolicy class] where:@{@"cp_contact_uuid":self.contactsUUID} orderBy:nil offset:0 count:-1];
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        CPPolicy* policy = objc_getAssociatedObject(alertView,&CPAssociatedKeyPolicy);
        // 数据库操作
        BOOL success = [[CPDB getLKDBHelperByUser] deleteToDB:policy];
        if (!success) {
            CPLogError(@"删除保单失败:%@",policy);
            return;
        }
        CPLogInfo(@"%@,删除保单,更新UI",self);
        if ([self.policyArray containsObject:policy]) {
            // 计算IndexPath
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.policyArray indexOfObject:policy] inSection:0];
            // 内存操作
            [self.policyArray removeObject:policy];
            // 更新UI
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        // 同步
        [CPServer sync];
    }
}
@end
