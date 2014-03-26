//
//  NSString+CP_Aleph.h
//  Code Prometheus
//
//  Created by mirror on 13-11-25.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CP_Aleph)
// 字符串首字母转大写拼音,如果不是26字母,则返回 #
-(NSString*) aleph;
@end
