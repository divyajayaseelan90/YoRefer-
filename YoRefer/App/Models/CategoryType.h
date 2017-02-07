//
//  CategoryType.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/19/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryType : NSObject

@property (nonatomic, strong) NSString *categoryType;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryID;

+ (CategoryType *)getProductFromResponse:(NSDictionary *)response;
+ (CategoryType *)getServiceFromResponse:(NSDictionary *)response;
+ (CategoryType *)getPlaceFromResponse:(NSDictionary *)response;

@end
