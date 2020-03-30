//
//  ViewController.m
//  NSNotificationCenterDemo
//
//  Created by WGQ-Macbook Pro on 2020/3/21.
//  Copyright © 2020 WGQ. All rights reserved.
//

#import "ViewController.h"
#import "MyNotificationCenter.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)toTestButtonEvent:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSegueWithIdentifier:@"toTest" sender:nil];
}

- (IBAction)postButtonEvent:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Test" object:nil];
    [[MyNotificationCenter defaultCenter] postNotificationName:@"Test" object:nil];
}

@end
