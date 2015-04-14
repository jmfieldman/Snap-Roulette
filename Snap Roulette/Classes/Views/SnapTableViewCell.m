//
//  SnapTableViewCell.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapTableViewCell.h"

@interface SnapTableViewCell ()

@property (nonatomic, strong) UIImageView *snapImageView;

@property (nonatomic, strong) UIImageView *takerImageView;
@property (nonatomic, strong) UILabel     *takerNameLabel;

@end


@implementation SnapTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        _snapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20)];
        _snapImageView.layer.cornerRadius = 10;
        _snapImageView.layer.masksToBounds = YES;
        _snapImageView.userInteractionEnabled = YES;
        _snapImageView.layer.shouldRasterize = YES;
        _snapImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_snapImageView];
     
        UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            NSLog(@"tapped!");
        }];
        tap.numberOfTapsRequired = 2;
        [_snapImageView addGestureRecognizer:tap];
        
        
        _takerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 32, 32)];
        _takerImageView.layer.cornerRadius = 16;
        _takerImageView.layer.masksToBounds = YES;
        _takerImageView.layer.shouldRasterize = YES;
        _takerImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_takerImageView];
        
        _takerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 10, 200, 32)];
        _takerNameLabel.font = [UIFont fontWithName:@"Lato Regular" size:14];
        _takerNameLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
        [self.contentView addSubview:_takerNameLabel];
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
    
    NSMutableAttributedString *namestr = [[NSMutableAttributedString alloc] initWithString:taker[@"fullname"] attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:14] }];
    [namestr appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{}]];
    [namestr appendAttributedString:[[NSAttributedString alloc] initWithString:@"10m ago" attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : [UIColor blueColor] }]];
    _takerNameLabel.attributedText = namestr;
    
    /* Snap */
    _snapImageView.image = nil;
    _snap.fileColumnName = @"data";
    [_snap getFileDataWithBlock:^(NSData *fileData, AKFileDataRetrievalType retrievalType) {
        _snapImageView.image = [[UIImage alloc] initWithData:fileData];
    }];
    
}

@end
