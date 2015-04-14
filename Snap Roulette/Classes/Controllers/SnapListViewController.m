//
//  SnapListViewController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/25/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapListViewController.h"
#import "PFQuery+DualQuery.h"

@interface SnapListViewController ()

@property (nonatomic, strong) NSArray *snaps;

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
        
        if (_sent) [self refreshSnaps];
    }
    return self;
}

- (void) refreshSnaps {
    PFQuery *query = [PFQuery queryWithClassName:@"Snap"];
    [query includeKey:@"sentSnaps"];
    
    if (_sent) {
        [query whereKey:@"taker" equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:@"sentToUsers" equalTo:@[[PFUser currentUser]]];
    }
    
    [query dualQueryObjectsInBackgroundWithBlock:^(BOOL fromLocalDatastore, NSArray *objects, NSError *error) {
        NSLog(@"dualQueryObjectsInBackgroundWithBlock [%d] (local: %d): (error:%@) %@", (int)_sent, (int)fromLocalDatastore, error, objects);
        
        /*
        for (PFObject *o in objects) {
            NSLog(@"sentSnaps: %@", o[@"sentSnaps"]);
            NSArray *foob = o[@"sentSnaps"];
            NSLog(@"SS: %@", foob[0]);
        }
         */
        
    } pinResults:YES];
}


@end
