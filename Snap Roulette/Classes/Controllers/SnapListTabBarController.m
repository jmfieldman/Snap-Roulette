//
//  SnapListTabBarController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapListTabBarController.h"

@implementation SnapListTabBarController

+ (SnapListTabBarController*) sharedInstance {
    __strong static SnapListTabBarController *singleton = nil;
    @synchronized(self) {
        if (singleton == nil) singleton = [[SnapListTabBarController alloc] init];
    }
    return singleton;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (id) init {
    if ((self = [super init])) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"Photo Feed";
        self.viewControllers = @[ [[SnapListViewController alloc] initWithDirection:NO], [[SnapListViewController alloc] initWithDirection:YES] ];
    }
    return self;
}

@end
