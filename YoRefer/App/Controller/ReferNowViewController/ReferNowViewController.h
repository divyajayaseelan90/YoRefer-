//
//  ReferNowViewController.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/15/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "ReferNowTableViewCell.h"
#import "ShareView.h"
#import "CategoriesView.h"
#import <MediaPlayer/MediaPlayer.h>


#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>



@protocol Refer <NSObject>

@end

@interface ReferNowViewController : BaseViewController<referNowTableViewCell,Share,CategoryView,Refer, FBSDKSharingDelegate>

@property (nonatomic, readwrite) id<Refer>delegate;
@property (nonatomic, assign) int referOptionCount;
@property (nonatomic, retain) NSString * msg;

- (instancetype)initWithReferDetail:(NSMutableDictionary *)referDetail delegate:(id<Refer>)delegate;
- (void)getReferChannel:(NSDictionary *)referChannel;
- (void)messageWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel;
- (void)mailWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel;
- (void)wahtsUpWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel;
- (void)pushToReferScreen:(NSArray *)array;
- (void)getCurrentAddressDetail:(NSDictionary *)currentAddress;

@end

extern                              NSString            *isnameFieldBlank;

