//
//  LoginViewController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/19/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "LoginViewController.h"
#import "MainSnapViewController.h"
#import <FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoginViewController ()

@end

@implementation LoginViewController


- (id) init {
    if ((self = [super init])) {
        
        self.view.backgroundColor = [UIColor redColor];
        
        UILabel *helloWorld = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
        helloWorld.text = @"Snap Routlette";
        helloWorld.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:helloWorld];
        
        _facebookLoginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_facebookLoginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
        [_facebookLoginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _facebookLoginButton.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        [self.view addSubview:_facebookLoginButton];
        
    }
    return self;
}


- (void) loginButtonPressed:(id)sender {
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"user_friends"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
        }
        
        
        if (user) {
            [JFParseFBFriends updateCurrentUserWithCompletion:^(BOOL success, NSError *error) {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [[MainSnapViewController sharedInstance] updateFriends];
            }];
        }
        
    }];
    
}



@end
