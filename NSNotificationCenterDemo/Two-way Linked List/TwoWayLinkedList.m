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

/// 链表尾结点
@property(nonatomic, strong) TwoWayLinkedListNode<id> *tail;

@end


@implementation TwoWayLinkedList

- (instancetype)init {
    self = [super init];
    if (self) {
        _count = 0;
    }
    return self;
}

#pragma mark - Public Function

/// 在双向链表末尾添加节点，节点值为value
- (void)addNodeWithValue:(__nonnull id)value {
    TwoWayLinkedListNode *node = [TwoWayLinkedListNode nodeWithValue:value];
    
    if (_tail) {
        _tail.nextNode = node;
        node.previousNode = self.tail;
        _tail = node;
    } else {
        _head = node;
        _tail = node;
    }
    
    ++ _count;
}

/// 遍历所有节点
- (void)enumerateNodesUsingBlock:(void(^)(id value))block {
    TwoWayLinkedListNode *node = _head;
    while (node) {
        block(node.value);
        
        node = node.nextNode;
    }
}

/// 根据判断条件移除
- (void)removeNodesWithCondition:(BOOL(^)(id value))condition {
    if (!_head) {
        return;
    }
    
    TwoWayLinkedListNode *node = _head;
    while (node) {
        if (condition(node.value)) {
            if (node == _head) {
                _head = node.nextNode;
            }
            
            if (node == _tail) {
                _tail = node.previousNode;
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
    TwoWayLinkedListNode *node = _head.nextNode;
    while (node) {
        node.previousNode.nextNode = nil;
    }
    
    _head = nil;
    _tail = nil;
    _count = 0;
}


#pragma mark - description

- (NSString *)description {
    if (!_head) {
        return @"[]";
    }
    
    NSMutableString *string = [NSMutableString stringWithFormat:@"[%@", _head.value];
    TwoWayLinkedListNode *node = _head.nextNode;
    while (node) {
        [string appendFormat:@"%@", [NSString stringWithFormat:@", %@", node.value]];
        node = node.nextNode;
    }
    [string appendString:@"]"];
    return [string description];
}

- (NSString *)debugDescription {
    return [self description];
}

@end
