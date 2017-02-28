//
//  Animal.h
//  YYFMDBAdapterDemo
//
//  Created by bob on 17/2/28.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYFMDBAdapter.h"

@interface Animal : NSObject <YYFMDBSerializing>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, strong) NSNumber *age;

@end
