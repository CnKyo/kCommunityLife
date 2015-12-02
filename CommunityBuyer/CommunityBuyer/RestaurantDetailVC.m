//
//  RestaurantDetailVC.m
//  XiCheBuyer
//
//  Created by 周大钦 on 15/7/16.
//  Copyright (c) 2015年 zdq. All rights reserved.
//

#import "RestaurantDetailVC.h"
#import "LeftCell.h"
#import "RightCell.h"
#import "ShopCarView.h"
#import "JSBadgeView.h"
#import "DetailTextView.h"
#import "ChoseView.h"
#import "SellerDetailVC.h"
#import "ShopCarVC.h"
#import "BalanceVC.h"
#import "SellerDetailView.h"
#import "PingJiaCell.h"
#import "PingJiaHeadView.h"
#import "SellerView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <objc/runtime.h>
#import "ResSectionHeadView.h"
#import "ResSectionFooterView.h"

@interface RestaurantDetailVC ()<UITableViewDataSource,UITableViewDelegate>{

    LeftCell *tempCell;
    
    NSMutableArray *mainAry;
    
    int leftSelect;
    ResSectionHeadView *sectionHead;
    
    NSIndexPath *leftIndexPath;
    int sunNum;
    float sumPrice;
    
    UIView *maskView;
    
    UIScrollView *scrollView;
    BOOL isShowCar;
    JSBadgeView *badgeView;
    
    
    float heigth;
    float y;
    
    BOOL isCollect;
    int _FreePrice;
    
    
    ChoseView *choseView;
    
    UIButton *tempBT;
    
    int goCarNum;
    
    UIButton *tempBtn;
    int nowSelect;
    UIImageView *lineImage;
    
    UITableView *pjTableView;//评价列表
    NSArray *pjArray;
    
    SellerView *sellerView; //商家
    BOOL isLoadSeller;
    BOOL isLoadPj;
    
    SOrderRate *myRate;
    int pjSelect;
    UIButton *tempPjBT;
    NSMutableDictionary *tempDic;
    
    NSString *AdvString;
    PingJiaHeadView *sectionView;

}

@end

@implementation RestaurantDetailVC{

    BOOL isLoad;
}

- (void)viewWillAppear:(BOOL)animated{
    
//    if (!isLoad) {
    
        
       [self addMEmptyView:_mGoodsView rect:CGRectMake(0, 0, DEVICE_Width, DEVICE_InNavBar_Height-100)];
        
        sunNum =0;
        sumPrice = 0;
        
        [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
        [[SUser currentUser] getMyShopCar:^(SResBase *resb, NSArray *all) {
            [self headerEndRefresh];
            
            if (resb.msuccess) {
                
                mainAry = [[NSMutableArray alloc] initWithArray:all];
                int num = 0;
                for (SCarSeller *carseller in all) {
                    for (SCarGoods *cargoods in carseller.mCarGoods) {
                        
                        num += cargoods.mNum;
                    }
                }
                
                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
                if(num >0)
                    item.badgeValue = [NSString stringWithFormat:@"%d",num];
                else
                    item.badgeValue = nil;
                
                [self getGoods];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
            
        }];
        
//        isLoad = YES;
    
        
//    }
    
    
    
    
}

//获取商品列表
- (void)getGoods{
    
    
    [_mSeller getGoods:^(SResBase *info, NSArray *all){
        
        
        if (info.msuccess) {
            [SVProgressHUD dismiss];
            self.tempArray = [[NSMutableArray alloc] initWithArray:all];
//            self.tempArray = [[NSMutableArray alloc] init];
            
            
            NSLog(@"%@",self.tempArray);
            NSLog(@"%@",mainAry);
            
            if(self.tempArray.count >0){
            
                //遍历购物车
                for (SCarSeller *carSeller in mainAry) {
                    
                    if(carSeller.mId == _mSeller.mId){
                        
                        for(SCarGoods *carGoods in carSeller.mCarGoods){
                            
                            sunNum += carGoods.mNum;
                            sumPrice +=carGoods.mPrice*carGoods.mNum;
                            //遍历商品列表
                            for (SGoodsPack *pack in self.tempArray) {
                                
                                for (SGoods *goods in pack.mGoods) {
                                    
                                    if (goods.mId == carGoods.mGoodsId) {
                                        
                                        
                                        goods.mCount = carGoods.mNum;
                                        
                                    }
                                    
                                    [SCarSeller getCarInfoWithGoods:goods];//获取对应商品在购物车内数量
                                    
                                }
                            }
                        }
                        
                    }
                }
                
                UINib *nib = [UINib nibWithNibName:@"leftcell" bundle:nil];
                [self.tableView registerNib:nib forCellReuseIdentifier:@"leftcell"];
                
                
                UINib *nib2 = [UINib nibWithNibName:@"rightcell" bundle:nil];
                [self.tableView registerNib:nib2 forCellReuseIdentifier:@"rightcell"];
                
                UINib *nib3 = [UINib nibWithNibName:@"rightcell2" bundle:nil];
                [self.tableView registerNib:nib3 forCellReuseIdentifier:@"rightcell2"];
                
                _mLeftTableV.delegate = self;
                _mLeftTableV.dataSource = self;
                
                _mRightTableV.delegate = self;
                _mRightTableV.dataSource = self;
                
                
                if (self.tempArray.count>0) {
                    NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [_mLeftTableV selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                    
                    [_mRightTableV reloadData];
                }
                
                isLoad = YES;

                [self removeMEmptyView];
            }
            
            //加载数据
            [self loadData];
            
           
            
            
        }else{
            
            [SVProgressHUD showErrorWithStatus:info.mmsg];
            
        }
        
    }];
}

- (void)viewDidLoad {
    
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    
    leftSelect = 0;
    
    goCarNum = 0;
    pjSelect = 0;
    
    
    self.mPageName = (_mSeller.mName=nil?@"商家":_mSeller.mName);
    self.Title = self.mPageName;
    
    tempBtn = _mLeftBT;
    nowSelect  = 0 ;
    lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width/3-30, 3)];
    lineImage.backgroundColor = M_CO;
    lineImage.center = _mLeftBT.center;
    CGRect rect = lineImage.frame;
    rect.origin.y = 52;
    lineImage.frame = rect;
    [_mTopView addSubview:lineImage];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [SSeller getGongGao:_mSeller.mId block:^(SResBase *info, NSString *content) {
            
            _mAdv.text = content;
            AdvString = content;
        }];
        
    });
    
    
    _mLeftTableV.tableFooterView =  UIView.new;
    _mRightTableV.tableFooterView = UIView.new;
    

    
}

- (void)loadData{

    badgeView.layer.masksToBounds = YES;
    badgeView.layer.cornerRadius = 10;
    
    badgeView = [[JSBadgeView alloc] initWithParentView:_mCarBt alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgePositionAdjustment = CGPointMake(0, 5);
    badgeView.badgeStrokeWidth = 5;
    
    if(sunNum<=0){
        badgeView.hidden = YES;
    }else{
        badgeView.hidden = NO;
    }
    
    badgeView.badgeText = [NSString stringWithFormat:@"%d",sunNum];
    badgeView.badgeBackgroundColor = M_CO;
    _mSumPrice.text = [NSString stringWithFormat:@"¥%.2f元",sumPrice];
    
    if (sumPrice < _mSeller.mDeliveryFee) {
        [_mSuccess setTitle:[NSString stringWithFormat:@"差%.2f元起送",_mSeller.mDeliveryFee-sumPrice] forState:UIControlStateNormal];
    }else{
        [_mSuccess setTitle:@"选好了" forState:UIControlStateNormal];
    }
    
    if (_mSeller.mIsCollect) {
        
        self.rightBtnImage = [UIImage imageNamed:@"shoucang"];
        isCollect = YES;
    }else{
        self.rightBtnImage = [UIImage imageNamed:@"shoucangno"];
    }
    
    
    _mLeftTableV.backgroundColor = COLOR(240, 235, 234);
}

- (void)rightBtnTouched:(id)sender{
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:@"操作中" maskType:SVProgressHUDMaskTypeClear];
    
    [_mSeller favIt:^(SResBase *resb) {
       
        
        if (resb.msuccess) {
            
            isCollect = !isCollect;
            
            if (isCollect) {
                self.rightBtnImage = [UIImage imageNamed:@"shoucang"];
            }else{
                self.rightBtnImage = [UIImage imageNamed:@"shoucangno"];
            }
            
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
        }else{
        
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
}

#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    if (tableView == _mRightTableV) {
        
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        
        return pack.mGoods.count;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _mLeftTableV) {
        
        return [self.tempArray count];
        
    }else if (tableView == _mRightTableV){
        
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        
        if (pack.mGoods.count>0) {
            
            SGoods *goods = [pack.mGoods objectAtIndex:section];
            
            if (goods.mNorms.count>3 && !goods.mIsOpen) {
                return 3;
            }
            
             return goods.mNorms.count;
        }
        
        return 0;
    }
    
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",pjSelect];
    
    NSArray *arr = [tempDic objectForKey:key2];
    
    return [arr count];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (tableView == pjTableView) {

            return sectionView;
    }
    
    if (tableView == _mRightTableV) {
        
        sectionHead = [ResSectionHeadView shareView];
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        
        if (pack.mGoods.count>0) {
            SGoods *goods = [pack.mGoods objectAtIndex:section];
            
            sectionHead.mText.text = [NSString stringWithFormat:@"%@(%lu)",goods.mName,(unsigned long)goods.mNorms.count];
        }
        return sectionHead;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    if (tableView == _mRightTableV) {
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        if (pack.mGoods.count>0) {
            SGoods *goods = [pack.mGoods objectAtIndex:section];
            
            if (goods.mNorms.count>3) {
                
                ResSectionFooterView *footV = [ResSectionFooterView shareView];
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, 0.5)];
                line.backgroundColor = COLOR(196, 195, 201);
                [footV addSubview:line];
                
                
                footV.mNum.tag = section;
                [footV.mNum addTarget:self action:@selector(OpenClick:) forControlEvents:UIControlEventTouchUpInside];
                if (goods.mIsOpen) {
                    [footV.mNum setTitle:@"收起商品规格" forState:UIControlStateNormal];
                    footV.mJiantou.image = [UIImage imageNamed:@"huitopjiantou"];
                }else{
                    [footV.mNum setTitle:[NSString stringWithFormat:@"展开剩下%lu条",goods.mNorms.count-3] forState:UIControlStateNormal];
                    footV.mJiantou.image = [UIImage imageNamed:@"huiDownjiantou"];
                }
                
                return footV;
            }
        }
       
    }
    return nil;
}

- (void)OpenClick:(UIButton *)sender{

    SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
    
    SGoods *goods = [pack.mGoods objectAtIndex:sender.tag];
    
    goods.mIsOpen = !goods.mIsOpen;
    
    [_mRightTableV reloadData];

}

- (void)ChoseClick:(UIButton *)sender{

    pjSelect = (int)sender.tag-1;
    
    if (tempPjBT == sender) {
        return;
    }
    else
    {
        NSString *key1 = [NSString stringWithFormat:@"nowselectdata%d",pjSelect];
        
        if (![tempDic objectForKey:key1]) {
            [self.tableView headerBeginRefreshing];
        }
        else
        {
            if ([[tempDic objectForKey:key1] count]>0) {
                [self removeEmptyView];
                
                [self.tableView reloadData];
            }
            
        }
        
        [tempPjBT setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        [tempPjBT setBackgroundColor:[UIColor whiteColor]];
        tempPjBT.layer.borderWidth = 1;
        tempPjBT.layer.borderColor = COLOR(226, 226, 226).CGColor;
        
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sender setBackgroundColor:M_CO];
        sender.layer.borderWidth = 0;
        sender.layer.borderColor = [UIColor whiteColor].CGColor;
        tempPjBT = sender;
        
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (tableView == pjTableView) {
        return 60;
    }
    
    if (tableView == _mRightTableV) {
        return 35;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (tableView == _mRightTableV) {
        
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        if (pack.mGoods.count>0) {
            SGoods *goods = [pack.mGoods objectAtIndex:section];
            
            if (goods.mNorms.count>3) {
                return 35;
            }
        
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _mLeftTableV) {
        
        LeftCell *cell = (LeftCell *)[tableView dequeueReusableCellWithIdentifier:@"leftcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:cell.bounds];
//        imgV.image = [UIImage imageNamed:@"res_selectbg"];
        imgV.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = imgV;
        
        SGoodsPack *pack = [self.tempArray objectAtIndex:indexPath.row];
        
        cell.mName.text = pack.mName;
        
        if (indexPath.row == 0) {
            
            leftIndexPath = indexPath;
            
        }
       
        
        return cell;
        
    }else if (tableView == _mRightTableV){
    
        RightCell *cell;
        
        if (indexPath.row == 0) {
            cell = (RightCell *)[tableView dequeueReusableCellWithIdentifier:@"rightcell"];
        }else{
            cell = (RightCell *)[tableView dequeueReusableCellWithIdentifier:@"rightcell2"];
        }
        
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
       
        
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        
        if (pack.mGoods.count>0) {
            
            SGoods *goods = [pack.mGoods objectAtIndex:indexPath.section];
            
            SGoodsNorms *norm = [goods.mNorms objectAtIndex:indexPath.row];
            
            if (indexPath.row == 0) {
                [cell.mImg sd_setImageWithURL:[NSURL URLWithString:[goods.mImages objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
                cell.mName.text = goods.mName;
                cell.mPrice.text = [NSString stringWithFormat:@"¥%.2f",goods.mPrice];
                cell.mImg.layer.masksToBounds = YES;
                cell.mImg.layer.cornerRadius = 3;
            }else{
                cell.mPrice.text = [NSString stringWithFormat:@"¥%.2f",norm.mPrice];
                cell.mNormName.text = norm.mName;
            }
            
            if (norm.mId == 0) {
                norm.mCount = goods.mCount;
            }
            
            if (norm.mCount > 0) {
                cell.mDelButton.hidden = NO;
                cell.mNum.hidden = NO;
                cell.mNum.text = [NSString stringWithFormat:@"%d",norm.mCount];
            }else{
                cell.mDelButton.hidden = YES;
                cell.mNum.hidden = YES;
            }
            
            
            cell.mAddButton.tag = indexPath.row;
            cell.mAddButton.indexPath = indexPath;
            [cell.mAddButton addTarget:self action:@selector(AddClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.mDelButton.tag = indexPath.row;
            cell.mDelButton.indexPath = indexPath;
            [cell.mDelButton addTarget:self action:@selector(DelClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        return cell;
        
    }else if (tableView == pjTableView){
    
        PingJiaCell *cell = (PingJiaCell *)[tableView dequeueReusableCellWithIdentifier:@"pjcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",pjSelect];
        NSArray *arr = [tempDic objectForKey:key2];
        
        SOrderRateInfo *rate = [arr objectAtIndex:indexPath.row];
        
        [self initPingJiaCell:cell andRate:rate];
        
        return cell;
    }
   
    return nil;
}
char* g_asskey = "g_asskey";
- (void)initPingJiaCell:(PingJiaCell *)cell andRate:(SOrderRateInfo *)rate{

    [cell.mHeadImg sd_setImageWithURL:[NSURL URLWithString:rate.mAvatar] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
    cell.mName.text = rate.mUserName;
    cell.mTime.text = rate.mCreateTime;
    cell.mStarImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"xing_%d",rate.mStar]];
    cell.mContent.text = rate.mContent;
    cell.mReply.text = (rate.mReply=@""?@"":[NSString stringWithFormat:@"回复：%@",rate.mReply]);
    
    
    
    if( rate.mImages.count > 0 )
    {
        cell.mImgBgView.hidden = NO;
        if (rate.mImages.count>4) {
            cell.mImgViewHeight.constant = 95;
        }else{
            cell.mImgViewHeight.constant = 40;
        }
        
        for ( int  j = 0 ; j < 8; j++) {
            
            UIImageView * oneimg = (UIImageView *)[cell.mImgBgView viewWithTag:j+1];
            oneimg.image = nil;
            
            if (j < rate.mImages.count) {
                
                NSString* oneurl = rate.mImages[j];
                
                [oneimg sd_setImageWithURL:[NSURL URLWithString:oneurl] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
                
                if( !oneimg.userInteractionEnabled )
                {
                    oneimg.userInteractionEnabled  = YES;
                    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
                    [oneimg addGestureRecognizer:tap];
                }
                
                objc_setAssociatedObject(oneimg, g_asskey, nil, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(oneimg, g_asskey, rate, OBJC_ASSOCIATION_ASSIGN);
            }
            
        }
        
    }else{
        
        cell.mImgViewHeight.constant = 0;
        cell.mImgBgView.hidden = YES;
    }

}
-(void)imageClick:(UITapGestureRecognizer*)sender
{
    UIImageView* tagv = (UIImageView*)sender.view;
    
    SOrderRateInfo *rate = objc_getAssociatedObject(tagv, g_asskey);
    NSMutableArray* allimgs = NSMutableArray.new;
    for ( NSString* url in rate.mImages )
    {
        MJPhoto* onemj = [[MJPhoto alloc]init];
        onemj.url = [NSURL URLWithString:url ];
        onemj.srcImageView = tagv;
        [allimgs addObject: onemj];
    }
    
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
    browser.currentPhotoIndex = tagv.tag-1;
    browser.photos  = allimgs;
    [browser show];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == _mLeftTableV){
        
        leftIndexPath = indexPath;
        
        leftSelect = (int)indexPath.row;
        
        [_mRightTableV reloadData];
        
        NSLog(@"%d",leftSelect);
        
    }else if(tableView == _mRightTableV){
    
        
        SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
        
        SGoods *goods = [pack.mGoods objectAtIndex:indexPath.row];

        SellerDetailVC *seller = [[SellerDetailVC alloc] initWithNibName:@"SellerDetailVC" bundle:nil];
        seller.mGoods = goods;
        seller.mSeller = _mSeller;
        seller.mType = goods.mType;
        seller.mSumNum = sunNum;
        seller.mSumprice = sumPrice;
        [self pushViewController:seller];
    }
    
    
    
}

- (void)JiaClick:(CellButton *)sender{
    SGoodsNorms *norm;
    
    if (sender.mGoods.mNorms.count>1) {
        if (!tempBT) {
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择商品规格" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alt show];
            
            return;
        }
        
        int index = (int)tempBT.tag;
        norm = [sender.mGoods.mNorms objectAtIndex:index];
        sender.mGoods.mNormId = norm.mId;
        sender.mGoods.mCount = goCarNum;
    }


    goCarNum ++;
    choseView.mNum.text = [NSString stringWithFormat:@"%d",goCarNum];
}

- (void)JianClick:(CellButton *)sender{
    
    SGoodsNorms *norm;
    
    if (sender.mGoods.mNorms.count>1) {
        if (!tempBT) {
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择商品规格" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alt show];
            
            return;
        }
        
        int index = (int)tempBT.tag;
        norm = [sender.mGoods.mNorms objectAtIndex:index];
        sender.mGoods.mNormId = norm.mId;
        sender.mGoods.mCount = goCarNum;
    }

    
    if (goCarNum>0) {
        
        goCarNum --;
        choseView.mNum.text = [NSString stringWithFormat:@"%d",goCarNum];
    }
    
}

- (void)AddCarClick:(CellButton *)sender{
    
    SGoodsNorms *norm;
    
    if (sender.mGoods.mNorms.count>1) {
        if (!tempBT) {
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择商品规格" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alt show];
            
            return;
        }
        
        int index = (int)tempBT.tag;
        norm = [sender.mGoods.mNorms objectAtIndex:index];
        sender.mGoods.mNormId = norm.mId;
        sender.mGoods.mCount = goCarNum;
    }
    
    
    if (goCarNum<=0) {
        
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择商品数量" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alt show];
        
        return;
    }
    
    
    
    
    [SVProgressHUD showWithStatus:@"操作中.." maskType:SVProgressHUDMaskTypeClear];
    [sender.mGoods addToCart:norm.mId block:^(SResBase *info, NSArray *all){
        
        if (info.msuccess) {
            
            if (all.count >0) {
                
                
                sunNum = 0;
                sumPrice = 0;
                
                for (SCarSeller *carseller in all) {
                    
                    if( carseller.mId == _mSeller.mId )
                    {
                        for (SCarGoods *cargoods in carseller.mCarGoods) {
                            
                            sunNum += cargoods.mNum;
                            sumPrice += cargoods.mPrice*cargoods.mNum;
                        }
                    }
                }
                
                badgeView.hidden = NO;
                badgeView.badgeText = [NSString stringWithFormat:@"%d",sunNum];
                _mSumPrice.text = [NSString stringWithFormat:@"¥%.2f元",sumPrice];
                if (sumPrice < _mSeller.mDeliveryFee) {
                    [_mSuccess setTitle:[NSString stringWithFormat:@"差%.2f元起送",_mSeller.mDeliveryFee-sumPrice] forState:UIControlStateNormal];
                }else{
                    [_mSuccess setTitle:@"选好了" forState:UIControlStateNormal];
                }
                [_mRightTableV reloadData];

                
                
                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
                if(mainAry.count >0)
                    item.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[mainAry count]];
                else
                    item.badgeValue = nil;
            }
            
            [SVProgressHUD showSuccessWithStatus:info.mmsg];
            
            goCarNum = 0;
            [self closeChoseView];
        }else{
            
            [SVProgressHUD showErrorWithStatus:info.mmsg];
        }
    }];
   
}

- (void)BuyClick:(CellButton *)sender{
    
    
    if (goCarNum<=0) {
        
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择商品数量" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alt show];
        
        return;
    }
    SGoodsNorms *norm;
    if (sender.mGoods.mNorms.count>1) {
        int index = (int)tempBT.tag;
        norm = [sender.mGoods.mNorms objectAtIndex:index];
        
        sender.mGoods.mNormId = norm.mId;

    }
    
    sender.mGoods.mCount = goCarNum;
    
    [SVProgressHUD showWithStatus:@"操作中.." maskType:SVProgressHUDMaskTypeClear];
    [sender.mGoods addToCart:norm.mId block:^(SResBase *info, NSArray *all){
        
        if (info.msuccess) {
            [SVProgressHUD dismiss];
            
            
            
            if (all.count>0) {
                SCarSeller *carseller = [all objectAtIndex:0];
                
                
                NSMutableArray *goodsAry = NSMutableArray.new;
                
                
                for (SCarSeller *carseller in all) {
                    for (SCarGoods *cargoods in carseller.mCarGoods) {
                        
                        if (cargoods.mGoodsId == sender.mGoods.mId) {
                            
                            if (cargoods.mNum>0) {
                                [goodsAry addObject:cargoods];
                            }
                        }
                    }
                }
                
                
                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
                if(mainAry.count >0)
                    item.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[mainAry count]];
                else
                    item.badgeValue = nil;
                
                BalanceVC *balance = [[BalanceVC alloc] initWithNibName:@"BalanceVC" bundle:nil];
                balance.mGoodsAry = goodsAry;
                balance.mCarSeller = carseller;
                
                [self pushViewController:balance];

            }
            
            
//            [self closeChoseView];
        }else{
            
            [SVProgressHUD showErrorWithStatus:info.mmsg];
        }
    }];

    
}

- (void)delNum:(int)num andGoods:(SGoods *)goods andNorm:(SGoodsNorms *)norm{

        goods.mCount +=num;
        
        [SVProgressHUD showWithStatus:@"操作中" maskType:SVProgressHUDMaskTypeClear];
        [goods addToCart:norm.mId block:^(SResBase *info, NSArray *all){
            
            if (info.msuccess) {
                
                [SVProgressHUD dismiss];
                
                
                sunNum = 0;
                sumPrice = 0;
                
                if (all.count>0) {
                    
                    for (SCarSeller *seller in all) {
                        if( seller.mId == _mSeller.mId )
                        {
                            for (SCarGoods *goods in seller.mCarGoods) {
                                sunNum += goods.mNum;
                                sumPrice += goods.mPrice*goods.mNum;
                            }
                        }
                    }

                    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
                    if(mainAry.count >0)
                        item.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[mainAry count]];
                    else
                        item.badgeValue = nil;
                    
                    
                }
                badgeView.badgeText = [NSString stringWithFormat:@"%d",sunNum];
                _mSumPrice.text = [NSString stringWithFormat:@"¥%.2f元",sumPrice];
                
                if (sumPrice < _mSeller.mDeliveryFee) {
                    [_mSuccess setTitle:[NSString stringWithFormat:@"差%.2f元起送",_mSeller.mDeliveryFee-sumPrice] forState:UIControlStateNormal];
                }else{
                    [_mSuccess setTitle:@"选好了" forState:UIControlStateNormal];
                }
                
                [_mRightTableV reloadData];
                
            }else{
                
                goods.mCount -=num;
                
                [SVProgressHUD showErrorWithStatus:info.mmsg];
            }
        }];
    
    

}

- (void)AddClick:(CellButton *)sender{

    
    NSIndexPath *indexPath = sender.indexPath;
    
    SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
    
    SGoods *goods = [pack.mGoods objectAtIndex:indexPath.section];
    
    SGoodsNorms *norm = [goods.mNorms objectAtIndex:indexPath.row];
    
   [self delNum:1 andGoods:goods andNorm:norm];
    
//  [self layoutChoseView:goods];
    
    
}
- (void)DelClick:(CellButton *)sender{
    
     NSIndexPath *indexPath = sender.indexPath;
    
    SGoodsPack *pack = [self.tempArray objectAtIndex:leftSelect];
    
    SGoods *goods = [pack.mGoods objectAtIndex:indexPath.section];
    
    SGoodsNorms *norm = [goods.mNorms objectAtIndex:indexPath.row];
    

    [self delNum:-1 andGoods:goods andNorm:norm];
    
    
    
}


#pragma 评价
-(void)headerBeganRefresh
{
    self.page = 1;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    
    [SOrderRateInfo getComments:pjSelect page:self.page sellerId:_mSeller.mId block:^(SResBase *resb, NSArray *arr){
        
        
        [self.tableView headerEndRefreshing];
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",pjSelect];
            
            [tempDic setObject:arr forKey:key2];
            
            if (arr.count==0) {
                [self addEmptyViewWithImg:@"noitem"];
            }else
            {
                [self removeEmptyView];
            }
            
            [self.tableView reloadData];
        }
        else
        {
            [self addEmptyViewWithImg:@"noitem"];
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
    }];
    
}
-(void)footetBeganRefresh
{
    self.page++;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [SOrderRateInfo getComments:pjSelect page:self.page sellerId:_mSeller.mId block:^(SResBase *resb, NSArray *arr){
        
        
        [self.tableView footerEndRefreshing];
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",pjSelect];
            
            NSArray *arr2 = [tempDic objectForKey:key2];
            
            if (arr.count!=0) {
                [self removeEmptyView];
                
                
                NSMutableArray *array = [NSMutableArray array];
                if (arr2) {
                    [array addObjectsFromArray:arr2];
                }
                [array addObjectsFromArray:arr];
                [tempDic setObject:array forKey:key2];
            }else
            {
                if(!arr||arr.count==0)
                {
                    [SVProgressHUD showSuccessWithStatus:@"暂无数据"];
                }
                else
                    [SVProgressHUD showSuccessWithStatus:@"暂无新数据"];
                //   [self addEmptyView:@"暂无数据"];
                
            }
            
            [self.tableView reloadData];
            
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
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


- (IBAction)CarClick:(id)sender {
    
    if (sunNum <= 0) {
        [SVProgressHUD showErrorWithStatus:@"购物车为空"];
        return;
    }
    
    self.tabBarController.selectedIndex = 1;
    [self popToRootViewController];
    
}

- (IBAction)GoPlaceClick:(id)sender {
    
    if (sunNum <= 0) {
        [SVProgressHUD showErrorWithStatus:@"购物车为空"];
        return;
    }
    
    self.tabBarController.selectedIndex = 1;
    [self popToRootViewController];
}

- (IBAction)mTopClick:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    if (tempBtn == sender) {
        return;
    }
    else
    {
        if (button.tag ==10) {
            NSLog(@"left");
            nowSelect = 0;
            [self.view bringSubviewToFront:_mGoodsView];
        }
        else if(button.tag == 11)
        {
            nowSelect = 1;
            NSLog(@"mid");
            if (!isLoadPj) {
                [self loadPingJia];
            }else{
                 [self.view bringSubviewToFront:pjTableView];
            }
        }
        else
        {
            nowSelect = 2;
            NSLog(@"right");
            
            if (!isLoadSeller) {
                [self loadSellerDetail];
            }else{
                [self.view bringSubviewToFront:sellerView];
            }
            
        }
        
        [tempBtn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        [button setTitleColor:M_CO forState:UIControlStateNormal];
        
        tempBtn = button;
        
    }
    
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        lineImage.center = button.center;
        CGRect rect = lineImage.frame;
        rect.origin.y = 52;
        lineImage.frame = rect;
    }];

}

- (void)loadPingJia{

    tempDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    pjTableView = [[UITableView alloc] initWithFrame:_mGoodsView.frame];
    pjTableView.delegate = self;
    pjTableView.dataSource = self;
    [self.view addSubview:pjTableView];
    self.tableView = pjTableView;
    
    UINib *nib = [UINib nibWithNibName:@"PingJiaCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"pjcell"];
    
    PingJiaHeadView *headView = [PingJiaHeadView shareView];
    [self.tableView setTableHeaderView:headView];
    
    self.haveHeader = YES;
    self.haveFooter = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [SVProgressHUD showWithStatus:@"加载中.." maskType:SVProgressHUDMaskTypeClear];
    [SOrderRate getRateNum:_mSeller.mId block:^(SResBase *resb, SOrderRate *rate) {
        
        if (resb.msuccess) {
            
            [SVProgressHUD dismiss];
            
            myRate = rate;
            
            headView.mFen.text = [NSString stringWithFormat:@"%.2f",rate.mStar];
            NSString *string = [NSString stringWithFormat:@"daxingxing_%.1f",rate.mStar];
            headView.mXing.image = [UIImage imageNamed:string];
            
            isLoad = YES;
            [self loadSectionView];
            [pjTableView headerBeginRefreshing];
        }else{
        
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
    
    isLoadPj = YES;
}

- (void)loadSectionView{
    
    
    sectionView = [PingJiaHeadView shareView2];
    
    sectionView.mAllBT.layer.cornerRadius = 12;
    sectionView.mHaoBT.layer.cornerRadius = 12;
    sectionView.mZhongBT.layer.cornerRadius = 12;
    sectionView.mChaBT.layer.cornerRadius = 12;
    
    sectionView.mHaoBT.layer.borderWidth = 1;
    sectionView.mHaoBT.layer.borderColor = COLOR(226, 226, 226).CGColor;
    
    sectionView.mZhongBT.layer.borderWidth = 1;
    sectionView.mZhongBT.layer.borderColor = COLOR(226, 226, 226).CGColor;
    
    sectionView.mChaBT.layer.borderWidth = 1;
    sectionView.mChaBT.layer.borderColor = COLOR(226, 226, 226).CGColor;
    
    
    [sectionView.mAllBT setTitle:[NSString stringWithFormat:@"全部(%d)",myRate.mTotalCount] forState:UIControlStateNormal];
    [sectionView.mHaoBT setTitle:[NSString stringWithFormat:@"好评(%d)",myRate.mGoodCount] forState:UIControlStateNormal];
    [sectionView.mZhongBT setTitle:[NSString stringWithFormat:@"中评(%d)",myRate.mNeutralCount] forState:UIControlStateNormal];
    [sectionView.mChaBT setTitle:[NSString stringWithFormat:@"差评(%d)",myRate.mBadCount] forState:UIControlStateNormal];
    
    [sectionView.mAllBT addTarget:self action:@selector(ChoseClick:) forControlEvents:UIControlEventTouchUpInside];
    [sectionView.mHaoBT addTarget:self action:@selector(ChoseClick:) forControlEvents:UIControlEventTouchUpInside];
    [sectionView.mZhongBT addTarget:self action:@selector(ChoseClick:) forControlEvents:UIControlEventTouchUpInside];
    [sectionView.mChaBT addTarget:self action:@selector(ChoseClick:) forControlEvents:UIControlEventTouchUpInside];
    
    tempPjBT = sectionView.mAllBT;
}

- (void)loadSellerDetail{
    
    

    sellerView  = [SellerView shareView];
    sellerView.frame = _mGoodsView.frame;
    [self.view addSubview:sellerView];
    
    [sellerView.mCallBT addTarget:self action:@selector(CallClick:) forControlEvents:UIControlEventTouchUpInside];
    isLoadSeller = YES;
    
    sellerView.mImg.layer.masksToBounds = YES;
    sellerView.mImg.layer.cornerRadius = 35;
    
    [_mSeller getDetail:^(SResBase *info) {
        if (info.msuccess) {
            
            [sellerView.mImg sd_setImageWithURL:[NSURL URLWithString:_mSeller.mLogo] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
            sellerView.mName.text = [NSString stringWithFormat:@"%@",_mSeller.mName];
            
            sellerView.mTime.text = [NSString stringWithFormat:@"%@",_mSeller.mBusinessHours];
            
            
            sellerView.mQPrice.text = [NSString stringWithFormat:@"¥%.2f",_mSeller.mDeliveryFee];
            sellerView.mPPrice.text = [NSString stringWithFormat:@"¥%.2f",_mSeller.mServiceFee];
            sellerView.mPhone.text = [NSString stringWithFormat:@"%@",_mSeller.mMobile];
            sellerView.mAddress.text = _mSeller.mAddress;
            sellerView.mAdv.text = AdvString;
           
            [sellerView.mBgImg sd_setImageWithURL:[NSURL URLWithString:_mSeller.mImage] placeholderImage:[UIImage imageNamed:@"sellerBg"]];
            
            if ([_mSeller.mDetail isEqualToString:@""]) {
                sellerView.mRemark.text = @"暂无介绍";
            }else{
                sellerView.mRemark.text = _mSeller.mDetail;
            }

        }
    }];
}


-(void)layoutChoseView:(SGoods *)goods
{
    
    [SCarSeller getCarInfoWithGoods:goods];//获取对应商品在购物车内数量
    
    CGRect rect = self.view.bounds;
    rect.size.height -=50;
    maskView = [[UIView alloc]initWithFrame:rect];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.0;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeChoseView)];
    [maskView addGestureRecognizer:ges];
    [self.view addSubview:maskView];
 
    choseView = [ChoseView shareView];
    [choseView.mImg sd_setImageWithURL:[NSURL URLWithString:[goods.mImages objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
    NSString *str = @"";
    float xx = 0;
    float yy = 0;
    float height = 0;
    if(goods.mNorms.count>1){
        
        SGoodsNorms *norm = [goods.mNorms objectAtIndex:0];
        choseView.mPrice.text = [NSString stringWithFormat:@"¥%.2f",norm.mPrice];
        choseView.mNumKu.text = [NSString stringWithFormat:@"库存%d件",norm.mStock];

        for (int i = 0;i < goods.mNorms.count;i++) {
            
            SGoodsNorms *norm = [goods.mNorms objectAtIndex:i];
            
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ ",norm.mName]];
            
            
            if (xx+ norm.mName.length*15+20 >DEVICE_Width-23) {
                
                xx = 0 ;
                yy +=40;
            }
            
            CellButton *button = [[CellButton alloc] initWithFrame:CGRectMake(xx, yy, norm.mName.length*15+20, 30)];
            button.mGoods = goods;
            [button setTitle:norm.mName forState:UIControlStateNormal];
            [button setTitleColor:COLOR(107, 107, 109) forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor whiteColor]];
            button.layer.borderColor = COLOR(107, 107, 109).CGColor;
            button.layer.borderWidth = 0.5;
            button.tag = i;
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button addTarget:self action:@selector(GuigeClick:) forControlEvents:UIControlEventTouchUpInside];
            
            xx += button.frame.size.width+15;
            
            [choseView.mGuigeView addSubview:button];
            
        }
        height = yy+30;
    }
    choseView.mGuigeHeight.constant = height;
    
    choseView.mGuige.text = [NSString stringWithFormat:@"请选择%@",str];
    
    choseView.mJiaBT.mGoods = goods;
    [choseView.mJiaBT addTarget:self action:@selector(JiaClick:) forControlEvents:UIControlEventTouchUpInside];
    choseView.mJianBT.mGoods = goods;
    [choseView.mJianBT addTarget:self action:@selector(JianClick:) forControlEvents:UIControlEventTouchUpInside];
    choseView.mJiaCar.mGoods = goods;
    [choseView.mJiaCar addTarget:self action:@selector(AddCarClick:) forControlEvents:UIControlEventTouchUpInside];
    
    choseView.mBuy.mGoods = goods;
    [choseView.mBuy addTarget:self action:@selector(BuyClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    choseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:choseView];
    CGRect rect2 = choseView.frame;
    rect2.origin.y = DEVICE_Height;
    rect2.size.width = DEVICE_Width;
    rect2.size.height +=(height-35);
    choseView.frame = rect2;
    
    [choseView.mClose addTarget:self action:@selector(closeChoseView) forControlEvents:UIControlEventTouchUpInside];
   
    
    [UIView animateWithDuration:0.2 animations:^{
        maskView.alpha = 0.5;
        CGRect rect2 = choseView.frame;
        rect2.origin.y = DEVICE_Height-rect2.size.height;
        choseView.frame = rect2;
        
       
    }];
    
    isShowCar = YES;
}

- (void)GuigeClick:(CellButton *)sender{
    
    tempBT.layer.borderColor = COLOR(107, 107, 109).CGColor;
    tempBT.layer.borderWidth = 0.5;
    [tempBT setTitleColor:COLOR(107, 107, 109) forState:UIControlStateNormal];
    [tempBT setBackgroundColor:[UIColor whiteColor]];
    
    sender.layer.borderWidth = 0;
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setBackgroundColor:M_CO];
   
    SGoodsNorms *norm = [sender.mGoods.mNorms objectAtIndex:sender.tag];
    choseView.mNum.text = [NSString stringWithFormat:@"%d",norm.mCount];
    goCarNum = norm.mCount;
    tempBT = sender;
}



-(void)closeChoseView
{
    
    [UIView animateWithDuration:0.2 animations:^{
        //     EditTempBtn = nil;
        maskView.alpha = 0.0f;
        CGRect rect = choseView.frame;
        rect.origin.y = DEVICE_Height+50;
        choseView.frame =rect;
        
    } completion:^(BOOL finished) {
        [choseView removeFromSuperview];
        [maskView removeFromSuperview];
        tempBT = nil;
        
        [_mRightTableV reloadData];
    }];
    
    isShowCar = NO;
    
}


















@end
