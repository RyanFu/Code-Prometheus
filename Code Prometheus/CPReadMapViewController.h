//
//  CPReadMapViewController.h
//  Code Prometheus
//
//  Created by mirror on 13-12-9.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMapViewController.h"
#import "CPCusAnnotationView.h"

@interface CPReadMapViewController : BaseMapViewController
@property(nonatomic) CPPointAnnotation* cpAnnotation;
@end
