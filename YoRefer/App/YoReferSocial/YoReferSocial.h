//
//  YoReferSocial.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/24/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol Scocial <NSObject>

- (void)faceBookUser:(NSDictionary *)userInfo;

@end

@interface YoReferSocial : NSObject<FBLoginViewDelegate>

@property (nonatomic, weak) id<Scocial>delegate;
+ (YoReferSocial *)shareYoReferSocial;
- (void)faceBookWithDelegate:(id<Scocial>)delegate;

@end
