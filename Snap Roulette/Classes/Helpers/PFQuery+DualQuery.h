//
//  PFQuery+DualQuery.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PFDQArrayResultBlock)(BOOL fromLocalDatastore, NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error);

@interface PFQuery (DualQuery)

- (void) dualQueryObjectsInBackgroundWithBlock:(PF_NULLABLE_S PFDQArrayResultBlock)block pinResults:(BOOL)pin;

@end
