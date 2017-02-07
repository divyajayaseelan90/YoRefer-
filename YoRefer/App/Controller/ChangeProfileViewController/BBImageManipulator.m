//
//  BBImageManipulator.m
//  BabyBerry
//
//  Created by Darshan R on 4/14/15.
//  Copyright (c) 2015 CereBrahm Innovations Pvt Ltd. All rights reserved.
//

#import "BBImageManipulator.h"

@implementation BBImageManipulator

// Constants to adjust the max/min values of zoom
const CGFloat kMaxScale = 3.0;
const CGFloat kMinScale = 1.0;

+(BBImageManipulator*)loadController:(UIImage*)image{
    BBImageManipulator *controller = [[BBImageManipulator alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [controller initialize:image];
    return controller;
}

-(void)initialize:(UIImage*)image{
    
    [self setBackgroundColor:[UIColor blackColor]];
    
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImage:image];
    [self addSubview:imageView];
    
    originalImageFrame = imageView.frame;
 
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 80, 40, 40)];
    [btn setImage:[UIImage imageNamed:@"icon_account_delete.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

}

-(void)setupUIAndGestures {
    if (self.isRotatableByButton) {
        UIButton *rotateBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 30, 40, 40)];
        [rotateBtn setImage:[UIImage imageNamed:@"rotate"] forState:UIControlStateNormal];
        [rotateBtn addTarget:self action:@selector(rotateByAngle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rotateBtn];
    }
    
    if (self.isZoomable) {
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [self addGestureRecognizer:pinchRecognizer];

    }
    
    if (self.doubleTapZoomable){

        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapScale:)];
        [doubleTapRecognizer setNumberOfTapsRequired:2];
        doubleTapScaled = NO;
        [self addGestureRecognizer:doubleTapRecognizer];
        
    }
    
    if (self.isZoomable || self.isDoubleTapZoomable) {
        // if an image is zoomable, making it pannable also so we can move the image around once its zoomed.
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panRecognizer];
    }
    
    if (self.isRotatableByGesture) {
        UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        [self addGestureRecognizer:rotationRecognizer];
    }
}

/**
 * Returns YES if imageView is bigger than the self
 * or if the minX minY values doesn't match, else returns NO.
 *
 */
-(BOOL) isImageZoomed {
//    NSLog(@"------------------------");
//    NSLog(@"MaxX-%f",CGRectGetMaxX(imageView.frame));
//    NSLog(@"MaxY-%f",CGRectGetMaxY(imageView.frame));
//    NSLog(@"MinX-%f",CGRectGetMinX(imageView.frame));
//    NSLog(@"MinY-%f",CGRectGetMinY(imageView.frame));
//    
//    NSLog(@"Self MaxX-%f",CGRectGetMaxX(self.frame));
//    NSLog(@"Self MaxY-%f",CGRectGetMaxY(self.frame));
//    NSLog(@"Self X-%f",self.frame.origin.x);
//    NSLog(@"Self Y-%f",self.frame.origin.y);
//    NSLog(@"------------------------");

    if ((CGRectGetMaxX(imageView.frame) > CGRectGetMaxX(self.frame)) || (CGRectGetMaxY(imageView.frame) > CGRectGetMaxY(self.frame)) || (CGRectGetMinX(imageView.frame) < self.frame.origin.x) || (CGRectGetMinY(imageView.frame) < self.frame.origin.y)) {
        return YES;
    }
    return NO;
}

#pragma mark - Action

-(void)close:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self removeFromSuperview];
}

-(void)rotateByAngle:(id)sender {

    // Aligning the imageview in the center of the screen before rotating.
    [imageView setCenter:self.center];
    
    // Rotates the image by 90 degrees clockwise. M_PI_2(radians) = 90˚
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, M_PI_2);
    
    [imageView setTransform:newTransform];
    
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }

    CGFloat currentScale = [[imageView.layer valueForKeyPath:@"transform.scale"] floatValue];
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    // Restricting the scale between max and min scales.
    scale = MIN(scale, kMaxScale / currentScale);
    scale = MAX(scale, kMinScale / currentScale);
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [imageView setTransform:newTransform];
    
    if ([(UIPinchGestureRecognizer*)sender scale] < 1) { // Zoom Out/Pinch In
        if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            // To align the imageView to the center if the image is moved during scaling.
            [UIView animateWithDuration:0.5
                             animations:^{
                                 // Aligning the imageview in the center of the screen
                                 [imageView setCenter:self.center];

                             }];
        }
    }

    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
 
}

-(void)doubleTapScale:(id)sender {
    
    CGFloat scale;
    
    if ([self isImageZoomed]) {
        doubleTapScaled = YES;
    }
    
    if (!doubleTapScaled) {
        // Scaling up by 2 on first double tap
        scale = 2;
        CGAffineTransform currentTransform = imageView.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
        
        [imageView setTransform:newTransform];
        doubleTapScaled = YES;
    } else {
        // This executes either on a second double tap or a double tap on a zoomed image.
        // Resetting the Transform and setting the imageView back to original size.
        [imageView setTransform:CGAffineTransformIdentity];
        [imageView setFrame:originalImageFrame];
        // Aligning the image to the center of the screen.
        [imageView setCenter:self.center];
        
        doubleTapScaled = NO;
    }

}

-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [imageView setTransform:newTransform];
    
    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

-(void)move:(id)sender {

    if([self isImageZoomed]) {
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
        
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            _firstX = [imageView center].x;
            _firstY = [imageView center].y;
        }
        
        translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
        
        [imageView setCenter:translatedPoint];
    }
}

@end
