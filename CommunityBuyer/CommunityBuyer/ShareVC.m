//
//  ShareVC.m
//  JiaZhengBuyer
//
//  Created by 周大钦 on 15/7/29.
//  Copyright (c) 2015年 zdq. All rights reserved.
//


#import "ShareVC.h"
#import <ShareSDK/ShareSDK.h>


@interface ShareVC ()<ISSShareViewDelegate>{


}

@end

@implementation ShareVC

- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    self.mPageName = @"分享";
    self.Title = self.mPageName;
    [_mImage sd_setImageWithURL:[NSURL URLWithString:[GInfo shareClient].mShareQrCodeImage] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
    
   
}



- (IBAction)ShareXinLang:(id)sender {
    
    [self Share:ShareTypeSinaWeibo];
}
- (IBAction)SharePengyouquan:(id)sender {
    [self Share:ShareTypeWeixiTimeline];
}
- (IBAction)ShareWeiXin:(id)sender {
    [self Share:ShareTypeWeixiSession];
}
- (IBAction)SareQQ:(id)sender {
    [self Share:ShareTypeQQ];
}

- (void)Share:(ShareType)type{
    
    
    NSLog(@"%@;%@;%@",[GInfo shareClient].mshareUrl,[GInfo shareClient].mShareTitle,[GInfo shareClient].mShareContent);
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[GInfo shareClient].mShareContent
                                       defaultContent:@""
                                                image:[ShareSDK pngImageWithImage:[UIImage imageNamed:@"AppIcon"]]
                                                title:[GInfo shareClient].mShareTitle
                                                  url:[GInfo shareClient].mshareUrl
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    //自定义标题栏相关委托
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:self
                                               authManagerViewDelegate:nil];
    //自定义标题栏相关委托
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"分享"
                                                              oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                               qqButtonHidden:YES
                                                        wxSessionButtonHidden:YES
                                                       wxTimelineButtonHidden:YES
                                                         showKeyboardOnAppear:NO
                                                            shareViewDelegate:self
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];
  
    
    [ShareSDK clientShareContent:publishContent
                            type:type
                     authOptions:authOptions
                    shareOptions:shareOptions
                   statusBarTips:NO
                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                              NSLog(@"state:%u",state);
                              if (state == SSPublishContentStateSuccess)
                              {
                                 
                                [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                                  
                                  
                              }
                              else if(state == 3){//取消返回
                                  
                              }
                              else if (state == SSPublishContentStateFail)//失败
                              {
                                  [SVProgressHUD showErrorWithStatus:[error errorDescription]];//[error errorDescription]@"加载分享内容失败,请检查网络后重试"
                              }
                          }];//??????

    
    
}

#pragma mark - ISSShareViewDelegate
- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType

{
    
    //修改分享编辑框的标题栏颜色
    viewController.navigationController.navigationBar.barTintColor = COLOR(67, 161, 263);
    
    //将分享编辑框的标题栏替换为图片
    //    UIImage *image = [UIImage imageNamed:@"iPhoneNavigationBarBG.png"];
    //    [viewController.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
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
