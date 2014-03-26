//
//  CPConsumptionLogViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-30.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPConsumptionLogViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>

@interface CPOrderInfo : NSObject
@property(nonatomic) NSNumber* price;
@property(nonatomic) NSString* updateDate;
@end
@implementation CPOrderInfo
@end

@interface CPConsumptionLogViewController ()
// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@property (nonatomic) NSArray* orderInfoArray;
@end

@implementation CPConsumptionLogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self requestConsumptionLog];
        self.dirty = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"orderInfo";
    static NSInteger const viewTag1 = 10001;
    static NSInteger const viewTag2 = 10002;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CPOrderInfo* orderInfo = self.orderInfoArray[indexPath.row];
    UILabel* priceLabel = (UILabel*)[cell viewWithTag:viewTag1];
    priceLabel.text = [NSString stringWithFormat:@"%d豆",[orderInfo.price integerValue]/100];
    UILabel* updateDateLabel = (UILabel*)[cell viewWithTag:viewTag2];
    updateDateLabel.text = orderInfo.updateDate;
    return cell;
}

#pragma mark - private
-(void) requestConsumptionLog{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    [CPServer requestOrderInfo:^(BOOL success, NSString *message, NSMutableArray *results) {
        if (success) {
            NSMutableArray* orderInfos = [NSMutableArray array];
            for (NSDictionary* dic in results) {
                CPOrderInfo* orderInfo = [CPOrderInfo new];
                orderInfo.price = [dic objectForKey:@"price"];
                orderInfo.updateDate = [dic objectForKey:@"updateDate"];
                [orderInfos addObject:orderInfo];
            }
            self.orderInfoArray = [NSArray arrayWithArray:orderInfos];
            [self.tableView reloadData];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
        }
        [hud hide:YES];
    }];
}
@end
