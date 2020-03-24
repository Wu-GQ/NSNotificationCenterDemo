//
//  TwoWayLinkedListNode.m
//  NSNotificationCenterDemo
//
//  Created by wuguoqiao on 2020/3/24.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "TwoWayLinkedListNode.h"

@implementation TwoWayLinkedListNode

+ (instancetype)nodeWithValue:(__nonnull id)value {
    TwoWayLinkedListNode *node = [[TwoWayLinkedListNode alloc] init];
    node.value = value;
    return node;
}

@end
