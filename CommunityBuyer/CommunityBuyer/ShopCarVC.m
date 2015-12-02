//
//  ShopCarVC.m
//  CommunityBuyer
//
//  Created by 周大钦 on 15/9/22.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import "ShopCarVC.h"
#import "ShopCarCell.h"
#import "AddressCell.h"
#import "ShopCarHeadView.h"
#import "ShopCarFooterView.h"
#import "AddressVC.h"
#import "BalanceVC.h"

@interface ShopCarVC ()<UITableViewDataSource,UITableViewDelegate>{

    SAddress *DefaultAddress;
    ShopCarFooterView *headView;
}

@end

@implementation ShopCarVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hiddenBackBtn = YES;
    
    self.mPageName = @"购物车";
    self.Title = self.mPageName;
    
   
    self.rightBtnImage = [UIImage imageNamed:@"lajitong"];
    
    [self loadTableView:CGRectMake(0, 64, DEVICE_Width, DEVICE_InNavTabBar_Height) delegate:self dataSource:self];
    
    self.haveHeader = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UINib *nib2 = [UINib nibWithNibName:@"ShopCarCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"cell1"];
    
    
    UINib *nib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"addressCell"];
    
    DefaultAddress = [SAddress loadDefault];
    
    [self.tableView headerBeginRefreshing];
    [self addDataChangeNotif];
}

-(void)addDataChangeNotif
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doreload:) name:@"ShopCarChanged" object:nil];
}
-(void)doreload:(id)sender
{
    [self.tableView headerBeginRefreshing];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)rightBtnTouched:(id)sender{

    [SVProgressHUD showWithStatus:@"操作中.." maskType:SVProgressHUDMaskTypeClear];
    
    [SCarSeller clearCarInfo:^(SResBase *resb) {
      
        if (resb.msuccess) {
            [SVProgressHUD dismiss];
            [self.tableView headerBeginRefreshing];
            
            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
            item.badgeValue = nil;
        }else{
        
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
}

-(void)headerBeganRefresh
{
    
    
    
    
    [SVProgressHUD showWithStatus:@"加载中.." maskType:SVProgressHUDMaskTypeClear];
    [[SUser currentUser] getMyShopCar:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];

        if (resb.msuccess) {
            
            [SVProgressHUD dismiss];
            
            self.tempArray = [[NSMutableArray alloc] initWithArray:all];
            
            
            if (all.count==0) {
                [self addEmptyViewWithImg:@"noitem"];
            }else
            {
                [self removeEmptyView];
            }
            
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
            
            [self.tableView reloadData];
            
            
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if ( all.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        
        [self.tableView reloadData];
        
    }];
    
    
}


#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return self.tempArray.count+1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.tempArray.count>0) {
            return 1;
        }else{
            return 0;
        }
        
    }
    SCarSeller *car = [self.tempArray objectAtIndex:section-1];
    return car.mCarGoods.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 0) {
        return 0;
    }
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section ==0) {
        return nil;
    }

    SCarSeller *car = [self.tempArray objectAtIndex:section-1];
    
    ShopCarHeadView *view = [ShopCarHeadView shareView];
    view.mCheck.tag = section-1;
    [view.mCheck addTarget:self action:@selector(SectionClick:) forControlEvents:UIControlEventTouchUpInside];
    view.mName.text = [NSString stringWithFormat:@"%@",car.mName];
    view.mCheck.selected = car.mIsCheck;
    [view.mCheck setImage:[UIImage imageNamed:@"quanhong"] forState:UIControlStateSelected];
    
    return view;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        return nil;
    }
    
    SCarSeller *car = [self.tempArray objectAtIndex:section-1];
    headView = [ShopCarFooterView shareView];
    
    headView.mJieSuan.tag = section-1;
    [headView.mJieSuan addTarget:self action:@selector(JieSuanClick:) forControlEvents:UIControlEventTouchUpInside];
    headView.mJieSuan.layer.masksToBounds = YES;
    headView.mJieSuan.layer.cornerRadius = 3;
    
    float price = 0;
    for (SCarGoods *goods in car.mCarGoods) {
        price += goods.mPrice*goods.mNum;
    }
    
    headView.mPrice.text = [NSString stringWithFormat:@"¥%.2f",price];
    
    return headView;
    
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==0) {
        AddressCell *cell = (AddressCell *)[tableView dequeueReusableCellWithIdentifier:@"addressCell"];
        
        if (!DefaultAddress || DefaultAddress == nil) {
            cell.mNoAddress.hidden = NO;
            cell.mName.hidden = YES;
            cell.mPhone.hidden = YES;
            cell.mAddress.hidden = YES;
        }else{
        
            cell.mNoAddress.hidden = YES;
            cell.mName.hidden = NO;
            cell.mPhone.hidden = NO;
            cell.mAddress.hidden = NO;
            cell.mName.text = DefaultAddress.mName;
            cell.mPhone.text = DefaultAddress.mMobile;
            cell.mAddress.text = DefaultAddress.mAddress;
        }
        
        cell.mJiantou.hidden = NO;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    ShopCarCell *cell = (ShopCarCell *)[tableView dequeueReusableCellWithIdentifier:@"cell1"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SCarSeller *car = [self.tempArray objectAtIndex:indexPath.section-1];
    
    SCarGoods *goods = [car.mCarGoods objectAtIndex:indexPath.row];
    
    [cell.mChoseBT setImage:[UIImage imageNamed:@"quanhong"] forState:UIControlStateSelected];
    cell.mChoseBT.selected = goods.mIsCheck;
    
    [cell.mImg sd_setImageWithURL:[NSURL URLWithString:goods.mLogo] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
    cell.mGoodsName.text = goods.mName;
    cell.mPrice.text = [NSString stringWithFormat:@"¥%.2f",goods.mPrice];
    cell.mNum.text = [NSString stringWithFormat:@"%d",goods.mNum];
    
    [cell.mChoseBT addTarget:self action:@selector(RowClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mJiaBT addTarget:self action:@selector(AddClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mJianBT addTarget:self action:@selector(JianClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mDelBT addTarget:self action:@selector(DelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    return cell;

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        AddressVC *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
        
        viewController.itblock = ^(SAddress* retobj){
            if( retobj )
            {
                
               DefaultAddress  = retobj;
                
                [self.tableView reloadData];
                
            }
            
        };
        [self pushViewController:viewController];;
    }
}

- (void)SectionClick:(UIButton *)sender{
    
    NSLog(@"%d",sender.selected);
    sender.selected = !sender.selected;
    NSLog(@"%d",sender.selected);
    SCarSeller *car = [self.tempArray objectAtIndex:sender.tag];
    
    if (sender.selected) {
        
        car.mIsCheck = YES;
        for (int i = 0; i < car.mCarGoods.count; i++) {
            
            SCarGoods *goods = [car.mCarGoods objectAtIndex:i];
            goods.mIsCheck = YES;
        }
    }else{
        car.mIsCheck = NO;
        for (int i = 0; i < car.mCarGoods.count; i++) {
            
            SCarGoods *goods = [car.mCarGoods objectAtIndex:i];
            goods.mIsCheck = NO;
        }
    }
    [self.tableView reloadData];
   
}

- (void)JieSuanClick:(UIButton *)sender{
    
    NSMutableArray *goodsAry = NSMutableArray.new;
    
    SCarSeller *car = [self.tempArray objectAtIndex:(int)sender.tag];
    
    for (SCarGoods *goods in car.mCarGoods) {
        if (goods.mIsCheck) {
            [goodsAry addObject:goods];
        }
    }
    
    if (goodsAry.count<=0) {
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择商品" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alt show];
        return;
    }

    BalanceVC *balance = [[BalanceVC alloc] initWithNibName:@"BalanceVC" bundle:nil];
    balance.mGoodsAry = goodsAry;
    balance.mCarSeller = car;
    
    [self pushViewController:balance];
    
}

- (void)DelClick:(UIButton *)sender{

    ShopCarCell *cell = (ShopCarCell*)[sender findSuperViewWithClass:[ShopCarCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    
    SCarSeller *car = [self.tempArray objectAtIndex:indexpath.section-1];
    
    SCarGoods *goods = [car.mCarGoods objectAtIndex:indexpath.row];
    
    goods.mNum = 0;
    [SVProgressHUD showWithStatus:@"操作中.." maskType:SVProgressHUDMaskTypeClear];
    [goods addToCart:[goods.mNormsId intValue] block:^(SResBase *info, NSArray *all){
        
        if (info.msuccess) {
            
            [SVProgressHUD showSuccessWithStatus:info.mmsg];
            
            
            self.tempArray = [[NSMutableArray alloc] initWithArray:all];
            
            [self.tableView reloadData];
            
            
            int badge = 0;
            
            for (SCarSeller *carseller in self.tempArray) {
                for (SCarGoods *cargoods in carseller.mCarGoods) {
                    
                    badge += cargoods.mNum;
                }
            }
            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
            if (badge>0)
                item.badgeValue = [NSString stringWithFormat:@"%d",badge];
            else
                item.badgeValue = nil;
            
            
        }else{
            
            [SVProgressHUD showErrorWithStatus:info.mmsg];
        }
    }];

}

- (void)RowClick:(UIButton *)sender
{
    
    ShopCarCell *cell = (ShopCarCell*)[sender findSuperViewWithClass:[ShopCarCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    
    SCarSeller *car = [self.tempArray objectAtIndex:indexpath.section-1];
    
    SCarGoods *goods = [car.mCarGoods objectAtIndex:indexpath.row];
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        goods.mIsCheck = YES;
    }else{
        goods.mIsCheck = NO;
    }
    
}

- (void)AddClick:(UIButton *)sender{
    
    [self dealNum:1 sender:sender];
}

- (void)JianClick:(UIButton *)sender{

    
    [self dealNum:-1 sender:sender];
    
}
-(void)dealNum:(int)i sender:(UIButton*)sender
{
    
    ShopCarCell *cell = (ShopCarCell*)[sender findSuperViewWithClass:[ShopCarCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    
    SCarSeller *car = [self.tempArray objectAtIndex:indexpath.section-1];
    
    SCarGoods *goods = [car.mCarGoods objectAtIndex:indexpath.row];
    
    if ( ( i == -1 && goods.mNum > 0 ) || ( i == 1 ) ) {
        
        goods.mNum +=i;
        [SVProgressHUD showWithStatus:@"操作中.." maskType:SVProgressHUDMaskTypeClear];
        [goods addToCart:[goods.mNormsId intValue] block:^(SResBase *info, NSArray *all){
            
            if (info.msuccess) {
                
                [SVProgressHUD showSuccessWithStatus:info.mmsg];
                
                self.tempArray = [[NSMutableArray alloc] initWithArray:all];
                
                [self.tableView reloadData];
                
                int badge = 0;
                
                for (SCarSeller *carseller in self.tempArray) {
                    for (SCarGoods *cargoods in carseller.mCarGoods) {
                        
                        badge += cargoods.mNum;
                    }
                }
                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
                if (badge>0)
                    item.badgeValue = [NSString stringWithFormat:@"%d",badge];
                else
                    item.badgeValue = nil;
                
            }else{
                goods.mNum -=i;
                [SVProgressHUD showErrorWithStatus:info.mmsg];
            }
        }];
    }
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

@end
