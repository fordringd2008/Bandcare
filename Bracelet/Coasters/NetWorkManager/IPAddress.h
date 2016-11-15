//
//  IPAddress.h
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#ifndef WuLiuNoProblem_IPAddress_h
#define WuLiuNoProblem_IPAddress_h

// IP (纯IP)

// IP 地址 (外网)
#define IP @"http://www.sz-hema.net/"
//#define IP @"http://120.25.212.156/"

#define isHttps                    0   // 1: https  2: http

#define _URL_Head                   @"bandcare/"

#define _URL(_k)                   [NSString stringWithFormat:@"%@%@%@",IP, _URL_Head, _k]

#define _URL_Head_1                 @"hm/"

#define _URL_1(_k)                 [NSString stringWithFormat:@"%@%@%@",IP, _URL_Head_1, _k]

#define _ALI_URL                   [NSString stringWithFormat:@"http://plant-data.%@/", ALI_HostId]


#define updateSportData_URL         _URL(@"updateSportData")           // 上传运动数据

#define getSportData_URL            _URL(@"getSportData")              // 获取运动数据

#define updateUserInfo_URL          _URL(@"updateUserInfo")            // 更新用户个人信息

#define getUserInfo_URL             _URL(@"getUserInfo")               // 获取用户个人信息

#define applyFriend_URL             _URL(@"applyFriend")               // 申请加好友

#define getFriendApplyList_URL      _URL(@"getFriendApplyList")        // 获取好友申请列表

#define updateFriendship_URL        _URL(@"updateFriendship")          // 接受或者拒绝好友申请

#define getFriendsInfo_URL          _URL(@"getFriendsInfo")            // 获取好友列表信息

#define pushHintInfo_URL            _URL(@"pushHintInfo")              // 提醒好友运动，回复提醒接口

#define pushLikeInfo_URL            _URL(@"pushLikeInfo")              // 点赞接口

#define getTodayGlobalRank_URL      _URL(@"getTodayGlobalRank")        // 获取今日全球排行榜

#define updateUserSys_URL           _URL(@"updateUserSys")             // 更新系统设置

#define getUserSys_URL              _URL(@"getUserSys")                // 获取系统设置

#define updateFeedback_URL          _URL(@"updateFeedback")            // 意见反馈

#define getPushInfoList_URL         _URL(@"getPushInfoList")           // 获取推送消息列表

#define token_distribute_server_URL _URL_1(@"stsService")              // stsService  (post)



// ----------------------------------------------------------------------
// -----------------------------------------------------    新的登陆流程接口
// ----------------------------------------------------------------------

#define register_URL_1              _URL_1(@"register")                                     // 注册

#define findPassword_URL_1          _URL_1(@"findPassword")                                 // 找回密码

#define login_URL_1                 _URL_1(@"login")                                        // 登陆

#define updatePassword_URL_1        _URL_1(@"updatePassword")                               // 修改密码(邮箱修改)

#define registerByPhone_URL_1       _URL_1(@"registerByPhone")                              // 手机号注册

#define updatePasswordByPhone_URL_1 _URL_1(@"updatePasswordByPhone")                        // 手机号密码重置

#define loginByThird_URL_1          _URL_1(@"loginByThird")                                 // 第三方平台登录

#define getUserToken_URL_1          _URL_1(@"getUserToken")                                 // 获取用户token值

#define updatePushInfo_URL_1        _URL(@"updatePushInfo")                                 // 推送channelId上传

#define authPhoneExist_URL_1        _URL_1(@"authPhoneExist")                               // 验证手机号是否已经注册











#endif
