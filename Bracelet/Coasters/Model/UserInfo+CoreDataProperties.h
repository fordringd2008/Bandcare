//
//  UserInfo+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/3/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;               // 权限
@property (nullable, nonatomic, retain) NSString *account;              // 邮箱 也可能是 手机号 或者 第三方登陆ID
@property (nullable, nonatomic, retain) NSNumber *isNeedUpdate;         // 是否需要上传个人信息      BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *loginType;        // 0 邮箱 1 手机 2 QQ 3 新浪 4 face 5 twitt
@property (nullable, nonatomic, retain) NSString *user_pic_url;         // 头像
@property (nullable, nonatomic, retain) NSData   *orData;               // 二维码图片
@property (nullable, nonatomic, retain) NSString *password;             // 密码
@property (nullable, nonatomic, retain) NSString *area_code;            // 国家电话前缀 非手机号登陆为空字符串
@property (nullable, nonatomic, retain) NSString *pName;                // 外设名称
@property (nullable, nonatomic, retain) NSString *pUUIDString;          // 外设UUIDString
@property (nullable, nonatomic, retain) NSNumber *swithShowSreenWhenPut;// 手环抬手亮屏   BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *swithShowMenu;        // 手环日期菜单是否显示     BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *swithShockWhenDisconnect;// 蓝牙断开是否震动   BOOL 类型
@property (nullable, nonatomic, retain) NSString *token;                // token 验证登录，如改变，用户需重新登录
@property (nullable, nonatomic, retain) NSNumber *unit;                 // 单位 BOOL 类型 YES:公制  NO:英制
@property (nullable, nonatomic, retain) NSNumber *update_time;          // 更新时间
@property (nullable, nonatomic, retain) NSDate   *user_birthday;        // 生日
@property (nullable, nonatomic, retain) NSNumber *user_gender;    // 性别 (bool)类型   0：男；1：女 （和接口一致）
@property (nullable, nonatomic, retain) NSNumber *user_height;          // 身高   单位 cm       doubleValue
@property (nullable, nonatomic, retain) NSNumber *user_id;              // 用户的ID  用于向别人发送请求 和接受请求用
@property (nullable, nonatomic, retain) NSString *user_nick_name;       // 昵称
@property (nullable, nonatomic, retain) NSNumber *user_sport_target;    // 用户运动步数目标值
@property (nullable, nonatomic, retain) NSNumber *user_weight;          // 体重   单位 kg       doubleValue
@property (nullable, nonatomic, retain) NSString *user_language_code;   // 01：中文；02：英文；03：法文
@property (nullable, nonatomic, retain) NSString *user_sleep_start_time;// 用户睡觉开始时间，例："0930"表示9点半
@property (nullable, nonatomic, retain) NSString *user_sleep_end_time;  // 用户睡觉结束时间
@property (nullable, nonatomic, retain) NSNumber *user_situps_target;   // 用户仰卧起坐目标数
@property (nullable, nonatomic, retain) NSNumber *sport_like_number;    // 今日用户的运动点赞个数
@property (nullable, nonatomic, retain) NSNumber *situps_like_number;   // 今日用户的仰卧点赞个数


@end

NS_ASSUME_NONNULL_END
