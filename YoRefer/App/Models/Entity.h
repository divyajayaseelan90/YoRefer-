//
//  Entity.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 14/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entity : NSObject

@property (strong, nonatomic) NSDictionary          *user;
@property (strong, nonatomic) NSString              *systemId;
@property (strong, nonatomic) NSString              *updatedAt;
@property (strong, nonatomic) NSString              *foursquareCategoryId;
@property (strong, nonatomic) NSString              *comment;
@property (strong, nonatomic) NSString              *askId;
@property (strong, nonatomic) NSString              *createdAt;
@property (strong, nonatomic) NSArray               *location;
@property (strong, nonatomic) NSString              *askedAt;
@property (strong, nonatomic) NSString              *address;
@property (strong, nonatomic) NSString              *city;
@property (strong, nonatomic) NSString              *referrals;
@property (strong, nonatomic) NSString              *category;
@property (strong, nonatomic) NSDictionary          *entity;
@property (nonatomic, strong) NSString              *entityId;
@property (strong, nonatomic) NSString              *entityName;
@property (strong, nonatomic) NSArray               *toUsers;
@property (strong, nonatomic) NSString              *channel;
@property (strong, nonatomic) NSString              *referredAt;
@property (strong, nonatomic) NSDictionary          *from;
@property (strong, nonatomic) NSString              *note;
@property (strong, nonatomic) NSString              *type;
@property (strong, nonatomic) NSString              *mediaId;

+ (Entity *)getentityByResponse:(NSDictionary *)response;

@end
