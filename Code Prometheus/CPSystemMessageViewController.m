//
//  CPSystemMessageViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-17.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPSystemMessageViewController.h"
#import "CPPushMessage.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>

@interface CPSystemMessageViewController ()
@property (nonatomic) NSMutableArray* pushMessageArray;
@end

@implementation CPSystemMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self loadDB];
    [self requestPushMessage];
}

#pragma mark - private

//-(void) loadDB{
//    self.pushMessageArray = [[CPDB getLKDBHelperByUser] search:[CPPushMessage class] where:nil orderBy:nil offset:0 count:-1];
//    
//    
//    for (int i=0; i<100; i++) {
//        CPPushMessage* pm = [[CPPushMessage alloc] init];
//        pm.cp_timestamp = @([[NSDate date] timeIntervalSince1970]);
//        pm.cp_content = @"dsojfojdfodnodnsfdsf\nddd\ndsdd";
//        [self.pushMessageArray addObject:pm];
//    }
//}

-(void) requestPushMessage{
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    [CPServer pushSearchWithBlock:^(BOOL success, NSMutableArray *results, NSString *message) {
        if (success) {
            self.pushMessageArray = [NSMutableArray array];
            for (NSDictionary* dic in results) {
                CPPushMessage* pushMessage = [CPPushMessage new];
                pushMessage.cp_content = [dic objectForKey:@"message"];
                pushMessage.cp_title = [dic objectForKey:@"title"];
                pushMessage.createTime = [dic objectForKey:@"createTime"];
                [self.pushMessageArray addObject:pushMessage];
            }
            [self.tableView reloadData];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
        }
        [hud hide:YES];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pushMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell_system_message";
    static NSInteger const CP_CELL_SUB_TAG_1 = 10001;
    static NSInteger const CP_CELL_SUB_TAG_2 = 10002;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CPPushMessage* pm = self.pushMessageArray[indexPath.row];
    
    // 内容
    UILabel* pushMessageLabel = (UILabel*)[cell viewWithTag:CP_CELL_SUB_TAG_1];
    pushMessageLabel.text = pm.cp_content;
    
    // 日期
    UILabel* dateLabel = (UILabel*)[cell viewWithTag:CP_CELL_SUB_TAG_2];
//    static NSDateFormatter* df = nil;
//    if (!df) {
//        df = [[NSDateFormatter alloc] init];
//        df.dateFormat = @"yyyy-MM-dd";
//    }
//    dateLabel.text = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:pm.cp_timestamp.doubleValue]];
    dateLabel.text = pm.createTime;
    
//    // 动态高度
//    CGRect cellFrame = [cell frame];
//    [pushMessageLabel sizeToFit];
//    cellFrame.size.height += pushMessageLabel.frame.size.height;
//    [cell setFrame:cellFrame];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *CellIdentifier = @"cell_system_message";
//    static NSInteger const CP_CELL_SUB_TAG_1 = 10001;
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    CPPushMessage* pm = self.pushMessageArray[indexPath.row];
//    
//    UILabel* pushMessageLabel = (UILabel*)[cell viewWithTag:CP_CELL_SUB_TAG_1];
//    pushMessageLabel.text = pm.cp_content;
//    
//    [pushMessageLabel sizeToFit];
//    
//    [cell.contentView setNeedsLayout];
//    [cell.contentView layoutIfNeeded];
//    
//    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    return height;
    
    
    
    CPPushMessage* pm = self.pushMessageArray[indexPath.row];
    
    NSString *text = pm.cp_content;
    UIFont *cellFont = [UIFont systemFontOfSize:17.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize textSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return  tableView.rowHeight + textSize.height;
}

@end
