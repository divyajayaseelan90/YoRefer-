//
//  CoreData.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreData : NSObject

+ (CoreData *)shareData;

- (void)setCarouselWithLoginId:(NSString *)loginId response:(NSDictionary *)response;

- (NSArray *)getCarouselWithLoginId:(NSString *)loginId;

- (void)deleteCarouselWithLoginId:(NSString *)loginId;

- (void)setFeaturedWithLoginId:(NSString *)loginId response:(NSDictionary *)response;

- (NSArray *)getFeaturedWithLoginId:(NSString *)loginId;

#pragma mark  - Me

- (void)setReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getReferWithLoginId:(NSString *)loginId;
- (void)setQueriesWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getQueriesWithLoginId:(NSString *)loginId;
- (void)setFeedsWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getFeedsWithLoginId:(NSString *)loginId feedsType:(NSString *)feedsType;
- (void)setFeedsWithLoginId:(NSString *)loginId response:(NSDictionary *)response feedsType:(NSString *)feedsType;
- (NSArray *)getFriendsWithLoginId:(NSString *)loginId;
- (void)deleteFriendsWithLoginId:(NSString *)loginId;
- (void)setFriendsWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
//Place
- (void)setPlaceReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getPlaceReferWithLoginId:(NSString *)loginId;
- (void)deletePlaceReferWithLoginId:(NSString *)loginId;
//Product
- (void)setProdcutReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getProducteReferWithLoginId:(NSString *)loginId;
- (void)deleteProductReferWithLoginId:(NSString *)loginId;
//Service
- (void)setServiceReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getServiceReferWithLoginId:(NSString *)loginId;
- (void)deleteServiceReferWithLoginId:(NSString *)loginId;
//Web
- (void)setWebReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getWebReferWithLoginId:(NSString *)loginId;
- (void)deleteWebReferWithLoginId:(NSString *)loginId;

- (void)deleteFeaturedWithLoginId:(NSString *)loginId;
- (void)deleteQueriesWithLoginId:(NSString *)loginId;
#pragma mark - home
- (void)setHomeReferWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getHomeReferWithLoginId:(NSString *)loginId;
- (void)setHomeAskWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getHomeAskWithLoginId:(NSString *)loginId;
- (NSArray *)getHomeEntityWithLoginId:(NSString *)loginId;
- (void)setHomeEntityWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (void)deleteFeedsWithLoginId:(NSString *)loginId feedsType:(NSString *)feed;

#pragma mark - Category
- (void)setCategoryWithLoginId:(NSString *)loginId response:(NSDictionary *)response;
- (NSArray *)getCategoryAskWithLoginId:(NSString *)loginId;
- (void)deleteCategoryWithLoginId:(NSString *)loginId;

- (void)deleteAskWithLoginId:(NSString *)loginId;
- (void)deleteReferWithLoginId:(NSString *)loginId;

- (void)setContactWithLoginId:(NSString *)loginId response:(NSMutableArray *)response type:(NSString *)type;
- (NSArray *)getContactAskWithLoginId:(NSString *)loginId type:(NSString *)type;
- (void)deleteContactWithLoginId:(NSString *)loginId type:(NSString *)type;

#pragma mark - Offline
- (void)setOfflineReferDetailsWithLoginId:(NSString *)loginId response:(NSMutableArray *)response;
- (NSArray *)getOfflineReferWithLoginId:(NSString *)loginId;
- (void)deleteOfflineReferWithLoginId:(NSString *)loginId;

- (void)setOfflineAskDetailsWithLoginId:(NSString *)loginId response:(NSMutableArray *)response;
- (NSArray *)getOfflineAskWithLoginId:(NSString *)loginId;
- (void)deleteOfflineAskWithLoginId:(NSString *)loginId;

- (void)localReferWithLoginId:(NSString *)loginId response:(NSMutableArray *)response;
- (NSArray *)getLocalReferWithLoginId:(NSString *)loginId;
- (void)deleteLocalReferWithLoginId:(NSString *)loginId;

- (void)localAskWithLoginId:(NSString *)loginId response:(NSMutableArray *)response;
- (NSArray *)getLocalAskWithLoginId:(NSString *)loginId;
- (void)deleteLocalAskWithLoginId:(NSString *)loginId;

@end

