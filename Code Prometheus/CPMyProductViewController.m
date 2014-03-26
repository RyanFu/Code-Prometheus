//
//  CPMyProductViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-30.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPMyProductViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>
#import <Masonry.h>

static NSString* const TITLE_NIL = @"-";
static char CPAssociatedKeyProduct;

@interface CPProduct : NSObject
@property(nonatomic) NSString* productId;
@property(nonatomic) NSString* name;
@property(nonatomic) NSNumber* price;
@property(nonatomic) NSString* desc;
@property(nonatomic) NSString* room;
@end
@implementation CPProduct
@end

@interface CPMyProductViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentProductLabel;
@property (weak, nonatomic) IBOutlet UIView *productsLayoutView;
@property (nonatomic) NSArray* productsArray;

// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@property (nonatomic) NSString* selectProductId;
@end

@implementation CPMyProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    self.selectProductId = CPProductId;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        CPLogInfo(@"需重新加载数据,%@",self);
        [self requestProducts];
        self.dirty = NO;
    }
}

- (void)updateUI{
    if (CPMemberName) {
        self.currentProductLabel.text = CPMemberName;
    }else{
        self.currentProductLabel.text = TITLE_NIL;
    }
    UIView* lastRootView = nil;
    for (CPProduct* product in self.productsArray) {
        // 根view
        UIView* rootView = [UIView new];
        [self.productsLayoutView addSubview:rootView];
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
        objc_setAssociatedObject(myButton, &CPAssociatedKeyProduct, product, OBJC_ASSOCIATION_ASSIGN);
        [myButton addTarget:self action:@selector(changeProduct:) forControlEvents:UIControlEventTouchUpInside];
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
        // 产品名
        UILabel* productNameLabel = [[UILabel alloc] init];
        productNameLabel.font = [productNameLabel.font fontWithSize:14];
        [myButton addSubview:productNameLabel];
        productNameLabel.text = product.name;
        [productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right);
            make.centerY.equalTo(myButton.mas_centerY);
        }];
        // 空间
        UILabel* productRoomLabel = [[UILabel alloc] init];
        productRoomLabel.font = [productRoomLabel.font fontWithSize:14];
        [myButton addSubview:productRoomLabel];
        productRoomLabel.text = [NSString stringWithFormat:@"%@MB空间",product.room];
        [productRoomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(myButton.mas_centerX);
            make.centerY.equalTo(myButton.mas_centerY);
        }];
        // 价格
        UILabel* productPriceLabel = [[UILabel alloc] init];
        productPriceLabel.font = [productPriceLabel.font fontWithSize:14];
        [myButton addSubview:productPriceLabel];
        productPriceLabel.text = [NSString stringWithFormat:@"%@豆/月",product.price];
        [productPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
    for (UIView* rootView in [self.productsLayoutView subviews]) {
        UIControl* myButton = rootView.subviews.lastObject;
        CPProduct* product = objc_getAssociatedObject(myButton, &CPAssociatedKeyProduct);
        
        if ([self.selectProductId isEqualToString:product.productId]) {
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
-(void) requestProducts{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    [CPServer requestProduct:^(BOOL success, NSString *message, NSMutableArray *results) {
        if (success) {
            NSMutableArray* products = [NSMutableArray array];
            for (NSDictionary* dic in results) {
                CPProduct* product = [CPProduct new];
                product.productId = [dic objectForKey:@"productId"];
                product.name = [dic objectForKey:@"name"];
                product.price = [dic objectForKey:@"price"];
                product.desc = [dic objectForKey:@"desc"];
                product.room = [dic objectForKey:@"room"];
                [products addObject:product];
            }
            self.productsArray = [NSArray arrayWithArray:products];
            [self updateUI];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
        }
        [hud hide:YES];
    }];
}
- (IBAction)confirm:(id)sender {
    [[TWMessageBarManager sharedInstance] hideAll];
    if ([self.selectProductId isEqualToString:CPProductId]) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                       description:@"正在使用此套餐,未变更"
                                                              type:TWMessageBarMessageTypeInfo];
    }else{
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.removeFromSuperViewOnHide = YES;
        [self.view addSubview:hud];
        [hud show:YES];
        [CPServer changeProduct:self.selectProductId block:^(BOOL success, NSString *message) {
            if (success) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                               description:@"更改套餐成功"
                                                                      type:TWMessageBarMessageTypeSuccess];
            }else{
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                               description:message
                                                                      type:TWMessageBarMessageTypeError];
            }
            [hud hide:YES];
        }];
    }
}
- (void)changeProduct:(id)sender {
    CPProduct* product = objc_getAssociatedObject(sender, &CPAssociatedKeyProduct);
    self.selectProductId = product.productId;
    [self updateMyButton];
}
@end
