//
//  ObjectDeallocObserver.h
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/27.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/// 通过关联对象，获得对象的释放事件
@interface ObjectDeallocObserver : NSObject

@property(nonatomic, copy) typeof(void(^)(void)) deallocBlock;

@end

NS_ASSUME_NONNULL_END
