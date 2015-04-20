//
//  SnapListViewController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/25/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapListViewController.h"
#import "PFQuery+DualQuery.h"
#import "SnapTableViewCell.h"

@interface SnapListViewController ()

@property (nonatomic, strong) NSArray *snaps;

@end

@implementation SnapListViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = self.title;
}

- (id) initWithDirection:(BOOL)sent {
    if ((self = [super init])) {
        
        _sent = sent;
        
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = sent ? @"Sent Photos" : @"Received Photos";
        
        self.tabBarItem.image = [UIImage imageNamed:sent ? @"sent" : @"recv"];
        
        self.tableView.rowHeight = self.view.bounds.size.width * 1.33 + 42;
		self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 48, 0);
		
        self.refreshControl = [[UIRefreshControl alloc] init];
        //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Hello" attributes:@{}];
        [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        
        [self refreshSnaps];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRefresh:)
                                                     name:_sent ? @"SentSnap" : @"RemoteNotif"
                                                   object:nil];
        
    }
    return self;
}

- (void) handleRefresh:(id)sender {
    [self refreshSnaps];
}


- (void) refreshSnaps {
    PFQuery *query = [PFQuery queryWithClassName:@"Snap"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"sentSnaps"];
    [query includeKey:@"sentToUserArray"];
    [query includeKey:@"taker"];
    
    if (_sent) {
        [query whereKey:@"taker" equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:@"sentToUserArray" equalTo:[PFUser currentUser]];
    }
    
    NSString *lastUpKey = _sent ? @"lastUpdateSent" : @"lastUpdateRecv";
    NSDate *lastUpdate = [NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults] integerForKey:lastUpKey]];
    
    [query dualQueryObjectsInBackgroundWithBlock:^(BOOL fromLocalDatastore, NSArray *objects, NSError *error) {
        if (!fromLocalDatastore) return;
        
        //NSLog(@"dualQueryObjectsInBackgroundWithBlock [%d] (local: %d): (error:%@) %@", (int)_sent, (int)fromLocalDatastore, error, objects);
        
        /*
        for (PFObject *o in objects) {
            NSLog(@"sentSnaps: %@", o[@"sentSnaps"]);
            NSArray *foob = o[@"sentSnaps"];
            NSLog(@"SS: %@", foob[0]);
        }
         */
        
        _snaps = objects;
        [self.tableView reloadData];
        
        //if (!fromLocalDatastore)
            [self.refreshControl endRefreshing];
        
        [[NSUserDefaults standardUserDefaults] setInteger:[NSDate date].timeIntervalSince1970-10 forKey:lastUpKey];
        
    } since:lastUpdate pinResults:YES];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SnapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"snap"];
    if (!cell) {
        cell = [[SnapTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"snap"];
    }
    
    cell.snap = _snaps[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _snaps.count;
}


@end
