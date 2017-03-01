//
//  YYFMDBAdapter.m
//  YDKit
//
//  Created by bob on 16/8/26.
//  Copyright © 2016年 __company__. All rights reserved.
//

#import "YYFMDBAdapter.h"
#import "YYModel.h"

@implementation YYFMDBAdapter

+ (NSArray *)columnValues:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
    
    NSSet *propertyKeys = model.YYPropertyKeys;
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    NSDictionary *dictionaryValue = model.YYPropertyValues;
    
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *propertyKey in Keys)
    {
        NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]])
        {
            [values addObject:[dictionaryValue valueForKey:propertyKey]];
        }
    }
    return values;
}

+ (NSDictionary *)columnKeyValues:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
    
    NSSet *propertyKeys = model.YYPropertyKeys;
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    NSDictionary *dictionaryValue = model.YYPropertyValues;
    
    for (NSString *propertyKey in Keys)
    {
        NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]])
        {
            [values setObject:[dictionaryValue valueForKey:propertyKey] forKey:keyPath];
        }
    }
    return values;
}

+ (NSString *)insertStatementForModel:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
    
    NSSet *propertyKeys = model.YYPropertyKeys;
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *stats = [NSMutableArray array];
    NSMutableArray *qmarks = [NSMutableArray array];
    for (NSString *propertyKey in Keys)
    {
        NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]])
        {
            [stats addObject:keyPath];
            [qmarks addObject:[NSString stringWithFormat:@":%@",keyPath]];
        }
    }
    
    NSString *statement = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [self tableNameForModel:model], [stats componentsJoinedByString:@", "], [qmarks componentsJoinedByString:@", "]];
    
    return statement;
}

+ (NSString *)updateStatementForModel:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
    
    NSSet *propertyKeys = model.YYPropertyKeys;
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *stats = [NSMutableArray array];
    for (NSString *propertyKey in Keys) {
        NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]] && ![keyPath isEqualToString:[model.class FMDBPrimaryKey]]) {
            NSString *s = [NSString stringWithFormat:@"%@ = :%@", keyPath,keyPath];
            [stats addObject:s];
        }
    }
    
    return [NSString stringWithFormat:@"update %@ set %@ where %@",  [self tableNameForModel:model], [stats componentsJoinedByString:@", "], [self whereStatementForModel:model]];
}

+ (NSString *)deleteStatementForModel:(NSObject<YYFMDBSerializing> *)model {
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    
    return [NSString stringWithFormat:@"delete from %@ where %@",  [self tableNameForModel:model], [self whereStatementForModel:model]];
}

+ (NSString *)whereStatementForModel:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    // Build the where statement
    NSString *primaryKey = [model.class FMDBPrimaryKey];
    NSMutableArray *where = [NSMutableArray array];

    NSString *s = [NSString stringWithFormat:@"%@ = :%@", primaryKey,primaryKey];
    [where addObject:s];
    return [where componentsJoinedByString:@" AND "];
}

+ (NSString *)tableNameForModel:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);

    NSString *tableName = NSStringFromClass(model.class);
    if ([model.class respondsToSelector:@selector(FMDBTableName)]) {
        tableName = [(id<YYFMDBSerializing>)model.class FMDBTableName];
    }
    return tableName;
}

+ (NSString *)createTableStatementForModel:(NSObject<YYFMDBSerializing> *)model
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(YYFMDBSerializing)]);
    
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"create table if not exists %@ ",  [self tableNameForModel:model]];
    
    [resultString appendString:[NSString stringWithFormat:@"( %@ integer primary key", [model.class FMDBPrimaryKey]]];
    
    NSDictionary *dic = model.YYPropertyNameAndTypes;
    NSDictionary *sqlDic = [YYFMDBAdapter sqlTypeDictionary];
    
    NSDictionary *colmnDic = [YYFMDBAdapter columnByPropertyKeyWithModel:model];

    for (NSString *key in dic.allKeys) {
        NSString *type = dic[key];
        
        type = [[type substringFromIndex:2]substringToIndex:([type substringFromIndex:2].length-1)];
        
        if ([sqlDic.allKeys containsObject:type]) {
            NSString *value = colmnDic[key];
            if (![value isEqualToString:[model.class FMDBPrimaryKey]]) {
                [resultString appendFormat:@",%@ %@", value, sqlDic[type]];
            }
        }
    }
    
    [resultString appendString:@")"];
    
    return resultString;
}

+ (NSDictionary *)columnByPropertyKeyWithModel:(NSObject<YYFMDBSerializing> *)model {

    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
    
    NSSet *propertyKeys = model.YYPropertyKeys;
    
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableDictionary *stats = [NSMutableDictionary dictionary];
    
    for (NSString *propertyKey in Keys) {
        NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]]) {
            [stats setObject:keyPath forKey:propertyKey];
        }
    }
    
    return stats;
}

+ (NSDictionary *)sqlTypeDictionary {
    static NSDictionary *sqlTypeDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlTypeDictionary = @{
                              @"char" : @"integer",
                              @"int" : @"integer",
                              @"short" : @"integer",
                              @"long" : @"integer",
                              @"long long" : @"integer",
                              @"unsigned char" : @"integer",
                              @"unsigned int" : @"integer",
                              @"unsigned short" : @"integer",
                              @"unsigned long" : @"integer",
                              @"unsigned long long" : @"integer",
                              @"float" : @"float",
                              @"double" : @"double",
                              @"bool" : @"bool",
                              @"BOOL" : @"bool",
                              @"NSString" : @"text",
                              @"NSNumber" : @"real",
                              @"NSNumber" : @"real",
                              @"NSDate" : @"integer",
                              @"NSData" : @"blob",
                              @"NSInteger" : @"integer",
                              };
    });
    
    return sqlTypeDictionary;
}

@end


@implementation NSObject (YYExtendModel)

- (NSDictionary *)YYPropertyNameAndTypes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    Class cls = [self class];
    
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:cls];
    
    // Get black list
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(FMDBConvertBlackList)]) {
        NSArray *properties = [(id<YYFMDBSerializing>)cls FMDBConvertBlackList];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    YYClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        
        for (YYClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            [result setObject:propertyInfo.typeEncoding forKey:propertyInfo.name];
        }
        
        curClassInfo = curClassInfo.superClassInfo;
    }
    
    return result;
}

- (NSSet *)YYPropertyKeys
{
    NSMutableSet *keys = [NSMutableSet set];
    
    Class cls = [self class];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:cls];
    
    // Get black list
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(FMDBConvertBlackList)]) {
        NSArray *properties = [(id<YYFMDBSerializing>)cls FMDBConvertBlackList];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    YYClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        
        for (YYClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            [keys addObject:propertyInfo.name];
        }
        
        curClassInfo = curClassInfo.superClassInfo;
    }
    
    return keys;
}

- (NSDictionary *)YYPropertyValues
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    Class cls = [self class];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:cls];
    
    // Get black list
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(FMDBConvertBlackList)]) {
        NSArray *properties = [(id<YYFMDBSerializing>)cls FMDBConvertBlackList];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    YYClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        
        for (YYClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            
            id mValue = [self valueForKey:propertyInfo.name];
            
            if (!mValue) {
                mValue = @"";
            }
            
            [result setObject:mValue forKey:propertyInfo.name];
        }
        
        curClassInfo = curClassInfo.superClassInfo;
    }
    
    return result;
}

- (NSArray *)YYPropertyArrayValues
{
    NSMutableArray *result = [NSMutableArray array];
    
    Class cls = [self class];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:cls];
    
    // Get black list
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(FMDBConvertBlackList)]) {
        NSArray *properties = [(id<YYFMDBSerializing>)cls FMDBConvertBlackList];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    YYClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        
        for (YYClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            
            id mValue = [self valueForKey:propertyInfo.name];
            
            if (!mValue) {
                mValue = @"";
            }
            
            [result addObject:mValue];
        }
        
        curClassInfo = curClassInfo.superClassInfo;
    }
    
    return result;
}

@end

