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
    _takerImageView.image = [UIImage imageNamed:@"facebook_default_portrait"];
    [_takerImageView sd_setImageWithURL:[NSURL URLWithString:[RandomHelpers urlForFBPicture:snap[@"taker"]]] placeholderImage:[UIImage imageNamed:@"facebook_default_portrait"] options:0 completed:nil];
    
    /* Snap */
    _snapImageView.image = nil;
    _snap.fileColumnName = @"data";
    [_snap getFileDataWithBlock:^(NSData *fileData, AKFileDataRetrievalType retrievalType) {
        _snapImageView.image = [[UIImage alloc] initWithData:fileData];
    }];
    
}

@end
