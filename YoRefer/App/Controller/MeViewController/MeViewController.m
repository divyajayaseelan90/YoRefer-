//
//  MeViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "MeViewController.h"
#import "Configuration.h"
#import "RedeemPointsViewController.h"
#import "UserManager.h"
#import "YoReferAPI.h"
#import "MeModel.h"
#import "EntityViewController.h"
#import "CoreData.h"
#import "Utility.h"
#import "ReferNowViewController.h"
#import "QueryNowViewController.h"
#import "MapViewController.h"
#import "MeViewController.h"
#import "DocumentDirectory.h"
#import "LazyLoading.h"
#import "Constant.h"
#import "Helper.h"
#import "WebViewController.h"
#import "ChangeProfileViewController.h"
#import "BBImageManipulator.h"

typedef enum
{
    Self,
    Guset
    
}UserType;

NSInteger       const         kMeHeaderTag              = 101;

NSInteger       const         kMeSegmentTag             = 101;
NSInteger       const         kMeCategoriesTag          = 102;
NSInteger       const         kMeRefersTag              = 103;
NSInteger       const         kMeRefersMeCountTag       = 104;
NSInteger       const         kMeAsksTag                = 105;
NSInteger       const         kMeAsksCountTag           = 106;
NSInteger       const         kMeFeedsTag               = 107;
NSInteger       const         kMeFeedsCountTag          = 108;
NSInteger       const         kMeFriendsTag             = 2001;
NSInteger       const         kMeFriendsCountTag        = 201;
NSInteger       const         kMETotalPointsTag         = 202;
NSInteger       const         kMeHeaderViewTag          = 10000;
NSUInteger      const         kMeHeaderViewHeight       = 175.0;
NSUInteger      const         kMeTableViewHeight        = 175.0;
NSUInteger      const         kMeTableViewYPos          = 46.0;
NSUInteger      const         kMePointsViewTag          = 700;
NSUInteger      const         kMeReferBackgroundTag     = 157;
NSUInteger      const         kMeAsksBackgroundTag      = 167;
NSUInteger      const         kMeFeedsBackgroundTag     = 177;
NSUInteger      const         kMeFriendsBackgroundTag   = 187;
NSInteger       const         kMeUpdateProfilePicture   = 12000;
NSString    *   const         kMeSelfTitle              = @"Me";
NSString    *   const         kMeError                  = @"Unable to get carousel";
NSString    *   const         kMeLoading                = @"Loading...";
NSString    *   const         kMePlaces                 = @"places";
NSString    *   const         kMeProduct                = @"product";
NSString    *   const         kMePlaceRefer             = @"placeRefer";
NSString    *   const         kMeAllSearchRefer         = @"AllSearchRefer";

NSString    *   const         kMeProductRefer           = @"productRefer";
NSString    *   const         kMeServiceRefer           = @"serviceRefer";
NSString    *   const         kMeWebRefer               = @"webRefer";
NSString    *   const         kMeServices               = @"services";
NSString    *   const         kMeAll                    = @"all";
NSString    *   const         kMeSent                   = @"sent";
NSString    *   const         kMeReceived               = @"received";
NSString    *   const         kMeFriends                = @"friends";
NSString    *   const         kMeAsk                    = @"ask";
NSString    *   const         kMeReferImage             = @"referimage";
NSString    *   const         kMeReferAddress           = @"address" ;
NSString    *   const         kMeRefernowCategoryType   = @"categorytype";
NSString    *   const         kMeyReferNowName          = @"name";
NSString    *   const         kMeReferNowCategory       = @"category";
NSString    *   const         kMeMessage                = @"message";
NSString    *   const         kMeLocatton               = @"location";
NSString    *   const         kMePhone                  = @"phone";
NSString    *   const         kMeWebsite                = @"website";
NSString    *   const         kMeQueryMessage           = @"querymeessage";
NSString    *   const         kMeReferEntityId          = @"entityId";
NSString    *   const         kMeReferLatitude          = @"latitude";
NSString    *   const         kMeReferLongitude         = @"longitude";
NSString    *   const         kMeReferisEntityId         = @"isentiyd";
NSString    *   const kMeViewError                  = @"Unable to get carousel";


@interface MeDetail : NSObject

@property (nonatomic, strong)       NSMutableDictionary   * meDetails;
@property (nonatomic, readwrite)    categories              categories;
@property (nonatomic, readwrite)    FeedsType               feedsType;
@property (nonatomic, readwrite)    MeType                  meType;
@property (nonatomic, readwrite)    UserType                userType;
@property (nonatomic, strong)       NSDictionary          * userDetail;
@property (nonatomic, strong)       NSMutableArray        * rerefreeUser;
@property (nonatomic, readwrite)    BOOL                    isUpdateProfilePicture;
@property (nonatomic, strong)       NSArray               * referals;

@end

@interface MeViewController ()<CategoryView, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic,strong)            MeDetail           * meDetails;
@property (nonatomic, strong)           NSArray            * referResponse;
@property (nonatomic, readwrite) BOOL                        isRemoveProfileImage;
@property (nonatomic, strong) UIImageView *profileImg;

@property (nonatomic, strong) UISearchBar                 *searchBar;
@property (nonatomic, strong) UIView *segmentView;

@property (nonatomic, readwrite) BOOL                        isSearch;

@property (nonatomic, retain) UIView *referOptionView;
@property (nonatomic, retain) UIView *asksOptionView;
@property (nonatomic, retain) UIView *feedsOptionView;
@property (nonatomic, retain) UIView *friendsOptionView;
@property (nonatomic, strong) UIView *viewBg;

@end

@implementation MeViewController

- (instancetype)initWithUser:(NSString *)userType userDetail:(NSDictionary *)userDetail
{
    self = [super init];
    if (self)
    {
        self.meDetails = [[MeDetail alloc]init];
        if ([userType isEqualToString:@"Self"])
            self.meDetails.userType = Self;
        else
            self.meDetails.userType = Guset;
        self.meDetails.userDetail = userDetail;
    }
    return self;
}

#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = (self.meDetails.meType == Guset)?[  [self.meDetails.userDetail valueForKey:kName]capitalizedString]:kMeSelfTitle;
    self.meDetails.isUpdateProfilePicture = NO;
    self.isRemoveProfileImage = NO;
    self.meDetails.meDetails = [[NSMutableDictionary alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    [self headerView];
    [self sideView];
    [self place];
    self.meDetails.meType = Refers;
    self.meDetails.categories = Places;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:@"meprofileupdated" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    UITabBarController *tabBarController = (id)self.revealViewController.frontViewController;
    [tabBarController.tabBar setHidden:NO];
    [self.appDelegate DCButtonWithStatus:NO];
    if(self.meDetails.userType  == Self)
        [self updateProfilePage];
}

- (void)headerView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 64.0;
    CGFloat width = frame.size.width;
    CGFloat height = kMeHeaderViewHeight;
    CGFloat padding = 0.0;
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setTag:1232];
    [view setBackgroundColor:[UIColor colorWithRed:(46.0/255.0) green:(46.0/255.0) blue:(46.0/255.0) alpha:1.0]];
    [self.view addSubview:view];
    //BacgroundImage
    xPos = 0.0;
    yPos = 0.0;
    width = view.frame.size.width;
    height = view.frame.size.height - 40.0;
    UIImageView *backGroundImg = [self createImageViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [backGroundImg setTag:23123];
    [view addSubview:backGroundImg];
    [self setImageWithImageView:backGroundImg];
    //
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = backGroundImg.bounds;
    [backGroundImg addSubview:visualEffectView];
    //ProfileView
    yPos = 0.0;
    xPos = 0.0;
    padding = 90.0;
    width = padding;
    height = view.frame.size.height - 66.0;
    UIView *profileView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
 
    if (self.meDetails.userType == Self)
    {
        UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(profileGestureTapped:)];
        [profileView addGestureRecognizer:profileGestureRecognizer];

//        [profileView setUserInteractionEnabled:YES];
        
    }else
    {
        UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
        [profileView addGestureRecognizer:profileGestureRecognizer];
        
//        [profileView setUserInteractionEnabled:NO];
    }
    [view addSubview:profileView];
    xPos = 2.0;
    width = profileView.frame.size.width;
    height = padding;
    yPos = 10.0;
    _profileImg = [self createImageViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [self setImageWithImageView:_profileImg];
    [_profileImg.layer setCornerRadius:45.0];
    [_profileImg.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_profileImg.layer setBorderWidth:2.0];
    [_profileImg.layer setMasksToBounds:YES];
    [profileView addSubview:_profileImg];
    //optionalview
    xPos = padding;
    yPos = 0.0;
    width = view.frame.size.width - _profileImg.frame.size.width;
    height = view.frame.size.height - 66.0;
    UIView *optionView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view addSubview:optionView];
    //Name
    xPos = 0.0;
    yPos = optionView.frame.size.height - 6.0;
    width = view.frame.size.width;
    height = 30.0;
    UIView *nameView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    yPos = 0.0;
    xPos = 35.0;
    UILabel *profileName = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if (self.meDetails.userType == Self)
    {
        [profileName setText:[[[UserManager shareUserManager] name] capitalizedString]];
    }
    else{
        [profileName setText:[[self.meDetails.userDetail valueForKey:@"name"] capitalizedString]];
        self.title = [[self.meDetails.userDetail valueForKey:@"name"] capitalizedString];
    }
    [profileName setFont:[[Configuration shareConfiguration] yoReferFontWithSize:16.0]];
    [profileName setTextColor:[UIColor whiteColor]];
    [profileName setTextAlignment:NSTextAlignmentLeft];
    [nameView addSubview:profileName];
    [view addSubview:nameView];
    //ReferFeeds
    xPos = 0.0;
    yPos = nameView.frame.origin.y + nameView.frame.size.height;
    width = view.frame.size.width;
    height = 47.0;
    UIView *referFeddsView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referFeddsView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    [view addSubview:referFeddsView];
    //Redeem Points
    if (self.meDetails.userType == Self)
    {
        xPos = 0.0;
        yPos = 0.0;
        width = optionView.frame.size.width;
        height = padding - 40.0;
        UIView *pointsView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
        [optionView addSubview:pointsView];
        //redeem points
        xPos = 0.0;
        yPos = 0.0;
        width = roundf(pointsView.frame.size.width /2) - 14.0;
        height = pointsView.frame.size.height;
        UIView *redeemView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
        UITapGestureRecognizer *redeemPointsGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(redeemPointsGestureTapped:)];
        [redeemView addGestureRecognizer:redeemPointsGesture];
        [pointsView addSubview:redeemView];
        width = redeemView.frame.size.width;
        height = 30.0;
        xPos = 0.0;
        yPos = roundf((redeemView.frame.size.height - height)/2);
        UILabel *redeemlabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Redeem Points"];
        [redeemlabel setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
        [redeemlabel setTextColor:[UIColor whiteColor]];
        [redeemlabel setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
        [redeemlabel.layer setCornerRadius:roundf(redeemlabel.frame.size.height/2)];
        [redeemlabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [redeemlabel.layer setBorderWidth:2.0];
        [redeemlabel.layer setMasksToBounds:YES];
        [redeemView addSubview:redeemlabel];
        //CountView
        xPos = redeemView.frame.size.width + 4.0;
        yPos = 0.0;
        width = roundf(pointsView.frame.size.width /2) + 14.0;
        height = pointsView.frame.size.height;
        UIView *countView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
        UITapGestureRecognizer *countPointsGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sideViewGestureTapped:)];
        [countView addGestureRecognizer:countPointsGesture];
        [pointsView addSubview:countView];
        width = 15.0;
        height = 15.0;
        xPos = countView.frame.size.width - 20.0;
        yPos = roundf((countView.frame.size.height - height)/2);
        UIImageView *arrowImg = [self createImageViewWithFrame:CGRectMake(xPos, yPos, width, height)];
        [arrowImg setImage:[homeArrow imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [arrowImg setTintColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
        [countView addSubview:arrowImg];
        
        width = countView.frame.size.width - 24.0;
        height = 30.0;
        xPos = 0.0;
        yPos = roundf((countView.frame.size.height - height)/2);
        NSInteger earnedPoints = [[self.meDetails.userDetail objectForKey:@"pointsearned"] integerValue];
        NSInteger burnedPoints = [[self.meDetails.userDetail objectForKey:@"pointsburnt"] integerValue];
        NSInteger totalPoints = earnedPoints - burnedPoints;
        UILabel *countlabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:[NSString stringWithFormat:@"%ld Points",(long)totalPoints]];
        [countlabel setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
        [countlabel setTextColor:[UIColor whiteColor]];
        [countlabel setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
        [countlabel.layer setCornerRadius:roundf(redeemlabel.frame.size.height/2)];
        [countlabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [countlabel.layer setBorderWidth:2.0];
        [countlabel.layer setMasksToBounds:YES];
        [countView addSubview:countlabel];
    }
    //ActionView
    padding = 40.0;
    xPos = 0.0;
    yPos = padding + 4.0;
    width = view.frame.size.width - _profileImg.frame.size.width;
    height = view.frame.size.height - ((padding * 2) + 40.0);
    UIView *actionView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [optionView addSubview:actionView];
    //refers
    xPos = 0.0;
    yPos = 0.0;
    width = roundf(actionView.frame.size.width / 4);
    height = actionView.frame.size.height;
    UIView *referView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    UITapGestureRecognizer *referGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referGesturedTapped:)];
    [referView addGestureRecognizer:referGestureRecognizer];
    [actionView addSubview:referView];
    //refer label
    width = referView.frame.size.width;
    height = 20.0;
    xPos = roundf((referView.frame.size.width - width)/2);
    yPos = 10.0;
    UILabel *referLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:(self.meDetails.userType == Self)?[[UserManager shareUserManager] refers]:[self.meDetails.userDetail valueForKey:kReferCount]];
    [referLbl setTextColor:[UIColor whiteColor]];
    [referLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [referView addSubview:referLbl];
    //title
    yPos = referLbl.frame.size.height + 10.0;
    UILabel *referTitleLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Refers"];
    [referTitleLbl setTextColor:[UIColor whiteColor]];
    [referTitleLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [referView addSubview:referTitleLbl];
    //line
    yPos = referLbl.frame.size.height + referTitleLbl.frame.size.height + 10.0;
    height = 2.0;
    width = referView.frame.size.width - 10.0;
    xPos = roundf((referView.frame.size.width - width)/2);
    UIView *referSelectLineView= [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referSelectLineView setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [referView addSubview:referSelectLineView];
    //slde Line
    width = 1.0;
    height = referView.frame.size.height - 2.0;
    xPos = referView.frame.size.width - width;
    yPos = roundf((referView.frame.size.height - height)/2) + 4.0;
    UIView *referSideLineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referSideLineView setBackgroundColor:[UIColor whiteColor]];
    [referView addSubview:referSideLineView];
    //asks
    xPos = referView.frame.size.width;
    yPos = 0.0;
    width = roundf(actionView.frame.size.width / 4);
    height = actionView.frame.size.height;
    UIView *asksView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    UITapGestureRecognizer *askGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(askGesturedTapped:)];
    [asksView addGestureRecognizer:askGestureRecognizer];
    [actionView addSubview:asksView];
    //asks label
    width = asksView.frame.size.width;
    height = 20.0;
    xPos = roundf((asksView.frame.size.width - width)/2);
    yPos = 10.0;
    UILabel *askLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:(self.meDetails.userType == Self)?[[UserManager shareUserManager] askCount]:[self.meDetails.userDetail valueForKey:kAskCount]];
    [askLbl setTextColor:[UIColor whiteColor]];
    [askLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [asksView addSubview:askLbl];
    //title
    yPos = askLbl.frame.size.height + 10.0;
    UILabel *askTitleLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Asks"];
    [askTitleLbl setTextColor:[UIColor whiteColor]];
    [askTitleLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [asksView addSubview:askTitleLbl];
    //line
    yPos = askLbl.frame.size.height + askTitleLbl.frame.size.height + 10.0;
    height = 2.0;
    width = asksView.frame.size.width - 10.0;
    xPos = roundf((asksView.frame.size.width - width)/2);
    UIView *askSelectLineView= [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askSelectLineView setBackgroundColor:[UIColor clearColor]];
    [asksView addSubview:askSelectLineView];
    //slde Line
    width = 1.0;
    height = asksView.frame.size.height- 6.0;
    xPos = asksView.frame.size.width - width;
    yPos = roundf((asksView.frame.size.height - height)/2) + 4.0;
    UIView *askSideLineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askSideLineView setBackgroundColor:[UIColor whiteColor]];
    [asksView addSubview:askSideLineView];
    //feeds
    xPos = referView.frame.size.width + asksView.frame.size.width;
    yPos = 0.0;
    width = roundf(actionView.frame.size.width / 4);
    height = actionView.frame.size.height;
    UIView *feedsView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    UITapGestureRecognizer *feedsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedGesturedTapped:)];
    [feedsView addGestureRecognizer:feedsGestureRecognizer];
    [actionView addSubview:feedsView];
    //feeds label
    width = feedsView.frame.size.width;
    height = 20.0;
    xPos = roundf((asksView.frame.size.width - width)/2);
    yPos = 10.0;
    UILabel *feedsLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:(self.meDetails.userType == Self)?[self.meDetails.userDetail valueForKey:kFeedsCount]:[self.meDetails.userDetail valueForKey:kFeedsCount]];
    [feedsLbl setTextColor:[UIColor whiteColor]];
    [feedsLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [feedsView addSubview:feedsLbl];
    //title
    yPos = feedsLbl.frame.size.height + 10.0;
    UILabel *feedsTitleLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Feeds"];
    [feedsTitleLbl setTextColor:[UIColor whiteColor]];
    [feedsTitleLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [feedsView addSubview:feedsTitleLbl];
    //line
    yPos = feedsLbl.frame.size.height + feedsTitleLbl.frame.size.height + 10.0;
    height = 2.0;
    width = feedsView.frame.size.width - 10.0;
    xPos = roundf((feedsView.frame.size.width - width)/2);
    UIView *feedsSelectLineView= [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [feedsSelectLineView setBackgroundColor:[UIColor clearColor]];
    [feedsView addSubview:feedsSelectLineView];
    //slde Line
    width = 1.0;
    height = feedsView.frame.size.height - 6.0;
    xPos = feedsView.frame.size.width - width;
    yPos = roundf((feedsView.frame.size.height - height)/2) + 4.0;
    UIView *feedsSideLineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [feedsSideLineView setBackgroundColor:[UIColor whiteColor]];
    [feedsView addSubview:feedsSideLineView];
    //friends
    xPos = referView.frame.size.width + asksView.frame.size.width + feedsView.frame.size.width;
    yPos = 0.0;
    width = roundf(actionView.frame.size.width / 4);
    height = actionView.frame.size.height;
    UIView *friendsView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    UITapGestureRecognizer *friendsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(friendGesturedTapped:)];
    [friendsView addGestureRecognizer:friendsGestureRecognizer];
    [actionView addSubview:friendsView];
    //friends label
    width = friendsView.frame.size.width;
    height = 20.0;
    xPos = roundf((friendsView.frame.size.width - width)/2);
    yPos = 10.0;
    UILabel *friendsLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:(self.meDetails.userType == Self)?[self.meDetails.userDetail valueForKey:kFriendsCount]:[self.meDetails.userDetail valueForKey:kFriendsCount]];
    [friendsLbl setTextColor:[UIColor whiteColor]];
    [friendsLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [friendsView addSubview:friendsLbl];
    //title
    yPos = friendsLbl.frame.size.height + 10.0;
    UILabel *friendsTitleLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Friends"];
    [friendsTitleLbl setTextColor:[UIColor whiteColor]];
    [friendsTitleLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [friendsView addSubview:friendsTitleLbl];
    //line
    yPos = friendsLbl.frame.size.height + friendsTitleLbl.frame.size.height + 10.0;
    height = 2.0;
    width = friendsView.frame.size.width - 10.0;
    xPos = roundf((friendsView.frame.size.width - width)/2);
    UIView *friendsSelectLineView= [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [friendsSelectLineView setBackgroundColor:[UIColor clearColor]];
    [friendsView addSubview:friendsSelectLineView];
    //slde Line
    width = 1.0;
    height = friendsView.frame.size.height - 10.0;
    xPos = friendsView.frame.size.width - width;
    yPos = roundf((friendsView.frame.size.height - height)/2) + 6.0;
    UIView *friendsSideLineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [friendsSideLineView setBackgroundColor:[UIColor whiteColor]];
   // [friendsView addSubview:friendsSideLineView];
    
    
     //ReferFeeds
    [_referOptionView removeFromSuperview];
    _referOptionView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 252.0, referFeddsView.frame.size.width, referFeddsView.frame.size.height)];
    [_referOptionView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
//    [referFeddsView addSubview:referOptionView];
    [self.view  addSubview:_referOptionView];
    [self referOptionWithViw:_referOptionView];
    
    //AsksOption
    [_asksOptionView removeFromSuperview];
    _asksOptionView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 252.0, referFeddsView.frame.size.width, referFeddsView.frame.size.height)];
    [_asksOptionView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
//    [referFeddsView addSubview:asksOptionView];
    [self.view  addSubview:_asksOptionView];
    [_asksOptionView setHidden:YES];
    [self asksOptionWithView:_asksOptionView title:@"Asks"];
    
    
    //FeedsOption
    [_feedsOptionView removeFromSuperview];
    _feedsOptionView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 252.0, referFeddsView.frame.size.width, referFeddsView.frame.size.height)];
    [_feedsOptionView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
//    [referFeddsView addSubview:feedsOptionView];
    [self.view  addSubview:_feedsOptionView];
    [_feedsOptionView setHidden:YES];
    [self feedsOptionWithView:_feedsOptionView];
    
    
    
    //FriendsOption
    [_friendsOptionView removeFromSuperview];
    _friendsOptionView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 252.0, referFeddsView.frame.size.width, referFeddsView.frame.size.height)];
    [_friendsOptionView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
//    [referFeddsView addSubview:friendsOptionView];
    [self.view  addSubview:_friendsOptionView];
    [_friendsOptionView setHidden:YES];
    [self asksOptionWithView:_friendsOptionView title:@"Friends"];
    
    
    _viewBg = [[UIView alloc]initWithFrame:CGRectMake(frame.origin.x, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+30, frame.size.width, 50)];
    [_viewBg setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    [self.view  addSubview:_viewBg];
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(frame.origin.x+15, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+30, frame.size.width-30, 45)];
    _searchBar.placeholder = @"Search";
    [_searchBar setDelegate:self];
    _searchBar.layer.borderWidth = 3;
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    [_searchBar setBarTintColor:[UIColor whiteColor]];
    [_searchBar setBackgroundColor:[UIColor whiteColor]];
    _searchBar.layer.cornerRadius = 8.0;
    _searchBar.layer.masksToBounds = YES;
    [self.view addSubview:_searchBar];
    [self.view bringSubviewToFront:_searchBar];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];

}

-(void)zoomImage:(UITapGestureRecognizer*) gesture{
    NSData *milestoneImageData = UIImagePNGRepresentation(_profileImg.image);
    NSData *noImageData = UIImagePNGRepresentation([UIImage imageNamed:@"no_image"]);
    NSData *loadingImageData = UIImagePNGRepresentation([UIImage imageNamed:@"loading"]);
    if (![milestoneImageData isEqual:noImageData] && ![milestoneImageData isEqual:loadingImageData]) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        BBImageManipulator *controller = [BBImageManipulator loadController:_profileImg.image];
//        [controller setRotatableByButton:YES];
        [controller setZoomable:YES];
        [controller setDoubleTapZoomable:YES];
        [controller setupUIAndGestures];
        [self.view addSubview:controller];
    }
}


- (void)sideView
{
    CGRect frame = [self bounds];
    CGFloat xPos = frame.size.width;
    CGFloat yPos = 64.0;
    CGFloat width = frame.size.width - 160.0;
    CGFloat height = kMeHeaderViewHeight - 42.0;
    UIView *viewPoints = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewPoints.backgroundColor = [UIColor colorWithRed:(46.0/255.0) green:(46.0/255.0) blue:(46.0/255.0) alpha:1.0f];
    viewPoints.tag = Points;
    UITapGestureRecognizer *viewTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewPointsGestureTapped:)];
    [viewPoints addGestureRecognizer:viewTapped];
    xPos = 0.0;
    yPos = 20.0;
    width = 15.0;
    height = viewPoints.frame.size.height - 40.0;
    UIButton *buttonCloseView = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    buttonCloseView.backgroundColor = [UIColor clearColor];
    [buttonCloseView setBackgroundImage:[UIImage imageNamed:@"icon_sidebar.png"] forState:UIControlStateNormal];
    [buttonCloseView addTarget:self action:@selector(pointsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [viewPoints addSubview:buttonCloseView];
    xPos = 30.0;
    yPos = 0.0;
    width = viewPoints.frame.size.width/2;
    height = viewPoints.frame.size.height/3;
    UILabel *pointsEarned = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Points Earned", @"")];
    pointsEarned.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    pointsEarned.textAlignment = NSTextAlignmentLeft;
    pointsEarned.textColor = [UIColor whiteColor];
    [viewPoints addSubview:pointsEarned];
    yPos = pointsEarned.frame.size.height;
    width = viewPoints.frame.size.width/2;
    UILabel *pointsBurned = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Points Redeemed", @"")];
    pointsBurned.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    pointsBurned.textAlignment = NSTextAlignmentLeft;
    pointsBurned.textColor = [UIColor whiteColor];
    [viewPoints addSubview:pointsBurned];
    yPos = pointsBurned.frame.size.height + pointsBurned.frame.origin.y;
    width = viewPoints.frame.size.width/2;
    UILabel *pointsAvailable = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Points Available", @"")];
    pointsAvailable.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    pointsAvailable.textAlignment = NSTextAlignmentLeft;
    pointsAvailable.textColor = [UIColor whiteColor];
    [viewPoints addSubview:pointsAvailable];
    xPos = pointsEarned.frame.size.width;
    yPos = 0.0;
    width = (viewPoints.frame.size.width/2) - 20.0;
    UILabel *pointsEarnednumber = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:[self.meDetails.userDetail objectForKey:@"pointsearned"]];
    pointsEarnednumber.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    pointsEarnednumber.textAlignment = NSTextAlignmentRight;
    pointsEarnednumber.textColor = [UIColor whiteColor];
    [viewPoints addSubview:pointsEarnednumber];
    xPos = pointsBurned.frame.size.width;
    yPos = pointsEarnednumber.frame.size.height;
    width = (viewPoints.frame.size.width/2) - 20.0;
    UILabel *pointsBurnedNumber = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:[self.meDetails.userDetail objectForKey:@"pointsburnt"]];
    pointsBurnedNumber.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    pointsBurnedNumber.textAlignment = NSTextAlignmentRight;
    pointsBurnedNumber.textColor = [UIColor whiteColor];
    [viewPoints addSubview:pointsBurnedNumber];
    NSInteger earnedPoints = [[[UserManager shareUserManager] pointsEarned] integerValue];
    NSInteger burnedPoints = [[[UserManager shareUserManager] pointsBurnt] integerValue];
    NSInteger totalPoints = earnedPoints - burnedPoints;
    xPos = pointsAvailable.frame.size.width;
    yPos = pointsBurnedNumber.frame.size.height + pointsBurnedNumber.frame.origin.y;
    width = (viewPoints.frame.size.width/2) - 20.0;
    UILabel *pointsAvailableNumber = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:[NSString stringWithFormat:@"%ld",totalPoints]];
    pointsAvailableNumber.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    pointsAvailableNumber.textAlignment = NSTextAlignmentRight;
    pointsAvailableNumber.textColor = [UIColor whiteColor];
    [viewPoints addSubview:pointsAvailableNumber];
    viewPoints.tag = kMePointsViewTag;
    [self.view addSubview:viewPoints];
}

- (void)asksOptionWithView:(UIView *)view title:(NSString *)title
{
    CGFloat xPos = 15.0;
    CGFloat yPos = 5.0;
    CGFloat width = view.frame.size.width - 30.0;
    CGFloat height = view.frame.size.height - 10.0;
    _segmentView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    _segmentView.backgroundColor = [UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(6.0/255.0) alpha:1.0f];
    _segmentView.layer.cornerRadius = 17.0;
    _segmentView.layer.masksToBounds = YES;
    [view addSubview:_segmentView];
    width = _segmentView.frame.size.width - 4.0;
    height = _segmentView.frame.size.height - 4.0;
    xPos = 2.0;
    yPos = 2.0;
    UILabel *askLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:title];
    askLabel.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
    askLabel.userInteractionEnabled = YES;
    askLabel.textColor = [UIColor whiteColor];
    askLabel.layer.cornerRadius = 17.0;
    askLabel.layer.masksToBounds = YES;
    [_segmentView addSubview:askLabel];
}

- (void)feedsOptionWithView:(UIView *)view
{
    CGFloat xPos = 15.0;
    CGFloat yPos = 5.0;
    CGFloat width = view.frame.size.width - 30.0;
    CGFloat height = view.frame.size.height - 10.0;
    _segmentView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    _segmentView.backgroundColor = [UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(6.0/255.0) alpha:1.0f];
    _segmentView.layer.cornerRadius = 17.0;
    _segmentView.layer.masksToBounds = YES;
    [view addSubview:_segmentView];
    width = _segmentView.frame.size.width/3;
    height = _segmentView.frame.size.height - 2.0;
    xPos = 1.0;
    yPos = 1.0;
    UILabel *allLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"All"];
    allLabel.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
    allLabel.tag = All;
    allLabel.userInteractionEnabled = YES;
    allLabel.textColor = [UIColor whiteColor];
    allLabel.layer.cornerRadius = 17.0;
    allLabel.layer.masksToBounds = YES;
    [_segmentView addSubview:allLabel];
    xPos = allLabel.frame.size.width;
    yPos = 6.0;
    width = 2.0;
    height = allLabel.frame.size.height - 12.0;
    xPos = allLabel.frame.size.width + 2.0;
    yPos = 1.0;
    width = (_segmentView.frame.size.width/3) - 3.0;
    height = _segmentView.frame.size.height - 2.0;
    UILabel *sentLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Sent"];
    sentLabel.tag = Sent;
    sentLabel.userInteractionEnabled = YES;
    sentLabel.backgroundColor = [UIColor clearColor];
    sentLabel.textColor = [UIColor grayColor];
    sentLabel.layer.cornerRadius = 17.0;
    sentLabel.layer.masksToBounds = YES;
    [_segmentView addSubview:sentLabel];
    xPos = sentLabel.frame.size.width + sentLabel.frame.origin.x;
    yPos = 6.0;
    width = 2.0;
    height = sentLabel.frame.size.height - 12.0;
    xPos = sentLabel.frame.size.width + sentLabel.frame.origin.x + 2.0;
    yPos = 1.0;
    width = (_segmentView.frame.size.width/3) - 2.0;
    height = _segmentView.frame.size.height - 2.0;
    UILabel *receivedlabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Received", nil)];
    receivedlabel.tag = Received;
    receivedlabel.userInteractionEnabled = YES;
    receivedlabel.backgroundColor = [UIColor clearColor];
    receivedlabel.textColor = [UIColor grayColor];
    receivedlabel.layer.cornerRadius = 17.0;
    receivedlabel.layer.masksToBounds = YES;
    [_segmentView addSubview:receivedlabel];
    UITapGestureRecognizer *allGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(allGestureTapped:)];
    [allLabel addGestureRecognizer:allGestureRecognizer];
    UITapGestureRecognizer *sentGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sentGestureTapped:)];
    [sentLabel addGestureRecognizer:sentGestureRecognizer];
    UITapGestureRecognizer *receivedGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(receivedGestureTapped:)];
    [receivedlabel addGestureRecognizer:receivedGestureRecognizer];
}

- (void)referOptionWithViw:(UIView *)view
{
    
    CGFloat xPos = 15.0;
    CGFloat yPos = 5.0;
    CGFloat width = view.frame.size.width - 30.0;
    CGFloat height = view.frame.size.height - 10.0;
    _segmentView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    _segmentView.backgroundColor = [UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(6.0/255.0) alpha:1.0f];
    _segmentView.layer.cornerRadius = 17.0;
    _segmentView.layer.masksToBounds = YES;
    [view addSubview:_segmentView];
    //place label
    width = _segmentView.frame.size.width/4;
    height = _segmentView.frame.size.height - 2.0;
    xPos = 1.0;
    yPos = 1.0;
    UILabel *placeLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Places"];
    placeLabel.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
    placeLabel.userInteractionEnabled = YES;
    placeLabel.textColor = [UIColor whiteColor];
    placeLabel.layer.cornerRadius = 17.0;
    placeLabel.layer.masksToBounds = YES;
    [_segmentView addSubview:placeLabel];
    //product label
    xPos = placeLabel.frame.size.width + 3.0;
    yPos = 1.0;
    width = (_segmentView.frame.size.width/4) - 1.0;
    height = _segmentView.frame.size.height - 2.0;
    UILabel *productLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Products"];
    productLabel.userInteractionEnabled = YES;
    productLabel.backgroundColor = [UIColor clearColor];
    productLabel.textColor = [UIColor grayColor];
    productLabel.layer.cornerRadius = 17.0;
    productLabel.layer.masksToBounds = YES;
    [_segmentView addSubview:productLabel];
    //service label
    xPos = productLabel.frame.size.width + productLabel.frame.origin.x + 7.0;
    yPos = 1.0;
    width = (_segmentView.frame.size.width/4);
    height = _segmentView.frame.size.height - 3.0;
    UILabel *servicelabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Services", nil)];
    servicelabel.userInteractionEnabled = YES;
    servicelabel.backgroundColor = [UIColor clearColor];
    servicelabel.textColor = [UIColor grayColor];
    servicelabel.layer.cornerRadius = 17.0;
    servicelabel.layer.masksToBounds = YES;
    [_segmentView addSubview:servicelabel];
    //web label
    xPos = servicelabel.frame.size.width + servicelabel.frame.origin.x;
    yPos = 1.0;
    width = (_segmentView.frame.size.width/4) - 10.0;
    height = _segmentView.frame.size.height - 2.0;
    UILabel *weblabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Web", nil)];
    weblabel.userInteractionEnabled = YES;
    weblabel.backgroundColor = [UIColor clearColor];
    weblabel.textColor = [UIColor grayColor];
    weblabel.layer.cornerRadius = 17.0;
    weblabel.layer.masksToBounds = YES;
    [_segmentView addSubview:weblabel];

    //GestureRecognizer
    UITapGestureRecognizer *placeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeGestureTapped:)];
    [placeLabel addGestureRecognizer:placeGestureRecognizer];
    
    UITapGestureRecognizer *productGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(productGestureTapped:)];
    [productLabel addGestureRecognizer:productGestureRecognizer];
    
    UITapGestureRecognizer *serviceGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(serviceGestureTapped:)];
    [servicelabel addGestureRecognizer:serviceGestureRecognizer];
    
    UITapGestureRecognizer *webGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webGestureTapped:)];
    [weblabel addGestureRecognizer:webGestureRecognizer];
}

- (void)setImageWithImageView:(UIImageView *)imageView
{
    NSString *imageUrl;
    NSArray *array;
    if (self.meDetails.userType == Guset && [[self.meDetails.userDetail valueForKey:kFrom] valueForKey:kDp]!= nil && [[[self.meDetails.userDetail valueForKey:kFrom] valueForKey:kDp] length] > 0)
    {
        array = [[[self.meDetails.userDetail objectForKey:kFrom] objectForKey:kDp] componentsSeparatedByString:@"/"];
        imageUrl = [[self.meDetails.userDetail objectForKey:kFrom] objectForKey:kDp];
        
    }else if (self.meDetails.userType == Guset && [[self.meDetails.userDetail valueForKey:kToUser] count] > 0 && ![[[[self.meDetails.userDetail valueForKey:kToUser] objectAtIndex:0] valueForKey:kGuest] boolValue])
    {
        array = [[[[self.meDetails.userDetail objectForKey:kToUser] objectAtIndex:0]objectForKey:kDp] componentsSeparatedByString:@"/"];
        imageUrl = [[[self.meDetails.userDetail objectForKey:kToUser] objectAtIndex:0]objectForKey:kDp];
        
    }else if (self.meDetails.userType == Guset && [[self.meDetails.userDetail valueForKey:kUser] valueForKey:kDp] != nil && [[[self.meDetails.userDetail valueForKey:kUser] valueForKey:kDp] length] > 0)
    {
        array = [[[self.meDetails.userDetail objectForKey:kUser] objectForKey:kDp] componentsSeparatedByString:@"/"];
        imageUrl = [[self.meDetails.userDetail objectForKey:kUser] objectForKey:kDp];
        
    }else if (self.meDetails.userType == Guset && [self.meDetails.userDetail objectForKey:@"friendsDp"] != nil && [[self.meDetails.userDetail objectForKey:@"friendsDp"] length] > 0)
    {
        array = [[self.meDetails.userDetail objectForKey:@"friendsDp"] componentsSeparatedByString:@"/"];
        imageUrl = [self.meDetails.userDetail objectForKey:@"friendsDp"];
        
    }else if (self.meDetails.userType != Guset && [[UserManager shareUserManager] dp] != nil && [[[UserManager shareUserManager] dp] length] > 0)
    {
        array = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
        imageUrl = [[UserManager shareUserManager] dp];
    }
    if ([array count] > 0)
    {
        NSString *imageName = [array objectAtIndex:[array count]-1];
        
        if ([[self.meDetails.userDetail objectForKey:@"number"] isEqualToString:@"(null)"] || [[self.meDetails.userDetail objectForKey:@"number"] isEqualToString:@""]){
            
            if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] emailId],imageName]] && (imageName != nil && [imageName length] > 0))
            {
                [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] emailId],imageName]];
                
            }else
            {
                if ([array count] > 1)
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:imageUrl] imageView:imageView];
                }else
                {
                    [imageView setImage: (imageView.tag == 23123)?nil:profilePic];
                }
                
            }
        }
        else{
        
            if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
            {
                [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                
            }else
            {
                if ([array count] > 1)
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:imageUrl] imageView:imageView];
                }else
                {
                    [imageView setImage: (imageView.tag == 23123)?nil:profilePic];
                }
                
            }
        }

    }else
    {
        [imageView setImage: (imageView.tag == 23123)?nil:profilePic];
        [imageView setBackgroundColor:[UIColor colorWithRed:(46.0/255.0) green:(46.0/255.0) blue:(46.0/255.0) alpha:1.0]];
    }

}

- (UIView *)createViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    return view;
}

- (UIImageView *)createImageViewWithFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    return imageView;
    
}

- (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]];
    label.text = NSLocalizedString(text, @"");
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 3;
    return label;
}

#pragma mark - GestureRecognizer

- (void)profileGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    ChangeProfileViewController *vctr = [[ChangeProfileViewController alloc]init];
    [self.navigationController pushViewController:vctr animated:YES];

}

- (void)placeGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
     self.meDetails.categories = Places;
    [self activeSectionWithCategories:Places view:[gestureRecognizer.view superview]];
    [self place];
    
}

- (void)productGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.meDetails.categories = Product;
    [self activeSectionWithCategories:Product view:[gestureRecognizer.view superview]];
    [self product];
    
}

- (void)serviceGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.meDetails.categories = Services;
    [self activeSectionWithCategories:Services view:[gestureRecognizer.view superview]];
    [self service];
}

- (void)webGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.meDetails.categories = Web;
    [self activeSectionWithCategories:Web view:[gestureRecognizer.view superview]];
    [self web];
    
}


- (void)allGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.meDetails.feedsType = All;
    [self getFeeds];
    [self activeSectionWithFeeds:All view:[gestureRecognizer.view superview]];
    
}

- (void)sentGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.meDetails.feedsType = Sent;
    [self getFeeds];
    [self activeSectionWithFeeds:Sent view:[gestureRecognizer.view superview]];
    
}

- (void)receivedGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.meDetails.feedsType = Received;
    [self getFeeds];
    [self activeSectionWithFeeds:Received view:[gestureRecognizer.view superview]];
    
}

- (void)activeSectionWithCategories:(categories)categories view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    switch (categories) {
        case Places:
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:3]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:3]setTextColor:[UIColor grayColor]];
            break;
        case Product:
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:3]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:3]setTextColor:[UIColor grayColor]];
            break;
        case Services:
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:3]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:3]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            break;
        case Web:
            [(UILabel *)[subViews objectAtIndex:3]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:3]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];            break;
        default:
            break;
    }
    
}

- (void)activeSectionWithFeeds:(FeedsType)feedsType view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    switch (feedsType)
    {
        case All:
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            break;
        case Sent:
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            break;
        case Received:
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
    
}

- (void)redeemPointsGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    RedeemPointsViewController *vctr = [[RedeemPointsViewController alloc]init];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)sideViewGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView *profileView = (UIView *)[self.view viewWithTag:700];
    CGRect newProfile =  [(UIView *)[self.view viewWithTag:700] frame];
    if(profileView.frame.origin.x == self.view.frame.size.width)
    {
        newProfile.origin.x = 160.0;
        [UIView animateWithDuration:1.0 animations:^(void){
            profileView.frame = newProfile;
            
        }];
        
        
    }
}

- (void)viewPointsGestureTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    UIView *profileView = (UIView *)[self.view viewWithTag:kMePointsViewTag];
    CGRect newProfile =  [(UIView *)[self.view viewWithTag:kMePointsViewTag] frame ];
    if(profileView.frame.origin.x == 160.0)
    {
        newProfile.origin.x = self.view.frame.size.width;
        [UIView animateWithDuration:1.0 animations:^(void){
            profileView.frame = newProfile;
            
        }];
    }
}

- (void)referGesturedTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    _isSearch = NO;
    [_searchBar setText:@""];
    if (self.meDetails.meType == Refers)
        return;
    self.meDetails.meType = Refers;
    [self activeMeWithType:Refers view:gestureRecognizer.view.superview];
    [self place];
}

- (void)askGesturedTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    _isSearch = NO;
    [_searchBar setText:@""];
    if (self.meDetails.meType == Asks)
        return;
    self.meDetails.meType = Asks;
    [self activeMeWithType:Asks view:gestureRecognizer.view.superview];
    [self getAsk];
}

- (void)feedGesturedTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    _isSearch = NO;
    [_searchBar setText:@""];
    if (self.meDetails.meType == Feeds)
        return;
    self.meDetails.meType = Feeds;
    [self activeMeWithType:Feeds view:gestureRecognizer.view.superview];
    self.meDetails.feedsType = All;
    [self getFeeds];
}

- (void)friendGesturedTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    _isSearch = NO;
    [_searchBar setText:@""];
    if (self.meDetails.meType == Friends)
        return;
    self.meDetails.meType = Friends;
    [self activeMeWithType:Friends view:gestureRecognizer.view.superview];
    [self getFriend];
}

- (void)updateHeaderViewWithMetype:(MeType)meType superView:(UIView *)superView
{
    /*
    NSArray *superViewSubViews = [superView subviews];
    CGRect newFrame;
    */
    switch (meType) {
        case Refers:
            [_referOptionView setHidden:NO];
            [_asksOptionView setHidden:YES];
            [_feedsOptionView setHidden:YES];
            [_friendsOptionView setHidden:YES];
            /*
            [(UIView *)[superViewSubViews objectAtIndex:4]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:0]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:1]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:2]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:3]setHidden:YES];
            newFrame = superView.frame;
            newFrame.size = CGSizeMake(superView.frame.size.width, (superView.frame.size.height < kMeTableViewHeight)?(superView.frame.size.height + 42.0):kMeTableViewHeight);
            superView.frame = newFrame;
            */
            break;
        case Asks:
            [_referOptionView setHidden:YES];
            [_asksOptionView setHidden:NO];
            [_feedsOptionView setHidden:YES];
            [_friendsOptionView setHidden:YES];
            /*
            [(UIView *)[superViewSubViews objectAtIndex:4]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:0]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:1]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:2]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:3]setHidden:YES];
            newFrame = superView.frame;
            newFrame.size = CGSizeMake(superView.frame.size.width, (superView.frame.size.height < kMeTableViewHeight)?(superView.frame.size.height + 42.0):kMeTableViewHeight);
            superView.frame = newFrame;
            */
            break;
        case Feeds:
            [_referOptionView setHidden:YES];
            [_asksOptionView setHidden:YES];
            [_feedsOptionView setHidden:NO];
            [_friendsOptionView setHidden:YES];
            /*
            [(UIView *)[superViewSubViews objectAtIndex:4]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:0]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:1]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:2]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:3]setHidden:YES];
            newFrame = superView.frame;
            newFrame.size = CGSizeMake(superView.frame.size.width, (superView.frame.size.height < kMeTableViewHeight)?(superView.frame.size.height + 42.0):kMeTableViewHeight);
            superView.frame = newFrame;
            */
            break;
        case Friends:
            [_referOptionView setHidden:YES];
            [_asksOptionView setHidden:YES];
            [_feedsOptionView setHidden:YES];
            [_friendsOptionView setHidden:NO];
            /*
            [(UIView *)[superViewSubViews objectAtIndex:4]setHidden:NO];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:0]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:1]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:2]setHidden:YES];
            [(UIView *)[[[superViewSubViews objectAtIndex:4]subviews]objectAtIndex:3]setHidden:NO];
            newFrame = superView.frame;
            newFrame.size = CGSizeMake(superView.frame.size.width, (superView.frame.size.height < kMeTableViewHeight)?(superView.frame.size.height + 42.0):kMeTableViewHeight);
            superView.frame = newFrame;
            */
            break;
        default:
            break;
    }
}
- (void)activeMeWithType:(MeType)meType view:(UIView *)view
{
    [self updateHeaderViewWithMetype:meType superView:view.superview.superview];
    NSArray *subViews = [view subviews];
    switch (meType)
    {
        case Refers:
            [(UIView *)[[[subViews objectAtIndex:0] subviews] objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UIView *)[[[subViews objectAtIndex:1] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:2] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:3] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            break;
        case Asks:
            [(UIView *)[[[subViews objectAtIndex:0] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:1] subviews] objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UIView *)[[[subViews objectAtIndex:2] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:3] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            break;
        case Feeds:
            [(UIView *)[[[subViews objectAtIndex:0] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:1] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:2] subviews] objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UIView *)[[[subViews objectAtIndex:3] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            break;
        case Friends:
            [(UIView *)[[[subViews objectAtIndex:0] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:1] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:2] subviews] objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[[[subViews objectAtIndex:3] subviews] objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            break;
        default:
            break;
    }
    
}

- (void)referListWithDetail:(NSMutableArray *)referList
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    view.tag = 80000;
    [view setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(8.0/255.0) blue:(8.0/255.0) alpha:0.8f]];
    [self.view addSubview:view];
    CGFloat height = 400.0;
    CGFloat width = view.frame.size.width - 12.0;
    CGFloat yPos = roundf((view.frame.size.height- height)/2);
    CGFloat xPos = roundf((view.frame.size.width - width)/2);
    Users *addContact  = [[Users alloc]initWithViewFrame:CGRectMake(xPos, yPos, width, height) delegate:self users:referList];
    [addContact.layer setCornerRadius:5.0];
    [addContact.layer setMasksToBounds:YES];
    [view addSubview:addContact];
    width = 26.0;
    height = 26.0;
    xPos = view.frame.size.width - (width + 3.0);
    yPos = yPos - 18.0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:crossBtnImg];
    [view addSubview:imageView];
    width = 50.0;
    height = 38.0;
    xPos = view.frame.size.width - width;
    yPos = yPos - 16.0;
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [closeBtn setBackgroundColor:[UIColor clearColor]];
    [closeBtn addTarget:self action:@selector(closeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
}

#pragma mark  - Handler
- (void)place
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
     NSArray *placerefer = [[CoreData shareData] getPlaceReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([placerefer count] > 0 && self.meDetails.userType == Self)
    {
         NSMutableArray *places = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in placerefer)
        {
            MeModel *me = [MeModel getPlaceByResponse:dictionary];
            [places addObject:me];
        }
        [self hideHUD];
        [self.meDetails.meDetails setValue:places forKey:kMePlaceRefer];
        [self reloadTableView];
    }else
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
        
        [param setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
        [param setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];
        [param setValue:kPlace forKey:@"referType"];
        [[YoReferAPI sharedAPI] getPlaceReferWithParam:param completionHandler:^(NSDictionary *response ,NSError *error)
         {
             [self didReceivePlaceReferWithResponse:response error:error];
             
         }];
    }
}

- (void)didReceivePlaceReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else
    {
        if ([[response valueForKey:@"response"] count] > 0)
        {
            NSArray *refer;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setPlaceReferWithLoginId:[[UserManager shareUserManager] number] response:response];
                refer = [[CoreData shareData] getPlaceReferWithLoginId:[[UserManager shareUserManager] number]];
            }else
            {
                refer = [response valueForKey:@"response"];
            }
            if ([refer count] > 0)
            {
                NSMutableArray *placesRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    MeModel *me = [MeModel getPlaceByResponse:dictionary];
                    [placesRefer addObject:me];
                    
                }
                [self.meDetails.meDetails setValue:placesRefer forKey:kMePlaceRefer];
            }

        }else
        {
            
        }
    }
    [self reloadTableView];
}

- (void)product
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    NSArray *productRefer = [[CoreData shareData] getProducteReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([productRefer count] > 0 && self.meDetails.userType == Self)
    {
        NSMutableArray *product = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in productRefer)
        {
            MeModel *me = [MeModel getPlaceByResponse:dictionary];
            [product addObject:me];
        }
        [self hideHUD];
        [self.meDetails.meDetails setValue:product forKey:kMeProductRefer];
        [self reloadTableView];
    }else
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
        [param setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
        [param setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];
        [param setValue:kProduct forKey:@"referType"];
        [[YoReferAPI sharedAPI] getProductReferWithParam:param completionHandler:^(NSDictionary *response ,NSError *error)
         {
             [self didReceiveProductReferWithResponse:response error:error];
             
         }];
    }
}

- (void)didReceiveProductReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else
    {
        if ([[response valueForKey:@"response"] count] > 0)
        {
            NSArray *refer;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setProdcutReferWithLoginId:[[UserManager shareUserManager] number] response:response];
                refer = [[CoreData shareData] getProducteReferWithLoginId:[[UserManager shareUserManager] number]];
            }else
            {
                refer = [response valueForKey:@"response"];
            }
            if ([refer count] > 0)
            {
                NSMutableArray *productRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    MeModel *me = [MeModel getPlaceByResponse:dictionary];
                    [productRefer addObject:me];
                    
                }
                [self.meDetails.meDetails setValue:productRefer forKey:kMeProductRefer];
            }

        }
    }
      [self reloadTableView];
}

- (void)service
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    NSArray *serviceRefer = [[CoreData shareData] getServiceReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([serviceRefer count] > 0 && self.meDetails.userType == Self)
    {
        NSMutableArray *service = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in serviceRefer)
        {
            MeModel *me = [MeModel getPlaceByResponse:dictionary];
            [service addObject:me];
        }
        [self hideHUD];
        [self.meDetails.meDetails setValue:service forKey:kMeServiceRefer];
        [self reloadTableView];
    }else
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
        [param setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
        [param setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];
        [param setValue:kService forKey:@"referType"];
        [[YoReferAPI sharedAPI] getServiceReferWithParam:param completionHandler:^(NSDictionary *response ,NSError *error)
         {
             [self didReceiveServiceReferWithResponse:response error:error];
             
         }];
    }
}

- (void)didReceiveServiceReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
            
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else
    {
        if ([[response valueForKey:@"response"] count] > 0)
        {
            NSArray *refer;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setServiceReferWithLoginId:[[UserManager shareUserManager] number] response:response];
                refer = [[CoreData shareData] getServiceReferWithLoginId:[[UserManager shareUserManager] number]];
            }else
            {
                refer = [response valueForKey:@"response"];
            }
            if ([refer count] > 0)
            {
                NSMutableArray *serviceRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    MeModel *me = [MeModel getPlaceByResponse:dictionary];
                    [serviceRefer addObject:me];
                    
                }
                [self.meDetails.meDetails setValue:serviceRefer forKey:kMeServiceRefer];
                
            }

        }else
        {
            
        }
    }
    [self reloadTableView];
}

- (void)web
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    NSArray *webRefer = [[CoreData shareData] getWebReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([webRefer count] > 0 && self.meDetails.userType == Self)
    {
        NSMutableArray *web = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in webRefer)
        {
            MeModel *me = [MeModel getPlaceByResponse:dictionary];
            [web addObject:me];
        }
        [self hideHUD];
        [self.meDetails.meDetails setValue:web forKey:kMeWebRefer];
        [self reloadTableView];
    }else
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
        [param setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
        [param setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];

        [param setValue:kWeb forKey:@"referType"];
        [[YoReferAPI sharedAPI] getWebReferWithParam:param completionHandler:^(NSDictionary *response ,NSError *error)
         {
             [self didReceiveWebReferWithResponse:response error:error];
             
         }];
    }
}

- (void)didReceiveWebReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else
    {
        if ([[response valueForKey:@"response"] count] > 0)
        {
            NSArray *refer;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setWebReferWithLoginId:[[UserManager shareUserManager] number] response:response];
                refer = [[CoreData shareData] getWebReferWithLoginId:[[UserManager shareUserManager] number]];
            }else
            {
                refer = [response valueForKey:@"response"];
            }
            if ([refer count] > 0)
            {
                NSMutableArray *webRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    MeModel *me = [MeModel getPlaceByResponse:dictionary];
                    [webRefer addObject:me];
                    
                }
                [self.meDetails.meDetails setValue:webRefer forKey:kMeWebRefer];
                            }

        }else
        {
            
        }
    }
    [self reloadTableView];
}
- (void)getFeeds
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    NSArray *feeds = [[CoreData shareData] getFeedsWithLoginId:[[UserManager shareUserManager] number]feedsType:[NSString stringWithFormat:@"%d", self.meDetails.feedsType]];
    if ([feeds count] > 0 && self.meDetails.userType == Self)
    {
        if (  self.meDetails.feedsType == All)
        {
            NSMutableArray *all = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in feeds)
            {
                MeModel *me = [MeModel getFeedsAllByResponse:dictionary];
                [all addObject:me];
            }
            [self.meDetails.meDetails setValue:all forKey:kMeAll];
        }else if (self.meDetails.feedsType == Sent)
        {
            
            NSMutableArray *sent = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in feeds)
            {
                MeModel *me = [MeModel getFeedsSentByResponse:dictionary];
                [sent addObject:me];
                
            }
            [self.meDetails.meDetails setValue:sent forKey:kMeSent];
        }else if (  self.meDetails.feedsType == Received)
        {
            NSMutableArray *received = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in feeds)
            {
                MeModel *me = [MeModel getFeedsReceivedByResponse:dictionary];
                [received addObject:me];
            }
            
            [self.meDetails.meDetails setValue:received forKey:kMeReceived];
        }
       [self reloadTableView];
        [self hideHUD];
    }else
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
        [params setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
        [params setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];

        [params setValue:@"5" forKey:@"limit"];
        [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"before"];
        [params setValue:[NSString stringWithFormat:@"%u", self.meDetails.feedsType] forKey:@"feed"];
        [[YoReferAPI sharedAPI] getFeedsWithParams:params completionHandler:^(NSDictionary *response ,NSError *error)
         {
             [self didReceiveFeedsWithResponse:response error:error];
            
        }];
    }
}

- (void)didReceiveFeedsWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else{
        if ([[resonse objectForKey:@"response"] count] > 0)
        {
            NSArray *feeds;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setFeedsWithLoginId:[[UserManager shareUserManager] number] response:resonse feedsType:[NSString stringWithFormat:@"%d",self.meDetails.feedsType]];
                feeds = [[CoreData shareData] getFeedsWithLoginId:[[UserManager shareUserManager] number]feedsType:[NSString stringWithFormat:@"%d", self.meDetails.feedsType]];
                
            }else
            {
                feeds = [resonse objectForKey:@"response"];
                
            }
            if ([feeds count] > 0)
            {
                if (self.meDetails.feedsType == All)
                {
                    NSMutableArray *all = [[NSMutableArray alloc]init];
                    for (NSDictionary *dictionary in feeds)
                    {
                        MeModel *me = [MeModel getFeedsAllByResponse:dictionary];
                        [all addObject:me];
                        
                    }
                    [self.meDetails.meDetails setValue:all forKey:kMeAll];
                    
                }else if (self.meDetails.feedsType == Sent)
                {
                    NSMutableArray *sent = [[NSMutableArray alloc]init];
                    for (NSDictionary *dictionary in feeds)
                    {
                        MeModel *me = [MeModel getFeedsSentByResponse:dictionary];
                        [sent addObject:me];
                        
                    }
                    [self.meDetails.meDetails setValue:sent forKey:kMeSent];
                }else if (self.meDetails.feedsType == Received)
                {
                    NSMutableArray *received = [[NSMutableArray alloc]init];
                    for (NSDictionary *dictionary in feeds)
                    {
                        MeModel *me = [MeModel getFeedsReceivedByResponse:dictionary];
                        [received addObject:me];
                    }
                    [self.meDetails.meDetails setValue:received forKey:kMeReceived];
                }
            }
 
        }else
        {
            
        }
    }
    [self reloadTableView];
}

- (void)didReceiveNextFeedsWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else{
        
        if ([[resonse objectForKey:@"response"] count] > 0)
        {
            NSArray *feeds;
            feeds = [resonse objectForKey:@"response"];
            if ([feeds count] > 0)
            {
                if (self.meDetails.feedsType == All)
                {
                    NSMutableArray *all = [NSMutableArray arrayWithArray:[self.meDetails.meDetails objectForKey:kMeAll]];
                    for (NSDictionary *dictionary in feeds)
                    {
                        
                        MeModel *me = [MeModel getFeedsAllByResponse:dictionary];
                        [all addObject:me];
                        
                    }
                    [self.meDetails.meDetails setValue:all forKey:kMeAll];
                }else if (self.meDetails.feedsType == Sent)
                {
                    NSMutableArray *sent = [NSMutableArray arrayWithArray:[self.meDetails.meDetails objectForKey:kMeSent]];
                    for (NSDictionary *dictionary in feeds)
                    {
                        MeModel *me = [MeModel getFeedsSentByResponse:dictionary];
                        [sent addObject:me];
                        
                    }
                    [self.meDetails.meDetails setValue:sent forKey:kMeSent];
                }else if (self.meDetails.feedsType == Received)
                {
                    NSMutableArray *received = [NSMutableArray arrayWithArray:[self.meDetails.meDetails objectForKey:kMeSent]];
                    for (NSDictionary *dictionary in feeds)
                    {
                        MeModel *me = [MeModel getFeedsReceivedByResponse:dictionary];
                        [received addObject:me];
                    }
                    [self.meDetails.meDetails setValue:received forKey:kMeReceived];
                    
                }
                [self reloadTableView];
            }
        }
        
    }
}


- (void)getFriend
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    NSArray *friendsDetail = [[CoreData shareData] getFriendsWithLoginId:[[UserManager shareUserManager] number]];
    if ([friendsDetail count] > 0 && self.meDetails.userType == Self)
    {
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:friendsDetail];
        friendsDetail = [orderedSet array];
        NSMutableArray *nonGuestUser = [[NSMutableArray alloc]init];
        [friendsDetail enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop)
         {
             if (obj != [NSNull null]) {
                 BOOL isGuest = [[obj valueForKey:@"guest"] boolValue];
                 if (!isGuest)
                 {
                     [nonGuestUser addObject:obj];
                 }

             }
             
         }];

        if ([nonGuestUser count] > 0)
        {
            NSMutableArray *friends  =[[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in nonGuestUser)
            {
                MeModel *me = [MeModel getFriendsByResponse:dictionary];
                [friends addObject:me];
                
            }
            [self.meDetails.meDetails setValue:friends forKey:kMeFriends];
            [self reloadTableView];
            [self hideHUD];
        }
    }else
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:[self.meDetails.userDetail objectForKey:@"number"] forKey:@"number"];
        [params setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];

        [[YoReferAPI sharedAPI] getFriendwithParam:params completionHandler:^(NSDictionary *response ,NSError *error)
        {
            [self didReceiveFriendsWithResponse:response error:error];
            
        }];
    }
}

- (void)didReceiveFriendsWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        if ([[resonse objectForKey:@"response"] count] > 0)
        {
            NSArray *array ;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setFriendsWithLoginId:[[UserManager shareUserManager] number] response:resonse];
                array = [[CoreData shareData] getFriendsWithLoginId:[[UserManager shareUserManager] number]];
            }else
            {
                array = [resonse objectForKey:@"response"];
                
            }
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:array];
            array = [orderedSet array];
            NSMutableArray *nonGuestUser = [[NSMutableArray alloc]init];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop)
             {
                 BOOL isGuest = [[obj valueForKey:@"guest"] boolValue];
                 if (!isGuest)
                 {
                     [nonGuestUser addObject:obj];
                 }
             }];
            if ([nonGuestUser count] > 0)
            {
                NSMutableArray *friends  =[[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in nonGuestUser)
                {
                    MeModel *me = [MeModel getFriendsByResponse:dictionary];
                    [friends addObject:me];
                }
                [self.meDetails.meDetails setValue:friends forKey:kMeFriends];
            }
   
        }else
        {
            
        }
    }
     [self reloadTableView];
}


- (void)getAsk
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    NSArray *asks = [[CoreData shareData] getQueriesWithLoginId:[[UserManager shareUserManager] number]];
    if ([asks count] > 0 && self.meDetails.userType == Self)
        {
            NSMutableArray *ask = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in asks)
            {
                MeModel *me = [MeModel getAskByResponse:dictionary];
                [ask addObject:me];
                
            }
            [self.meDetails.meDetails setValue:ask forKey:kMeAsk];
            [self reloadTableView];
            [self hideHUD];
        }else
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
            [params setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
            [params setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];

            [params setValue:@"5" forKey:@"limit"];
            [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"before"];
            [[YoReferAPI sharedAPI] getAskWithParam:params completionHandler:^(NSDictionary *response ,NSError *error){
                
                [self didReceiveAskWithResponse:response error:error];
                
            }];
        }
}

- (void)didReceiveAskWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
        
    }else
    {
        if ([[resonse objectForKey:@"response"] count] > 0)
        {
            NSArray *asks ;
            if (self.meDetails.userType == Self)
            {
                [[CoreData shareData] setQueriesWithLoginId:[[UserManager shareUserManager] number] response:resonse];
                asks = [[CoreData shareData] getQueriesWithLoginId:[[UserManager shareUserManager] number]];
            }else
            {
                asks = [resonse objectForKey:@"response"];
            }
            
            if ([asks count] > 0)
            {
                NSMutableArray *ask = [[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in asks)
                {
                    MeModel *me = [MeModel getAskByResponse:dictionary];
                    [ask addObject:me];
                }
                [self.meDetails.meDetails setValue:ask forKey:kMeAsk];
                [self hideHUD];
                
            }
        }else
        {
        }
    }
    [self reloadTableView];
}


- (void)didRecevieNextAskWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        NSMutableArray *askArray = [NSMutableArray arrayWithArray:[self.meDetails.meDetails objectForKey:kMeAsk]];
        for (NSDictionary *dictionary in [response objectForKey:@"response"])
        {
            MeModel *home = [MeModel getAskByResponse:dictionary];
            [askArray addObject:home];
            
        }
        [self.meDetails.meDetails setValue:askArray forKey:kMeAsk];
        [self reloadTableView];
    }
}

- (void)updateProfilePage
{
    UIView *view = [self.view viewWithTag:kMeHeaderViewTag];
    NSArray *array = [view subviews];
    for (int i = 0; i < [array count]; i++)
    {
        if ([[array objectAtIndex:i] isKindOfClass:[UIImageView class]])
        {
            UIImageView *imageView = (UIImageView *)[array objectAtIndex:i];
            NSArray *imageArray = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
            if ([imageArray count] > 1)
            {
                NSString *imageName = [imageArray objectAtIndex:[array count]-1];
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                }else
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[UserManager shareUserManager] dp]] imageView:imageView];
                }
            }
        }
    }
}

#pragma mark  - TableView datasource and Delegate
-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    CGFloat tableViewHeight = 254.0;
    
    self.searchBar.frame = CGRectMake(frame.origin.x+15, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+30, frame.size.width-30, 45);
    
    self.tableView.frame = CGRectMake(frame.origin.x, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+60, frame.size.width, frame.size.height - tableViewHeight);
    
    self.viewBg.frame = CGRectMake(frame.origin.x, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+30, frame.size.width, 50);
    
    [self.view layoutIfNeeded];
    
}
- (CGFloat)setMeTableViewHeightWithDetails:(MeType)details
{
    CGFloat height;
    switch (details) {
        case Refers:
            height = kMeTableViewHeight;
            break;
        case Asks:
            height = kMeTableViewHeight;
            break;
        case Feeds:
            height = kMeTableViewHeight;
            break;
        case Friends:
            height = kMeTableViewHeight;
            break;
        default:
            break;
    }
    return height;
}

- (NSInteger )getReferCountWithMeType:(categories)categories
{
    NSInteger count = 0;
    
    switch (categories) {
        case Places:
            if (_isSearch == YES)
                count = [[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] count];
            else
                count = [[self.meDetails.meDetails objectForKey:kMePlaceRefer] count];
            break;
            /*
        case SearchAll:
            count = [[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] count];
            break;
             */
        case Product:
            if (_isSearch == YES)
                count = [[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] count];
            else
                count = [[self.meDetails.meDetails objectForKey:kMeProductRefer] count];
            break;
        case Services:
            if (_isSearch == YES)
                count = [[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] count];
            else
                count = [[self.meDetails.meDetails objectForKey:kMeServiceRefer] count];
            break;
        case Web:
            if (_isSearch == YES)
                count = [[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] count];
            else
                count = [[self.meDetails.meDetails objectForKey:kMeWebRefer] count];
            break;
        default:
            break;
    }
    
    return count;
}

- (NSInteger)getQueriesCount
{
    return [[self.meDetails.meDetails objectForKey:kMeAsk] count];
}

- (NSInteger)getFeedsCountWithFeedsType:(FeedsType)feedsTyps
{
    NSInteger count = 0;
    switch (feedsTyps) {
        case All:
            count = [[self.meDetails.meDetails objectForKey:kMeAll] count];
            break;
        case Sent:
            count = [[self.meDetails.meDetails objectForKey:kMeSent] count];
            break;
        case Received:
            count = [[self.meDetails.meDetails objectForKey:kMeReceived] count];
            break;
        default:
            break;
    }
    return count;
}


- (NSInteger)getFreiendsCount
{
    return [[self.meDetails.meDetails objectForKey:kMeFriends] count];
}

- (NSInteger)getMeCountWithMeType:(MeType)meType
{
    NSInteger count = 0;
    switch (meType)
    {
        case Refers:
            count = [self getReferCountWithMeType: self.meDetails.categories];
            break;
        case Asks:
            count = [self getQueriesCount];
            break;
        case Feeds:
            count = [self getFeedsCountWithFeedsType: self.meDetails.feedsType];
            break;
        case Friends:
            count = [self getFreiendsCount];
            break;
        default:
            break;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getMeCountWithMeType: self.meDetails.meType];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.meDetails.meType == Asks)
    {
        return 185.0;
    }else if ( self.meDetails.meType == Friends)
    {
        return 50.0;
    }else if ( self.meDetails.meType == Feeds)
    {
        return 419.0;
    }
    return 130.0;
}

- (MeTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    if (cell == nil)
    {
        cell = [self getMeTableViewCellWithMeType: self.meDetails.meType indexPath:indexPath];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    return cell;
}
- (MeTableViewCell *)getMeTableViewCellWithMeType:(MeType)meType indexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch (meType) {
        case Refers:
            cell = [self getReferTableViewCellWithCategories: self.meDetails.categories indexPath:indexPath];
            break;
        case Asks:
            cell = [self getQueriesTableViewCellIndexPath:indexPath];
            break;
        case Feeds:
            cell = [self getFeedsTableViewCellWithFeedsType: self.meDetails.feedsType indexPath:indexPath];
            break;
        case Friends:
            cell = [self getFriendsTableViewCellIndexPath:indexPath];
            break;
        default:
            break;
    }
    return cell;
    
}
- (MeTableViewCell *)getReferTableViewCellWithCategories:(categories)categories indexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch (categories)
    {
        case Places:
            if (_isSearch == YES)
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] meType:Refers];
            else
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMePlaceRefer] meType:Refers];
            break;
            /*
        case SearchAll:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] meType:Refers];
            break;
            */
        case Product:
            if (_isSearch == YES)
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] meType:Refers];
            else
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeProductRefer] meType:Refers];
            break;
        case Services:
            if (_isSearch == YES)
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] meType:Refers];
            else
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeServiceRefer] meType:Refers];
            break;
        case Web:
            if (_isSearch == YES)
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] meType:Refers];
            else
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeWebRefer] meType:Refers];
            break;

        default:
            break;
    }
    return cell;
}

- (MeTableViewCell *)getQueriesTableViewCellIndexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch ( self.meDetails.meType)
    {
        case Asks:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAsk] meType:Asks];
            break;
        default:
            break;
    }
    return cell;
}


- (MeTableViewCell *)getFeedsTableViewCellWithFeedsType:(FeedsType)feedsType indexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch (feedsType)
    {
        case All:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeAll] meType:Feeds];
            break;
        case Sent:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeSent] meType:Feeds];
            break;
        case Received:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeReceived] meType:Feeds];
            break;
        default:
            break;
    }
    return cell;
}


- (MeTableViewCell *)getFriendsTableViewCellIndexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch ( self.meDetails.meType)
    {
        case Friends:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.meDetails.meDetails objectForKey:kMeFriends] meType:Friends];
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.meDetails.meDetails objectForKey:kMeAsk ] count] > 0 && [[self.meDetails.meDetails objectForKey:kMeAsk ] count] == (indexPath.row+1) && self.meDetails.meType == Asks)
    {
        
        if (_isSearch == NO) {
            
            MeModel *meAsk =(MeModel *)[[self.meDetails.meDetails objectForKey:kMeAsk ] objectAtIndex:[[self.meDetails.meDetails objectForKey:kMeAsk ] count] -1] ;
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
            [params setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
            [params setValue:[self.meDetails.userDetail objectForKey:kEmail] forKey:kEmail];
            [params setValue:@"5" forKey:@"limit"];
            [params setValue:meAsk.askedAt forKey:@"before"];
            [[YoReferAPI sharedAPI] getAskWithParam:params completionHandler:^(NSDictionary *response ,NSError *error)
             {
                 [self didRecevieNextAskWithResponse:response error:error];
                 
             }];
        }
        
    }else  if (self.meDetails.meType == Feeds)
    {
        if (_isSearch == NO) {
            
            if (self.meDetails.feedsType == All && [[self.meDetails.meDetails objectForKey:kMeAll ] count] > 0 && [[self.meDetails.meDetails objectForKey:kMeAll ] count] == (indexPath.row+1))
            {
                MeModel *meAll =(MeModel *)[[self.meDetails.meDetails objectForKey:kMeAll ] objectAtIndex:[[self.meDetails.meDetails objectForKey:kMeAll ] count] -1];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
                [params setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
                [params setValue:@"5" forKey:@"limit"];
                [params setValue:meAll.referredAt forKey:@"before"];
                [params setValue:[NSString stringWithFormat:@"%u", self.meDetails.feedsType] forKey:@"feed"];
                [[YoReferAPI sharedAPI] getFeedsWithParams:params completionHandler:^(NSDictionary *response ,NSError *error){
                    
                    [self didReceiveNextFeedsWithResponse:response error:error];
                    
                }];
                
            }else  if (self.meDetails.feedsType == Sent && [[self.meDetails.meDetails objectForKey:kMeSent ] count] > 0 && [[self.meDetails.meDetails objectForKey:kMeSent ] count] == (indexPath.row+1))
            {
                MeModel *meSent =(MeModel *)[[self.meDetails.meDetails objectForKey:kMeSent ] objectAtIndex:[[self.meDetails.meDetails objectForKey:kMeSent ] count] -1];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
                [params setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
                [params setValue:@"5" forKey:@"limit"];
                [params setValue:meSent.referredAt forKey:@"before"];
                [params setValue:[NSString stringWithFormat:@"%u", self.meDetails.feedsType] forKey:@"feed"];
                [[YoReferAPI sharedAPI] getFeedsWithParams:params completionHandler:^(NSDictionary *response ,NSError *error)
                 {
                     [self didReceiveNextFeedsWithResponse:response error:error];
                     
                 }];
            }else  if (self.meDetails.feedsType == Received && [[self.meDetails.meDetails objectForKey:kMeReceived ] count] > 0 && [[self.meDetails.meDetails objectForKey:kMeReceived ] count] == (indexPath.row+1))
            {
                MeModel *received =(MeModel *)[[self.meDetails.meDetails objectForKey:kMeReceived ] objectAtIndex:[[self.meDetails.meDetails objectForKey:kMeReceived ] count] -1];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
                [params setValue:[self.meDetails.userDetail objectForKey:kNumber] forKey:kNumber];
                [params setValue:@"5" forKey:@"limit"];
                [params setValue:received.referredAt forKey:@"before"];
                [params setValue:[NSString stringWithFormat:@"%u", self.meDetails.feedsType] forKey:@"feed"];
                [[YoReferAPI sharedAPI] getFeedsWithParams:params completionHandler:^(NSDictionary *response ,NSError *error)
                 {
                     [self didReceiveNextFeedsWithResponse:response error:error];
                     
                 }];
                
            }
        }
    }
}

#pragma mark - Action Sheet
- (void)profileTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UIActionSheet *popup = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Profile Picture", @"") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upload new photo", nil];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        [[YoReferMedia shareMedia]setMediaWithDelegate:self title:@"Select Picture"];
        self.meDetails.isUpdateProfilePicture = YES;
        break;
            default:
        break;
    }
}

#pragma mark - Button delegate
- (IBAction)pointsButtonTapped:(id)sender
{
    UIView *profileView = (UIView *)[self.view viewWithTag:700];
    CGRect newProfile =  [(UIView *)[self.view viewWithTag:700] frame ];
    if(profileView.frame.origin.x == 160.0)
    {
        newProfile.origin.x = self.view.frame.size.width;
        [UIView animateWithDuration:1.0 animations:^(void){
            profileView.frame = newProfile;
            
        }];
    }
}

- (IBAction)closeBtnTapped:(id)sender
{
    [(UIView *)[self.view viewWithTag:80000] removeFromSuperview];
}

#pragma mark - Protocol

- (void)getProfilePicture:(NSMutableDictionary *)profilePicture
{
    if (self.meDetails.isUpdateProfilePicture)
    {
        self.meDetails.isUpdateProfilePicture = NO;
    }else
    {
        self.meDetails.isUpdateProfilePicture = NO;
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
        [dictionary setValue:category.categoryID forKey:kCategoryid];
        [dictionary setValue:[profilePicture objectForKey:kImage] forKey:kReferimage];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refertypemedia"];
        [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:kCity];
        [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"searchtext"];
        [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kLocation];
        [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
        [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
        [dictionary setValue:kPlace forKey:kCategorytype];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
        ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:nil];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}

- (void)getFriendProfileWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.meDetails.userType == Guset)
    {
        return;
    }
    MeModel *me  = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeFriends] objectAtIndex:indexPath.row];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];

    BOOL isGuest = [me.guest boolValue];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.refers] forKey:kFeedsCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.askCount ] forKey:kAskCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.entityReferCount] forKey:kReferCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.connections ] forKey:kFriendsCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.pointsEarned ] forKey:kPointsEarned];
    [userDetail setValue:me.dp forKey:@"friendsDp"];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.pointsBurnt ] forKey:kPointsBurnt];
    [userDetail setValue:[NSString stringWithFormat:@"%@",me.number] forKey:kNumber];
    [userDetail setValue:me.name  forKey:kName];
    [userDetail setValue:me.from   forKey:kFrom];
    [userDetail setValue:me.toUsers   forKey:kToUser];
    if (!isGuest)
    {
        MeViewController *vctr = [[MeViewController alloc]initWithUser:@"Guest" userDetail:userDetail];
        [self.navigationController pushViewController:vctr animated:YES];
        
    }
}

- (BOOL)getUserDetailWithIndexPath:(NSIndexPath *)indexPath userType:(NSUInteger )usetType detail:(NSMutableDictionary **)detail
{
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    MeModel * home ;
    BOOL isGuest = NO;
    if (self.meDetails.meType == Feeds)
    {
        if (self.meDetails.feedsType == All)
            home = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAll] objectAtIndex:indexPath.row];
        else if (self.meDetails.feedsType == Sent)
            home = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeSent] objectAtIndex:indexPath.row];
        else if (self.meDetails.feedsType == Received)
            home = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeReceived] objectAtIndex:indexPath.row];
        if (usetType ==0)
        {
            isGuest = [[home.from objectForKey:kGuest] boolValue];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:kRefers]] forKey:kReferCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"askCount"]] forKey:kAskCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"entityReferCount"]] forKey:kFeedsCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:kConnections]] forKey:kFriendsCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:kNumber]] forKey:kNumber];
            [userDetail setValue:[home.from objectForKey:kName] forKey:kName];
            [userDetail setValue:home.from   forKey:kFrom];
            [userDetail setValue:home.toUsers   forKey:kToUser];
        }else if (usetType ==1)
        {
            NSMutableArray *refreeUser = [[NSMutableArray alloc]init];
            for ( int i =0; i < [home.toUsers count]; i++)
            {
                if([[[home.toUsers objectAtIndex:i]objectForKey:kGuest] boolValue])
                {
                    
                }else
                {
                    [refreeUser addObject:[home.toUsers objectAtIndex:i]];
                }
                
            }
        if ([refreeUser count] > 0)
            {
                if (!self.meDetails.rerefreeUser)
                   self.meDetails.rerefreeUser = [[NSMutableArray alloc]init];
                
                self.meDetails.rerefreeUser = refreeUser;
                
                [self referListWithDetail:refreeUser];
                
            }
        }
        if (isGuest)
            return NO;
    }else if (self.meDetails.meType == Asks)
    {
        home = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAsk] objectAtIndex:indexPath.row];
        isGuest = [[home.user objectForKey:kGuest] boolValue];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:kRefers]] forKey:kReferCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"askCount"]] forKey:kAskCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"entityReferCount"]] forKey:kFeedsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:kConnections]] forKey:kFriendsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:kNumber]] forKey:kNumber];
        [userDetail setValue:[home.user objectForKey:kName] forKey:kName];
        [userDetail setValue:home.from   forKey:kFrom];
        [userDetail setValue:home.user   forKey:kUser];
        if (isGuest)
            return NO;
    }
    *detail = userDetail;
    return YES;
}
- (void)getReferUserWithDetail:(NSDictionary *)user
{
    [(UIView *)[self.view viewWithTag:80000] removeFromSuperview];
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:kNumber]] forKey:kNumber];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:kRefers]] forKey:kFeedsCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"askCount"]] forKey:kAskCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"entityReferCount"]] forKey:kReferCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"connections"]] forKey:kFriendsCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
    [userDetail setValue:[NSNumber numberWithBool:YES] forKey:kToUser];
    [userDetail setValue:[user objectForKey:kName] forKey:kName];
    [userDetail setValue:[[NSArray alloc] initWithObjects:user, nil]   forKey:kToUser];
        MeViewController *vctr = [[MeViewController alloc]initWithUser:@"Guest" userDetail:userDetail];
        [self.navigationController pushViewController:vctr animated:YES];
}

- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictionary = nil;
    if ([self getUserDetailWithIndexPath:indexPath userType:0 detail:&dictionary])
    {
        MeViewController *vctr = [[MeViewController alloc]initWithUser:@"Guest" userDetail:dictionary];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}
- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath
{
     NSMutableDictionary *dictionary = nil;
    
    [self getUserDetailWithIndexPath:indexPath userType:1 detail:&dictionary];
    
}

- (void)responseEntityPageWithDetails:(NSDictionary *)details
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    [response setValue:[[details valueForKey:kEntity] valueForKey:kName] forKey:kName];
    [response setValue:[[details valueForKey:kEntity] valueForKey:kCategory] forKey:kCategory];
    [response setValue:[[details valueForKey:kEntity] valueForKey:@"referCount"] forKey:kReferCount];
    [response setValue:[[details valueForKey:kEntity] valueForKey:@"mediaCount"] forKey:kMediaCount];
    [response setValue:[[details valueForKey:kEntity] valueForKey:@"mediaLinks"] forKey:kMediaLinks];
    [response setValue:[details valueForKey:@"entityId"] forKey:kEntityId];
    [response setValue:[details valueForKey:@"note"] forKey:kMessage];
    [response setValue:[details valueForKey:kType] forKey:kType];
    [response setValue:[details valueForKey:kEntity] forKey:kEntity];
    [response setValue:[details valueForKey:@"mediaId"]  forKey:kMediaId];
    if ([[details valueForKey:kType]  isEqualToString:kProduct])
    {
        [response setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] forKey:kLocation];
        [response setValue:[[[[details valueForKey:kEntity]objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[[[details valueForKey:kEntity]objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
    }else
    {
        [response setValue:[[details valueForKey:kEntity] objectForKey:kPosition] forKey:kLocation];
        [response setValue:[[details valueForKey:kEntity]objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[details valueForKey:kEntity] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[details valueForKey:kEntity] objectForKey:kWebSite] forKey:kWeb];
    }
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:response];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)responseReferPageWithDetails:(NSDictionary *)details
{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[details valueForKey:@"mediaId"] forKey:kReferimage];
    [dictionary setValue:[details valueForKey:kType] forKey:kCategorytype];
    [dictionary setValue:[details valueForKey:@"entityName"] forKey:kName];
    [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kCategory] forKey:kCategory];
    [dictionary setValue:[details valueForKey:@"note"] forKey:kMessage];
    [dictionary setValue:[[details valueForKey:kEntity] objectForKey:@"entityId"] forKey:kEntityId];
    if ([[dictionary valueForKey:kType]  isEqualToString:kProduct])
    {
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
        [dictionary setValue:[[[[details valueForKey:kEntity]objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocation];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWebSite];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCity] forKey:kCity];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCity] forKey:@"searchtext"];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCity] forKey:kFromWhere];
        if ([[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] count] > 0)
        {
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
        }
    }else
    {
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kCity] forKey:kCity];
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kCity] forKey:@"searchtext"];
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kLocality] forKey:kLocation];
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[[details valueForKey:@"entity"] objectForKey:kWebSite] forKey:kWebSite];
        if ([[details valueForKey:kLocation] count] > 0)
        {
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kLocation] objectAtIndex:0]] forKey:kLongitude];
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kLocation] objectAtIndex:1]] forKey:kLatitude];
        }
    }
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)responseMapPageWithDetails:(NSDictionary *)details
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[[details valueForKey:kEntity]  objectForKey:kEntityId] forKey:@"entityid"];
    [dict setValue:[[details valueForKey:kEntity] valueForKey:@"referCount"] forKey:kReferCount];
    [dict setValue:[[details valueForKey:kEntity] valueForKey:@"mediaCount"] forKey:@"mediaCount"];
    [dict setValue:[[details valueForKey:kEntity] valueForKey:kName] forKey:kName];
    [dict setValue:[details valueForKey:@"note"] forKey:kMessage];
    [dict setValue:[details valueForKey:kType] forKey:kType];
    if ([[details valueForKey:kType] isEqualToString:kProduct])
    {
        [dict setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude
         ];
        [dict setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
        [dict setValue:[details valueForKey:@"mediaId"] forKey:kImage];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] valueForKey:kCity] forKey:kCity];
        [dict setValue:[[[[details valueForKey:@"entity"]objectForKey:@"purchasedFrom"] objectForKey:kDetail] valueForKey:kLocality] forKey:kLocality];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] valueForKey:kPhone] forKey:kPhone];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCategory] forKey:kCategory];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCity] forKey:kFromWhere];
    }else
    {
        [dict setValue:[[details valueForKey:kLocation] objectAtIndex:0] forKey:kLongitude];
        [dict setValue:[[details valueForKey:kLocation] objectAtIndex:1] forKey:kLatitude];
        [dict setValue:[details valueForKey:@"mediaId"] forKey:kImage];
        [dict setValue:[[details valueForKey:kEntity]  valueForKey:kLocality] forKey:kLocality];
        [dict setValue:[[details valueForKey:kEntity]  valueForKey:kCity] forKey:kCity];
        [dict setValue:[[details valueForKey:kEntity]  valueForKey:kPhone] forKey:kPhone];
        [dict setValue:[[details valueForKey:kEntity] objectForKey:kWebSite] forKey:kWeb];
        [dict setValue:[[details valueForKey:kEntity]   objectForKey:kCategory] forKey:kCategory];
        
    }
    NSMutableArray *mapArray = [[NSMutableArray alloc]initWithObjects:dict, nil];
    MapViewController *vctr=[[MapViewController alloc]initWithResponse:mapArray type:@"Others" isCurrentOffers:NO];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)responseSelfPageWithDetails:(NSDictionary *)details userType:(NSInteger)userType
{
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc]init];
    BOOL isGuest;
    if (userType ==0)
    {
        isGuest = [[[details valueForKey:kFromWhere] objectForKey:kGuest] boolValue];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:kRefers]] forKey:kFeedsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:@"askCount"]] forKey:kAskCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom]objectForKey:@"entityReferCount"]] forKey:kReferCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom]objectForKey:kConnections]] forKey:kFriendsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:kNumber]] forKey:kNumber];
        [userDetail setValue:[[details valueForKey:kFrom] objectForKey:kName] forKey:kName];
        [userDetail setValue:[details valueForKey:kFrom]   forKey:kFrom];
        [userDetail setValue:[details valueForKey:@"toUser"]   forKey:kToUser];
    }else if (userType ==1)
    {
        NSMutableArray *refreeUser = [[NSMutableArray alloc]init];
        for ( int i =0; i < [[details valueForKey:@"toUsers"] count]; i++)
        {
            if([[[[details valueForKey:@"toUsers"] objectAtIndex:i]objectForKey:kGuest] boolValue])
            {
                
            }else
            {
                [refreeUser addObject:[[details valueForKey:@"toUsers"] objectAtIndex:i]];
            }
            
        }
        if ([refreeUser count] > 0)
        {
            [self referListWithDetail:refreeUser];
            
        }
        
    }
    if (isGuest || userType == 1)
    {
        
    }else
    {
        MeViewController *vctr = [[MeViewController alloc]initWithUser:@"Guest" userDetail:userDetail];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}

- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    NSDictionary *categoryList = [self.meDetails.referals objectAtIndex:indexPath.row];
    [response setValue:[categoryList objectForKey:kName] forKey:kName];
    [response setValue:[categoryList objectForKey:kCategory] forKey:kCategory];
    [response setValue:[[categoryList valueForKey:kEntity] objectForKey:@"referCount"] forKey:kReferCount];
    [response setValue:[[categoryList valueForKey:kEntity] objectForKey:@"mediaCount"] forKey:kMediaCount];
    [response setValue:[[categoryList valueForKey:kEntity] objectForKey:@"mediaLinks"] forKey:kMediaLinks];
    [response setValue:[categoryList objectForKey:kEntityId] forKey:@"entityid"];
    [response setValue:[categoryList objectForKey:kType] forKey:kType];
    [response setValue:[categoryList objectForKey:kEntity] forKey:kEntity];
    [response setValue:[categoryList valueForKey:@"mediaId"] forKey:kMediaId];
    if ([[categoryList objectForKey:kType]  isEqualToString:kProduct])
    {
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
    }else
    {
        [response setValue:[categoryList valueForKey:kLocation] forKey:kPosition];
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kWebSite] forKey:kWeb];
    }
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:response];
         [self.navigationController pushViewController:vctr animated:YES];
}

- (void)feedsWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [self getFeedsWithFeedsNumber:(FeedsType) self.meDetails.feedsType];
    
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithCategory:(MeModel *)[array objectAtIndex:indexPath.row]]];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)refersWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [self getReferWithCategories: self.meDetails.categories];
    
    // Here to implement Shorten Url method for Entity View Controller...
    
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithCategory:(MeModel *)[array objectAtIndex:indexPath.row]]];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (NSMutableArray *)getFeedsWithFeedsNumber:(FeedsType)feedsType
{
    NSMutableArray *array = nil;
    switch (feedsType)
    {
        case All:
            array  = [self.meDetails.meDetails objectForKey:kMeAll];
            break;
        case Sent:
            array  = [self.meDetails.meDetails objectForKey:kMeSent];
            break;
        case Received:
            array  = [self.meDetails.meDetails objectForKey:kMeReceived];
            break;
            
        default:
            break;
    }
    
    return array;
}



- (NSMutableDictionary *)getEntityDetailWithCategory:(MeModel *)category
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    [response setValue:[category.entity valueForKey:kName] forKey:kName];
    [response setValue:[category.entity valueForKey:kCategory] forKey:kCategory];
    [response setValue:[category.entity valueForKey:@"referCount"] forKey:kReferCount];
    [response setValue:[category.entity valueForKey:@"mediaCount"] forKey:kMediaCount];
    [response setValue:[category.entity valueForKey:@"mediaLinks"] forKey:kMediaLinks];
    [response setValue:category.entityId forKey:@"entityid"];
    [response setValue:category.note forKey:kMessage];
    [response setValue:category.type forKey:kType];
    [response setValue:category.entity forKey:kEntity];
    NSString *mediaId = ([category.dp isKindOfClass:[NSNull class]])?@"":([category.dp length] > 0)?category.dp:@"";
    [response setValue:mediaId forKey:@"mediaid"];
    [response setValue:category.type forKey:kType];
    if ([category.type  isEqualToString:kProduct])
    {
        [response setValue:[[[category.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] forKey:kLocation];
        [response setValue:[[[category.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[[category.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[[category.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
    }else
    {
        [response setValue:[category.entity objectForKey:kPosition] forKey:kLocation];
        [response setValue:[category.entity objectForKey:kLocality] forKey:kLocality];
        [response setValue:[category.entity objectForKey:kPhone] forKey:kPhone];
        [response setValue:[category.entity objectForKey:kWebSite] forKey:kWeb];
    }
    return  response;
}


- (NSMutableArray *)getReferWithCategories:(categories)categories
{
    NSMutableArray *array = nil;
    switch (categories)
    {
        case Places:
            if (_isSearch == YES)
                array  = [self.meDetails.meDetails objectForKey:kMeAllSearchRefer];
            else
                array  = [self.meDetails.meDetails objectForKey:kMePlaceRefer];
            break;
            /*
        case SearchAll:
            array  = [self.meDetails.meDetails objectForKey:kMeAllSearchRefer];
            break;
            */
        case Product:
            if (_isSearch == YES)
                array  = [self.meDetails.meDetails objectForKey:kMeAllSearchRefer];
            else
                array  = [self.meDetails.meDetails objectForKey:kMeProductRefer];
            break;
        case Services:
            if (_isSearch == YES)
                array  = [self.meDetails.meDetails objectForKey:kMeAllSearchRefer];
            else
                array  = [self.meDetails.meDetails objectForKey:kMeServiceRefer];
            break;
        case Web:
            if (_isSearch == YES)
                array  = [self.meDetails.meDetails objectForKey:kMeAllSearchRefer];
            else
                array  = [self.meDetails.meDetails objectForKey:kMeWebRefer];
            break;
        default:
            break;
    }
    
    return array;
    
}


- (NSMutableDictionary *)getReferDetailWithIndexPath:(NSIndexPath *)indexPath
{
    MeModel *feeds;
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    if (self.meDetails.meType == Refers)
    {
        if( self.meDetails.categories == Places)
        {
            if (_isSearch == YES)
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] objectAtIndex:indexPath.row];
            else
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMePlaceRefer] objectAtIndex:indexPath.row];
        }
        /*
        else if( self.meDetails.categories == SearchAll)
        {
            feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] objectAtIndex:indexPath.row];
        }
        */

        else if( self.meDetails.categories == Product)
        {
            if (_isSearch == YES)
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] objectAtIndex:indexPath.row];
            else
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeProductRefer] objectAtIndex:indexPath.row];
        }
        else if( self.meDetails.categories == Services)
        {
            if (_isSearch == YES)
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] objectAtIndex:indexPath.row];
            else
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeServiceRefer] objectAtIndex:indexPath.row];
        }else if( self.meDetails.categories == Web)
        {
            if (_isSearch == YES)
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAllSearchRefer] objectAtIndex:indexPath.row];
            else
                feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeWebRefer] objectAtIndex:indexPath.row];
        }
        if ([[feeds.entity objectForKey:kType] isEqualToString:kWeb])
        {
            [dictionary setValue:[feeds.entity valueForKey:kCategory] forKey:kCategory];
            [dictionary setValue:@"Weblink" forKey:kAddress];
            [dictionary setValue:feeds.note forKey:kMessage];
            [dictionary setValue:[feeds.entity valueForKey:kName] forKey:kName];
            [dictionary setValue:[feeds.entity valueForKey:kWebSite] forKey:kWebSite];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
            [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
            [dictionary setValue:[feeds.entity valueForKey:@"entityId"] forKey:kEntityId];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
        }else
        {
            [dictionary setValue:feeds.dp forKey:kReferimage];
            [dictionary setValue:feeds.type forKey:kCategorytype];
            [dictionary setValue:feeds.name forKey:kName];
            [dictionary setValue:[feeds.entity objectForKey:kCategory] forKey:kCategory];
            [dictionary setValue:feeds.note forKey:kMessage];
            if ([feeds.type  isEqualToString:kProduct])
            {
            [dictionary setValue:[[[feeds.entity valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kName] forKey:kFromWhere];
                [dictionary setValue:[feeds.entity valueForKey:kCity] forKey:kCity];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocation];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWebSite];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
                if ([[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] count] > 0)
                {
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
                }
            }else
            {
                [dictionary setValue:[feeds.entity objectForKey:kCity] forKey:kCity];
                [dictionary setValue:[feeds.entity objectForKey:kLocality] forKey:kLocation];
                [dictionary setValue:[feeds.entity objectForKey:kPhone] forKey:kPhone];
                [dictionary setValue:[feeds.entity objectForKey:kWebSite] forKey:kWebSite];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
                if ([[feeds.entity objectForKey:kPosition] count] > 0)
                {
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[[feeds.entity objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[[feeds.entity objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
                }
            }
            [dictionary setValue:[feeds.entity objectForKey:@"entityId"] forKey:kEntityId];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        }
    }else if (self.meDetails.meType == Feeds)
    {
        if (self.meDetails.feedsType == All)
            feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAll] objectAtIndex:indexPath.row];
        else if (self.meDetails.feedsType == Sent)
            feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeSent] objectAtIndex:indexPath.row];
        else if (self.meDetails.feedsType == Received)
            feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeReceived] objectAtIndex:indexPath.row];
        if ([[feeds.entity valueForKey:kType] isEqualToString:kWeb])
        {
            [dictionary setValue:[feeds.entity valueForKey:kCategory] forKey:kCategory];
            [dictionary setValue:@"Weblink" forKey:kAddress];
            [dictionary setValue:feeds.note forKey:kMessage];
            [dictionary setValue:[feeds.entity valueForKey:kName] forKey:kName];
            [dictionary setValue:[feeds.entity valueForKey:kWebSite] forKey:kWebSite];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
            [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
            [dictionary setValue:[feeds.entity valueForKey:kEntityId] forKey:kEntityId];
            
        }else
        {
            [dictionary setValue:feeds.mediaId forKey:kReferimage];
            [dictionary setValue:feeds.type forKey:kCategorytype];
            [dictionary setValue:feeds.entityName forKey:kName];
            [dictionary setValue:[feeds.entity objectForKey:kCategory] forKey:kCategory];
            [dictionary setValue:feeds.note forKey:kMeMessage];
            if ([feeds.type  isEqualToString:kProduct])
            {
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCity] forKey:kCity];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocation];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWebSite];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
                [dictionary setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] valueForKey:kDetail] valueForKey:kName] forKey:kFromWhere];
                if ([[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] count] > 0)
                {
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
                }
            }else
            {
                [dictionary setValue:[feeds.entity objectForKey:kCity] forKey:kCity];
                [dictionary setValue:[feeds.entity objectForKey:kLocality] forKey:kLocation];
                [dictionary setValue:[feeds.entity objectForKey:kPhone] forKey:kPhone];
                [dictionary setValue:[feeds.entity objectForKey:kWebSite] forKey:kWebSite];
                if ([feeds.location count] > 0)
                {
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[feeds.location objectAtIndex:0]] forKey:kLongitude];
                    [dictionary setValue:[NSString stringWithFormat:@"%@",[feeds.location objectAtIndex:1]] forKey:kLatitude];
                    
                }
            }
            [dictionary setValue:[feeds.entity objectForKey:kEntityId] forKey:kEntityId];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isentity"];
        }
    }else if (self.meDetails.meType == Asks)
    {
        NSDictionary *refer = [self.meDetails.referals objectAtIndex:indexPath.row];
        [dictionary setValue:[refer valueForKey:kType] forKey:kCategorytype];
        [dictionary setValue:[refer valueForKey:kCategory] forKey:kCategory];
        [dictionary setValue:[[refer valueForKey:kEntity] objectForKey:@"foursquareCategoryId"] forKey:@"categoryid"];
        [dictionary setValue:[[refer valueForKey:kEntity] valueForKey:kName] forKey:kName];
        [dictionary setValue:[[[refer valueForKey:@"toUsers"] objectAtIndex:0] valueForKey:kCity] forKey:kCity];
        [dictionary setValue:[[[refer valueForKey:@"toUsers"] objectAtIndex:0] valueForKey:kCity] forKey:@"searchtext"];
        [dictionary setValue:[[[refer valueForKey:@"toUsers"] objectAtIndex:0] valueForKey:kLocality] forKey:kLocation];
        if ([[refer valueForKey:kLocation] count] > 0)
        {
            [dictionary setValue:[[refer valueForKey:kLocation] objectAtIndex:1] forKey:kLatitude];
            [dictionary setValue:[[refer valueForKey:kLocation] objectAtIndex:0] forKey:kLongitude];
        }
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[[refer objectForKey:kEntity] objectForKeyedSubscript:kPhone] forKey:kPhone];
        if ( [refer valueForKey:@"mediaId"] != nil && [ [refer valueForKey:@"mediaId"] length] > 0)
            [dictionary setValue: [refer valueForKey:@"mediaId"] forKey:kReferimage];
        [dictionary setValue:[[refer valueForKey:kEntity] objectForKeyedSubscript:kWebSite] forKey:kWebSite];
        [dictionary setValue:[[refer objectForKey:kEntity]  valueForKey:kEntityId] forKey:@"kEntityId"];
    }
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    return dictionary;
}

-(NSMutableDictionary *)setReferWithCategoryList:(NSDictionary *)categoryList
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[categoryList objectForKey:kType] forKey:kCategorytype];
    [dictionary setValue:[categoryList objectForKey:kCategory] forKey:kCategory];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:@"foursquareCategoryId"] forKey:@"categoryid"];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kName] forKey:kName];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kCity] forKey:kCity];
     [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kCity] forKey:@"searchtext"];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kLocality] forKey:kLocation];
    if ([[[categoryList objectForKey:kEntity] objectForKey:kPosition] count] > 0)
    {
        [dictionary setValue:[[[categoryList objectForKey:kEntity] objectForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
        [dictionary setValue:[[[categoryList objectForKey:kEntity] objectForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
    }
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kPhone] forKey:kPhone];
    if ([categoryList objectForKey:@"mediaId"] != nil && [[categoryList objectForKey:@"mediaId"] length] > 0)
        [dictionary setValue:[categoryList objectForKey:@"mediaId"] forKey:kReferimage];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kWebSite] forKey:kWebSite];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kEntityId] forKey:kEntityId];
    return dictionary;
}

- (void)getCategoryListWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self setReferWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]] delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath
{
    MeModel *query = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAsk] objectAtIndex:indexPath.row];
    self.meDetails.referals = (NSArray *)query.referrals;
    if ([(NSArray *)query.referrals count] > 0)
    {
        NSMutableDictionary *referals = [[NSMutableDictionary alloc]init];
        NSMutableArray *referalArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in (NSArray *)query.referrals)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[dictionary objectForKey:@"mediaId"] forKey:kDp];
            [dic setValue:[[dictionary objectForKey:kEntity]objectForKey:kName] forKey:kName];
            [dic setValue:[[dictionary objectForKey:@"entity"]objectForKey:@"locality"] forKey:kLocality];
            [dic setValue:[dictionary valueForKey:kCategory] forKey:kCategory];
            NSMutableDictionary *dicCount = [[NSMutableDictionary alloc]init];
            [dicCount setValue:[[dictionary objectForKey:kEntity]objectForKey:@"referCount"] forKey:@"referCount"];
            [dic setValue:dicCount forKey:kEntity];
            [referalArray addObject:dic];
        }
        self.referResponse = [[NSArray alloc]init];
        self.referResponse = (NSArray *)query.referrals;
        [referals setValue:(NSArray *)query.referrals forKey:@"response"];
        [self rightBarBackButton];
        [[YoReferUserDefaults shareUserDefaluts] setValue:@"Hide" forKey:@"Header"];
        UIView *categoryView  = [[CategoriesView alloc] initWithViewFrame:self.view.frame categoryList:referals delegate:self isResponse:YES];
        categoryView.tag = 40000;
        [categoryView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
        [self.view addSubview:categoryView];
        categoryView.frame = CGRectMake(0.0, [self bounds].size.height - 59.0, [self bounds].size.width, [self bounds].size.height - 85.0);
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             categoryView.frame = CGRectMake(0.0,59.0, [self bounds].size.width, [self bounds].size.height - 85.0);
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)getReferalsWithIndexPath:(NSIndexPath *)indexPath
{

}
- (NSMutableDictionary *)getQueryDetailWithIndexPath:(NSIndexPath *)indexPath
{
    MeModel *query = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAsk] objectAtIndex:indexPath.row];
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:query.type forKey:kCategorytype];
    [dictionary setValue:query.entityName forKey:kName];
    [dictionary setValue:query.category forKey:kCategory];
    [dictionary setValue:@"" forKey:@""];
    [dictionary setValue:query.askId forKey:@"askId"];
    [dictionary setValue:([query.city isKindOfClass:[NSNull class]])?@"":query.city forKey:kCity];
    [dictionary setValue:([query.city isKindOfClass:[NSNull class]])?@"":query.city forKey:@"searchtext"];
    
    
    [dictionary setValue:@"" forKey:kLocation];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[query.location objectAtIndex:1]] forKey:kLatitude];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[query.location objectAtIndex:0]] forKey:kLongitude];
    [dictionary setValue:[query.user objectForKey:kNumber] forKey:kReferPhone];
    [dictionary setValue:[query.user objectForKey:kName] forKey:kReferName];
    [dictionary setValue:@"" forKey:kPhone];
    [dictionary setValue:@"" forKey:kName];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kMeReferisEntityId];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsAsk];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"contactcategory"];
    return dictionary;
}
- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self getReferDetailWithIndexPath:indexPath] delegate:nil];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)pushToQueryPageWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:(indexPath)?[self getQueryDetailWithIndexPath:indexPath]:nil delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath
{
    MeModel *feeds;
    if (self.meDetails.feedsType == All)
        feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeAll] objectAtIndex:indexPath.row];
    else if (self.meDetails.feedsType == Sent)
        feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeSent] objectAtIndex:indexPath.row];
    else if (self.meDetails.feedsType == Received)
        feeds = (MeModel *)[[self.meDetails.meDetails objectForKey:kMeReceived] objectAtIndex:indexPath.row];
    if ([[feeds.entity valueForKey:kType]isEqualToString:kWeb])
    {
        WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[feeds.entity valueForKey:kWebSite]] title:@"Web" refer:YES categoryType:@""];
        [self.navigationController pushViewController:vctr animated:YES];
        
    }else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[feeds.entity  objectForKey:kEntityId] forKey:@"entityid"];
        [dict setValue:[feeds.entity valueForKey:@"referCount"] forKey:kReferCount];
        [dict setValue:[feeds.entity valueForKey:@"mediaCount"] forKey:@"mediaCount"];
        [dict setValue:[feeds.entity objectForKey:@"mediaLinks"] forKey:kMediaLinks];
        [dict setValue:[feeds.entity valueForKey:kName] forKey:kName];
        [dict setValue:[feeds.entity valueForKey:kCategory] forKey:kCategory];
        [dict setValue:feeds.note forKey:kMessage];
        [dict setValue:feeds.mediaId forKey:kImage];
        [dict setValue:feeds.entity forKey:kEntity];
        [dict setValue:feeds.type forKey:kType];
        if ([feeds.type isEqualToString:kProduct])
        {
            [dict setValue:[NSString stringWithFormat:@"%@",[[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
            [dict setValue:[NSString stringWithFormat:@"%@",[[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
            [dict setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] valueForKey:kLocality] forKey:kLocality];
            [dict setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] valueForKey:kCity] forKey:kCity];
            [dict setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] valueForKey:kPhone] forKey:kPhone];
            [dict setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
            [dict setValue:[[[feeds.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kCategory] forKey:kCategory];
        }else
        {
            [dict setValue:[feeds.location objectAtIndex:0] forKey:kLongitude];
            [dict setValue:[feeds.location objectAtIndex:1] forKey:kLatitude];
            [dict setValue:[[[feeds.entity  valueForKey:@"mediaLinks"] objectAtIndex:0] valueForKey:@"mediaId"] forKey:kImage];
            [dict setValue:[feeds.entity  valueForKey:kLocality] forKey:kLocality];
            [dict setValue:[feeds.entity  valueForKey:kCity] forKey:kCity];
            [dict setValue:[feeds.entity  valueForKey:kPhone] forKey:kPhone];
            [dict setValue:[feeds.entity objectForKey:kWebSite] forKey:kWeb];
            [dict setValue:[feeds.entity   objectForKey:kCategory] forKey:kCategory];
        }
        NSMutableArray *mapArray = [[NSMutableArray alloc]initWithObjects:dict, nil];
        MapViewController *vctr=[[MapViewController alloc]initWithResponse:mapArray type:@"Others" isCurrentOffers:NO];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}

#pragma mark - Notification
- (void)profileUpdated:(NSNotification *)Notification
{
    [(UIView *)[self.view viewWithTag:1232] removeFromSuperview];
    [self headerView];
    self.meDetails.meType = Refers;
    [self place];
    
} 

#pragma mark - SearchBar Delegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self enableDisableCancelWithsearchBar:searchBar Button:YES];
}

- (void)enableDisableCancelWithsearchBar:(UISearchBar *)searchBar Button:(BOOL)isCancel
{
    searchBar.showsCancelButton = isCancel;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    _isSearch = YES;
    
    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
//    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
//    [self.homeDetails.homeDetails setValue:searchBar.text forKey:kHomeSearchText];
    
    [self.tableView setHidden:YES];
    
    if (self.meDetails.meType == Refers) {
        [self searchRefersWithText:searchBar.text];
    }
    else if (self.meDetails.meType == Asks) {
        [self searchAsksWithText:searchBar.text];
    }
    else if (self.meDetails.meType == Feeds) {
        [self searchFeedsWithText:searchBar.text];
    }
    else if (self.meDetails.meType == Friends) {
        [self searchFriendsWithText:searchBar.text];
    }
    
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    _isSearch = NO;

    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
    searchBar.text = @"";

    
    if (self.meDetails.meType == Refers) {
        [self searchRefersWithText:searchBar.text];
    }
    else if (self.meDetails.meType == Asks) {
        [self searchAsksWithText:searchBar.text];
    }
    else if (self.meDetails.meType == Feeds) {
        [self searchFeedsWithText:searchBar.text];
    }
    else if (self.meDetails.meType == Friends) {
        [self searchFriendsWithText:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar{
    
}

#pragma mark SearchWithText - Handler
- (void)searchRefersWithText:(NSString *)text
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [params setValue:text forKey:@"query"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"number"] forKey:@"number"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"email"] forKey:@"email"];

    
    /*
    NSString *categoryType;
    if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1000"]) {
        categoryType = @"place";
    }
    else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1001"])
    {
        categoryType = @"product";
    }
    else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1002"])
    {
        categoryType = @"service";
    }
    else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1003"])
    {
        categoryType = @"web";
    }
    
    [params setValue:categoryType forKey:@"referType"];
    */

    
//  http://54.165.84.198:8080/irefer/api/user/userEntityFeed/%2B918817569622/product?query=product

    [[YoReferAPI sharedAPI] searchRefersByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
        [self didReceiveRefersSearchResponse:response error:error];
         
     }];
    
}

- (void)searchAsksWithText:(NSString *)text
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [params setValue:text forKey:@"query"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"number"] forKey:@"number"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"email"] forKey:@"email"];


    [[YoReferAPI sharedAPI] searchAsksByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
        [self didReceiveAskSearchResponse:response error:error];
     }];
    
}


- (void)searchFeedsWithText:(NSString *)text
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:text forKey:@"query"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"number"] forKey:@"number"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"email"] forKey:@"email"];
    
    [[YoReferAPI sharedAPI] searchFeedsByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
        [self didReceiveFeedsSearchResponse:response error:error];
         
     }];
    
}


- (void)searchFriendsWithText:(NSString *)text
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:text forKey:@"query"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"number"] forKey:@"number"];
    [params setValue:[self.meDetails.userDetail objectForKey:@"email"] forKey:@"email"];


    [[YoReferAPI sharedAPI] searchFriendsByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
        [self didReceiveFriendsSearchResponse:response error:error];
         
     }];
    
}

#pragma mark - Animation Methods

-(void) animateHide
{
    CGRect frame  = [self bounds];
    CGFloat tableViewHeight = 240.0;
    
    [UIView animateWithDuration:0.2
                     animations:^{

                         self.tableView.frame = CGRectMake(frame.origin.x, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+13, frame.size.width, frame.size.height - tableViewHeight);
                         
                         [self.referOptionView setHidden:YES];
                         [self.asksOptionView setHidden:YES];
                         [self.feedsOptionView setHidden:YES];
                         [self.friendsOptionView setHidden:YES];
                         
//                         [self.segmentView setHidden:YES];
                     }];
}

-(void) animateShow
{
    CGRect frame  = [self bounds];
    CGFloat tableViewHeight = 254.0;
    
    [UIView animateWithDuration:0.2
                     animations:^{

                         self.tableView.frame = CGRectMake(frame.origin.x, [self setMeTableViewHeightWithDetails: self.meDetails.meType]+60, frame.size.width, frame.size.height - tableViewHeight);
                         
                         if (self.meDetails.meType == Refers)
                         {
                             [_referOptionView setHidden:NO];
                             [_asksOptionView setHidden:YES];
                             [_feedsOptionView setHidden:YES];
                             [_friendsOptionView setHidden:YES];
                         }
                         else if (self.meDetails.meType == Asks)
                         {
                             [_referOptionView setHidden:YES];
                             [_asksOptionView setHidden:NO];
                             [_feedsOptionView setHidden:YES];
                             [_friendsOptionView setHidden:YES];
                         }
                         else if (self.meDetails.meType == Feeds)
                         {
                             [_referOptionView setHidden:YES];
                             [_asksOptionView setHidden:YES];
                             [_feedsOptionView setHidden:NO];
                             [_friendsOptionView setHidden:YES];
                         }
                         else if (self.meDetails.meType == Friends)
                         {
                             [_referOptionView setHidden:YES];
                             [_asksOptionView setHidden:YES];
                             [_feedsOptionView setHidden:YES];
                             [_friendsOptionView setHidden:NO];
                         }

                     }];

}

#pragma mark - Receive Responce Method

- (void)didReceiveRefersSearchResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];[self.tableView setHidden:NO];
    
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeViewError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else if([[response objectForKey:@"response"] count] <=0)
    {
        /*
        alertView([[Configuration shareConfiguration] appName], @"No result found", nil, @"Ok", nil, 0);
        return;
        */
        [self hideHUD];
        
        
        
        [self.meDetails.meDetails setValue:nil forKey:kMeAllSearchRefer];
        
        [self.view layoutIfNeeded];
        [self reloadTableView];
        
        if (_isSearch == YES) {
            
            [self animateHide];
        }
        else{
            [self animateShow];
        }

        
    }else
    {
        
        if ([[response objectForKey:@"response"] count] > 0)
        {
            NSArray *refersArr ;
            
            refersArr = [response objectForKey:@"response"];

            if ([refersArr count] > 0)
            {
                NSMutableArray *referArr = [[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in refersArr)
                {
                    
                    MeModel *me = [MeModel getAllSearchRefersByResponse:dictionary];
                    [referArr addObject:me];
                    
                    /*
                    if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1000"]) {
                       
                        MeModel *me = [MeModel getPlaceByResponse:dictionary];
                        [referArr addObject:me];
                    }
                    else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1001"])
                    {
                        MeModel *me = [MeModel getProductByResponse:dictionary];
                        [referArr addObject:me];
                    }
                    else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1002"])
                    {
                        MeModel *me = [MeModel getServiceByResponse:dictionary];
                        [referArr addObject:me];
                    }
                    else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1003"])
                    {
                        MeModel *me = [MeModel getPlaceByResponse:dictionary];
                        [referArr addObject:me];
                    }
                    */
                }
                
                [self.meDetails.meDetails setValue:referArr forKey:kMeAllSearchRefer];
//                self.meDetails.categories = SearchAll;
                
                /*
                if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1000"]) {
                    
                     [self.meDetails.meDetails setValue:referArr forKey:kMePlaceRefer];
                }
                else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1001"])
                {
                     [self.meDetails.meDetails setValue:referArr forKey:kMeProductRefer];
                }
                else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1002"])
                {
                     [self.meDetails.meDetails setValue:referArr forKey:kMeServiceRefer];
                }
                else if ([[NSString stringWithFormat:@"%u", self.meDetails.categories] isEqualToString:@"1003"])
                {
                     [self.meDetails.meDetails setValue:referArr forKey:kMeWebRefer];
                }
                */
                
                [self hideHUD];
                
                
                [self.view layoutIfNeeded];
                [self reloadTableView];
                
                if (_isSearch == YES) {
                    
                    [self animateHide];
                }
                else{
                    [self animateShow];
                }

                
                @try {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                @catch (NSException *e )
                {
                    NSLog(@"bummer: %@",e);
                }
            }
        }
    }
}


- (void)didReceiveAskSearchResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];[self.tableView setHidden:NO];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeViewError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else if([[response objectForKey:@"response"] count] <=0)
    {
        /*
        alertView([[Configuration shareConfiguration] appName], @"No result found", nil, @"Ok", nil, 0);
        return;
        */
        
        [self hideHUD];
        
        if (_isSearch == YES) {
            
            [self animateHide];
        }
        else{
            [self animateShow];
        }
        
        [self.meDetails.meDetails setValue:nil forKey:kMeAsk];
        
        [self.view layoutIfNeeded];
        [self reloadTableView];

        
    }else
    {
    
        if ([[response objectForKey:@"response"] count] > 0)
        {
            NSArray *asks ;
            
            asks = [response objectForKey:@"response"];
            
            if ([asks count] > 0)
            {
                NSMutableArray *ask = [[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in asks)
                {
                    MeModel *me = [MeModel getAskByResponse:dictionary];
                    [ask addObject:me];
                }
                [self.meDetails.meDetails setValue:ask forKey:kMeAsk];
                [self hideHUD];
                
                if (_isSearch == YES) {
                    
                    [self animateHide];
                }
                else{
                    [self animateShow];
                }
                
                [self.view layoutIfNeeded];
                [self reloadTableView];

                @try {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                @catch (NSException *e )
                {
                    NSLog(@"bummer: %@",e);
                }

                
            }
        }
    }
}


- (void)didReceiveFeedsSearchResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];[self.tableView setHidden:NO];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeViewError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else if([[response objectForKey:@"response"] count] <=0)
    {
        /*
        alertView([[Configuration shareConfiguration] appName], @"No result found", nil, @"Ok", nil, 0);
        return;
        */
        
        [self hideHUD];
        
        if (_isSearch == YES) {
            
            [self animateHide];
        }
        else{
            [self animateShow];
        }
        
        [self.meDetails.meDetails setValue:nil forKey:kMeAll];
        
        [self.view layoutIfNeeded];
        [self reloadTableView];

        
    }else
    {
        
        if ([[response objectForKey:@"response"] count] > 0)
        {
            NSArray *feeds ;
            
            feeds = [response objectForKey:@"response"];
            
            if ([feeds count] > 0)
            {
                NSMutableArray *feed = [[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in feeds)
                {
                    MeModel *me = [MeModel getFeedsAllByResponse:dictionary];
                    [feed addObject:me];
                }
//                self.meDetails.meDetails = [[NSMutableDictionary alloc]init];
//                [self.meDetails.meDetails setValue:nil forKey:kMeAll];
                [self.meDetails.meDetails setValue:feed forKey:kMeAll];
                [self hideHUD];
                
                [self reloadTableView];
                
                if (_isSearch == YES) {
                    
                    [self animateHide];
                }
                else{
                    [self animateShow];
                }

                [self.view layoutIfNeeded];
                

                @try {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    
                }
                @catch (NSException *e )
                {
                    NSLog(@"bummer: %@",e);
                }
            }
        }
    }
}


- (void)didReceiveFriendsSearchResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];[self.tableView setHidden:NO];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeViewError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else if([[response objectForKey:@"response"] count] <=0)
    {
        /*
        alertView([[Configuration shareConfiguration] appName], @"No result found", nil, @"Ok", nil, 0);
        return;
        */
        
        [self hideHUD];
        
        if (_isSearch == YES) {
            
            [self animateHide];
        }
        else{
            [self animateShow];
        }
        
        [self.meDetails.meDetails setValue:nil forKey:kMeFriends];
        
        [self.view layoutIfNeeded];
        [self reloadTableView];

        
    }else
    {
        
        if ([[response objectForKey:@"response"] count] > 0)
        {
            
            NSArray *asks ;
            
            asks = [response objectForKey:@"response"];
                
            if ([asks count] > 0)
            {
                NSMutableArray *ask = [[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in asks)
                {
                    MeModel *me = [MeModel getFriendsByResponse:dictionary];
                    [ask addObject:me];
                }
                [self.meDetails.meDetails setValue:ask forKey:kMeFriends];
                [self hideHUD];
                
                if (_isSearch == YES) {
                    
                    [self animateHide];
                }
                else{
                    [self animateShow];
                }

                [self.view layoutIfNeeded];
                [self reloadTableView];

                @try {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                @catch (NSException *e )
                {
                    NSLog(@"bummer: %@",e);
                }
            }
        }
    }
}



#pragma mark - didReceiveMemoryWarning
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

@implementation MeDetail

@end

