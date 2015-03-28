//
//  RandomHelpers.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 3/27/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "RandomHelpers.h"

@implementation RandomHelpers

+ (NSString*) urlForFBPicture:(PFUser*)user {
	NSString *fbId = user[@"fbId"];
	return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", fbId];
}

@end
