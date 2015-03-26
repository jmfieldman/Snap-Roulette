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
        
        self.title = @"Snap Roulette";
        
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
        _takePhotoButton.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height - 100, 80, 80);
        //_takePhotoButton.backgroundColor = [UIColor blueColor];
        [_takePhotoButton setImage:[FlatWheelImage flatWheelImageWithSize:CGSizeMake(80,80) slices:18 green:YES] forState:UIControlStateNormal];
        [_takePhotoButton addTarget:self action:@selector(handleTakePhoto:) forControlEvents:UIControlEventTouchUpInside];        
        [self.view addSubview:_takePhotoButton];
        
        _takePhotoButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _takePhotoButton.layer.shadowOffset = CGSizeMake(0,0);
        _takePhotoButton.layer.shadowOpacity = 0.5;
        _takePhotoButton.layer.shadowRadius = 5;
     
        /* Add title */
        _titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snap_roulette"]];
        _titleView.center = CGPointMake(self.view.bounds.size.width/2, 70);
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
        POPBasicAnimation *rotanim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
        rotanim.toValue = @(M_PI*0.95);
        rotanim.repeatForever = YES;
        //rotanim.removedOnCompletion = NO;
        rotanim.additive = YES;
        rotanim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_takePhotoButton.layer pop_addAnimation:rotanim forKey:@"rot"];
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
    
    #ifdef TARGET_IPHONE_SIMULATOR
    [self handleImageSnapped:[UIImage imageNamed:@"test"]];
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
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        NSLog(@"took image: %f %f %d", image.size.width, image.size.height, (int)image.imageOrientation);
        
        CGFloat edge = MIN(image.size.width, image.size.height);
        UIImage *cropped = [self imageByCroppingImage:image toSize:CGSizeMake(edge, edge)];
        NSLog(@"cropped image: %f %f %d", cropped.size.width, cropped.size.height, (int)cropped.imageOrientation);
        
        
        [self handleImageSnapped:cropped];
        
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


@end
