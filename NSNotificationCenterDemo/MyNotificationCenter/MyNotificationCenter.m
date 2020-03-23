//
//  MyNotificationCenter.m
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/21.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "MyNotificationCenter.h"


typedef void(^NotificationModelBlock)(NSNotification *note);


@interface MyNotificationModel : NSObject

@property(nonatomic, copy, nullable) NSString *name;

@property(nonatomic, strong, nullable) id object;

// MASK: 此处使用 weak 属性修饰，以免 observer 被通知中心持有，导致无法释放
@property(nonatomic, weak) id observer;

@property(nonatomic, assign) SEL selector;

@property(nonatomic, copy) NotificationModelBlock block;

@property(nonatomic, strong, nullable) NSOperationQueue *queue;

@end

@implementation MyNotificationModel

@end


@interface MyNotificationCenter ()

// MASK: 此处为了简单使用了数组，最好可以使用双向链表，因为不需要通过下标访问，增删操作也很频繁
@property(nonatomic, strong) NSMutableArray<MyNotificationModel *> *noneNameAndNoneObjectNotification;

@property(nonatomic, strong) NSMutableDictionary<id, NSMutableArray<MyNotificationModel *> *> *nameAndNoneObjectNotification;

@property(nonatomic, strong) NSMutableDictionary<id, NSMutableDictionary<id, NSMutableArray<MyNotificationModel *> *> *> *nameAndObjectNotification;

// MASK: 使用信号量作为线程安全的保障
@property(nonatomic, strong) dispatch_semaphore_t semaphore;

@end


@implementation MyNotificationCenter

/**
 * MyNotificationCenter 的基本逻辑
 * -------- 基本结构 --------
 *  1. 用来存储通知对象的变量
 *   (1) noneNameAndNoneObject，NSMutableArray，接收所有的通知
 *   (2) nameAndNoneObject, NSMutableDictionary<NSMutableArray>，接收对应的通知
 *   (3) nameAndObject, NSMutableDictionary<NSMutableDictionary<NSMutableArray>>, 接收对应的通知
 * -------- 添加通知 --------
 *  当 name 和 object 都为空时，加入(1)，否则按照 name 和 object 加入对应的数组
 * -------- 发送通知 --------
 *  先给 noneNameAndNoneObject 数组中的所有对象发送通知
 *  然后找 nameAndObject 中对应的数组，发送通知
 * -------- 移除通知 --------
 *  遍历 noneNameAndNoneObject 和 nameAndObject ，移除对应的通知
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

// MASK: 以免 copy 导致单例对象的地址发生改变
- (id)copyWithZone:(nullable NSZone *)zone {
    return [MyNotificationCenter defaultCenter];
}

- (instancetype)init {
    self = [super init];
    if (self) {
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
    
    // 无 name 和无 object 中的通知对象，可以接收所有的通知
    for (MyNotificationModel *model in _noneNameAndNoneObjectNotification) {
        [self callFunctionWithNotificationModel:model notification:notification];
    }
    
    // 无 name 和有 object 的通知无法发送，不考虑。其它的根据 name 和 object 是否有值，去对应的结构中查找能够接收通知的对象
    if (notification.name && !notification.object) {
        for (MyNotificationModel *model in _nameAndNoneObjectNotification[notification.name]) {
            [self callFunctionWithNotificationModel:model notification:notification];
        }
    }
    
    if (notification.name && notification.object) {
        for (MyNotificationModel *model in _nameAndObjectNotification[notification.name][notification.object]) {
            [self callFunctionWithNotificationModel:model notification:notification];
        }
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
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    [self removeSameObserver:observer fromArray:_noneNameAndNoneObjectNotification];
    
    [self removeSameObserver:observer fromNotificationModelArrayDictionary:_nameAndNoneObjectNotification];
    
    for (id name in _nameAndObjectNotification) {
        [self removeSameObserver:observer fromNotificationModelArrayDictionary:_nameAndObjectNotification[name]];
        
        if ([_nameAndObjectNotification[name] count] == 0) {
            [_nameAndObjectNotification removeObjectForKey:name];
        }
    }
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    if (!aName && !anObject) {
        [self removeSameObserver:observer fromArray:_noneNameAndNoneObjectNotification];
    } else if (aName && !anObject) {
        [self removeSameObserver:observer fromNotificationModelArrayDictionary:_nameAndNoneObjectNotification];
    } else if (aName && anObject) {
        [self removeSameObserver:observer fromNotificationModelArrayDictionary:_nameAndObjectNotification[aName]];
        
        if ([_nameAndObjectNotification[aName] count] == 0) {
            [_nameAndObjectNotification removeObjectForKey:aName];
        }
    }
    
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - Private Function 添加通知

/// 添加通知
- (void)addObserverWithName:(nullable NSNotificationName)name object:(nullable id)obj model:(MyNotificationModel *)model {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    // 根据 name 和 object 是否为空，分别存储到三个对象中
    if (!name && !obj) {
        if (!_noneNameAndNoneObjectNotification) {
            _noneNameAndNoneObjectNotification = [NSMutableArray array];
        }
        [_noneNameAndNoneObjectNotification addObject:model];
    } else if (name && !obj) {
        if (!_nameAndNoneObjectNotification) {
            _nameAndNoneObjectNotification = [NSMutableDictionary dictionary];
        }
        if (!_nameAndNoneObjectNotification[name]) {
            _nameAndNoneObjectNotification[name] = [NSMutableArray array];
        }
        [_nameAndNoneObjectNotification[name] addObject:model];
    } else if (name && obj) {
        if (!_nameAndObjectNotification) {
            _nameAndObjectNotification = [NSMutableDictionary dictionary];
        }
        if (!_nameAndObjectNotification[name]) {
            _nameAndObjectNotification[name] = [NSMutableDictionary dictionary];
        }
        if (!_nameAndObjectNotification[name][obj]) {
            _nameAndObjectNotification[name][obj] = [NSMutableArray array];
        }
        [_nameAndObjectNotification[name][obj] addObject:model];
    }
    
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - Private Function 发送通知

/// 发送通知
- (void)callFunctionWithNotificationModel:(MyNotificationModel *)model notification:(NSNotification *)notification {
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
}


#pragma mark - Private Function 移除通知

- (void)removeSameObserver:(id)observer fromNotificationModelArrayDictionary:(NSMutableDictionary<id, NSMutableArray<MyNotificationModel *> *> *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray<MyNotificationModel *> * _Nonnull array, BOOL * _Nonnull stop) {
        [self removeSameObserver:observer fromArray:array];
        
        // 当对应 name 和 object 的通知序列都被移除后，移除该Key值
        if ([array count] == 0) {
            [dictionary removeObjectForKey:key];
        }
    }];
}

- (void)removeSameObserver:(id)observer fromArray:(NSMutableArray<MyNotificationModel *> *)array {
    // 倒序遍历时删除对象，不会造成崩溃
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MyNotificationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 只移除相同 observer 的通知
        if (obj.observer == observer) {
            [array removeObjectAtIndex:idx];
        }
    }];
}

@end
