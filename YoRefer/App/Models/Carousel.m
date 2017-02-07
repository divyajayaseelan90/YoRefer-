//
//  Carousel.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Carousel.h"


NSString * const kCarouselSystemId           = @"systemId";
NSString * const kCarouselCategory           = @"category";
NSString * const kCarouselReferCount         = @"referCount";
NSString * const kCarouselPosition           = @"position";
NSString * const kCarouselEntityId           = @"entityId";
NSString * const kCarouselMediaLinks         = @"mediaLinks";
NSString * const kCarouselDp                 = @"dp";
NSString * const kCarouselType               = @"type";
NSString * const kCarouselMediaCount         = @"mediaCount";
NSString * const kCarouselCity               = @"city";
NSString * const kCarouselOffers             = @"offers";
NSString * const kCarouselWebsite            = @"website";
NSString * const kCarouselCountry            = @"country";
NSString * const kCarouselName               = @"name";
NSString * const kCarouselLocality           = @"locality";


@implementation Carousel


+ (Carousel *)getCarouselFromResponse:(NSDictionary *)response
{
    
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        
        Carousel * carousel = [[Carousel alloc]init];
        
        NSString *systemId = [response objectForKey:kCarouselSystemId];
        if (systemId != nil && [systemId isKindOfClass:[NSString class]] > 0)
        {
            carousel.systemId = systemId;
            
        }
        
        NSString *category = [response objectForKey:kCarouselCategory];
        if (category != nil && [category isKindOfClass:[NSString class]] > 0)
        {
            carousel.category = category;
            
        }
        
        NSString *referCount = [NSString stringWithFormat:@"%@",[response objectForKey:kCarouselReferCount]];
        if (category != nil && [category isKindOfClass:[NSString class]] > 0)
        {
            carousel.referCount = referCount;
            
        }
        
        NSArray *position = [response objectForKey:kCarouselPosition];
        if (position != nil && [position isKindOfClass:[NSArray class]])
        {
            carousel.position = position;
            
        }
        
        
        NSString *entityId = [response objectForKey:kCarouselEntityId];
        if (entityId != nil && [entityId isKindOfClass:[NSString class]] > 0)
        {
            carousel.entityId = entityId;
            
        }
        
        NSArray *mediaLinks = [response objectForKey:kCarouselMediaLinks];
        if (mediaLinks != nil && [mediaLinks isKindOfClass:[NSArray class]])
        {
            carousel.mediaLinks = mediaLinks;
            
        }
        
        NSDictionary *dp = [response objectForKey:kCarouselDp];
        if (dp != nil && [dp isKindOfClass:[NSDictionary class]])
        {
            carousel.dp = dp;
            
        }
        
        NSString *type = [response objectForKey:kCarouselType];
        if (type != nil && [type isKindOfClass:[NSString class]] > 0)
        {
            carousel.type = type;
            
        }
        
        NSString *mediaCount = [NSString stringWithFormat:@"%@",[response objectForKey:kCarouselMediaCount]];
        if (mediaCount != nil && [mediaCount isKindOfClass:[NSString class]] > 0)
        {
            carousel.mediaCount = mediaCount;
            
        }
        
        NSString *city = [response objectForKey:kCarouselCity];
        if (city != nil && [city isKindOfClass:[NSString class]] > 0)
        {
            carousel.city = city;
            
        }
        
        NSArray *offers = [response objectForKey:kCarouselOffers];
        if (offers != nil && [offers isKindOfClass:[NSArray class]])
        {
            carousel.offers = offers;
            
        }

        NSString *website = [response objectForKey:kCarouselWebsite];
        if (website != nil && [website isKindOfClass:[NSString class]] > 0)
        {
            carousel.website = website;
            
        }
        
        NSString *country = [response objectForKey:kCarouselCountry];
        if (country != nil && [country isKindOfClass:[NSString class]] > 0)
        {
            carousel.country = country;
            
        }
        
        NSString *name = [response objectForKey:kCarouselName];
        if (name != nil && [name isKindOfClass:[NSString class]] > 0)
        {
            carousel.name = name;
            
        }
        
        
        NSString *locality = [response objectForKey:kCarouselLocality];
        if (locality != nil && [locality isKindOfClass:[NSString class]] > 0)
        {
            carousel.locality = locality;
            
        }
     
        return carousel;
        
    }
    
    return nil;
    
}




@end
