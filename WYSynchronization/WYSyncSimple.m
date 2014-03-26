//
//  WYSyncSimple.m
//  Code Prometheus
//
//  Created by mirror on 13-9-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "WYSyncSimple.h"
#import "WYSynchronization.h"
#import "WYUtil.h"
#import "WYConfig.h"


// 定时器类型
typedef enum{
    TimerTypeCancel,
    TimerTypeNone,
    TimerTypeCheckNet,
    TimerTypeJson,
}TimerType;

NSString* nameFromTimerType(TimerType type){
    NSString* typeString;
    switch (type) {
        case TimerTypeCancel:
            typeString = @"取消类型";
            break;
        case TimerTypeNone:
            typeString = @"无类型";
            break;
        case TimerTypeCheckNet:
            typeString = @"循环检测网络";
            break;
        case TimerTypeJson:
            typeString = @"循环JSON同步";
            break;
        default:
            typeString = @"？？？";
            break;
    }
    return typeString;
}

@interface WYSyncSimple ()<WYSynchronizationDelegate>

// readonly
@property (atomic) BOOL lock;
@property (atomic) BOOL hasNextSync;

// 定时器
@property (nonatomic,weak) NSTimer* timer;
// 定时器类型
@property (nonatomic) TimerType currentTimerType;

// 计数，超过n次后清空数据库，重新fullcopy
@property (nonatomic) NSInteger failedCountForClean;

@property (nonatomic) WYSynchronization* syncInDoing;

@end




@implementation WYSyncSimple


#pragma mark public

// 单例
static WYSyncSimple* wy_syncSimple;

+(id) allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (wy_syncSimple == nil){
            wy_syncSimple = [super allocWithZone:zone];
            return wy_syncSimple;
        }
    }
    return nil;
}



// 开启定时器
-(void) fireTimerWithType:(TimerType)timerType interval:(NSTimeInterval)interval{
    if (self.currentTimerType == TimerTypeCancel) {
        WYLogWarn(@"同步服务处于取消状态,无法开启定时器");
        return;
    }
    if (!self.timer && self.currentTimerType == TimerTypeNone) {
        // 类型
        self.currentTimerType = timerType;
        // 开始
        WYLogWarn(@"启动定时器，类型:%@",nameFromTimerType(self.currentTimerType));
        NSTimer* timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(doSync) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.timer = timer;
    }else{
        WYLogWarn(@"当前存在定时器,类型:%@,无法再次启动",nameFromTimerType(self.currentTimerType));
    }
}
// 结束定时器
-(void) invalidateTimer:(TimerType)timerType{
    if (timerType != self.currentTimerType) {
        if (self.currentTimerType != TimerTypeNone) {
           WYLogWarn(@"定时器类型不相符,不能取消定时器,当前类型:%@,期望取消类型:%@",nameFromTimerType(self.currentTimerType),nameFromTimerType(timerType));
        }
        return;
    }
    if (self.timer) {
        WYLogInfo(@"取消定时器，定时器类型:%@",nameFromTimerType(self.currentTimerType));
        // 类型
        self.currentTimerType = TimerTypeNone;
        // 结束
        [self.timer invalidate];
        self.timer = nil;
    }
}
+(WYSyncSimple*) sharedWYSyncSimple{
    // 单例
    @synchronized(self){
        if (!wy_syncSimple){
            wy_syncSimple = [WYSyncSimple new];
            wy_syncSimple.failedMaxCountForClean = 3;
            wy_syncSimple.intervalForCheckNet = 10;
            wy_syncSimple.intervalForJsonRequest = 3;
            wy_syncSimple.currentTimerType = TimerTypeNone;
            [WYSynchronization setSyncDBNameAndCreat:@"___wy_sync"];
        }
    }
    return wy_syncSimple;
}
-(void) notifyNeedSync{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (![self checkSync]) {
            WYLogWarn(@"同步服务参数校验未通过");
            return;
        }
        if (self.currentTimerType == TimerTypeCancel) {
            WYLogWarn(@"开启同步服务(从取消状态)");
            self.currentTimerType = TimerTypeNone;
        }
        WYLogInfo(@"通知需要同步");
        // 如果正在同步,则修改 HasNextSync ， 并退出此次请求
        if(self.lock){
            WYLogInfo(@"正在同步，此条需同步通知忽略");
            self.hasNextSync = YES;
            return;
        }
        // 设置标记位为正在同步,HasNextSync为no
        self.lock = YES;
        self.hasNextSync = NO;
        [self doSync];
    });
}
// 通知取消同步
-(void) notifyCancelSync{
    WYLogWarn(@"取消同步服务");
    self.currentTimerType = TimerTypeCancel;
    if (self.timer) {
        WYLogInfo(@"取消定时器，定时器类型:%@",nameFromTimerType(self.currentTimerType));
        // 结束
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.syncInDoing) {
        [self.syncInDoing cancelSynchronization];
        self.syncInDoing = nil;
    }
    self.lock = NO;
}
-(void) doSync{
    [self.delegate willDoSync];
    WYLogInfo(@"异步同步开始-------------------------");
    // 检查网络
    if (![WYUtil networkIsOk]) {
        // 无网状态下，开辟定时器，每 IntervalForSync 秒检测下网络
        WYLogInfo(@"没有网络，开启检测网络定时器,间隔:%d",self.intervalForCheckNet);
        [self fireTimerWithType:TimerTypeCheckNet interval:self.intervalForCheckNet];
        return;
    }
    // 有网，取消定时器(如果存在)
    [self invalidateTimer:TimerTypeCheckNet];
    
    // 本地是否存在操作队列
    WYLogInfo(@"检测是否存在本地操作队列");
    NSArray* dbNames = nil;
    NSArray* tbNames = nil;
    NSArray* uuids = nil;
    [self.delegate uploadDatabaseOperationWhereDBName:&dbNames table:&tbNames uuid:&uuids];
    NSInteger count = [WYSynchronization countForOperationWithDbName:dbNames tbNames:tbNames uuids:uuids];
    if (count>0) {
        WYLogInfo(@"存在本地操作队列,进行 upload");
        // 执行upload   本地操作队列上传 Upload
        WYSynchronization* uploadSync = [self creatUploadSync];
        self.syncInDoing = uploadSync;
        BOOL startSuccess = [uploadSync startSynchronization];
        if (!startSuccess) {
            CPLogWarn(@"同步无法开始.");
            [self notifyCancelSync];
        }
    }else{
        WYLogInfo(@"不存在本地操作队列,进行 download");
        // 执行download
        WYSynchronization* downloadSync = [self creatDownloadSync];
        self.syncInDoing = downloadSync;
        BOOL startSuccess = [downloadSync startSynchronization];
        if (!startSuccess) {
            CPLogWarn(@"同步无法开始.");
            [self notifyCancelSync];
        }
    }
}

-(BOOL) checkSync{
//    if (!self.dbName) {
//        return NO;
//    }
    if (!self.url_download) {
        return NO;
    }
    if (!self.url_upload) {
        return NO;
    }
    if (!self.delegate) {
        return NO;
    }
    if (self.failedMaxCountForClean < 0) {
        return NO;
    }
    return YES;
}

#pragma mark private

-(WYSynchronization*)creatUploadSync{
    WYSynchronization *uploadSync = [WYSynchronization synchronizationWithDelegate:[[self class] sharedWYSyncSimple]];
    uploadSync.synchronizationUrl = [NSURL URLWithString:self.url_upload];
    uploadSync.synchronizationType = SynchronizationTypeC2SForDatabase;
    return uploadSync;
}

-(WYSynchronization*)creatDownloadSync{
    WYSynchronization *downloadSync = [WYSynchronization synchronizationWithDelegate:[[self class] sharedWYSyncSimple]];
    downloadSync.synchronizationUrl = [NSURL URLWithString:self.url_download];
    downloadSync.synchronizationType = SynchronizationTypeS2CForDatabase;
    return downloadSync;
}





#pragma mark WYSynchronizationDelegate

-(NSArray*) s2cOperationsWithSynchronization:(WYSynchronization*)wySynchronization Json:(NSDictionary*)json{
    return [self.delegate downloadOperationsFromJson:json];
}
-(NSString*) s2cRequestJsonWithSynchronization:(WYSynchronization*)wySynchronization{
    return [self.delegate downloadRequestJson];
}
// 通过操作队列，更新数据库前
-(void) s2cWillUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations{
    WYLogInfo(@"准备数据库更新");
    // 判断是否需要清空数据库
    BOOL isClean = [self.delegate downloadIsCleanDBWithJson:wySynchronization.responseJson];
    if (isClean) {
        WYLogWarn(@"服务器要求清空数据库,进行fullcopy");
        [self.delegate dropDB];
        [self.delegate creatDB];
    }
}
// 通过操作队列，更新数据库后
-(void) s2cDidUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations{
    WYLogInfo(@"数据库更新完成");
}

-(BOOL) s2cIsSuccessWhenRequestFinishWithSynchronization:(WYSynchronization*)wySynchronization Json:(NSDictionary*)responce{
    return [self.delegate downloadIsSuccessWithJson:responce];
}
-(void) s2cWillUpdateDBWithSynchronization:(WYSynchronization *)wySynchronization operation:(WYDatabaseOperation *)operation{
    if ([self.delegate respondsToSelector:@selector(downloadWillDoOperation:)]) {
        [self.delegate downloadWillDoOperation:operation];
    }
}
-(void) s2cDidUpdateDBWithSynchronization:(WYSynchronization *)wySynchronization operation:(WYDatabaseOperation *)operation{
    if ([self.delegate respondsToSelector:@selector(downloadDidDoOperation:)]) {
        [self.delegate downloadDidDoOperation:operation];
    }
}
// C 2 S
// 获取同步的json
-(NSString*) c2sRequestJsonWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations{
    return [self.delegate uploadRequestJsonWithOperations:operations];
}
// 接受服务器返回值,返回是否同步成功
// 此方法内不应该直接调用 notifyNeedSync ，因为必须先处理完 操作队列 的删除
-(BOOL) c2sIsSuccessWhenRequestFinishWithSynchronization:(WYSynchronization*)wySynchronization Json:(NSDictionary*)responce{
    return [self.delegate uploadIsSuccessWithJson:responce];
}
// 获取需要上传的操作队列的条件
-(void) c2sDatabaseOperationWhereDBName:(NSArray**)dbName table:(NSArray**)tableName uuid:(NSArray**)uuid{
    return [self.delegate uploadDatabaseOperationWhereDBName:dbName table:tableName uuid:uuid];
}

// 同步失败
-(void) synchronizationFailed:(WYSynchronization*)wySynchronization{
    WYLogWarn(@"同步失败,类型:%@,原因:%@",nameFromSynchronizationType(wySynchronization.synchronizationType),nameFromSynchronizationFailedType(wySynchronization.synchronizationFailedType));
    if (wySynchronization.synchronizationFailedType == SynchronizationFailedTypeDatabaseError) {
        WYLogError(@"由于数据库原因，同步失败，还剩%d次机会",self.failedMaxCountForClean-self.failedCountForClean);
        self.failedCountForClean = self.failedCountForClean + 1;
    }
    // 超过n次数据库错误，则fullcopy
    if (self.failedCountForClean > self.failedMaxCountForClean) {
        WYLogError(@"由于数据库原因，同步失败，没有机会了，进行数据库清除！");
        [self.delegate dropDB];
        [self.delegate creatDB];
        WYLogError(@"数据库重置完成！重置机会次数");
        self.failedCountForClean = 0;
    }
    self.syncInDoing = nil;
    // 同步失败，循环再次同步
    WYLogWarn(@"同步失败，开启循环同步定时器,间隔:%d",self.intervalForJsonRequest);
    [self fireTimerWithType:TimerTypeJson interval:self.intervalForJsonRequest];
}

// 同步成功
-(void) synchronizationFinished:(WYSynchronization*)wySynchronization{
    WYLogInfo(@"同步成功,类型:%@",nameFromSynchronizationType(wySynchronization.synchronizationType));
    // json同步成功，取消定时器（如果有）
    [self invalidateTimer:TimerTypeJson];
    
    // 重置clean条件
    if (self.failedCountForClean != 0 ) {
        WYLogWarn(@"同步成功,重置机会次数 %d ->0",self.failedCountForClean);
        self.failedCountForClean = 0;
    }
    
    // 是否需要download
    BOOL needDownAfterUpload = NO;
    
    switch (wySynchronization.synchronizationType) {
        case SynchronizationTypeS2CForDatabase:{
            [self.delegate downloadFinishWithJson:wySynchronization.responseJson];
            break;
        }
        case SynchronizationTypeC2SForDatabase:{
            
            needDownAfterUpload = [self.delegate uploadNeedDownloadWithJson:wySynchronization.responseJson];
            
            [self.delegate uploadFinishWithJson:wySynchronization.responseJson];
            
            break;
        }
        default:
            break;
    }
    // 同步结束
    WYLogInfo(@"同步结束-------------------------");
    [self.delegate didDoSync];
    self.syncInDoing = nil;
    self.lock = NO;
    // 如果存在下次同步,或者服务器要求download,则再次通知
    if (needDownAfterUpload || self.hasNextSync) {
        CPLogInfo(@"存在下次同步,或者服务器要求download,再次进行同步!");
        [self notifyNeedSync];
    }
}

// 开始同步前
-(void) beforeSynchronization:(WYSynchronization*)wySynchronization{
    WYLogInfo(@"开始同步,类型:%@",nameFromSynchronizationType(wySynchronization.synchronizationType));
}
@end
