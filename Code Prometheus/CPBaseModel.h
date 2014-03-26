//
//  CPBaseModel.h
//  Code Prometheus
//
//  Created by mirror on 13-9-16.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYDatabaseOperation.h"

NSString *const CP_ENTITY_OPERATION_KEY;

typedef NS_ENUM(NSInteger, CP_ENTITY_OPERATION) {
    CP_ENTITY_OPERATION_ADD,
    CP_ENTITY_OPERATION_DELETE,
    CP_ENTITY_OPERATION_UPDATE
};

@class FMResultSet;

@interface CPBaseModel : NSObject

+ (instancetype) newAdaptDB;

@end

