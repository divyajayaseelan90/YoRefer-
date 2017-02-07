//
//  YoReferSocialChannels.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "YoReferSocialChannels.h"
#import "YoReferUserDefaults.h"


NSString *const kFacebookSharing    = @"facebook";
NSString *const kTwitterSharing     = @"twitter";
NSString *const kWhatsappSharing    = @"whatsapp";
NSString *const kSMSSharing         = @"sms";
NSString *const kEmailSharing       = @"email";
NSString *const kPointerestSharing  = @"pointerest";

@implementation YoReferSocialChannels


 + (YoReferSocialChannels *)shareYoReferSocial
{
    
    static YoReferSocialChannels *_shareYoReferSocial = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        _shareYoReferSocial = [[YoReferSocialChannels alloc]init];
        
    });
    
    return _shareYoReferSocial;
    
}

#pragma mark - FaceBookSharing

- (void)setDefaultSharing
{
    /*
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kFacebookSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kTwitterSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kWhatsappSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kSMSSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kEmailSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kPointerestSharing];
    */
    
    [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kFacebookSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kTwitterSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kWhatsappSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kSMSSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kEmailSharing];
    [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kPointerestSharing];
    
}


- (void)setFaceBookSharing
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kFacebookSharing])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kFacebookSharing];

    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kFacebookSharing];
    
}


- (BOOL)getFaceBookSahring
{
    
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kFacebookSharing];
    
    
}

#pragma mark - TwitterSharing

- (void)setTwitterSharing
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kTwitterSharing])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kTwitterSharing];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kTwitterSharing];
    
}


- (BOOL)getTwitterSahring
{
    
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kTwitterSharing];
    
    
}

#pragma mark - WhatsappSharing

- (void)setWhatsappSharing
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kWhatsappSharing])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kWhatsappSharing];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kWhatsappSharing];
    
}


- (BOOL)getWhatsappSahring
{
    
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kWhatsappSharing];
    
    
}


#pragma mark - SmsSharing

- (void)setSmsSharing
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kSMSSharing])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kSMSSharing];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kSMSSharing];
    
}


- (BOOL)getSmsSahring
{
    
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kSMSSharing];
    
    
}


#pragma mark - EmailSharing

- (void)setEmailSharing
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kEmailSharing])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kEmailSharing];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kEmailSharing];
    
}


- (BOOL)getEmailSahring
{
    
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kEmailSharing];
    
    
}

#pragma mark - PointerestSharing

- (void)setPointerestSharing
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kPointerestSharing])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kPointerestSharing];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kPointerestSharing];
    
}


- (BOOL)getPointerestSahring
{
    
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kPointerestSharing];
    
    
}



@end
