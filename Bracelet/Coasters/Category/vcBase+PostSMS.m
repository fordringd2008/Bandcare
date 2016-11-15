//
//  vcBase+PostSMS.m
//  Coasters
//
//  Created by 丁付德 on 16/6/18.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase+PostSMS.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>

@implementation vcBase (PostSMS)


-(void)postSMS:(NSString *)phoneNumber countrycode:(NSString *)countrycode block:(void(^)())block
{
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber
                                   zone:countrycode
                       customIdentifier:nil
                                 result:^(NSError *error)
     {
         if (error) {
             NSLog(@"error：%@", error);
             /*
              200	验证成功
              405	AppKey为空
              406	AppKey无效
              456	国家代码或手机号码为空
              457	手机号码格式错误
              466	请求校验的验证码为空
              467	请求校验验证码频繁（5分钟内同一个appkey的同一个号码最多只能校验三次）
              468	验证码错误
              474	没有打开服务端验证开关
              */
             switch (error.code) {
                 case 457:
                     LMBShow(@"手机号码格式错误");
                     break;
                 case 467:
                     LMBShow(@"您发送过于频繁,请稍后再试");
                     break;
             }
         }else
         {
             block();
         }
     }];
}

@end
