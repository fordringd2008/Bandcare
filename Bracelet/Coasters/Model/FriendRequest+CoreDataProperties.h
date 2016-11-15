//
//  FriendRequest+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FriendRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequest (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;               // 当前用户
@property (nullable, nonatomic, retain) NSDate *dateTime;               // 申请时间
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSString *friend_id;            // 请求的 用户ID
@property (nullable, nonatomic, retain) NSString *friend_msg;           // 用户自定义的语句
@property (nullable, nonatomic, retain) NSString *friend_name;          // 请求的 用户名称
@property (nullable, nonatomic, retain) NSNumber *isOver;               // 是否已经处理过
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSNumber *type;                 // 1:申请我  2:接受我  3:提醒我  4:回复提醒喝水  5:点赞
@property (nullable, nonatomic, retain) NSString *user_pic_url;         // 头像地址
@property (nullable, nonatomic, retain) NSNumber *year;                 // 年      （方便帅选）

@end

NS_ASSUME_NONNULL_END
