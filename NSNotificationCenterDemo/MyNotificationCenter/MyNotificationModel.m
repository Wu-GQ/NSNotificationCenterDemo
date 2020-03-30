//
//  MyNotificationModel.m
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/27.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "MyNotificationModel.h"
#import "ObjectDeallocObserver.h"
#import <objc/runtime.h>


@implementation MyNotificationModel

- (void)setObserver:(id)observer {
    _observer = observer;
    
    if (_observer) {
        ObjectDeallocObserver *deallocObserver = [ObjectDeallocObserver new];
        __weak typeof(self) weakSelf = self;
        deallocObserver.deallocBlock = ^{
            if (weakSelf.observerDeallocBlock) {
                weakSelf.observerDeallocBlock(weakSelf);
            }
        };
        
        // 使用UUID保证当同一对象添加多个通知时，不会因为 Key 相同导致覆盖之前的关联对象
        NSString *key = [NSString stringWithFormat:@"DeallocBlock_%@", [[NSUUID UUID] UUIDString]];
        
        // MASK: 由于关联对象在被关联对象释放时，自动释放，可以通过关联对象的释放获取到被关联对象的释放时机
        objc_setAssociatedObject(_observer, [key UTF8String], deallocObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
