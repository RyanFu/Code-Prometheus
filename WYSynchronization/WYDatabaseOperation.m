//
//  WYDatabaseOperation.m
//  Code Prometheus
//
//  Created by mirror on 13-9-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "WYDatabaseOperation.h"
#import "LKDBHelper.h"

@implementation WYDatabaseOperation

//主键
+(NSString *)getPrimaryKey
{
    return @"wy_uuid";
}

//表名
+(NSString *)getTableName
{
    return NSStringFromClass(self);
}
@end


@implementation NSObject (Operation)

+(NSString*) syncOperationDBName{
    return @"";
}
+(NSString*) syncOperationTBName{
    return @"";
}
-(NSString*) syncOperationUUID{
    return @"";
}
-(NSTimeInterval) syncOperationTimestamp{
    return 0.0;
}
+(NSString*) syncOperationPrimaryKey{
    return @"";
}
-(NSString*) syncDataContent{
    return @"";
}
@end