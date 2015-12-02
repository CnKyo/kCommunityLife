//
//  addrEdit.m
//  CommunityBuyer
//
//  Created by zzl on 15/9/24.
//  Copyright © 2015年 zdq. All rights reserved.
//

#import "addrEdit.h"
#import "fix_searchInMap.h"
#import "dateModel.h"
@interface addrEdit ()

@end

@implementation addrEdit
{
    SAddress*   _msubmit;
}

- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _msubmit = SAddress.new;
    if( _mHaveAddr )
    {
        self.mname.text = _mHaveAddr.mName;
        self.mtel.text = _mHaveAddr.mMobile;
        self.maddr.text = _mHaveAddr.mAddress;
        self.mdetail.text = _mHaveAddr.mDoorplate;
        self.mPageName = @"编辑地址";
        
        _msubmit.mAddress = _mHaveAddr.mAddress;
        _msubmit.mlat = _mHaveAddr.mlat;
        _msubmit.mlng = _mHaveAddr.mlng;
        
    }
    else
    {
        self.mPageName = @"新增收货地址";
    }
    
    self.Title = self.mPageName;

    
    
    self.rightBtnImage = [UIImage imageNamed:@"gougou"];
 
   
    
}
-(void)rightBtnTouched:(id)sender{
    
    if( self.mname.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请先输入收货人名字"];
        return;
    }
    
    if( self.mtel.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请先输入收货人电话"];
        return;
    }
    
    if( _msubmit.mAddress.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请先选择地址区域"];
        return;
    }
    
    if( self.mdetail.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请先输入详细地址"];
        return;
    }
    
    _msubmit.mId = _mHaveAddr.mId;
    _msubmit.mName = self.mname.text;
    _msubmit.mMobile = self.mtel.text;
    _msubmit.mDoorplate = self.mdetail.text;
    
    __weak addrEdit* rself = self;
    [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
    [_msubmit addOneAddress:^(SResBase *resb, SAddress *retobj) {
        if( resb.msuccess )
        {
            _msubmit =  retobj;
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
            if( rself.itblock )
                rself.itblock( retobj );
            [rself leftBtnTouched:nil];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
    
    
}
- (IBAction)addrTouchDown:(id)sender {
    searchInMap* vc = [[searchInMap alloc]init];
    vc.mNowAddr = _mHaveAddr.mAddress;
    vc.mLat = _mHaveAddr.mlat;
    vc.mLng = _mHaveAddr.mlng;
    
    vc.itblock = ^(NSString* add,float lng,float lat){
        
        _msubmit.mAddress = add;
        _msubmit.mlat = lat;
        _msubmit.mlng = lng;
        self.maddr.text = add;
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
