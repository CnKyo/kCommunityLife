//
//  SettingVC.m
//  CommunityBuyer
//
//  Created by 周大钦 on 15/9/22.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import "SettingVC.h"
#import "OwnCell.h"
#import "feedBackViewController.h"
#import "WebVC.h"
#import "APService.h"

@interface SettingVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    
    self.mPageName = @"设置";
    self.Title = self.mPageName;
    
    [self loadTableView:CGRectMake(0, 0, DEVICE_Width, DEVICE_InNavBar_Height)delegate:self dataSource:self];
    
    UINib *nib = [UINib nibWithNibName:@"OwnCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.haveHeader = NO;
    self.haveFooter = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = M_BGCO;
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    
}

#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return self.tempArray.count;
    
    return 4;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OwnCell *cell = (OwnCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.mSwith.hidden = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    cell.mJiantou.hidden = NO;
    cell.mSwith.hidden = YES;
    
    switch (indexPath.row) {
            
        case 0:
            cell.mImage.image = [UIImage imageNamed:@"own_xx"];
            cell.mName.text = @"接收系统消息";
            
            cell.mSwith.hidden = NO;
            cell.mJiantou.hidden = YES;
            [cell.mSwith addTarget:self action:@selector(mSwithClick:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case 1:
            cell.mImage.image = [UIImage imageNamed:@"own_yjfk"];
            cell.mName.text = @"意见反馈";
            break;
        case 2:
            cell.mImage.image = [UIImage imageNamed:@"own_xinshou"];
            cell.mName.text = @"新手帮助";
            break;
        case 3:
            cell.mImage.image = [UIImage imageNamed:@"own_gy"];
            cell.mName.text = @"关于我们";
            break;
            
        default:
            break;
    }
    
    
    
    return cell;
}


- (void)mSwithClick:(UISwitch *)sw{
    
    if(sw.isOn){
        [SUser relTokenWithPush];
    }else{
        [SUser clearTokenWithPush];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.row) {
        case 1:{
        
            feedBackViewController *feedBack = [[feedBackViewController alloc]initWithNibName:@"feedBackViewController" bundle:nil];
            [self pushViewController:feedBack];
        
        }
            
            break;
        case 2:{
        
        
            WebVC* vc = [[WebVC alloc]init];
            vc.mName = @"新手帮助";
            vc.mUrl = [GInfo shareClient].mHelpUrl;
            [self pushViewController:vc];
        }

            break;
        case 3:{
        
            WebVC* vc = [[WebVC alloc]init];
            vc.mName = @"关于我们";
            vc.mUrl = [GInfo shareClient].mAboutUrl;
            [self pushViewController:vc];
            
        }
            
            break;
            
        default:
            break;
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
