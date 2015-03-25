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

+ (SnapListViewController*) sharedInstance {
    __strong static SnapListViewController *singleton = nil;
    @synchronized(self) {
        if (singleton == nil) singleton = [[SnapListViewController alloc] init];
    }
    return singleton;
}


- (id) init {
    if ((self = [super init])) {
        
        self.view.backgroundColor = [UIColor magentaColor];
        self.title = @"Snaps";
        
    }
    return self;
}


@end
