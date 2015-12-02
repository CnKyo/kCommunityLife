

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFURLResponseSerialization.h"


@class SResBase;

@interface APIClient : AFHTTPRequestOperationManager

+ (APIClient *)sharedClient;

-(void)getUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)( SResBase* info))callback;

-(void)postUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)( SResBase* info))callback;

- (void)cancelHttpOpretion:(AFHTTPRequestOperation *)http;
+ (NSString *)APiWithUrl:(NSString *)mUrl;
+ (NSString *)wapWithUrl:(NSString *)path;
+ (NSString *)NoWapUrl:(NSString *)path;
@end
