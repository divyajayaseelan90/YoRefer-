//
//  Configuration.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Configuration : NSObject


+ (Configuration *)shareConfiguration;

- (UIFont *)yoReferFontWithSize:(CGFloat)size;

- (UIFont *)yoReferBoldFontWithSize:(CGFloat)size;

+ (NSString *)appGroupName;

- (NSString *)appName;

- (NSString *)errorMessage;

-(NSString *)baseURL;

- (NSString *)timeInterval;

- (NSString *)connectionStatus;

- (NSString *)getTermsAndConditions;

- (NSString *)getPrivacyPolicy;

- (NSString *)getAboutUs;

- (NSString *)getFeedBackRecipient;


@end
