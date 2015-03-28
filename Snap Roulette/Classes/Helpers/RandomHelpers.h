//
//  RandomHelpers.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 3/27/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomHelpers : NSObject

+ (NSString*) urlForFBPicture:(PFUser*)user;
+ (NSArray*) randomSubsetOfUsers:(NSArray*)users ofMaxSize:(int)size;
+ (UIImageView*) roundPortraitViewForUser:(PFUser*)user ofSize:(int)size;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
