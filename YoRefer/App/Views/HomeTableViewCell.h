//
//  HomeTableViewCell.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"

typedef enum {
    referAsk,
    carousel,
    segment,
    refer,
    ask,
    search
}HomeType;


@protocol homeTableViewCell <NSObject>

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

@interface HomeTableViewCell : UITableViewCell

@property (nonatomic, weak) id <homeTableViewCell>delegate;
- (instancetype)initWithDelegate:(id<homeTableViewCell>)delegate response:(NSDictionary *)response homeType:(HomeType)homeType indexPath:(NSIndexPath *)indexPath;
@end

extern NSString * const kHomeCarouselReuseIdentifier;
extern NSString * const kHomeReferAskReuseIdentifier;
extern NSString * const kHomeSegmentReuseIdentifier;
extern NSString * const kHomeReferReuseIdentifier;
extern NSString * const kHomeAskReuseIdentifier;
extern NSString * const kHomeSearchReuseIdentifier;


