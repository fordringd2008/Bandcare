//
//  Friend+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Friend.h"

NS_ASSUME_NONNULL_BEGIN

@interface Friend (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSDate * dateTime;
@property (nullable, nonatomic, retain) NSNumber *isRequest;             // 是否是别人申请自己的  推送过来的数据 为YES
@property (nullable, nonatomic, retain) NSNumber *k_date;
@property (nullable, nonatomic, retain) NSDate *lastRemindDatetime;
@property (nullable, nonatomic, retain) NSNumber *tag;

@property (nullable, nonatomic, retain) NSNumber *user_sport_target;
@property (nullable, nonatomic, retain) NSNumber *user_situps_target;
@property (nullable, nonatomic, retain) NSString *sport_array_yeaterday;// 昨天的运动数据
@property (nullable, nonatomic, retain) NSString *sport_array;
@property (nullable, nonatomic, retain) NSNumber *sport_num;            // 今天的总步数
@property (nullable, nonatomic, retain) NSNumber *situps_num;           // 今天的总仰卧起坐个个数

@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *sport_like_num;
@property (nullable, nonatomic, retain) NSNumber *situps_like_num;


@property (nullable, nonatomic, retain) NSNumber *user_gender;
@property (nullable, nonatomic, retain) NSString *user_nick_name;
@property (nullable, nonatomic, retain) NSString *user_pic_url;
@property (nullable, nonatomic, retain) NSNumber *user_height;
@property (nullable, nonatomic, retain) NSNumber *user_weight;


@property (nullable, nonatomic, retain) NSString *user_sleep_start_time;
@property (nullable, nonatomic, retain) NSString *user_sleep_end_time;

// 最后点赞的时期，用来判定是否今天点过了
@property (nullable, nonatomic, retain) NSNumber *last_sportlike_kDate;
@property (nullable, nonatomic, retain) NSNumber *last_situplike_kDate;

@property (nullable, nonatomic, retain) NSNumber *band_type;





@end

NS_ASSUME_NONNULL_END
