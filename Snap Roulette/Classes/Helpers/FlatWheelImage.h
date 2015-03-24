//
//  FlatWheelImage.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 3/24/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlatWheelImage : NSObject

+ (UIImage*) flatWheelImageWithSize:(CGSize)imageSize slices:(int)slices green:(BOOL)green;

@end
