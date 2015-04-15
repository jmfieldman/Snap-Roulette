//
//  RadialEmoteSelector.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/15/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "RadialEmoteSelector.h"

#define NUM_EMOTES 12
static unsigned short s_emotes[NUM_EMOTES] = {0xe04f, 0xe04e, 0xe04d, 0xe04f, 0xe04e, 0xe04d, 0xe04f, 0xe04e, 0xe04d, 0xe04f, 0xe04e, 0xe04d};

@interface RadialEmoteSelector ()
@property (nonatomic, strong) NSMutableArray *emoteButtons;
@property (nonatomic, strong) NSMutableArray *openAnimations;
@property (nonatomic, strong) NSMutableArray *closeAnimations;
@end

@implementation RadialEmoteSelector

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        float cenx = frame.size.width/2;
        float ceny = frame.size.height/2;
        float outer_rad = cenx * 0.65;
        float emote_rad = outer_rad * 0.2;
        float arc = M_PI * 2 / NUM_EMOTES;
        
        _emoteButtons = [NSMutableArray array];
        _openAnimations = [NSMutableArray array];
        _closeAnimations = [NSMutableArray array];
        for (int e = 0; e < NUM_EMOTES; e++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, emote_rad*2, emote_rad*2);
            [button setTitle:[NSString stringWithFormat:@"%C", s_emotes[e]] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:emote_rad*1.2];
            button.titleLabel.minimumScaleFactor = 0.25;
            [self addSubview:button];
            [_emoteButtons addObject:button];
            
            //button.center = CGPointMake(cenx + outer_rad * cos(arc*e), ceny + outer_rad * sin(arc*e));
            button.center = CGPointMake(cenx, ceny);
            
            button.titleLabel.layer.shadowOffset = CGSizeZero;
            button.titleLabel.layer.shadowOpacity = 0.6;
            button.titleLabel.layer.shadowRadius = 3;
            
            __weak RadialEmoteSelector *weakself = self;
            [button bk_addEventHandler:^(id sender) {
                NSLog(@"yo");
                [weakself animateClose];
                weakself.resultHandler(0);
            } forControlEvents:UIControlEventTouchDown];
            
            POPSpringAnimation *oa = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            oa.fromValue = [NSValue valueWithCGPoint:CGPointMake(cenx, ceny)];
            oa.toValue   = [NSValue valueWithCGPoint:CGPointMake(cenx + outer_rad * cos(arc*e), ceny + outer_rad * sin(arc*e))];
            oa.velocity = [NSValue valueWithCGPoint:CGPointMake(10 * outer_rad * cos(arc*e), 10 * outer_rad * sin(arc*e))];
            oa.springBounciness = 1;
            oa.springSpeed = 1;
            [_openAnimations addObject:oa];
            
            POPSpringAnimation *ca = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            ca.fromValue = [NSValue valueWithCGPoint:CGPointMake(cenx + outer_rad * cos(arc*e), ceny + outer_rad * sin(arc*e))];
            ca.toValue   = [NSValue valueWithCGPoint:CGPointMake(cenx, ceny)];
            ca.velocity = [NSValue valueWithCGPoint:CGPointMake(-10 * outer_rad * cos(arc*e), -10 * outer_rad * sin(arc*e))];
            ca.springBounciness = 1;
            ca.springSpeed = 1;
            [_closeAnimations addObject:ca];
            
        }
        
    }
    return self;
}

- (void) animateOpen {
    self.userInteractionEnabled = YES;
    
    int i = 0;
    for (UIButton *b in _emoteButtons) {
        
        POPSpringAnimation *a = _openAnimations[i];
        [b pop_removeAnimationForKey:@"cen"];
        [b pop_addAnimation:a forKey:@"cen"];
        
        i++;
    }
}

- (void) animateClose {
    self.userInteractionEnabled = NO;
    
    int i = 0;
    for (UIButton *b in _emoteButtons) {
        
        POPSpringAnimation *a = _closeAnimations[i];
        [b pop_removeAnimationForKey:@"cen"];
        [b pop_addAnimation:a forKey:@"cen"];
        
        i++;
    }
}

@end
