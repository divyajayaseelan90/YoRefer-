//
//  UIManager.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "UIManager.h"
#import "HomeViewController.h"
#import "YoReferAppDelegate.h"
#import "SWRevealViewController.h"
#import "FeaturedViewController.h"
#import "ReferViewController.h"
#import "MeViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "UserManager.h"
#import "WebViewController.h"



NSString * const kUserLoginNotification = @"UserLoginIn";
NSString * const kUserLogoutNotification = @"UserLogOut";

@interface UIManager()

@property (nonatomic, strong) SWRevealViewController *revealViewController;

@property (nonatomic, strong) YoReferAppDelegate *appDelegate;

@end

@implementation UIManager



+ (UIManager *)sharedManager
{
    
    static UIManager *_sharedManager = nil;
    static dispatch_once_t onceToke;
    dispatch_once(&onceToke, ^{
        
        _sharedManager = [[UIManager alloc]init];
        
    });
    
    return _sharedManager;
    
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        self.appDelegate = (YoReferAppDelegate *)[UIApplication sharedApplication].delegate;
        self.revealViewController = self.appDelegate.viewController;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogin:) name:kUserLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut:) name:kUserLogoutNotification object:nil];
        
//        if (![[UserManager shareUserManager] isVlaidUser])
//        {
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//                [self showLoginViewControllerWithAnimated:YES];
//                
//            });
//            
//        }
        
    }
    
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:(218.0/255.0) green:(218.0/255.0) blue:(205.0/255.0) alpha:1.0f]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    return self;
    
}


- (void)userLogin:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    if ([[dic objectForKey:@"sessiontoken"] length] > 0 || [[dic objectForKey:@"number"] length] > 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self hideLoginViewControllerWithAnimated:NO];
            
        });
        
        [self goToHomePageWithAnimated:YES];
    }else
    {
        
        [self showLoginViewControllerWithAnimated:YES];
        
    }
    
    
    
}

- (void)userLogOut:(NSNotification *)notification
{
    
    [self showLoginViewControllerWithAnimated:NO];
    
}

- (void)showLoginViewControllerWithAnimated:(BOOL)animated
{
    
    UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
    
    [tabBarControllers setSelectedIndex:0];
    
    LoginViewController *vctr = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vctr];
    [self.revealViewController.frontViewController presentViewController:navi animated:animated completion:nil];
    
}

- (void)hideLoginViewControllerWithAnimated:(BOOL)animated
{
    
    
    [self.revealViewController.frontViewController dismissViewControllerAnimated:animated completion:nil];
    
    
}



#pragma mark - MenuTab Icons

- (void)getActiveMenuHomePageWithTag:(NSInteger)tag view:(UIView *)view
{
    
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_home.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    if (tag == 0)
    {
        [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_home_active.png"]];
        [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        
    }
    
    
}


- (void)getActiveMenuFeaturedPageWithTag:(NSInteger)tag view:(UIView *)view
{
    
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_featured.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    
    if (tag == 1)
    {
        [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_featured_active.png"]];
        [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        
    }
    
    
}


- (void)getActiveMenuReferPageWithTag:(NSInteger)tag view:(UIView *)view
{
    
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_rmenuefermenu.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    
    if (tag == 2)
    {
        [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_menureferactive.png"]];
        [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        
    }
    
    
}

- (void)getActiveMenuMePageWithTag:(NSInteger)tag view:(UIView *)view
{
    
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_user.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    
    
    if (tag == 3)
    {
        [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_user_active.png"]];
        [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        
    }
    
    
}


- (void)getActiveSettingsMePageWithTag:(NSInteger)tag view:(UIView *)view
{
    
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_settings.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    
    
    if (tag == 4)
    {
        [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_settings_active.png"]];
        [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        
    }
    
    
}




#pragma mark - tab Icons


- (void)getHomePageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_home.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    NSArray *viewConrollers = viewController.navigationController.viewControllers;
    if([viewConrollers count] > 0)
    {
        UIViewController *vctr = [viewConrollers objectAtIndex:0];
        if ([vctr isKindOfClass:[HomeViewController class]])
        {
            
            [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_home_active.png"]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
            
        }
        
        
    }
    
}

- (void)getFeaturedPageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_featured.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    NSArray *viewConrollers = viewController.navigationController.viewControllers;
    if([viewConrollers count] > 0)
    {
        UIViewController *vctr = [viewConrollers objectAtIndex:0];
        if ([vctr isKindOfClass:[FeaturedViewController class]])
        {
            
            [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_featured_active.png"]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
            
        }
        
        
    }
    
}

- (void)getReferPageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_refer.png"]];
    // [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    NSArray *viewConrollers = viewController.navigationController.viewControllers;
    if([viewConrollers count] > 0)
    {
        UIViewController *vctr = [viewConrollers objectAtIndex:0];
        if ([vctr isKindOfClass:[ReferViewController class]])
        {
            
            [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_refer.png"]];
            // [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
            
        }
        
        
    }
    
}


- (void)getMePageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_user.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    NSArray *viewConrollers = viewController.navigationController.viewControllers;
    if([viewConrollers count] > 0)
    {
        UIViewController *vctr = [viewConrollers objectAtIndex:0];
        if ([vctr isKindOfClass:[MeViewController class]])
        {
            
            [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_user_active.png"]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
            
        }
        
        
    }
    
}

- (void)getSettingsPageTabViewFromViewContoller:(UIViewController *)viewController view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    
    [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_settings.png"]];
    [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
    
    NSArray *viewConrollers = viewController.navigationController.viewControllers;
    if([viewConrollers count] > 0)
    {
        UIViewController *vctr = [viewConrollers objectAtIndex:0];
        if ([vctr isKindOfClass:[SettingsViewController class]])
        {
            
            [(UIImageView *)[subViews objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_settings_active.png"]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
            
        }
        
        
    }
    
}

#pragma mark -  page Controller

- (void)goWebPageWithAnimated:(BOOL)animated title:(NSString *)title url:(NSURL *)url
{
    
    UINavigationController *frontNavigationController = (id)self.revealViewController.frontViewController;
    
    if ([frontNavigationController isKindOfClass:[UITabBarController class]])
    {
     
//        UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
        
        WebViewController *webViewController = [[WebViewController alloc]initWithUrl:url title:NSLocalizedString(title, @"")refer:NO categoryType:@""];
        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:webViewController];
        if ([self.revealViewController presentedViewController])
        {
            
            [self.revealViewController.presentedViewController presentViewController:navigationController animated:YES completion:Nil];
            
            
        }else
        {
            
            [self.revealViewController presentViewController:navigationController animated:YES completion:nil];
            
        }

        
        
    }else
    {
        
        BaseViewController *topViewController = (BaseViewController *)frontNavigationController.topViewController;
        if (![topViewController isKindOfClass:[WebViewController class]])
        {
            WebViewController *webViewController = [[WebViewController alloc]initWithUrl:url title:NSLocalizedString(title, @"")refer:NO categoryType:@""];
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:webViewController];
            if ([self.revealViewController presentedViewController])
            {
                
                [self.revealViewController.presentedViewController presentViewController:navigationController animated:YES completion:Nil];
                
                
            }else
            {
                
                [self.revealViewController presentViewController:navigationController animated:YES completion:nil];
                
            }
            
            
        }
        else
        {
            
            
        }

        
    }
    
    
    
    
}

- (void)gotoLoginViewControllerWithAnimated:(BOOL)animated
{
    
}

- (void)goToHomePageWithAnimated:(BOOL)animated
{
    
    [self.revealViewController setFrontViewController:[self.appDelegate customeTabBar] animated:animated];
    
}

- (void)goToFeaturedPageWithAnimated:(BOOL)animated
{
    
    UINavigationController *frontNavigationController = (id)self.revealViewController.frontViewController;
    BaseViewController *topViewController = (BaseViewController *)frontNavigationController.topViewController;
    if (![topViewController isKindOfClass:[FeaturedViewController class]])
    {
        FeaturedViewController *homeViewController = [[FeaturedViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
        [self.revealViewController setFrontViewController:navigationController animated:animated];
    }
    else
    {
        
        
    }
    
    
}


- (void)goToReferPageWithAnimated:(BOOL)animated
{
    UINavigationController *frontNavigationController = (id)self.revealViewController.frontViewController;
    BaseViewController *topViewController = (BaseViewController *)frontNavigationController.topViewController;
    if (![topViewController isKindOfClass:[ReferViewController class]])
    {
        ReferViewController *homeViewController = [[ReferViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
        [self.revealViewController setFrontViewController:navigationController animated:animated];
    }
    else
    {
        
        
    }
    
    
}

- (NSMutableDictionary *)getMeDetail
{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:6];
    [dictionary setValue:([[[UserManager shareUserManager] refers] isEqualToString:@"(null)"])?@"0":[[UserManager shareUserManager] refers] forKey:@"refercount"];
    [dictionary setValue:([[[UserManager shareUserManager] askCount] isEqualToString:@"(null)"])?@"0":[[UserManager shareUserManager] askCount] forKey:@"askcount"];
    [dictionary setValue:([[[UserManager shareUserManager] entityReferCount] isEqualToString:@"(null)"])?@"0":[[UserManager shareUserManager] entityReferCount] forKey:@"feedscount"];
    [dictionary setValue:([[[UserManager shareUserManager] connections] isEqualToString:@"(null)"])?@"0":[[UserManager shareUserManager] connections] forKey:@"friendscount"];
    [dictionary setValue:[[UserManager shareUserManager] pointsEarned] forKey:@"pointsearned"];
    [dictionary setValue:[[UserManager shareUserManager] pointsBurnt] forKey:@"pointsburnt"];
    [dictionary setValue:[[UserManager shareUserManager] number] forKey:@"number"];
    [dictionary setValue:[[UserManager shareUserManager] name] forKey:@"name"];
    
    return dictionary;
    
    
}

- (void)goToMePageWithAnimated:(BOOL)animated
{
    
    
    UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
    
    [tabBarControllers setSelectedIndex:3];
    
    [self.revealViewController setFrontViewController:tabBarControllers animated:animated];
    
    [self.appDelegate setSelctedTabWithIndex:3];
    
//    UINavigationController *frontNavigationController = (id)self.revealViewController.frontViewController;
//    BaseViewController *topViewController = (BaseViewController *)frontNavigationController.topViewController;
//    if (![topViewController isKindOfClass:[MeViewController class]])
//    {
//        MeViewController *homeViewController = [[MeViewController alloc] initWithUser:@"Self" userDetail:[self getMeDetail]];
//        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
//        [self.revealViewController setFrontViewController:navigationController animated:animated];
//    }
//    else
//    {
//        MeViewController *homeViewController = [[MeViewController alloc] initWithUser:@"Self" userDetail:[self getMeDetail]];
//        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
//        [self.revealViewController setFrontViewController:navigationController animated:animated];
//        
//    }
    
    
}

- (void)goToSettingdPageWithAnimated:(BOOL)animated
{
    UINavigationController *frontNavigationController = (id)self.revealViewController.frontViewController;
    BaseViewController *topViewController = (BaseViewController *)frontNavigationController.topViewController;
    if (![topViewController isKindOfClass:[SettingsViewController class]])
    {
        SettingsViewController *homeViewController = [[SettingsViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
        [self.revealViewController setFrontViewController:navigationController animated:animated];
    }
    else
    {
        
        
    }
    
    
}

#pragma mark - Refer
- (void)gotoReferPage
{
    
    [self.revealViewController revealToggle:self];
    
}

#pragma mark - Menu

- (void)gotoHomePageWitnMenuAnimated:(BOOL)animated
{
    
    UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
    
    [tabBarControllers setSelectedIndex:0];
    
    [self.revealViewController setFrontViewController:tabBarControllers animated:animated];
    
    [self.appDelegate setSelctedTabWithIndex:0];
    
    
}


- (void)goToFeaturedPageWithMenuAnimated:(BOOL)animated
{
    
    UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
    
    [tabBarControllers setSelectedIndex:1];
    
    [self.revealViewController setFrontViewController:tabBarControllers animated:animated];
    
    [self.appDelegate setSelctedTabWithIndex:1];
    
}

- (void)goToMePageWithMenuAnimated:(BOOL)animated
{

    UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
    
    [tabBarControllers setSelectedIndex:3];
    
    [self.revealViewController setFrontViewController:tabBarControllers animated:animated];
    
    [self.appDelegate setSelctedTabWithIndex:3];
    
}

- (void)goToSettingdPageWithMenuAnimated:(BOOL)animated
{
    
    UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
    
    [tabBarControllers setSelectedIndex:4];
    
    [self.revealViewController setFrontViewController:tabBarControllers animated:animated];
    
    [self.appDelegate setSelctedTabWithIndex:4];
    
}

@end
