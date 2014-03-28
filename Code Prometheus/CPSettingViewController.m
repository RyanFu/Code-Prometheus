//
//  CPSettingViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-17.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPSettingViewController.h"
#import <TDBadgedCell.h>
#import <AddressBook.h>
#import "CPContacts.h"
#import <TWMessageBarManager.h>
#import <MBProgressHUD.h>
#import "CPSyncSettingViewController.h"
#import "CPNavigationController.h"
#import "CPAccountRechargeViewController.h"
#import "CPAboutUsViewController.h"

@interface CPSettingViewController ()
@property (weak, nonatomic) IBOutlet TDBadgedCell *systemMessageCell;

@end

@implementation CPSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.systemMessageCell.badgeString = @"99";
//    self.systemMessageCell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
//    
//    self.systemMessageCell.badge.fontSize = 16;
//    //    self.systemMessageCell.badgeLeftOffset = 8;
//    self.systemMessageCell.badgeRightOffset = 160;
//    self.systemMessageCell.badge.radius = 5;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消现有提示
    [[TWMessageBarManager sharedInstance] hideAll];
    if (indexPath.row == 2) {
        if (CPUserName) {
            UIStoryboard *accountRechargeStoryboard = [UIStoryboard storyboardWithName:@"CPAccountRechargeViewController" bundle:nil];
            CPAccountRechargeViewController* controller = [accountRechargeStoryboard instantiateViewControllerWithIdentifier:@"CPAccountRechargeViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:@"请先登录"
                                                                  type:TWMessageBarMessageTypeInfo];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    if (indexPath.row == 3) {
        // 启动进度条
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.removeFromSuperViewOnHide = YES;
        [self.view addSubview:hud];
        [hud show:YES];
        [self addContactsFromAddressBookWithCompleteBlock:^(BOOL success, NSInteger count) {
            if (success) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                               description:[NSString stringWithFormat:@"导入%d条通讯录",count]
                                                                      type:TWMessageBarMessageTypeSuccess];
                // 同步
                [CPServer sync];
            }else{
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                               description:@"导入通讯录失败,请查看权限设置"
                                                                      type:TWMessageBarMessageTypeError];
            }
            [hud hide:YES];
        } progressBlock:^(NSInteger total, NSInteger done) {
            hud.progress = ((double)done)/((double)total);
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.row == 4) {
        CPSyncSettingViewController* controller = [[CPSyncSettingViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (indexPath.row == 5) {
        UIStoryboard *accountRechargeStoryboard = [UIStoryboard storyboardWithName:@"CPAboutUsViewController" bundle:nil];
        CPAboutUsViewController* controller = [accountRechargeStoryboard instantiateViewControllerWithIdentifier:@"CPAboutUsViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void) addContactsFromAddressBookWithCompleteBlock:(void (^)(BOOL success,NSInteger count))completeBlock progressBlock:(void (^)(NSInteger total,NSInteger done))progressBlock{
    static RHAddressBook *pab = nil;
    if (!pab) {
        pab = [[RHAddressBook alloc] init];
    }
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined) {
        CPLogWarn(@"未获取到读取通讯录权限");
        CPLogInfo(@"开始请求权限");
        [pab requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
            if (granted) {
                CPLogInfo(@"请求读取通讯录权限成功");
                [self addContactsFromAddressBookWithCompleteBlock:completeBlock progressBlock:progressBlock];
            }else{
                CPLogWarn(@"拒绝读取通讯录,不能导入通讯录人脉 error:%@",error);
                completeBlock(NO,0);
            }
        }];
        return;
    }
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusDenied) {
        CPLogWarn(@"拒绝访问通讯录");
//        [self bk_performBlock:^(id obj) {
//            completeBlock(NO,0);
//        } afterDelay:0];
        double delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (completeBlock) {
                completeBlock(NO,0);
            }
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CPLogInfo(@"开始导入通讯录");
        NSArray *people = [pab people];
        NSUInteger total = 0;
        NSUInteger done = 0;
        for (RHPerson* person in people) {
            // 进度
            done++;
            progressBlock(people.count,done);
            // 检查姓名是否为nil或空
            if (!person.name || [person.name isEqualToString:@""]) {
                continue;
            }
            // 检查是否存在于数据库
            __block BOOL hasPerson = NO;
            [[CPDB getLKDBHelperByUser] executeDB:^(FMDatabase *db) {
                FMResultSet* set = [db executeQuery:@"SELECT count(*) FROM cp_contacts WHERE cp_name=?" withArgumentsInArray:@[person.name]];
                while ([set next]) {
                    NSString* sqlValue = [set stringForColumnIndex:0];
                    NSInteger count = sqlValue.integerValue;
                    if (count>0) {
                        hasPerson = YES;
                    }
                }
                [set close];
            }];
            if (!hasPerson) {
                // 添加
                CPContacts* contacts = [CPContacts newAdaptDB];
                contacts.cp_name = person.name;
                NSMutableString* phoneNumbers = [NSMutableString string];
                for (NSString* number in person.phoneNumbers.values) {
                    [phoneNumbers appendFormat:@"%@ ",number];
                }
                if (phoneNumbers.length>0) {
                    NSRange r;
                    r.location = phoneNumbers.length-1;
                    r.length = 1;
                    [phoneNumbers deleteCharactersInRange:r];
                }
                contacts.cp_phone_number = phoneNumbers;
                [[CPDB getLKDBHelperByUser] insertToDB:contacts];
                total++;
            }
        }
        CPLogInfo(@"导入通讯录完成,导入 %d 条记录",total);
//        [self bk_performBlock:^(id obj) {
//            completeBlock(YES,total);
//        } afterDelay:0];
        double delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (completeBlock) {
                completeBlock(YES,total);
            }
        });
    });
}
@end
