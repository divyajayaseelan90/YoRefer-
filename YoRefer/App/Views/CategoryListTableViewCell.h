//
//  CategoryListTableViewCell.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    PlacesList = 900,
    ProductList,
    ServicesList,
    WebList
    
}categoryList;

@protocol CategoryList <NSObject>

@optional

- (void)categoryListWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface CategoryListTableViewCell : UITableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<CategoryList>)delegate response:(NSDictionary *)response categorytype:(categoryList)categorytype;


@property (nonatomic, weak) id <CategoryList>delegate;

@property (nonatomic, readwrite) categoryList  categories;

@end

extern NSString * const kCategoryIdentifier;
