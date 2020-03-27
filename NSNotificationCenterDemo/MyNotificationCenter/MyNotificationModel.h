//
//  MyNotificationModel.h
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/27.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface MyNotificationModel : NSObject

/// 通知的 name
@property(nonatomic, copy, nullable) NSString *name;

/// 通知的 object
@property(nonatomic, strong, nullable) id object;

// MASK: 此处使用 weak 属性修饰，以免 observer 被通知中心持有，导致无法释放
/// 通知的发送对象 observer
@property(nonatomic, weak) id observer;

/// 通知的调用函数 selector
@property(nonatomic, assign) SEL selector;

/// 通知的回调函数 block
@property(nonatomic, copy) typeof(void(^)(NSNotification *)) block;

/// 通知回调函数的执行队列 queue
@property(nonatomic, strong, nullable) NSOperationQueue *queue;

/// 通知的发送对象 observer 释放时的回调
@property(nonatomic, copy) typeof(void(^)(MyNotificationModel *)) observerDeallocBlock;

@end

NS_ASSUME_NONNULL_END
