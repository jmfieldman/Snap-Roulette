//
//  PFQuery+DualQuery.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PFDQArrayResultBlock)(BOOL fromLocalDatastore, PF_NULLABLE_S NSArray *objects, PF_NULLABLE_S NSError *error);

@interface PFQuery (DualQuery)

- (void) dualQueryObjectsInBackgroundWithBlock:(PFDQArrayResultBlock)block pinResults:(BOOL)pin;

@end
