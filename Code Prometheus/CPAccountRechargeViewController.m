//
//  CPAccountRechargeViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-27.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPAccountRechargeViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>
#import <NSDate-Utilities.h>
#import "CPConsumptionLogViewController.h"
#import "CPRechargeLogViewController.h"
#import "CPMyProductViewController.h"
#import "CPRechargeViewController.h"

@interface CPAccountRechargeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *spaceTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceSurplusLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceRatioLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberTypeDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberType2Label;
@property (weak, nonatomic) IBOutlet UILabel *surplusTimeLabel;

@end

@implementation CPAccountRechargeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"账户充值";
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestMemberInfoAndUpdate];
}

#pragma mark - private

static NSString* const TITLE_NIL = @"-";

-(void) updateUI{
    if (CPMemberRoom) {
        self.spaceTotalLabel.text = [NSString stringWithFormat:@"%@MB",CPMemberRoom];
    }else{
        self.spaceTotalLabel.text = TITLE_NIL;
    }
    if (CPMemberLeftRoom) {
        self.spaceSurplusLabel.text = [NSString stringWithFormat:@"%@MB",CPMemberLeftRoom];
    }else{
        self.spaceSurplusLabel.text = TITLE_NIL;
    }
    if (CPMemberUsePercent) {
        self.spaceRatioLabel.text = CPMemberUsePercent;
    }else{
        self.spaceRatioLabel.text = TITLE_NIL;
    }
    if (CPMemberName) {
        self.memberTypeLabel.text = CPMemberName;
    }else{
        self.memberTypeLabel.text = TITLE_NIL;
    }
    if (CPMemberRoom && CPMemberPrice) {
        self.memberTypeDescriptionLabel.text = [NSString stringWithFormat:@"%@MB使用空间 %@豆/月",CPMemberRoom,CPMemberPrice];
    }else{
        self.memberTypeDescriptionLabel.text = TITLE_NIL;
    }
    if (CPMemberBalance) {
        self.balanceLabel.text = [NSString stringWithFormat:@"%@豆",CPMemberBalance];
    }else{
        self.balanceLabel.text = TITLE_NIL;
    }
    if (CPMemberName) {
        self.memberType2Label.text = CPMemberName;
    }else{
        self.memberType2Label.text = TITLE_NIL;
    }
    if (CPMemberBalance && CPMemberPrice) {
        double seconds = [CPMemberBalance doubleValue];
        NSInteger day = seconds / D_DAY;
        NSInteger monthTotal = [CPMemberBalance integerValue]/[CPMemberPrice integerValue];
        NSInteger year = monthTotal / 12;
        NSInteger month = monthTotal - year * 12;
        NSString* text = nil;
        if (year>0) {
            text = [NSString stringWithFormat:@"%d年%d个月%d天",year,month,day];
        }else{
            if (month>0) {
                text = [NSString stringWithFormat:@"%d个月%d天",month,day];
            }else{
                text = [NSString stringWithFormat:@"%d天",day];

            }
        }
        self.surplusTimeLabel.text = text;
    }else{
        self.surplusTimeLabel.text = TITLE_NIL;
    }
}

-(void) requestMemberInfoAndUpdate{
    MBProgressHUD* hud = nil;
    if (!CPMemberName) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.view addSubview:hud];
        [hud show:YES];
    }
    [CPServer requestMemberInfo:^(BOOL success,NSString* message,NSString* name,NSString* productId,NSNumber* price,NSString* room,NSNumber* memberTime,NSNumber* usage,NSString* usePercent,NSNumber* leftRoom,NSNumber* balance) {
        if (success) {
            BOOL needUpdateUI = NO;
            if (!CPMemberName || ![CPMemberName isEqualToString:name]) {
                CPLogInfo(@"更新会员名称:%@->%@",CPMemberName,name);
                CPSetMemberName(name);
                needUpdateUI = YES;
            }
            if (!CPProductId || ![CPProductId isEqualToString:productId]) {
                CPLogInfo(@"更新会员产品ID:%@->%@",CPProductId,productId);
                CPSetProductId(productId);
                needUpdateUI = YES;
            }
            if (!CPMemberPrice || ![CPMemberPrice isEqual:price]) {
                CPLogInfo(@"更新会员消费价格:%@->%@",CPMemberPrice,price);
                CPSetMemberPrice(price);
                needUpdateUI = YES;
            }
            if (!CPMemberRoom || ![CPMemberRoom isEqualToString:room]) {
                CPLogInfo(@"更新会员空间:%@->%@",CPMemberRoom,room);
                CPSetMemberRoom(room);
                needUpdateUI = YES;
            }
            if (!CPMemberTime || ![CPMemberTime isEqual:memberTime]) {
                CPLogInfo(@"更新会员剩余时间:%@->%@",CPMemberTime,memberTime);
                CPSetMemberTime(memberTime);
                needUpdateUI = YES;
            }
            if (!CPMemberUsage || ![CPMemberUsage isEqual:usage]) {
                CPLogInfo(@"更新会员使用的空间:%@->%@",CPMemberUsage,usage);
                CPSetMemberUsage(usage);
                needUpdateUI = YES;
            }
            if (!CPMemberUsePercent || ![CPMemberUsePercent isEqualToString:usePercent]) {
                CPLogInfo(@"更新会员使用空间百分比:%@->%@",CPMemberUsePercent,usePercent);
                CPSetMemberUsePercent(usePercent);
                needUpdateUI = YES;
            }
            if (!CPMemberLeftRoom || ![CPMemberLeftRoom isEqual:leftRoom]) {
                CPLogInfo(@"更新会员剩余空间:%@->%@",CPMemberLeftRoom,leftRoom);
                CPSetMemberLeftRoom(leftRoom);
                needUpdateUI = YES;
            }
            if (!CPMemberBalance || ![CPMemberBalance isEqual:balance]) {
                CPLogInfo(@"更新会员余额(豆):%@->%@",CPMemberBalance,balance);
                CPSetMemberBalance(balance);
                needUpdateUI = YES;
            }
            [self updateUI];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
        }
        if (hud) {
            [hud hide:YES];
        }
    }];
}

#pragma mark - IBAction
- (IBAction)changeMemberType:(id)sender {
    CPMyProductViewController* controller = [[CPMyProductViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)recharge:(id)sender {
    CPRechargeViewController* controller = [[CPRechargeViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma uitable
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 4) {
        UIStoryboard *consumptionLogViewController = [UIStoryboard storyboardWithName:@"CPConsumptionLogViewController" bundle:nil];
        CPConsumptionLogViewController* controller = [consumptionLogViewController instantiateViewControllerWithIdentifier:@"CPConsumptionLogViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (indexPath.row == 5) {
        
    }
    if (indexPath.row == 8) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CPRechargeLogViewController" bundle:nil];
        CPRechargeLogViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"CPRechargeLogViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
