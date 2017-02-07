//
//  EnterOTP.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTP <NSObject>

- (void)showAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)hideAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)ForgotPassword;

- (void)enterOPTWithParams:(NSMutableDictionary *)params;

@end


@interface EnterOTPView : UIView

@property (nonatomic, weak) id <OTP>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<OTP>)delegate;

@end
