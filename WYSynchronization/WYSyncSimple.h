//
//  WYSyncSimple.h
//  Code Prometheus
//
//  Created by mirror on 13-9-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYDatabaseOperation.h"

@protocol WYSyncSimpleDelegate <NSObject>

// 创建数据库
-(void) creatDB;
// 删除数据库
-(void) dropDB;


// json字典转操作对象
-(NSArray*) downloadOperationsFromJson:(NSDictionary*)json;
// s2c的请求参数
-(NSString*) downloadRequestJson;
// 是否清空数据库
-(BOOL) downloadIsCleanDBWithJson:(NSDictionary*)json;
// download完成
-(void) downloadFinishWithJson:(NSDictionary*)json;
// 接受服务器返回值,返回是否同步成功
-(BOOL) downloadIsSuccessWithJson:(NSDictionary*)responce;

// 获取同步的json
-(NSString*) uploadRequestJsonWithOperations:(NSArray*)operations;
// 接受服务器返回值,返回是否同步成功
-(BOOL) uploadIsSuccessWithJson:(NSDictionary*)responce;
// upload完成
-(void) uploadFinishWithJson:(NSDictionary*)json;
// 上传之后，是否需要下载
-(BOOL) uploadNeedDownloadWithJson:(NSDictionary*)json;
// 获取需要上传的操作队列的条件
-(void) uploadDatabaseOperationWhereDBName:(NSArray**)dbName table:(NSArray**)tableName uuid:(NSArray**)uuid;

//// File
//-(void) willUploadFileWithFileModel:(NSObject*)entity;
//-(void) didUploadFileWithFileModel:(NSObject*)entity;

//// 通过操作队列，更新数据库前
//-(void) s2cWillUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations;
//// 通过操作队列，更新数据库后
//-(void) s2cDidUpdateDBWithSynchronization:(WYSynchronization*)wySynchronization operations:(NSArray*)operations;




-(void) willDoSync;
-(void) didDoSync;

//// 服务器版本
//-(NSInteger) currentDBVersion;
//-(void) setDBVersion:(NSInteger)version;

@optional
// 执行某个操作前
-(void) downloadWillDoOperation:(WYDatabaseOperation*)op;
// 执行某个操作后
-(void) downloadDidDoOperation:(WYDatabaseOperation*)op;


@end


//@interface NSObject (WYSyncSimpleFileModel)
//// 子类需覆盖此方法，返回判断本数据的文件是否上传过的where查询条件
//+(NSString*) wy_whereForSearchWhenFileUpload;
//
//// 子类需覆盖此方法，返回需要上传的属性名（类型应该为nsstring）
//+(NSArray*) wy_propertyNamesForUpload;
//
//// 文件上传结束，子类应重写此方法，修改标志
//-(void) wy_fileUploadFinish;
//@end

@interface WYSyncSimple : NSObject

@property (nonatomic,weak) id<WYSyncSimpleDelegate> delegate;
//@property (nonatomic,copy) NSString* url_file_upload;
@property (nonatomic,copy) NSString* url_upload;
@property (nonatomic,copy) NSString* url_download;
//@property (nonatomic,copy) NSString* dbName;

// failedMaxCountForClean 次非网络的原因失败后，清空数据库，重新fullcopy,默认3
@property (nonatomic) NSInteger failedMaxCountForClean;
// 无网,检查网络间隔 默认10s
@property (nonatomic) NSInteger intervalForCheckNet;
// json请求异常,重新请求间隔 默认3s
@property (nonatomic) NSInteger intervalForJsonRequest;

// 通知同步
-(void) notifyNeedSync;

// 通知取消同步
-(void) notifyCancelSync;

//// 注册需文件同步的类
//-(void) registerFileModel:(Class)fileClass;

// 获取单例的 同步对象
+(WYSyncSimple*) sharedWYSyncSimple;

@end
