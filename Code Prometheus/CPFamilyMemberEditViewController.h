//
//  CPFamilyMemberEditViewController.h
//  Code Prometheus
//
//  Created by mirror on 13-12-5.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPFamilyMemberEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *familyMemberNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *familyButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *familySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *familyBirthdayButton;
@end
