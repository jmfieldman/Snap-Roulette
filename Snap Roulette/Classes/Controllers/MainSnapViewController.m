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
     
        /* Get FB Friends */
        _fbFriends = [NSArray array];
        [self updateFriends];
        
        /* Create capture session */
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        /* Create capture device */
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _captureInput  = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
        [_captureSession addInput:_captureInput];
        
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
        NSLog(@"took image: %f %f %ld", image.size.width, image.size.height, image.imageOrientation);
        
        CGFloat edge = MIN(image.size.width, image.size.height);
        UIImage *cropped = [self imageByCroppingImage:image toSize:CGSizeMake(edge, edge)];
        NSLog(@"cropped image: %f %f %ld", cropped.size.width, cropped.size.height, cropped.imageOrientation);
        
    }];
    
    
    
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
