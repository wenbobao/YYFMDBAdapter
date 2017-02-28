//
//  Animal.m
//  YYFMDBAdapterDemo
//
//  Created by bob on 17/2/28.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import "Animal.h"

@implementation Animal

+ (NSDictionary *)FMDBColumnsByPropertyKey
{
    return @{@"name":@"name",
             @"sex":@"sex",
             @"age":@"age"};
}

+ (NSString *)FMDBPrimaryKey
{
    return @"animalID";
}

+ (NSString *)FMDBTableName
{
    return @"Animal";
}

@end
