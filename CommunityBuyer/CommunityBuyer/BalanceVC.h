//
//  BalanceVC.h
//  CommunityBuyer
//
//  Created by 周大钦 on 15/9/24.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailTextView.h"

@interface BalanceVC : BaseVC

@property (nonatomic,strong) SCarSeller *mCarSeller;
@property (nonatomic,strong) NSMutableArray *mGoodsAry;

@property (weak, nonatomic) IBOutlet UILabel *mName;
@property (weak, nonatomic) IBOutlet UILabel *mPhone;
@property (weak, nonatomic) IBOutlet UILabel *mAddress;

@property (weak, nonatomic) IBOutlet UIView *mImgBgView;
@property (weak, nonatomic) IBOutlet UILabel *mNum;

@property (weak, nonatomic) IBOutlet UILabel *mPeisonText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mPeiSonViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *mTimeText;
@property (weak, nonatomic) IBOutlet UILabel *mPeison;


@property (weak, nonatomic) IBOutlet UILabel *mTime;

@property (weak, nonatomic) IBOutlet UITextField *mHeKa;
@property (weak, nonatomic) IBOutlet UITextField *mFaPiao;
@property (weak, nonatomic) IBOutlet UITextField *mBeiZhu;

@property (weak, nonatomic) IBOutlet UILabel *mPrice;
@property (weak, nonatomic) IBOutlet UILabel *mYunFei;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mYunFeiHeight;


@property (weak, nonatomic) IBOutlet UILabel *mHeJi;
@property (weak, nonatomic) IBOutlet UILabel *mSystempayTime;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mPayViewHeight;
@property (weak, nonatomic) IBOutlet UIView *mPayView;
@property (weak, nonatomic) IBOutlet UILabel *mNoAddress;

@property (weak, nonatomic) IBOutlet UILabel *SumPrice;
- (IBAction)GoAddressClick:(id)sender;

- (IBAction)GoPayClick:(id)sender;
- (IBAction)mTimeClick:(id)sender;

@end
