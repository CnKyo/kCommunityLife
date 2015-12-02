//
//  AddressVC.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "AddressVC.h"
#import "AddressCell.h"
#import "addMapVC.h"
#import "searchInMap.h"
#import "addrEdit.h"
@interface AddressVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AddressVC{

    BOOL isload;
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}



- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mPageName = @"常用地址";
    self.Title = self.mPageName;
    
    
    UINib *nib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
    
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    self.tableView = _mTableView;
    self.haveHeader = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = M_BGCO;
    [self.tableView registerNib:nib forCellReuseIdentifier:@"addressCell"];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.rightBtnTitle = @"新增";
    
    [self.tableView headerBeginRefreshing];
    
}

- (void)rightBtnTouched:(id)sender{

    addrEdit* vc = [[addrEdit alloc]initWithNibName:@"addrEdit" bundle:nil];
    vc.itblock = ^(SAddress* retobj)
    {
        if( retobj )
        {
            NSInteger index = self.tempArray.count>0?1:0;
            [self.tempArray insertObject:retobj atIndex:index];
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self removeEmptyView];
        }
        
    };
    
    [self  pushViewController:vc];
}

-(void)headerBeganRefresh
{
    [[SUser currentUser] getMyAddress:^(SResBase *resb, NSArray *arr) {
        
        [self headerEndRefresh];
        if (resb.msuccess) {
            
            
            self.tempArray = [[NSMutableArray alloc] initWithArray:arr];
            
            [self.tableView reloadData];
            if (self.tempArray.count == 0) {
                [self addEmptyViewWithImg:@"noitem"];
            }else
            {
                [self removeEmptyView];
            }
            
        }else
        {
            
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
}


#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

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
    AddressCell *cell = (AddressCell *)[tableView dequeueReusableCellWithIdentifier:@"addressCell"];
    cell.delegate = self;
    cell.mNoAddress.hidden = YES;
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:58.0f];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    
    SAddress *address = [self.tempArray objectAtIndex:indexPath.row];
    cell.mAddress.text = address.mAddress;
    cell.mPhone.text = address.mMobile;
    cell.mName.text = address.mName;
    
    cell.mTopTiao.hidden = !address.mIsDefault;
    cell.mBottomTiao.hidden = !address.mIsDefault;
    
//    cell.mDelBT.tag = indexPath.row;
//    [cell.mDelBT addTarget:self action:@selector(deleteOne:) forControlEvents:UIControlEventTouchUpInside];

  
    return cell;
}

- (void)deleteOne:(UIButton *)sender{

    AddressCell *cell = (AddressCell*)[sender findSuperViewWithClass:[AddressCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];

    SAddress *address = [self.tempArray objectAtIndex:indexpath.row];
    
    [SVProgressHUD showWithStatus:@"操作中"];
    [address delThis:^(SResBase *retobj){
        
        if (retobj.msuccess) {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            
            [self.tempArray removeObjectAtIndex:indexpath.row];
         
            [self.tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
         
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
        
        
    }];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"默认"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"删除"];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SAddress *address = [self.tempArray objectAtIndex:indexPath.row];
    
    switch (index) {
            
        case 0:
        {
            
            
            [SVProgressHUD showWithStatus:@"操作中"];
            __block SAddress* nowdef = nil;
            for ( SAddress* one in self.tempArray ) {
                if( one.mIsDefault )
                    nowdef = one;
            }
            [address setThisDefault:^(SResBase *resb) {
                
                if (resb.msuccess) {
                    
                    [SVProgressHUD showSuccessWithStatus:resb.mmsg];
                    if( nowdef )
                        nowdef.mIsDefault = NO;
                    
                    [self.tableView reloadData];
                    
                }else{
                    
                    [SVProgressHUD showErrorWithStatus:resb.mmsg];
                }
                
            }];
            
            
            break;
        }
        case 1:
        {
            [SVProgressHUD showWithStatus:@"操作中"];
            [address delThis:^(SResBase *retobj){
                
                if (retobj.msuccess) {
                    [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                    
                    [self.tempArray removeObjectAtIndex:indexPath.row];
                    [self.tableView beginUpdates];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    
                }
                else{
                    [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                }
                
                
            }];
            
            
            break;
        }
        default:
            break;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger index = indexPath.row;
    SAddress *address = [self.tempArray objectAtIndex:indexPath.row];
    
    if (_itblock) {
        _itblock(address);
        
        [self popViewController];
        return;
    }
    
    addrEdit* vc = [[addrEdit alloc]initWithNibName:@"addrEdit" bundle:nil];
    vc.mHaveAddr = address;
    vc.itblock = ^(SAddress* retobj)
    {
        if( retobj )
        {
            [self.tempArray replaceObjectAtIndex:index withObject:retobj];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    };
    
    [self pushViewController:vc];
    
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
