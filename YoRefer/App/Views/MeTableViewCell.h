//
//  MeTableViewCell.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/12/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    Refers = 10,
    Asks,
    Feeds,
    Friends,
    Points
    
}MeType;

typedef enum
{
    All = 300,
    Sent,
    Received
    
}FeedsType;

typedef enum
{
    Places = 1000,
    Product,
    Services,
    Web,
    SearchAll
    
}categories;

/*
typedef enum
{
    ViewRefers = 3000,
    ViewAsks,
    Entities
}homeSearchingType;
*/

@protocol Me <NSObject>

@optional

- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToQueryPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)selectIndexPath:(NSIndexPath *)indexPath;
- (void)refersWithIndexPath:(NSIndexPath *)indexPath;
- (void)feedsWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)getFriendProfileWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)getReferalsWithIndexPath:(NSIndexPath *)indexPath;
- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface MeTableViewCell : UITableViewCell
{
    UILabel *location;
    UIView *view_Main;
    
    NSIndexPath *indexPathShortenUrl;
    NSMutableArray *responseShortenUrl;
    
}
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<Me>)delegate response:(NSMutableArray *)response meType:(MeType )meType;

@property (nonatomic, weak) id <Me>delegate;

@property (nonatomic, readwrite) FeedsType     feeds;



@end

extern NSString * const kMeRefersIdentifier;
extern NSString * const kMeAsksIdentifier;
extern NSString * const kMeFeedsIdentifier;
extern NSString * const kMeFriendssIdentifier;
