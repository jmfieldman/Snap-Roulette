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

+ (UIImageView*) roundPortraitViewForUser:(PFUser*)user ofSize:(int)size {
	UIImageView *result = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
	result.layer.cornerRadius  = size / 2.0;
	result.layer.masksToBounds = YES;
		
	[result sd_setImageWithURL:[NSURL URLWithString:[RandomHelpers urlForFBPicture:user]] placeholderImage:[UIImage imageNamed:@"facebook_default_portrait"] options:SDWebImageRefreshCached completed:nil];
	return result;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

+ (NSString*) timeToAbbrev:(int)t {
    if (t < 60)        return [NSString stringWithFormat:@"%ds", t];
    if (t < 3600)      return [NSString stringWithFormat:@"%dm", t/60];
    if (t < 86400)     return [NSString stringWithFormat:@"%dh", t/3600];
    return [NSString stringWithFormat:@"%dd", t/86400];
}

@end
