//
//  CategoryListViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "CategoryListTableViewCell.h"
#import "CategoriesView.h"
#import "ReferNowViewController.h"

@interface CategoryListViewController : BaseViewController<CategoryList,CategoryView,Refer>

- (void)categoryListWithIndexPath:(NSIndexPath *)indexPath;

- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;

- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath;

@end
