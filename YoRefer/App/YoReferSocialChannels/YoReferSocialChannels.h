//
//  YoReferSocialChannels.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoReferSocialChannels : NSObject


+ (YoReferSocialChannels *)shareYoReferSocial;

- (void)setFaceBookSharing;

- (BOOL)getFaceBookSahring;

- (void)setTwitterSharing;

- (BOOL)getTwitterSahring;

- (void)setWhatsappSharing;

- (BOOL)getWhatsappSahring;

- (void)setSmsSharing;

- (BOOL)getSmsSahring;

- (void)setEmailSharing;

- (BOOL)getEmailSahring;

- (void)setPointerestSharing;

- (BOOL)getPointerestSahring;

- (void)setDefaultSharing;

@end
