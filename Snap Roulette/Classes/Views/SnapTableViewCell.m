//
//  SnapTableViewCell.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapTableViewCell.h"
#import "RadialEmoteSelector.h"

@interface SnapTableViewCell ()

@property (nonatomic, strong) RadialEmoteSelector *radialSelector;
@property (nonatomic, strong) UIImageView *snapImageView;

@property (nonatomic, strong) UIImageView *takerImageView;
@property (nonatomic, strong) UILabel     *takerNameLabel;
@property (nonatomic, strong) UILabel     *takerEmote;

@property (nonatomic, strong) NSMutableArray *receiverPortraits;
@property (nonatomic, strong) NSMutableArray *receiverNames;
@property (nonatomic, strong) NSMutableArray *receiverEmotes;

@end


@implementation SnapTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        _snapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, [UIScreen mainScreen].bounds.size.width - 0, [UIScreen mainScreen].bounds.size.width - 0)];
        //_snapImageView.layer.cornerRadius = 10;
        //_snapImageView.layer.masksToBounds = YES;
        _snapImageView.userInteractionEnabled = YES;
        //_snapImageView.layer.shouldRasterize = YES;
        //_snapImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_snapImageView];
        
        _radialSelector = [[RadialEmoteSelector alloc] initWithFrame:_snapImageView.bounds];
        _radialSelector.userInteractionEnabled = NO;
        [_snapImageView addSubview:_radialSelector];
        
        __weak SnapTableViewCell *weakself = self;
        UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            //NSLog(@"tapped!");
            [weakself.snapImageView removeGestureRecognizer:_snapImageView.gestureRecognizers[0]];
            [weakself.radialSelector animateOpen];
        }];
        tap.numberOfTapsRequired = 1;
        [_snapImageView addGestureRecognizer:tap];
        
        _radialSelector.resultHandler = ^(int emote) {
            [weakself.snapImageView addGestureRecognizer:tap];
            
            /* Set the emote */
            if (emote > 0) {
				if (emote == 1) emote = 0;
                PFUser *taker = weakself.snap[@"taker"];
                BOOL takerB = ([taker.objectId isEqualToString:PFUser.currentUser.objectId]);
                
                [PFCloud callFunctionInBackground:@"set_emote" withParameters:@{@"snapId":weakself.snap.objectId, @"isTaker":@(takerB), @"emote":@(emote)} block:^(id object, NSError *error) {
                    NSLog(@"set_emote result obj: %@ error: %@", object, error);
					
					if (takerB) {
						weakself.snap[@"emote"] = @(emote);
						[weakself.snap pinInBackgroundWithBlock:^(BOOL success, NSError *error) {
							if (error) NSLog(@"(A) pinning emote error: %@", error);
							else NSLog(@"taker emote updated");
							[weakself updateEmotes];
						}];
					} else {
						NSArray *sentSnaps = weakself.snap[@"sentSnaps"];
						//NSLog(@"sent snap array: %@", sentSnaps);
						for (PFObject *sentSnap in sentSnaps) {
							PFUser *receiver = sentSnap[@"receiver"];
							if ([receiver.objectId isEqualToString:PFUser.currentUser.objectId]) {
								sentSnap[@"emote"] = @(emote);
								[sentSnap pinInBackgroundWithBlock:^(BOOL success, NSError *error) {
									if (error) NSLog(@"(B) pinning emote error: %@", error);
									else NSLog(@"receiver emote updated");
									[weakself updateEmotes];
								}];
							}
						}
					}
                }];
            }
        };
        
        _takerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 32, 32)];
        _takerImageView.layer.cornerRadius = 16;
        _takerImageView.layer.masksToBounds = YES;
        _takerImageView.layer.shouldRasterize = YES;
        _takerImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_takerImageView];
		
		_takerEmote = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
		_takerEmote.center = CGPointMake(_takerImageView.center.x + 11, _takerImageView.center.y + 11);
		_takerEmote.font = [UIFont systemFontOfSize:14];
		_takerEmote.minimumScaleFactor = 0.5;
		_takerEmote.textAlignment = NSTextAlignmentCenter;
		_takerEmote.layer.shadowOffset = CGSizeZero;
		_takerEmote.layer.shadowOpacity = 0.65;
		_takerEmote.layer.shadowRadius = 4;
		[self.contentView addSubview:_takerEmote];
		
        _takerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 5, 200, 32)];
        _takerNameLabel.font = [UIFont fontWithName:@"Lato Regular" size:14];
        _takerNameLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
        [self.contentView addSubview:_takerNameLabel];
        
        
        /* Receiver stuff */
        _receiverPortraits = [NSMutableArray array];
        _receiverNames     = [NSMutableArray array];
        _receiverEmotes    = [NSMutableArray array];
        
        #define NUM_RECEIVERS 5
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat prad = w / 15;
        
        CGFloat w_occ_by_port = prad * NUM_RECEIVERS * 2;
        CGFloat w_occ_by_sp = w - w_occ_by_port;
        
        CGFloat xoff = w_occ_by_sp / (NUM_RECEIVERS+1) + prad;
        CGFloat xmar = w_occ_by_sp / (NUM_RECEIVERS+1) + prad * 2;
        
        CGFloat yoff = w + 60 + prad;
        for (int r = 0; r < NUM_RECEIVERS; r++) {
            
            UIImageView *portrait = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, prad*2, prad*2)];
            portrait.center = CGPointMake(xoff + xmar * r, yoff);
            portrait.layer.cornerRadius = prad;
            portrait.layer.masksToBounds = YES;
            [self.contentView addSubview:portrait];
            [_receiverPortraits addObject:portrait];
            
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, prad*2.2, prad)];
            name.center = CGPointMake(portrait.center.x, portrait.center.y + prad * 1.7);
            name.textAlignment = NSTextAlignmentCenter;
            name.minimumScaleFactor = 0.5;
            [self.contentView addSubview:name];
            [_receiverNames addObject:name];
			
			UILabel *emote = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, prad*1.3, prad*1.3)];
			emote.center = CGPointMake(portrait.center.x + prad*0.75, portrait.center.y + prad*0.75);
			emote.font = [UIFont systemFontOfSize:prad];
			emote.minimumScaleFactor = 0.5;
			emote.textAlignment = NSTextAlignmentCenter;
			emote.layer.shadowOffset = CGSizeZero;
			emote.layer.shadowOpacity = 0.65;
			emote.layer.shadowRadius = 4;
            [self.contentView addSubview:emote];
            [_receiverEmotes addObject:emote];
        }
        
    }
    return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void) setSnap:(PFObject *)snap {
    _snap = snap;
    
    /* Taker */
    PFUser *taker = snap[@"taker"];
    
    _takerImageView.image = [UIImage imageNamed:@"facebook_default_portrait"];
    [_takerImageView sd_setImageWithURL:[NSURL URLWithString:[RandomHelpers urlForFBPicture:taker]] placeholderImage:[UIImage imageNamed:@"facebook_default_portrait"] options:0 completed:nil];
    
    //_takerNameLabel.text = taker[@"fullname"];
    
    NSString *tstr = [NSString stringWithFormat:@"%@ ago", [RandomHelpers timeToAbbrev:time(0)-snap.createdAt.timeIntervalSince1970] ];
    
    NSMutableAttributedString *namestr = [[NSMutableAttributedString alloc] initWithString:taker[@"fullname"] attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Lato-Regular" size:14] }];
    [namestr appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{}]];
    [namestr appendAttributedString:[[NSAttributedString alloc] initWithString:tstr attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Lato-Regular" size:10], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] }]];
    _takerNameLabel.attributedText = namestr;
    
    /* Snap */
    _snapImageView.image = nil;
    _snap.fileColumnName = @"data";
    [_snap getFileDataWithBlock:^(NSData *fileData, AKFileDataRetrievalType retrievalType) {
        _snapImageView.image = [[UIImage alloc] initWithData:fileData];
    }];
    
    
    /* Set up receivers */
    NSArray *sentTo = snap[@"sentToUserArray"];
    int howmany = (int)sentTo.count;
    
    for (int i = howmany; i < NUM_RECEIVERS; i++) {
        ((UIView*)_receiverEmotes[i]).alpha = 0;
        ((UIView*)_receiverNames[i]).alpha = 0;
        ((UIView*)_receiverPortraits[i]).alpha = 0;
    }
    
    for (int r = 0; r < howmany; r++) {
        ((UIView*)_receiverEmotes[r]).alpha = 1;
        ((UIView*)_receiverNames[r]).alpha = 1;
        ((UIView*)_receiverPortraits[r]).alpha = 1;
        
        PFUser *u = sentTo[r];
        
        ((UIImageView*)_receiverPortraits[r]).image = [UIImage imageNamed:@"facebook_default_portrait"];
        [((UIImageView*)_receiverPortraits[r]) sd_setImageWithURL:[NSURL URLWithString:[RandomHelpers urlForFBPicture:u]] placeholderImage:[UIImage imageNamed:@"facebook_default_portrait"] options:0 completed:nil];
        
        ((UILabel*)_receiverNames[r]).text = u[@"firstname"];
    }
	
	[self updateEmotes];
}

- (void) updateEmotes {
	
	int emote = [_snap[@"emote"] intValue];
	_takerEmote.text = (emote > 0) ? [NSString stringWithFormat:@"%C", (unsigned short)emote] : @"";

	/* Set up receivers */
	NSArray *sentSnaps = _snap[@"sentSnaps"];
	int howmany = (int)sentSnaps.count;
	
	for (int i = 0; i < howmany; i++) {
		PFObject *sentsnap = sentSnaps[i];
		int e = [sentsnap[@"emote"] intValue];
		
		UILabel *eL = _receiverEmotes[i];
		eL.text = [NSString stringWithFormat:@"%C", (unsigned short)e];
	}
	
}


@end
