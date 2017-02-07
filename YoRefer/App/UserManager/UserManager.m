//
//  UserManager.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "UserManager.h"
#import "YoReferUserDefaults.h"
#import "UIManager.h"
#import "DocumentDirectory.h"

NSString * const kLocationService = @"locationservice";
NSString * const kSessionToken      = @"sessionToken";
NSString * const kActiveFrom        = @"activeFrom";
NSString * const kaskCount          = @"askCount";
NSString * const kcity              = @"city";
NSString * const kConnections       = @"connections";
NSString * const kDp                = @"dp";
NSString * const kEmailId           = @"emailId";
NSString * const kEntityReferCount  = @"entityReferCount";
NSString * const kGuest             = @"guest";
NSString * const kLocality          = @"locality";
NSString * const kName              = @"name";
NSString * const kNumber            = @"number";
NSString * const kPointsBurnt       = @"pointsBurnt";
NSString * const kPointsEarned      = @"pointsEarned";
NSString * const kRefers            = @"refers";
NSString * const kSystemId          = @"systemId";
NSString * const kCurrentCity       = @"currentcity";
NSString * const kUser              = @"user";
NSString * const kReferNow          = @"referNow";
NSString * const kUpdateProfile     = @"updateProfile";
NSString * const kSplash            = @"splash";
NSString * const kUserRefer         = @"refer";
@implementation UserManager

+ (UserManager *)shareUserManager
{
    static UserManager *_shareUserManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _shareUserManager = [[UserManager alloc]init];
        
    });
    return _shareUserManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //        //no internet connection
        //        self.emailId = @"test@gmail.com";
        //        self.number = @"+919845824560";
        [self populatedUserFromUserDefaults];
    }
    return self;
}

- (void)populateUserInfoFromResponse:(NSDictionary *)response sessionId:(NSString *)sessionId
{
    if (response!= nil && [response isKindOfClass:[NSDictionary class]])
    {
        NSString *sessionToken = sessionId;
        if (sessionToken != nil && [sessionToken length] > 0)
        {
            self.sessionToken = sessionToken;
        }
        NSString *activeFrom = [NSString stringWithFormat:@"%@",[response objectForKey:kActiveFrom]];
        if (activeFrom != nil && [activeFrom length] > 0)
        {
            self.activeFrom = activeFrom;
        }
        NSString *askCount = [NSString stringWithFormat:@"%@",[response  objectForKey:kaskCount]];
        if (askCount != nil && [askCount length] > 0)
        {
            self.askCount = askCount;
        }
        NSString *city = [response objectForKey:kcity];
        if (city != nil && [city length] > 0)
        {
            self.city = city;
        }
        NSString *connections = [NSString stringWithFormat:@"%@",[response  objectForKey:kConnections]];
        if (connections != nil && [connections length] > 0)
        {
            self.connections = connections;
        }
        NSString *emailId = [response objectForKey:kEmailId];
        if (emailId != nil && [emailId length] > 0)
        {
            self.emailId = emailId;
        }
        NSString *entityReferCount = [NSString stringWithFormat:@"%@",[response objectForKey:kEntityReferCount]];
        if (entityReferCount != nil && [entityReferCount length] > 0)
        {
            self.entityReferCount = entityReferCount;
        }
        NSString *guest = [NSString stringWithFormat:@"%@",[response  objectForKey:kGuest]];
        if (guest != nil && [guest length] > 0)
        {
            self.guest = guest;
        }
        NSString *locality = [NSString stringWithFormat:@"%@",[response objectForKey:kLocality]];
        if (locality != nil && [locality length] > 0)
        {
            self.locality = locality;
        }
        NSString *name = [response objectForKey:kName];
        if (name != nil && [name length] > 0)
        {
            self.name = name;
        }
        NSString *number = [NSString stringWithFormat:@"%@",[response objectForKey:kNumber]];
        if (number != nil && [number length] > 0)
        {
            self.number = number;
            
        }
        NSString *pointsBurnt = [NSString stringWithFormat:@"%@",[response objectForKey:kPointsBurnt]];
        
        if (pointsBurnt != nil && [pointsBurnt length] > 0)
        {
            self.pointsBurnt = pointsBurnt;
            
        }
        NSString *pointsEarned = [NSString stringWithFormat:@"%@",[response  objectForKey:kPointsEarned]];
        
        if (pointsEarned != nil && [pointsEarned length] > 0)
        {
            self.pointsEarned = pointsEarned;
        }
        NSString *refers = [NSString stringWithFormat:@"%@",[response objectForKey:kRefers]];
        if (refers != nil && [refers length] > 0)
        {
            self.refers = refers;
        }
        NSString *systemId = [NSString stringWithFormat:@"%@",[response objectForKey:kSystemId]];
        if (systemId != nil && [systemId length] > 0)
        {
            self.systemId = systemId;
        }
        NSString *dp = [response  objectForKey:kDp];
        BOOL result = [[dp lowercaseString] hasPrefix:@"http://"];
        if (dp != nil && [dp length] > 0 && result)
        {
            self.dp = dp;
            
        }else
        {
            self.dp = @"";
        }
    }
    if ([self isVlaidUser])
    {
        [self saveUser];
    }
}
- (BOOL)isVlaidUser
{
    return ((self.name !=nil && [self.name length] > 0) && (self.sessionToken !=nil && [self.sessionToken length] > 0));
}
- (void)updateUser
{
    NSUserDefaults *userDefaults = [YoReferUserDefaults shareUserDefaluts];
    [userDefaults removeObjectForKey:kUser];
    [userDefaults synchronize];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:16];
    if(self.sessionToken != nil && [self.sessionToken length] >0)
        [dictionary setValue:self.sessionToken forKey:kSessionToken];
    if(self.activeFrom != nil && [self.activeFrom length] >0)
        [dictionary setValue:self.activeFrom forKey:kActiveFrom];
    if(self.askCount != nil && [self.askCount length] >0)
        [dictionary setValue:self.askCount forKey:kaskCount];
    if(self.city != nil && [self.city length] >0)
        [dictionary setValue:self.city forKey:kcity];
    if(self.connections != nil && [self.connections length] >0)
        [dictionary setValue:self.connections forKey:kConnections];
    if(self.dp != nil && [self.dp length] >0)
        [dictionary setValue:self.dp forKey:kDp];
    if(self.emailId != nil && [self.emailId length] >0)
        [dictionary setValue:self.emailId forKey:kEmailId];
    if(self.entityReferCount != nil && [self.entityReferCount length] >0)
        [dictionary setValue:self.entityReferCount forKey:kEntityReferCount];
    if(self.guest != nil && [self.guest length] >0)
        [dictionary setValue:self.guest forKey:kGuest];
    if(self.locality != nil && [self.locality length] >0)
        [dictionary setValue:self.locality forKey:kLocality];
    if(self.name != nil && [self.name length] >0)
        [dictionary setValue:self.name forKey:kName];
    if(self.number != nil && [self.number length] >0)
        [dictionary setValue:self.number forKey:kNumber];
    if(self.pointsBurnt != nil && [self.pointsBurnt length] >0)
        [dictionary setValue:self.pointsBurnt forKey:kPointsBurnt];
    if(self.pointsEarned != nil && [self.pointsEarned length] >0)
        [dictionary setValue:self.pointsEarned forKey:kPointsEarned];
    if(self.refers != nil && [self.refers length] >0)
        [dictionary setValue:self.refers forKey:kRefers];
    if(self.systemId != nil && [self.systemId length] >0)
        [dictionary setValue:self.systemId forKey:kSystemId];
    if(self.currentCity != nil && [self.currentCity length] >0)
        [dictionary setValue:self.currentCity forKey:kCurrentCity];
    [userDefaults setValue:dictionary forKey:kUser];
    [userDefaults synchronize];
}

- (void)saveUser
{
    NSUserDefaults *userDefaults = [YoReferUserDefaults shareUserDefaluts];
    [userDefaults removeObjectForKey:kUser];
    [userDefaults synchronize];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:16];
    if(self.sessionToken != nil && [self.sessionToken length] >0)
        [dictionary setValue:self.sessionToken forKey:kSessionToken];
    if(self.activeFrom != nil && [self.activeFrom length] >0)
        [dictionary setValue:self.activeFrom forKey:kActiveFrom];
    if(self.askCount != nil && [self.askCount length] >0)
        [dictionary setValue:self.askCount forKey:kaskCount];
    if(self.city != nil && [self.city length] >0)
        [dictionary setValue:self.city forKey:kcity];
    if(self.connections != nil && [self.connections length] >0)
        [dictionary setValue:self.connections forKey:kConnections];
    if(self.dp != nil && [self.dp length] >0)
        [dictionary setValue:self.dp forKey:kDp];
    if(self.emailId != nil && [self.emailId length] >0)
        [dictionary setValue:self.emailId forKey:kEmailId];
    if(self.entityReferCount != nil && [self.entityReferCount length] >0)
        [dictionary setValue:self.entityReferCount forKey:kEntityReferCount];
    if(self.guest != nil && [self.guest length] >0)
        [dictionary setValue:self.guest forKey:kGuest];
    if(self.locality != nil && [self.locality length] >0)
        [dictionary setValue:self.locality forKey:kLocality];
    if(self.name != nil && [self.name length] >0)
        [dictionary setValue:self.name forKey:kName];
    if(self.number != nil && [self.number length] >0)
        [dictionary setValue:self.number forKey:kNumber];
    if(self.pointsBurnt != nil && [self.pointsBurnt length] >0)
        [dictionary setValue:self.pointsBurnt forKey:kPointsBurnt];
    if(self.pointsEarned != nil && [self.pointsEarned length] >0)
        [dictionary setValue:self.pointsEarned forKey:kPointsEarned];
    if(self.refers != nil && [self.refers length] >0)
        [dictionary setValue:self.refers forKey:kRefers];
    if(self.systemId != nil && [self.systemId length] >0)
        [dictionary setValue:self.systemId forKey:kSystemId];
    [userDefaults setValue:dictionary forKey:kUser];
    [userDefaults synchronize];
}

- (void)populatedUserFromUserDefaults
{
    NSDictionary *dictionary = [[YoReferUserDefaults shareUserDefaluts] objectForKey:kUser];
    if (dictionary != nil && [dictionary isKindOfClass:[NSDictionary class]])
    {
        NSString *sessionToken = [dictionary objectForKey:kSessionToken];
        if (sessionToken != nil && [sessionToken length] > 0)
        {
            self.sessionToken = sessionToken;
        }
        NSString *activeFrom = [dictionary  objectForKey:kActiveFrom];
        if (activeFrom != nil && [activeFrom length] > 0)
        {
            self.activeFrom = activeFrom;
        }
        NSString *askCount = [dictionary  objectForKey:kaskCount];
        if (askCount != nil && [askCount length] > 0)
        {
            self.askCount = askCount;
        }
        NSString *city = [dictionary  objectForKey:kcity];
        if (city != nil && [city length] > 0)
        {
            self.city = city;
        }
        NSString *connections = [dictionary  objectForKey:kConnections];
        if (connections != nil && [connections length] > 0)
        {
            self.connections = connections;
        }
        NSString *emailId = [dictionary  objectForKey:kEmailId];
        if (emailId != nil && [emailId length] > 0)
        {
            self.emailId = emailId;
        }
        NSString *entityReferCount = [dictionary  objectForKey:kEntityReferCount];
        if (entityReferCount != nil && [entityReferCount length] > 0)
        {
            self.entityReferCount = entityReferCount;
        }
        NSString *guest = [dictionary  objectForKey:kGuest];
        if (guest != nil && [guest length] > 0)
        {
            self.guest = guest;
        }
        NSString *locality = [dictionary  objectForKey:kLocality];
        if (locality != nil && [locality length] > 0)
        {
            self.locality = locality;
        }
        NSString *name = [dictionary  objectForKey:kName];
        if (name != nil && [name length] > 0)
        {
            self.name = name;
        }
        NSString *number = [dictionary  objectForKey:kNumber];
        
        if (number != nil && [number length] > 0)
        {
            self.number = number;
        }
        NSString *pointsBurnt = [dictionary  objectForKey:kPointsBurnt];
        if (pointsBurnt != nil && [pointsBurnt length] > 0)
        {
            self.pointsBurnt = pointsBurnt;
        }
        
        NSString *pointsEarned = [dictionary  objectForKey:kPointsEarned];
        if (pointsEarned != nil && [pointsEarned length] > 0)
        {
            self.pointsEarned = pointsEarned;
        }
        NSString *refers = [dictionary  objectForKey:kRefers];
        if (refers != nil && [refers length] > 0)
        {
            self.refers = refers;
        }
        NSString *systemId = [dictionary  objectForKey:kSystemId];
        if (systemId != nil && [systemId length] > 0)
        {
            self.systemId = systemId;
        }
        NSString *currentCity = [dictionary  objectForKey:kCurrentCity];
        if (currentCity != nil && [currentCity length] > 0)
        {
            self.currentCity = currentCity;
        }
        NSString *dp = [dictionary  objectForKey:kDp];
        if (dp != nil && [dp length] > 0)
        {
            NSArray *array = [dp componentsSeparatedByString:@"/"];
            NSString *imageName = [array objectAtIndex:[array count]-1];
            if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",self.number,imageName]])
            {
                self.dp = dp;
                
            }else
            {
                self.dp = @"";
            }
        }else
        {
            self.dp = @"";
        }
    }
}
- (void)clearUserInfo
{
    self.sessionToken = nil;
    self.activeFrom = nil;
    self.askCount = nil;
    self.city= nil;
    self.connections= nil;
    self.dp= nil;
    self.emailId= nil;
    self.entityReferCount= nil;
    self.guest= nil;
    self.locality= nil;
    self.name= nil;
    self.number= nil;
    self.pointsBurnt= nil;
    self.pointsEarned= nil;
    self.refers= nil;
    self.systemId= nil;
    NSUserDefaults *userDefaults = [YoReferUserDefaults shareUserDefaluts];
    [userDefaults removeObjectForKey:kUser];
    [userDefaults synchronize];
}

- (void)logOut
{
    [self clearUserInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLogOut" object:self userInfo:nil];
}

#pragma mark - TwitterSharing
- (void)enableLocation
{
    [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kLocationService];
}
- (void)disableLocation
{
    [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kLocationService];
}
- (void)setLocationService
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kLocationService])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kLocationService];
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kLocationService];
}
- (BOOL)isLocation
{
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kLocationService];
}
- (BOOL)getLocationService
{
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kLocationService];
}
- (void)setCurrentLocationWithAddress:(NSDictionary *)address latitude:(NSString *)latitude
                           laongitude:(NSString *)logitude
{
    if (address != nil && [address isKindOfClass:[NSDictionary class]])
    {
        self.Path = [address objectForKey:@"FormattedAddressLines"];
    }
    
    if (latitude != nil && [latitude length] > 0)
    {
        self.latitude = latitude;
    }
    
    if (logitude != nil && [logitude length] > 0)
    {
        self.longitude = logitude;
    }
}

#pragma mark - Ask

- (void)setReferPage
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kReferNow])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kReferNow];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kReferNow];
}


- (BOOL)getReferPage
{
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kReferNow];
}
- (void)setSplashWithBool:(BOOL)isSplash
{
    if (isSplash)
    {
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kSplash];
        
    }else
    {
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kSplash];
        
    }
}


- (BOOL)getSplash
{
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kSplash];
}


#pragma  mark - Refer

- (void)setReferWithResponse:(NSMutableDictionary *)response
{
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        [response setValue:self.currentAddress forKey:@"location"];
        [[YoReferUserDefaults shareUserDefaluts] setValue:response forKey:kUserRefer];
        [[YoReferUserDefaults shareUserDefaluts] synchronize];
        
    }
    
}

#pragma mark - Update profile page
- (void)setProfilePage
{
    if ([[YoReferUserDefaults shareUserDefaluts] boolForKey:kUpdateProfile])
        [[YoReferUserDefaults shareUserDefaluts] setBool:NO forKey:kUpdateProfile];
    
    else
        [[YoReferUserDefaults shareUserDefaluts] setBool:YES forKey:kUpdateProfile];
}


- (BOOL)getProfilePage
{
    return [[YoReferUserDefaults shareUserDefaluts] boolForKey:kUpdateProfile];
}


- (void)setDeviceToken:(NSString *)deviceToken
{
    [[NSUserDefaults standardUserDefaults]setValue:deviceToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
