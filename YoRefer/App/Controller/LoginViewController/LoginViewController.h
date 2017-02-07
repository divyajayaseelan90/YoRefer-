//
//  LoginViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 06/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpView.h"
#import "LoginView.h"
#import "ForgotPasswordView.h"
#import "EnterOTPView.h"

@interface LoginViewController : UIViewController<Login,SignUp,ForgotPassword,OTP>


- (void)showAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)hideAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)login:(UITapGestureRecognizer *)gestureRecognizer;

- (void)signUp:(UITapGestureRecognizer *)gestureRecognizer;

- (void)ForgotPassword;

- (void)loginWithParams:(NSMutableDictionary*)params;

- (void)forgotPasswordWithParams:(NSMutableDictionary *)params;

- (void)enterOPTWithParams:(NSMutableDictionary *)params;

- (void)signUpWithParams:(NSMutableDictionary*)params;

- (void)faceBook;

- (void)faceBookUser:(NSDictionary *)userInfo;

- (void)termsAndConditions;

- (void)privacyPolicy;

@end
