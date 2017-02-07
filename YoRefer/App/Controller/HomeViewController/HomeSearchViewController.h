//
//  HomeSearchViewController.h
//  YoRefer
//
//  Created by Devendra Rathore on 1/14/17.
//  Copyright © 2017 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HomeSearchTableViewCell.h"

@interface HomeSearchViewController : BaseViewController<homeSearchTableViewCell>

@property (retain, nonatomic) NSString *searchBarString;


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
