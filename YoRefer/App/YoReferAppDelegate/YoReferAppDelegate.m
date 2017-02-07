//
//  AppDelegate.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "YoReferAppDelegate.h"
#import "HomeViewController.h"
#import "FeaturedViewController.h"
#import "MeViewController.h"
#import "SettingsViewController.h"
#import "MenuViewController.h"
#import "Configuration.h"
#import "LoginViewController.h"
#import "UserManager.h"
#import "UIManager.h"
#import "LocationManager.h"
#import "ReferViewController.h"
#import "DCPathButton.h"
#import "DCPathItemButton.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>
#import <TwitterKit/TwitterKit.h>
#import "DocumentDirectory.h"
#import "YoReferSocialChannels.h"

typedef enum{
    TabHome,
    TabFeatured,
    TabRefer,
    TabMe,
    TabSettings
}toolBarItems;

CGFloat const tabImageViewWidth            =  21.0;
CGFloat const tabImageViewheight           =  20.0;
CGFloat const tabHomeFixedBarButton        = -14.0;
CGFloat const tabOtherFixedBarButton       = -11.0;

@interface YoReferAppDelegate ()<SWRevealViewControllerDelegate, UITabBarControllerDelegate,DCPathButtonDelegate,UIAlertViewDelegate>
{
    DCPathButton *dcPathButton;
}
@property (nonatomic, strong)  UIView *home,*featured,*refer,*me,*settings;
@property (strong, nonatomic)  UITabBarController *tabBarController;
@end
@implementation YoReferAppDelegate

#pragma mark -
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[LocationManager shareLocationManager];
    [UserManager shareUserManager];
    [Configuration shareConfiguration];
    [[Helper shareHelper] isReferChannel:NO];
    if (![[UserManager shareUserManager] getSplash])
    {
        [[UserManager shareUserManager] setSplashWithBool:YES];
        
    }else
    {
        [[UserManager shareUserManager] setSplashWithBool:NO];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    [Fabric with:@[[Crashlytics class], [Digits class], [Twitter class]]];
    UINavigationController *frontNavigationController = nil;
    if ([[UserManager shareUserManager] isVlaidUser])
    {
        [self customeTabBar];
        
    }else
    {
        LoginViewController *vctr = [[LoginViewController alloc]init];
        frontNavigationController = [[UINavigationController alloc]initWithRootViewController:vctr];
    }
    MenuViewController *vctr = [[MenuViewController alloc]init];
    UINavigationController *menuNavigationController = [[UINavigationController alloc]initWithRootViewController:vctr];
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menuNavigationController frontViewController:([[UserManager shareUserManager] isVlaidUser])?self.tabBarController:frontNavigationController];
    revealController.delegate = self;
    self.viewController = revealController;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    //UserManger
    [UIManager sharedManager];
    //Register UserNotification
    [self registerUserNotification:application];
    //Current Location
    [self currentLocation];
    [[LocationManager shareLocationManager] getCurrentLocation];
    //Status Bar
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[CoreData shareData] deleteCategoryWithLoginId:[[UserManager shareUserManager] number]];
    [[CoreData shareData] deleteCarouselWithLoginId:[[UserManager shareUserManager] number]];
    // Override point for customization after application launch.
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[YoReferSocialChannels shareYoReferSocial] setDefaultSharing];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.window endEditing:YES];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    BOOL isLocation =  ([[UserManager shareUserManager] getLocationService]);
    if (!isLocation)
    {
        [[UserManager shareUserManager] disableLocation];
        
    }else if (isLocation)
    {
        [[UserManager shareUserManager] enableLocation];
        
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"locationupdating" object:nil userInfo:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BOOL isLocation = ([[UserManager shareUserManager] getLocationService]);
    if (!isLocation)
    {
        [[UserManager shareUserManager] disableLocation];
        
    }else if (isLocation)
    {
        [[UserManager shareUserManager] enableLocation];
        
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"locationupdating" object:nil userInfo:nil];
    [[DocumentDirectory shareDirectory] deleteDirectoryWithSpecficTimeUserId:[[UserManager shareUserManager] number]];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
#pragma mark- didRegisterUserNotificationSettings

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

#pragma amrk- didRegisterForRemoteNotificationsWithDeviceToken
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[UserManager shareUserManager] setDeviceToken:devToken];
}

#pragma mark- didFailToRegisterForRemoteNotificationsWithError
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSDictionary *alert  =[userInfo objectForKey:@"aps"];
    NSString *message ;
    if ([alert isKindOfClass:[NSDictionary class]])
    {
        message = [alert valueForKey:@"alert"];
    }
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[Configuration shareConfiguration] appName] message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (state == UIApplicationStateInactive)
    {
        
         [[NSNotificationCenter defaultCenter] postNotificationName:@"pullToReferesh" object:nil userInfo:nil];
        
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[CoreData shareData] deleteReferWithLoginId:[[UserManager shareUserManager] number]];
    [[CoreData shareData]deleteAskWithLoginId:[[UserManager shareUserManager] number]];
    //Deleting Medata
    [[CoreData shareData] deleteQueriesWithLoginId:[[UserManager shareUserManager] number] ];
    [[CoreData shareData] deleteFriendsWithLoginId:[[UserManager shareUserManager] number]];
    NSArray *feedData = @[@"300",@"301",@"302"];
    for (int i = 0; i< feedData.count; i++)
    {
        [[CoreData shareData] deleteFeedsWithLoginId:[[UserManager shareUserManager] number]feedsType:feedData[i]];
    }
    [[CoreData shareData] deletePlaceReferWithLoginId:[[UserManager shareUserManager] number]];
    [[CoreData shareData] deleteProductReferWithLoginId:[[UserManager shareUserManager] number]];
    [[CoreData shareData] deleteServiceReferWithLoginId:[[UserManager shareUserManager] number]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pullToReferesh" object:nil userInfo:nil];
}

- (void)registerUserNotification:(UIApplication *)application
{
    if (!TARGET_IPHONE_SIMULATOR) {
        UIApplication *application = [UIApplication sharedApplication];
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
        }else {
            [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        }
    }else{
        NSLog(@"You can not subscribe a device token in simulator.");
    }
}

#pragma mark -
#pragma mark - Current Location
- (void)currentLocation
{
    BOOL isLocation = ([[UserManager shareUserManager] getLocationService]);
    if (!isLocation)
    {
        [[UserManager shareUserManager] disableLocation];
        
    }else if ([[UserManager shareUserManager] getLocationService])
    {
        [[UserManager shareUserManager] enableLocation];
    }
    if (![[UserManager shareUserManager] getLocationService] && [[UserManager shareUserManager] isVlaidUser])
     {
     }
}
#pragma mark -
#pragma mark - Core data
- (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"YoRefer.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
#pragma mark- TabBar Intialisation and decleration
- (CGRect)bounds
{
    return [[UIScreen mainScreen] bounds];
}
- (UITabBarController *)customeTabBar
{
    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.delegate = self;
    [self ConfigureDCPathButtonWithView:self.tabBarController.view];
    HomeViewController *home = [[HomeViewController alloc]init];
    // home.title = @"Home";
    UINavigationController *homeNavi = [[UINavigationController alloc]initWithRootViewController:home];
    FeaturedViewController *featured = [[FeaturedViewController alloc]init];
    //featured.title = @"Featured";
    UINavigationController *featuredNavi = [[UINavigationController alloc]initWithRootViewController:featured];
    ReferViewController *refer = [[ReferViewController alloc]init];
    //refer.title = @"Refer";
    UINavigationController *referNavi = [[UINavigationController alloc]initWithRootViewController:refer];
    MeViewController *me = [[MeViewController alloc]initWithUser:@"Self" userDetail:[self getMeDetail]];
    //me.title = @"Me";
    UINavigationController *meNavi = [[UINavigationController alloc]initWithRootViewController:me];
    SettingsViewController *settings = [[SettingsViewController alloc]init];
    //settings.title = @"Settings";
    UINavigationController *settingsNavi = [[UINavigationController alloc]initWithRootViewController:settings];
    [self.tabBarController setViewControllers:[[NSArray alloc]initWithObjects:homeNavi,featuredNavi,referNavi,meNavi, settingsNavi,nil] animated:YES];
    [self customeTabBarWithTabBarController:self.tabBarController];
    return self.tabBarController;
}

- (void)customeTabBarWithTabBarController:(UITabBarController *)tabBarController
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height =  50.0;
    UIImageView *imgTab = [[UIImageView alloc]initWithFrame:CGRectMake(xPos,yPos,width,height)];
    tabBarController.tabBar.tag=10;
    [tabBarController.tabBar addSubview:imgTab];
    xPos = 0.0;
    yPos = 0.0;
    width = round(frame.size.width / 5);
    //home
    self.home = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) tag:TabHome];
    self.home.tag = TabHome;
    [[YoReferUserDefaults  shareUserDefaluts] setValue:@"0" forKey:@"ActiveTab"];
    //image
    CGFloat imageWidth = tabImageViewWidth;
    CGFloat imageHeight = tabImageViewWidth;
    CGFloat imageXPos = roundf((self.home.frame.size.width - imageWidth)/2) + 0.5;
    CGFloat imageYPos = roundf((self.home.frame.size.height - imageHeight)/2) - 8.0;
    UIImageView *homeImgView = [self createImageWithFrame:CGRectMake(imageXPos, imageYPos, imageWidth, imageHeight) tag:TabHome];
    [self.home addSubview:homeImgView];
    //label
    CGFloat labelWidth = self.home.frame.size.width;
    CGFloat labelHeight = 20.0;
    CGFloat labelXPos = 0.0;
    CGFloat labelYpos = homeImgView.frame.size.height + 8.0;
    UILabel *homeLbl = [self createLabelWithFrame:CGRectMake(labelXPos, labelYpos, labelWidth, labelHeight) tag:TabHome];
    [homeLbl setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
    [self.home addSubview:homeLbl];
    [imgTab addSubview:self.home];
    //featured
    xPos = self.home.frame.size.width - 2.0;
    self.featured = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) tag:TabFeatured];
    self.featured.tag = TabFeatured;
    //image
    imageWidth = 24.0;
    UIImageView *featuredImgView = [self createImageWithFrame:CGRectMake(imageXPos, imageYPos, imageWidth, imageHeight) tag:TabFeatured];
    [self.featured addSubview:featuredImgView];
    //label
    UILabel *featuredLbl = [self createLabelWithFrame:CGRectMake(labelXPos, labelYpos, labelWidth, labelHeight) tag:TabFeatured];
    [self.featured addSubview:featuredLbl];
    [imgTab addSubview:self.featured];
    //refer
    xPos = self.featured.frame.origin.x + self.featured.frame.size.width;
    self.refer = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) tag:TabRefer];
    self.refer.tag = TabRefer;
    //image
    CGFloat referWidth = ([self bounds].size.width > 320 ? self.refer.frame.size.width - 8.0 : self.refer.frame.size.width + 5.0);
    CGFloat referHeight = self.refer.frame.size.height + 18.0;
    CGFloat referXPos = ([self bounds].size.width > 320 ? 7.0 : 2.0);
    CGFloat referYPos = -14.0;
    UIImageView *referImgView = [self createImageWithFrame:CGRectMake(referXPos, referYPos, referWidth, referHeight) tag:TabRefer];
    [self.refer addSubview:referImgView];
    [imgTab addSubview:self.refer];
    [tabBarController.tabBar addSubview:self.refer];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referGuestureTapped:)];
    [self.refer addGestureRecognizer:gestureRecognizer];
    //me
    xPos = self.refer.frame.origin.x + self.refer.frame.size.width - 2.0;
    self.me = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) tag:TabMe];
    self.me.tag = TabMe;
    //image
    imageWidth = 22.0;
    UIImageView *meImgView = [self createImageWithFrame:CGRectMake(imageXPos, imageYPos, imageWidth, imageHeight) tag:TabMe];
    [self.me addSubview:meImgView];
    //label
    UILabel *meLbl = [self createLabelWithFrame:CGRectMake(labelXPos + 1.5, labelYpos, labelWidth, labelHeight) tag:TabMe];
    [self.me addSubview:meLbl];
    [imgTab addSubview:self.me];
    //settings
    xPos = self.me.frame.origin.x + self.me.frame.size.width - 3.0;
    self.settings = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) tag:TabSettings];
    self.settings.tag = TabSettings;
    //image
    imageWidth = 22.0;
    UIImageView *settingsImgView = [self createImageWithFrame:CGRectMake(imageXPos, imageYPos, imageWidth, imageHeight) tag:TabSettings];
    [self.settings addSubview:settingsImgView];
    //label
    UILabel *settingsLbl = [self createLabelWithFrame:CGRectMake(labelXPos, labelYpos, labelWidth, labelHeight) tag:TabSettings];
    [self.settings addSubview:settingsLbl];
    [imgTab addSubview:self.settings];
}

- (void)referGuestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"dcbutton" object:nil userInfo:nil];
}
- (void)setSelctedTabWithIndex:(NSInteger)index
{
    if (index == 0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"scrollToTop" object:nil];
        [(UIImageView *)[[self.home subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_home_active.png"]];
        [(UILabel *)[[self.home subviews] objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        [(UIImageView *)[[self.featured subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_featured.png"]];
        [(UILabel *)[[self.featured subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.me subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_user.png"]];
        [(UILabel *)[[self.me subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.settings subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_settings.png"]];
        [(UILabel *)[[self.settings subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        
    }else if (index == 1)
    {
        [(UIImageView *)[[self.home subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_home.png"]];
        [(UILabel *)[[self.home subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.featured subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_featured_active.png"]];
        [(UILabel *)[[self.featured subviews] objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        [(UIImageView *)[[self.me subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_user.png"]];
        [(UILabel *)[[self.me subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.settings subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_settings.png"]];
        [(UILabel *)[[self.settings subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        
    }else if (index == 3)
    {
        [(UIImageView *)[[self.home subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_home.png"]];
        [(UILabel *)[[self.home subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.featured subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_featured.png"]];
        [(UILabel *)[[self.featured subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.me subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_user_active.png"]];
        [(UILabel *)[[self.me subviews] objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
        [(UIImageView *)[[self.settings subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_settings.png"]];
        [(UILabel *)[[self.settings subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
    }else if (index == 4)
    {
        [(UIImageView *)[[self.home subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_home.png"]];
        [(UILabel *)[[self.home subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.featured subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_featured.png"]];
        [(UILabel *)[[self.featured subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.me subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_user.png"]];
        [(UILabel *)[[self.me subviews] objectAtIndex:1]setTextColor:[UIColor blackColor]];
        [(UIImageView *)[[self.settings subviews] objectAtIndex:0]setImage:[UIImage imageNamed:@"icon_settings_active.png"]];
        [(UILabel *)[[self.settings subviews] objectAtIndex:1]setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(59.0/255.0) blue:(0.0/255.0) alpha:1.0]];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarControllers didSelectViewController:(UIViewController *)viewController
{
    [[YoReferUserDefaults  shareUserDefaluts] setValue:[NSString stringWithFormat:@"%lu",(unsigned long)tabBarControllers.selectedIndex] forKey:@"ActiveTab"];
    [self setSelctedTabWithIndex:tabBarControllers.selectedIndex];
}

- (UIImageView *)createImageWithFrame:(CGRect)frame tag:(toolBarItems)tag
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    [imageView setImage:[self toolBarImageWithTag:tag]];
    return imageView;
}


- (UILabel *)createLabelWithFrame:(CGRect)frame tag:(toolBarItems)tag
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setText:[self toolBartextWithTag:tag]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:13.0]];
    return label;
}
- (NSString *)toolBartextWithTag:(toolBarItems)tag
{
    NSString *string = nil;
    switch (tag) {
        case TabHome:
        string = @"Home";
        break;
        case TabFeatured:
        string = @"Featured";
        break;
        case TabRefer:
        string = @"Refer";
        break;
        case TabMe:
        string = @"Me";
        break;
        case TabSettings:
        string = @"Settings";
        break;
        default:
        break;
    }
    return string;
}


- (UIImage *)toolBarImageWithTag:(toolBarItems)tag
{
    UIImage *image = nil;
    switch (tag) {
        case TabHome:
        image = [UIImage imageNamed:@"icon_home_active.png"];
        break;
        case TabFeatured:
        image = [UIImage imageNamed:@"icon_featured.png"];
        break;
        case TabRefer:
        image = [UIImage imageNamed:@""];
        break;
        case TabMe:
        image = [UIImage imageNamed:@"icon_user.png"];
        break;
        case TabSettings:
        image = [UIImage imageNamed:@"icon_settings.png"];
        break;
        default:
        break;
    }
    return image;
}
- (UIView *)createViewWithFrame:(CGRect)frame tag:(toolBarItems)tag
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.tag = tag;
    view.userInteractionEnabled = YES;
    return view;
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
    
    [dictionary setValue:[[UserManager shareUserManager] emailId] forKey:@"email"];
    
    return dictionary;
}

- (void)ConfigureDCPathButtonWithView:(UIView *)view
{
    // Configure center button
    //
    dcPathButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"icon_refer.png"]
                                             hilightedImage:[UIImage imageNamed:@"icon_refer.png"]];
    dcPathButton.delegate = self;
    
    // Configure item buttons
    //
    DCPathItemButton *itemButton_1 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_category.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_cercle_refer_category"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_cercle_refer_category"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_cercle_refer_category"]];
    DCPathItemButton *itemButton_2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_contact.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_cercle_refer_contact.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_cercle_refer_contact.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_cercle_refer_contact.png"]];
    
    DCPathItemButton *itemButton_3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_camera.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_cercle_refer_camera.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_cercle_refer_camera.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_cercle_refer_camera.png"]];
    
    DCPathItemButton *itemButton_4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_location.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_cercle_refer_location"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_cercle_refer_location"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_cercle_refer_location"]];
    
    DCPathItemButton *itemButton_5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_web.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_cercle_refer_web.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_cercle_refer_web.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_cercle_refer_web.png"]];
    
    DCPathItemButton *itemButton_6 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_new.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_cercle_refer_new.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_cercle_refer_new.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_cercle_refer_new.png"]];
    
    // Add the item button into the center button
    //
    [dcPathButton addPathItems:@[itemButton_1, itemButton_2, itemButton_3, itemButton_4, itemButton_5,itemButton_6]];
    
    // Change the bloom radius
    //
    dcPathButton.bloomRadius = 120.0f;
    // Change the DCButton's center
    //
   // dcPathButton.dcButtonCenter = CGPointMake((([[UIScreen mainScreen]bounds].size.width-95)/2)+48, [[UIScreen mainScreen]bounds].size.height-38);
    
    //    NSLog(@"x=%f y=%f",self.view.bounds.size.width / 2,self.view.bounds.size.height - 25.5f);
    //    NSLog(@"x=%f y=%f",self.view.frame.size.width,[COMMON getScreenSize].height-90.5);
    //
    
    // Setting the DCButton appearance
    //
//    dcPathButton.soundsEnable = YES;
//    dcPathButton.centerBtnRotationEnable = YES;
//    
//    
//    NSLog(@"dcPath=%f %f %f  ",dcPathButton.frame.origin.y,dcPathButton.frame.size.width,dcPathButton.frame.size.height);
    [view addSubview:dcPathButton];
}


#pragma mark - DCPathButton Delegate
- (void)willPresentDCPathButtonItems:(DCPathButton *)dcPathButton
{
    
}

- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex
{
}

- (void)didPresentDCPathButtonItems:(DCPathButton *)dcPathButton
{

}


- (void)itemButtonTappedAtIndex:(NSUInteger)index
{
    //   NSLog(@"index=%lu",(unsigned long)index);
    NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%lu",(unsigned long)index],@"index", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dcbutton" object:nil userInfo:dictionary];
}

- (void)DCButtonWithStatus:(BOOL)status
{
    [dcPathButton setHidden:status];
}

@end
