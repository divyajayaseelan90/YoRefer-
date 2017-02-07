//
//  Helper.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (Helper *)shareHelper;

- (BOOL)validateLoginAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (NSString *)getErrorStringFromErrorDescription:(NSArray *)error;

- (BOOL)validateSignUpAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (BOOL)emailValidationWithEmail:(NSString *)emailString;

- (BOOL)validateForgotPasswordAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (BOOL)validateOTPAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (NSString *)getLocalCountryCode;

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;

- (BOOL)validateChangePwdAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (BOOL)validateReferChannelEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (NSString *)getExactPhoneNumberWithNumber:(NSString *)phoneNumber;

- (BOOL)validateAskAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params;

- (BOOL)validateAddContactAllEnteriesWithError:(NSArray **)error contacts:(NSMutableDictionary *)contacts isMessage:(BOOL)isMessage;

- (BOOL)webValidationWithWeb:(NSString *)WebString;

-(NSString *)currentTimeWithMilliSecound;

-(NSMutableArray *)getAllContacts;

- (NSString *)getRandomEntityId;

- (void)isReferChannel:(BOOL)isReferChannel;

- (BOOL)isReferChannelStatus;
@end
