//
//  UserManager.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject
@property (strong, nonatomic) NSString *sessionToken;
@property (strong, nonatomic) NSString *activeFrom;
@property (strong, nonatomic) NSString *askCount;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *connections;
@property (strong, nonatomic) NSString *dp;
@property (strong, nonatomic) NSString *emailId;
@property (strong, nonatomic) NSString *entityReferCount;
@property (strong, nonatomic) NSString *guest;
@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *pointsBurnt;
@property (strong, nonatomic) NSString *pointsEarned;
@property (strong, nonatomic) NSString *refers;
@property (strong, nonatomic) NSString *systemId;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *currentAddress;
@property (strong, nonatomic) NSString *referAddress;
@property (strong, nonatomic) NSString *currentCity;
@property (strong, nonatomic) NSString *currentCountry;
@property (strong , nonatomic)NSArray  *Path;

@property (strong, nonatomic) NSString *cCityState;

+ (UserManager *)shareUserManager;
- (void)populateUserInfoFromResponse:(NSDictionary *)response sessionId:(NSString *)sessionId;
- (void)setCurrentLocationWithAddress:(NSDictionary *)address latitude:(NSString *)latitude
                           laongitude:(NSString *)logitude;
- (BOOL)isVlaidUser;
- (void)logOut;
- (void)setLocationService;
- (BOOL)getLocationService;
- (BOOL)isLocation;
- (void)updateUser;
- (void)setReferPage;
- (BOOL)getReferPage;
- (void)setSplashWithBool:(BOOL)isSplash;
- (BOOL)getSplash;
- (void)setReferWithResponse:(NSMutableDictionary *)response;
- (void)setDeviceToken:(NSString *)deviceToken;
- (void)enableLocation;
- (void)disableLocation;
- (void)setProfilePage;
- (BOOL)getProfilePage;
@end
