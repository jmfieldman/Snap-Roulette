//
//  MainSnapViewController.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/24/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

extern UINavigationController *nav;

@interface MainSnapViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *snapListButton;

+ (MainSnapViewController*) sharedInstance;

- (void) updateFriends;

@end
