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

#import "SnapListTabBarController.h"
#import "FlatWheelImage.h"

@interface LoginViewController ()
@property (nonatomic, strong) UIImageView *titleView;
@property (nonatomic, strong) UIImageView *wheel;
@property (nonatomic, strong) UIButton *login;
@end

@implementation LoginViewController


- (id) init {
    if ((self = [super init])) {
        
        //self.view.backgroundColor = [UIColor colorWithRed:179.0/255 green:207.0/255 blue:224.0/255 alpha:1];
        self.view.backgroundColor = [UIColor colorWithRed:199.0/255 green:227.0/255 blue:244.0/255 alpha:1];
        //self.view.backgroundColor = [UIColor colorWithRed:107.0/255.0 green:149.0/255.0 blue:241.0/255.0 alpha:1];
        
        /* Add title */
        _titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snap_roulette"]];
        _titleView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4);
        _titleView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        //[self.view addSubview:_titleView];
        
        UILabel *helloWorld = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height * 0.1, self.view.frame.size.width, 80)];
        helloWorld.text = @"Snap Routlette";
        helloWorld.font = [UIFont fontWithName:@"Avenir-Medium" size:36];
        helloWorld.textAlignment = NSTextAlignmentCenter;
        //[self.view addSubview:helloWorld];

        UILabel *helloWorld2 = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height * 0.75, self.view.frame.size.width - 20, 50)];
        helloWorld2.text = @"Snap Roulette needs to know who your friends are.\n We will never post to your wall.";
        helloWorld2.font = [UIFont fontWithName:@"Avenir-Medium" size:12];
        helloWorld2.textColor = [UIColor colorWithWhite:0 alpha:0.8];
        helloWorld2.numberOfLines = 2;
        helloWorld2.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:helloWorld2];

        
        
        UIImageView *camera = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width * 0.6, self.view.bounds.size.width * 0.6)];
        camera.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*0.5);
        camera.image = [UIImage imageNamed:@"camera"];
        [self.view addSubview:camera];
        
        _wheel = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width * 0.29, self.view.bounds.size.width * 0.29)];
        _wheel.center = CGPointMake(camera.center.x, camera.center.y + camera.frame.size.height*0.0395);
        _wheel.image = [FlatWheelImage flatWheelImageWithSize:_wheel.bounds.size slices:19 green:YES];
        [self.view addSubview:_wheel];
        
        
        _facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_facebookLoginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchDown];
        _facebookLoginButton.frame = self.view.bounds;
        [self.view addSubview:_facebookLoginButton];
        
        UIImage *li = [UIImage imageNamed:@"login-facebook"];
        _login = [UIButton buttonWithType:UIButtonTypeCustom];
        [_login setImage:li forState:UIControlStateNormal];
        _login.frame = CGRectMake(0, 0, li.size.width, li.size.height);
        _login.center = CGPointMake(camera.center.x, self.view.bounds.size.height * 0.9);
        [_login addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_login];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reanim:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reanim:(NSNotification*)notif {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 0.99 * 10000000);
    rotationAnimation.duration = 15000000;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100000000;
    [_wheel.layer removeAllAnimations];
    [_wheel.layer addAnimation:rotationAnimation forKey:@"rot"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 0.99 * 10000000);
    rotationAnimation.duration = 15000000;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100000000;
    [_wheel.layer removeAllAnimations];
    [_wheel.layer addAnimation:rotationAnimation forKey:@"rot"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"fuck");
}

- (void) loginButtonPressed:(id)sender {
    
    UILabel *connecting = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height * 0.1, self.view.bounds.size.width, self.view.bounds.size.height * 0.3)];
    connecting.text = @"Connecting...";
    connecting.numberOfLines = 1;
    connecting.font = [UIFont fontWithName:@"Avenir-Medium" size:24];
    connecting.textAlignment = NSTextAlignmentCenter;
    connecting.alpha = 1;
    connecting.minimumScaleFactor = 0.5;
    [self.view addSubview:connecting];
    //[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
    //    connecting.alpha = 0.5;
    //} completion:nil];
    
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    

                
                    [[MainSnapViewController sharedInstance] animWheel];
                });
            }];
            
            /* Load snap list */
            dispatch_async(dispatch_get_main_queue(), ^{
                [SnapListTabBarController sharedInstance];
                nav.viewControllers = @[ [SnapListTabBarController sharedInstance] ];
            });
        }
        
    }];
    
}



@end
