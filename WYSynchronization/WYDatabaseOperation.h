//
//  WYDatabaseOperation.h
//  Code Prometheus
//
//  Created by mirror on 13-9-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

// 操作，1新增或修改，2删除
typedef enum{
    SynchronizationOperationAddOrUpdate = 1,
    SynchronizationOperationDelete = 2,
}SynchronizationOperation;

@class WYDatabaseOperation;
@interface WYDatabaseOperation : NSObject

@property (nonatomic,copy) NSString *wy_uuid;
@property (nonatomic,copy) NSString *wy_dbName;
@property (nonatomic,copy) NSString *wy_tbName;
@property (nonatomic,copy) NSString *wy_primary_key;
@property (nonatomic,copy) NSString *wy_data;
@property (nonatomic) NSTimeInterval wy_timestamp;
@property (nonatomic) SynchronizationOperation wy_operation;

@end

@interface NSObject (Operation)

+(NSString*) syncOperationDBName;
+(NSString*) syncOperationTBName;
-(NSString*) syncOperationUUID;
-(NSTimeInterval) syncOperationTimestamp;
+(NSString*) syncOperationPrimaryKey;
-(NSString*) syncDataContent;
@end
