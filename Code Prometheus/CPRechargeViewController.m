//
//  CPRechargeViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-30.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPRechargeViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>
#import <Masonry.h>
#import "AlixLibService.h"
#import "AlixPayResult.h"

static char CPAssociatedKeyRechargeItem;

@interface CPRechargeItem : NSObject
@property(nonatomic) NSString* itemId;
@property(nonatomic) NSString* title;
@property(nonatomic) NSNumber* price;
@property(nonatomic) NSNumber* amount;
@end
@implementation CPRechargeItem
@end

//@interface CPSign : NSObject
//@property(nonatomic) NSNumber* rechargeId;
//@property(nonatomic) NSString* signInfo;
//@property(nonatomic) NSString* sign;
//@end
//@implementation CPSign
//@end

@interface CPRechargeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *rechargeItemLayoutView;

@property (nonatomic) NSArray* rechargeItemArray;
// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@property (nonatomic) NSString* selectRechargeItemId;

@property (weak,nonatomic) MBProgressHUD* hud;

@property (nonatomic) BOOL needDisplayMessage;
@property (nonatomic) BOOL paySuccess;
@end

@implementation CPRechargeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self requestRechargeItem];
        self.dirty = NO;
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.needDisplayMessage) {
        if (self.paySuccess) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"YES"
                                                           description:@"交易成功"
                                                                  type:TWMessageBarMessageTypeSuccess];
        }else{
            //失败
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:@"交易失败"
                                                                  type:TWMessageBarMessageTypeError];
        }
        self.needDisplayMessage = NO;
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!CP_IS_IOS7_AND_UP) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
- (void)updateUI{
    UIView* lastRootView = nil;
    for (CPRechargeItem* rechargeItem in self.rechargeItemArray) {
        // 根view
        UIView* rootView = [UIView new];
        [self.rechargeItemLayoutView addSubview:rootView];
        if (lastRootView) {
            [rootView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastRootView.mas_bottom);
                make.left.equalTo(@0);
                make.right.equalTo(@0);
                make.height.equalTo(@44);
            }];
        }else{
            [rootView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.left.equalTo(@0);
                make.right.equalTo(@0);
                make.height.equalTo(@44);
            }];
        }
        lastRootView = rootView;
        // 单选按钮
        UIControl* myButton = [[UIControl alloc] init];
        objc_setAssociatedObject(myButton, &CPAssociatedKeyRechargeItem, rechargeItem, OBJC_ASSOCIATION_ASSIGN);
        [myButton addTarget:self action:@selector(changeRechargeItem:) forControlEvents:UIControlEventTouchUpInside];
        [rootView addSubview:myButton];
        [myButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        // 图片
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_RADIO_NO] highlightedImage:[UIImage imageNamed:CP_RESOURCE_IMAGE_RADIO_YES]];
        [myButton addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.centerY.equalTo(myButton.mas_centerY);
        }];
        // 需要豆数
        UILabel* amountLabel = [[UILabel alloc] init];
        amountLabel.font = [amountLabel.font fontWithSize:14];
        [myButton addSubview:amountLabel];
        amountLabel.text = [NSString stringWithFormat:@"%@豆",rechargeItem.amount];
        [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right);
            make.centerY.equalTo(myButton.mas_centerY);
        }];
        // 充值项描述
        UILabel* titleLabel = [[UILabel alloc] init];
        titleLabel.font = [titleLabel.font fontWithSize:14];
        [myButton addSubview:titleLabel];
        titleLabel.text = rechargeItem.title;
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(myButton.mas_centerX);
            make.centerY.equalTo(myButton.mas_centerY);
        }];
        // 价格
        UILabel* priceLabel = [[UILabel alloc] init];
        priceLabel.font = [priceLabel.font fontWithSize:14];
        [myButton addSubview:priceLabel];
        priceLabel.text = [NSString stringWithFormat:@"%d¥",[rechargeItem.price integerValue]/100];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-20));
            make.centerY.equalTo(myButton.mas_centerY);
        }];
    }
    if (lastRootView) {
        [lastRootView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
        }];
    }
    [self updateMyButton];
}
-(void) updateMyButton{
    for (UIView* rootView in [self.rechargeItemLayoutView subviews]) {
        UIControl* myButton = rootView.subviews.lastObject;
        CPRechargeItem* item = objc_getAssociatedObject(myButton, &CPAssociatedKeyRechargeItem);
        if ([self.selectRechargeItemId isEqualToString:item.itemId]) {
            for (UIView* subView in myButton.subviews) {
                if ([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView* imageView = (UIImageView*)subView;
                    imageView.highlighted = YES;
                }
                if ([subView isKindOfClass:[UILabel class]]) {
                    UILabel* label = (UILabel*)subView;
                    label.textColor = [UIColor blackColor];
                }
            }
        }else{
            for (UIView* subView in myButton.subviews) {
                if ([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView* imageView = (UIImageView*)subView;
                    imageView.highlighted = NO;
                }
                if ([subView isKindOfClass:[UILabel class]]) {
                    UILabel* label = (UILabel*)subView;
                    label.textColor = [UIColor grayColor];
                }
            }
        }
    }
}
-(void) requestRechargeItem{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    [CPServer requestRechargeItem:^(BOOL success, NSString *message, NSMutableArray *results) {
        if (success) {
            NSMutableArray* rechargeItems = [NSMutableArray array];
            for (NSDictionary* dic in results) {
                CPRechargeItem* rechargeItem = [CPRechargeItem new];
                rechargeItem.itemId = [dic objectForKey:@"itemId"];
                rechargeItem.title = [dic objectForKey:@"title"];
                rechargeItem.price = [dic objectForKey:@"price"];
                rechargeItem.amount = [dic objectForKey:@"amount"];
                [rechargeItems addObject:rechargeItem];
            }
            self.rechargeItemArray = [NSArray arrayWithArray:rechargeItems];
            [self updateUI];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
        }
        [hud hide:YES];
    }];
}
- (void)changeRechargeItem:(id)sender {
    CPRechargeItem* rechargeItem = objc_getAssociatedObject(sender, &CPAssociatedKeyRechargeItem);
    self.selectRechargeItemId = rechargeItem.itemId;
    [self updateMyButton];
}
- (IBAction)recharge:(id)sender {
    [[TWMessageBarManager sharedInstance] hideAll];
    if (!self.selectRechargeItemId) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                       description:@"请选择充值类型"
                                                              type:TWMessageBarMessageTypeError];
        return;
    }
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud = hud;
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    [CPServer requestRechargeCreateWithItemID:self.selectRechargeItemId block:^(BOOL success, NSString *message, NSNumber *rechargeId, NSString *signInfo, NSString *sign) {
        if (success) {
            NSString *appScheme = @"Code Prometheus";
            NSString* orderInfo = signInfo;
            NSString* signedStr = sign;
            NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                     orderInfo, signedStr, @"RSA"];
            CPLogInfo(@"请求支付宝 orderString:%@",orderString);
            [AlixLibService payOrder:orderString AndScheme:appScheme seletor:@selector(paymentResult:) target:self];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
            [hud hide:YES];
        }
    }];
}
//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    //结果处理
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
	if (result)
    {
		if (result.statusCode == 9000)
        {
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            //交易成功
//            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
//			id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(key);
//            
//			if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
//                
//			}
            self.needDisplayMessage = YES;
            self.paySuccess = YES;
            
        }
        else
        {
            //交易失败
            self.needDisplayMessage = YES;
            self.paySuccess = NO;
            
        }
    }
    else
    {
        //交易失败
        self.needDisplayMessage = YES;
        self.paySuccess = NO;
        
    }
    if (self.hud) {
        [self.hud hide:YES];
        self.hud = nil;
    }
}
@end
