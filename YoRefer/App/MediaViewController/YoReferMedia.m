//
//  MediaViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "YoReferMedia.h"
#import "YoReferAppDelegate.h"
#import "SWRevealViewController.h"
#import "Utility.h"
#import "Configuration.h"
#import "LoginViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NSString * const message        = @"Please select your option";
NSString * const camera         = @"Camera";
NSString * const gallery        = @"Gallery";
NSString * const cancel         = @"Cancel";

@interface YoReferMedia ()<UIAlertViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) SWRevealViewController *revealViewController;

@end

@implementation YoReferMedia

@synthesize delegate = _delegate;


+ (YoReferMedia *)shareMedia
{
    
    static YoReferMedia *_shareMedia = nil;
    static dispatch_once_t onceToke;
    
    dispatch_once(&onceToke, ^{
        
        _shareMedia = [[YoReferMedia alloc]init];
        
    });
    
    return _shareMedia;
    
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        YoReferAppDelegate *appDelegate = (YoReferAppDelegate *)[UIApplication sharedApplication].delegate;
        self.revealViewController = appDelegate.viewController;
        
    }
    
    return self;
    
}

- (void)setMediaWithDelegate:(id<Media>)delegate title:(NSString *)mediaTitle
{
    
    self.delegate = delegate;
    UIAlertView *alertView = [[UIAlertView alloc]init];
    [alertView setTitle:mediaTitle];
    [alertView setMessage:message];
    [alertView addButtonWithTitle:camera];
    [alertView addButtonWithTitle:gallery];
    [alertView addButtonWithTitle:cancel];
    [alertView setDelegate:self];
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:camera])
    {
//        [self camera];
        [self goToCamera];
        
    }else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:gallery])
    {
//        [self gallery];
        [self goToLibrary];
        
    }else  if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:cancel])
    {
    }
    
    if (alertView.tag == 3491832)
    {
        if (buttonIndex == 0) {
            BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
            if (canOpenSettings)
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else
        {
        }
       
    }
    
    
}


- (void)camera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(@"camera not available", @""), nil, @"Ok", nil, 0);
        return;
        
    }else
    {
        [self setMediaPickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}


- (void)gallery
{
    [self setMediaPickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)setMediaPickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    /*
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    imagePicker.mediaTypes = mediaTypes;
    
    imagePicker.delegate = (id)self;
    
    imagePicker.allowsEditing = YES;
    
    imagePicker.sourceType = sourceType;
    */
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.editing = NO;

    
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        imagePicker.sourceType = sourceType;
        NSArray *mediaTypesAllowed = [NSArray arrayWithObject:@"public.image"];
        [imagePicker setMediaTypes:mediaTypesAllowed];
    }
    else{
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *mediaTypesAllowed = [NSArray arrayWithObject:@"public.image"];
        [imagePicker setMediaTypes:mediaTypesAllowed];
    }
    
    
    
    if ([self.revealViewController presentedViewController])
    {
        [self.revealViewController.presentedViewController presentViewController:imagePicker animated:NO completion:Nil];
        
    }else
    {
        [self.revealViewController presentViewController:imagePicker animated:YES completion:nil];
    }
    
}


- (void)camDenied
{
    NSLog(@"%@", @"Denied camera access");
    
    NSString *alertText;
    NSString *alertButton;
    
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings)
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again.";
        
        alertButton = @"Go";
    }
    else
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Touch Privacy.\n\n5. Turn the Camera on.\n\n6. Open this app and try again.";
        
        alertButton = @"OK";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Permission"
                          message:alertText
                          delegate:self
                          cancelButtonTitle:alertButton
                          otherButtonTitles:@"Cancel", nil];
    alert.tag = 3491832;
    [alert show];
}


- (IBAction)goToCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
//        [self popCamera];
        [self camera];
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 NSLog(@"Granted access to %@", AVMediaTypeVideo);
//                 [self popCamera];
                 [self camera];
             }
             else
             {
                 NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                 [self camDenied];
             }
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        // My own Helper class is used here to pop a dialog in one simple line.
//        [Helper popAlertMessageWithTitle:@"Error" alertText:@"You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access."];
    }
    else
    {
        [self camDenied];
    }
}

- (IBAction)goToLibrary
{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        [self gallery];
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
        [self camDenied];
    }
    
    else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
                
                [self gallery];
            }
            
            else {
                // Access has been denied.
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                [self camDenied];
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
    else
    {
        [self camDenied];
    }
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{   NSMutableDictionary *mediaDict = [[NSMutableDictionary alloc]init];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        [mediaDict setValue:videoURL forKey:@"url"];
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        CMTime time = CMTimeMake(1, 1);
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        [mediaDict setObject:thumbnail forKey:@"image"];
        [mediaDict setValue:@"video" forKey:@"type"];
    }
    else
    {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [mediaDict setObject:image forKey:@"image"];
        [mediaDict setValue:@"image" forKey:@"type"];
        
        //[mediaDict setob:[info objectForKey:@"UIImagePickerControllerOriginalImage"] forKey:@"image"];
        
        
    }
    if ([self.delegate respondsToSelector:@selector(getProfilePicture:)])
    {
        
        [self.delegate getProfilePicture:mediaDict];
        
    }
    
    if ([self.revealViewController presentedViewController])
    {
        
        [self.revealViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        
        
    }else
    {
        
        [self.revealViewController dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}



@end
