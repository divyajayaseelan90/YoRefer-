//
//  MeViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "MeTableViewCell.h"
#import "ReferNowViewController.h"
#import "Users.h"

@interface MeViewController : BaseViewController<Me,Refer,Users,UIActionSheetDelegate>

- (void)refersWithIndexPath:(NSIndexPath *)indexPath;

- (void)feedsWithIndexPath:(NSIndexPath *)indexPath;

- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;

- (void)pushToQueryPageWithIndexPath:(NSIndexPath *)indexPath;

- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath;

- (instancetype)initWithUser:(NSString *)userType userDetail:(NSDictionary *)userDetail;

- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath;

- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath;
- (void)getReferalsWithIndexPath:(NSIndexPath *)indexPath;
- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath;
- (void)getCategoryListWithIndexPath:(NSIndexPath *)indexPath;

- (void)getReferUserWithDetail:(NSDictionary *)user;

- (void)getProfilePicture:(NSMutableDictionary *)profilePicture;

- (void)getFriendProfileWithIndexPath:(NSIndexPath *)indexPath;

@end
