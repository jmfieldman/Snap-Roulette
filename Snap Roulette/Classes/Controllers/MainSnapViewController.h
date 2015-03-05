//
//  MainSnapViewController.h
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/24/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainSnapViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *takePhotoButton;

+ (MainSnapViewController*) sharedInstance;

- (void) updateFriends;

@end
