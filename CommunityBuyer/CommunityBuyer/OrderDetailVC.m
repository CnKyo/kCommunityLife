//
//  OrderDetailVC.m
//  CommunityBuyer
//
//  Created by 周大钦 on 15/9/24.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import "OrderDetailVC.h"
#import "GoodsView.h"
#import "PayStateVC.h"
#import "CmmVC.h"
#import "PayView.h"
#import "RestaurantDetailVC.h"
#import "ServiceDetailVC.h"

@interface OrderDetailVC ()<UIAlertViewDelegate,UITextFieldDelegate>{
        
    NSString *str;
    UIButton *tempBT;
}

@end

@implementation OrderDetailVC

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

+(void)gotoOrderDetailWithOrderId:(int)orderId vc:(UIViewController*)vc
{
    SOrderObj* tt  = SOrderObj.new;
    tt.mId = orderId;
    
    [SVProgressHUD showWithStatus:@"正在获取订单信息" maskType:SVProgressHUDMaskTypeClear];
    [tt getDetail:^(SResBase *resb) {
        
        if (resb.msuccess) {
            [SVProgressHUD dismiss];
            [OrderDetailVC whereToGo:tt vc:vc];
        }
        else [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
}

+(OrderDetailVC*)whichVC:(SOrderObj*)order
{
    OrderDetailVC *orderDetail = nil;
    
    
    orderDetail = [[OrderDetailVC alloc] initWithNibName:@"OrderDetailNewVC" bundle:nil];

    
    return orderDetail;
}
+(void)whereToGo:(SOrderObj*)order vc:(UIViewController*)vc
{
    OrderDetailVC *orderDetail = [self whichVC:order];
    
    orderDetail.mTagOrder = order;
    [vc.navigationController pushViewController:orderDetail animated:YES];
}

- (void)leftBtnTouched:(id)sender{

    [self popToRootViewController];
}



- (void)viewDidLoad {
    
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    self.mPageName = @"订单详情";
    self.Title = self.mPageName;
//    self.rightBtnImage = [UIImage imageNamed:@"hongphone"];
    
    
    [self loadData];
}

- (void)loadData{
    
    [self addMEmptyView:self.view rect:CGRectZero];
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
    if( _mTagOrder != nil )
    {
        [_mTagOrder getDetail:^(SResBase *retobj) {
            
            if (retobj.msuccess) {
                [SVProgressHUD dismiss];
                [self updatePageInfo];
                [self removeMEmptyView];
            }
            else {
                
                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                
            }
        }];
    }
    else
    {
        _mTagOrder = SOrderObj.new;
        _mTagOrder.mId = _mOrderId;
        [_mTagOrder getDetail:^(SResBase *retobj) {
            if (retobj.msuccess) {
                [SVProgressHUD dismiss];
                [self updatePageInfo];
                [self removeMEmptyView];
            }else{
                
                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            }
        }];
    }
    
}

- (void)updatePageInfo{
    
    [self updateTopView];
    
    [self updateMiddleView];
    
    [self updateBotomView];
    
    
    
}

- (void)updateTopView{
    
    [_mTopImg sd_setImageWithURL:[NSURL URLWithString:_mTagOrder.mStatusFlowImage] placeholderImage:[UIImage imageNamed:@"DefaultBanner"]];

    
    _mOrderState.text = [NSString stringWithFormat:@"订单状态 %@          ",_mTagOrder.mOrderStatusStr];
    _mOrderState.layer.masksToBounds = YES;
    _mOrderState.layer.cornerRadius = 10;
    
    if (_mTagOrder.mOrderType == 2){
        _mServiceName.text = [NSString stringWithFormat:@"服务人员：%@",_mTagOrder.mStaffName];
    }else{
        _mServiceName.text = [NSString stringWithFormat:@"配送人员：%@",_mTagOrder.mStaffName];
    }
    _mCuiDanBT.layer.cornerRadius = 3;
    _mCuiDanBT.layer.borderWidth = 0.8;
    _mCuiDanBT.layer.borderColor = COLOR(225, 228, 228).CGColor;
    if (_mTagOrder.mIsCanReminder) {
        _mCuiDanBT.hidden = NO;
    }else{
        _mCuiDanBT.hidden = YES;
    }

    _mSellerName.text = _mTagOrder.mSellerName;
    
    
    _mLxkfBT.layer.cornerRadius = 3;
    _mLxkfBT.layer.borderWidth = 0.8;
    _mLxkfBT.layer.borderColor = COLOR(225, 228, 228).CGColor;
    
    _mLxsjBT.layer.cornerRadius = 3;
    _mLxsjBT.layer.borderWidth = 0.8;
    _mLxsjBT.layer.borderColor = COLOR(225, 228, 228).CGColor;


}

- (void)CallClick:(UITapGestureRecognizer *)sender{
    
    NSMutableString * mobile=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_mTagOrder.mStaffMobile];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobile]];
}

- (void)CallClick2:(UITapGestureRecognizer *)sender{
    
    NSMutableString * mobile=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_mTagOrder.mSellerTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobile]];
}

- (void)updateMiddleView{

    float price = 0;
    
    for (int i = 0; i < _mTagOrder.mCartSellers.count; i++) {
        
        SCarSeller *scarSeller = _mTagOrder.mCartSellers[i];
        GoodsView *goodsView = [GoodsView shareView];
        CGRect rect = goodsView.frame;
        rect.origin.y = rect.size.height*i;
        rect.size.width = DEVICE_Width;
        goodsView.frame = rect;
        
        goodsView.mName.text = scarSeller.mGoodsName;
        goodsView.mNum.text = [NSString stringWithFormat:@"X%d",scarSeller.mNum];
        goodsView.mPrice.text = [NSString stringWithFormat:@"¥%.2f",scarSeller.mPrice];
        
        [_mGoodsView addSubview:goodsView];
        
        price += scarSeller.mPrice;
    }
    
    _mGoodsViewHeight.constant = _mTagOrder.mCartSellers.count*48;
    
    _mYunFeiPrice.text = [NSString stringWithFormat:@"¥%.2f",_mTagOrder.mFreight];
    
    _mSumPrice.text = [NSString stringWithFormat:@"¥%.2f",_mTagOrder.mTotalFee];}



- (void)updateBotomView{

    _mName.text = [NSString stringWithFormat:@"收货人：%@",_mTagOrder.mName];
    _mPhone.text = [NSString stringWithFormat:@"电     话：%@",_mTagOrder.mMobile];
    _mPayType.text = [NSString stringWithFormat:@"支付方式：%@",_mTagOrder.mPayType];
    _mPlayOrderTime.text = [NSString stringWithFormat:@"顾客下单时间：%@",_mTagOrder.mCreateTime];
    _mArriveTime.text = [NSString stringWithFormat:@"预约到达时间：%@",_mTagOrder.mAppTime];
    _mAddress.text = _mTagOrder.mAddress;
    _mOrderSn.text = [NSString stringWithFormat:@"订单编号：%@", _mTagOrder.mSn];
    if (_mTagOrder.mBuyRemark.length <= 0) {
        _mRemark.text =@"无";
    }else{
        _mRemark.text =_mTagOrder.mBuyRemark;
    }
    
    _mLeftBT.layer.cornerRadius = 3;
    _mRightBT.layer.cornerRadius = 3;
    _mOneBT.layer.cornerRadius = 3;
    
    NSMutableArray *statuAry =  NSMutableArray.new;
    SEL selectorAry[6];
    int index = 0;
    
    if (_mTagOrder.mIsCanDelete) {//删除订单
        
        [statuAry addObject:@"删除订单"];
        selectorAry[index] = @selector(deleteAction);
        index++;
    }
    if (_mTagOrder.mIsCanRate) {//评价
        
        [statuAry addObject:@"评价"];
        selectorAry[index] = @selector(PingjiaAction);
        index++;
    }
    if (_mTagOrder.mIsCanCancel) {//取消订单
        
        [statuAry addObject:@"取消订单"];
        selectorAry[index] = @selector(cancelAction);
        index++;
    }
    if (_mTagOrder.mIsCanPay) {//去支付
        
        [statuAry addObject:@"去支付"];
        selectorAry[index] = @selector(GoPayAction);
        index++;
        
    }
    if (_mTagOrder.mIsCanConfirm) {//确认完成
         [statuAry addObject:@"确认完成"];
        selectorAry[index] = @selector(comfirmAction);
        index++;
    }

    
    if(((_mTagOrder.mIsCanDelete || _mTagOrder.mIsCanRate) && statuAry.count<2) || statuAry.count == 0){
    
        [statuAry addObject:@"去逛逛"];
        selectorAry[index] = @selector(deleteAction);
        index++;
    }
    
    
    if(statuAry.count == 2){
        
        _mLeftBT.hidden = NO;
        _mRightBT.hidden = NO;
        _mOneBT.hidden = YES;
        [_mLeftBT setTitle:[statuAry objectAtIndex:0] forState:UIControlStateNormal];
        [_mLeftBT addTarget:self action:selectorAry[0] forControlEvents:UIControlEventTouchUpInside];
        
        [_mRightBT setTitle:[statuAry objectAtIndex:1] forState:UIControlStateNormal];
        [_mRightBT addTarget:self action:selectorAry[1] forControlEvents:UIControlEventTouchUpInside];
        
        
    }else if (statuAry.count == 1){
    
        _mLeftBT.hidden = YES;
        _mRightBT.hidden = YES;
        _mOneBT.hidden = NO;
        
        [_mOneBT setTitle:[statuAry objectAtIndex:0] forState:UIControlStateNormal];
        [_mOneBT addTarget:self action:selectorAry[0] forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)deleteAction{
    //删除订单
    
    [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeClear];
    [_mTagOrder deleteThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            [self popToRootViewController];
            
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];
    
    
}

//取消订单
- (void)cancelAction{
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入取消理由" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    //    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //得到输入框
    //    UITextField *tf=[alertView textFieldAtIndex:0];
    
    if (buttonIndex == 0) {
        
        [SVProgressHUD showWithStatus:@"正在取消..." maskType:SVProgressHUDMaskTypeClear];
        [_mTagOrder cancelThis:str block:^(SResBase *resb) {
            if( resb.msuccess )
            {
                [SVProgressHUD showSuccessWithStatus:resb.mmsg];
                
                [self updatePageInfo];
            }
            else
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            
        }];
        
    }else{
        
        return;
    }
}

//评价订单
- (void)PingjiaAction{
    
    CmmVC* vc = [[CmmVC alloc]initWithNibName:@"CmmVC" bundle:nil];
    vc.mtagOrder = self.mTagOrder;
    [self pushViewController:vc];
}

//去支付
- (void)GoPayAction{

    PayView *payV = [[PayView alloc] initWithNibName:@"PayView" bundle:nil];
    payV.mTagOrder = _mTagOrder;
    [self pushViewController:payV];
}

//确认完成
- (void)comfirmAction{

    [SVProgressHUD showWithStatus:@"正在确认完成..." maskType:SVProgressHUDMaskTypeClear];
    
    [_mTagOrder confirmThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:@"操作成功"];
            
            [self updatePageInfo];
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];
    
    
}

//去逛逛
- (void)GoAction{

    self.tabBarController.selectedIndex = 0;
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


- (void)tuiKuanAction{//申请退款

    [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeClear];
    [_mTagOrder deleteThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            [self popToRootViewController];
            
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];
    
}






- (IBAction)mCuidanClick:(id)sender {
    
    //确认完成
    [SVProgressHUD showWithStatus:@"正在催单..." maskType:SVProgressHUDMaskTypeClear];
    
    [_mTagOrder cuidanThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:@"催单成功"];
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];

    
}
- (IBAction)mSellerClick:(id)sender {
    
    
    if (_mTagOrder.mSellerType == 1) {
        
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        RestaurantDetailVC *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantDetailVC"];
        SSeller *seller = [[SSeller alloc] init];
        seller.mId = _mTagOrder.mSellerId;
        viewController.mSeller = seller;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        
        ServiceDetailVC *serviceVC = [[ServiceDetailVC alloc] init];
        
        SSeller *seller = [[SSeller alloc] init];
        seller.mId = _mTagOrder.mSellerId;
        serviceVC.mSeller = seller;
        [self pushViewController:serviceVC];
        
    }

}
- (IBAction)mLxkfClick:(id)sender {
    
    NSMutableString * string=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

- (IBAction)mLxsjClick:(id)sender {
    
    NSMutableString * string=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_mTagOrder.mSellerTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
@end
