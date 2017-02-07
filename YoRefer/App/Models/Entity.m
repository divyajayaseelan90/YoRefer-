//
//  Entity.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 14/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Entity.h"

NSString * const kEntitySystemID                  = @"systemId";
NSString * const kEntityUpdatedAt                 = @"updatedAt";
NSString * const kEntityFourSquareCategoryID      = @"foursquareCategoryId";
NSString * const kEntityComment                   = @"comment";
NSString * const kEntityLocation                  = @"location";
NSString * const kEntityAskedAt                   = @"askedAt";
NSString * const kEntityAddress                   = @"address";
NSString * const kEntityCity                      = @"city";
NSString * const kEntityUser                      = @"user";
NSString * const kEntityReferrals                 = @"referredAt";
NSString * const kEntityCreatedAt                 = @"createdAt";
NSString * const kEntityAskID                     = @"askId";
NSString * const kEntityCategory                  = @"category";
NSString * const kEntityEntity                    = @"entity";
NSString * const kEntityEntityID                  = @"entityId";
NSString * const kEntityEntityName                = @"entityName";
NSString * const kEntityToUsers                   = @"toUsers";
NSString * const kEntityChannel                   = @"channel";
NSString * const kEntityFrom                      = @"from";
NSString * const kEntityType                      = @"type";
NSString * const kEntityMediaID                   = @"mediaId";
NSString * const kEntityNote                          = @"note";


@implementation Entity

+ (Entity *)getentityByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        Entity *entity = [[Entity alloc]init];
        
        NSString *systemId = [response valueForKey:kEntitySystemID];
        
        if (systemId != nil || [systemId isKindOfClass:[NSString class]]) {
            
            entity.systemId = systemId;
        }
        
        NSString *category = [response valueForKey:kEntityCategory];
        
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            
            entity.category = category;
        }
        
        NSDictionary *entity1 = [response valueForKey:kEntityEntity];
        
        if (entity1 != nil || [entity1 isKindOfClass:[NSDictionary class]]) {
            
            entity.entity = entity1;
        }
        
        NSString *entityId = [response valueForKey:kEntityEntityID];
        
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            
            entity.entityId = entityId;
        }
        
        NSString *entityName = [response valueForKey:kEntityEntityName];
        
        if (entityName != nil || [entityName isKindOfClass:[NSString class]]) {
            
            entity.entityName = entityName;
        }
        
        NSArray *toUsers = [response valueForKey:kEntityToUsers];
        
        if (toUsers != nil || [toUsers isKindOfClass:[NSArray class]]) {
            
            entity.toUsers = toUsers;
        }
        
        NSString *channel = [response valueForKey:kEntityChannel];
        
        if (channel != nil || [channel isKindOfClass:[NSString class]]) {
            
            entity.channel = channel;
        }
        
        NSString *referredAt = [NSString stringWithFormat:@"%@",[response valueForKey:kEntityReferrals]];
        
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            
            entity.referredAt = referredAt;
        }
        
        NSDictionary *from = [response valueForKey:kEntityFrom];
        
        if (from != nil || [from isKindOfClass:[NSDictionary class]]) {
            
            entity.from = from;
        }
        
        NSString *note = [response valueForKey:kEntityNote];
        
        if (note != nil || [note isKindOfClass:[NSString class]]) {
            
            entity.note = note;
        }
        
        NSString *city = [response valueForKey:kEntityCity];
        
        if (city != nil || [city isKindOfClass:[NSString class]]) {
            
            entity.city = city;
        }
        
        NSString *type = [response valueForKey:kEntityType];
        
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            
            entity.type = type;
        }
        
        NSString *mediaId = [response valueForKey:kEntityMediaID];
        
        if (mediaId != nil || [mediaId isKindOfClass:[NSString class]]) {
            
            entity.mediaId = mediaId;
        }
        
        NSArray *location = [response valueForKey:kEntityLocation];
        
        if (location != nil || [location isKindOfClass:[NSArray class]]) {
            
            entity.location = location;
        }
        
        NSString *askId = [response valueForKey:kEntityAskID];
        
        if (askId != nil || [askId isKindOfClass:[NSString class]]) {
            
            entity.askId = askId;
        }
        
        return entity;
        
    }
    
    
    return nil;
}


@end
