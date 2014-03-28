//
//  CPDebugViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-19.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPDebugViewController.h"
#import <MessageUI/MessageUI.h>
#import "ASIHTTPRequest.h"

@interface CPDebugViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation CPDebugViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            [self sendMailInApp];
            break;
        }
        case 1:{
            [self cleanLog];
            break;
        }
        case 2:{
            [self doSync:nil];
            break;
        }
        case 3:{
            [self cleanSession:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - private

-(void) alertWithMessage:(NSString*)message{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"发送日志" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - 清除日志

-(void) cleanLog{
    [[CPLog sharedLog] cleanLog];
}

#pragma mark - 发送日志
//激活邮件功能
- (void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能"];
        return;
    }
    if (![mailClass canSendMail]) {
        [self alertWithMessage:@"没有设置邮件账户"];
        return;
    }
    [self displayMailPicker];
}

// 手动同步
- (void)doSync:(id)sender {
    CPLogInfo(@"手动同步");
    [CPServer sync];
}

// 清除session
- (void)cleanSession:(id)sender {
    CPLogInfo(@"清除session");
    [ASIHTTPRequest clearSession];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    //设置主题
    [mailPicker setSubject: @"保险助手,日志"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: CP_LOG_EMAIL_TO];
    [mailPicker setToRecipients: toRecipients];
    
    //添加抄送
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    [mailPicker setCcRecipients:ccRecipients];
    
    //添加密送
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
//    [mailPicker setBccRecipients:bccRecipients];
    
    // 添加附件
    NSArray* FileInfos = [[CPLog sharedLog] logFileInfos];
    for (DDLogFileInfo *fileInfo in FileInfos) {
        NSData* data = [NSData dataWithContentsOfFile:fileInfo.filePath];
        [mailPicker addAttachmentData:data mimeType:@"text/plain" fileName:fileInfo.fileName];
    }
    NSString *emailBody = @"<font color='red'>牛B的氩哥,请查收日志哦~</font>";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:^{
    }];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *msg = nil;
        switch (result) {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultSaved:
                break;
            case MFMailComposeResultSent:
                msg = @"成功";
                break;
            case MFMailComposeResultFailed:
                msg = @"失败";
                break;
            default:
                break;
        }
        if (msg) {
            [self alertWithMessage:msg];
        }
    }];
    
//    NSString *msg = nil;
//    switch (result) {
//            case MFMailComposeResultCancelled:
//            break;
//            case MFMailComposeResultSaved:
//            break;
//            case MFMailComposeResultSent:
//            msg = @"成功";
//            break;
//            case MFMailComposeResultFailed:
//            msg = @"失败";
//            break;
//        default:
//            break;
//    }
//    if (msg) {
//        [self alertWithMessage:msg];
//    }
}
@end
