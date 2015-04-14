//
//  SnapListViewController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/25/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapListViewController.h"

@interface SnapListViewController ()

@end

@implementation SnapListViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = self.title;
}

- (id) initWithDirection:(BOOL)sent {
    if ((self = [super init])) {
        
        _sent = sent;
        
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = sent ? @"Sent Photos" : @"Received Photos";
        
    }
    return self;
}


@end
