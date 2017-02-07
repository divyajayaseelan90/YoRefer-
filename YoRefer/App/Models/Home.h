//
//  Home.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/16/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Home : NSObject

@property (nonatomic, strong) NSString      *  systemId ;
@property (nonatomic, strong) NSString      *  category;
@property (nonatomic, strong) NSDictionary  *  entity;
@property (nonatomic, strong) NSArray       *  toUser;
@property (nonatomic, strong) NSString      *  entityId;
@property (nonatomic, strong) NSString      *  entityName;
@property (nonatomic, strong) NSString      *  channel;
@property (nonatomic, strong) NSDictionary  *  from;
@property (nonatomic, strong) NSString      *  note;
@property (nonatomic, strong) NSString      *  type;
@property (nonatomic, strong) NSString      *  mediaId;
@property (nonatomic, strong) NSArray       *  location;
@property (nonatomic, strong) NSString      *  referredAt;
@property (nonatomic, strong) NSString      *  city;
@property (nonatomic, strong) NSString      *  updatedAt;
@property (nonatomic, strong) NSString      *  askId;
@property (nonatomic, strong) NSString      *  fourSquareCategoryId;
@property (nonatomic, strong) NSString      *  comment;
@property (nonatomic, strong) NSString      *  askedAt;
@property (nonatomic, strong) NSString      *  address ;
@property (nonatomic, strong) NSDictionary  *  user;
@property (nonatomic, strong) NSArray       *  referrals;
@property (nonatomic, strong) NSString      *  createdAt;

@property (strong, nonatomic) NSString      *responseCount;


@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSArray *position;
@property (strong, nonatomic) NSString *dp;
@property (strong, nonatomic) NSString *name;


+ (Home *)getReferFromResponse:(NSDictionary *)response;

+ (Home *)getAskFromResponse:(NSDictionary *)response;

+ (Home *)getEntityFromResponse:(NSDictionary *)response;

+ (Home *)getEntitySearchFromResponse:(NSDictionary *)response;


@end
