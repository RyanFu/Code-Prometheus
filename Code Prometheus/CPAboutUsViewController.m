//
//  CPAboutUsViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-31.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPAboutUsViewController.h"
#import "CPFeedbackViewController.h"

@interface CPAboutUsViewController ()

@end

@implementation CPAboutUsViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"关于我们";
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            
            break;
        }
        case 1:{
            
            break;
        }
        case 2:{
            // 意见反馈
            CPFeedbackViewController* controller = [[CPFeedbackViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 3:{
            
            break;
        }
        default:
            break;
    }
}
@end
