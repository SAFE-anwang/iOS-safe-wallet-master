//
//  BRCoreDataManager.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/22.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BRCoreDataManager : NSObject

/// 创建单例对象
+ (instancetype)sharedInstance;

/**
 提交指定托管对象上下文的改动
 
 @param context 指定的托管对象上下文
 */
- (void)saveContext:(NSManagedObjectContext *)context;

#pragma mark - plan 1 core data stack


/// 主上下文 用于UI协作或其他使用主线程的情况
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

/**
 创建一个用于操作的私有上下文
 */
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;

/**
 获取当前线程Context
 */
- (NSManagedObjectContext *) contextForCurrentThread;


/**
 创建实体
 */
-(NSManagedObject *)createEntityNamedWith:(NSString *)entityName;

/** 删除实体 */
- (void) deleteEntity:(NSArray *)entitylist;

/**
 删除表中所有数据
 */
- (void) deleteEntityAllData:(NSString *)entity;

/** 分页查询 */
- (NSArray *)objectsSortedBy:(NSString *)key ascending:(BOOL)ascending offset:(NSUInteger)offset limit:(NSUInteger)limit entity:(NSString *) entityName;

/**
 查询数据
 */
-(NSArray *)fetchEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

/** 查询带有条件数据 */
- (NSArray *)entity:(NSString *) entityName objectsMatching:(NSPredicate *) predicate;

-(NSArray *)fetchObjects:(NSFetchRequest *) request;


@end
