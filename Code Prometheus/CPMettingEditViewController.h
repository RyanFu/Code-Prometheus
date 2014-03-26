//
//  CPMettingEditViewController.h
//  Code Prometheus
//
//  Created by mirror on 13-12-10.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HPGrowingTextView.h>

@class CPMettingEditViewController;

@protocol CPMettingEditDelegate <NSObject>
@optional
- (void)meetingContentTextViewDidEndEditing:(CPMettingEditViewController *)meeting withText:(NSString*)text;
- (void)meetingContentTextViewWillChangeHeight:(CPMettingEditViewController *)meeting withDiff:(float)diff;
@end

@interface CPMettingEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *mettingDateButton;
@property (weak, nonatomic) IBOutlet UIButton *mettingButton;
@property (weak, nonatomic) IBOutlet UIView *meetingContentLayoutView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *meetingContentLayoutViewHeight;

// 内容textview
@property (nonatomic)HPGrowingTextView* growingTextView;

@property (weak,nonatomic)id<CPMettingEditDelegate> delegate;

@end
