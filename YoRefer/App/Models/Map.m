//
//  Map.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/23/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Map.h"


NSString * const  kMapEntity                           = @"entity";
NSString * const  kMapLocality                         = @"locality";
NSString * const  kMapReferredAt                       = @"referredAt";
NSString * const  kMapCategory                         = @"category";
NSString * const  kMapPosition                         = @"position";
NSString * const  kMapEntityId                         = @"entityId";
NSString * const  kMapDp                               = @"dp";
NSString * const  kMapType                             = @"type";
NSString * const  kMapnName                            = @"name";

@implementation Map


+ (Map *)MapWithResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
     
        Map *map = [[Map alloc]init];

        NSDictionary *entity = ([[response objectForKey:kMapEntity] isKindOfClass:[NSNull class]] ? @"":[response objectForKey:kMapEntity]);
        if (entity != nil && [entity isKindOfClass:[NSDictionary class]])
        {
            
            map.entity = entity;
        }
        
        NSString *locality = ([[response objectForKey:kMapLocality] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapLocality]);
        if (locality != nil && [locality isKindOfClass:[NSString class]] > 0)
        {
            map.locality = locality;
        }
        
        NSString *referredAt = ([[response objectForKey:kMapReferredAt] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapReferredAt]);
        if (referredAt != nil && [referredAt isKindOfClass:[NSString class]] > 0)
        {
            map.referredAt = referredAt;
        }
        
        NSString *category = ([[response objectForKey:kMapCategory] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapCategory]);
        if (category != nil && [category isKindOfClass:[NSString class]] > 0)
        {
            map.category = category;
        }
        
        NSArray *position = ([[response objectForKey:kMapPosition] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapPosition]);
        if (position != nil && [position isKindOfClass:[NSArray class]])
        {
            map.position = position;
        }
        
        NSString *entityId = ([[response objectForKey:kMapEntityId] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapEntityId]);
        if (entityId != nil && [entityId isKindOfClass:[NSString class]] > 0)
        {
            map.entityId = entityId;
        }
        
        NSString *dp = ([[response objectForKey:kMapDp] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapDp]);
        if (dp != nil && [dp isKindOfClass:[NSString class]] > 0)
        {
            map.dp = dp;
        }
        
        NSString *type = ([[response objectForKey:kMapType] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapType]);
        if (type != nil && [type isKindOfClass:[NSString class]] > 0)
        {
            map.type = type;
        }

        NSString *name = ([[response objectForKey:kMapnName] isKindOfClass:[NSNull class]]?@"":[response objectForKey:kMapnName]);
        if (name != nil && [name isKindOfClass:[NSString class]] > 0)
        {
            map.name = name;
        }
        
        return map;
        
    }
    
    return nil;
}


@end
