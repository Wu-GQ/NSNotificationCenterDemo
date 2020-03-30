//
//  MyNotificationCenter.m
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/21.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "MyNotificationCenter.h"
#import "TwoWayLinkedList.h"
#import "MyNotificationModel.h"


@interface MyNotificationCenter ()

// MASK: 此处使用双向链表，因为不需要通过下标访问，增删操作比较多，基本没有查找操作
@property(nonatomic, strong) NSMutableDictionary<id, NSMutableDictionary<id, TwoWayLinkedList<MyNotificationModel *> *> *> *notificationDictionary;

// MASK: 使用信号量作为线程安全的保障
@property(nonatomic, strong) dispatch_semaphore_t semaphore;

@end


@implementation MyNotificationCenter

/**
 * MyNotificationCenter 的逻辑要点：
 * 1. 单例对象
 *  NSNotificationCenter 使用 class 属性修饰的 defaultCenter 访问全局唯一的通知中心。
 *
 * 2. 添加通知
 * (1) 添加通知有两种方式，SEL 和 block。
 * (2) 添加通知时，可选添加 name 和 object。
 * (3) 当 name 为空时，可以接收所有 name 的通知；当 object 为空，可以接收所有 object 的通知。
 * (4) 当 name 不为空时，只能接收指定 name 的通知；当 object 不为空时，只能接收指定 object 的通知。
 * (5) 相同的 name 和 object 被重复添加时，每一个被添加的通知都可以被响应。
 *
 * 3. 发送通知
 * (1) 发送通知时，name 不能为空。name 为空时，没有通知接收者。
 * (2) 发送通知时，当发送者的 object 为空时，只有接收通知的 name 相同且 object 也为空，才能接到通知。
 * (3) 发送通知时，若发送者的 object 不为空时，只要接收通知的 name 相同或者 object 相同，就能接到通知。
 *
 * 4. 移除通知
 * (1) 移除通知有两种方式，removeObserver: 和 removeObserver:name:object:。
 * (2) 移除通知时，observer 必须相同。
 * (3) 移除通知和添加通知的参数规则相同。空可以匹配所有值，非空则必须相同。
 * (4) 当接收者被释放时，通知自动被移除。
 */

# pragma mark - 单例模式

+ (MyNotificationCenter *)defaultCenter {
    static MyNotificationCenter *_instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        // alloc 会调用 allocWithZone: 函数，需要重写 allocWithZone: 函数才能实现每次获取的都是y同一个对象
        _instance = [[super allocWithZone:nil] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MyNotificationCenter defaultCenter];
}

// MASK: 以免 copy 导致对象的地址发生改变，破坏单例的原则
- (id)copyWithZone:(nullable NSZone *)zone {
    return [MyNotificationCenter defaultCenter];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _notificationDictionary = [NSMutableDictionary dictionary];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}


#pragma mark - Public Function 添加通知

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    MyNotificationModel *model = [MyNotificationModel new];
    model.observer = observer;
    model.selector = aSelector;
    model.name = aName;
    model.object = anObject;
    
    __weak typeof(self) weakSelf = self;
    model.observerDeallocBlock = ^(MyNotificationModel *model) {
        [weakSelf removeObserver:model.observer name:model.name object:model.object];
    };
    
    [self addObserverWithName:aName object:anObject model:model];
}

- (id <NSObject>)addObserverForName:(nullable NSNotificationName)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block {
    // 由于通过该方法添加的通知没有observer，需要手动创造一个observer，以用来移除通知
    NSObject *observer = [NSObject new];
    
    MyNotificationModel *model = [MyNotificationModel new];
    model.observer = observer;
    model.name = name;
    model.object = obj;
    model.block = block;
    model.queue = queue;
    
    [self addObserverWithName:name object:obj model:model];
    
    // 返回的 observer 需要用强引用，否则该通知无法被销毁
    return observer;
}


#pragma mark - Public Function 发送通知

- (void)postNotification:(NSNotification *)notification {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    if (!notification.name) {
        return;
    }
    
    [self sendNotification:notification modelList:_notificationDictionary[[NSNull null]][[NSNull null]]];
    [self sendNotification:notification modelList:_notificationDictionary[notification.name][[NSNull null]]];
    
    if (notification.object) {
        [self sendNotification:notification modelList:_notificationDictionary[[NSNull null]][notification.object]];
        [self sendNotification:notification modelList:_notificationDictionary[notification.name][[NSNull null]]];
    }
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject {
    [self postNotification:[NSNotification notificationWithName:aName object:anObject]];
}

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo {
    [self postNotification:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}


#pragma mark - Public Function 移除通知

- (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil object:nil];
}

- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    if (!aName && !anObject) {
        [_notificationDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableDictionary<id,TwoWayLinkedList<MyNotificationModel *> *> * _Nonnull dictionary, BOOL * _Nonnull stop) {
            [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TwoWayLinkedList<MyNotificationModel *> * _Nonnull list, BOOL * _Nonnull stop) {
                [list removeObjectsWithCondition:^BOOL(MyNotificationModel * _Nonnull value) {
                    return value.observer == observer;
                }];
                
                if (list.count == 0) {
                    [dictionary removeObjectForKey:key];
                }
            }];
            
            if ([dictionary count] == 0) {
                [_notificationDictionary removeObjectForKey:key];
            }
        }];
    } else if (aName && !anObject) {
        [_notificationDictionary[aName] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TwoWayLinkedList<MyNotificationModel *> * _Nonnull list, BOOL * _Nonnull stop) {
            [list removeObjectsWithCondition:^BOOL(MyNotificationModel * _Nonnull value) {
                return value.observer == observer;
            }];
            
            if (list.count == 0) {
                [_notificationDictionary[aName] removeObjectForKey:key];
            }
        }];
        
        if ([_notificationDictionary[aName] count] == 0) {
            [_notificationDictionary removeObjectForKey:aName];
        }
    } else if (!aName && anObject) {
        [_notificationDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableDictionary<id,TwoWayLinkedList<MyNotificationModel *> *> * _Nonnull dictionary, BOOL * _Nonnull stop) {
            [dictionary[anObject] removeObjectsWithCondition:^BOOL(MyNotificationModel * _Nonnull value) {
                return value.observer == observer;
            }];
            
            if ([dictionary[anObject] count] == 0) {
                [dictionary removeObjectForKey:key];
            }
            
            if ([dictionary count] == 0) {
                [_notificationDictionary removeObjectForKey:key];
            }
        }];
    } else {
        [_notificationDictionary[aName][anObject] removeObjectsWithCondition:^BOOL(MyNotificationModel * _Nonnull value) {
            return value.observer == observer;
        }];
        
        if ([_notificationDictionary[aName][anObject] count] == 0) {
            [_notificationDictionary[aName] removeObjectForKey:anObject];
            
            if ([_notificationDictionary[aName] count] == 0) {
                [_notificationDictionary removeObjectForKey:aName];
            }
        }
    }
    
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - Private Function 添加通知

/// 添加通知
- (void)addObserverWithName:(nullable NSNotificationName)name object:(nullable id)obj model:(MyNotificationModel *)model {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    // 若 name 或 obj 为空时，使用 NSNull 替代
    id nameKey = name;
    if (!nameKey) {
        nameKey = [NSNull null];
    }
    id objKey = obj;
    if (!obj) {
        obj = [NSNull null];
    }
    
    // 使用懒加载初始化
    if (!_notificationDictionary[nameKey]) {
        _notificationDictionary[nameKey] = [NSMutableDictionary dictionary];
    }
    if (!_notificationDictionary[nameKey][objKey]) {
        _notificationDictionary[nameKey][objKey] = [[TwoWayLinkedList alloc] init];
    }
    
    // 加入通知序列中
    [_notificationDictionary[nameKey][objKey] addObjectWithValue:model];
    
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - Private Function 发送通知

/// 向序列中的所有接收者发送通知
- (void)sendNotification:(NSNotification *)notification modelList:(TwoWayLinkedList *)list {
    [list enumerateObjectsUsingBlock:^(MyNotificationModel * _Nonnull model) {
        // 当 observer 不为空，且 observer 能响应 selector 时，调用 SEL，否则调用 block
        if (model.observer && [model.observer respondsToSelector:model.selector]) {
            if ([NSStringFromSelector(model.selector) hasSuffix:@":"]) {
                [model.observer performSelector:model.selector withObject:notification];
            } else {
                [model.observer performSelector:model.selector];
            }
        } else if (model.block) {
            if (model.queue) {
                NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                    model.block(notification);
                }];
                [model.queue addOperation:op];
            } else {
                model.block(notification);
            }
        }
    }];
}


@end
