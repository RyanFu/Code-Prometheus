//
//  CPDB.m
//  Code Prometheus
//
//  Created by mirror on 13-10-8.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPDB.h"
#import "CP_DB_Info.h"

#warning 模拟数据
#import "CPContacts.h"
#import "CPTrace.h"
#import "CPPolicy.h"
#import <NSDate-Utilities.h>

@implementation CPDB

#warning 如果用户名为 ___cp_off_line_db ___wy_sync 会出问题\
解决方案是,把同步数据库和离线数据库放在特殊文件夹,和普通用户数据库分离
static LKDBHelper* cpLKDBHelper;
+(LKDBHelper*) getLKDBHelperByUser{
    NSString* userName = CPUserName;
    // 初始化sync 初始化lkdb
    if (!cpLKDBHelper) {
        @synchronized(self){
            if (!cpLKDBHelper) {
                if (userName) {
                    cpLKDBHelper = [[LKDBHelper alloc] initWithDBName:userName];
                }else{
                    cpLKDBHelper = [[LKDBHelper alloc] initWithDBName:(NSString*)OFF_LINE_DB_Name];
                }
                return cpLKDBHelper;
            }
        }
    }
    if (userName) {
        if (![[NSString stringWithFormat:@"%@.db",userName] isEqualToString:[cpLKDBHelper performSelector:@selector(dbname)]]) {
            cpLKDBHelper = [[LKDBHelper alloc] initWithDBName:userName];
        }
    }else{
        if (![[NSString stringWithFormat:@"%@.db",OFF_LINE_DB_Name] isEqualToString:[cpLKDBHelper performSelector:@selector(dbname)]]) {
            cpLKDBHelper = [[LKDBHelper alloc] initWithDBName:(NSString*)OFF_LINE_DB_Name];
        }
    }
    
    return cpLKDBHelper;
}

+(void) creatDB{
    LKDBHelper* dbHelper = [self getLKDBHelperByUser];
    NSArray* sqls = [[NSString stringWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"main.sql"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@";"];
    [dbHelper executeDB:^(FMDatabase *db) {
#warning DO 应该开启事务
//        [db beginTransaction];
        for (NSString* sql in sqls) {
            // 去左右空格
            NSString* sql_norm = [sql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![sql_norm isEqualToString:@""]) {
                [db executeUpdate:sql];
            }
        }
//        [db commit];
    }];
    CPLogWarn(@"读取SQL文件,创建数据表");
    
    // 模拟数据
#warning 可能存在内存泄露
#define ContactsCount 0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CPLogInfo(@"开始输入模拟数据");

        @autoreleasepool {
            int progressLast = -1;
            int (^randomNumber)(int, int) = ^(int from, int to) {
                return (int)(from + (arc4random() % (to - from + 1)));
            };
            
            for (int i=0; i<ContactsCount; i++) {
                int progress = ((double)i)/ContactsCount*100;
                if (progressLast != progress) {
                    CPLogInfo(@"%d%%",progress);
                    progressLast = progress;
                }
                // 人脉
                CPContacts* c = [CPContacts newAdaptDB];
                // 人脉名
                NSMutableString* name = [NSMutableString string];
                int nameSize = randomNumber(1,4);
                for (int j=0; j<nameSize; j++) {
                    int charString = randomNumber(65,90);
                    [name appendFormat:@"%c",randomNumber(0,1)?charString:charString+32];
                }
                c.cp_name = name;
                // 人脉生日
                static NSDateFormatter* df = nil;
                if (!df) {
                    df = [[NSDateFormatter alloc] init];
                    df.dateFormat = @"yyyy-MM-dd";
                }
                if (randomNumber(0,4)==0) {
                    c.cp_birthday = nil;
                }else{
                    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                    int randomDay = randomNumber(0,100*(double)D_YEAR/(double)D_DAY);
                    NSTimeInterval newed = now - randomDay*(double)D_DAY;
                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:newed];
                    c.cp_birthday = [df stringFromDate:date];
                }
                // 人脉电话
                NSMutableString* numbers = [NSMutableString string];
                int count = randomNumber(0,3);
                for (int j=0; j<count; j++) {
                    for (int z=0; z<11; z++) {
                        int number = randomNumber(0,9);
                        [numbers appendFormat:@"%d",number];
                    }
                    [numbers appendString:@" "];
                }
                if (numbers.length>0) {
                    NSRange range;
                    range.location = numbers.length-1;
                    range.length = 1;
                    [numbers deleteCharactersInRange:range];
                }
                if (numbers.length > 0 ) {
                    c.cp_phone_number = numbers;
                }else{
                    if (randomNumber(0,1) == 0) {
                        c.cp_phone_number = numbers;
                    }
                }

                [[CPDB getLKDBHelperByUser] insertToDB:c];
                
                // 追踪
                int traceCount = randomNumber(0,4);
                for (int j=0; j<traceCount; j++) {
                    CPTrace* trace = [CPTrace newAdaptDB];
                    trace.cp_contact_uuid = c.cp_uuid;
                    // 日期
                    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                    trace.cp_date = randomNumber(0,4)==0?[NSNumber numberWithDouble:now+randomNumber(-D_YEAR,D_YEAR)]:nil;
                    // 内容
                    NSMutableString* name = [NSMutableString string];
                    int nameSize = randomNumber(1,100);
                    for (int j=0; j<nameSize; j++) {
                        int charString = randomNumber(65,90);
                        [name appendFormat:@"%c",randomNumber(0,1)?charString:charString+32];
                    }
                    trace.cp_description = name;
                    [[CPDB getLKDBHelperByUser] insertToDB:trace];
                }
                
                // 保单
                int policyCount = randomNumber(0,4);
                for (int j=0; j<policyCount; j++) {
                    CPPolicy* policy = [CPPolicy newAdaptDB];
                    policy.cp_contact_uuid = c.cp_uuid;
                    // 提醒日期
                    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                    policy.cp_remind_date = randomNumber(0,4)==0?[NSNumber numberWithDouble:now+randomNumber(-D_YEAR,D_YEAR)]:nil;
                    // 名称
                    NSMutableString* name = [NSMutableString string];
                    int nameSize = randomNumber(1,10);
                    for (int j=0; j<nameSize; j++) {
                        int charString = randomNumber(65,90);
                        [name appendFormat:@"%c",randomNumber(0,1)?charString:charString+32];
                    }
                    policy.cp_name = name;
                    [[CPDB getLKDBHelperByUser] insertToDB:policy];
                }
                
            }
        }
        CPLogInfo(@"结束输入模拟数据");
    });
    
}
+(void) creatDBIfNotExist{
    NSString* userName = CPUserName;
    if (!userName) {
        userName = (NSString*)OFF_LINE_DB_Name;
    }
    NSString* path = [LKDBUtils getPathForDocuments:userName inDir:@"db"];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@.db",path]];
    if (!exist) {
        CPLogWarn(@"creatDBIfNotExist->数据库不存在,创建数据库:%@",userName);
        [self creatDB];
    }else{
        CPLogInfo(@"creatDBIfNotExist->取消创建,数据库存在,%@",userName);
    }
}
+(void) creatDBFromOFFLineDB{
    CPLogInfo(@"依据离线DB创建用户DB文件");
    NSString* userName = CPUserName;
    if (!userName) {
        CPLogWarn(@"无用户,无法依据离线DB创建用户DB文件");
        return;
    }
    NSString* path = [LKDBUtils getPathForDocuments:(NSString*)OFF_LINE_DB_Name inDir:@"db"];
    path = [NSString stringWithFormat:@"%@.db",path];
    BOOL existOffLineDB = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!existOffLineDB) {
        CPLogWarn(@"无离线数据库,无法依据离线DB创建用户DB文件");
        return;
    }
    NSString* pathNew = [LKDBUtils getPathForDocuments:userName inDir:@"db"];
    pathNew = [NSString stringWithFormat:@"%@.db",pathNew];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathNew]) {
#warning 如果用户数据库存在,应该copy数据到这个库,现在是拒绝copy,直接覆盖\
这句话看不懂了。。。(忽略？)
//        CPLogWarn(@"文件存在:%@,开始删除!",pathNew);
//        BOOL success = [CPFile deleteFileWithPath:pathNew];
//        if (!success) {
//            CPLogWarn(@"文件删除失败,creatDBFromOFFLineDB 失败");
//            return;
//        }
//        CPLogWarn(@"文件删除成功,开始重命名文件");
        CPLogWarn(@"同时存在 离线数据库 和 用户名%@的数据库,异常情况!",userName);
        CPLogWarn(@"删除离线数据库");
        [CPFile deleteFileWithPath:path];
//        CPLogWarn(@"文件存在,无法重命名:from %@ to %@",path,pathNew);
        return;
    }
    // 转换
    NSError * err = NULL;
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL result = [fm moveItemAtPath:path toPath:pathNew error:&err];
    if(!result){
        CPLogError(@"Error: %@", err);
    } else{
        CPLogInfo(@"依据离线DB创建用户DB文件成功");
    }
}
+(void) dropDB{
    CPLogWarn(@"开始清空数据库");
    LKDBHelper* dbHelper = [self getLKDBHelperByUser];
    [dbHelper dropAllTable];
    CPLogWarn(@"完成清空数据库");
}
+(void) deleteDBFile{
    CPLogWarn(@"开始删除数据库");
    LKDBHelper* dbHelper = [self getLKDBHelperByUser];
    [LKDBUtils deleteWithFilepath:[LKDBUtils getPathForDocuments:[dbHelper valueForKey:@"dbname"] inDir:@"db"]];
    CPLogWarn(@"完成删除数据库");
}

//+(NSTimeInterval) guessServerTime{
//    NSString* value = [self getDBInfoWithKey:CP_DB_INFO_DELTA_T Update:NO];
//    return [[NSDate date] timeIntervalSince1970] - [value doubleValue];
//}
//
//#pragma mark - private
//NSMutableArray* cp_db_infos;
//+(NSString*) getDBInfoWithKey:(NSString*)key Update:(BOOL)update{
//    @synchronized(self){
//        if (!cp_db_infos && !update) {
//            cp_db_infos = [[CPDB getLKDBHelperByUser] search:[CP_DB_Info class] where:nil orderBy:nil offset:0 count:-1];
//        }
//    }
//    if (update) {
//        cp_db_infos = [[CPDB getLKDBHelperByUser] search:[CP_DB_Info class] where:nil orderBy:nil offset:0 count:-1];
//    }
//    for (CP_DB_Info* info in cp_db_infos) {
//        if ([info.cp_key isEqualToString:key]) {
//            return info.cp_value;
//        }
//    }
//    return nil;
//}

@end
