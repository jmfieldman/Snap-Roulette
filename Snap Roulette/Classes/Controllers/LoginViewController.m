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

- (void) viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser]) {
        /* Successfully logged in here */
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[MainSnapViewController sharedInstance]];
        [self presentViewController:controller animated:NO completion:nil];
    }
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
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSLog(@"%@", result);
                    user[@"fbId"]      = result[@"id"];
                    user[@"firstname"] = result[@"first_name"];
                    user[@"lastname"]  = result[@"last_name"];
                    user[@"name"]      = result[@"name"];
                    user[@"gender"]    = result[@"gender"];
                    [user saveInBackground];
                    
                    
                    /* Successfully logged in here */
                    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[MainSnapViewController sharedInstance]];
                    [self presentViewController:controller animated:YES completion:nil];
                    
                }
            }];
        }
        
        /* This is how to get friends: */
        #if 0
        // Issue a Facebook Graph API request to get your user's friend list
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    [friendIds addObject:[friendObject objectForKey:@"id"]];
                }
                
                // Construct a PFUser query that will find friends whose facebook ids
                // are contained in the current user's friend list.
                PFQuery *friendQuery = [PFUser query];
                [friendQuery whereKey:@"fbId" containedIn:friendIds];
                
                // findObjects will return a list of PFUsers that are friends
                // with the current user
                NSArray *friendUsers = [friendQuery findObjects];
            }
        }];
        #endif
        
    }];
    
}



@end
