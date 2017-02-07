
//
//  BaseViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "UIManager.h"
#import "SWRevealViewController.h"
#import "YoReferUserDefaults.h"
#import "MapViewController.h"
#import "CategoryListViewController.h"
#import "ContactViewController.h"
#import "MapViewController.h"
#import "WebViewController.h"
#import "ReferNowViewController.h"
#import "CoreData.h"
#import "YoReferMedia.h"
#import "QueryNowViewController.h"
#import "ReferNowViewController.h"
#import "HomeViewController.h"
#import "MeViewController.h"
#import "EntityViewController.h"
#import "Configuration.h"
#import "FeaturedViewController.h"
#import "SettingsViewController.h"
#import "RedeemPointsViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "ImageViewController.h"

typedef enum{
    
    
    BaseHome,
    BaseFeatured,
    Refer,
    Me,
    Settings
    
    
}toolBarItems;


typedef enum
{
    ReferCategory,
    ReferContact,
    ReferPhoto,
    ReferLocation,
    ReferWeb,
    ReferNew,
    ReferAsk,
    ReferNewAsk = 20
}MainReferType;


CGFloat const homeFixedBarButton        = -14.0;
CGFloat const otherFixedBarButton       = -11.0;
CGFloat const imageViewWidth            = 21.0;
CGFloat const imageViewheight           = 20.0;

@interface BaseViewController ()<UITableViewDataSource,UITableViewDelegate,Query,LocationManger>

@property (nonatomic, readwrite) toolBarItems toolBarItems;

@property (strong, nonatomic) SWRevealViewController *revealController;

@property (nonatomic, strong) MBProgressHUD *progressHUD;



@end

@implementation BaseViewController

#pragma mark  - instancetype
- (instancetype)init
{
    self = [super initWithNibName:@"BaseViewController" bundle:nil];
    if (self)
    {
        
        
    }
    
    
    return self;
    
    
    
    
}


#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (YoReferAppDelegate *)[UIApplication sharedApplication].delegate;
    self.revealController = [self revealViewController];
    [self.revealController panGestureRecognizer];
    //[self ConfigureDCPathButtonWithView:self.view];
    [self barItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushViewController:) name:@"menu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushDCbutton:) name:@"dcbutton" object:nil];
    if ([self isKindOfClass:[EntityViewController class]])
    {
        self.navigationItem.title  = [[Configuration shareConfiguration] appName];
        self.tableView.separatorColor = [UIColor clearColor];
    }else if ([self isKindOfClass:[MapViewController class]])
    {
        self.navigationItem.title  = @"Map";
    }
    else if ([self isKindOfClass:[ImageViewController class]])
    {
        self.navigationItem.title  = @"Image";
    }else if ([self isKindOfClass:[QueryNowViewController class]])
    {
        self.navigationItem.title  = @"Ask Now";
        self.tableView.backgroundColor = [UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f];
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.tableFooterView = [UIView new];
    }else if ([self isKindOfClass:[ReferNowViewController class]])
    {
        self.navigationItem.title = @"Refer Now";
        self.tableView.backgroundColor = [UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f];
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.tableFooterView = [UIView new];
    }else if ([self isKindOfClass:[HomeViewController class]])
    {
        self.navigationItem.title  = @"Home";
        self.tableView.separatorColor = [UIColor clearColor];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    UITabBarController *tabBarController = (id)self.revealViewController.frontViewController;
    
    if ([self isKindOfClass:[ReferNowViewController class]] || [self isKindOfClass:[WebViewController class]] || [[UserManager shareUserManager] getSplash] ||[self isKindOfClass:[RedeemPointsViewController class]] ||[self isKindOfClass:[QueryNowViewController class]] ||[self isKindOfClass:[ImageViewController class]])
    {
        [tabBarController.tabBar setHidden:YES];
        [self.appDelegate DCButtonWithStatus:YES];
        
    }
    else
    {
        
        [tabBarController.tabBar setHidden:NO];
        [self.appDelegate DCButtonWithStatus:NO];
        
    }
    
}



-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)reloadTableView
{
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView reloadData];
    
    
}

#pragma mark - tableView datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *identifier = @"Identifier";
    
    
    UITableViewCell *cell;
    if (cell == nil)
    {
        
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        
    }
    
    
    return cell;
    
    
}



#pragma BarItems

- (void)barItems
{
    
    
    self.navigationController.navigationBar.hidden = NO;
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    UIBarButtonItem * leftBarBtn ;
    
    
    NSArray *arary = [self.navigationController viewControllers];
    
    
    if ([arary count] > 1)
    {
        
        
        leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBackBarButtonTapped:)];
        
        
        
        
    }else
    {
        
        if ([self isKindOfClass:[WebViewController class]])
        {
            leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBackBarButtonTapped:)];
        }else
        {
            
            
            
            leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTapped:)];
            
        }
        
        
        
    }
    
    
    
    
    
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    UIButton *rightButton = [[UIButton alloc]init];
    rightButton.frame = CGRectMake(0.0, 0.0, 20.0, 28.0);
    [rightButton setImage:[UIImage imageNamed:@"icon_home_location.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    
    if ([self isKindOfClass:[ReferNowViewController class]])
    {
        
        
//        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addReferItem:)];
//        
//        
//        self.navigationItem.rightBarButtonItem = addButton;
        
        
        
        
    }else
    {
        if([self isKindOfClass:[CategoryListViewController class]]|| [self isKindOfClass:[WebViewController class]] || [self isKindOfClass:[MapViewController class]]  || [self isKindOfClass:[ContactViewController class]] || [self isKindOfClass:[EntityViewController class]] || [self isKindOfClass:[ImageViewController class]]){
            
            
        }else
        {
            
            
            self.navigationItem.rightBarButtonItem = rightBarBtn;
            
            
        }
        
        
        
        
    }
    
    
}

- (void)rightBarBackButton
{
    
    
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBackBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
}

- (CGRect)bounds
{
    
    
    return [[UIScreen mainScreen] bounds];
    
    
}

#pragma mark - Button delegate

- (IBAction)leftBarButtonTapped:(id)sender
{
    
    if ([self isKindOfClass:[HomeViewController class]])
    {
        [self.tableView endEditing:YES];
    }
    [self.revealController revealToggle:nil];
    
    
}

- (void)hideViewWithView:(UIView *)view
{
    
    
    
    
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         view.frame = CGRectMake(0.0, [self bounds].size.height, [self bounds].size.width, [self bounds].size.height - 40.0);
                         if ([self isKindOfClass:[CategoryListViewController class]])
                                self.navigationItem.title = @"Category List";
                     }
                     completion:^(BOOL finished){
                         
                         
                         [view removeFromSuperview];
                         if ([self isKindOfClass:[HomeViewController class]] || [self isKindOfClass:[MeViewController class]])
                         {
                             [self checkHomeSubViews];
                             
                         }
                     }];
    
    
}

- (void)checkHomeSubViews
{
    
    
    NSArray *subViews = [self.view subviews];
    
    
    BOOL isSubView = NO;
    
    
    for (UIView *view  in subViews) {
        
        
        if ([view isKindOfClass:[CategoriesView class]])
        {
            
            
            //[self hideViewWithView:view];
            isSubView = YES;
            
            
        }
        
        
    }
    
    
    if (!isSubView)
    {
        UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTapped:)];
        self.navigationItem.leftBarButtonItem = leftBarBtn;
        
        
    }
    
    
}

- (IBAction)leftBackBarButtonTapped:(id)sender
{
    self.navigationItem.rightBarButtonItem = nil;
    if ([self isKindOfClass:[MeViewController class]])
    {
        
        
        BOOL isSubView = NO;
        
        
        NSArray *subViews = [self.view subviews];
        
        
        
        
        for (UIView *view  in subViews) {
            
            
            if ([view isKindOfClass:[CategoriesView class]])
            {
                
                
                [self hideViewWithView:view];
                isSubView = YES;
                
                
            }
            
            
        }
        
        
        if (!isSubView)
        {
            
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }
        
        
        
        
    }else if ([self isKindOfClass:[HomeViewController class]])
    {
        
        
        BOOL isSubView = NO;
        
        
        NSArray *subViews = [self.view subviews];
        
        
        
        
        for (UIView *view  in subViews) {
            
            
            if ([view isKindOfClass:[CategoriesView class]])
            {
                
                
                [self hideViewWithView:view];
                isSubView = YES;
                
                
            }
            
            
        }
        
        
        if (!isSubView)
        {
            UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTapped:)];
            self.navigationItem.leftBarButtonItem = leftBarBtn;
            
            
        }
        
        
        
        
    }else if ([self isKindOfClass:[HomeViewController class]])
    {
        
        
        BOOL isSubView = NO;
        
        
        NSArray *subViews = [self.view subviews];
        
        
        
        
        for (UIView *view  in subViews) {
            
            
            if ([view isKindOfClass:[CategoriesView class]])
            {
                
                
                [self hideViewWithView:view];
                isSubView = YES;
                
                
            }
            
            
        }
        
        
        if (!isSubView)
        {
            UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTapped:)];
            self.navigationItem.leftBarButtonItem = leftBarBtn;
            
            
        }
        
        
        
        
    }else if ([self isKindOfClass:[ReferNowViewController class]])
    {
        BOOL isSubView = NO;
        
        
        NSArray *subViews = [self.view subviews];
        
        
        
        
        for (UIView *view  in subViews) {
            
            
            if ([view isKindOfClass:[ShareView class]])
            {
                
                
                [self hideViewWithView:view];
                isSubView = YES;
                [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                
                
            }else if ([view isKindOfClass:[CategoriesView class]])
            {
                
                
                [self hideViewWithView:view];
                [self home:nil];
                isSubView = YES;
                [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                
            }else if (view.tag == 60000)
            {
                [UIView animateWithDuration:0.7
                                 animations:^{
                                     view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
                                 } completion:^(BOOL finished) {
                                     [view removeFromSuperview];
                                 }];
                
                isSubView = YES;
                [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                
            }
           
            
            
        }
        
        
        if (!isSubView)
        {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
        
    }else if ([self isKindOfClass:[CategoryListViewController class]])
    {
        BOOL isSubView = NO;
        
        
        NSArray *subViews = [self.view subviews];
        
        
        for (UIView *view  in subViews) {
            
            
            if ([view isKindOfClass:[CategoriesView class]])
            {
                [self hideViewWithView:view];
                isSubView = YES;
                
                
            }
            
            
            
        }
        
        
        if (!isSubView)
            [self.navigationController popViewControllerAnimated:YES];
        
        
        
        
    }else if ([self isKindOfClass:[WebViewController class]])
    {
        BOOL isSubView = NO;
        
        
        NSArray *subViews = [self.view subviews];
        
        
        for (UIView *view  in subViews) {
            
            
            if ([view isKindOfClass:[WebViewController class]])
            {
                [self hideViewWithView:view];
                isSubView = YES;
                
                
            }
            
            
        }
        if (!isSubView){
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
        
        
        
    }
    else
    {
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
        
    }
    
    
    
    
    
    
}
- (IBAction)rightBarButtonTapped:(id)sender
{
    
    if ([self isKindOfClass:[HomeViewController class]])
    {
        [self.tableView endEditing:YES];
    }

    
    MapViewController *vctr = [[MapViewController alloc]initWithResponse:nil type:@"Offers" isCurrentOffers:YES];
    [self.navigationController pushViewController:vctr animated:YES];
    
    
    
    
}

- (IBAction)addReferItem:(id)sender
{
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addreferitem" object:self userInfo:nil];
    
    
}

#pragma mark - DCPathButton Delegate

- (void)willPresentDCPathButtonItems:(DCPathButton *)dcPathButton {
    
    
}

- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
}

- (void)didPresentDCPathButtonItems:(DCPathButton *)dcPathButton {
    
    
    
    
}


-(void)itemButtonTappedAtIndex:(NSUInteger)index
{
    //   NSLog(@"index=%lu",(unsigned long)index);
    
    
    [self pushToViewControllerWithReferType:(MainReferType)index];
    
    
}

- (void)pushViewController:(NSNotification *)notification
{
    MainReferType referType ;
    
    
    if ([[[notification valueForKey:@"userInfo"] objectForKey:@"submenu"] isEqualToString:@"category"])
    {
        referType = ReferCategory;
    }else  if ([[[notification valueForKey:@"userInfo"] objectForKey:@"submenu"] isEqualToString:@"contact"])
    {
        referType = ReferContact;
    }else  if ([[[notification valueForKey:@"userInfo"] objectForKey:@"submenu"] isEqualToString:@"photo"])
    {
        referType = ReferPhoto;
    }else  if ([[[notification valueForKey:@"userInfo"] objectForKey:@"submenu"] isEqualToString:@"location"])
    {
        referType = ReferLocation;
    }else  if ([[[notification valueForKey:@"userInfo"] objectForKey:@"submenu"] isEqualToString:@"web"])
    {
        referType = ReferWeb;
    }else  if ([[[notification valueForKey:@"userInfo"] objectForKey:@"submenu"] isEqualToString:@"new"])
    {
        referType = ReferNew;
    }
    
    
    [self pushToViewControllerWithReferType:referType];
    
    
}

- (UIViewController *)getViewControllerWithSelctedIndex
{
    
    UITabBarController *viewControllers = (id)self.revealViewController.frontViewController;
    
    UIViewController *viewController;
    
    switch ([viewControllers selectedIndex]) {
        case 0:
        viewController = [self isKindOfClass:[HomeViewController class]] ? self : nil;
        break;
        case 1:
        viewController = [self isKindOfClass:[FeaturedViewController class]] ? self : nil;
        break;
        case 3:
        viewController = [self isKindOfClass:[MeViewController class]] ? self : nil;
        break;
        case 4:
        viewController = [self isKindOfClass:[SettingsViewController class]] ? self : nil;
        break;
        default:
        break;
    }
    
    return viewController;
    
    
}

- (void)pushToViewControllerWithReferType:(MainReferType)refertype
{
    
    
    UIViewController *viewController  = [self getViewControllerWithSelctedIndex];
    
    if (refertype == ReferCategory)
    {
        
        
        CategoryListViewController *vctr = [[CategoryListViewController alloc]init];
        [viewController.navigationController pushViewController:vctr animated:YES];
        
        
    }else if (refertype == ReferContact)
    {
        
        
        ContactViewController *vctr = [[ContactViewController alloc]init];
        [viewController.navigationController  pushViewController:vctr animated:YES];
        
        
        
        
    }else if (refertype == ReferPhoto)
    {
        
        
        [self pushToMediaViewController];
        
        
        
        
    }else if (refertype == ReferLocation)
    {
        
        
        
        MapViewController *vctr = [[MapViewController alloc]initWithResponse:nil type:@"Offers" isCurrentOffers:YES];
        [viewController.navigationController pushViewController:vctr animated:YES];
        
        
        //map
        
        
    }else if (refertype == ReferWeb)
    {
        
        
        WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:@"http://www.google.com"] title:@"Web" refer:YES categoryType:@""];
        [viewController.navigationController pushViewController:vctr animated:YES];
        
        
    }else if (refertype == ReferNew )
    {
        
        
        ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self setBaseReferDefaultValue] delegate:nil];
        [viewController.navigationController pushViewController:vctr animated:YES];
    }
    else if (refertype == ReferAsk  || refertype == ReferNewAsk)
    {
        
        
        QueryNowViewController *vctr = [[QueryNowViewController alloc]initWithQueryDetail:[self setQueryDefaultValue] delegate:self];
        [viewController.navigationController pushViewController:vctr animated:YES];
        
        
    }
    
    
}


- (void)pushToMediaViewController
{
    
    UITabBarController *viewControllers = (id)self.revealViewController.frontViewController;
    
    if ([self isKindOfClass:[HomeViewController class]] && [viewControllers selectedIndex] == 0)
    {
        [[YoReferMedia shareMedia] setMediaWithDelegate:self title:@"Select Picture"];
        
    }else if ([self isKindOfClass:[FeaturedViewController class]] && [viewControllers selectedIndex] == 1)
    {
        [[YoReferMedia shareMedia] setMediaWithDelegate:self title:@"Select Picture"];
        
    }else if ([self isKindOfClass:[MeViewController class]] && [viewControllers selectedIndex] == 3)
    {
        [[YoReferMedia shareMedia] setMediaWithDelegate:self title:@"Select Picture"];
        
    }else if ([self isKindOfClass:[SettingsViewController class]] && [viewControllers selectedIndex] == 4)
    {
        [[YoReferMedia shareMedia] setMediaWithDelegate:self title:@"Select Picture"];
        
    }
    
}

- (NSMutableDictionary *)setQueryDefaultValue
{
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSMutableArray *array;
    if ([categoryArray  count] > 0)
    {
        array = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [categoryArray valueForKey:kPlace])
        {
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
        }
    }
    CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
    [dictionary setValue:category.categoryName forKey:kCategory];
    [dictionary setValue:category.categoryType forKey:kCategorytype];
    [dictionary setValue:category.categoryID forKey:kCategoryid];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kAddress];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:kCity];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"searchtext"];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];

    
    return dictionary;
    
}


- (NSMutableDictionary *)setBaseReferDefaultValue
{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    
    
    NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSMutableArray *array;
    
    
    if ([categoryArray  count] > 0)
    {
        
        
        array = [[NSMutableArray alloc]init];
        
        
        for (NSDictionary *dictionary in [categoryArray valueForKey:@"place"]) {
            
            
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
            
            
        }
        
        
    }
    
    
    CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
    
    
    [dictionary setValue:category.categoryName forKey:@"category"];
    [dictionary setValue:category.categoryID forKey:@"categoryid"];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"city"];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"searchtext"];
    [dictionary setValue:@"" forKey:@"location"];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:@"latitude"];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"newrefer"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isentiyd"];
    [dictionary setValue:@"place" forKey:@"categorytype"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refer"];
    
    
    return dictionary;
    
    
}


- (NSMutableDictionary *)getReferNowWithReferImage:(UIImage *)referNowImage
{
    
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:referNowImage forKey:@"referimage"];
    return dictionary;
    
    
}

- (void)getProfilePicture:(NSDictionary *)profilePicture
{
    NSMutableDictionary *refer = [self setBaseReferDefaultValue];
    [refer setValue:[profilePicture objectForKey:@"image"] forKey:@"referimage"];
    [refer setValue:[NSNumber numberWithBool:YES] forKey:@"refertypemedia"];
    [refer setValue:[NSNumber numberWithBool:YES] forKey:@"newrefer"];
    [refer setValue:[NSNumber numberWithBool:NO] forKey:@"isentiyd"];
    
    
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:refer delegate:nil];
    [self.navigationController pushViewController:vctr animated:YES];
    
    
    
    
}

+(bool)isNetworkAvailable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

#pragma mark - GestureRecognizer

- (void)home:(UITapGestureRecognizer *)gestureRecognizer
{
    
    
    
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSString stringWithFormat:@"%d",(toolBarItems)gestureRecognizer.view.tag] forKey:@"ActiveTab"];
    
    
    [[UIManager sharedManager] goToHomePageWithAnimated:YES];
    
    
    
    
}

- (void)featured:(UITapGestureRecognizer *)gestureRecognizer
{
    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSString stringWithFormat:@"%d",(toolBarItems)gestureRecognizer.view.tag] forKey:@"ActiveTab"];
    
    [[UIManager sharedManager] goToFeaturedPageWithAnimated:YES];
    
    
    
    
}

- (void)refer:(UITapGestureRecognizer *)gestureRecognizer
{
    
    
//    [dcPathButton centerButtonTapped];
    
    //    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSString stringWithFormat:@"%d",(toolBarItems)gestureRecognizer.view.tag] forKey:@"ActiveTab"];
    //
    //    [[UIManager sharedManager] goToReferPageWithAnimated:YES];
    
    
    
    
}

- (void)me:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSString stringWithFormat:@"%d",(toolBarItems)gestureRecognizer.view.tag] forKey:@"ActiveTab"];
    
    
    [[UIManager sharedManager] goToMePageWithAnimated:YES];
    
    
}

- (void)settings:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSString stringWithFormat:@"%ld",gestureRecognizer.view.tag] forKey:@"ActiveTab"];
    
    
    [[UIManager sharedManager] goToSettingdPageWithAnimated:YES];
    
    
    
    
}


#pragma mark - HUD


- (void)showHUDWithMessage:(NSString *)message
{
    if (self.progressHUD != nil)
    {
        [self hideHUD];
        self.progressHUD = nil;
    }
    
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
    
    
    self.progressHUD.labelText = message;
    self.progressHUD.labelFont = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    
    
    [self.progressHUD show:YES];
}

- (void)showSuccessHUDWithMessage:(NSString *)message
{
    if (self.progressHUD != nil)
    {
        [self hideHUD];
        self.progressHUD = nil;
    }
    
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
    
    
    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
    
    // Set custom view mode
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    
    
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = message;
    self.progressHUD.labelFont = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    
    
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:2.0];
}

- (void)showErrorHUDWithMessage:(NSString *)message
{
    if (self.progressHUD != nil)
    {
        [self hideHUD];
        self.progressHUD = nil;
    }
    
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    // Configure for text only and offset down
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = message;
    self.progressHUD.labelFont = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    self.progressHUD.margin = 10.f;
    self.progressHUD.removeFromSuperViewOnHide = YES;
    
    
    [self.progressHUD hide:YES afterDelay:2.0];
}

- (void)hideHUD
{
    [self.progressHUD hide:YES];
}

- (void)ConfigureDCPathButtonWithView:(UIView *)view
{
    // Configure center button
    dcPathButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@""]
                                             hilightedImage:[UIImage imageNamed:@""]];
    dcPathButton.delegate = self;
    DCPathItemButton *itemButton_1 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_category.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_refer_category.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_refer_category.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_refer_category.png"]];
    
    
    DCPathItemButton *itemButton_2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_contact.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_refer_contact.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_refer_contact.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_refer_contact.png"]];
    
    
    DCPathItemButton *itemButton_3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_camera.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_refer_camera.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_refer_camera.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_refer_camera.png"]];
    
    
    DCPathItemButton *itemButton_4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_location.png"]
                                                           highlightedImage:[UIImage imageNamed:@"iocn_refer_location.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_refer_location.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_refer_location.png"]];
    
    
    DCPathItemButton *itemButton_5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_web.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_refer_web.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_refer_web.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_refer_web.png"]];
    
    
    DCPathItemButton *itemButton_6 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"icon_refer_new.png"]
                                                           highlightedImage:[UIImage imageNamed:@"icon_refer_new.png"]
                                                            backgroundImage:[UIImage imageNamed:@"icon_refer_new.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"icon_refer_new.png"]];
    
    
    // Add the item button into the center button
    //
    [dcPathButton addPathItems:@[itemButton_1, itemButton_2, itemButton_3, itemButton_4, itemButton_5,itemButton_6]];
    
    
    // Change the bloom radius
    //
    dcPathButton.bloomRadius = 120.0f;
    // Change the DCButton's center
    dcPathButton.centerBtnRotationEnable = YES;
    [view addSubview:dcPathButton];
    
    
}

- (void)pushDCbutton:(NSNotificationCenter *)notification
{
    
    if (self  == [self getViewControllerWithSelctedIndex])
    {
        
        
        [self pushToViewControllerWithReferType:(MainReferType)[[[notification valueForKey:@"userInfo"] valueForKey:@"index"] integerValue]];
        
        
        //        [dcPathButton centerButtonTapped];
        
    }
    
    
}

#pragma mark - current location

- (void)locationUpdate
{
    LocationManager *loactiomMnager = [[LocationManager shareLocationManager] initWithDelegate:self];
    NSLog(@"%@",loactiomMnager);
}

- (void)currentLocation
{
    if ([[UserManager shareUserManager] getLocationService] && ![[Helper shareHelper] isReferChannelStatus])
    {
        LocationManager *loactiomMnager = [[LocationManager shareLocationManager] initWithDelegate:self];
        NSLog(@"%@",loactiomMnager);
    }
}

- (void)getCurrentLocationWithAddress:(NSDictionary *)address latitude:(NSString *)latitude logitude:(NSString *)logitude
{
    /*
     NSArray *addressArray = [address objectForKey:@"FormattedAddressLines"];
    if ([addressArray count] > 0)
    {
        NSString *currentAddress = [NSString stringWithFormat:@"%@,%@,%@",[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],[addressArray objectAtIndex:2]];
        [[UserManager shareUserManager] setCurrentAddress:currentAddress];
        [[UserManager shareUserManager] setCurrentCity:[address valueForKey:@"City"]];
        [[UserManager shareUserManager] setLatitude:latitude];
        [[UserManager shareUserManager] setLocality:logitude];
        
        
        if (addressArray.count == 3) {
            [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@,%@",[addressArray objectAtIndex:1], [addressArray objectAtIndex:2]]];
        }
        else if (addressArray.count == 4) {
            [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@,%@",[addressArray objectAtIndex:2], [addressArray objectAtIndex:3]]];
        }
        else if (addressArray.count == 5) {
             [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@,%@,%@",[addressArray objectAtIndex:2],[addressArray objectAtIndex:3], [addressArray objectAtIndex:4]]];
        }
        else if (addressArray.count == 6) {
            [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@,%@, %@",[addressArray objectAtIndex:3],[addressArray objectAtIndex:4], [addressArray objectAtIndex:5]]];
        }
        else if (addressArray.count == 7) {
            [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@,%@, %@",[addressArray objectAtIndex:4],[addressArray objectAtIndex:5], [addressArray objectAtIndex:6]]];
        }
        
        //        [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@,%@, %@",[addressArray objectAtIndex:2],[addressArray objectAtIndex:3], [addressArray objectAtIndex:4]]];
        
        NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"locationUpdated", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationupdating" object:nil userInfo:dictionary];
    }
     */
    
    NSString *currentAddress = [NSString stringWithFormat:@"%@,%@,%@,%@",[address objectForKey:@"City"],[address objectForKey:@"State"],[address objectForKey:@"Country"],[address objectForKey:@"ZIP"]];
    [[UserManager shareUserManager] setCurrentAddress:currentAddress];
    [[UserManager shareUserManager] setCurrentCity:[address valueForKey:@"City"]];
    [[UserManager shareUserManager] setLatitude:latitude];
    [[UserManager shareUserManager] setLocality:logitude];
    
    [[UserManager shareUserManager] setCCityState:[NSString stringWithFormat:@"%@", currentAddress]];
    
    NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"locationUpdated", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationupdating" object:nil userInfo:dictionary];

}




#pragma mark -didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

