
//
//  MeModel.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/12/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeModel : NSObject

@property (strong, nonatomic) NSDictionary *entity;
@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSString *referredAt;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSArray *position;
@property (strong, nonatomic) NSString *entityId;
@property (strong, nonatomic) NSString *dp;
@property (strong, nonatomic) NSString *latlng;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSString *systemId;
@property (strong, nonatomic) NSString *updatedAt;
@property (strong, nonatomic) NSString *foursquareCategoryId;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *askId;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSArray *location;
@property (strong, nonatomic) NSString *askedAt;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *referrals;
@property (strong, nonatomic) NSString *responseCount;

@property (strong, nonatomic) NSString *refers;
@property (strong, nonatomic) NSString *pointsEarned;
@property (strong, nonatomic) NSString *connections;
@property (strong, nonatomic) NSString *askCount;
@property (strong, nonatomic) NSString *pointsBurnt;
@property (strong, nonatomic) NSString *facebookId;
@property (strong, nonatomic) NSString *guest;
@property (strong, nonatomic) NSString *emailId;
@property (strong, nonatomic) NSString *entityReferCount;
@property (strong, nonatomic) NSString *activeFrom;
@property (strong, nonatomic) NSString *number;

@property (strong, nonatomic) NSArray  *toUsers;
@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSDictionary *from;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSString *mediaId;

+ (MeModel *)getAllSearchRefersByResponse:(NSDictionary *)response;

+ (MeModel *)getPlaceByResponse:(NSDictionary *)response;

+ (MeModel *)getProductByResponse:(NSDictionary *)response;

+ (MeModel *)getServiceByResponse:(NSDictionary *)response;

+ (MeModel *)getAskByResponse:(NSDictionary *)response;

+ (MeModel *)getFriendsByResponse:(NSDictionary *)response;

+ (MeModel *)getFeedsAllByResponse:(NSDictionary *)response;

+ (MeModel *)getFeedsSentByResponse:(NSDictionary *)response;

+ (MeModel *)getFeedsReceivedByResponse:(NSDictionary *)response;
@end
