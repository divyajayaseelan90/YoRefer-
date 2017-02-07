//
//  CategoryType.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/19/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "CategoryType.h"

NSString * const kCategoryType = @"type";
NSString * const kCategoryName = @"name";
NSString * const kCategoryID   = @"categoryId";


@implementation CategoryType

#pragma mark - Product
+ (CategoryType *)getProductFromResponse:(NSDictionary *)response
{
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        CategoryType *category = [[CategoryType alloc]init];
        
        NSString *categoryType = [response objectForKey:kCategoryType];
        if (categoryType != nil && [categoryType isKindOfClass:[NSString class]] > 0)
        {
            category.categoryType = categoryType;
        }
        
        NSString *categoryName= [response objectForKey:kCategoryName];
        if (categoryName != nil && [categoryName isKindOfClass:[NSString class]] > 0)
        {
            category.categoryName = categoryName;
        }
        
        return category;
    }
    
    return nil;
}


#pragma mark - Service
+ (CategoryType *)getServiceFromResponse:(NSDictionary *)response
{
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        CategoryType *category = [[CategoryType alloc]init];
        
        NSString *categoryType = [response objectForKey:kCategoryType];
        if (categoryType != nil && [categoryType isKindOfClass:[NSString class]] > 0)
        {
            category.categoryType = categoryType;
        }
        
        NSString *categoryName= [response objectForKey:kCategoryName];
        if (categoryName != nil && [categoryName isKindOfClass:[NSString class]] > 0)
        {
            category.categoryName = categoryName;
        }
        
        return category;
    }
    
    return nil;
}

#pragma mark - Place
+ (CategoryType *)getPlaceFromResponse:(NSDictionary *)response
{
    if (response != nil && [response isKindOfClass:[NSDictionary class]])
    {
        CategoryType *category = [[CategoryType alloc]init];
        
        NSString *categoryType = [response objectForKey:kCategoryType];
        if (categoryType != nil && [categoryType isKindOfClass:[NSString class]] > 0)
        {
            category.categoryType = categoryType;
        }
        
        NSString *categoryName= [response objectForKey:kCategoryName];
        if (categoryName != nil && [categoryName isKindOfClass:[NSString class]] > 0)
        {
            category.categoryName = categoryName;
        }
        
        NSString *categoryId= [response objectForKey:kCategoryID];
        if (categoryId != nil && [categoryId isKindOfClass:[NSString class]] > 0)
        {
            category.categoryID = categoryId;
        }
        
        return category;
    }
    
    return nil;
}


@end
