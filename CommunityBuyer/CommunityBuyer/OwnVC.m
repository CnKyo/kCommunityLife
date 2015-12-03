//
//  OwnVC.m
//  XiCheBuyer
//
//  Created by 周大钦 on 15/6/18.
//  Copyright (c) 2015年 zdq. All rights reserved.
//

#import "OwnVC.h"
#import "feedBackViewController.h"
#import "AddressVC.h"
#import "ShareVC.h"
#import "CollectVC.h"
#import "MyPhoneListVC.h"
#import "ResigerVC.h"
#import "OwnCell.h"
#import "MessageVC.h"
#import "SettingVC.h"
#import "myStoreViewController.h"
#import<MessageUI/MessageUI.h>
#define Height (DEVICE_Width*0.67)

@interface OwnVC ()<UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>{

    UIImageView *imageV;
    UIView *nav;
    UILabel *lab;
    
    UIImageView *headImg;
    
    UILabel *namelb;
    UILabel *phonelb;
    
    UIButton *resBT;
    UIButton *loginBT;
    UIView   *lineh;
    
    UIButton *rightbtn;
    
    int mSysNum;
    int mMycollectionNum;
    int mAddressNum;
    
    BOOL flag;
    
    NSString *mAppUrl;
}

@end

@implementation OwnVC{

    BOOL isGoLogin;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
     [self updateHeaderInfo];
    
    flag = NO;

}

- (void)initNum{
    
    [[SUser currentUser] haveNewMsg:^(int newMsgCount, int cartGoodsCount, int collectCount, int addressCount) {
        
        
        mSysNum = newMsgCount;
        mAddressNum = addressCount;
        mMycollectionNum = collectCount;
        
        UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:3];
        if (newMsgCount>0)
            item2.badgeValue = [NSString stringWithFormat:@"%d",newMsgCount];
        else
            item2.badgeValue = nil;
        [self.tableView reloadData];
    }];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hiddenBackBtn = YES;
    self.mPageName = @"我的";
    self.Title = self.mPageName;
    
    mAppUrl = nil;
    
    [self loadTableView:CGRectMake(0, 0, DEVICE_Width, DEVICE_Height-50) delegate:self  dataSource:self];
    
    self.tableView.backgroundColor = M_BGCO;
    self.tableView.userInteractionEnabled = YES;
    
    UINib *nib = [UINib nibWithNibName:@"OwnCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell1"];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, 55)];
    UILabel *kf = [[WPHotspotLabel alloc] initWithFrame:CGRectMake(0, 15, DEVICE_Width, 20)];
//    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"客户服务热线：%@",[GInfo shareClient].mServiceTel]];
//    NSRange contentRange = {7, [content length]-7};
//    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
//    kf.attributedText = content;

    kf.textColor = M_TCO;
    kf.textAlignment = NSTextAlignmentCenter;
    kf.font = [UIFont systemFontOfSize:13];
    [footView addSubview:kf];
//    kf.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CallClick:)];
//    [kf addGestureRecognizer:tap];
    
    NSDictionary *mStyle = @{@"Action":[WPAttributedStyleAction styledActionWithAction:^{
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        MLLog(@"打电话");
    }],@"color": COLOR(68, 159, 243),@"xiahuaxian":@[M_CO,@{NSUnderlineStyleAttributeName : @(kCTUnderlineStyleSingle|kCTUnderlinePatternSolid)}]};
    
    kf.attributedText = [[NSString stringWithFormat:@"客户服务热线：<Action><xiahuaxian>%@</xiahuaxian></Action>",[GInfo shareClient].mServiceTel] attributedStringWithStyleBook:mStyle];

    
    UILabel *fu = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, DEVICE_Width, 20)];
    fu.text = [NSString stringWithFormat:@"服务时间：%@",[GInfo shareClient].mServiceTime];
    fu.textColor = M_TCO;
    fu.textAlignment = NSTextAlignmentCenter;
    fu.font = [UIFont systemFontOfSize:13];
    [footView addSubview:fu];
    
    [self.tableView setTableFooterView:footView];
    
    [self loadTop];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushcoming:) name:@"pushnotfi" object:nil];
    
}
-(void)pushcoming:(id)sender
{
    [self updateHeaderInfo];
}


- (void)CallClick:(UITapGestureRecognizer *)sender{

    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)loadTop{

    nav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, DEVICE_NavBar_Height)];
    lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    lab.text = @"我的";
    lab.textColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:16];
    [nav addSubview:lab];
    [self.view addSubview:nav];
    
    rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_Width-70, 20, 50, 44)];
    [rightbtn setTitle:@"退出" forState:UIControlStateNormal];
    rightbtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightbtn addTarget:self action:@selector(outClick:) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:rightbtn];
    
    imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, Height)];
    imageV.image = [UIImage imageNamed:@"own_bg"];
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    imageV.userInteractionEnabled = YES;
    
    [self.tableView setTableHeaderView:imageV];
    
    UITapGestureRecognizer *imgAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goMyInfoClick:)];
    [imageV addGestureRecognizer:imgAction];
    
    
    
    headImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, Height-140, 80, 80)];
    headImg.center = imageV.center;
    CGRect rect = headImg.frame;
//    rect.origin.y = Height-160;
    headImg.frame = rect;
    headImg.layer.cornerRadius = 40;
    headImg.image = [UIImage imageNamed:@"defultHead"];
    headImg.clipsToBounds = YES;
    headImg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;//自动布局，自适应顶部
    [imageV addSubview:headImg];
    
    namelb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headImg.frame), self.view.frame.size.width, 30)];
    namelb.text = @"";
    namelb.textColor = [UIColor whiteColor];
    namelb.textAlignment = NSTextAlignmentCenter;
    namelb.font = [UIFont systemFontOfSize:20];
    namelb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;//自动布局，自适应顶部
    [imageV addSubview:namelb];
    
    phonelb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(namelb.frame), self.view.frame.size.width, 30)];
    phonelb.text = @"";
    phonelb.textColor = [UIColor whiteColor];
    phonelb.textAlignment = NSTextAlignmentCenter;
    phonelb.font = [UIFont systemFontOfSize:20];
    phonelb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;//自动布局，自适应顶部
    [imageV addSubview:phonelb];
    
    resBT = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_Width/2-55, CGRectGetMaxY(headImg.frame)+10, 55, 30)];
    [resBT setTitle:@"注册" forState:UIControlStateNormal];
    [resBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resBT.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [imageV addSubview:resBT];
    [resBT addTarget:self action:@selector(GOResiger:) forControlEvents:UIControlEventTouchUpInside];
    
    lineh = [[UIView alloc] initWithFrame:CGRectMake(DEVICE_Width/2, CGRectGetMaxY(headImg.frame)+16, 1, 18)];
    lineh.backgroundColor = [UIColor whiteColor];
    lineh.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [imageV addSubview:lineh];
    
    loginBT = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_Width/2+1, CGRectGetMaxY(headImg.frame)+10, 55, 30)];
    [loginBT setTitle:@"登陆" forState:UIControlStateNormal];
    [loginBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBT.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [imageV addSubview:loginBT];
    [loginBT addTarget:self action:@selector(GoLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    
   


    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    if (scrollView.contentOffset.y>=Height-160) {
        
        nav.backgroundColor = [UIColor whiteColor];
        lab.textColor = [UIColor blackColor];
        [rightbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        nav.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
        [rightbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, 12)];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
    return 55;
    
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OwnCell *cell = (OwnCell *)[tableView dequeueReusableCellWithIdentifier:@"cell1"];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_Width, 0.5)];
    line.backgroundColor = M_LINECO;
    

    cell.mSwith.hidden = YES;
    NSLog(@"%@",[cell.mImage valueForKey:@"eeee"]);
    
    switch (indexPath.row) {
        case 0:
            cell.mImage.image = [UIImage imageNamed:@"own_xx"];
            cell.mName.text = mSysNum>0?[NSString stringWithFormat:@"系统消息(%d)",mSysNum]:@"系统消息";
            [cell addSubview:line];
            
            
            break;
        case 1:
            cell.mImage.image = [UIImage imageNamed:@"own_sc"];
            cell.mName.text = mMycollectionNum>0?[NSString stringWithFormat:@"我的收藏(%d)",mMycollectionNum]:@"我的收藏";
            
            break;
            
        case 2:
            cell.mImage.image = [UIImage imageNamed:@"own_dz"];
            cell.mName.text = mAddressNum>0?[NSString stringWithFormat:@"地址管理(%d)",mAddressNum]:@"地址管理";
            
            break;
            
        case 3:
            cell.mImage.image = [UIImage imageNamed:@"own_sz"];
            cell.mName.text = @"设置";
            
            break;
        case 4:
            cell.mImage.image = [UIImage imageNamed:@"own_store"];
            cell.mName.text = @"我要开店";
            
            break;
        case 5:
            cell.mImage.image = [UIImage imageNamed:@"own_yqhy"];
            cell.mName.text = @"邀请好友";
            
            break;
            
        default:
            break;
        
    }
        
        
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        
        return;
    }
    
    switch (indexPath.row) {
        case 0:
            
            [self goMsgClick];
            break;
        case 1:
           
            [self goCollectClick];
            break;
            
        case 2:
            [self goAddressClick];
            
            break;
            
        case 3:
            [self goSetting];
            
            break;
        case 4:
            [self myStore];
            
            break;
        case 5:
            [self MyShare];
            
            break;
            
        default:
            break;
    }

}

- (void)MyShare{
    
    NSLog(@"%@",[GInfo shareClient].mShareContent);
    
    [self showMessageView:nil title:@"邀请好友" body:[GInfo shareClient].mShareContent];
}

- (void)myStore{
    
    if (flag) {
        return;
    }
    
    flag = YES;
    
    [[SUser currentUser] checkReg:^(SResBase *resb, SSeller *seller) {
        
        
        if (resb.msuccess) {
            
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
            
            
            
            if (seller.mIsCheck == 0) {
                [SVProgressHUD showErrorWithStatus:@"开店信息待审核中！"];
                
            }
            if (seller.mIsCheck == 1) {
                [self AlertViewWithTag:2 andMsg:@"亲爱的商家，距离成功入驻仅仅差一小步哦！请下载掌管生活掌柜端APP进一步完善资料。祝您心想事成入驻成功！"];
            }
            
            if (seller){
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                myStoreViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ms"];
                viewController.mSeller = seller;
                
                [self.navigationController pushViewController:viewController animated:YES];
                
            }

            
        }
        else{
            
            if (seller.mIsCheck == 0) {
                [self AlertViewWithTag:1 andMsg:@"恭喜发财，入驻成功！请下载并登陆掌管生活掌柜端APP进一步完善管理商品。"];
                [SVProgressHUD dismiss];
            }else{
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
            
            flag = NO;
        }
    }];




}
-(void)updateHeaderInfo
{
    
    if ([SUser isNeedLogin]) {
        
        rightbtn.hidden = YES;
        namelb.hidden = YES;
        phonelb.hidden = YES;
        resBT.hidden = NO;
        loginBT.hidden = NO;
        lineh.hidden = NO;
        headImg.image = [UIImage imageNamed:@"defultHead"];
//        [self gotoLoginVC];
        return;
        
    }else{
        rightbtn.hidden = NO;
        namelb.hidden = NO;
        phonelb.hidden = NO;
        resBT.hidden = YES;
        loginBT.hidden = YES;
        lineh.hidden = YES;
    }


    namelb.text = [SUser currentUser].mUserName;
    phonelb.text = [SUser currentUser].mPhone;
    
    if ([SUser currentUser].mHeadImg) {
        
        headImg.image = [SUser currentUser].mHeadImg;
    }else{
        [headImg sd_setImageWithURL:[NSURL URLWithString:[SUser currentUser].mHeadImgURL] placeholderImage:[UIImage imageNamed:@"defultHead"]];
    }

    headImg.layer.masksToBounds = YES;
    headImg.layer.borderColor = [UIColor colorWithRed:0.580 green:0.506 blue:0.478 alpha:1].CGColor;
    headImg.layer.cornerRadius = headImg.frame.size.width/2;
    headImg.layer.borderWidth = 5;
    
    [self initNum];
}

-(void)showMessageView:(NSArray*)phones title:(NSString*)title body:(NSString*)body
{
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController*controller=[[MFMessageComposeViewController alloc]init];
        controller.recipients=phones;
        controller.navigationBar.tintColor=[UIColor redColor];
        controller.body=body;
        controller.messageComposeDelegate=self;
        [self presentViewController:controller animated:YES completion:nil];

    }
    else
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"提示信息"
                                                   message:@"该设备不支持短信功能"
                                                  delegate:nil
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil,nil];
        [alert show];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch(result){
        caseMessageComposeResultSent:
            //信息传送成功
            break;
        caseMessageComposeResultFailed:
            //信息传送失败
            break;
        caseMessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)GoLoginClick:(id)sender{

    
    [self gotoLoginVC];
}

- (void)GOResiger:(id)sender{

    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ResigerVC *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ResigerVC"];
    viewController.mIsOwn = YES;
    
    [self presentViewController:viewController animated:YES completion:nil];
}



- (void)goAddressClick{
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddressVC *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
    viewController.mIsCommon = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goMsgClick{
    
    
    WebVC* vc = [[WebVC alloc]init];
    vc.mName = @"系统消息";
    vc.mUrl =  [APIClient APiWithUrl:[NSString stringWithFormat:@"msg.message?token=%@&userId=%d",[SUser currentUser].mToken,[SUser currentUser].mUserId]];
    
    [self pushViewController:vc];
    
    /*
    MessageVC *msgVC = [[MessageVC alloc] init];
    [self pushViewController:msgVC];
     */
    
}

- (void)goSetting{

    SettingVC *set = [[SettingVC alloc] init];
    [self pushViewController:set];
}

- (void)goMyInfoClick:(UIGestureRecognizer *)sender {
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    id viewController = [storyboard instantiateViewControllerWithIdentifier:@"myinfo"];
    
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 1) {
        MLLog(@"通过");
        if (buttonIndex == 0) {
            WebVC *www = [WebVC new];
            www.mName = @"下载地址";
            www.mUrl = mAppUrl;
            [self pushViewController:www];
        }
        
    }
    else if (alertView.tag == 2) {
        MLLog(@"不通过");
        if (buttonIndex == 0) {
            WebVC *www = [WebVC new];
            www.mName = @"下载地址";
            www.mUrl = mAppUrl;
            [self pushViewController:www];
        }
        
    }
    
    else if( alertView.tag == 100 )
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
        
        return;
    }
    else
    {
        if( buttonIndex == 0 )
        {
            [SUser logout];
            
            [self updateHeaderInfo];

            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
            item.badgeValue = nil;

            
            UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:3];
            item2.badgeValue = nil;
            
            mSysNum = 0;
            mMycollectionNum = 0;
            mAddressNum = 0;
        }
    }
}
-(void)doupdateAPP
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GInfo shareClient].mAppDownUrl]];
}
- (void)outClick:(id)sender {
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"注销账号" message:@"您确定要注销当前账号吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    
    
    
    [alert show];
    
}



- (void)goCollectClick{
    
    CollectVC *collect = [[CollectVC alloc] init];
    [self pushViewController:collect];
    
}

- (void)AlertViewWithTag:(int)tag andMsg:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"进入下载" otherButtonTitles:@"取消", nil];
    alert.tag = tag;
    [alert show];
}

@end
