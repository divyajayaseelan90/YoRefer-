//
//  FeaturedTableViewCell.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Featured.h"


typedef enum {
    
    Popular,
    FeaturedNearBy
    
}FeaturedType;


@protocol Featured <NSObject>

- (void)getBeginIndexPath:(NSIndexPath *)indexPath;
- (void)getEndIndexPath:(NSIndexPath *)indexPath;
- (void)getBeginViewDetailWithIndexPath:(NSIndexPath *)indexPath;
- (void)getEndViewDetailWithIndexPath:(NSIndexPath *)indexPath;
- (void)getBeginReferNowWithIndexPath:(NSIndexPath *)indexPath;
- (void)getEndRefrNowWithIndexPath:(NSIndexPath *)indexPath;


@end

@interface FeaturedTableViewCell : UITableViewCell

- (instancetype)initWihtIndexPath:(NSIndexPath *)indexPath delegate:(id<Featured>)delegate response:(Featured *)response;

@property (nonatomic, weak) id <Featured>delegate;


@end

extern NSString * const kFeaturedPopularIdentifier;
extern NSString * const kFeaturedFeaturedNearByIdentifier;

