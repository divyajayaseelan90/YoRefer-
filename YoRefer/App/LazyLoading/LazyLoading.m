//
//  LazyLoading.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 14/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "UserManager.h"

#pragma mark -
@implementation LazyLoading

+ (LazyLoading *)shareLazyLoading
{
    static LazyLoading *_shareLazyLoading = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareLazyLoading = [[LazyLoading alloc]init];
    });
    return _shareLazyLoading;
}


- (void)loadImageWithUrl:(NSURL *)url imageView:(UIImageView *)imageView
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(round(imageView.frame.size.width /2), round(imageView.frame.size.height/2));
    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    if (imageView.tag == 340000)
    {
        [activityIndicator stopAnimating];
        activityIndicator.hidesWhenStopped = YES;
    }
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ( error == nil && data )
                    {
                        UIImage *urlImage = [[UIImage alloc] initWithData:data];
                        UIImage *imageToDisplay;
                        if (urlImage.imageOrientation == UIImageOrientationUp) {
                            NSLog(@"portrait");
                            imageToDisplay = urlImage;
                        } else if (urlImage.imageOrientation == UIImageOrientationLeft || urlImage.imageOrientation == UIImageOrientationRight) {
                            NSLog(@"landscape");
                            imageToDisplay = [self imageRotatedByDegrees:urlImage deg:90];
                        }else if (urlImage.imageOrientation == UIImageOrientationDown)
                        {
                            imageToDisplay = [self imageRotatedByDegrees:urlImage deg:180];
                        }
                        imageView.image = imageToDisplay;
                        [activityIndicator stopAnimating];
                        activityIndicator.hidesWhenStopped = YES;
                        [[DocumentDirectory shareDirectory] addDirectoryWithPath:[[UserManager shareUserManager] number] image:imageView.image imageName:[NSString stringWithFormat:@"%@",url]];
                    }
                    
                });
            }
        }
    }];
    [task resume];
    
//    NSOperationQueue *queue;
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    if ( queue == nil )
//    {
//        queue = [NSOperationQueue mainQueue];
//    }
//    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse * resp, NSData     *data, NSError *error)
//     {
//         dispatch_async(dispatch_get_main_queue(),^
//                        {
//                            if ( error == nil && data )
//                            {
//                                
//                                UIImage *urlImage = [[UIImage alloc] initWithData:data];
//                                UIImage *imageToDisplay;
//                                if (urlImage.imageOrientation == UIImageOrientationUp) {
//                                    NSLog(@"portrait");
//                                    imageToDisplay = urlImage;
//                                } else if (urlImage.imageOrientation == UIImageOrientationLeft || urlImage.imageOrientation == UIImageOrientationRight) {
//                                    NSLog(@"landscape");
//                                    imageToDisplay = [self imageRotatedByDegrees:urlImage deg:90];
//                                }else if (urlImage.imageOrientation == UIImageOrientationDown)
//                                {
//                                    imageToDisplay = [self imageRotatedByDegrees:urlImage deg:180];
//                                }
//                                dispatch_async(dispatch_get_main_queue(),
//                                               ^{
//                                                   imageView.image = imageToDisplay;
//                                                   [activityIndicator stopAnimating];
//                                                   activityIndicator.hidesWhenStopped = YES;
//                                                   [[DocumentDirectory shareDirectory] addDirectoryWithPath:[[UserManager shareUserManager] number] image:imageView.image imageName:[NSString stringWithFormat:@"%@",url]];
//                                               });
//                            }
//                        });
//     }];
    
}


- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}





@end
