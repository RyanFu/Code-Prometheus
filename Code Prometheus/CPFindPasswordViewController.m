//
//  CPFindPasswordViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-20.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFindPasswordViewController.h"
#import "CPFindPasswordByPhoneNumberViewController.h"
#import "CPFindPasswordByEmailViewController.h"

@interface CPFindPasswordViewController ()

@end

@implementation CPFindPasswordViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"找回您的密码";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back:)];
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)findPasswordByPhoneNumber:(id)sender {
    CPFindPasswordByPhoneNumberViewController* controller = [[CPFindPasswordByPhoneNumberViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)findPasswordByEmail:(id)sender {
    CPFindPasswordByEmailViewController* controller = [[CPFindPasswordByEmailViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
