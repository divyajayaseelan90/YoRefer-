//
//  Featured.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Featured.h"


NSString * const kFeaturedUpdatedAt =  @"updatedAt";
NSString * const kFeatureddiscount  = @"discount";
NSString * const kFeaturedentity  = @"entity";
NSString * const kFeaturedpoints  = @"points";
NSString * const kFeaturedmessage = @"message";
NSString * const kFeaturedentityId = @"entityId";
NSString * const kFeaturedSystemId = @"systemId";
NSString * const kFeaturedType= @"type";
NSString * const kFeaturedUsed= @"used";
NSString * const kFeaturedLocation= @"location";
NSString * const kFeaturedValidTo= @"validTo";
NSString * const kFeaturedValidFrom= @"validFrom";
NSString * const kFeaturedCreatedAt= @"createdAt";

@implementation Featured


+ (Featured *)getPopularWithResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        
        Featured *featured = [[Featured alloc]init];
        
        NSString *discount = [NSString stringWithFormat:@"%@",[response valueForKey:kFeatureddiscount]];
        if (discount !=nil && [discount isKindOfClass:[NSString class]] > 0)
        {
            featured.discount = discount;
        }
        
        NSString *updatedAt = ([[response valueForKey:kFeaturedUpdatedAt] isKindOfClass:[NSNull class]]?@"":[response valueForKey:kFeaturedUpdatedAt]);
        if (updatedAt !=nil && [updatedAt isKindOfClass:[NSString class]] > 0)
        {
            featured.updatedAt = updatedAt;
        }
        
        NSDictionary *entity = [response valueForKey:kFeaturedentity];
        if (entity !=nil && [entity isKindOfClass:[NSDictionary class]])
        {
            featured.entity = entity;
        }
        
        NSString *points = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedpoints]];
        if (points !=nil && [points isKindOfClass:[NSString class]] > 0)
        {
            featured.points = points;
        }
        
        NSString *message = [response valueForKey:kFeaturedmessage];
        if (message !=nil && [message isKindOfClass:[NSString class]] > 0)
        {
            featured.message = message;
        }
        
        NSString *entityId = [response valueForKey:kFeaturedentityId];
        if (entityId !=nil && [entityId isKindOfClass:[NSString class]] > 0)
        {
            featured.entityId = entityId;
        }
        
        NSString *systemId = [response valueForKey:kFeaturedSystemId];
        if (systemId !=nil && [systemId isKindOfClass:[NSString class]] > 0)
        {
            featured.systemId = systemId;
        }
        
        NSString *type = [response valueForKey:kFeaturedType];
        if (type !=nil && [type isKindOfClass:[NSString class]] > 0)
        {
            featured.type = type;
        }
        
        NSString *used = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedUsed]];
        if (used !=nil && [used isKindOfClass:[NSString class]] > 0)
        {
            featured.used = used;
        }

        NSArray *location = [response valueForKey:kFeaturedLocation];
        if (location !=nil && [location isKindOfClass:[NSArray class]])
        {
            featured.location = location;
        }
        
        NSString *validTo = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedValidTo]];
        if (validTo !=nil && [validTo isKindOfClass:[NSString class]] > 0)
        {
            featured.validTo = validTo;
        }
        
        NSString *validFrom = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedValidFrom]];
        if (validFrom !=nil && [validFrom isKindOfClass:[NSString class]] > 0)
        {
            featured.validFrom = validFrom;
        }
        
        NSString *createdAt = ([[response valueForKey:kFeaturedCreatedAt] isKindOfClass:[NSNull class]]?@"":[response valueForKey:kFeaturedCreatedAt]);
        if (createdAt !=nil && [createdAt isKindOfClass:[NSString class]] > 0)
        {
            featured.createdAt = createdAt;
        }
        
        return featured;
        
    }
    
    return nil;
}


+ (Featured *)getNearByWithResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        
        Featured *featured = [[Featured alloc]init];
        
        NSString *discount = [NSString stringWithFormat:@"%@",[response valueForKey:kFeatureddiscount]];
        if (discount !=nil && [discount isKindOfClass:[NSString class]] > 0)
        {
            featured.discount = discount;
        }
        
        NSString *updatedAt = ([[response valueForKey:kFeaturedUpdatedAt] isKindOfClass:[NSNull class]]?@"":[response valueForKey:kFeaturedUpdatedAt]);
        if (updatedAt !=nil && [updatedAt isKindOfClass:[NSString class]] > 0)
        {
            featured.updatedAt = updatedAt;
        }
        
        NSDictionary *entity = [response valueForKey:kFeaturedentity];
        if (entity !=nil && [entity isKindOfClass:[NSDictionary class]])
        {
            featured.entity = entity;
        }
        
        NSString *points = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedpoints]];
        if (points !=nil && [points isKindOfClass:[NSString class]] > 0)
        {
            featured.points = points;
        }
        
        NSString *message = [response valueForKey:kFeaturedmessage];
        if (message !=nil && [message isKindOfClass:[NSString class]] > 0)
        {
            featured.message = message;
        }
        
        NSString *entityId = [response valueForKey:kFeaturedentityId];
        if (entityId !=nil && [entityId isKindOfClass:[NSString class]] > 0)
        {
            featured.entityId = entityId;
        }
        
        NSString *systemId = [response valueForKey:kFeaturedSystemId];
        if (systemId !=nil && [systemId isKindOfClass:[NSString class]] > 0)
        {
            featured.systemId = systemId;
        }
        
        NSString *type = [response valueForKey:kFeaturedType];
        if (type !=nil && [type isKindOfClass:[NSString class]] > 0)
        {
            featured.type = type;
        }
        
        NSString *used = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedUsed]];
        if (used !=nil && [used isKindOfClass:[NSString class]] > 0)
        {
            featured.used = used;
        }
        
        NSArray *location = [response valueForKey:kFeaturedLocation];
        if (location !=nil && [location isKindOfClass:[NSArray class]])
        {
            featured.location = location;
        }
        
        NSString *validTo = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedValidTo]];
        if (validTo !=nil && [validTo isKindOfClass:[NSString class]] > 0)
        {
            featured.validTo = validTo;
        }
        
        NSString *validFrom = [NSString stringWithFormat:@"%@",[response valueForKey:kFeaturedValidFrom]];
        if (validFrom !=nil && [validFrom isKindOfClass:[NSString class]] > 0)
        {
            featured.validFrom = validFrom;
        }
        
        NSString *createdAt = ([[response valueForKey:kFeaturedCreatedAt] isKindOfClass:[NSNull class]]?@"":[response valueForKey:kFeaturedCreatedAt]);
        if (createdAt !=nil && [createdAt isKindOfClass:[NSString class]] > 0)
        {
            featured.createdAt = createdAt;
        }
        
        return featured;
        
    }
    
    return nil;
    
}


@end
