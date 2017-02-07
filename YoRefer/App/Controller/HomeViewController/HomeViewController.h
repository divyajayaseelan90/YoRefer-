//
//  HomeViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "HomeTableViewCell.h"

@interface HomeViewController : BaseViewController<homeTableViewCell>

- (void)getCarouselDetailWithIndex:(NSInteger)index;
- (void)getRefer;
- (void)getAsk;
- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushAskPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath;
- (void)askPost;

@end
