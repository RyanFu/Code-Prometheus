//
//  CPFeedbackViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-31.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPFeedbackViewController.h"
#import <HPTextViewInternal.h>

@interface CPFeedbackViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet HPTextViewInternal *myTextView;

@end

@implementation CPFeedbackViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"意见反馈";
    // 内容textview
    self.myTextView.displayPlaceHolder = YES;
    [self.myTextView setPlaceholderColor:[UIColor lightGrayColor]];
    self.myTextView.placeholder = @"请在此输入您对保险助手的建议,限制1000个字";
    self.myTextView.layer.borderWidth = 1;
    self.myTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.myTextView.layer.cornerRadius = 8;
    self.myTextView.delegate = self;
}
- (IBAction)submit:(id)sender {
    
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    HPTextViewInternal* myTextView = (HPTextViewInternal*)textView;
    BOOL display = myTextView.displayPlaceHolder;
    if (textView.text==nil || [textView.text isEqualToString:@""]) {
        myTextView.displayPlaceHolder = YES;
    }else{
        myTextView.displayPlaceHolder = NO;
    }
    if (display != myTextView.displayPlaceHolder) {
        [myTextView setNeedsDisplay];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return [[textView text] length] - range.length + text.length <= 1000;
}
@end
