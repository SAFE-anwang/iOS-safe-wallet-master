//
//  BRCoreDataManager.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/22.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCoreDataManager.h"

@interface BRCoreDataManager ()

/// 持久化存储协调器
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc;



@end

@implementation BRCoreDataManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               [self saveContext:self.mainContext];
                                                           }];
        
        // 创建托管对象模型，并使用Company.momd路径当做初始化参数
        NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"safeWallet" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
        
        // 创建持久化存储调度器
        self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // 创建并关联SQLite数据库文件，如果已经存在则不会重复创建
        NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
     
        dataPath = [dataPath stringByAppendingFormat:@"/safeWallet.sqlite"];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                                  NSInferMappingModelAutomaticallyOption : @YES};
        
        NSPersistentStore *store =  [self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:options error:nil];
        if (!store) {
            // log error
        }
        
        self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [self.mainContext setPersistentStoreCoordinator:self.psc];
        
        self.backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.backgroundContext.parentContext = self.mainContext;
    }
    return self;
}

- (void)saveContext:(NSManagedObjectContext *)context {
    if (!context || ![context hasChanges]) {
        return;
    }
    [context performBlockAndWait:^{
        NSError *error = nil;
        if (![context save:&error]) {
            BRLog(@"save error!!!");
        }
        if (context.parentContext) {
            // 递归保存
            [self saveContext:context.parentContext];
        }
    }];
}

/**
 创建实体
 */
-(NSManagedObject *)createEntityNamedWith:(NSString *)entityName{
    NSManagedObject* entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self contextForCurrentThread]];
    return entity;
}

// 删除实体
- (void) deleteEntity:(NSArray *)entitylist{
    NSManagedObjectContext *context = [self contextForCurrentThread];
    for(NSManagedObject *obj in entitylist) {
        [context deleteObject:obj];
    }
    // 保存数据
    [self saveContext:context];
}

/**
 删除实体所有数据
 */
- (void) deleteEntityAllData:(NSString *)entity {
    NSManagedObjectContext *context = [self contextForCurrentThread];
    NSArray *allObj = [NSArray arrayWithArray:[self fetchEntity:entity withPredicate:nil]];
    for(NSManagedObject *obj in allObj) {
        [context deleteObject:obj];
    }
    [self saveContext:context];
}

/**
获取当前线程Context
 */
- (NSManagedObjectContext *) contextForCurrentThread {
    if ([NSThread isMainThread]) {
        return self.mainContext;
    } else {
        NSManagedObjectContext* threadContext = [[NSThread currentThread].threadDictionary objectForKey:@"BRThreadContextKey"];
        if (!threadContext) {
            //疑问1：NSPrivateQueueConcurrencyType这个起什么作用
            threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [threadContext setParentContext:self.mainContext];
            [[NSThread currentThread].threadDictionary setObject:threadContext forKey:@"BRThreadContextKey"];
        }
        
        return threadContext;
        
//        return self.backgroundContext;
    }
}

-(NSArray *)fetchObjects:(NSFetchRequest *) request{
    __block NSError* error = nil;
    __block NSArray* result = nil;
    [[self contextForCurrentThread] performBlockAndWait:^{
        result = [[self contextForCurrentThread] executeFetchRequest:request error:&error];
        if (error) {
            BRLog(@"fetchObjects error :%@", [error localizedDescription]);
        }
    }];
    return result;
}

/**
 查询数据
 */
-(NSArray *)fetchEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    __block NSError* error = nil;
    __block NSArray* result = nil;
    [[self contextForCurrentThread] performBlockAndWait:^{
        result = [[self contextForCurrentThread] executeFetchRequest:request error:&error];
        if (error) {
            BRLog(@"fetch %@ error :%@", entityName, [error localizedDescription]);
        }
    }];
    return result;
}

/** 分页查询 */
- (NSArray *)objectsSortedBy:(NSString *)key ascending:(BOOL)ascending offset:(NSUInteger)offset limit:(NSUInteger)limit entity:(NSString *) entityName {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
    request.fetchOffset = offset;
    request.fetchLimit = limit;
    __block NSError* error = nil;
    __block NSArray* result = nil;
    [[self contextForCurrentThread] performBlockAndWait:^{
        result = [[self contextForCurrentThread] executeFetchRequest:request error:&error];
        if (error) {
            BRLog(@"objectsSortedBy fetch %@ error :%@", entityName, [error localizedDescription]);
        }
    }];
    return result;
}

/** 查询带有条件数据 */
- (NSArray *)entity:(NSString *) entityName objectsMatching:(NSPredicate *)predicate{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    __block NSError* error = nil;
    __block NSArray* result = nil;
    [[self contextForCurrentThread] performBlockAndWait:^{
        result = [[self contextForCurrentThread] executeFetchRequest:request error:&error];
        if (error) {
            BRLog(@"fetch %@ error :%@", entityName, [error localizedDescription]);
        }
    }];
   
    return result;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
