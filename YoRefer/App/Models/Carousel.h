//
//  Carousel.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Carousel : NSObject


@property (nonatomic, strong) NSString      *systemId;
@property (nonatomic, strong) NSString      *category;
@property (nonatomic, strong) NSString      *referCount;
@property (nonatomic, strong) NSArray       *position;
@property (nonatomic, strong) NSString      *entityId;
@property (nonatomic, strong) NSArray       *mediaLinks;
@property (nonatomic, strong) NSDictionary  *dp;
@property (nonatomic, strong) NSString      *type;
@property (nonatomic, strong) NSString      *mediaCount;
@property (nonatomic, strong) NSString      *city;
@property (nonatomic, strong) NSArray       *offers;
@property (nonatomic, strong) NSString      *website;
@property (nonatomic, strong) NSString      *country;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSString      *locality;


+ (Carousel *)getCarouselFromResponse:(NSDictionary *)response;

@end
