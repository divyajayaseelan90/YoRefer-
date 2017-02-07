//
//  Login.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Login <NSObject>

- (void)showAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)hideAnimatedWithTextFiled:(UITextField *)textFiled;

- (void)signUp:(UITapGestureRecognizer *)gestureRecognizer;

- (void)loginWithParams:(NSMutableDictionary*)params;

- (void)ForgotPassword;

- (void)faceBook;

@end

@interface LoginView : UIView

@property (nonatomic,weak) id <Login>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Login>)delegate;

@end
