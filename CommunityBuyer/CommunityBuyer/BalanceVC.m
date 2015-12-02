//
//  BalanceVC.m
//  CommunityBuyer
//
//  Created by 周大钦 on 15/9/24.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import "BalanceVC.h"
#import "DatePicker.h"
#import "PayStateVC.h"
#import "AddressVC.h"
#import "OrderDetailVC.h"

@interface BalanceVC (){

    UIButton *btn;
    
    float yue;
    UILabel *yueLB;
    NSString *payType;
    
    int num;
    float price;
    float yunPrice;
    
    SAddress *defaultAddress;
    
    DatePicker *datePic;
    
    SOrderObj *myOrder;
}

@end

@implementation BalanceVC

- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    
    [super viewDidLoad];
    
    self.mPageName = @"确认订单";
    self.Title = self.mPageName;
    
    self.mSystempayTime.text = [NSString stringWithFormat:@"请在下单后%@内完成支付",[GInfo shareClient].mSystemOrderPass];
    
    [self loadData];
    
    [self layoutPayView];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)loadData{

    
    defaultAddress = [SAddress loadDefault];
    
    if(!defaultAddress || defaultAddress == nil){
    
        _mNoAddress.hidden = NO;
        _mName.hidden = YES;
        _mPhone.hidden = YES;
        _mAddress.hidden = YES;
    }else{
        _mNoAddress.hidden = YES;
        _mName.hidden = NO;
        _mPhone.hidden = NO;
        _mAddress.hidden = NO;
        _mName.text = defaultAddress.mName;
        _mPhone.text = defaultAddress.mMobile;
        _mAddress.text = defaultAddress.mAddress;
    }
    
    
    num = 0;
    price = 0;
    
    
    for (SCarGoods *goods in _mGoodsAry) {
        
        num += goods.mNum;
        price += (goods.mPrice*goods.mNum);
        
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"共%d件",num]];
    
    [attriString addAttribute:NSForegroundColorAttributeName value:M_TCO range:NSMakeRange(0,1)];
    [attriString addAttribute:NSForegroundColorAttributeName value:M_TCO range:NSMakeRange(attriString.length-1,1)];
    
    _mNum.attributedText = attriString;
    
    for (UIImageView *imgV in _mImgBgView.subviews) {
        
        if ([imgV isKindOfClass:[UIImageView class]]) {
            
            for (int i = 0; i < _mGoodsAry.count; i++) {
                
                SCarGoods *goods = [_mGoodsAry objectAtIndex:i];
                
                if (imgV.tag -10 ==i) {
                    
                    [imgV sd_setImageWithURL:[NSURL URLWithString:goods.mLogo] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
                }
            }
        }
    }
    
    SCarGoods *goods = [_mGoodsAry objectAtIndex:0];
    
    
    [self setTextField:_mHeKa];
    [self setTextField:_mFaPiao];
    [self setTextField:_mBeiZhu];
    
    _mPrice.text = [NSString stringWithFormat:@"¥%.2f",price];
    _mYunFei.text = [NSString stringWithFormat:@"¥%.2f",_mCarSeller.mDeliveryFee];
    
    _SumPrice.text = [NSString stringWithFormat:@"¥%.2f",price+_mCarSeller.mDeliveryFee];
    _mHeJi.text = [NSString stringWithFormat:@"¥%.2f",price+_mCarSeller.mDeliveryFee];
    
    if (goods.mType == 2) {
        
        _mPeisonText.text = @"服务时间";
        _mTimeText.text = @"服务时间";
        _mPeiSonViewHeight.constant = 0;
        _mPeison.text = @"";
        _SumPrice.text = [NSString stringWithFormat:@"¥%.2f",price];
        _mYunFeiHeight.constant = 0;
        
        _mHeJi.text = [NSString stringWithFormat:@"¥%.2f",price];
        
    }


}

- (void)setTextField:(UITextField *)txf{

    txf.layer.borderColor = COLOR(206, 206, 207).CGColor;
    txf.layer.borderWidth = 0.5;
    
    
    CGRect frame = [txf frame];
    frame.size.width = 7.0f;
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    txf.leftViewMode = UITextFieldViewModeAlways;
    txf.leftView = leftview;
}

- (void)layoutPayView{

    float height = 0;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < [GInfo shareClient].mPayments.count; i++) {
        
        SPayment *payment = [[GInfo shareClient].mPayments objectAtIndex:i];
        
        UIButton *wxBT = [[UIButton alloc] initWithFrame:CGRectMake(0, height, DEVICE_Width, 55)];
        [contentView addSubview:wxBT];
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
        [contentView addSubview:line2];
        
        
        height = CGRectGetMaxY(line2.frame);
        
    }
    
    contentView.frame = CGRectMake(0, 40, DEVICE_Width, height);
    [_mPayView addSubview:contentView];
    
    _mPayViewHeight.constant = 40+height;
}



- (void)goPay:(SOrderObj *)order{
    
    if ([payType isEqualToString:@""]) {
        return;
    }

        [SVProgressHUD showWithStatus:@"正在支付..." maskType:SVProgressHUDMaskTypeNone];
        [order payIt:payType block:^(SResBase *retobj) {
            
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
    pay.mTOrder = myOrder;
    pay.mIsOK = YES;
    pay.mPayType = payType;
    
    [self pushViewController:pay];
    
}

- (void)payNO{
    PayStateVC *pay = [[PayStateVC alloc] initWithNibName:@"PayStateVC" bundle:nil];
    pay.mTOrder = myOrder;
    pay.mPayType = payType;
    pay.mIsOK = NO;
    [self pushViewController:pay];
    
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

- (IBAction)GoAddressClick:(id)sender {
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddressVC *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
    
    viewController.itblock = ^(SAddress* retobj){
        if( retobj )
        {
            
            defaultAddress  = retobj;
            
            _mNoAddress.hidden = YES;
            _mName.hidden = NO;
            _mPhone.hidden = NO;
            _mAddress.hidden = NO;
            _mName.text = defaultAddress.mName;
            _mPhone.text = defaultAddress.mMobile;
            _mAddress.text = defaultAddress.mAddress;
            
            
        }
        
    };
    [self pushViewController:viewController];;
}

- (IBAction)GoPayClick:(id)sender {
    
    
    NSMutableArray *idAry = NSMutableArray.new;
    for (SCarGoods *goods in _mGoodsAry) {
        
        [idAry addObject:[NSString stringWithFormat:@"%d",goods.mId]];
    }
    
    [SVProgressHUD showWithStatus:@"处理中.." maskType:SVProgressHUDMaskTypeClear];
    
    if (myOrder) {
        [self goPay:myOrder];
    }
    
    [SOrderObj dealOneOrder:idAry addressId:defaultAddress.mId giftContent:_mHeKa.text invoiceTitle:_mFaPiao.text buyRemark:_mBeiZhu.text appTime:[Util getDataString:_mTime.text bfull:NO] block:^(SResBase *resb, SOrderObj *retobj) {
        
        if (resb.msuccess) {
            [SVProgressHUD dismiss];
            
            myOrder = retobj;
            
            if(myOrder.mIsCanPay){
                [self goPay:retobj];
            }else{
            
                [OrderDetailVC whereToGo:myOrder vc:self];
            }
            
            
        }else{
            
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
    }];
    

}

- (IBAction)mTimeClick:(id)sender {
    
    if (!datePic) {
        datePic = [[DatePicker alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
        datePic.backgroundColor = [UIColor whiteColor];
    }
    
    datePic.hidden = NO;
    
    [datePic SetTextFieldDate:_mTime];
    [datePic setDatePickerType:UIDatePickerModeDateAndTime dateFormat:@"yyyy-MM-dd hh:mm"];
    
    [datePic showInView:self.view];
    
    
}


@end
