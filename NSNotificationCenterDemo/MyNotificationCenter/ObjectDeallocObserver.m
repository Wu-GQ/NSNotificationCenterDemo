//
//  ObjectDeallocObserver.m
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/27.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "ObjectDeallocObserver.h"


@implementation ObjectDeallocObserver

- (void)dealloc {
    if (_deallocBlock) {
        _deallocBlock();
        _deallocBlock = nil;
    }
    NSLog(@"%s", __FUNCTION__);
}

@end
