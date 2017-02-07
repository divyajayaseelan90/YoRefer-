//
//  FeaturedViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "FeaturedTableViewCell.h"
#import "ReferNowViewController.h"


@interface FeaturedViewController : BaseViewController<Featured,Refer>

- (void)getBeginIndexPath:(NSIndexPath *)indexPath;

- (void)getEndIndexPath:(NSIndexPath *)indexPath;

- (void)getBeginViewDetailWithIndexPath:(NSIndexPath *)indexPath;
- (void)getEndViewDetailWithIndexPath:(NSIndexPath *)indexPath;
- (void)getBeginReferNowWithIndexPath:(NSIndexPath *)indexPath;
- (void)getEndRefrNowWithIndexPath:(NSIndexPath *)indexPath;

@end
