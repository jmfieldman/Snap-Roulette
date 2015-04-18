//
//  MainSnapViewController.m
//  Snap Roulette
//
//  Created by Jason Fieldman on 2/24/15.
//  Copyright (c) 2015 Jason Fieldman. All rights reserved.
//

#import "MainSnapViewController.h"
#import "SnapListTabBarController.h"
#import "LoginViewController.h"
#import "FlatWheelImage.h"
#import "RandomHelpers.h"

@interface MainSnapViewController ()

@property (nonatomic, strong) NSArray *fbFriends;
@property (nonatomic, strong) UIView *photoCover;

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIImageView *titleView;

@property (nonatomic, strong) UIView *polaroidShot;

/* capture session */
@property (nonatomic, strong) AVCaptureSession           *captureSession;
@property (nonatomic, strong) AVCaptureDevice            *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput       *captureInput;
@property (nonatomic, strong) AVCaptureStillImageOutput  *captureImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic, strong) AVCaptureConnection        *captureConnection;

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
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Snaps" style:UIBarButtonItemStyleDone target:self action:@selector(handleSnapList:)];
        
        /* Add preview */
        _previewView = [[UIView alloc] initWithFrame:self.view.bounds];
        _previewView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_previewView];
        
        /* Build the photo cover */
        float viewfinder_size = self.view.bounds.size.width * 0.95;
        float viewfinder_border_alpha = 0.5;
        _photoCover = [[UIView alloc] initWithFrame:self.view.bounds];
        _photoCover.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_photoCover];
        {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, (self.view.bounds.size.height - viewfinder_size)/2)];
            v.backgroundColor = [UIColor colorWithWhite:0 alpha:viewfinder_border_alpha];
            [_photoCover addSubview:v];
        }
        {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - (self.view.bounds.size.height - viewfinder_size)/2, self.view.bounds.size.width, (self.view.bounds.size.height - viewfinder_size)/2)];
            v.backgroundColor = [UIColor colorWithWhite:0 alpha:viewfinder_border_alpha];
            [_photoCover addSubview:v];
        }
        {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - viewfinder_size)/2, (self.view.bounds.size.width - viewfinder_size)/2, viewfinder_size)];
            v.backgroundColor = [UIColor colorWithWhite:0 alpha:viewfinder_border_alpha];
            [_photoCover addSubview:v];
        }
        {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - (self.view.bounds.size.width - viewfinder_size)/2, (self.view.bounds.size.height - viewfinder_size)/2, (self.view.bounds.size.width - viewfinder_size)/2, viewfinder_size)];
            v.backgroundColor = [UIColor colorWithWhite:0 alpha:viewfinder_border_alpha];
            [_photoCover addSubview:v];
        }
        {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - viewfinder_size)/2, (self.view.bounds.size.height - viewfinder_size)/2, viewfinder_size, viewfinder_size)];
            v.layer.borderColor = [UIColor colorWithWhite:1 alpha:viewfinder_border_alpha].CGColor;
            v.layer.borderWidth = 2;
            v.backgroundColor = [UIColor clearColor];
            v.clipsToBounds = NO;
            [_photoCover addSubview:v];
        }
        
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotoButton.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height - 120, 80, 80);
        _takePhotoButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - (self.view.bounds.size.height - viewfinder_size)/4);
        //_takePhotoButton.backgroundColor = [UIColor blueColor];
        [_takePhotoButton setImage:[FlatWheelImage flatWheelImageWithSize:CGSizeMake(80,80) slices:18 green:YES] forState:UIControlStateNormal];
        [_takePhotoButton addTarget:self action:@selector(handleTakePhoto:) forControlEvents:UIControlEventTouchUpInside];        
        [self.view addSubview:_takePhotoButton];
        
        _takePhotoButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _takePhotoButton.layer.shadowOffset = CGSizeMake(0,0);
        _takePhotoButton.layer.shadowOpacity = 0.5;
        _takePhotoButton.layer.shadowRadius = 5;
     
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraButton setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
        _switchCameraButton.layer.shadowOpacity = 0.3;
        _switchCameraButton.layer.shadowOffset = CGSizeZero;
        _switchCameraButton.layer.shadowRadius = 3;
        _switchCameraButton.frame = CGRectMake(20, 20, 32, 32);
        _switchCameraButton.center = CGPointMake(self.view.bounds.size.width*0.2, _takePhotoButton.center.y);
        [_switchCameraButton addTarget:self action:@selector(switchCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchCameraButton];

        
        _snapListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_snapListButton setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
        _snapListButton.layer.shadowOpacity = 0.3;
        _snapListButton.layer.shadowOffset = CGSizeZero;
        _snapListButton.layer.shadowRadius = 3;
        _snapListButton.frame = CGRectMake(20, 20, 32, 32);
        _snapListButton.center = CGPointMake(self.view.bounds.size.width*0.8, _takePhotoButton.center.y);
        [_snapListButton addTarget:self action:@selector(snapListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_snapListButton];
        
        
        /* Add title */
        _titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snap_roulette"]];
        _titleView.center = CGPointMake(self.view.bounds.size.width/2, (self.view.bounds.size.height - viewfinder_size)/4);
        _titleView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        [self.view addSubview:_titleView];
        
        /* Get FB Friends */
        _fbFriends = [NSArray array];
        [self updateFriends];
        
        /* Create capture session */
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        /* Create capture device */
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _captureInput  = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
        if (_captureInput) [_captureSession addInput:_captureInput];
        
        /* capture output */
        _captureImageOutput = [[AVCaptureStillImageOutput alloc] init];
        _captureImageOutput.outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
        [_captureSession addOutput:_captureImageOutput];
        
        /* Preview */
        _capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _capturePreviewLayer.frame = self.view.bounds;
        _capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [_previewView.layer addSublayer:_capturePreviewLayer];
        
        [_captureSession startRunning];
        
        
        /* Take photo button rotation */
        #if 0
        POPBasicAnimation *rotanim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
        rotanim.toValue = @(M_PI*0.95);
        rotanim.repeatForever = YES;
        //rotanim.removedOnCompletion = NO;
        rotanim.additive = YES;
        rotanim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_takePhotoButton.layer pop_addAnimation:rotanim forKey:@"rot"];
        #endif
        
    }
    return self;
}


- (void) updateFriends {
    [JFParseFBFriends findFriendsAndUpdate:YES completion:^(BOOL success, BOOL localStore, NSArray *pfusers, NSError *error) {
        NSLog(@"friends: suc:%d ld:%d users:%@ error:%@", success, localStore, pfusers, error);
        if (success) {
            _fbFriends = pfusers;
			
			/* Check image cache for user portraits */
			for (PFUser *friend in pfusers) {
				NSString *picUrl = [RandomHelpers urlForFBPicture:friend];
				SDWebImageManager *manager = [SDWebImageManager sharedManager];
				if (![manager cachedImageExistsForURL:[NSURL URLWithString:picUrl]]) {
                    [manager downloadImageWithURL:[NSURL URLWithString:picUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        
                    }];
				}
			}
		}
    }];
    
    if (PFUser.currentUser) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *oldUser = [def stringForKey:@"curUserID"];
        if ([oldUser isEqualToString:PFUser.currentUser.objectId]) return;
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation[@"user"] = [PFUser currentUser];
        
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succ, NSError* err) {
            if (!succ || err) { NSLog(@"reg error: %@", err); return; }
            [def setObject:PFUser.currentUser.objectId forKey:@"curUserID"];
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [_takePhotoButton.layer removeAnimationForKey:@"rot"];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 0.99 * 10000000);
    rotationAnimation.duration = 5000000;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100000000;
    [_takePhotoButton.layer addAnimation:rotationAnimation forKey:@"rot"];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* Show login screen if we do not have a user */
    if (!PFUser.currentUser) {
        LoginViewController *controller = [[LoginViewController alloc] init];
        [self presentViewController:controller animated:NO completion:nil];
    } else {
        /* Load snap list */
        dispatch_async(dispatch_get_main_queue(), ^{
            [SnapListTabBarController sharedInstance];
        });
    }
    
}

- (void) handleTakePhoto:(id)sender {
	
	UIView *white = [[UIView alloc] initWithFrame:self.view.bounds];
	white.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:white];
	[UIView animateWithDuration:0.5
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 white.alpha = 0;
					 } completion:^(BOOL finished) {
						 [white removeFromSuperview];
					 }];
	
    #if TARGET_IPHONE_SIMULATOR
	[self handleImageSnapped:[RandomHelpers imageWithImage:[UIImage imageNamed:@"test"] scaledToSize:CGSizeMake(512, 512)]];
    return;
    #else
    
    for (AVCaptureConnection *connection in [_captureImageOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                _captureConnection = connection;
                break;
            }
        }
        if (_captureConnection) {
            break;
        }
    }
    
    [_captureImageOutput captureStillImageAsynchronouslyFromConnection:_captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

		NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
		
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			
			UIImage *image = [[UIImage alloc] initWithData:imageData];
			NSLog(@"took image: %f %f %d", image.size.width, image.size.height, (int)image.imageOrientation);
            
            #if 0
            /* OLD WAY; SQUARE FIRST */
			CGFloat edge = MIN(image.size.width, image.size.height);
			UIImage *cropped = [self imageByCroppingImage:image toSize:CGSizeMake(edge, edge)];
			NSLog(@"cropped image: %f %f %d", cropped.size.width, cropped.size.height, (int)cropped.imageOrientation);
			
			cropped = [RandomHelpers imageWithImage:cropped scaledToSize:CGSizeMake(512, 512)];
            #endif
            
            CGFloat newsize = 512;
            image = [RandomHelpers imageWithImage:image scaledToSize:CGSizeMake(newsize, newsize * (image.size.height / image.size.width))];
			NSLog(@"shrunk image: %f %f %d", image.size.width, image.size.height, (int)image.imageOrientation);
			UIImage *cropped = [self imageByCroppingImage:image toSize:CGSizeMake(newsize, newsize)];
            NSLog(@"cropped image: %f %f %d", cropped.size.width, cropped.size.height, (int)cropped.imageOrientation);
            
			dispatch_main_async_safe(^(){
				[self handleImageSnapped:cropped];
			});
		});
    }];
    
    #endif
    
    #if 0
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    #endif
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

- (void) handleImageSnapped:(UIImage*)image {
	
	//[PreloadedSFX playSFX:PLSFX_SHUTTER];
	
    float iW = self.view.bounds.size.width * 1.35;
    float iH = iW;
    float picRatio = 0.8;
    
    _polaroidShot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iW, iH)];
    
    UIImageView *pic = [[UIImageView alloc] initWithImage:image];
    pic.frame = CGRectMake(iW * 0.1, iH * 0.05, iW * picRatio, iH * picRatio);
    [_polaroidShot addSubview:pic];
    
    UIImageView *pol = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"polaroid"]];
    pol.frame = _polaroidShot.bounds;
    [_polaroidShot addSubview:pol];
    
    [self.view addSubview:_polaroidShot];
    
    _polaroidShot.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.58);
    //_polaroidShot.alpha = 0.3;
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    anim.toValue = [NSValue valueWithCGSize:CGSizeMake(0.75, 0.75)];
    [_polaroidShot pop_addAnimation:anim forKey:@"scalexy"];
    
    POPSpringAnimation *animC = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    animC.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.5)];
    [_polaroidShot pop_addAnimation:animC forKey:@"center"];
    
    POPSpringAnimation *animR = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    animR.toValue = @(-0.15);
    [_polaroidShot.layer pop_addAnimation:animR forKey:@"rot"];
    
    POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim2.fromValue = @(0.0);
    anim2.toValue = @(1.0);
    [_polaroidShot pop_addAnimation:anim2 forKey:@"fade"];
    
    
    /* Wind down rotation */
    CGFloat angle = [(NSNumber *)[_takePhotoButton.layer.presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    [_takePhotoButton.layer removeAnimationForKey:@"rot"];
    
    POPBasicAnimation *rotanim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotanim.fromValue = @(angle);
    rotanim.duration = 0.9;
    rotanim.toValue = @(angle + M_PI*0.95);
    rotanim.repeatForever = NO;
    rotanim.removedOnCompletion = NO;
    rotanim.additive = NO;
    rotanim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_takePhotoButton.layer pop_addAnimation:rotanim forKey:@"rot"];
	
    /* ----------------- GET RECEIVERS ---------------- */
	
	NSArray *receivers = [RandomHelpers randomSubsetOfUsers:_fbFriends ofMaxSize:5];
	//receivers = @[receivers[0], receivers[0], receivers[0], receivers[0], receivers[0]];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		int index = 0;
		for (PFUser *friend in receivers) {
			
			int indexOffset = index - 2;
			float portraitSpacing = _polaroidShot.bounds.size.width * 0.15;
			float pX = (_polaroidShot.bounds.size.width / 2) + (indexOffset * portraitSpacing);
			float pY = (_polaroidShot.bounds.size.height * 0.822);
			float sz = (_polaroidShot.bounds.size.width * 0.12);
			
			UIImageView *portrait = [RandomHelpers roundPortraitViewForUser:friend ofSize:sz];
			portrait.center = CGPointMake(160, 300);
			portrait.alpha = 0;
			[_polaroidShot addSubview:portrait];
			
			CGPoint p = [_polaroidShot convertPoint:_takePhotoButton.center fromView:self.view];
			portrait.center = p;
			
			POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
			move.toValue = [NSValue valueWithCGPoint:CGPointMake(pX, pY)];
			move.beginTime = CACurrentMediaTime() + index*0.05;
			[portrait pop_addAnimation:move forKey:@"move"];
			
			POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
			alpha.toValue = @1;
			alpha.beginTime = move.beginTime;
			alpha.duration = 0.05;
			[portrait pop_addAnimation:alpha forKey:@"alpha"];
			
			
			UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, portraitSpacing * 0.95, sz * 0.3)];
			name.text = friend[@"firstname"];
			name.textAlignment = NSTextAlignmentCenter;
			name.textColor = [UIColor colorWithWhite:0.2 alpha:1];
			name.font = [UIFont fontWithName:@"Lato-Regular" size:14];
			name.minimumScaleFactor = 0.5;
			name.alpha = 0;
			name.center = CGPointMake(pX, pY + sz*0.75);
			[_polaroidShot addSubview:name];
			
			POPBasicAnimation *alphaN = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
			alphaN.toValue = @1;
			alphaN.beginTime = move.beginTime + 0.25;
			alphaN.duration = 0.15;
			[name pop_addAnimation:alphaN forKey:@"alpha"];
			
			index++;
		}
	});
	
    NSMutableArray *recIds = [NSMutableArray array];
    for (PFUser *u in receivers) {
        [recIds addObject:u.objectId];
    }
	 
	//PFUser *u = _fbFriends[0];
	//NSData *iData = UIImagePNGRepresentation(image);
    NSData *iData = UIImageJPEGRepresentation(image, 0.4);
	NSString *b64 = [iData base64EncodedStringWithOptions:0];
	[PFCloud callFunctionInBackground:@"submit_snap" withParameters:@{@"receivers":recIds, @"snap_image_data":b64} block:^(id object, NSError *error) {
		NSLog(@"submit_snap result obj: %@ error: %@", object, error);
	}];
	
	/* Create the dismissal layer */
	UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissButton.frame = self.view.bounds;
	[self.view addSubview:dismissButton];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[dismissButton bk_addEventHandler:^(id sender) {
			
			POPSpringAnimation *animR = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
			animR.toValue = @(-0.45 + (arc4random()%100/100.0)*0.5);
			animR.springSpeed = 0.3;
			[_polaroidShot.layer pop_addAnimation:animR forKey:@"rot"];
			
			POPSpringAnimation *animP = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
			animP.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 1.5)];
			animP.springSpeed = 0.05;
			animP.dynamicsTension = 30;
			[_polaroidShot pop_addAnimation:animP forKey:@"pos"];
			
			[_polaroidShot performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2];
			
			[(UIButton*)sender removeFromSuperview];
			
			#if 0
			/* Take photo button rotation */
			POPBasicAnimation *rotanim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
			rotanim.toValue = @(M_PI*0.95);
			rotanim.repeatForever = YES;
			//rotanim.removedOnCompletion = NO;
			rotanim.additive = YES;
			rotanim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			[_takePhotoButton.layer pop_removeAllAnimations];
			_takePhotoButton.layer.transform = CATransform3DIdentity;
			[_takePhotoButton.layer pop_addAnimation:rotanim forKey:@"rot"];
            #endif
            
            CGFloat angle = [(NSNumber *)[_takePhotoButton.layer.presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
            [_takePhotoButton.layer pop_removeAnimationForKey:@"rot"];
            
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.fromValue = @(angle);
            rotationAnimation.toValue = @(angle + M_PI * 2.0 * 10000000);
            rotationAnimation.duration = 10000000;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = 100000000;
            [_takePhotoButton.layer addAnimation:rotationAnimation forKey:@"rot"];
            
			
		} forControlEvents:UIControlEventTouchUpInside];
	});
}

- (void) handleSnapList:(id)sender {
    SnapListViewController *controller = [[SnapListViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size {
    // not equivalent to image.size (which depends on the imageOrientation)!
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(void)switchCameraTapped:(id)sender {
    //Change camera source
    if(_captureSession) {
        //Indicate that some changes will be made to the session
        [_captureSession beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [_captureSession.inputs objectAtIndex:0];
        [_captureSession removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err) {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        } else {
            [_captureSession addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [_captureSession commitConfiguration];
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) return device;
    }
    return nil;
}


- (void) snapListButtonPressed:(id)sender {
    [self.navigationController pushViewController:[SnapListTabBarController sharedInstance] animated:YES];
}

@end
