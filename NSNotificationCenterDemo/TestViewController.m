//
//  TestViewController.m
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/21.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "TestViewController.h"
#import "MyNotificationCenter.h"


@interface TestViewController ()

@property(nonatomic, copy) NSString *string;

@property(nonatomic, strong) id observer;

@end


@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.string = @"TestViewController";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 第一种方式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testFunction:) name:@"Test" object:nil];
//    [[MyNotificationCenter defaultCenter] addObserver:self selector:@selector(testFunction:) name:@"Test" object:nil];
//    [[MyNotificationCenter defaultCenter] addObserverForName:@"Test" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//        NSLog(@"%s", __FUNCTION__);
//
//        [self testFunction2];
//    }];
    
    // 第二种方式
//    __weak typeof(self) weakSelf = self;
//    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"Test" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//        NSLog(@"%s", __FUNCTION__);
//
//        [weakSelf testFunction2];
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[MyNotificationCenter defaultCenter] removeObserver:self name:@"Test" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Test" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Test" object:nil];
//    [[MyNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)testFunction:(NSNotification *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", sender);
}

- (void)testFunction2 {
    NSLog(@"%s", __FUNCTION__);
    
//    NSLog(@"%@", sender);
}

- (void)testFunction3:(NSNotification *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", sender);
}

- (IBAction)postButtonEvent:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [[MyNotificationCenter defaultCenter] postNotificationName:@"Test" object:nil];
}

@end
