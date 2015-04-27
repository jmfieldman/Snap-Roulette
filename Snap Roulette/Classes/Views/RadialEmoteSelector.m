//
//  RadialEmoteSelector.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/15/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "RadialEmoteSelector.h"

#define NUM_EMOTES 12
static __strong NSString *s_emotes[NUM_EMOTES] = {@"😁", @"😂", @"😃", @"😊", @"❤", @"👍", @"😱", @"😳", @"😭", @"😇", @"😮", @"💩" };

@interface RadialEmoteSelector ()
@property (nonatomic, strong) NSMutableArray *emoteButtons;
@property (nonatomic, strong) NSMutableArray *openAnimations;
@property (nonatomic, strong) NSMutableArray *closeAnimations;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *flagButton;
@end

@implementation RadialEmoteSelector

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        float cenx = frame.size.width/2;
        float ceny = frame.size.height/2;
        float outer_rad = cenx * 0.65;
        float emote_rad = outer_rad * 0.25;
        float arc = M_PI * 2 / NUM_EMOTES;
        
        __weak RadialEmoteSelector *weakself = self;
        
        /* Close button */
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = self.bounds;
        _closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
        _closeButton.alpha = 0;
        [_closeButton bk_addEventHandler:^(id sender) {
            [weakself animateClose];
            weakself.resultHandler(0);
        } forControlEvents:UIControlEventTouchDown];
        [self addSubview:_closeButton];
        
        _flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flagButton.frame = CGRectMake(10, 10, 30, 30);
        //_flagButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _flagButton.alpha = 0;
        [_flagButton setTitle:@"Flag" forState:UIControlStateNormal];
        [_flagButton setTitleColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
        _flagButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:11];
        _flagButton.layer.cornerRadius = 15;
        _flagButton.layer.borderColor = [UIColor redColor].CGColor;
        _flagButton.layer.borderWidth = 2;
        [_flagButton bk_addEventHandler:^(id sender) {
            [weakself animateClose];
            weakself.resultHandler(@"🚩");
        } forControlEvents:UIControlEventTouchDown];
        [self addSubview:_flagButton];
        
        _emoteButtons = [NSMutableArray array];
        _openAnimations = [NSMutableArray array];
        _closeAnimations = [NSMutableArray array];
        for (int e = 0; e < NUM_EMOTES; e++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, emote_rad*2, emote_rad*2);
            [button setTitle:s_emotes[e] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:emote_rad*1.2];
            button.titleLabel.minimumScaleFactor = 0.25;
            button.tag = e;
            [self addSubview:button];
            [_emoteButtons addObject:button];
            
            //button.center = CGPointMake(cenx + outer_rad * cos(arc*e), ceny + outer_rad * sin(arc*e));
            button.center = CGPointMake(cenx, ceny);
            
            button.titleLabel.layer.shadowOffset = CGSizeZero;
            button.titleLabel.layer.shadowOpacity = 0.6;
            button.titleLabel.layer.shadowRadius = 3;
            
            button.alpha = 0;
            
            [button bk_addEventHandler:^(UIButton *sender) {
                //NSLog(@"yo");
                [weakself animateClose];
                weakself.resultHandler(s_emotes[sender.tag]);
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
        
        [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
            b.alpha = 1;
        } completion:nil];
    }
    
    [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
        _closeButton.alpha = 1;
        _flagButton.alpha = 1;
    } completion:nil];
}

- (void) animateClose {
    self.userInteractionEnabled = NO;
    
    int i = 0;
    for (UIButton *b in _emoteButtons) {
        
        POPSpringAnimation *a = _closeAnimations[i];
        [b pop_removeAnimationForKey:@"cen"];
        [b pop_addAnimation:a forKey:@"cen"];
        
        i++;
        
        [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
            b.alpha = 0;
        } completion:nil];
    }
    
    [UIView animateWithDuration:0.07 delay:0 options:0 animations:^{
        _closeButton.alpha = 0;
        _flagButton.alpha = 0;
    } completion:nil];
}

@end
