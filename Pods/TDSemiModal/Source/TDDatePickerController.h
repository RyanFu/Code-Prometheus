//
//  TDDatePickerController.h
//
//  Created by Nathan  Reed on 30/09/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"TDSemiModal.h"


@interface TDDatePickerController : TDSemiModalViewController {
	// 623637646
	// 原始代码可能存在循环引用
	__weak id delegate;
	// id delegate;
	// 623637646
}
// 623637646
// 原始代码可能存在循环引用
@property (nonatomic, weak) id delegate;
// @property (nonatomic, strong) IBOutlet id delegate;
// 623637646
@property (nonatomic, strong) IBOutlet UIDatePicker* datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
// 623637646
// 添加默认日期功能
@property (nonatomic) NSDate* date;
// 623637646
-(IBAction)saveDateEdit:(id)sender;
-(IBAction)clearDateEdit:(id)sender;
-(IBAction)cancelDateEdit:(id)sender;

@end

@interface NSObject (TDDatePickerControllerDelegate)
-(void)datePickerSetDate:(TDDatePickerController*)viewController;
-(void)datePickerClearDate:(TDDatePickerController*)viewController;
-(void)datePickerCancel:(TDDatePickerController*)viewController;
@end

