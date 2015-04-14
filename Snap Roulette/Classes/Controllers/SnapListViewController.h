//
//  SnapListViewController.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/25/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapListViewController : UITableViewController

@property (nonatomic, readonly) BOOL sent;

- (id) initWithDirection:(BOOL)sent;

@end
