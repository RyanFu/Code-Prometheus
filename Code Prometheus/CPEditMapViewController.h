//
//  CPEditMapViewController.h
//  Code Prometheus
//
//  Created by mirror on 13-12-6.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMapViewController.h"
#import "CPCusAnnotationView.h"

@class CPEditMapViewController;

@protocol CPEditMapDelegate <NSObject>
-(void) saveAddress:(CPEditMapViewController*)controller name:(NSString*)name longitude:(NSString*)longitude latitude:(NSString*)latitude;
@end


@interface CPEditMapViewController : BaseMapViewController
@property(nonatomic) NSString* name;
@property(nonatomic) CPPointAnnotation* cpAnnotation;
@property(nonatomic,weak) id<CPEditMapDelegate> delegate;
@end
