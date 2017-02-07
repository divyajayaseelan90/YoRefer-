//
//  EntityTableViewCell.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 13/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Featured.h"

typedef enum
{
    EntityFeeds,
    EntityPhotos
}EntityType;

@protocol Entity <NSObject>

- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)getReferalsWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface EntityTableViewCell : UITableViewCell

@property (nonatomic, weak) id<Entity>delegate;
- (instancetype)initEntityType:(EntityType)entityType response:(NSDictionary *)response indexPath:(NSIndexPath *)indexPath delegate:(id<Entity>)delegate type:(NSString *)type;

@property (nonatomic, strong) UIImageView *beginImg;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

extern NSString * const kEntityFeedsReuseIdentifier;
extern NSString * const kEntityPhotosReuseIdentifier;
