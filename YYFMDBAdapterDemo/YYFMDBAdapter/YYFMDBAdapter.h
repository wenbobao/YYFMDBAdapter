//
//  YYFMDBAdapter.h
//  YDKit
//
//  Created by bob on 16/8/26.
//  Copyright © 2016年 __company__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YYModel;
@class FMResultSet;

@protocol YYFMDBSerializing

@required

+ (NSDictionary *)FMDBColumnsByPropertyKey;

// 注: 不建议使用复合主键
+ (NSString *)FMDBPrimaryKey;

@optional

// 表名
// 默认使用类名
+ (NSString *)FMDBTableName;

+ (NSArray *)FMDBConvertBlackList;

@end

@interface YYFMDBAdapter : NSObject

+ (NSArray *)columnValues:(NSObject<YYFMDBSerializing> *)model;

+ (NSDictionary *)columnKeyValues:(NSObject<YYFMDBSerializing> *)model;

+ (NSString *)insertStatementForModel:(NSObject<YYFMDBSerializing> *)model;

+ (NSString *)updateStatementForModel:(NSObject<YYFMDBSerializing> *)model;

+ (NSString *)deleteStatementForModel:(NSObject<YYFMDBSerializing> *)model;

+ (NSString *)createTableStatementForModel:(NSObject<YYFMDBSerializing> *)model;

@end


@interface NSObject (YYExtendModel)

- (NSDictionary *)YYPropertyNameAndTypes;

- (NSSet *)YYPropertyKeys;

- (NSDictionary *)YYPropertyValues;

- (NSArray *)YYPropertyArrayValues;

@end
