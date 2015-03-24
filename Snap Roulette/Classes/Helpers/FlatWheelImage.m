//
//  FlatWheelImage.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 3/24/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "FlatWheelImage.h"

@implementation FlatWheelImage

+ (UIImage*) flatWheelImageWithSize:(CGSize)imageSize slices:(int)slices green:(BOOL)green {
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGPoint middle = CGPointMake(imageSize.width/2, imageSize.height/2);
    
    UIColor *redC   = [UIColor colorWithRed:1 green:0.25 blue:0.25 alpha:1];
    UIColor *blackC = [UIColor colorWithWhite:0.3 alpha:1];
    UIColor *greenC = [UIColor colorWithRed:0.25 green:1 blue:0.25 alpha:1];
    
    /* Create wheel */
    if (green) slices++;
    double arc = 2 * M_PI / slices;
    
    for (int slice = 0; slice < slices; slice++) {
        CGContextBeginPage(c, NULL);
        CGContextMoveToPoint(c, middle.x, middle.y);
        CGContextAddArc(c, middle.x, middle.y, middle.x * 0.95, arc * slice, arc * (slice + 1), 0);
        CGContextAddLineToPoint(c, middle.x, middle.y);
        CGContextSetFillColorWithColor(c, (slice % 2) ? redC.CGColor : blackC.CGColor);
        if (green && slice == (slices-1)) {
            CGContextSetFillColorWithColor(c, greenC.CGColor);
        }
        CGContextFillPath(c);
    }
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
