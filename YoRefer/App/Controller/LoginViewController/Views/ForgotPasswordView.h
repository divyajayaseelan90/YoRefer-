//
//  ForgotPassword.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ForgotPassword <NSObject>

- (void)showAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)hideAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)forgotPasswordWithParams:(NSMutableDictionary *)params;

- (void)login:(UITapGestureRecognizer *)gestureRecognizer;

@end


@interface ForgotPasswordView : UIView

@property (nonatomic,weak) id <ForgotPassword>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<ForgotPassword>)delegate;

@end
