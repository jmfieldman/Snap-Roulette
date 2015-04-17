//
//  PFQuery+DualQuery.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "PFQuery+DualQuery.h"

@implementation PFQuery (DualQuery)


- (void) dualQueryObjectsInBackgroundWithBlock:(PFDQArrayResultBlock)block since:(NSDate*)date pinResults:(BOOL)pin {

    NSLog(@"dual query since: %ld", (long)date.timeIntervalSince1970);
    
    PFQuery *copy = [self copy];
    
    if (date) {
        [self whereKey:@"updatedAt" greaterThan:date];
    }
    
    [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) NSLog(@"findObjects error: %@", error); else NSLog(@"found %d objects", (int)objects.count);
        
        if (!pin) block(NO, objects, error);
        
        if (!error && objects.count && pin) {
            [PFObject pinAllInBackground:objects block:^(BOOL succ, NSError *error) {
                NSLog(@"PINNED %d OBJECTS with error: %@", (int)objects.count, error);
                if (pin) block(NO, objects, error);
            }];
        }
    }];
    
    //[copy whereKey:@"updatedAt" greaterThan:[NSDate dateWithTimeIntervalSince1970:0]];    
    [copy fromLocalDatastore];
    [copy ignoreACLs];
    
    [copy findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(YES, objects, error);
    }];
    
}

@end
