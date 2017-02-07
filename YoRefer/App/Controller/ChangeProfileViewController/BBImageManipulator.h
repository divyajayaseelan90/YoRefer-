//
//  BBImageManipulator.h
//  BabyBerry
//
//  Created by Darshan R on 4/14/15.
//  Copyright (c) 2015 CereBrahm Innovations Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBImageManipulator : UIView {
    UIImageView *imageView;
    CGFloat _firstX;
    CGFloat _firstY;
    CGFloat _lastScale;
    CGFloat _lastRotation;
    BOOL doubleTapScaled;
    CGRect originalImageFrame;
}

@property (nonatomic, assign, getter=isRotatableByButton) BOOL rotatableByButton;
@property (nonatomic, assign, getter=isRotatableByGesture) BOOL rotatableByGesture;
@property (nonatomic, assign, getter=isZoomable) BOOL zoomable;
@property (nonatomic, assign, getter=isDoubleTapZoomable) BOOL doubleTapZoomable;

+(BBImageManipulator*)loadController:(UIImage*)image;
-(void) setupUIAndGestures;

@end
