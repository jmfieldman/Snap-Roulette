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

+ (NSArray*) randomSubsetOfUsers:(NSArray*)users ofMaxSize:(int)size {
	if (users.count <= size) return [NSArray arrayWithArray:users];
	
	NSMutableArray *result = [NSMutableArray array];
	NSMutableArray *seed   = [NSMutableArray arrayWithArray:users];
	
	for (int i = 0; i < size; i++) {
		int index = arc4random() % seed.count;
		[result addObject:seed[index]];
		[seed removeObjectAtIndex:index];
	}
	
	return result;
}

@end
