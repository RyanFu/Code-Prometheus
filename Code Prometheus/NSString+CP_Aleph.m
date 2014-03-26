//
//  NSString+CP_Aleph.m
//  Code Prometheus
//
//  Created by mirror on 13-11-25.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "NSString+CP_Aleph.h"
#import <PinYin4Objc.h>

@implementation NSString (CP_Aleph)

-(NSString*) aleph{
    // 格式
    static HanyuPinyinOutputFormat *cpOutputFormat = nil;
    if (!cpOutputFormat) {
        cpOutputFormat=[[HanyuPinyinOutputFormat alloc] init];
        [cpOutputFormat setToneType:ToneTypeWithoutTone];
        [cpOutputFormat setVCharType:VCharTypeWithV];
        [cpOutputFormat setCaseType:CaseTypeUppercase];
    }
    // 校验
    if (self.length<1) {
        return @"#";
    }
    // GO
    NSString* initial =[PinyinHelper toHanyuPinyinStringWithNSString:[self substringToIndex:1] withHanyuPinyinOutputFormat:cpOutputFormat withNSString:@""];
    initial = [initial substringToIndex:1];
    char initialChar = [initial characterAtIndex:0];
    if (initialChar<65 || initialChar>90) {
        if (initialChar>=97 && initialChar<=122) {
            initialChar -=32;
            initial = [NSString stringWithFormat:@"%c",initialChar];
        }else{
            initial = @"#";
        }
    }
    return initial;
}
@end
