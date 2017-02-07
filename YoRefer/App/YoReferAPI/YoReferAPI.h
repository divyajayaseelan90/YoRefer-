//
//  YoReferAPI.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^APICompletionHandler)(NSDictionary *dictionary,NSError *error);

@interface YoReferAPI : NSObject

+ (YoReferAPI *)sharedAPI;

#pragma mark - Login

- (void)loginWithParams:(NSDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)tokenWithParams:(NSDictionary *)params
            completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)uploadImageWithParam:(NSDictionary *)param
           completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)signUpWithParams:(NSDictionary *)params
       completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)forgotPasswordWithParam:(NSDictionary *)params
              completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)facebookLoginWithParams:(NSDictionary *)params
              completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Me(Profile)

- (void)getAskWithParam:(NSMutableDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)getFriendwithParam:(NSMutableDictionary *)param
         completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)getReferWithParam:(NSDictionary *)param
        completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)getFeedsWithParams:(NSMutableDictionary *)params
         completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)getPlaceReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)getProductReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)getServiceReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)getWebReferWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)searchRefersByCategory:(NSMutableDictionary *)params
       completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)searchAsksByCategory:(NSMutableDictionary *)params
             completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)searchFeedsByCategory:(NSMutableDictionary *)params
             completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)searchFriendsByCategory:(NSMutableDictionary *)params
            completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Featured

- (void)featuredWithParam:(NSDictionary *)params
        completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)searchFeaturedbyCategory:(NSDictionary *)params
        completionHandler:(APICompletionHandler)apiCompletionHandler;


#pragma mark  - Entity

- (void)entityWithParams:(NSDictionary *)params
                entityId:(NSString *)entityId
       completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Location
- (void)getLocationDetailWithParma:(NSString *)param CompletionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Home

- (void)carouselWithParam:(NSDictionary *)params
        completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)referWithParams:(NSMutableDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)askWithParams:(NSMutableDictionary *)params
    completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)searchByCategory:(NSMutableDictionary *)params
       completionHandler:(APICompletionHandler)apiCompletionHandler;


- (void)getViewRefersSearchWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;
//View Asks Search
- (void)getAsksSearchWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;
//Entities Search
- (void)getEntitiesSearchWithParam:(NSDictionary *)param completionHandler:(APICompletionHandler)apiCompletionHandler;


#pragma mark - Categories

- (void)categoriesWithParam:(NSDictionary *)params
          completionHandler:(APICompletionHandler)apiCompletionHandler;
- (void)searchCategoryByCategory:(NSDictionary *)params
          completionHandler:(APICompletionHandler)apiCompletionHandler;


#pragma mark - ReferNow

- (void)getMessagesWithCompletionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)getCategoryWithCompletionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)getReferCodeWithCompletionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)referChannelWithParams:(NSMutableDictionary *)params
             completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)referWebChannelWithParams:(NSMutableDictionary *)params
                completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Map

- (void)currentLocationOfferWithParams:(NSMutableDictionary *)params
                     completionHandler:(APICompletionHandler)apiCompletionHandler;

- (void)mapSearchWithParams:(NSMutableDictionary *)params
                     completionHandler:(APICompletionHandler)apiCompletionHandler;


#pragma mark - Ask now

- (void)queryWithParams:(NSMutableDictionary *)params
           completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Category

- (void)categoryWithParams:(NSDictionary *)params
         completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Change password

- (void)changePasswordWithParams:(NSDictionary *)params
               completionHandler:(APICompletionHandler)apiCompletionHandler;

#pragma mark - Change Profile
- (void)changeProfileWithParams:(NSDictionary *)params
              completionHandler:(APICompletionHandler)apiCompletionHandler;


#pragma mark - Shorten Url

- (void)getShortenUrlWithParam:(NSMutableDictionary *)params
      completionHandler:(APICompletionHandler)apiCompletionHandler;


@end
