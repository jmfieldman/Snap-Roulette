//
//  PFQuery+DualQuery.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "PFQuery+DualQuery.h"

@implementation PFQuery (DualQuery)


- (void) dualQueryObjectsInBackgroundWithBlock:(PFDQArrayResultBlock)block pinResults:(BOOL)pin {

    PFQuery *copy = [self copy];
    
    [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(NO, objects, error);
        
        if (!error && objects.count && pin) {
            [PFObject pinAllInBackground:objects];
        }
    }];
    
    [copy fromLocalDatastore];
    [copy ignoreACLs];
    
    [copy findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(YES, objects, error);
    }];
    
}

@end
