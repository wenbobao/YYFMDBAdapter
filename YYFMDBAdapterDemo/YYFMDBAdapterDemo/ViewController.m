//
//  ViewController.m
//  YYFMDBAdapterDemo
//
//  Created by bob on 17/2/28.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import "ViewController.h"
#import "Animal.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // create sql
    [self createAnimalSQL];
    // insert sql
    [self insertAnimalSQL];
    // update sql
    [self updateAnimalSQL];
    // delete sql
    [self deleteAnimalSQL];
    // columnValues
    [self columnValues];
    // columnKeyValues
    [self columnKeyValues];
}

- (void)createAnimalSQL
{
    Animal *animal = [[Animal alloc]init];
    NSString *createSQL = [YYFMDBAdapter createTableStatementForModel:animal];
    NSLog(@"%@", createSQL);
}

- (void)insertAnimalSQL
{
    Animal *animal = [[Animal alloc]init];
    animal.name = @"tag";
    animal.sex = @"male";
    animal.age = @10;
    NSString *insertSQL = [YYFMDBAdapter insertStatementForModel:animal];
    NSLog(@"%@", insertSQL);
}

- (void)updateAnimalSQL
{
    Animal *animal = [[Animal alloc]init];
    animal.name = @"tag";
    animal.sex = @"male";
    animal.age = @12;
    NSString *updateSQL = [YYFMDBAdapter updateStatementForModel:animal];
    NSLog(@"%@", updateSQL);
}

- (void)deleteAnimalSQL
{
    Animal *animal = [[Animal alloc]init];
    animal.name = @"tag";
    animal.sex = @"male";
    animal.age = @12;
    NSString *deleteSQL = [YYFMDBAdapter deleteStatementForModel:animal];
    NSLog(@"%@", deleteSQL);
}

- (void)columnKeyValues
{
    Animal *animal = [[Animal alloc]init];
    animal.name = @"tag";
    animal.sex = @"male";
    animal.age = @12;
    NSDictionary *KeyValues = [YYFMDBAdapter columnKeyValues:animal];
    NSLog(@"%@", KeyValues);
}

- (void)columnValues
{
    Animal *animal = [[Animal alloc]init];
    animal.name = @"tag";
    animal.sex = @"male";
    animal.age = @12;
    NSArray *columnValues = [YYFMDBAdapter columnValues:animal];
    NSLog(@"%@", columnValues);
}

@end
