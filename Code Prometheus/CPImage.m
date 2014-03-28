//
//  CPImage.m
//  Code Prometheus
//
//  Created by mirror on 13-12-3.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPImage.h"
#import <SDImageCache.h>
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>

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
                if (self.cp_url) {
                    _image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.cp_url];
                }
                if (!_image) {
                    _image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.cp_uuid];
                }
            }
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
    [[SDImageCache sharedImageCache] removeImageForKey:cpimage.cp_uuid];
    if (cpimage.cp_url && [[CPDB getLKDBHelperByUser] rowCount:self where:@{@"cp_url":cpimage.cp_url}] == 0) {
        [[SDImageCache sharedImageCache] removeImageForKey:cpimage.cp_url];
    }
}
+(void)dbDidInserted:(NSObject *)entity result:(BOOL)result{
    [super dbDidInserted:entity result:result];
    CPImage* cpimage = (CPImage*)entity;
    if (cpimage.image) {
        if (cpimage.cp_url) {
            [[SDImageCache sharedImageCache] storeImage:cpimage.image forKey:cpimage.cp_url];
        }else{
            [[SDImageCache sharedImageCache] storeImage:cpimage.image forKey:cpimage.cp_uuid];
        }
    }
}
+(void)dbWillUpdate:(NSObject *)entity{
    @throw [NSException exceptionWithName:@"不建议更新 CPImage" reason:@"更新CPImage,其对应的图片文件可能不能清除!" userInfo:nil];
}
@end



@implementation UIImageView (CPImage)

-(void)setImageWithCPImage:(CPImage*)image{
    UIImage* ima = image.image;
    if (ima) {
        self.image = ima;
    }else{
        if (image.cp_url) {
            [self setImageWithURL:[NSURL URLWithString:image.cp_url] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageProgressiveDownload|SDWebImageRefreshCached|SDWebImageContinueInBackground];
        }else{
            CPLogError(@"图片未同步,并且本地找不到! uuid:%@",image.cp_uuid);
            self.image = [UIImage imageNamed:@"cp_null_photo"];
        }
    }
}

@end

@implementation UIButton (CPImage)
-(void)setImageWithCPImage:(CPImage*)image{
    UIImage* ima = image.image;
    if (ima) {
        [self setImage:ima forState:UIControlStateNormal];
    }else{
        if (image.cp_url) {
            [self setImageWithURL:[NSURL URLWithString:image.cp_url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageProgressiveDownload|SDWebImageRefreshCached|SDWebImageContinueInBackground];
        }else{
            CPLogError(@"图片未同步,并且本地找不到! uuid:%@",image.cp_uuid);
            [self setImage:[UIImage imageNamed:@"cp_null_photo"] forState:UIControlStateNormal];
        }
    }
}

@end
