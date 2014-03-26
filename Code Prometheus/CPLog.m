//
//  CPLog.m
//  Code Prometheus
//
//  Created by mirror on 13-9-26.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPLog.h"
#import <MessageUI/MessageUI.h>
#import <KSCrash.h>
#import <KSCrashInstallationEmail.h>


@interface CPLog ()
@property (nonatomic,weak) DDFileLogger* fileLogger;
@end

@implementation CPLog
+ (instancetype)sharedLog {
    static CPLog *singleton;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}
-(void) prepareLog{
    // 控制台
    [DDLog addLogger:[DDTTYLogger sharedInstance]withLogLevel:LOG_LEVEL_VERBOSE];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    // 文件
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger = fileLogger;
    fileLogger.rollingFrequency = DEFAULT_LOG_ROLLING_FREQUENCY;
    fileLogger.logFileManager.maximumNumberOfLogFiles = DEFAULT_LOG_MAX_NUM_LOG_FILES;
    [DDLog addLogger:fileLogger withLogLevel:LOG_LEVEL_VERBOSE];
    
    // 崩溃日志
    [self installCrashHandler];
}
- (NSArray *)logFileInfos
{
//    NSUInteger maximumLogFilesToReturn = MIN(self.fileLogger.logFileManager.maximumNumberOfLogFiles, 10);
//    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
//    DDFileLogger *logger = self.fileLogger;
//    NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
//    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
//        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
//        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
//        [errorLogFiles addObject:fileData];
//    }
//    return errorLogFiles;
    return [self.fileLogger.logFileManager sortedLogFileInfos];
}
#warning 清空日志待实现
- (void) cleanLog{
//    DDFileLogger *logger = self.fileLogger;
//    NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
//    for (int i = 0; i < sortedLogFileInfos.count; i++) {
//        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
//        
//        NSLog(@"path %@",logFileInfo.filePath);
//        NSLog(@"name %@",logFileInfo.fileName);
//    }
    
    
    
    
//        DDFileLogger *logger = self.fileLogger;
//        
//        NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
//    
//        
//        NSUInteger count = [sortedLogFileInfos count];
//        BOOL excludeFirstFile = NO;
//        
//        if (count > 0)
//        {
//            DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:0];
//            
//            if (!logFileInfo.isArchived)
//            {
//                excludeFirstFile = YES;
//            }
//        }
//        
//        NSArray *sortedArchivedLogFileInfos;
//        if (excludeFirstFile)
//        {
//            count--;
//            sortedArchivedLogFileInfos = [sortedLogFileInfos subarrayWithRange:NSMakeRange(1, count)];
//        }
//        else
//        {
//            sortedArchivedLogFileInfos = sortedLogFileInfos;
//        }
//        
//        NSUInteger i;
//        for (i = maxNumLogFiles; i < count; i++)
//        {
//            DDLogFileInfo *logFileInfo = [sortedArchivedLogFileInfos objectAtIndex:i];
//            
//            NSLogInfo(@"DDLogFileManagerDefault: Deleting file: %@", logFileInfo.fileName);
//            
//            [[NSFileManager defaultManager] removeItemAtPath:logFileInfo.filePath error:nil];
//        }
    
    
    CPLogWarn(@"清空日志,此功能未实现");
}



#pragma mark - crash 日志
- (void) installCrashHandler
{
    KSCrashInstallation* installation = [self makeEmailInstallation];
    [installation install];
    [KSCrash sharedInstance].deleteBehaviorAfterSendAll = KSCDeleteAlways;
    [installation sendAllReportsWithCompletion:^(NSArray* reports, BOOL completed, NSError* error)
     {
         if(completed)
         {
             NSLog(@"Sent %d reports", (int)[reports count]);
         }
         else
         {
             NSLog(@"Failed to send reports: %@", error);
         }
     }];
}
- (KSCrashInstallation*) makeEmailInstallation
{
    KSCrashInstallationEmail* email = [KSCrashInstallationEmail sharedInstance];
    email.recipients = @[CP_LOG_EMAIL_TO];
    email.subject = @"崩溃日志";
    email.message = [NSString stringWithFormat:@"用户:%@",CPUserName];
    email.filenameFmt = @"crash-report-%d.txt";
    
    [email addConditionalAlertWithTitle:@"帮助我们"
                                message:@"检测到上次您的程序发生崩溃,请帮助我们完善系统,点击确定发送Email给我们"
                              yesAnswer:@"帮帮他"
                               noAnswer:@"不理他"];
    [email setReportStyle:KSCrashEmailReportStyleApple useDefaultFilenameFormat:YES];
    return email;
}
@end
