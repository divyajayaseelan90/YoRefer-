//
//  Featured.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Featured : NSObject

@property (nonatomic, strong) NSString *discount;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSDictionary *entity;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *entityId;
@property (nonatomic, strong) NSString *systemId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *used;
@property (nonatomic, strong) NSArray *location;
@property (nonatomic, strong) NSString *validTo;
@property (nonatomic, strong) NSString *validFrom;
@property (nonatomic, strong) NSString *createdAt;

+ (Featured *)getPopularWithResponse:(NSDictionary *)response;

+ (Featured *)getNearByWithResponse:(NSDictionary *)response;

@end
