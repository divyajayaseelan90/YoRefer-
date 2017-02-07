//
//  Home.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/16/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Home.h"

NSString * const  kHomeSystemId                         = @"systemId";
NSString * const  kHomeCategory                         = @"category";
NSString * const  kHomeEntity                           = @"entity";
NSString * const  kHomeToUser                           = @"toUsers";
NSString * const  kHomeEntityId                         = @"entityId";
NSString * const  kHomeEntityName                       = @"entityName";
NSString * const  kHomeChannel                          = @"channel";
NSString * const  kHomeFrom                             = @"from";
NSString * const  kHomeNote                             = @"note";
NSString * const  kHomeType                             = @"type";
NSString * const  kHomeMediaId                          = @"mediaId";
NSString * const  kHomeLocation                         = @"location";
NSString * const  kHomeReferredAt                       = @"referredAt";
NSString * const  kHomeCity                             = @"city";
NSString * const  kHomeUpdatedAt                        = @"updatedAt";
NSString * const  kHomeAskId                            = @"askId";
NSString * const  kHomeFourSquareCategoryId             = @"foursquareCategoryId";
NSString * const  kHomeComment                          = @"comment";
NSString * const  kHomeAskedAt                          = @"askedAt";
NSString * const  kHomeAddress                          = @"address";
NSString * const  kHomeUser                             = @"user";
NSString * const  kHomeReferrals                        = @"referrals";
NSString * const  kHomeCreatedAt                        = @"createdAt";
NSString * const  kHomeResponseCount                       = @"response";


NSString * const kHomeLocality                          = @"locality";
NSString * const kHomePosition        = @"position";
NSString * const kHomeEntityID        = @"entityId";
NSString * const kHomeDP              = @"dp";
NSString * const kHomeName            = @"name";


@implementation Home

+ (Home *)getReferFromResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        
        Home *home = [[Home alloc]init];
        
        NSString *systemId = [response objectForKey:kHomeSystemId];
        if (systemId != nil && [systemId isKindOfClass:[NSString class]] > 0)
        {
            home.systemId= systemId;
        }
        
        NSDictionary *entity = [response objectForKey:kHomeEntity];
        if (entity != nil && [entity isKindOfClass:[NSDictionary class]])
        {
            home.entity = entity;
        }
        
        NSArray *toUser = [response objectForKey:kHomeToUser];
        if (toUser != nil && [toUser isKindOfClass:[NSArray class]])
        {
            home.toUser = toUser;
        }

        NSString *entityId = [response objectForKey:kHomeEntityId];
        if (entityId != nil && [entityId isKindOfClass:[NSString class]] > 0)
        {
            home.entityId= entityId;
        }
    
        NSString *entityName = [response objectForKey:kHomeEntityName];
        if (entityName != nil && [entityName isKindOfClass:[NSString class]] > 0)
        {
            home.entityName= entityName;
        }
        
        NSString *channel = [response objectForKey:kHomeChannel];
        if (channel != nil && [channel isKindOfClass:[NSString class]] > 0)
        {
            home.channel= channel;
        }
        
        NSDictionary *from = [response objectForKey:kHomeFrom];
        if (from != nil && [from isKindOfClass:[NSDictionary class]])
        {
            home.from = from;
        }
        
        NSString *note = [response objectForKey:kHomeNote];
        if (note != nil && [note isKindOfClass:[NSString class]] > 0)
        {
            home.note= note;
        }
        
        NSString *type = [response objectForKey:kHomeType];
        if (type != nil && [type isKindOfClass:[NSString class]] > 0)
        {
            home.type= type;
        }
        
        NSString *mediaId = [response objectForKey:kHomeMediaId];
        if (mediaId != nil && [mediaId isKindOfClass:[NSString class]] > 0)
        {
            home.mediaId= mediaId;
        }

        NSArray *location = [response objectForKey:kHomeLocation];
        if (location != nil && [location isKindOfClass:[NSArray class]])
        {
            home.location = location;
        }

        NSString *referredAt = [NSString stringWithFormat:@"%@",[response objectForKey:kHomeReferredAt]];
        if (referredAt != nil && [referredAt isKindOfClass:[NSString class]] > 0)
        {
            home.referredAt= referredAt;
        }
        
        return home;

        
    }
    
    return nil;
    
    
}


+ (Home *)getAskFromResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        
        Home *home = [[Home alloc]init];
        
        NSString *systemId = ([[response objectForKey:kHomeSystemId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeSystemId]);
        if (systemId != nil && [systemId isKindOfClass:[NSString class]] > 0)
        {
            home.systemId= systemId;
            
        }
        
        NSString *updatedAt = ([[response objectForKey:kHomeUpdatedAt] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeUpdatedAt]);
        if (updatedAt != nil && [updatedAt isKindOfClass:[NSString class]] > 0)
        {
            home.updatedAt = updatedAt;
            
        }
        
        NSString *category = ([[response objectForKey:kHomeCategory] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeCategory]);
        if (category != nil && [category isKindOfClass:[NSString class]] > 0)
        {
            home.category = category;
            
        }
        
        NSString *askId = ([[response objectForKey:kHomeAskId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeAskId]);
        if (askId != nil && [askId isKindOfClass:[NSString class]] > 0)
        {
            home.askId = askId;
            
        }
        
        NSString *fourSquareCategoryId = ([[response objectForKey:kHomeFourSquareCategoryId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeFourSquareCategoryId]);
        if (fourSquareCategoryId != nil && [fourSquareCategoryId isKindOfClass:[NSString class]] > 0)
        {
            home.fourSquareCategoryId = fourSquareCategoryId;
            
        }
        
        NSString *comment = ([[response objectForKey:kHomeComment] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeComment]);
        if (comment != nil && [comment isKindOfClass:[NSString class]] > 0)
        {
            home.comment = comment;
            
        }
        
        NSString *type = ([[response objectForKey:kHomeType] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeType]);
        if (type != nil && [type isKindOfClass:[NSString class]] > 0)
        {
            home.type = type;
            
        }
        
        NSArray *location = ([[response objectForKey:kHomeLocation] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeLocation]);
        if (location != nil && [location isKindOfClass:[NSArray class]])
        {
            home.location = location;
            
        }
        
        NSString *askedAt = ([[response objectForKey:kHomeAskedAt] isKindOfClass:[NSNull class]]?@"":[NSString stringWithFormat:@"%@",[response objectForKey:kHomeAskedAt]]);
        if (askedAt != nil && [askedAt isKindOfClass:[NSString class]] > 0)
        {
            home.askedAt = askedAt;
            
        }
        
        NSString *address = ([[response objectForKey:kHomeAddress] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeAddress]);
        if (address != nil && [address isKindOfClass:[NSString class]] > 0)
        {
            home.address = address;
            
        }
        
        NSString *city = ([[response objectForKey:kHomeCity] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeCity]);
        if (city != nil && [city isKindOfClass:[NSString class]] > 0)
        {
            home.city = city;
            
        }
        
        NSDictionary *user = ([[response objectForKey:kHomeUser] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeUser]);
        if (user != nil && [user isKindOfClass:[NSDictionary class]])
        {
            home.user = user;
            
        }
        
        NSArray *referrals = ([[response objectForKey:kHomeReferrals] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeReferrals]);
        if (referrals != nil && [referrals isKindOfClass:[NSArray class]])
        {
            home.referrals = referrals;
            
        }
        
        NSString *createdAt = ([[response objectForKey:kHomeCreatedAt] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeCreatedAt]);
        if (createdAt != nil && [createdAt isKindOfClass:[NSString class]] > 0)
        {
            home.createdAt = createdAt;
            
        }
        
        NSString *responseCnt = [response valueForKey:kHomeResponseCount];
        if (responseCnt != nil || [responseCnt isKindOfClass:[NSString class]]) {
            home.responseCount = responseCnt;
        }

        
        
        return home;
        
        
    }
    
    return nil;
    
    
}


+ (Home *)getEntityFromResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        
        Home *home = [[Home alloc]init];
        
        NSString *systemId = ([[response objectForKey:kHomeSystemId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeSystemId]);
        if (systemId != nil && [systemId isKindOfClass:[NSString class]] > 0)
        {
            home.systemId= systemId;
            
        }
        
        NSString *updatedAt = ([[response objectForKey:kHomeUpdatedAt] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeUpdatedAt]);
        if (updatedAt != nil && [updatedAt isKindOfClass:[NSString class]] > 0)
        {
            home.updatedAt = updatedAt;
            
        }
        
        NSString *category = ([[response objectForKey:kHomeCategory] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeCategory]);
        if (category != nil && [category isKindOfClass:[NSString class]] > 0)
        {
            home.category = category;
            
        }
        
        NSString *askId = ([[response objectForKey:kHomeAskId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeAskId]);
        if (askId != nil && [askId isKindOfClass:[NSString class]] > 0)
        {
            home.askId = askId;
            
        }
        
        NSString *fourSquareCategoryId = ([[response objectForKey:kHomeFourSquareCategoryId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeFourSquareCategoryId]);
        if (fourSquareCategoryId != nil && [fourSquareCategoryId isKindOfClass:[NSString class]] > 0)
        {
            home.fourSquareCategoryId = fourSquareCategoryId;
            
        }
        
        NSString *comment = ([[response objectForKey:kHomeComment] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeComment]);
        if (comment != nil && [comment isKindOfClass:[NSString class]] > 0)
        {
            home.comment = comment;
            
        }
        
        NSString *type = ([[response objectForKey:kHomeType] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeType]);
        if (type != nil && [type isKindOfClass:[NSString class]] > 0)
        {
            home.type = type;
            
        }
        
        NSArray *location = ([[response objectForKey:kHomeLocation] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeLocation]);
        if (location != nil && [location isKindOfClass:[NSArray class]])
        {
            home.location = location;
            
        }
        
        NSString *askedAt = ([[response objectForKey:kHomeAskedAt] isKindOfClass:[NSNull class]]?@"":[NSString stringWithFormat:@"%@",[response objectForKey:kHomeAskedAt]]);
        if (askedAt != nil && [askedAt isKindOfClass:[NSString class]] > 0)
        {
            home.askedAt = askedAt;
            
        }
        
        NSString *address = ([[response objectForKey:kHomeAddress] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeAddress]);
        if (address != nil && [address isKindOfClass:[NSString class]] > 0)
        {
            home.address = address;
            
        }
        
        NSString *city = ([[response objectForKey:kHomeCity] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeCity]);
        if (city != nil && [city isKindOfClass:[NSString class]] > 0)
        {
            home.city = city;
            
        }
        
        NSDictionary *user = ([[response objectForKey:kHomeUser] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeUser]);
        if (user != nil && [user isKindOfClass:[NSDictionary class]])
        {
            home.user = user;
            
        }
        
        NSArray *referrals = ([[response objectForKey:kHomeReferrals] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeReferrals]);
        if (referrals != nil && [referrals isKindOfClass:[NSArray class]])
        {
            home.referrals = referrals;
            
        }
        
        NSString *createdAt = ([[response objectForKey:kHomeCreatedAt] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kHomeCreatedAt]);
        if (createdAt != nil && [createdAt isKindOfClass:[NSString class]] > 0)
        {
            home.createdAt = createdAt;
            
        }
        
        
        return home;
        
        
    }
    
    return nil;
    
}

+ (Home *)getEntitySearchFromResponse:(NSDictionary *)response
{
    
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        Home *places = [[Home alloc]init];
        
        NSDictionary *entity = [response valueForKey:kHomeEntity];
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            places.entity = entity;
        }
        
        NSString *locality = [response valueForKey:kHomeLocality];
        
        if (locality != nil || [locality isKindOfClass:[NSString class]]) {
            places.locality = locality;
        }
        
        NSString *referredAt = [response valueForKey:kHomeReferredAt];
        
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            places.referredAt = referredAt;
        }
        
        NSString *category = [response valueForKey:kHomeCategory];
        
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            places.category = category;
        }
        
        
        NSArray *position = [response valueForKey:kHomePosition];
        if (locality != nil || [locality isKindOfClass:[NSArray class]]) {
            places.position = position;
        }
        
        NSString *entityId = [response valueForKey:kHomeEntityID];
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            places.entityId = entityId;
        }
        
        NSString *dp = [response valueForKey:kHomeDP];
        if (dp != nil || [dp isKindOfClass:[NSString class]]) {
            places.dp = dp;
        }
        
        NSString *type = [response valueForKey:kHomeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            places.type = type;
        }
        
        NSString *name = [response valueForKey:kHomeName];
        if (name != nil || [name isKindOfClass:[NSString class]]) {
            places.name = name;
        }
        
        return places;
    }
    return nil;
}

@end
