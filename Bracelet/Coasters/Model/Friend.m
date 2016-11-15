//
//  Friend.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "Friend.h"


@implementation Friend

// Insert code here to add functionality to your managed object subclass

-(void)perfect
{
    [self perfect:NULL];
}

- (void)perfect:(void (^)(id model))perfectBlock
{
    self.dateTime = [DFD HmF2KNSIntToDate:[self.k_date intValue]];
    if (perfectBlock)
        perfectBlock(self);
}


// 这里的name 是属性的名字
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([property.name isEqualToString:@"last_sportlike_kDate"])
    {
        if (!oldValue || ![oldValue boolValue]) return @0;
        else
        {
            return @([DFD HmF2KNSDateToInt:DNow]);
        }
    }
    return oldValue;
}

// return @{@“模型属性名” : @“json数组的key”};
// 注意：这里如果 主键或者双主键中的 参与了映射， objectByDictionary 中方法需要 value 需要改动
+ (NSDictionary *)replacedKeyFromPropertyName
{
    /*
     sport_like_status	int	今天是否已对运动步数点赞 0：没有点赞；1：已点赞
     situps_like_status	int	今天是否已对仰卧起坐点赞 0：没有点赞；1：已点赞
     */
    
    return @{ @"user_id":@"userid",
              @"last_sportlike_kDate":@"sport_like_status",
              @"last_situplike_kDate":@"situps_like_status"};
    
    // band_type
    
    // 这里  sport_like_status: @"0" --> @0;                               今天没有点赞， 最后点赞日期为0
    // 这里  sport_like_status: @"1" --> @([DFD HmF2KNSDateToInt:DNow]);   今天  有点赞， 最后点赞日期为今天
}


+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    NSString *primary2 = @"userid";
    id value1          = myUserInfoAccess;
    id value2          = [dictionary objectForKey:primary2];
    // 这里需要是属性名 |||
    Friend *model = [Friend MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", value1, value2] inContext:context];
    if (model)
    {
        model = [model mj_setKeyValues:dictionary context:context];
        //NSLog(@"去更新");
    }
    else
    {
        model = [self mj_objectWithKeyValues:dictionary context:context];
        if (model) {
            //NSLog(@"插入成功");
        }else{
            //NSLog(@"插入失败");
        }
    }
    [model perfect:perfectBlock];
    [context MR_saveToPersistentStoreAndWait];
    DBSave
    return model;
}


@end
