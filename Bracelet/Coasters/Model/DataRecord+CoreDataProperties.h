//
//  DataRecord+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/3/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DataRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataRecord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSDate   *date;                             // 日期（NSDate）
@property (nullable, nonatomic, retain) NSNumber *dateValue;                        // 日期值(8321)
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *isUpload;
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSString *step_array;   // 24小时的步数集合字符串 例如 13，12，45，8，
@property (nullable, nonatomic, retain) NSString *distance_array;// 24小时的距离集合字符串 例如 13，12，45，8，

@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSNumber *step_count;       // 24小时的数据步数总和
@property (nullable, nonatomic, retain) NSNumber *distance_count;   // 24小时的距离总和
@property (nullable, nonatomic, retain) NSNumber *heat_count; // 24小时的消耗热量总和   这个数据来源于实时
                                                              // 如果是二代手环，这个数字要除以10
@property (nullable, nonatomic, retain) NSNumber *situps_count;       // 24小时的仰卧起坐步数总和
@property (nullable, nonatomic, retain) NSNumber *refresh_count;      // 计数器
@property (nullable, nonatomic, retain) NSString *heat_array;// 24小时的热量集合字符串 例如 13，12，45，8，
@property (nullable, nonatomic, retain) NSNumber *ropeSkipping_count;       // 跳绳数量
@property (nullable, nonatomic, retain) NSNumber *swim_count;               // 游泳数量

@property (nullable, nonatomic, retain) NSNumber *heat_situps;         // 今日仰卧起坐消耗热量
@property (nullable, nonatomic, retain) NSNumber *heat_ropeSkipping; // 今日仰卧起坐消耗热量
@property (nullable, nonatomic, retain) NSNumber *heat_swim;        // 今日仰卧起坐消耗热量




@end

NS_ASSUME_NONNULL_END
