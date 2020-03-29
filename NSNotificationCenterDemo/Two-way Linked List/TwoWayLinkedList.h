//
//  TwoWayLinkedList.h
//  NSNotificationCenterDemo
//
//  Created by wuguoqiao on 2020/3/24.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwoWayLinkedListNode.h"


NS_ASSUME_NONNULL_BEGIN

/// 双向链表
@interface TwoWayLinkedList<ObjectType> : NSObject

/// 链表的节点数量
@property(nonatomic, assign, readonly) NSUInteger count;


/// 在双向链表末尾添加节点，节点值为value
- (void)addObjectWithValue:(__nonnull ObjectType)value;

/// 遍历所有节点
- (void)enumerateObjectsUsingBlock:(void(^)(ObjectType value))block;

/// 根据判断条件移除
- (void)removeObjectsWithCondition:(BOOL(^)(ObjectType value))condition;

/// 移除链表中所有节点
- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
