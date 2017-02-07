//
//  MeModel.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/12/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "MeModel.h"

NSString * const kMeEntity          = @"entity";
NSString * const kMeLocality        = @"locality";
NSString * const kMeReferredAt      = @"referredAt";
NSString * const kMeCategory        = @"category";
NSString * const kMePosition        = @"position";
NSString * const kMeEntityID        = @"entityId";
NSString * const kMeDP              = @"dp";
NSString * const kMeType            = @"type";
NSString * const kMeName            = @"name";

NSString * const kMeSystemID                  = @"systemId";
NSString * const kMeUpdatedAt                 = @"updatedAt";
NSString * const kMeFourSquareCategoryID      = @"foursquareCategoryId";
NSString * const kMeComment                   = @"comment";
NSString * const kMeLocation                  = @"location";
NSString * const kMeAskedAt                   = @"askedAt";
NSString * const kMeAddress                   = @"address";
NSString * const kMeCity                      = @"city";
NSString * const kMeUser                      = @"user";
NSString * const kMeReferrals                 = @"referrals";
NSString * const kMeResponseCount             = @"response";

NSString * const kMeCreatedAt                 = @"createdAt";
NSString * const kMeAskID                     = @"askId";

NSString * const kMeRefers                    = @"refers";
NSString * const kMePointsEarned              = @"pointsEarned";
NSString * const kMeConnections               = @"connections";
NSString * const kMeAskCount                  = @"askCount";
NSString * const kMePointsBurnt               = @"pointsBurnt";
NSString * const kMeFacebookID                = @"facebookId";
NSString * const kMeGuest                     = @"guest";
NSString * const kMeEmailID                   = @"emailId";
NSString * const kMeEntityReferCount          = @"entityReferCount";
NSString * const kMeActiveFrom                = @"activeFrom";
NSString * const kMeNumber                    = @"number";

NSString * const kMeToUsers                   = @"toUsers";
NSString * const kMeEntityName                = @"entityName";
NSString * const kMeChannel                   = @"channel";
NSString * const kMeFrom                      = @"from";
NSString * const kMeNote                      = @"note";
NSString * const kMeMediaID                   = @"mediaId";
NSString * const kMelatlong                   = @"latlong";


@implementation MeModel

+ (MeModel *)getAllSearchRefersByResponse:(NSDictionary *)response
{
    
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        MeModel *places = [[MeModel alloc]init];
        
        NSDictionary *entity = [response valueForKey:kMeEntity];
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            places.entity = entity;
        }
        
        NSString *locality = [response valueForKey:kMeLocality];
        
        if (locality != nil || [locality isKindOfClass:[NSString class]]) {
            places.locality = locality;
        }
        
        NSString *referredAt = [response valueForKey:kMeReferredAt];
        
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            places.referredAt = referredAt;
        }
        
        NSString *category = [response valueForKey:kMeCategory];
        
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            places.category = category;
        }
        
        
        NSArray *position = [response valueForKey:kMePosition];
        if (locality != nil || [locality isKindOfClass:[NSArray class]]) {
            places.position = position;
        }
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            places.entityId = entityId;
        }
        
        NSString *dp = [response valueForKey:kMeDP];
        if (dp != nil || [dp isKindOfClass:[NSString class]]) {
            places.dp = dp;
        }
        
        NSString *type = [response valueForKey:kMeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            places.type = type;
        }
        
        NSString *name = [response valueForKey:kMeName];
        if (name != nil || [name isKindOfClass:[NSString class]]) {
            places.name = name;
        }
        
        return places;
    }
    return nil;
}

+ (MeModel *)getPlaceByResponse:(NSDictionary *)response
{

    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        MeModel *places = [[MeModel alloc]init];
        
        NSDictionary *entity = [response valueForKey:kMeEntity];
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            places.entity = entity;
        }
        
        NSString *locality = [response valueForKey:kMeLocality];

        if (locality != nil || [locality isKindOfClass:[NSString class]]) {
            places.locality = locality;
        }
        
        NSString *referredAt = [response valueForKey:kMeReferredAt];
        
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            places.referredAt = referredAt;
        }
        
        NSString *category = [response valueForKey:kMeCategory];

        if (category != nil || [category isKindOfClass:[NSString class]]) {
            places.category = category;
        }
        
        
        NSArray *position = [response valueForKey:kMePosition];
        if (locality != nil || [locality isKindOfClass:[NSArray class]]) {
            places.position = position;
        }
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            places.entityId = entityId;
        }
        
        NSString *dp = [response valueForKey:kMeDP];
        if (dp != nil || [dp isKindOfClass:[NSString class]]) {
            places.dp = dp;
        }
        
        NSString *type = [response valueForKey:kMeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            places.type = type;
        }
        
        NSString *name = [response valueForKey:kMeName];
        if (name != nil || [name isKindOfClass:[NSString class]]) {
            places.name = name;
        }
        
        return places;
    }
    return nil;
}

+ (MeModel *)getProductByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        
        MeModel *product = [[MeModel alloc]init];
        NSDictionary *entity = [response valueForKey:kMeEntity];
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            product.entity = entity;
        }
        
        NSString *locality = [response valueForKey:kMeLocality];
        if (locality != nil || [locality isKindOfClass:[NSString class]]) {
            product.locality = locality;
        }
        
        NSString *referredAt = [response valueForKey:kMeReferredAt];
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            product.referredAt = referredAt;
        }
        
        NSString *category = [response valueForKey:kMeCategory];
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            product.category = category;
        }
        
        NSArray *position = [response valueForKey:kMePosition];
        if (locality != nil || [locality isKindOfClass:[NSArray class]]) {
            product.position = position;
        }
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            product.entityId = entityId;
        }

        NSString *dp = [response valueForKey:kMeDP];
        if (dp != nil || [dp isKindOfClass:[NSString class]]) {
            product.dp = dp;
        }
        
        NSString *type = [response valueForKey:kMeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            product.type = type;
        }
        
        NSString *name = [response valueForKey:kMeName];
        if (name != nil || [name isKindOfClass:[NSString class]]) {
            product.name = name;
        }
        
        return product;
    }

    return nil;
}


+ (MeModel *)getServiceByResponse:(NSDictionary *)response
{
    
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
       
        MeModel *service = [[MeModel alloc]init];
        NSDictionary *entity = [response valueForKey:kMeEntity];
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            service.entity = entity;
        }
        
        NSString *locality = [response valueForKey:kMeLocality];
        if (locality != nil || [locality isKindOfClass:[NSString class]]) {
            service.locality = locality;
        }
        
        NSString *referredAt = [response valueForKey:kMeReferredAt];
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            service.referredAt = referredAt;
        }
        
        NSString *category = [response valueForKey:kMeCategory];
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            service.category = category;
        }
        
        NSArray *position = [response valueForKey:kMePosition];
        if (locality != nil || [locality isKindOfClass:[NSArray class]]) {
            service.position = position;
        }
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            service.entityId = entityId;
        }
        
        NSString *dp = [response valueForKey:kMeDP];
        if (dp != nil || [dp isKindOfClass:[NSString class]]) {
            service.dp = dp;
        }
        
        NSString *type = [response valueForKey:kMeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            service.type = type;
        }
        
        NSString *name = [response valueForKey:kMeName];
        if (name != nil || [name isKindOfClass:[NSString class]]) {
            service.name = name;
        }
        
        return service;
    }
    
    return nil;
}

+ (MeModel *)getAskByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        
        MeModel *asks = [[MeModel alloc]init];
        NSDictionary *user = [response valueForKey:kMeUser];
        
        if (user != nil || [user isKindOfClass:[NSDictionary class]]) {
            asks.user = user;
        }
        
        NSString *systemId = [response valueForKey:kMeSystemID];
        if (systemId != nil || [systemId isKindOfClass:[NSString class]]) {
            asks.systemId = systemId;
        }
        
        NSString *updatedAt = [response valueForKey:kMeUpdatedAt];
        if (updatedAt != nil || [updatedAt isKindOfClass:[NSString class]]) {
            asks.updatedAt = updatedAt;
        }
        
        NSString *category = [response valueForKey:kMeCategory];
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            asks.category = category;
        }
        
        NSString *foursquareCategoryId = [response valueForKey:kMeFourSquareCategoryID];
        if (foursquareCategoryId != nil || [foursquareCategoryId isKindOfClass:[NSString class]]) {
            asks.foursquareCategoryId = foursquareCategoryId;
        }
        
        NSArray *location = [response valueForKey:kMeLocation];
        if (location != nil || [location isKindOfClass:[NSArray class]]) {
            asks.location = location;
        }
        
        
        NSString *comment = [response valueForKey:kMeComment];
        if (comment != nil && [comment isKindOfClass:[NSString class]] &&![comment isKindOfClass:[NSNull class]]) {
            asks.comment = comment;
        }
        
        NSString *askedAt = [NSString stringWithFormat:@"%@",[response valueForKey:kMeAskedAt]];
        if (askedAt != nil || [askedAt isKindOfClass:[NSString class]]) {
            asks.askedAt = askedAt;
        }
        
        NSString *type = [response valueForKey:kMeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            asks.type = type;
        }
        
        NSString *address = [response valueForKey:kMeAddress];
        if (address != nil || [address isKindOfClass:[NSString class]]) {
            asks.address = address;
        }
        
        NSString *city = [response valueForKey:kMeCity];
        if (city != nil || [city isKindOfClass:[NSString class]]) {
            asks.city = city;
        }
        
        NSString *referrals = [response valueForKey:kMeReferrals];
        if (referrals != nil || [referrals isKindOfClass:[NSString class]]) {
            asks.referrals = referrals;
        }
        
        NSString *createdAt = [response valueForKey:kMeCreatedAt];
        if (createdAt != nil || [createdAt isKindOfClass:[NSString class]]) {
            asks.createdAt = createdAt;
        }
        
        NSString *askId = [response valueForKey:kMeAskID];
        if (askId != nil || [askId isKindOfClass:[NSString class]]) {
            asks.askId = askId;
        }
        
        NSString *responseCnt = [response valueForKey:kMeResponseCount];
        if (responseCnt != nil || [responseCnt isKindOfClass:[NSString class]]) {
            asks.responseCount = responseCnt;
        }

        
        return asks;
    }
    
    return nil;
}


+ (MeModel *)getFriendsByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        
        MeModel *friends = [[MeModel alloc]init];
        NSString *refers = [NSString stringWithFormat:@"%@",[response valueForKey:kMeRefers]];
        
        if (refers != nil || [refers isKindOfClass:[NSString class]]) {
            friends.refers = refers;
        }
        
        NSString *locality = [response valueForKey:kMeLocality];
        if (locality != nil || [locality isKindOfClass:[NSString class]]) {
            friends.locality = locality;
        }
        
        
        NSString *pointsEarned = [NSString stringWithFormat:@"%@",[response valueForKey:kMePointsEarned]];
        if (pointsEarned != nil || [pointsEarned isKindOfClass:[NSString class]]) {
            friends.pointsEarned = pointsEarned;
        }
        
        NSString *connections = [NSString stringWithFormat:@"%@",[response valueForKey:kMeConnections]];
        if (connections != nil || [connections isKindOfClass:[NSString class]]) {
            friends.connections = connections;
        }
        
        NSString *systemId = [response valueForKey:kMeSystemID];
        if (systemId != nil || [systemId isKindOfClass:[NSString class]]) {
            friends.systemId = systemId;
        }
        
        NSString *askCount = [NSString stringWithFormat:@"%@",[response valueForKey:kMeAskCount]];
        if (askCount != nil || [askCount isKindOfClass:[NSString class]]) {
            friends.askCount = askCount;
        }
        
        NSString *pointsBurnt = [NSString stringWithFormat:@"%@",[response valueForKey:kMePointsBurnt]];
        if (pointsBurnt != nil || [pointsBurnt isKindOfClass:[NSString class]]) {
            friends.pointsBurnt = pointsBurnt;
        }
        
        NSString *facebookId = [response valueForKey:kMeFacebookID];
        if (facebookId != nil || [facebookId isKindOfClass:[NSString class]]) {
            friends.facebookId = facebookId;
        }
        
        NSString *city = [response valueForKey:kMeCity];
        if (city != nil || [city isKindOfClass:[NSString class]]) {
            friends.city = city;
        }
        
        NSString *emailId = [response valueForKey:kMeEmailID];
        if (emailId != nil || [emailId isKindOfClass:[NSString class]]) {
            friends.emailId = emailId;
        }
        
        NSString *name = [response valueForKey:kMeName];
        if (name != nil || [name isKindOfClass:[NSString class]]) {
            friends.name = name;
        }
        
        NSString *entityReferCount = [NSString stringWithFormat:@"%@",[response valueForKey:kMeEntityReferCount]];
        if (entityReferCount != nil || [entityReferCount isKindOfClass:[NSString class]]) {
            friends.entityReferCount = entityReferCount;
        }
        
        NSString *guest = [response valueForKey:kMeGuest];
        if (guest != nil || [guest isKindOfClass:[NSString class]]) {
            friends.guest = guest;
        }
        
        NSString *activeFrom = [NSString stringWithFormat:@"%@",[response valueForKey:kMeActiveFrom]];
        if (activeFrom != nil || [activeFrom isKindOfClass:[NSString class]]) {
            friends.activeFrom = activeFrom;
        }
        
        NSString *number = [response valueForKey:kMeNumber];
        if (number != nil || [guest isKindOfClass:[NSString class]]) {
            friends.number = number;
        }
        
        NSString *dp = [response valueForKey:kMeDP];
        if (dp != nil || [dp isKindOfClass:[NSString class]]) {
            friends.dp = dp;
        }
        
        NSString *latlng = [response valueForKey:kMelatlong];
        if (latlng != nil || [latlng isKindOfClass:[NSString class]]) {
            friends.latlng = latlng;
        }
        
        return friends;
    }
    
    return nil;
}

+ (MeModel *)getFeedsAllByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
       
        MeModel *feedsAll = [[MeModel alloc]init];
        NSString *systemId = [response valueForKey:kMeSystemID];
        
        if (systemId != nil || [systemId isKindOfClass:[NSString class]]) {
            feedsAll.systemId = systemId;
        }
        
        NSString *category = [response valueForKey:kMeCategory];
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            feedsAll.category = category;
        }
        
        NSDictionary *entity = [response valueForKey:kMeEntity];
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            feedsAll.entity = entity;
        }
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            feedsAll.entityId = entityId;
        }
        
        NSString *entityName = [response valueForKey:kMeEntityName];
        if (entityName != nil || [entityName isKindOfClass:[NSString class]]) {
            feedsAll.entityName = entityName;
        }
        
        NSArray *toUsers = [response valueForKey:kMeToUsers];
        if (toUsers != nil || [toUsers isKindOfClass:[NSArray class]]) {
            feedsAll.toUsers = toUsers;
        }
        
        NSString *channel = [response valueForKey:kMeChannel];
        if (channel != nil || [channel isKindOfClass:[NSString class]]) {
            feedsAll.channel = channel;
        }
        
        NSString *referredAt = [NSString stringWithFormat:@"%@",[response valueForKey:kMeReferredAt]];
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            feedsAll.referredAt = referredAt;
        }
        
        NSDictionary *from = [response valueForKey:kMeFrom];
        if (from != nil || [from isKindOfClass:[NSDictionary class]]) {
            feedsAll.from = from;
        }
        
        NSString *note = [response valueForKey:kMeNote];
        if (note != nil || [note isKindOfClass:[NSString class]]) {
            feedsAll.note = note;
        }
        
        NSString *city = [response valueForKey:kMeCity];
        if (city != nil || [city isKindOfClass:[NSString class]]) {
            feedsAll.city = city;
        }
        
        NSString *type = [response valueForKey:kMeType];
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            feedsAll.type = type;
        }
        
        NSString *mediaId = [response valueForKey:kMeMediaID];
        if (mediaId != nil || [mediaId isKindOfClass:[NSString class]]) {
            feedsAll.mediaId = mediaId;
        }
        
        NSArray *location = [response valueForKey:kMeLocation];
        if (location != nil || [location isKindOfClass:[NSArray class]]) {
            feedsAll.location = location;
        }
        
        NSString *askId = [response valueForKey:kMeAskID];
        if (askId != nil || [askId isKindOfClass:[NSString class]]) {
            feedsAll.askId = askId;
        }
        
        return feedsAll;
    }
    
    return nil;
}

+ (MeModel *)getFeedsSentByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        MeModel *feedsSent = [[MeModel alloc]init];
        
        
        NSString *systemId = [response valueForKey:kMeSystemID];
        
        
        if (systemId != nil || [systemId isKindOfClass:[NSString class]]) {
            
            
            feedsSent.systemId = systemId;
        }
        
        
        NSString *category = [response valueForKey:kMeCategory];
        
        
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            
            
            feedsSent.category = category;
        }
        
        
        NSDictionary *entity = [response valueForKey:kMeEntity];
        
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            
            
            feedsSent.entity = entity;
        }
        
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        
        
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            
            
            feedsSent.entityId = entityId;
        }
        
        
        NSString *entityName = [response valueForKey:kMeEntityName];
        
        
        if (entityName != nil || [entityName isKindOfClass:[NSString class]]) {
            
            
            feedsSent.entityName = entityName;
        }
        
        
        NSArray *toUsers = [response valueForKey:kMeToUsers];
        
        
        if (toUsers != nil || [toUsers isKindOfClass:[NSArray class]]) {
            
            
            feedsSent.toUsers = toUsers;
        }
        
        
        NSString *channel = [response valueForKey:kMeChannel];
        
        
        if (channel != nil || [channel isKindOfClass:[NSString class]]) {
            
            
            feedsSent.channel = channel;
        }
        
        
        NSString *referredAt = [NSString stringWithFormat:@"%@",[response valueForKey:kMeReferredAt]];
        
        
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            
            
            feedsSent.referredAt = referredAt;
        }
        
        
        NSDictionary *from = [response valueForKey:kMeFrom];
        
        
        if (from != nil || [from isKindOfClass:[NSDictionary class]]) {
            
            
            feedsSent.from = from;
        }
        
        
        NSString *note = [response valueForKey:kMeNote];
        
        
        if (note != nil || [note isKindOfClass:[NSString class]]) {
            
            
            feedsSent.note = note;
        }
        
        
        NSString *city = [response valueForKey:kMeCity];
        
        
        if (city != nil || [city isKindOfClass:[NSString class]]) {
            
            
            feedsSent.city = city;
        }
        
        
        NSString *type = [response valueForKey:kMeType];
        
        
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            
            
            feedsSent.type = type;
        }
        
        
        NSString *mediaId = [response valueForKey:kMeMediaID];
        
        
        if (mediaId != nil || [mediaId isKindOfClass:[NSString class]]) {
            
            
            feedsSent.mediaId = mediaId;
        }
        
        
        NSArray *location = [response valueForKey:kMeLocation];
        
        
        if (location != nil || [location isKindOfClass:[NSArray class]]) {
            
            
            feedsSent.location = location;
        }
        
        
        NSString *askId = [response valueForKey:kMeAskID];
        
        
        if (askId != nil || [askId isKindOfClass:[NSString class]]) {
            
            
            feedsSent.askId = askId;
        }
        
        
        return feedsSent;
        
        
    }
    
    
    return nil;
}

+ (MeModel *)getFeedsReceivedByResponse:(NSDictionary *)response
{
    if (response != nil || [response isKindOfClass:[NSDictionary class]]) {
        MeModel *feedsReceived = [[MeModel alloc]init];
        
        
        NSString *systemId = [response valueForKey:kMeSystemID];
        
        
        if (systemId != nil || [systemId isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.systemId = systemId;
        }
        
        
        NSString *category = [response valueForKey:kMeCategory];
        
        
        if (category != nil || [category isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.category = category;
        }
        
        
        NSDictionary *entity = [response valueForKey:kMeEntity];
        
        
        if (entity != nil || [entity isKindOfClass:[NSDictionary class]]) {
            
            
            feedsReceived.entity = entity;
        }
        
        
        NSString *entityId = [response valueForKey:kMeEntityID];
        
        
        if (entityId != nil || [entityId isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.entityId = entityId;
        }
        
        
        NSString *entityName = [response valueForKey:kMeEntityName];
        
        
        if (entityName != nil || [entityName isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.entityName = entityName;
        }
        
        
        NSArray *toUsers = [response valueForKey:kMeToUsers];
        
        
        if (toUsers != nil || [toUsers isKindOfClass:[NSArray class]]) {
            
            
            feedsReceived.toUsers = toUsers;
        }
        
        
        NSString *channel = [response valueForKey:kMeChannel];
        
        
        if (channel != nil || [channel isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.channel = channel;
        }
        
        
        NSString *referredAt = [NSString stringWithFormat:@"%@",[response valueForKey:kMeReferredAt]];
        
        
        if (referredAt != nil || [referredAt isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.referredAt = referredAt;
        }
        
        
        NSDictionary *from = [response valueForKey:kMeFrom];
        
        
        if (from != nil || [from isKindOfClass:[NSDictionary class]]) {
            
            
            feedsReceived.from = from;
        }
        
        
        NSString *note = [response valueForKey:kMeNote];
        
        
        if (note != nil || [note isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.note = note;
        }
        
        
        NSString *city = [response valueForKey:kMeCity];
        
        
        if (city != nil || [city isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.city = city;
        }
        
        
        NSString *type = [response valueForKey:kMeType];
        
        
        if (type != nil || [type isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.type = type;
        }
        
        
        NSString *mediaId = [response valueForKey:kMeMediaID];
        
        
        if (mediaId != nil || [mediaId isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.mediaId = mediaId;
        }
        
        
        NSArray *location = [response valueForKey:kMeLocation];
        
        
        if (location != nil || [location isKindOfClass:[NSArray class]]) {
            
            
            feedsReceived.location = location;
        }
        
        
        NSString *askId = [response valueForKey:kMeAskID];
        
        
        if (askId != nil || [askId isKindOfClass:[NSString class]]) {
            
            
            feedsReceived.askId = askId;
        }
        return feedsReceived;
    }
    
    
    return nil;
}

@end
