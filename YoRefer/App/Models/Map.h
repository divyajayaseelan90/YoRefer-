//
//  Map.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/23/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Map : NSObject

@property (nonatomic, strong) NSDictionary  *entity;
@property (nonatomic, strong) NSString      *locality;
@property (nonatomic, strong) NSString      *referredAt;
@property (nonatomic, strong) NSString      *category;
@property (nonatomic, strong) NSArray       *position;
@property (nonatomic, strong) NSString      *entityId;
@property (nonatomic, strong) NSString      *dp;
@property (nonatomic, strong) NSString      *type;
@property (nonatomic, strong) NSString      *name;


+ (Map *)MapWithResponse:(NSDictionary *)response;

@end
