//
//  CPFile.h
//  Code Prometheus
//
//  Created by mirror on 13-11-21.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPFile : NSObject
// 文件
+(NSString*) copyFile:(NSData*) data name:(NSString*)fileName;
+(NSString*) filePathWithName:(NSString*)fileName;
+(BOOL) deleteFileWithPath:(NSString*)path;
+(NSString*) copyFileInCache:(NSData *)data name:(NSString *)fileName;
+(NSString*) fileCachePathWithName:(NSString*)fileName;

// 网络
+(BOOL) downloadFileWithURL:(NSString*)url toPath:(NSString*)path;
+(NSString*) uploadFile:(NSData*)data url:(NSString*)url key:(NSString*)key;
@end
