//
//  HomeSearchTableViewCell.h
//  YoRefer
//
//  Created by Devendra Rathore on 1/14/17.
//  Copyright © 2017 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"

typedef enum {
    viewRefer,
    viewAsk,
    viewEntity
}HomeSearchType;


@protocol homeSearchTableViewCell <NSObject>

- (void)getCarouselDetailWithIndex:(NSInteger)index;
- (void)getRefer;
- (void)getAsk;
- (void)pushAskPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToViewControllerWithIndex:(NSInteger)index;
- (void)referNowTappedWithView:(UITapGestureRecognizer *)GestureRecognizer;
@optional
- (void)getReferalsWithIndexPath:(NSIndexPath *)indexPath;

@end


@interface HomeSearchTableViewCell : UITableViewCell

@property (nonatomic, weak) id <homeSearchTableViewCell>delegate;
- (instancetype)initWithDelegate:(id<homeSearchTableViewCell>)delegate response:(NSDictionary *)response homeType:(HomeSearchType)homeType indexPath:(NSIndexPath *)indexPath;

@end

extern NSString * const kHomeSearchReferReuseIdentifier;
extern NSString * const kHomeSearchAskReuseIdentifier;
extern NSString * const kHomeSearchEntityReuseIdentifier;

