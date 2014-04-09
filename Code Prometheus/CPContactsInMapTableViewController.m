//
//  CPContactsInMapTableViewController.m
//  Code Prometheus
//
//  Created by 管理员 on 14-4-9.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "CPContactsInMapTableViewController.h"
#import "CPCusAnnotationView.h"
#import "CPContactsDetailViewController.h"

@interface CPContactsInMapTableViewController ()

@end

@implementation CPContactsInMapTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 去重复
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (CPPointAnnotation* annotation in self.annotationArray) {
        [dict setObject:annotation forKey:annotation.uuid];
    }
    self.annotationArray = [[dict allValues] mutableCopy];
    // UI
    self.navigationItem.title = @"客户列表";
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.annotationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_contacts";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CPPointAnnotation* annotation = self.annotationArray[indexPath.row];
    cell.textLabel.text = annotation.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CPPointAnnotation* annotation = self.annotationArray[indexPath.row];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CPContactsDetailViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"CPContactsDetailViewController"];
    controller.contactsUUID = annotation.uuid;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
