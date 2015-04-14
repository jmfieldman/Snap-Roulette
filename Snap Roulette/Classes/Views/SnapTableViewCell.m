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

@end


@implementation SnapTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        _snapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20)];
        _snapImageView.layer.cornerRadius = 10;
        _snapImageView.layer.masksToBounds = YES;
        
        
        [self.contentView addSubview:_snapImageView];
        
    }
    return self;
}


- (void) setSnap:(PFObject *)snap {
    _snap = snap;
    
    _snapImageView.image = nil;
    
    _snap.fileColumnName = @"data";
    [_snap getFileDataWithBlock:^(NSData *fileData, AKFileDataRetrievalType retrievalType) {
        _snapImageView.image = [[UIImage alloc] initWithData:fileData];
    }];
    
}

@end
