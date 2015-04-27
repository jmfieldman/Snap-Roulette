//
//  SnapListTabBarController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 4/14/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "SnapListTabBarController.h"

@interface SnapListTabBarController ()
@property (nonatomic, strong) UIImageView *glass;
@end

@implementation SnapListTabBarController

+ (SnapListTabBarController*) sharedInstance {
    __strong static SnapListTabBarController *singleton = nil;
    @synchronized(self) {
        if (singleton == nil) singleton = [[SnapListTabBarController alloc] init];
    }
    return singleton;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    });
    //self.navigationController.navigationBarHidden = NO;
    NSLog(@"sub didappear");
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    NSLog(@"sub willappear");
    
    /* Get remote notification token */
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (id) init {
    if ((self = [super init])) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"Photo Feed";
        self.viewControllers = @[ [[SnapListViewController alloc] initWithDirection:NO], [[SnapListViewController alloc] initWithDirection:YES] ];
        
        #if 0
        self.tabBar.hidden = YES;
        
        _glass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glass"]];
        _glass.alpha = 0.5;
        _glass.frame = CGRectMake(0, 0, _glass.bounds.size.width * 1.5, _glass.bounds.size.height * 1.5);
        [self.view addSubview:_glass];
        
        UIView *backing = [[UIView alloc] initWithFrame:CGRectMake(0, _glass.bounds.size.height-1, _glass.bounds.size.width, 2)];
        backing.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
        [self.view insertSubview:backing aboveSubview:_glass];
        #endif
    }
    return self;
}

@end
