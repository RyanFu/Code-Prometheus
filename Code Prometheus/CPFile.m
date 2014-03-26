//
//  CPFile.m
//  Code Prometheus
//
//  Created by mirror on 13-11-21.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFile.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation CPFile
+(NSString*) copyFile:(NSData*) data name:(NSString*)fileName{
    CPLogInfo(@"拷贝文件:%@",fileName);
    NSString *filePath = [self filePathWithName:fileName];
    // 写入
    NSError *error;
    BOOL success = [data writeToFile:filePath options:0 error:&error];
    if (!success) {
        CPLogError(@"拷贝文件(writeToFile)失败:%@", error);
    }
    return success ? filePath : nil;
}
+(NSString*) filePathWithName:(NSString*)fileName{
    // 路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* documentsName = CPUserName;
    if (!documentsName) {
        documentsName = @"___cp_off_line_files";
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/___cp_file/%@",
                          documentsDirectory,documentsName];
    // 文件夹
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [NSString stringWithFormat:@"%@/%@",filePath,fileName];
    return filePath;
}
+(BOOL) deleteFileWithPath:(NSString*)path{
    NSError* error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:path];
    if (!exist) {
        CPLogWarn(@"文件不存在,无需删除");
        return YES;
    }
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    if (!success) {
        CPLogError(@"删除文件错误:%@",error);
    }else{
        CPLogInfo(@"删除文件成功 path:%@",path);
    }
    return success;
}

+(NSString*) copyFileInCache:(NSData *)data name:(NSString *)fileName{
    CPLogInfo(@"拷贝缓存文件:%@",fileName);
    NSString *filePath = [self fileCachePathWithName:fileName];
    // 写入
    NSError *error;
    BOOL success = [data writeToFile:filePath options:0 error:&error];
    if (!success) {
        CPLogError(@"拷贝缓存文件(writeToFile)失败:%@", error);
    }
    return success ? filePath : nil;
}
+(NSString*) fileCachePathWithName:(NSString*)fileName{
    // 路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString* documentsName = CPUserName;
    if (!documentsName) {
        documentsName = @"___cp_off_line_files";
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/___cp_file/%@",
                          cacheDirectory,documentsName];
    // 文件夹
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [NSString stringWithFormat:@"%@/%@",filePath,fileName];
    return filePath;
}

+(BOOL) downloadFileWithURL:(NSString*)url toPath:(NSString*)path{
    CPLogInfo(@"开始下载文件,url:%@,path:%@",url,path);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDownloadProgressDelegate:self];
    request.showAccurateProgress = YES;
    [request setDownloadDestinationPath :path];
    [request startSynchronous ];
    NSError* error = [request error];
    if(!error){
        return YES;
    }else{
        CPLogError(@"下载文件失败,error:%@,url:%@,path:%@",error,url,path);
        return NO;
    }
}
// 同步上传文件，返回文件url,失败返回nil
+(NSString*) uploadFile:(NSData*)data url:(NSString*)url key:(NSString*)key{
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setUploadProgressDelegate:self];
    request.showAccurateProgress = YES;
    [request setData:data forKey:key];
    [request startSynchronous];
    NSError* error = [request error];
    if(!error){
        NSString* json = [request responseString];
        return json;
    }else{
        CPLogError(@"上传文件失败:%@",error);
        return nil;
    }
}
#pragma mark - ASIProgressDelegate
+(void)setProgress:(float)newProgress{
    static NSInteger progressLast = -1;
    NSInteger progress = newProgress*100;
    if (newProgress != progress) {
        CPLogInfo(@"进度:%d%%",progress);
        progressLast = progress;
    }
}
@end
