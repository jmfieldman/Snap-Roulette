//
//  MainSnapViewController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/24/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "MainSnapViewController.h"
#import "SnapListViewController.h"
#import "LoginViewController.h"
#import "FlatWheelImage.h"

@interface MainSnapViewController ()

@property (nonatomic, strong) NSArray *fbFriends;

@end

@implementation MainSnapViewController

+ (MainSnapViewController*) sharedInstance {
    __strong static MainSnapViewController *singleton = nil;
    @synchronized(self) {
        if (singleton == nil) singleton = [[MainSnapViewController alloc] init];
    }
    return singleton;
}

- (id) init {
    if ((self = [super init])) {
        self.view.backgroundColor = [UIColor orangeColor];
        
        self.title = @"Snap Roulette";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Snaps" style:UIBarButtonItemStyleDone target:self action:@selector(handleSnapList:)];
        
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotoButton.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height - 100, 80, 80);
        //_takePhotoButton.backgroundColor = [UIColor blueColor];
        [_takePhotoButton setImage:[FlatWheelImage flatWheelImageWithSize:CGSizeMake(80,80) slices:18 green:YES] forState:UIControlStateNormal];
        [_takePhotoButton addTarget:self action:@selector(handleTakePhoto:) forControlEvents:UIControlEventTouchUpInside];        
        [self.view addSubview:_takePhotoButton];
        
        _takePhotoButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _takePhotoButton.layer.shadowOffset = CGSizeMake(0,0);
        _takePhotoButton.layer.shadowOpacity = 0.5;
        _takePhotoButton.layer.shadowRadius = 5;
     
        /* Get FB Friends */
        _fbFriends = [NSArray array];
        [self updateFriends];
    }
    return self;
}

- (void) updateFriends {
    [JFParseFBFriends findFriendsAndUpdate:YES completion:^(BOOL success, BOOL localStore, NSArray *pfusers, NSError *error) {
        NSLog(@"friends: suc:%d ld:%d users:%@ error:%@", success, localStore, pfusers, error);
        if (success) {
            _fbFriends = pfusers;
        }
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* Show login screen if we do not have a user */
    if (!PFUser.currentUser) {
        LoginViewController *controller = [[LoginViewController alloc] init];
        [self presentViewController:controller animated:NO completion:nil];
    }
}

- (void) handleTakePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@", info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (_fbFriends.count == 0) return;
    
    PFObject *snap = [PFObject objectWithClassName:@"Snap"];
    snap[@"taker"] = [PFUser currentUser];
    snap[@"data"]  = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    [snap saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        PFObject *sentsnap    = [PFObject objectWithClassName:@"SentSnap"];
        sentsnap[@"taker"]    = [PFUser currentUser];
        sentsnap[@"snap"]     = snap;
        sentsnap[@"receiver"] = _fbFriends[0];
        [sentsnap saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"SAVED!");
        }];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) handleSnapList:(id)sender {
    SnapListViewController *controller = [[SnapListViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
