//
//  AppDelegate.m
//  XiCheBuyer
//
//  Created by 周大钦 on 15/6/18.
//  Copyright (c) 2015年 zdq. All rights reserved.
//

#import "AppDelegate.h"
#import "MyInfoVC.h"
#import "OrderVC.h"
#import "dateModel.h"
#import "MTA.h"
#import <QMapKit/QMapKit.h>
#import "WXApi.h"
#import "CBCUtil.h"
#import "APService.h"
#import "WebVC.h"
#import "OrderDetailVC.h"
#import <AlipaySDK/AlipaySDK.h>


#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "MessageVC.h"



@interface AppDelegate ()<WXApiDelegate>

@end

@interface myalert : UIAlertView

@property (nonatomic,strong) id obj;

@end

@implementation myalert


@end


@implementation AppDelegate

+(AppDelegate *)shareAppDelegate
{
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    return app;
}
-(void)initExtComp
{
    [MTA startWithAppkey:@"IKHT7IKM935M"];
    
    [QMapServices sharedServices].apiKey = QQMAPKEY;
    
    [WXApi registerApp:@"wx84ca610fce9ab38f" withDescription:[Util getAPPName]];
    
    [ShareSDK registerApp:@"90bafc5f1caa"];//字符串api20为您的ShareSDK的AppKey
    
//    //添加新浪微博应用
//    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
//                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                             redirectUri:@"http://www.sharesdk.cn"];
//    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
//    [ShareSDK  connectSinaWeiboWithAppKey:@"568898243"
//                                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                              redirectUri:@"http://www.sharesdk.cn"
//                              weiboSDKCls:[WeiboSDK class]];
//    
//    
//    //添加QQ应用
//    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
//                     qqApiInterfaceCls:[QQApiInterface class]
//                       tencentOAuthCls:[TencentOAuth class]];
//    
//    //添加微信应用
//    [ShareSDK connectWeChatWithAppId:@"wxa2ca4ec0aa044c24"
//                           wechatCls:[WXApi class]];
//    //微信登陆的时候需要初始化
//    [ShareSDK connectWeChatWithAppId:@"wxa2ca4ec0aa044c24"
//                           appSecret:@"adb78dc62d78adc1b013c75574954cb7"
//                           wechatCls:[WXApi class]];
    
}


//15123380391
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [self initExtComp];
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
    
    
    [APService setupWithOption:launchOptions];
    
    [SUser relTokenWithPush];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"push object :%@",[defaults objectForKey:@"push"]);
    
    if( notificationPayload )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:notificationPayload forKey:@"push"];
        
        [defaults synchronize];
        
        [self performSelector:@selector(PushController:) withObject:notificationPayload afterDelay:1];
        
        
    }
    
    [[SAppInfo shareClient] getUserLocation:YES block:^(NSString *err) {
        
    }];
    
    return YES;
}

- (void)PushController:(NSDictionary *)dic{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"push_Message" object:dic];

}




-(void)gotoLogin
{
    LoginVC* vc = [[LoginVC alloc]init];
    
    [(UINavigationController*)((UITabBarController*)self.window.rootViewController).selectedViewController pushViewController:vc animated:YES];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    MLLog(@"hhhhhhurl:%@",url);
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // url:wx206e0a3244b4e469://pay/?returnKey=&ret=0 withsouce url:com.tencent.xin
    MLLog(@"url:%@ withsouce url:%@",url,sourceApplication);
    if ([url.host isEqualToString:@"safepay"])
    {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      
                                                      MLLog(@"xxx:%@",resultDic);
                                                      
                                                      SResBase* retobj = nil;
                                                      
                                                      if (resultDic)
                                                      {
                                                          if ( [[resultDic objectForKey:@"resultStatus"] intValue] == 9000 )
                                                          {
                                                              SResBase* retobj = [[SResBase alloc]init];
                                                              retobj.msuccess = YES;
                                                              retobj.mmsg = @"支付成功";
                                                              retobj.mcode = 0;
                                                              [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                                                          }
                                                          else
                                                          {
                                                              retobj = [SResBase infoWithError: [resultDic objectForKey:@"memo" ]];
                                                              [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                                                          }
                                                      }
                                                      else
                                                      {
                                                          retobj = [SResBase infoWithError: @"支付出现异常"];
                                                          [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                                                      }
                                                  }];
        return YES;
    }
    else if( [sourceApplication isEqualToString:@"com.tencent.xin"] )
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

-(void) onResp:(BaseResp*)resp
{
    if( [resp isKindOfClass: [PayResp class]] )
    {
        NSString *strMsg    =   [NSString stringWithFormat:@"errcode:%d errmsg:%@ payinfo:%@", resp.errCode,resp.errStr,((PayResp*)resp).returnKey];
        MLLog(@"payresp:%@",strMsg);
        
        SResBase* retobj = SResBase.new;
        if( resp.errCode == -1 )
        {//
            retobj.msuccess = NO;
            retobj.mmsg = @"支付出现异常";
        }
        else if( resp.errCode == -2 )
        {
            retobj.msuccess = NO;
            retobj.mmsg = @"用户取消了支付";
        }
        else
        {
            retobj.msuccess = YES;
            retobj.mmsg = @"支付成功";
        }
        
        if( [SAppInfo shareClient].mPayBlock )
        {
            [SAppInfo shareClient].mPayBlock(retobj);
        }
        else
        {
            MLLog(@"may be err no block to back");
        }
    }
    else
    {
        MLLog(@"may be err what class one onResp");
    }
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   
    [application setApplicationIconBadgeNumber:0];
    [APService resetBadge];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



/*
 sourceApplication:
 
 1.com.tencent.xin
 
 2.com.alipay.safepayclient
 */


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"reg push err:%@",error);
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
    
    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateActive) {
        
        [self dealPush:userInfo bopenwith:NO];
    }
    else
    {
        [self dealPush:userInfo bopenwith:YES];
    }
}
-(void)dealPush:(NSDictionary*)userinof bopenwith:(BOOL)bopenwith
{
    
    SMessageInfo* pushobj = [[SMessageInfo alloc]initWithAPN:userinof];
    
    if( !bopenwith )
    {//当前用户正在APP内部,,
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushnotfi" object:nil];
        
        myalert *alertVC = [[myalert alloc]initWithTitle:@"提示" message:@"有新的消息是否查看?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        alertVC.obj = pushobj;
        [alertVC show];
    }
    else
    {
        [self dealMsg:pushobj];
    }
}






- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        SMessageInfo* pushobj = ((myalert *)alertView).obj;
        [self dealMsg:pushobj];
    }
}

-(void)dealMsg:(SMessageInfo*)obj
{
    if( obj.mType == 1 )
    {
        
        MessageVC *msg = [[MessageVC alloc] init];
        
        [(UINavigationController*)((UITabBarController*)self.window.rootViewController).selectedViewController pushViewController:msg animated:YES];
    }
    else if( obj.mType == 2 )
    {
        WebVC* vc = [[WebVC alloc]init];
        vc.mName = @"详情";
        vc.mUrl = obj.mArgs;
        [(UINavigationController*)((UITabBarController*)self.window.rootViewController).selectedViewController pushViewController:vc animated:YES];
    }
    else if( obj.mType == 3 || obj.mType == 4 )
    {
        [OrderDetailVC gotoOrderDetailWithOrderId:[obj.mArgs intValue] vc:((UINavigationController *)(((UITabBarController*)self.window.rootViewController).selectedViewController)).topViewController];
        
        
    }
    
}



- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    
    NSLog(@"tag:%@ alias%@ irescod:%d",tags,alias,iResCode);
    if( iResCode == 6002 )
    {
        [SUser relTokenWithPush];
    }
    
}
@end
