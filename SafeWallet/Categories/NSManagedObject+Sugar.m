//
//  NSManagedObject+Sugar.m
//
//  Created by Aaron Voisine on 8/22/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "NSManagedObject+Sugar.h"
#import <objc/runtime.h>

static const char *_contextKey = "contextKey";
static const char *_storeURLKey = "storeURLKey";

static NSManagedObjectContextConcurrencyType _concurrencyType = NSMainQueueConcurrencyType;
static NSUInteger _fetchBatchSize = 100;

@implementation NSManagedObject (Sugar)

// MARK: - create objects

+ (instancetype)managedObject
{
    __block NSEntityDescription *entity = nil;
    __block NSManagedObject *obj = nil;
    
    [self.context performBlockAndWait:^{
        entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.context];
        obj = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
    }];
    return obj;
}

+ (NSArray *)managedObjectArrayWithLength:(NSUInteger)length
{
    __block NSEntityDescription *entity = nil;
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:length];
    
    [self.context performBlockAndWait:^{
        entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.context];
        
        for (NSUInteger i = 0; i < length; i++) {
            [a addObject:[[self alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context]];
        }
    }];
    
    return a;
}

// MARK: - fetch existing objects

+ (NSArray *)allObjects
{
    return [self fetchObjects:self.fetchReq];
}

+ (NSArray *)objectsMatching:(NSString *)predicateFormat, ...
{
    NSArray *a;
    va_list args;

    va_start(args, predicateFormat);
    a = [self objectsMatching:predicateFormat arguments:args];
    va_end(args);
    return a;
}

+ (instancetype)anyObjectMatching:(NSString *)predicateFormat, ...
{
    NSArray *a;
    va_list args;
    
    va_start(args, predicateFormat);
    a = [self objectsMatching:predicateFormat arguments:args];
    va_end(args);
    if ([a count]) {
        return [a objectAtIndex:0];
    } else return nil;
}

+ (NSArray *)objectsMatching:(NSString *)predicateFormat arguments:(va_list)args
{
    NSFetchRequest *request = self.fetchReq;
    
    request.predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    return [self fetchObjects:request];
}

+ (instancetype)anyObjectMatching:(NSString *)predicateFormat arguments:(va_list)args
{
    NSArray * array = [self objectsMatching:predicateFormat arguments:args];
    if ([array count]) {
        return [array objectAtIndex:0];
    } else return nil;
}

+ (NSArray *)objectsSortedBy:(NSString *)key ascending:(BOOL)ascending
{
    return [self objectsSortedBy:key ascending:ascending offset:0 limit:0];
}

+ (NSArray *)objectsSortedBy:(NSString *)key ascending:(BOOL)ascending offset:(NSUInteger)offset limit:(NSUInteger)limit
{
    NSFetchRequest *request = self.fetchReq;

    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
    request.fetchOffset = offset;
    request.fetchLimit = limit;
    return [self fetchObjects:request];
}

+ (NSArray *)fetchObjects:(NSFetchRequest *)request
{
//    @synchronized(self) {
        __block NSArray *a = nil;
        __block NSError *error = nil;

        [self.context performBlockAndWait:^{
            @try {
                a = [self.context executeFetchRequest:request error:&error];
                if (error) {}//BRLog(@"%s: %@", __func__, error);
            }
            @catch (NSException *exception) {
        #if DEBUG
                @throw;
        #endif
                // if this is a not a debug build, delete the persisent data store before crashing
                [[NSFileManager defaultManager]
                 removeItemAtURL:objc_getAssociatedObject([NSManagedObject class], &_storeURLKey) error:nil];
                @throw;
            }
        }];
        
        return a;
//    }
}

// MARK: - count exising objects

+ (NSUInteger)countAllObjects
{
    return [self countObjects:self.fetchReq];
}

+ (NSUInteger)countObjectsMatching:(NSString *)predicateFormat, ...
{
    NSUInteger count;
    va_list args;
    
    va_start(args, predicateFormat);
    count = [self countObjectsMatching:predicateFormat arguments:args];
    va_end(args);
    return count;
}

+ (NSUInteger)countObjectsMatching:(NSString *)predicateFormat arguments:(va_list)args
{
    NSFetchRequest *request = self.fetchReq;
    
    request.predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    return [self countObjects:request];
}

+ (NSUInteger)countObjects:(NSFetchRequest *)request
{
    __block NSUInteger count = 0;
    __block NSError *error = nil;

    [self.context performBlockAndWait:^{
        @try {
            count = [self.context countForFetchRequest:request error:&error];
            if (error) {}//BRLog(@"%s: %@", __func__, error);
        }
        @catch (NSException *exception) {
#if DEBUG
            @throw;
#endif
            // if this is a not a debug build, delete the persisent data store before crashing
            [[NSFileManager defaultManager]
             removeItemAtURL:objc_getAssociatedObject([NSManagedObject class], &_storeURLKey) error:nil];
            @throw;
        }
    }];
    
    return count;
}

// MARK: - delete objects

+ (NSUInteger)deleteObjects:(NSArray *)objects
{
    [self.context performBlockAndWait:^{
        for (NSManagedObject *obj in objects) {
            [self.context deleteObject:obj];
        }
    }];
    
    return objects.count;
}

// MARK: - core data stack

// call this before any NSManagedObject+Sugar methods to use a concurrency type other than NSMainQueueConcurrencyType
+ (void)setConcurrencyType:(NSManagedObjectContextConcurrencyType)type
{
    _concurrencyType = type;
}

// set the fetchBatchSize to use when fetching objects, default is 100
+ (void)setFetchBatchSize:(NSUInteger)fetchBatchSize
{
    _fetchBatchSize = fetchBatchSize;
}

// returns the managed object context for the application, or if the context doesn't already exist, creates it and binds
// it to the persistent store coordinator for the application
+ (NSManagedObjectContext *)context
{
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        NSURL *docURL =
            [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        NSURL *modelURL = [NSBundle.mainBundle URLsForResourcesWithExtension:@"momd" subdirectory:nil].firstObject;
        NSString *projName = modelURL.lastPathComponent.stringByDeletingPathExtension;
        NSURL *storeURL = [[docURL URLByAppendingPathComponent:projName] URLByAppendingPathExtension:@"sqlite"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *coordinator =
            [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSError *error = nil;
        
        if ([coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL
             options:@{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                       NSInferMappingModelAutomaticallyOption:@(YES)} error:&error] == nil) {
            //BRLog(@"%s: %@", __func__, error);
#if DEBUG
            abort();
#else
            // if this is a not a debug build, attempt to delete and create a new persisent data store before crashing
            if (! [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]) {
                //BRLog(@"%s: %@", __func__, error);
            }
            
            if ([coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL
                 options:@{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                           NSInferMappingModelAutomaticallyOption:@(YES)} error:&error] == nil) {
                //BRLog(@"%s: %@", __func__, error);
                abort(); // Forsooth, I am slain!
            }
#endif
        }

        if (coordinator) {
            NSManagedObjectContext *moc = nil;

            moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            moc.persistentStoreCoordinator = coordinator;

            objc_setAssociatedObject([NSManagedObject class], &_storeURLKey, storeURL,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [NSManagedObject setContext:moc];

            // this will save changes to the persistent store before the application terminates
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil
             queue:nil usingBlock:^(NSNotification *note) {
                [self saveContext];
            }];
        }
    });

    NSManagedObjectContext *context = objc_getAssociatedObject(self, &_contextKey);

    if (! context && self != [NSManagedObject class]) {
        context = [NSManagedObject context];
        [self setContext:context];
    }

    return (context == (id)[NSNull null]) ? nil : context;
}

// sets a different context for NSManagedObject+Sugar methods to use for this type of entity
+ (void)setContext:(NSManagedObjectContext *)context
{
    objc_setAssociatedObject(self, &_contextKey, (context ? context : [NSNull null]),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// persists changes (this is called automatically for the main context when the app terminates)
+ (void)saveContext
{
//    BRLog(@"save 保存数据线程 %@", [NSThread currentThread]);
    if (! self.context.hasChanges) return;
    
    [self.context performBlockAndWait:^{

        if (self.context.hasChanges) {
            @autoreleasepool {
                NSError *error = nil, *e;
                NSUInteger taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
                
                // this seems to fix unreleased temporary object IDs
            
                [self.context obtainPermanentIDsForObjects:[[[self context] registeredObjects] allObjects] error:&e];
                
                if (! [self.context save:&error]) { // persist changes
                    //BRLog(@"%s: %@", __func__, error);
#if DEBUG
                    abort();
#endif
                    
                }
                
                [self.context.registeredObjects enumerateObjectsUsingBlock:^(__kindof NSManagedObject * _Nonnull obj, BOOL * _Nonnull stop) {
                    [self.context refreshObject:obj mergeChanges:NO];
                }];
                
                [[UIApplication sharedApplication] endBackgroundTask:taskId];
            }
        }
    }];
}

// MARK: - entity methods

// override this if entity name differs from class name
+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (NSFetchRequest *)fetchReq
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];

    request.fetchBatchSize = _fetchBatchSize;
    request.returnsObjectsAsFaults = NO;
    return request;
}

+ (NSFetchedResultsController *)fetchedResultsController:(NSFetchRequest *)request
{
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context
            sectionNameKeyPath:nil cacheName:nil];
}

// id value = entity[@"key"]; thread safe valueForKey:
- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    __block id obj = nil;

    [self.managedObjectContext performBlockAndWait:^{
        obj = [self valueForKey:(NSString *)key];
    }];

    return obj;
}

// entity[@"key"] = value; thread safe setValue:forKey:
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    [self.managedObjectContext performBlockAndWait:^{
        [self setValue:obj forKey:(NSString *)key];
    }];
}

- (void)deleteObject
{
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext deleteObject:self];
    }];
}

+ (void) deleteEntityAllData:(NSString *) entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    //2.创建删除请求  参数是：查询请求
    //NSBatchDeleteRequest是iOS9之后新增的API，不兼容iOS8及以前的系统
    NSBatchDeleteRequest *deletRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    //3.使用存储调度器(NSPersistentStoreCoordinator)执行删除请求
    /**
     Request：存储器请求（NSPersistentStoreRequest）  删除请求NSBatchDeleteRequest继承于NSPersistentStoreRequest
     context：管理对象上下文
     */
    [self.context.persistentStoreCoordinator executeRequest:deletRequest withContext:self.context error:nil];
}


@end
