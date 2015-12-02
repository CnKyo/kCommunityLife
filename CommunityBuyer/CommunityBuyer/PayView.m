//
//  PayView.m
//  CommunityBuyer
//
//  Created by 周大钦 on 15/11/23.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import "PayView.h"
#import "PayStateVC.h"

@interface PayView (){

    NSString *payType;
    UIButton *btn;

}

@end

@implementation PayView

- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    self.mPageName = @"订单支付";
    self.Title = self.mPageName;
    
    [self loadPayView];
}

- (void)loadPayView{

    float height = 0;
    
//    UIView *contentView = [[UIView alloc] init];
//    contentView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < [GInfo shareClient].mPayments.count; i++) {
        
        SPayment *payment = [[GInfo shareClient].mPayments objectAtIndex:i];
        
        UIButton *wxBT = [[UIButton alloc] initWithFrame:CGRectMake(0, height, DEVICE_Width, 55)];
        [_mPayView addSubview:wxBT];
        wxBT.tag = i;
        [wxBT addTarget:self action:@selector(choosePayClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imgV1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 39, 39)];
        [imgV1 sd_setImageWithURL:[NSURL URLWithString:payment.mIconName] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
        [wxBT addSubview:imgV1];
        
        UILabel *wxLB = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV1.frame)+10, 0, 200, 55)];
        wxLB.text = payment.mName;
        wxLB.textColor = COLOR(72, 63, 69);
        [wxBT addSubview:wxLB];
        
        UIImageView * checkIV2 = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_Width-47, 14, 27, 27)];
        checkIV2.tag = 100;
        [wxBT addSubview:checkIV2];
        if (payment.mDefault) {
            checkIV2.image = [UIImage imageNamed:@"quanhong"];
            payType = payment.mCode;
            btn = wxBT;
        }else{
            checkIV2.image = [UIImage imageNamed:@"quan"];
        }
        
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(wxBT.frame), DEVICE_Width-10, 0.5)];
        line2.backgroundColor = COLOR(208, 206, 204);
        [_mPayView addSubview:line2];
        
        
        height = CGRectGetMaxY(line2.frame);
        
    }
    
    _mPayViewHeight.constant = height;

    _mPayBT.layer.cornerRadius = 3;

}

- (void)choosePayClick:(id)sender {
    
    UIButton *btnn = sender;
    for (UIImageView *imgV in [btn subviews]) {
        
        if ([imgV isKindOfClass:[UIImageView class]] ) {
            
            if (imgV.tag == 100) {
                imgV.image = [UIImage imageNamed:@"quan"];
            }
            
        }
    }
    
    for (UIImageView *imgV in [btnn subviews]) {
        
        if ([imgV isKindOfClass:[UIImageView class]] ) {
            
            if (imgV.tag == 100) {
                imgV.image = [UIImage imageNamed:@"quanhong"];
            }
            
        }
    }
    
    
    
    SPayment *payment = [[GInfo shareClient].mPayments objectAtIndex:btnn.tag];
    payType = payment.mCode;
    
    btn = btnn;
}



- (void)goPay{
    
    if ([payType isEqualToString:@""]) {
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在支付..." maskType:SVProgressHUDMaskTypeNone];
    [_mTagOrder payIt:payType block:^(SResBase *retobj) {
        
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:@"支付成功"];
            [self performSelector:@selector(payOk) withObject:nil afterDelay:0.75f];
        }
        else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            [self performSelector:@selector(payNO) withObject:nil afterDelay:0.75f];
        }
        
        
    }];
}

-(void)payOk
{
    PayStateVC *pay = [[PayStateVC alloc] initWithNibName:@"PayStateVC" bundle:nil];
    pay.mTOrder = _mTagOrder;
    pay.mIsOK = YES;
    pay.mPayType = payType;
    
    [self pushViewController:pay];
    
}

- (void)payNO{
    PayStateVC *pay = [[PayStateVC alloc] initWithNibName:@"PayStateVC" bundle:nil];
    pay.mTOrder = _mTagOrder;
    pay.mIsOK = NO;
    pay.mPayType = payType;
    [self pushViewController:pay];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)mGoPayClick:(id)sender {
    
    [self goPay];
}
@end
