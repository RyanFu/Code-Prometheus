//
//  WYSynchronization.m
//  Code Prometheus
//
//  Created by mirror on 13-9-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "WYSynchronization.h"
#import "LKDBHelper.h"
#import "JSONKit.h"
#import "WYConfig.h"
#import "ASIHTTPRequest.h"


NSString* nameFromSynchronizationFailedType(SynchronizationFailedType type){
    NSString* name;
    switch (type) {
        case SynchronizationFailedTypeNone:
            name = @"无错误";
            break;
        case SynchronizationFailedTypeNoNetwork:
            name = @"无网络";
            break;
        case SynchronizationFailedTypeDatabaseError:
            name = @"数据库异常";
            break;
        case SynchronizationFailedTypeTimeOut:
            name = @"请求超时";
            break;
        case SynchronizationFailedTypeRequestError:
            name = @"http异常";
            break;
        case SynchronizationFailedTypeServerFailed:
            name = @"服务器返回标记为失败";
            break;
        default:
            name = @"未定义";
            break;
    }
    return name;
}

NSString* nameFromSynchronizationType(SynchronizationType type){
    NSString* name;
    switch (type) {
        case SynchronizationTypeS2CForDatabase:
            name = @"S2C,Download,服务器向客户端同步";
            break;
        case SynchronizationTypeC2SForDatabase:
            name = @"C2S,Upload,客户端向服务器同步";
            break;
        default:
            name = @"未定义";
            break;
    }
    return name;
}



// 线程池
static NSOperationQueue *sharedQueue = nil;

@interface WYSynchronization ()
// 同步委托
@property (nonatomic,weak) id<WYSynchronizationDelegate> synchronizationDelegate;

// 此同步对象包含的操作队列
@property (nonatomic) NSMutableArray *databaseOperationsForC2S;

// 有效
@property (nonatomic) BOOL cancel;
// 当前的request
@property (nonatomic) ASIHTTPRequest* requestInDoing;
@end

@implementation WYSynchronization

+(void)initialize{
    [super initialize];
    sharedQueue = [[NSOperationQueue alloc] init];
    [sharedQueue setMaxConcurrentOperationCount:1];
}

- (id)initWithDelegate:(id<WYSynchronizationDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.synchronizationDelegate = delegate;
        self.particle = -1;
    }
    return self;
}

+(id)synchronizationWithDelegate:(id<WYSynchronizationDelegate>)delegate{
    return [[self alloc] initWithDelegate:delegate];
}

-(NSString *)description{
    NSString* synchronizationFailedType = nil;
    NSString* synchronizationType = nil;
    switch (self.synchronizationFailedType) {
        case SynchronizationFailedTypeNoNetwork:
            synchronizationFailedType = @"SynchronizationFailedTypeNoNetwork";
            break;
        case SynchronizationFailedTypeDatabaseError:
            synchronizationFailedType = @"SynchronizationFailedTypeDatabaseError";
            break;
        case SynchronizationFailedTypeTimeOut:
            synchronizationFailedType = @"SynchronizationFailedTypeTimeOut";
            break;
        case SynchronizationFailedTypeRequestError:
            synchronizationFailedType = @"SynchronizationFailedTypeRequestError";
            break;
        case SynchronizationFailedTypeServerFailed:
            synchronizationFailedType = @"SynchronizationFailedTypeServerFailed";
            break;
        default:
            break;
    }
    switch (self.synchronizationType) {
        case SynchronizationTypeS2CForDatabase:
            synchronizationType = @"SynchronizationTypeS2CForDatabase";
            break;
        case SynchronizationTypeC2SForDatabase:
            synchronizationType = @"SynchronizationTypeC2SForDatabase";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"\n\n%@\nurl:%@\nrequestMethod:%@\nSynchronizationFailedType:%@\nSynchronizationType:%@\ntag:%@\nparticle:%d\n\n",[super description],self.synchronizationUrl,self.requestMethod,synchronizationFailedType,synchronizationType,self.tag,self.particle];
}

#pragma mark public
LKDBHelper* wySyncLKDBHelper = nil;
+(LKDBHelper*) getLKDBHelperForSync{
    return wySyncLKDBHelper;
}
// 操作队列所在数据库名,使用同步框架前必须设置
+(void) setSyncDBNameAndCreat:(NSString*)name{
    if (wySyncLKDBHelper){
        [wySyncLKDBHelper setDBName:name];
    }else{
        wySyncLKDBHelper = [[LKDBHelper alloc] initWithDBName:name];
    }
    // 如果没有操作队列数据库,则新建
    [self creatSynchronizationDB];
}


// 准备同步，加入运行队列
-(BOOL) startSynchronization{
    if(![[self class] getLKDBHelperForSync]){
        WYLogError(@"未设置 LKDBHelper");
        return NO;
    }
    // 判断可否同步
    if(!self.synchronizationDelegate){
        return NO;
    }
    if(!self.synchronizationType){
        return NO;
    }
    if(!self.synchronizationUrl){
        return NO;
    }
    if (self.cancel) {
        // 处于取消状态,不同步
        return NO;
    }
    // 验证完成，加入队列，开始执行
    [sharedQueue addOperation:self];
    return YES;
}
// 取消同步
-(void) cancelSynchronization{
    WYLogWarn(@"取消同步:%@",self);
    self.cancel = YES;
    [sharedQueue cancelAllOperations];
    if (self.requestInDoing) {
        WYLogWarn(@"取消请求:%@",self.requestInDoing);
        [self.requestInDoing clearDelegatesAndCancel];
    }
}
// 获取操作队列条数，应在非ui线程下执行
+(NSInteger) countForOperationWithDbName:(NSArray*)dbNames tbNames:(NSArray*)tbNames uuids:(NSArray*)uuids{
    NSMutableDictionary* where = [NSMutableDictionary dictionary];
    if (dbNames) {
        [where setObject:dbNames forKey:@"wy_dbName"];
    }
    if (tbNames) {
        [where setObject:tbNames forKey:@"wy_tbName"];
    }
    if (uuids) {
        [where setObject:uuids forKey:@"wy_uuid"];
    }
    LKDBHelper* helper = [[self class] getLKDBHelperForSync];
    return [helper rowCount:[WYDatabaseOperation class] where:where];
}
+(void) notifyReplaceEntity:(NSObject *)entity{
    LKDBHelper* globalHelper = [WYSynchronization getLKDBHelperForSync];
    WYDatabaseOperation* dbOperation = [WYDatabaseOperation new];
    dbOperation.wy_operation = SynchronizationOperationAddOrUpdate;
    dbOperation.wy_dbName = [[entity class] syncOperationDBName];
    dbOperation.wy_tbName = [[entity class] syncOperationTBName];
    dbOperation.wy_timestamp = [entity syncOperationTimestamp];
    dbOperation.wy_uuid = [entity syncOperationUUID];
    dbOperation.wy_primary_key = [[entity class] syncOperationPrimaryKey];
    dbOperation.wy_data = [entity syncDataContent];
    [globalHelper insertToDB:dbOperation];
}
//+(void) notifyCreatOperation:(SynchronizationOperation)op dbName:(NSString *)dbName tbName:(NSString*)tbName timestamp:(NSTimeInterval)timestamp uuid:(NSString*)uuid primaryKey:(NSString*)key data:(NSString*)data{
//    LKDBHelper* globalHelper = [WYSynchronization getLKDBHelperForSync];
//    WYDatabaseOperation* dbOperation = [WYDatabaseOperation new];
//    dbOperation.wy_operation = op;
//    dbOperation.wy_dbName = dbName;
//    dbOperation.wy_tbName = tbName;
//    dbOperation.wy_timestamp = timestamp;
//    dbOperation.wy_uuid = uuid;
//    dbOperation.wy_primary_key = key;
//    dbOperation.wy_data = data;
//    [globalHelper insertToDB:dbOperation];
//}
+(void) notifyDeleteEntity:(NSObject *)entity{
    LKDBHelper* globalHelper = [WYSynchronization getLKDBHelperForSync];
    WYDatabaseOperation* dbOperation = [WYDatabaseOperation new];
    dbOperation.wy_operation = SynchronizationOperationDelete;
    dbOperation.wy_dbName = [[entity class] syncOperationDBName];
    dbOperation.wy_tbName = [[entity class] syncOperationTBName];
    dbOperation.wy_timestamp = [entity syncOperationTimestamp];
    dbOperation.wy_uuid = [entity syncOperationUUID];
    dbOperation.wy_primary_key = [[entity class] syncOperationPrimaryKey];
    dbOperation.wy_data = @"";
    [globalHelper insertToDB:dbOperation];
}

+(void) replaceSyncOperation:(WYDatabaseOperation*)op{
    LKDBHelper* globalHelper = [WYSynchronization getLKDBHelperForSync];
    [globalHelper insertToDB:op];
}

#pragma mark private

// 进行同步
-(void) main{
    if (self.cancel) {
        return;
    }
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:self.synchronizationUrl];
    if(self.requestMethod){
        [request setRequestMethod:self.requestMethod];
    }
//    request.timeOutSeconds = 60*60;
    [request setTag:self.synchronizationType];
    // 开始同步
    switch (self.synchronizationType) {
        case SynchronizationTypeS2CForDatabase:{
            // 从服务器向客户端同步数据
            _requestJson = [self.synchronizationDelegate s2cRequestJsonWithSynchronization:self];
            if(_requestJson){
                WYLogVerbose(@"请求json:%@",_requestJson);
                [request setPostBody:[NSMutableData dataWithData:[_requestJson dataUsingEncoding:NSUTF8StringEncoding]]];
            }
            break;
        }
        case SynchronizationTypeC2SForDatabase:{
            // 从客户端向服务器同步数据
            NSArray* dbNames = nil;
            NSArray* tbNames = nil;
            NSArray* uuids = nil;
            [self.synchronizationDelegate c2sDatabaseOperationWhereDBName:&dbNames table:&tbNames uuid:&uuids];
            NSMutableDictionary* where = [NSMutableDictionary dictionary];
            if (dbNames) {
                [where setObject:dbNames forKey:@"wy_dbName"];
            }
            if (tbNames) {
                [where setObject:tbNames forKey:@"wy_tbName"];
            }
            if (uuids) {
                [where setObject:uuids forKey:@"wy_uuid"];
            }
            LKDBHelper* globalHelper = [WYSynchronization getLKDBHelperForSync];
            self.databaseOperationsForC2S = [globalHelper search:[WYDatabaseOperation class] where:where orderBy:nil offset:0 count:self.particle];
            // 如果c2s没有操作队列，则结束
            if (!self.databaseOperationsForC2S || self.databaseOperationsForC2S.count==0) {
                WYLogWarn(@"没有操作队列可同步");
                return;
            }
            _requestJson = [self.synchronizationDelegate c2sRequestJsonWithSynchronization:self operations:self.databaseOperationsForC2S];
            if(_requestJson){
                WYLogVerbose(@"请求json:%@",_requestJson);
                [request setPostBody:[NSMutableData dataWithData:[_requestJson dataUsingEncoding:NSUTF8StringEncoding]]];
            }
            break;
        }
            
        default:
            break;
    }
    // 开始同步 回调
    [self.synchronizationDelegate beforeSynchronization:self];
    if (self.cancel) {
        return;
    }
    // 同步请求
    self.requestInDoing = request;
    [request startSynchronous];
    self.requestInDoing = nil;
    if (self.cancel) {
        return;
    }
    NSError* error = [request error];
    if(!error){
        [self requestFinished:request];
    }else{
        [self requestFailed:request];
    }
}


+(void) creatSynchronizationDB{
    // 如果没有操作队列数据库,则新建
    [[self getLKDBHelperForSync] createTableWithModelClass:[WYDatabaseOperation class]];
    WYLogWarn(@"创建sync表(如果不存在)");
}

-(BOOL) updateWithDatabaseOperation:(WYDatabaseOperation*)databaseOperation{
    if ([self.synchronizationDelegate respondsToSelector:@selector(s2cWillUpdateDBWithSynchronization:operation:)]) {
        [self.synchronizationDelegate s2cWillUpdateDBWithSynchronization:self operation:databaseOperation];
    }
    BOOL result = NO;
    NSString* sql = [self sqlWithDatabaseOperation:databaseOperation];
    WYLogInfo(@"执行sql:%@",sql);
    if(sql){
#warning 连续执行1000条操作,会异常,可能是这里出现问题!\
不能连续创建LKDBHelper对象,应该判断此操作队列是否属于这个用户,是,用以前做得单例去操作,否,则不应该出现此种情况,打LOG,丢弃此操作队列
        LKDBHelper* helper = [[LKDBHelper alloc] initWithDBName:databaseOperation.wy_dbName];
        @try {
            result = [helper executeSQL:sql arguments:nil];
        }
        @catch (NSException *exception) {
            WYLogError(@"%sdb异常,sql:%@,NSException:%@",__FUNCTION__,sql,exception);
        }
        @finally {
            
        }
    }
    if ([self.synchronizationDelegate respondsToSelector:@selector(s2cDidUpdateDBWithSynchronization:operation:)]) {
        [self.synchronizationDelegate s2cDidUpdateDBWithSynchronization:self operation:databaseOperation];
    }
    return result;
}
-(BOOL) updateWithDatabaseOperationArray:(NSArray*)databaseOperationArray{
    BOOL result = YES;
    for (WYDatabaseOperation* databaseOperation in databaseOperationArray) {
        result = result && [self updateWithDatabaseOperation:databaseOperation];
        if (!result) {
            break;
        }
    }
    return result;
}
-(BOOL) deleteOperationWhenC2SFinished{
    BOOL result = YES;
    LKDBHelper* helper = [WYSynchronization getLKDBHelperForSync];
    for (WYDatabaseOperation* wyDO in self.databaseOperationsForC2S) {
        result = [helper deleteToDB:wyDO] && result;
    }
    return result;
}
#define DELETE_SQL @"DELETE FROM %@ WHERE %@ = '%@'"
#define REPLACE_SQL @"REPLACE INTO %@(%@) values(%@)"

-(NSString*) sqlWithDatabaseOperation:(WYDatabaseOperation*)databaseOperation{
    NSString* sql = nil;
    switch (databaseOperation.wy_operation) {
        case SynchronizationOperationAddOrUpdate:{
            // replace
            NSMutableString* keys = [NSMutableString stringWithCapacity:20];
            NSMutableString* values = [NSMutableString stringWithCapacity:20];
            NSMutableDictionary* entity = [databaseOperation.wy_data objectFromJSONStringWithParseOptions:JKParseOptionStrict];
            for (NSString* e_key in entity.allKeys) {
                NSString* e_value = [entity objectForKey:e_key];
                [keys appendFormat:@"%@,",e_key];
                [values appendFormat:@"'%@',",e_value];
            }
            if (keys.length !=0 && values.length != 0) {
                sql = [NSString stringWithFormat:REPLACE_SQL,databaseOperation.wy_tbName,[keys substringToIndex:([keys length]-1)],[values substringToIndex:([values length]-1)]];
            }
            break;
        }
        case SynchronizationOperationDelete:{
            sql = [NSString stringWithFormat:DELETE_SQL,databaseOperation.wy_tbName,databaseOperation.wy_primary_key,databaseOperation.wy_uuid];
            break;
        }
        default:
            break;
    }
    return sql;
}

#pragma mark ASIHTTPRequestDelegate
-(void)requestFinished:(ASIHTTPRequest*)request{
    // 解析封装json
    WYLogVerbose(@"响应json:%@",[request responseString]);
    _responseJson = [[request responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
    switch (request.tag) {
        case SynchronizationTypeS2CForDatabase:{
            BOOL ok = [self.synchronizationDelegate s2cIsSuccessWhenRequestFinishWithSynchronization:self Json:_responseJson];
            if(!ok){
                // 失败
                // 取消所有将要执行的线程
                [sharedQueue cancelAllOperations];
                _synchronizationFailedType = SynchronizationFailedTypeServerFailed;
                [self.synchronizationDelegate synchronizationFailed:self];
                break;
            }
            NSArray* databaseOperationArray = [self.synchronizationDelegate s2cOperationsWithSynchronization:self Json:_responseJson];
            
            // 更新数据库前
            [self.synchronizationDelegate s2cWillUpdateDBWithSynchronization:self operations:databaseOperationArray];
            // 按operation操作数据库
            BOOL ok_db = [self updateWithDatabaseOperationArray:databaseOperationArray];
            if(!ok_db){
                // 失败
                // 取消所有将要执行的线程
                [sharedQueue cancelAllOperations];
                _synchronizationFailedType = SynchronizationFailedTypeDatabaseError;
                [self.synchronizationDelegate synchronizationFailed:self];
                break;
            }
            // 更新数据库结束
            [self.synchronizationDelegate s2cDidUpdateDBWithSynchronization:self operations:databaseOperationArray];
            // 成功
            [self.synchronizationDelegate synchronizationFinished:self];
//            // 进行下个同步
//            self.doNext = YES;
            break;
        }
        case SynchronizationTypeC2SForDatabase:{
            
            BOOL ok = [self.synchronizationDelegate c2sIsSuccessWhenRequestFinishWithSynchronization:self Json:_responseJson];
            if(!ok){
                // 失败
                // 取消所有将要执行的线程
                [sharedQueue cancelAllOperations];
                _synchronizationFailedType = SynchronizationFailedTypeServerFailed;
                [self.synchronizationDelegate synchronizationFailed:self];
                break;
            }
            // 服务器同步成功
            BOOL ok_db = [self deleteOperationWhenC2SFinished];
            if(!ok_db){
                // 数据库删除操作队列异常
                // 取消所有将要执行的线程
                [sharedQueue cancelAllOperations];
                _synchronizationFailedType = SynchronizationFailedTypeDatabaseError;
                [self.synchronizationDelegate synchronizationFailed:self];
                break;
            }
            // 胜利
            [self.synchronizationDelegate synchronizationFinished:self];
//            // 进行下个同步
//            self.doNext = YES;
            break;
        }
        default:
            break;
    }
}



-(void)requestFailed:(ASIHTTPRequest*)request{
    NSError *error = [request error];
    WYLogWarn(@"%s请求失败:%@",__FUNCTION__,error);
    
    // 取消所有将要执行的线程
    [sharedQueue cancelAllOperations];
    
    switch (request.tag) {
        case SynchronizationTypeS2CForDatabase:
            _synchronizationFailedType = SynchronizationFailedTypeRequestError;
            [self.synchronizationDelegate synchronizationFailed:self];
            break;
        case SynchronizationTypeC2SForDatabase:
            _synchronizationFailedType = SynchronizationFailedTypeRequestError;
            [self.synchronizationDelegate synchronizationFailed:self];
            break;
        default:
            break;
    }
}
@end
