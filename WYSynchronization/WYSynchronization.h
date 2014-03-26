//
//  WYSynchronization.h
//  Code Prometheus
//
//  Created by mirror on 13-9-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYDatabaseOperation.h"


@class LKDBHelper;
// 同步失败原因
typedef enum{
    // 无错误
     SynchronizationFailedTypeNone,
    // 无网络
    SynchronizationFailedTypeNoNetwork,
    // 数据库异常
    SynchronizationFailedTypeDatabaseError,
    // 请求超时
    SynchronizationFailedTypeTimeOut,
    // http请求异常
    SynchronizationFailedTypeRequestError,
    // 服务器返回标记为失败
    SynchronizationFailedTypeServerFailed,
}SynchronizationFailedType;
// 
NSString* nameFromSynchronizationFailedType(SynchronizationFailedType type);


// 同步类型
typedef enum{
    SynchronizationTypeS2CForDatabase = 1,
    SynchronizationTypeC2SForDatabase = 2,
}SynchronizationType;
NSString* nameFromSynchronizationType(SynchronizationType type);


@class WYSynchronization;
@protocol WYSynchronizationDelegate <NSObject>

// S 2 C
// s2c的请求参数
-(NSString*) s2cRequestJsonWithSynchronization:(WYSynchronization*)wySynchronization;
// 接受服务器返回值,返回是否请求同步成功
-(BOOL) s2cIsSuccessWhenRequestFinishWithSynchronization:(WYSynchronization*)wySynchronization Json:(NSDictionary*)responce;
// json字典转操作对象
-(NSArray*) s2cOperationsWithSynchronization:(WYSynchronization*)wySynchronization Json:(NSDictionary*)json;
// 通过操作队列，更新数据库前
-(void) s2cWillUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations;
// 通过操作队列，更新数据库后
-(void) s2cDidUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations;
@optional
// 执行某个操作前
-(void) s2cWillUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operation:(WYDatabaseOperation*)operation;
// 执行某个操作后
-(void) s2cDidUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operation:(WYDatabaseOperation*)operation;


// C 2 S
// 获取同步的json
-(NSString*) c2sRequestJsonWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations;
// 接受服务器返回值,返回是否同步成功
-(BOOL) c2sIsSuccessWhenRequestFinishWithSynchronization:(WYSynchronization*)wySynchronization Json:(NSDictionary*)responce;
// 获取需要上传的操作队列的条件
-(void) c2sDatabaseOperationWhereDBName:(NSArray**)dbName table:(NSArray**)tableName uuid:(NSArray**)uuid;



// 同步失败
-(void) synchronizationFailed:(WYSynchronization*)wySynchronization;

// 同步成功
-(void) synchronizationFinished:(WYSynchronization*)wySynchronization;

// 开始同步前
-(void) beforeSynchronization:(WYSynchronization*)wySynchronization;

@end



@interface WYSynchronization : NSOperation

// 同步url
@property (nonatomic,strong) NSURL* synchronizationUrl;
// 请求方式：GET,POST,PUT,DELETE
@property (nonatomic,copy) NSString* requestMethod;

// 失败类型
@property (nonatomic,readonly) SynchronizationFailedType synchronizationFailedType;
// 同步类型
@property (nonatomic) SynchronizationType synchronizationType;
// 标记
@property (nonatomic) id tag;

// 请求的json
@property (nonatomic,readonly) NSString* requestJson;

// 响应的json
@property (nonatomic,readonly) NSMutableDictionary* responseJson;

// c2s同步粒度，当客户端向服务器同步数据时，每次http请求发送的操作队列数量 -1代表同步所有  Default=-1
@property (nonatomic) NSInteger particle;


// 构造方法
- (id)initWithDelegate:(id<WYSynchronizationDelegate>)delegate;
+(id)synchronizationWithDelegate:(id<WYSynchronizationDelegate>)delegate;


// 进行同步
-(BOOL) startSynchronization;
// 取消同步
-(void) cancelSynchronization;

+(LKDBHelper*) getLKDBHelperForSync;

// 操作队列所在数据库名,使用同步框架前必须设置
+(void) setSyncDBNameAndCreat:(NSString*)name;

// 获取操作队列条数，应在非ui线程下执行
+(NSInteger) countForOperationWithDbName:(NSArray*)dbNames tbNames:(NSArray*)tbNames uuids:(NSArray*)uuids;

// 生成新增或更新 操作队列
+(void) notifyReplaceEntity:(NSObject *)entity;
// 生成删除 操作队列
+(void) notifyDeleteEntity:(NSObject *)entity;
//// 生成操作队列
//+(void) notifyCreatOperation:(SynchronizationOperation)op dbName:(NSString *)dbName tbName:(NSString*)tbName timestamp:(NSTimeInterval)timestamp uuid:(NSString*)uuid primaryKey:(NSString*)key data:(NSString*)data;

+(void) replaceSyncOperation:(WYDatabaseOperation*)op;

@end
