//
//  RadialEmoteSelector.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/15/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RadialEmoteSelectorResultBlock)(int emote);

@interface RadialEmoteSelector : UIView

@property (nonatomic, copy) RadialEmoteSelectorResultBlock resultHandler;

- (void) animateOpen;

@end
