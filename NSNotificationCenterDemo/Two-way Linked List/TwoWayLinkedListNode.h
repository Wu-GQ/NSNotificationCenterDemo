//
//  TwoWayLinkedListNode.h
//  NSNotificationCenterDemo
//
//  Created by wuguoqiao on 2020/3/24.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 双向链表节点
@interface TwoWayLinkedListNode<ObjectType> : NSObject

/// 节点值
@property(nonatomic, strong) ObjectType value;
/// 后一节点
@property(nonatomic, strong, nullable) TwoWayLinkedListNode *nextNode;
/// 前一节点
@property(nonatomic, weak, nullable) TwoWayLinkedListNode *previousNode;


+ (instancetype)nodeWithValue:(__nonnull ObjectType)value;

@end

NS_ASSUME_NONNULL_END
