//
//  MainVC.m
//  JiaZhengBuyer
//
//  Created by 周大钦 on 15/7/21.
//  Copyright (c) 2015年 zdq. All rights reserved.
//
#import "AddressTableview.h"
#import "CustomBtn.h"
#import "PingjiaVC.h"
#import "RestaurantDetailVC.h"
#import "ActivityVC.h"
#import "RestaurantVC.h"
#import "OrderVC.h"
#import "NavC.h"
#import "SDCycleScrollView.h"
#import "TAPageControl.h"
#import "CollectCell.h"
#import "AddressVC.h"
#import "SellerDetailView.h"
#import "MoreVC.h"

#import "MainVC.h"

#import "searchHotVC.h"
#import "CmmVC.h"
@interface MainVC ()<AddressDelegate,SDCycleScrollViewDelegate,UITabBarControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation MainVC{
    
    NSString*   _lastciyt;
    NSArray*    _alltopads;
    BOOL AddressIsOpen;
    
    BOOL _bneedhidstatusbar;
    
    UIButton* cancelBtn;
    
    float _msellat;
    float _msellng;
    
    NSArray *_bottomAry;
    NSArray *_bannerAry;
    
    int selectIndex;
    
    UIView *headView;
    SDCycleScrollView *cycleScrollView;
    UIView *menuView;
    UIView *advertView;
    
    NSArray *goodsAry;
    NSArray *sellerAry;
}


- (instancetype)init{
    
    return [super init];
}


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

-(void)checkUserGinfo
{
    [super checkUserGinfo];
    [self reloadDataAndView];
}

- (void)titleClick:(UITapGestureRecognizer *)tap{
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    
    NSLog(@"点点点");
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddressVC *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
    
    viewController.itblock = ^(SAddress* retobj){
        if( retobj )
        {
            
            self.AddressTitle = [SAppInfo shareClient].mAddr = retobj.mAddress;
            
        }
        
    };
    [self pushViewController:viewController];
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hiddenBackBtn = YES;
    self.mPageName = @"";
    self.AddressTitle = self.mPageName;
    self.navBar.leftBtn.hidden = NO;
    
    self.navBar.titleLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
    
    [self.navBar.titleLabel addGestureRecognizer:tap];
    
    self.rightBtnImage = [UIImage imageNamed:@"serach"];
    
    
    self.navBar.leftBtn.hidden = YES;
    CGRect rect = self.navBar.leftBtn.frame;
    rect.size.width = 100;
    self.navBar.leftBtn.frame = rect;
    
    [self loadTableView:CGRectMake(0, DEVICE_NavBar_Height, DEVICE_Width, DEVICE_InNavTabBar_Height) delegate:self  dataSource:self];
    self.tableView.userInteractionEnabled = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, 0)];
    headView.backgroundColor = M_BGCO;
    
    UINib *nib = [UINib nibWithNibName:@"CollectCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    
    _lastciyt = [SAppInfo shareClient].mSelCity;
    
    [self showFrist];
    
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PushClick:) name:@"push_Message" object:nil];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserGinfo) name:@"UserGinfoSuccess" object:nil];
    
    
    self.tabBarController.delegate = self;
}

- (void)PushClick:(NSNotification *)notif{

    NSDictionary *dic = notif.object;
    
    [[AppDelegate shareAppDelegate] dealPush:dic bopenwith:YES];
}

-(void)rightBtnTouched:(id)sender
{
    //CmmVC* vc  = [[CmmVC alloc]initWithNibName:@"CmmVC" bundle:nil];
    searchHotVC* vc = [[searchHotVC alloc]initWithNibName:@"searchHotVC" bundle:nil];
    [self pushViewController:vc];
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

     int Index = (int)tabBarController.selectedIndex;
    ((NavC *)viewController).TabBar = tabBarController;
    
  if(Index == 1 || Index == 2){
    
        if ( [SUser isNeedLogin] ) {
            
            self.tabBarController.selectedIndex = 0;
            [self gotoLoginVC:viewController];
            
        }
    }

}


-(void)layoutTopAdsAfterMain
{
    
    
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
    [SMainFunc getMainFuncs:^(SResBase *resb, NSArray *banner, NSArray *menus, NSArray *notices, NSArray *rgoods, NSArray *rseller) {
        
        if (resb.msuccess) {
            
            goodsAry = rgoods;
            sellerAry = rseller;
            
            
            [self loadAndupdateTopAdView:banner];
            
            [self loadAndupdateMainView:menus];
            
            [self loadAndupdateNoticeView:notices];
            
            
            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];

    

    [[SAppInfo shareClient] getUserLocation:YES block:^(NSString *err) {

        if( !err )
        {
            self.AddressTitle = [SAppInfo shareClient].mAddr;
            
            _msellat = [SAppInfo shareClient].mlat;
            _msellng = [SAppInfo shareClient].mlng;
        }
        else
        {
            self.AddressTitle = @"定位失败,请手动设置";
            
        }

    }];
    
}


-(void)tableViewCellDidSelectAddress
{
    [self leftBtnTouched:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)headerBeganRefresh
{
    [self performSelector:@selector(headerEndRefresh) withObject:nil afterDelay:0.5];
}
-(void)footetBeganRefresh
{
    [self performSelector:@selector(footetEndRefresh) withObject:nil afterDelay:0.5];
    
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}
-(void)gotoApp
{
    //初始化,必须调用
    [self showWithStatus:@"正在获取配置信息..."];
    [GInfo getGInfo:^(SResBase *resb, GInfo *gInfo) {

        if( !resb.msuccess )
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            [self addNotifacationStatus:@"获取配置信息失败,请稍后再试"];
        }
        else
        {
            [SVProgressHUD dismiss];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkUserGinfo];
            });
            
            [self getMsgNum];

            [self checkAPPUpdate];
            
            
        }
    }];
}

- (void)getMsgNum{

    [SVProgressHUD showWithStatus:@"加载中.." maskType:SVProgressHUDMaskTypeClear];
    [[SUser currentUser] haveNewMsg:^(int newMsgCount, int cartGoodsCount, int collectCount, int addressCount) {
        
        [SVProgressHUD dismiss];
        if ([SUser isNeedLogin]) {
            
        }else{
        
            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
            if(cartGoodsCount>0)
                item.badgeValue = [NSString stringWithFormat:@"%d",cartGoodsCount];
            else
                item.badgeValue = nil;
            
            UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:3];
            if (newMsgCount>0)
                item2.badgeValue = [NSString stringWithFormat:@"%d",newMsgCount];
            else
                item2.badgeValue = nil;
        }
        
    }];

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( [GInfo shareClient].mForceUpgrade )
    {
        [self doupdateAPP];
    }
    else
    {
        if( 1 == buttonIndex )
        {
            [self doupdateAPP];
        }
    }
}
-(void)doupdateAPP
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GInfo shareClient].mAppDownUrl]];
}

-(void)checkAPPUpdate
{
    
    if( [GInfo shareClient].mAppDownUrl )
    {
        NSString* msg = [GInfo shareClient].mUpgradeInfo;
        if( [GInfo shareClient].mForceUpgrade )
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:msg delegate:self cancelButtonTitle:@"升级" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:msg delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }
    }
}


-(NSArray*)getFristImages
{
    if( DeviceIsiPhone() )
    {
        return @[@"f_img1",@"f_img2"];
    }
    else
    {
        return @[@"f_img1",@"f_img2"];
    }
    
}
-(void)fristTaped:(UITapGestureRecognizer*)sender
{
    UIView* ttt = [sender view];
    UIView* pview = [ttt superview];
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect f = pview.frame;
        f.origin.y = -pview.frame.size.height;
        pview.frame = f;
        
    } completion:^(BOOL finished) {
        
        [pview removeFromSuperview];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        NSString* nowver = [Util getAppVersion];
        [def setObject:nowver forKey:@"showed"];
        [def synchronize];
        _bneedhidstatusbar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        
        [self gotoApp];
    }];
}
-(void)showFrist
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSString* v = [def objectForKey:@"showed"];
    NSString* nowver = [Util getAppVersion];
    if( ![v isEqualToString:nowver] )
    {
        UIScrollView* firstview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        firstview.showsHorizontalScrollIndicator = NO;
        firstview.backgroundColor = [UIColor colorWithRed:0.937 green:0.922 blue:0.918 alpha:1.000];
        firstview.pagingEnabled = YES;
        firstview.bounces = NO;
        NSArray* allimgs = [self getFristImages];
        
        CGFloat x_offset = 0.0f;
        CGRect f;
        UIImageView* last = nil;
        for ( NSString* oneimgname in allimgs ) {
            UIImageView* itoneimage = [[UIImageView alloc] initWithFrame:firstview.bounds];
            itoneimage.image = [UIImage imageNamed: oneimgname];
            f = itoneimage.frame;
            f.origin.x = x_offset;
            itoneimage.frame = f;
            x_offset += firstview.frame.size.width;
            [firstview addSubview: itoneimage];
            last  = itoneimage;
        }
        UITapGestureRecognizer* guset = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fristTaped:)];
        last.userInteractionEnabled = YES;
        [last addGestureRecognizer: guset];
        
        CGSize cs = firstview.contentSize;
        cs.width = firstview.frame.size.width * allimgs.count;
        firstview.contentSize = cs;
        
        _bneedhidstatusbar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        
        
        [((UIWindow*)[UIApplication sharedApplication].delegate).window addSubview: firstview];
    }
    else
        [self gotoApp];
    
}
-(BOOL)prefersStatusBarHidden
{
    return _bneedhidstatusbar;
}


-(void)reloadDataAndView
{
    [self layoutTopAdsAfterMain];
    
}
-(void)loadAndupdateTopAdView:(NSArray *)arr
{
    
    
    
    NSMutableArray *bannerAry = NSMutableArray.new;
    for (int i = 0; i < arr.count; i++) {
        SMainFunc *func = [arr objectAtIndex:i];
        
        [bannerAry addObject:func.mImage];
    }

    cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, DEVICE_Width, DEVICE_Width*0.4) imagesGroup:bannerAry];
    cycleScrollView.delegate = self;
    [headView addSubview:cycleScrollView];
    
    _bannerAry = [[NSArray alloc] initWithArray:arr];
}


- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    SMainFunc *func = [_bannerAry objectAtIndex:index];
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    switch (func.mType) {
            
        case 1://商户类型
        {
            RestaurantVC *viewController = [[RestaurantVC alloc] initWithNibName:@"RestaurantVC" bundle:nil];
            viewController.mGoodsId = [func.mArg intValue];
            viewController.mGoodsName = func.mName;
            viewController.mType = func.mType;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
            break;
            
            
        case 2://服务类型
        {
            
            RestaurantVC *viewController = [[RestaurantVC alloc] initWithNibName:@"RestaurantVC" bundle:nil];
            viewController.mGoodsId = [func.mArg intValue];
            viewController.mType = func.mType;
            viewController.mGoodsName = func.mName;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
            break;
        case 3://商品详情
        {
            
            WebVC* vc = [[WebVC alloc] init];
            vc.mName = func.mName;
            vc.mUrl = [APIClient wapWithUrl:[NSString stringWithFormat:@"Goods/detail?goodsId=%d",[func.mArg intValue]]];
            [self pushViewController:vc];
        }
            
            break;
        case 4:{//商家详情
            
            SSeller *seller = [[SSeller alloc] init];
            seller.mId = [func.mArg intValue];
            
            SellerDetailView *sellerView = [[SellerDetailView alloc] initWithNibName:@"SellerDetailView" bundle:nil];
            sellerView.mSeller = seller;
            [self pushViewController:sellerView];
            
        }
            
            break;
        case 5:{//URL
            
            WebVC* vc = [[WebVC alloc] init];
            vc.mName = func.mName;
            vc.mUrl = func.mArg;
            [self pushViewController:vc];
            
        }
            
            break;
            
        default:
        {
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"暂未开通" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alt show];
        }
            
            break;
    }

}


-(void)loadAndupdateMainView:(NSArray *)funcs
{
   
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cycleScrollView.frame), DEVICE_Width, 200)];
    menuView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:menuView];
    
    float originy = 10;
    float originx = 0;
//    float width = DEVICE_Width/2;
    float width2 = DEVICE_Width/4;
    float height = 85;
    
    for (int i = 0; i<[funcs count];i++) {
        
        if (i>7) {
            return;
        }
        
        SMainFunc *fun = [funcs objectAtIndex:i];
        
        if (i%4==0) {
            originx = 0;
            originy = (i+1)/4*height+10;
        }else
        {
            originx = width2*(i%4);
            originy = originy;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originx, originy, width2, height)];
        view.backgroundColor = [UIColor whiteColor];
        UIImageView *image =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width2, height-30)];
        [view addSubview:image];
        //                image.backgroundColor = [UIColor redColor];
        image.contentMode = UIViewContentModeScaleAspectFit;
        
        image.userInteractionEnabled = YES;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, height-30, width2, 30)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = COLOR(71, 71, 72);
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = fun.mName;
        [view addSubview:lab];
        
        CustomBtn *btn = [[CustomBtn alloc] initWithFrame:CGRectMake(0, 0, width2, height)];
        btn.func = fun;
        [view addSubview:btn];
        if (i == 7 && funcs.count>8) {
            image.image = [UIImage imageNamed:@"more"];
            lab.text = @"全部";
            [btn addTarget:self action:@selector(moreBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [image sd_setImageWithURL:[NSURL URLWithString:fun.mImage] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
            [btn addTarget:self action:@selector(mainBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
       
        
        [menuView addSubview:view];
    }
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, originy+height+7, DEVICE_Width, 1)];
    line2.backgroundColor = COLOR(212, 212, 212);
    [menuView addSubview:line2];
    
    CGRect rect = menuView.frame;
    rect.size.height = CGRectGetMaxY(line2.frame);
    menuView.frame = rect;
    
    
}

- (void)loadAndupdateNoticeView:(NSArray *)arry{
    
    if (arry.count<=0) {
        
        CGRect recth = headView.frame;
        recth.size.height =CGRectGetMaxY(menuView.frame);
        recth.origin.y = 0;
        headView.frame = recth;
        [self.tableView setTableHeaderView:headView];
        return;
    }

    advertView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuView.frame)+8, DEVICE_Width, 200)];
    advertView.backgroundColor = M_BGCO;
    [headView addSubview:advertView];
    
    float originy = 0;
    float originx = 0;
    float width  = 0;
    float height = DEVICE_Width/2*0.75;
    
    
    for (int i = 0; i<[arry count];i++) {
        
        SMainFunc *fun = [arry objectAtIndex:i];
        
        if (i<2) {
            
            originy = 0;
            originx = DEVICE_Width/2*i;
            width = DEVICE_Width/2;
        }else{
        
            originy = (i-1)*(height+8);
            originx = 0;
            width = DEVICE_Width;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originx, originy, width, height)];
        view.layer.borderColor = COLOR(235, 235, 236).CGColor;
        view.layer.borderWidth = 0.5;
        
        view.backgroundColor = [UIColor whiteColor];
        UIImageView *image =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [view addSubview:image];
        image.clipsToBounds = YES;
        image.contentMode = UIViewContentModeScaleAspectFill;
        
        [image sd_setImageWithURL:[NSURL URLWithString:fun.mImage] placeholderImage:[UIImage imageNamed:@"DefaultBanner"]];
        image.userInteractionEnabled = YES;
        
        
        CustomBtn *btn = [[CustomBtn alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        btn.func = fun;
        [view addSubview:btn];
        //        [btn setBackgroundColor:fun.mBgColor];
        
        [btn addTarget:self action:@selector(mainBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [advertView addSubview:view];
        
    }
   
    
    CGRect rect = advertView.frame;
    rect.size.height = originy+height;
    advertView.frame = rect;
    
    NSLog(@"%.2f",CGRectGetMaxY(advertView.frame));
    CGRect recth = headView.frame;
    recth.size.height =CGRectGetMaxY(advertView.frame);
    recth.origin.y = 0;
    headView.frame = recth;
    [self.tableView setTableHeaderView:headView];
    
    
}


#pragma mark－－－－主菜单按钮


-(void)mainBtnTouched:(CustomBtn *)sender
{
    
    SMainFunc *func = sender.func;
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];

    switch (func.mType) {
            
        case 1://商户类型
        {
            RestaurantVC *viewController = [[RestaurantVC alloc] initWithNibName:@"RestaurantVC" bundle:nil];
            viewController.mGoodsId = [func.mArg intValue];
            viewController.mType = func.mType;
            viewController.mGoodsName = func.mName;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
            break;
            
            
        case 2://服务类型
        {
            
            RestaurantVC *viewController = [[RestaurantVC alloc] initWithNibName:@"RestaurantVC" bundle:nil];
            viewController.mGoodsId = [func.mArg intValue];
            viewController.mType = func.mType;
            viewController.mGoodsName = func.mName;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
            break;
        case 3://商品详情
        {
            
            WebVC* vc = [[WebVC alloc] init];
            vc.mName = func.mName;
            vc.mUrl = [APIClient wapWithUrl:[NSString stringWithFormat:@"Goods/detail?goodsId=%d",[func.mArg intValue]]];
            [self pushViewController:vc];
        }
            
            break;
        case 4:{//商家详情
            
            SSeller *seller = [[SSeller alloc] init];
            seller.mId = [func.mArg intValue];
            
            SellerDetailView *sellerView = [[SellerDetailView alloc] initWithNibName:@"SellerDetailView" bundle:nil];
            sellerView.mSeller = seller;
            [self pushViewController:sellerView];
            
        }
            
            break;
        case 5:{//URL
            
            WebVC* vc = [[WebVC alloc] init];
            vc.mName = func.mName;
            vc.mUrl = func.mArg;
            [self pushViewController:vc];
            
        }
            
            break;
            
        default:
        {
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"暂未开通" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alt show];
        }
            
            break;
    }

    
    
   
 
}

- (void)moreBtnTouched:(UIButton *)sender{

    MoreVC *more = [[MoreVC alloc] init];
    [self pushViewController:more];
}


- (void)CancelAction:(UIButton *)sender{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        //        menuView.alpha = 0;
    }];
    
}


#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    int num = 0;
    if (goodsAry.count>0) {
        num ++;
    }
    if (sellerAry.count>0) {
        num ++;
    }
    return num;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && goodsAry.count>0) {
        return 1;
    }
    return sellerAry.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, 40)];
    view.backgroundColor = M_BGCO;
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(8, 11, 17, 17)];
    
    [view addSubview:imageV];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 40)];
    lab.textColor = COLOR(136, 137, 138);
    lab.font = [UIFont systemFontOfSize:15];
    [view addSubview:lab];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_Width-50, 0, 50, 40)];
    [button setTitle:@"更多》" forState:UIControlStateNormal];
    [button setTitleColor:COLOR(136, 137, 138) forState:UIControlStateNormal];
    
    if (section == 0 && goodsAry.count>0) {
        lab.text = @"生活小帮手";
        imageV.image = [UIImage imageNamed:@"shangjia"];
    }else{
        
        lab.text = @"附近推荐商户";
        imageV.image = [UIImage imageNamed:@"shangjia"];
        button.hidden = YES;
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && goodsAry.count>0) {
        
        
    }

    CollectCell *cell = (CollectCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    SSeller *seller = [sellerAry objectAtIndex:indexPath.row];
    [cell.mImg sd_setImageWithURL:[NSURL URLWithString:seller.mLogo] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
    cell.mName.text = seller.mName;
//    cell.mTime.text = [NSString stringWithFormat:@"营业时间：%@",seller.mBusinessHours];
    cell.mKm.text = seller.mDist;
    [cell setStar:seller.mScore];
    
//    if (seller.mIsDelivery == 0)
//        cell.mPsTime.text = @"商家休息";
//    else
//        cell.mPsTime.text = [NSString stringWithFormat:@"配送时间：%@",seller.mDeliveryTime];
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[seller.mFreight dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    cell.mQsPrice.attributedText = attrStr;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    
    SSeller *seller = [sellerAry objectAtIndex:indexPath.row];
    
    SellerDetailView *sellerView = [[SellerDetailView alloc] initWithNibName:@"SellerDetailView" bundle:nil];
    sellerView.mSeller = seller;
    
    [self pushViewController:sellerView];
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
