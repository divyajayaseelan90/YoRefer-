//
//  SignUp.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoReferMedia.h"

@protocol SignUp <NSObject>

- (void)showAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)hideAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)login:(UITapGestureRecognizer *)gestureRecognizer;

- (void)signUpWithParams:(NSMutableDictionary*)params;


@end


@interface SignUpView : UIView <Media>

@property (nonatomic, weak) id <SignUp>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<SignUp>)delegate;

- (void)getProfilePicture:(NSMutableDictionary *)profilePicture;


@end
