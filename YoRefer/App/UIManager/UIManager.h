//
//  UIManager.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




@interface UIManager : NSObject

+ (UIManager *)sharedManager;


- (void)goToHomePageWithAnimated:(BOOL)animated;

- (void)goToFeaturedPageWithAnimated:(BOOL)animated;

- (void)goToReferPageWithAnimated:(BOOL)animated;

- (void)goToMePageWithAnimated:(BOOL)animated;

- (void)goToSettingdPageWithAnimated:(BOOL)animated;

- (void)getHomePageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view;

- (void)getFeaturedPageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view;

- (void)getReferPageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view;

- (void)getMePageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view;

- (void)getSettingsPageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view;

- (void)gotoHomePageWitnMenuAnimated:(BOOL)animated;

- (void)goToFeaturedPageWithMenuAnimated:(BOOL)animated;

- (void)goToMePageWithMenuAnimated:(BOOL)animated;

- (void)goToSettingdPageWithMenuAnimated:(BOOL)animated;

- (void)gotoReferPage;

- (void)goWebPageWithAnimated:(BOOL)animated title:(NSString *)title url:(NSURL *)url;

- (void)hideLoginViewControllerWithAnimated:(BOOL)animated;


- (void)getActiveMenuHomePageWithTag:(NSInteger)tag view:(UIView *)view;
- (void)getActiveMenuFeaturedPageWithTag:(NSInteger)tag view:(UIView *)view;
- (void)getActiveMenuReferPageWithTag:(NSInteger)tag view:(UIView *)view;
- (void)getActiveMenuMePageWithTag:(NSInteger)tag view:(UIView *)view;
- (void)getActiveSettingsMePageWithTag:(NSInteger)tag view:(UIView *)view;


@end
