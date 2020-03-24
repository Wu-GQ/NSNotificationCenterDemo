//
//  TwoWayLinkedList.m
//  NSNotificationCenterDemo
//
//  Created by wuguoqiao on 2020/3/24.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "TwoWayLinkedList.h"


@interface TwoWayLinkedList ()

/// 链表头结点
@property(nonatomic, strong) TwoWayLinkedListNode<id> *head;

@end


@implementation TwoWayLinkedList

/// 在双向链表末尾添加节点，节点值为value
- (void)addNodeWithValue:(__nonnull id)value {
    TwoWayLinkedListNode *node = [TwoWayLinkedListNode nodeWithValue:value];
    if (_head) {
        node.previousNode = _head.previousNode;
        node.nextNode = _head;
        
        _head.previousNode.nextNode = node;
        _head.previousNode = node;
    } else {
        _head = node;
        _head.previousNode = _head;
        _head.nextNode = _head;
    }
    
    ++ _count;
}

/// 移除链表中所有相同value的节点
- (void)removeAllNodeWithSameValue:(__nonnull id)value {
    if (!_head) {
        return;
    }
    
    TwoWayLinkedListNode *node = _head;
    while (node.nextNode != _head) {
        if (node.value == value) {
            if (node == _head) {
                _head = node.nextNode;
            }
            
            node.previousNode.nextNode = node.nextNode;
            node.nextNode.previousNode = node.previousNode;
            
            -- _count;
        }
        node = node.nextNode;
    }
}

/// 移除链表中所有节点
- (void)removeAllNode {
    
}

@end
