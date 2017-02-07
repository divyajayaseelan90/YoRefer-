//
//  EntityViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 13/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "Featured.h"
#import "EntityTableViewCell.h"
#import "Users.h"

@interface EntityViewController : BaseViewController<Entity,Users, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (instancetype)initWithentityDetail:(NSMutableDictionary *)entityDetail;
- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath;

@end
