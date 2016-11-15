//
//  Engine.m
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "NetManager.h"
#import "IPAddress.h"
#import "SecurityUtil.h"

static NSDictionary *NetMangerErrorCode;
@implementation NetManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        if (!NetMangerErrorCode) NetMangerErrorCode = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NetMangerErrorCode" ofType:@"plist"]];
    }
    return  self;
}


-(void)request:(NSString *)urlStr aDic:(NSDictionary *)dic isPost:(BOOL)isPost
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer    = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/plain", @"charset=UTF-8", @"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    if (isHttps)
    {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.securityPolicy = ({
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            [securityPolicy setAllowInvalidCertificates:YES];
            securityPolicy.validatesDomainName = NO;
            securityPolicy;
        });
    }else{
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    manager.requestSerializer.timeoutInterval = 20;
    __block NetManager *blolkSelf = self;
    if (isPost)
    {
        [manager POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress)
         {
             //NSLog(@"uploadProgress : %@", uploadProgress);
         }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
              NSLog(@" %@ 回来了 %@", urlStr,responseObject);
              NSString *status = [((NSDictionary *)responseObject)[@"status"] description];
              if ([NetMangerErrorCode.allKeys containsObject:status]) {
                  NSLog(@"--- 收到异常:%@", NetMangerErrorCode[status]);
              }else{
                 blolkSelf.responseSuccessDic(responseObject);
              }
         }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
         {
             blolkSelf.requestFailError(error);
         }];
    }else{
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
         {
             //NSLog(@"uploadProgress : %@", uploadProgress);
         }
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             NSLog(@"get_back->%@", responseObject);
             NSString *status = [((NSDictionary *)responseObject)[@"status"] description];
             if ([NetMangerErrorCode.allKeys containsObject:status]) {
                 NSLog(@"--- 收到异常:%@", NetMangerErrorCode[status]);
             }else{
                 blolkSelf.responseSuccessDic(responseObject);
             }
         }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
         {
             blolkSelf.requestFailError(error);
         }];
    }
}

- (void)getRequestWithUrlStr:(NSString *)urlStr
{
    NSLog(@"get -> :%@", urlStr);
    [self request:urlStr aDic:nil isPost:NO];
}

- (void)postRequestWithUrlStr:(NSString *)urlStr aDic:(NSDictionary *)dic
{
    NSLog(@"post -> :%@, 参数:%@", urlStr, dic);
    [self request:urlStr aDic:dic isPost:YES];
}

+(void)DF_requestWithAction:(void(^)(NetManager *net))action success:(void(^)(NSDictionary *dic))success failError:(void(^)(NSError *erro))failError inView:(UIView *)inView isShowError:(BOOL)isShowError
{
    __block NetManager *netManager = [[NetManager alloc] init];
    netManager.responseSuccessDic = success;
    __block UIView *blockView = inView;
    netManager.requestFailError = ^(NSError *erro){
        [MBProgressHUD hideAllHUDsForView:blockView animated:YES];
        if(isShowError) [MBProgressHUD show:kString(NONetTip) toView:blockView];
        NSLog(@"%@\n error:%@", NONetTip, erro);
        failError(erro);
    };
    action(netManager);
}


+(void)observeNet
{
    SetUserDefault(DNet, @1);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status) {
             case AFNetworkReachabilityStatusNotReachable:
             case AFNetworkReachabilityStatusUnknown:
             {
                 SetUserDefault(DNet, @0);
                 NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 未知");
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             {
                 SetUserDefault(DNet, @2);
                 NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前网络为 2G/3G/4G");
             }
             case AFNetworkReachabilityStatusReachableViaWiFi:
             {
                 SetUserDefault(DNet, @1);
                 NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前网络为 WIFI");
             }
         }
     }];
}

// 对传进的参数进行加码处理
-(NSString *)encode:(NSString *)string
{
    NSString *str=  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) string,NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return str;
}

-(void)get_finally:(NSString *)string
{
    NSString *url = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self getRequestWithUrlStr:url];
}

-(NSString *)ToUTF8:(NSString *)string
{
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


// ----------------------------------------------------------------------// 上传运动数据
-(void)updateSportData:(NSString *)access
            sport_data:(NSString *)sport_data
{
    if (!access || !sport_data) return;
    NSDictionary *dic = @{@"access":access,
                          @"sport_data":sport_data};
    [self postRequestWithUrlStr:updateSportData_URL aDic:dic];
}

// ----------------------------------------------------------------------// 上传运动数据
-(void)getSportData:(NSString *)access
            user_id:(NSString *)user_id
        k_date_from:(NSString *)k_date_from
          k_date_to:(NSString *)k_date_to
{
    if (!access) return;
    NSDictionary *dic;
    if (user_id)
    {
        
        dic = @{@"access":access,
              @"user_id":user_id,
              @"real_date_from":k_date_from,
              @"real_date_to":k_date_to,
              @"version":@"20"};
    }
    else
    {
        dic = @{@"access":access,
               @"real_date_from": k_date_from,
               @"real_date_to":k_date_to,
               @"version":@"20"};
    }
    [self postRequestWithUrlStr:getSportData_URL aDic:dic];
}

// ----------------------------------------------------------------------// 更新用户个人信息
-(void)updateUserInfo:(NSDictionary *)dic
{
    [self postRequestWithUrlStr:updateUserInfo_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取用户个人信息
-(void)getUserInfo:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserInfo_URL aDic:dic];
}


// ----------------------------------------------------------------------//获取好友申请列表
-(void)getFriendApplyList:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @ {@"access":access };
    [self postRequestWithUrlStr:getFriendApplyList_URL aDic:dic];
}



// ----------------------------------------------------------------------// 接受或者拒绝好友申请
-(void)updateFriendship:(NSString *)access
              friend_id:(NSString *)friend_id
            ship_status:(NSString *)ship_status
{
    if (!access || !friend_id || !ship_status) return;
    NSDictionary *dic = @{@"access":access,
                          @"friend_id":friend_id,
                          @"ship_status":ship_status,
                          @"app_name":AppNameForServer};
    [self postRequestWithUrlStr:updateFriendship_URL aDic:dic];
}


// ----------------------------------------------------------------------// 提醒好友运动，回复提醒接口
-(void)pushHintInfo:(NSString *)access
               type:(NSString *)type
          friend_id:(NSString *)friend_id
       hint_content:(NSString *)hint_content

{
    if (!access || !type || !friend_id || !hint_content) return;
    NSDictionary *dic = @{@"access":access,
                          @"type": type,
                          @"friend_id": friend_id,
                          @"hint_content": hint_content,
                          @"app_name":AppNameForServer};
    [self postRequestWithUrlStr:pushHintInfo_URL aDic:dic];
}


// ----------------------------------------------------------------------// 点赞接口
-(void)pushLikeInfo:(NSString *)access
               type:(int)type
          friend_id:(NSString *)friend_id
    today_real_date:(NSString *)today_real_date
{
    if (!access || !friend_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"type": @(type),
                          @"friend_id": friend_id,
                          @"today_real_date": today_real_date,
                          @"app_name": AppNameForServer,
                          @"version":@"20"
                          };
    [self postRequestWithUrlStr:pushLikeInfo_URL aDic:dic];
}


// ----------------------------------------------------------------------// 获取好友列表信息
-(void)getFriendsInfo:(NSString *)access
      today_real_date:(NSString *)today_real_date
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access,
                          @"today_real_date": today_real_date,
                          @"version":@"20"};
    [self postRequestWithUrlStr:getFriendsInfo_URL aDic:dic];
}


// ----------------------------------------------------------------------// 获取今日全球排行榜
-(void)getTodayGlobalRank:(NSString *)access
          today_real_date:(NSString *)today_real_date
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access,
                          @"today_real_date": today_real_date,
                          @"version":@"20"};
    [self postRequestWithUrlStr:getTodayGlobalRank_URL aDic:dic];
}



// ----------------------------------------------------------------------// 更新系统设置
-(void)updateSysSetting:(NSString *)access
               sys_unit:(BOOL)sys_unit
      sys_notify_status:(BOOL)sys_notify_status
{
    if (!access) return;
    NSDictionary *dic = @{ @"access": access,
                           @"sys_unit": (sys_unit ? @"01" : @"02"),
                           @"sys_notify_status":(sys_notify_status ? @"0":@"1")};
    [self postRequestWithUrlStr:updateUserSys_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取系统设置
-(void)getUserSys:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserSys_URL aDic:dic];
}


// ----------------------------------------------------------------------
// -----------------------------------------------------    新的登陆流程接口
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------// 邮箱注册
-(void)registerByEmail:(NSString *)email
              password:(NSString *)password
{
    if (!email || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"email":email,
                          @"password":password};
    [self postRequestWithUrlStr:register_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 邮箱找回密码
-(void)findPasswordByEmail:(NSString *)email
{
    if (!email) return;
    NSDictionary *dic = @{@"email":email};
    [self postRequestWithUrlStr:findPassword_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 登陆
-(void)login:(NSString *)account
        type:(int)type
    password:(NSString *)password
{
    if (!account || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"account":account,
                          @"type":(type == 1 ? @"01" : @"02"),
                          @"password":password};
    [self postRequestWithUrlStr:login_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 邮箱修改密码
-(void)updatePasswordByEmail:(NSString *)email
                         old:(NSString *)old
                         new:(NSString *)neW
{
    if (!email || !old || !neW) return;
    old = [SecurityUtil encryptAES:old];
    neW = [SecurityUtil encryptAES:neW];
    NSDictionary *dic = @{@"email":email,
                          @"old_password":old,
                          @"new_password":neW};
    [self postRequestWithUrlStr:updatePassword_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 手机号注册
-(void)registerByPhone:(NSString *)phone
              areaCode:(NSString *)areaCode
              authCode:(NSString *)authCode
              password:(NSString *)password
{
    if (!phone || !areaCode || !authCode || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"app_key":SMSAppKey,
                          @"phone":phone,
                          @"area_code":areaCode,
                          @"auth_code":authCode,
                          @"phone_password":password};
    [self postRequestWithUrlStr:registerByPhone_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 手机号密码重置
-(void)updatePasswordByPhone:(NSString *)phone
                    areaCode:(NSString *)areaCode
                    authCode:(NSString *)authCode
                    password:(NSString *)password
{
    if (!phone || !areaCode || !authCode || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"app_key":SMSAppKey,
                          @"phone":phone,
                          @"area_code":areaCode,
                          @"auth_code":authCode,
                          @"phone_password":password};
    [self postRequestWithUrlStr:updatePasswordByPhone_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 第三方平台登录
-(void)loginByThird:(NSString *)typeID
               type:(int)type
{
    if (!typeID) return;
    NSDictionary *dic = @{@"third_party_id":typeID,
                          @"third_type":[NSString stringWithFormat:@"0%d", type]};
    [self postRequestWithUrlStr:loginByThird_URL_1 aDic:dic];
}


// ----------------------------------------------------------------------// 验证手机号是否已经注册
-(void)authPhoneExist:(NSString *)phone
             areaCode:(NSString *)areaCode
{
    if (!phone || !areaCode) return;
    NSDictionary *dic = @{@"phone":phone, @"area_code":areaCode, @"app_key":SMSAppKey};
    [self postRequestWithUrlStr:authPhoneExist_URL_1 aDic:dic];
}




// ----------------------------------------------------------------------// 申请加好友
-(void)applyFriend:(NSString *)access
    friend_account:(NSString *)friend_account
friend_account_type:(NSString *)friend_account_type
      push_content:(NSString *)push_content
{
    if (!access || !friend_account || !friend_account_type || !push_content) return;
    NSDictionary *dic = @{@"access":access,
                          @"friend_account":friend_account,
                          @"friend_account_type":friend_account_type,
                          @"push_content":push_content,
                          @"app_name":AppNameForServer};
    [self postRequestWithUrlStr:applyFriend_URL aDic:dic];
}

// ----------------------------------------------------------------------//获取推送消息列表
-(void)getPushInfoList:(NSString *)access
                  time:(long long)time
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access,@"time":@(time)};
    [self postRequestWithUrlStr:getPushInfoList_URL aDic:dic];
}




// ----------------------------------------------------------------------// 意见反馈
-(void)updateFeedback:(NSString *)access
              content:(NSString *)content
{
    if (!access || !content) return;
    NSDictionary *dic = @{@"access":access,@"content":content};
    [self postRequestWithUrlStr:updateFeedback_URL aDic:dic];
}


// ----------------------------------------------------------------------// token-distribute-server
-(void)getToken_distribute_server:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:token_distribute_server_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取用户token值
-(void)getUserToken:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserToken_URL_1 aDic:dic];
}

@end
