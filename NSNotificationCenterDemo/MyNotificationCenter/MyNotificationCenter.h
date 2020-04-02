//
//  MyNotificationCenter.h
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/21.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyNotificationCenter : NSObject <NSCopying>

@property(class, readonly, strong) MyNotificationCenter *defaultCenter;

//+ (MyNotificationCenter *)defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;
- (id <NSObject>)addObserverForName:(nullable NSNotificationName)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block;

- (void)postNotification:(NSNotification *)notification;
- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject;
- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject;

@end

NS_ASSUME_NONNULL_END
