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

/// 循环双向链表，头结点的前一节点即尾结点
@interface TwoWayLinkedList<ObjectType> : NSObject

/// 链表的节点数量
@property(nonatomic, assign, readonly) NSUInteger count;


/// 在双向链表末尾添加节点，节点值为value
- (void)addNodeWithValue:(__nonnull ObjectType)value;

/// 移除链表中所有相同value的节点
- (void)removeAllNodeWithSameValue:(__nonnull ObjectType)value;

/// 移除链表中所有节点
- (void)removeAllNode;

@end

NS_ASSUME_NONNULL_END
