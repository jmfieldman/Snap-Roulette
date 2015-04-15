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

@property (nonatomic, strong) NSMutableArray *receiverPortraits;
@property (nonatomic, strong) NSMutableArray *receiverNames;
@property (nonatomic, strong) NSMutableArray *receiverLike;

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
            NSLog(@"tapped!");
            [weakself.snapImageView removeGestureRecognizer:_snapImageView.gestureRecognizers[0]];
            [weakself.radialSelector animateOpen];
        }];
        tap.numberOfTapsRequired = 2;
        [_snapImageView addGestureRecognizer:tap];
        
        _radialSelector.resultHandler = ^(int emote) {
            [weakself.snapImageView addGestureRecognizer:tap];
        };
        
        _takerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 32, 32)];
        _takerImageView.layer.cornerRadius = 16;
        _takerImageView.layer.masksToBounds = YES;
        _takerImageView.layer.shouldRasterize = YES;
        _takerImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_takerImageView];
        
        _takerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 5, 200, 32)];
        _takerNameLabel.font = [UIFont fontWithName:@"Lato Regular" size:14];
        _takerNameLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
        [self.contentView addSubview:_takerNameLabel];
        
        
        /* Receiver stuff */
        _receiverPortraits = [NSMutableArray array];
        _receiverNames     = [NSMutableArray array];
        _receiverLike      = [NSMutableArray array];
        
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
            name.center = CGPointMake(portrait.center.x, portrait.center.y + prad * 1.6);
            name.textAlignment = NSTextAlignmentCenter;
            name.minimumScaleFactor = 0.5;
            [self.contentView addSubview:name];
            [_receiverNames addObject:name];
            
            UIImageView *like = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [self.contentView addSubview:like];
            [_receiverLike addObject:like];
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
        ((UIView*)_receiverLike[i]).alpha = 0;
        ((UIView*)_receiverNames[i]).alpha = 0;
        ((UIView*)_receiverPortraits[i]).alpha = 0;
    }
    
    for (int r = 0; r < howmany; r++) {
        ((UIView*)_receiverLike[r]).alpha = 1;
        ((UIView*)_receiverNames[r]).alpha = 1;
        ((UIView*)_receiverPortraits[r]).alpha = 1;
        
        PFUser *u = sentTo[r];
        
        ((UIImageView*)_receiverPortraits[r]).image = [UIImage imageNamed:@"facebook_default_portrait"];
        [((UIImageView*)_receiverPortraits[r]) sd_setImageWithURL:[NSURL URLWithString:[RandomHelpers urlForFBPicture:u]] placeholderImage:[UIImage imageNamed:@"facebook_default_portrait"] options:0 completed:nil];
        
        ((UILabel*)_receiverNames[r]).text = u[@"firstname"];
    }
    
}

@end
