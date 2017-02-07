//
//  LocalReferAsk.m
//  YoRefer
//
//  Created by Bhaskar C M on 2/17/16.
//  Copyright © 2016 UDVI. All rights reserved.
//

#import "LocalReferAsk.h"
#import "CoreData.h"
#import "UserManager.h"
#import "DocumentDirectory.h"
#import "YoReferAPI.h"
#import "Configuration.h"
#import "Utility.h"
#import "YoReferUserDefaults.h"
#import "UIManager.h"

NSString    *   const kLocalReferNowError        = @"Unable to get refer";
NSString    *   const kLocalQueryError           = @"Unable to get ask";


@interface LocalReferAsk ()
@property (nonatomic, strong) NSArray *localRefer, *localAsk;
@property (nonatomic, readwrite) NSInteger isLocalIndex, isLocalAskIndex;
@property (nonatomic, strong) NSMutableDictionary *referChannel, *askLocal;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSString *channelType,*entityId;
@end

@implementation LocalReferAsk

+ (LocalReferAsk *)shareInstanceLocalAsk
{
    static LocalReferAsk *_shareLocalAsk = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareLocalAsk = [[LocalReferAsk alloc]init];
    });
    return _shareLocalAsk;
}

- (void)ask
{
   self.localAsk = [[CoreData shareData] getLocalAskWithLoginId:[[UserManager shareUserManager] number]];
    
    
    if ([self.localAsk count] > 1)
    {
        self.isLocalAskIndex = 0;
        self.askLocal = [self.localAsk objectAtIndex:self.isLocalIndex];
        
    }else
    {
        if ([self.localAsk count] > 0)
        {
            self.isLocalAskIndex = 0;
            self.askLocal = [self.localAsk objectAtIndex:self.isLocalIndex];
            
            
        }
    }
    
    if ([self.localAsk count] > 0)
    {
     
        [self postAskWithParams:self.askLocal];
        
    }

    
}


- (void)postAskWithParams:(NSMutableDictionary *)params
{
    
    [[YoReferAPI sharedAPI] queryWithParams:params completionHandler:^(NSDictionary *response , NSError *error)
     {
         
         [self didReceiveQueryWithResponse:response error:error];
         
     }];
    
}

- (void)didReceiveQueryWithResponse:(NSDictionary *)response error:(NSError *)error
{
    
    
    if (error !=nil)
    {
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kLocalQueryError, @""), nil, @"Ok", nil, 0);
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else
    {
        
        
        NSMutableDictionary *parmas = [[YoReferUserDefaults shareUserDefaluts] objectForKey:@"login"];
        
        [[YoReferAPI sharedAPI] loginWithParams:parmas completionHandler:^(NSDictionary *response ,NSError *error){
            
            [self didReceiveQueryLoginWithResponse:response error:error];
            
        }];
        
        
    }
    
    
    
    
}

- (void)didReceiveQueryLoginWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }
        
    }else {
        
        [[UserManager shareUserManager] populateUserInfoFromResponse:[[resonse objectForKey:@"response"] objectForKey:@"user"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"meprofileupdated" object:self userInfo:nil];
        
        
        
        if ([self.localAsk count] > 1)
        {
            
            if (self.isLocalAskIndex + 1 == [self.localAsk count])
            {
                [[CoreData shareData] deleteAskWithLoginId:[[UserManager shareUserManager] number]];
                
                [[CoreData shareData] deleteLocalAskWithLoginId:[[UserManager shareUserManager] number]];

                
            }else
            {
                self.isLocalAskIndex ++;
                self.askLocal = [self.localAsk objectAtIndex:self.isLocalAskIndex];
                [self postAskWithParams:self.askLocal];
                
            }
        }else
        {
            [[CoreData shareData] deleteAskWithLoginId:[[UserManager shareUserManager] number]];
            
            [[CoreData shareData] deleteLocalAskWithLoginId:[[UserManager shareUserManager] number]];

            
        }
        
    
    }
    
    
}

- (void)refer
{
    [self ask];
    
    self.localRefer = [[CoreData shareData] getLocalReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([self.localRefer count] > 1)
    {
        self.isLocalIndex = 0;
        self.referChannel = [self.localRefer objectAtIndex:self.isLocalIndex];
        self.contacts = [[self.localRefer objectAtIndex:self.isLocalIndex] valueForKey:@"to"];
        self.channelType = [[self.localRefer objectAtIndex:self.isLocalIndex] valueForKey:@"channeltype"];
    }else
    {
        if ([self.localRefer count] > 0)
        {
            self.isLocalIndex = 0;
            self.referChannel = [self.localRefer objectAtIndex:self.isLocalIndex];
            self.contacts = [[self.localRefer objectAtIndex:self.isLocalIndex] valueForKey:@"to"];
            self.channelType = [[self.localRefer objectAtIndex:self.isLocalIndex] valueForKey:@"channeltype"];
            
        }
    }
    
    if ([self.localRefer count] > 0)
    {
        if ([self.referChannel objectForKey:@"referimage"] != nil && [[self.referChannel objectForKey:@"referimage"]isKindOfClass:[UIImage class]])
        {
            
            [self postImageWithImge];
            
        }else
        {
            
            [self getReferCode];
            
        }
        
        
    }


}

#pragma mark - Post image
- (void)postImageWithImge
{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
    if ([[self.referChannel objectForKey:@"referimage"] isKindOfClass:[UIImage class]])
    {
        
        [param setValue:[self.referChannel objectForKey:@"referimage"] forKey:@"profileImage"];
        
        
    }else
    {
        
        NSArray *array = [[NSString stringWithFormat:@"%@",[self.referChannel objectForKey:@"referimage"]] componentsSeparatedByString:@"/"];
        
        NSString *imageName = [array objectAtIndex:[array count]-1];
        
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        
        if ([[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
            
            [param setValue:[[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] forKey:@"profileImage"];
            
            
        }
        
    }
    
    
    
    
    [[YoReferAPI sharedAPI] uploadImageWithParam:param completionHandler:^(NSDictionary *response,NSError *error)
     {
         
         [self didReceiveImageWithResponse:response error:error];
         
         
     }];
}

- (void)didReceiveImageWithResponse:(NSDictionary *)response error:(NSError *)error
{
    
    if (error !=nil)
    {

        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kLocalReferNowError, @""), nil, @"Ok", nil, 0);
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else
    {
        
        [self.referChannel setValue:[response objectForKey:@"response"] forKey:@"mediaLink"];
        [self getReferCode];
    }
    
}

#pragma mark - Refer code
- (void)getReferCode
{
    
    [[YoReferAPI sharedAPI] getReferCodeWithCompletionHandler:^(NSDictionary * response ,NSError *error)
     {
         
         [self didReceiveReferCodeWithResponse:response error:error];
         
         
     }];
    
}

- (void)didReceiveReferCodeWithResponse:(NSDictionary *)response error:(NSError *)error
{
    
    if (error !=nil)
    {
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kLocalReferNowError, @""), nil, @"Ok", nil, 0);
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else
    {
        
        [self.referChannel setValue:[response objectForKey:@"response"] forKey:@"refercode"];
        
        [self setReferChannel];
        
    }
    
    
}

#pragma mark - Refer channel
- (void)setReferChannel
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    
    if (![[self.referChannel objectForKey:@"isentiyd"] boolValue])
    {
        
        NSMutableDictionary *subParams;

        
        if ([[self.referChannel objectForKey:@"web"] boolValue])
        {
            
            subParams = [NSMutableDictionary dictionaryWithCapacity:4];
            [subParams setValue:[self.referChannel objectForKey:@"name"] forKey:@"name"];
            [subParams setValue:@"web" forKey:@"type"];
            //TODO:
            [subParams setValue:[self.referChannel valueForKey:@"category"] forKey:@"category"];
            [subParams setValue:[self.referChannel objectForKey:@"website"] forKey:@"website"];
            
            
            
        }else
        {
            subParams = [NSMutableDictionary dictionaryWithCapacity:11];
            
            [subParams setValue:[self.referChannel objectForKey:@"entityId"] forKey:@"entityId"];
            self.entityId = [subParams valueForKey:@"entityId"];
            
            [subParams setValue:[self.referChannel objectForKey:@"name"] forKey:@"name"];
            
            [subParams setValue:@"place" forKey:@"type"];
            
            [[self.referChannel objectForKey:@"categorytype"] isEqualToString:@"product"]?[subParams setValue:@"place" forKey:@"type"]:[subParams setValue:[[self.referChannel objectForKey:@"categorytype"] lowercaseString] forKey:@"type"];
            
            //            [subParams setValue:[[self.referChannel objectForKey:@"categorytype"] lowercaseString] forKey:@"type"];
            //TODO:
            [subParams setValue:[self.referChannel valueForKey:@"category"] forKey:@"category"];
            
            [subParams setValue:[NSString stringWithFormat:@"%@\n%@",[self.referChannel objectForKey:@"location"],[self.referChannel objectForKey:@"address"]] forKey:@"locality"];
            
            [subParams setValue:[self.referChannel objectForKey:@"refercity"] forKey:@"city"];
            
            [subParams setValue:[self.referChannel objectForKey:@"refercountry"] forKey:@"country"];
            
            [subParams setValue:[self.referChannel objectForKey:@"website"] forKey:@"website"];
            
            [subParams setValue:[NSArray arrayWithObjects:[self.referChannel objectForKey:@"longitude"],[self.referChannel objectForKey:@"latitude"], nil] forKey:@"position"];
            
            [subParams setValue:[self.referChannel objectForKey:@"phone"] forKey:@"phone"];
             //TODO:
            [subParams setValue:([[self.referChannel valueForKey:@"category"] length] > 0)?[self.referChannel valueForKey:@"category"]:@"" forKey:@"foursquareCategoryId"];
            
            
        }
        
        
        if ([[self.referChannel objectForKey:@"categorytype"] isEqualToString:@"product"])
        {
            
            NSMutableDictionary *purchageDetail=[[NSMutableDictionary alloc]init];
            [purchageDetail setValue:subParams forKey:@"detail"];
            
            NSMutableDictionary *product=[[NSMutableDictionary alloc]init];
            [product setValue:purchageDetail forKey:@"purchasedFrom"];
            
            [product setValue:[self getRandomEntityId] forKey:@"entityId"];
            self.entityId = [product valueForKey:@"entityId"];
            [product setValue:[self.referChannel objectForKey:@"name"] forKey:@"name"];
            [product setValue:[[self.referChannel objectForKey:@"categorytype"] lowercaseString] forKey:@"type"];
            //[product setValue:@"place"  forKey:@"type"];
            //TODO:
            [product setValue:[self.referChannel valueForKey:@"category"] forKey:@"category"];
            [product setValue:[self.referChannel objectForKey:@"city"] forKey:@"city"];
            [params setValue:product forKey:@"entity"];
            
        }else
        {
            
            [params setValue:subParams forKey:@"entity"];
            
        }
        
        
        
        
        
    }else
    {
        
        NSMutableDictionary *subParams = [NSMutableDictionary dictionaryWithCapacity:1];
        [subParams setValue:[self.referChannel objectForKey:@"entityId"] forKey:@"entityId"];
        self.entityId = [subParams valueForKey:@"entityId"];
        [params setValue:subParams forKey:@"entity"];
        
    }
    
    if ([[self.referChannel objectForKey:@"web"] boolValue])
    {
        
    }else
    {
        
        if ([self.referChannel objectForKey:@"mediaLink"]!=nil && [[self.referChannel objectForKey:@"mediaLink"] length] > 0)
        {
            [params setValue:([self.referChannel objectForKey:@"mediaLink"]!=nil && [[self.referChannel objectForKey:@"mediaLink"] length] > 0)?[self.referChannel objectForKey:@"mediaLink"]:@"" forKey:@"mediaLink"];
            
            
        }else
            
        {
            
            
            
            [params setValue:([self.referChannel objectForKey:@"referimage"]!=nil && [[self.referChannel objectForKey:@"referimage"] length] > 0)?[self.referChannel objectForKey:@"referimage"]:@"" forKey:@"mediaLink"];
            
        }
        
        
    }
    
    [params setValue:[self.referChannel objectForKey:@"refercode"] forKey:@"referCode"];
    [params setValue:([self.referChannel objectForKey:@"message"] != nil && [[self.referChannel objectForKey:@"message"] length] > 0)?[self.referChannel objectForKey:@"message"]:@"" forKey:@"note"];
    [params setValue:self.contacts forKey:@"to"];
    [params setValue:self.channelType forKey:@"channel"];
    
    [[YoReferAPI sharedAPI] referChannelWithParams:params completionHandler:^(NSDictionary *response , NSError *error)
     {
         
         
         [self didReceiveReferChannelWithResponse:response error:error];
         
     }];
    
}

- (void)didReceiveReferChannelWithResponse:(NSDictionary *)response error:(NSError *)error
{
    if (error !=nil)
    {

        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kLocalReferNowError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        NSMutableDictionary *parmas = [[YoReferUserDefaults shareUserDefaluts] objectForKey:@"login"];
        [[YoReferAPI sharedAPI] loginWithParams:parmas completionHandler:^(NSDictionary *response ,NSError *error){
            [self didReceiveLoginWithResponse:response error:error];
        }];
    }
    
}

- (void)didReceiveLoginWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }
        
    }else {
        NSArray *feedData = @[@"300",@"301",@"302"];
        for (int i = 0; i< feedData.count; i++)
        {
            [[CoreData shareData] deleteFeedsWithLoginId:[[UserManager shareUserManager] number]feedsType:feedData[i]];
        }
        [[UserManager shareUserManager] populateUserInfoFromResponse:[[resonse objectForKey:@"response"] objectForKey:@"user"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
        [[CoreData shareData] deleteReferWithLoginId:[[UserManager shareUserManager] number]];
        
            if ([self.localRefer count] > 1)
            {
                
                if (self.isLocalIndex + 1 == [self.localRefer count])
                {
                    [[CoreData shareData] deleteLocalReferWithLoginId:[[UserManager shareUserManager] number]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loclaRefer" object:self userInfo:nil];
                    
                }else
                {
                    self.isLocalIndex ++;
                    self.referChannel = [self.localRefer objectAtIndex:self.isLocalIndex];
                    self.contacts = [[self.localRefer objectAtIndex:self.isLocalIndex] valueForKey:@"to"];
                    self.channelType = [[self.localRefer objectAtIndex:self.isLocalIndex] valueForKey:@"channeltype"];
                    if ([self.referChannel objectForKey:@"referimage"] != nil && [[self.referChannel objectForKey:@"referimage"]isKindOfClass:[UIImage class]])
                    {
                        
                        [self postImageWithImge];
                        
                    }else
                    {
                        
                        [self getReferCode];
                        
                    }
                    
                }
            }else
            {
                [[CoreData shareData] deleteLocalReferWithLoginId:[[UserManager shareUserManager] number]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loclaRefer" object:self userInfo:nil];
                
            }
            
        }
}

#pragma mark -
- (NSString *)getRandomEntityId
{
    
    NSString *letters= @"abcdOPQRSTUVWXYZ0123456789";
    
    NSString *entityId = [self randomStringWithLength:20 letters:letters];
    
    return entityId;
    
    
}


-(NSString *) randomStringWithLength: (int) len letters:(NSString *)letters {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}


@end
