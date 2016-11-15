//
//  Friend+CoreDataProperties.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Friend+CoreDataProperties.h"

@implementation Friend (CoreDataProperties)

@dynamic  access;
@dynamic  user_id;
@dynamic  dateTime;
@dynamic  isRequest;             // 是否是别人申请自己的  推送过来的数据 为YES
@dynamic  k_date;
@dynamic  lastRemindDatetime;
@dynamic  tag;


@dynamic  user_sport_target;
@dynamic  user_situps_target;
@dynamic  sport_array;
@dynamic  sport_array_yeaterday;

@dynamic  sport_num;            // 今天的喝水量
@dynamic  situps_num;

@dynamic  distance;
@dynamic  sport_like_num;
@dynamic  situps_like_num;


@dynamic  user_gender;
@dynamic  user_nick_name;
@dynamic  user_pic_url;
@dynamic  user_height;
@dynamic  user_weight;


@dynamic  user_sleep_start_time;
@dynamic  user_sleep_end_time;

@dynamic  last_sportlike_kDate;         // 最后点赞的时期，用来判定是否今天点过了
@dynamic  last_situplike_kDate;


@dynamic  band_type;





@end
