//
//  CPImage.m
//  Code Prometheus
//
//  Created by mirror on 13-12-3.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPImage.h"
#import <SDImageCache.h>

@implementation CPImage{
    UIImage* _image;
}
+(void)initialize
{
    [super initialize];
    @synchronized(self) {
	}
    [self removePropertyWithColumeName:@"image"];
}
-(void)setImage:(UIImage *)image{
    _image = image;
}
-(UIImage *)image{
    if (!_image) {
        @synchronized(self){
            if (!_image) {
                _image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.cp_url];
            }
#warning 如果读取不到,应该去网络获取,并显示一张“请刷新”,网络也没有,则应该显示一张“无图片”\
废弃这个警告,应该在应用层控制\
不废除此警告,这里下载图片,控制层也下载
        }
    }
    return _image;
}
#pragma mark - LKDBHelper
// 表名
+(NSString *)getTableName
{
    return @"cp_file";
}

+(void)dbDidIDeleted:(NSObject *)entity result:(BOOL)result{
    [super dbDidIDeleted:entity result:result];
    CPImage* cpimage = (CPImage*)entity;
    // 若此图片在数据库中无引用,则从硬盘删除
    if ([[CPDB getLKDBHelperByUser] rowCount:self where:@{@"cp_url":cpimage.cp_url}] == 0) {
        [[SDImageCache sharedImageCache] removeImageForKey:cpimage.cp_url];
    }
}
+(void)dbDidInserted:(NSObject *)entity result:(BOOL)result{
    [super dbDidInserted:entity result:result];
    CPImage* cpimage = (CPImage*)entity;
    if (cpimage.image) {
        [[SDImageCache sharedImageCache] storeImage:cpimage.image forKey:cpimage.cp_url];
    }
}

//#pragma mark - WYSync
//-(NSString*) syncDataContent{
//    return [self propertyKeyValue];
//}
//#pragma mark - private
//-(NSString*)propertyKeyValue{
//    NSObject* entity = self;
//    LKModelInfos* infos = [[entity class] getModelInfos];
//    NSMutableString* data = [NSMutableString stringWithCapacity:infos.count*20];
//    [data appendString:@"{"];
//    for (int i=0; i<infos.count; i++) {
//        LKDBProperty* property = [infos objectWithIndex:i];
//        id value = [self modelValueWithProperty:property model:entity];
//        if (!value || value==[NSNull null]) {
//            value = @"";
//        }
//        [data appendFormat:@"\"%@\":\"%@\",",property.sqlColumeName,value];
//    }
//    [data replaceCharactersInRange:NSMakeRange(data.length-1, 1) withString:@"}"];
//    return data;
//}
//
//-(id)modelValueWithProperty:(LKDBProperty *)property model:(NSObject *)model {
//    id value = nil;
//    if(property.isUserCalculate)
//    {
//        value = [model userGetValueForModel:property];
//    }
//    else
//    {
//        value = [model modelGetValue:property];
//    }
//    if(value == nil)
//    {
//        value = @"";
//    }
//    return value;
//}
@end
