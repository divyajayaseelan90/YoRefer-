//
//  HomeSearchViewController.m
//  YoRefer
//
//  Created by Devendra Rathore on 1/14/17.
//  Copyright © 2017 UDVI. All rights reserved.
//

#import "HomeSearchViewController.h"
#import "Constant.h"
#import "Utility.h"
#import "Carousel.h"
#import "Home.h"
#import "EntityViewController.h"
#import "QueryNowViewController.h"
#import "ReferNowViewController.h"
#import "MapViewController.h"
#import "MeViewController.h"
#import "CategoriesView.h"
#import "Users.h"
#import "WebViewController.h"
#import "LocalReferAsk.h"
#import "CategoryListViewController.h"
#import "ContactViewController.h"
#import "MapViewController.h"
#import "WebViewController.h"
#import "ReferViewController.h"
#import "QueryNowViewController.h"
#import "HomeSearchViewController.h"

static NSString *menuType;

NSUInteger      const homeSearchnumberOfSection             = 1;
CGFloat         const homeSearchsectionHeight               = 85.0;
NSInteger       const khomeSearchHeaderView                 = 50000;
NSInteger       const khomeSearchAlertTag                   = 60000;
NSUInteger      const khomeSearchLocationButtonEnableTag    = 13212;
NSUInteger      const khomeSearchLocationButtonDisableTag   = 13213;
NSUInteger      const khomeSearchBeginTag                   = 23124;
NSString    *   const khomeSearchSearchPlaceHolder          = @"Places, Products or Services";
NSString    *   const khomeSearchlocationPlaceHolder        = @"Select Location";
NSString    *   const khomeSearchHomeSearchText             = @"searchtext";
NSString    *   const khomeSearchHomeError                  = @"Unable to get carousel";
NSString    *   const khomeSearchHomeAlertMessage           = @"Yorefer would like to use your location";


NSString    *   const kHomeViewRefer                  = @"viewRefer";
NSString    *   const kHomeViewAsk                    = @"viewAsk";
NSString    *   const kHomeViewEntities               = @"viewEntities";

@interface HomeSearchDetails : NSObject

@property (nonatomic, strong)    NSMutableArray        * carousel;
@property (nonatomic, strong)    NSMutableDictionary   * homeDetails;
@property (nonatomic, readwrite) HomeSearchType                homeType;
@property (nonatomic, strong)    NSString              * locationText;
@property (nonatomic, assign)    CGFloat                 referRowHeight;

@end



@interface HomeSearchViewController ()<UISearchBarDelegate,Query,Refer,UITextFieldDelegate,NIDropDownDelegate,LocationManger,CategoryView,Users,UIAlertViewDelegate>

@property (nonatomic, strong)    HomeSearchDetails          * homeDetails;
@property (nonatomic, strong)    NIDropDown                 * nIDropDown;
@property (nonatomic, strong)    NSArray                    * referResponse;
@property (nonatomic, strong)    NSMutableDictionary        * category;
@property (strong, nonatomic)    UIView                     * dropDownView;
@property (strong, nonatomic)    UIRefreshControl           * refreshControl;
@property (nonatomic, strong)    NSTimer                    * splashTimer;

@end


#pragma mark - implementation
@implementation HomeSearchViewController

@synthesize searchBarString;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homeDetails = [[HomeSearchDetails alloc]init];
    self.homeDetails.homeDetails = [[NSMutableDictionary alloc]init];
//    self.homeDetails.referRowHeight = 0.0;

    //Header controls
    [self headerView];
    
    //Refer
    [self viewRefersTapped];
}

#pragma mark - tableview datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 0.0f;
    
    //background View
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    
    return view;

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return homeSearchnumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self setNumberOfRowInSectionWitHomeType:self.homeDetails.homeType];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self rowHeightWithIndexPath:indexPath];
}

- (NSInteger)setNumberOfRowInSectionWitHomeType:(HomeSearchType)homeType
{
    NSInteger count = 0;
    switch (homeType) {
        case viewRefer:
            count = [[self.homeDetails.homeDetails objectForKey:kHomeViewRefer] count];
            break;
        case viewAsk:
            count = [[self.homeDetails.homeDetails objectForKey:kHomeViewAsk] count];
            break;
        case viewEntity:
            count = [[self.homeDetails.homeDetails objectForKey:kHomeViewEntities] count];
            break;
        default:
            count = 3;
            break;
    }
    return   count;
}

- (CGFloat)rowHeightWithIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;

    if (self.homeDetails.homeType == viewRefer){
        height = 419.0;
    }
    if (self.homeDetails.homeType == viewAsk){
         height = 186.0;
    }
    if (self.homeDetails.homeType == viewEntity){
        height = 130.0;
    }
    
    return height;
}


-(HomeSearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeSearchTableViewCell *cell;
    
    if (cell == nil)
    {
        cell = [self setHomeCellWithHomeWithIndexPath:indexPath];
        [cell setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    }
    return cell;
    
}

- (HomeSearchTableViewCell *)setHomeCellWithHomeWithIndexPath:(NSIndexPath *)indexPath
{
    HomeSearchTableViewCell *cell;
    
    NSLog(@"%@",indexPath);
       
            if (self.homeDetails.homeType == viewEntity)
                cell = [[HomeSearchTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeViewEntities] objectAtIndex:indexPath.row] homeType:viewEntity indexPath:indexPath];
            else if (self.homeDetails.homeType == viewRefer)
                cell = [[HomeSearchTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeViewRefer] objectAtIndex:indexPath.row] homeType:viewRefer indexPath:indexPath];
            else if (self.homeDetails.homeType == viewAsk)
                cell = [[HomeSearchTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeViewAsk] objectAtIndex:indexPath.row] homeType:viewAsk indexPath:indexPath];
           
    
    return cell;
}

- (NSString *)getCellIdentifireWithHomeType:(HomeSearchType)homeType indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentification = nil;
    switch (homeType) {
        case viewRefer:
            cellIdentification = nil;//[NSString stringWithFormat:@"%d_%@",indexPath.row,kHomeReferReuseIdentifier];
            break;
        case viewAsk:
            cellIdentification =nil; //[NSString stringWithFormat:@"%d_%@",indexPath.row,kHomeAskReuseIdentifier];
            break;
        case viewEntity:
            cellIdentification = kHomeSearchAskReuseIdentifier;
            break;
        default:
            break;
    }
    return cellIdentification;
}


- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:(self.homeDetails.homeType == viewAsk)?[self getEntityDetailWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]]:[self getEntityDetailWithIndexPath:indexPath]];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (NSMutableDictionary *)getEntityDetailWithCategoryList:(NSDictionary *)categoryList
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    [response setValue:[categoryList objectForKey:kName] forKey:kName];
    [response setValue:[categoryList objectForKey:kCategory] forKey:kCategory];
    [response setValue:[[categoryList valueForKey:kEntity] objectForKey:@"referCount"] forKey:kReferCount];
    [response setValue:[[categoryList valueForKey:kEntity] objectForKey:@"mediaCount"] forKey:kMediaCount];
    [response setValue:[[categoryList valueForKey:kEntity] objectForKey:@"mediaLinks"] forKey:kMediaLinks];
    [response setValue:[categoryList objectForKey:kEntityId] forKey:@"entityid"];
    [response setValue:[categoryList objectForKey:kType] forKey:kType];
    [response setValue:[categoryList objectForKey:kEntity] forKey:kEntity];
    [response setValue:[[[categoryList valueForKey:kEntity] objectForKey:kDp] objectForKey:@"mediaId"] forKey:kMediaId];
    if ([[categoryList objectForKey:kType]  isEqualToString:kProduct])
    {
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[[[categoryList valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
    }else
    {
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kPosition] forKey:kPosition];
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[categoryList valueForKey:kEntity] objectForKey:kWebSite] forKey:kWeb];
    }
    return  response;
}

- (NSMutableDictionary *)getEntityDetailWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    Home *home = (Home *)((self.homeDetails.homeType == viewEntity)?[[self.homeDetails.homeDetails objectForKey:kHomeViewEntities] objectAtIndex:indexPath.row]:(self.homeDetails.homeType == viewRefer)?[[self.homeDetails.homeDetails objectForKey:kHomeViewRefer] objectAtIndex:indexPath.row]:[[self.homeDetails.homeDetails objectForKey:kHomeViewAsk] objectAtIndex:indexPath.row]);
    [response setValue:[home.entity valueForKey:kName] forKey:kName];
    [response setValue:[home.entity valueForKey:kCategory] forKey:kCategory];
    [response setValue:[home.entity valueForKey:@"referCount"] forKey:kReferCount];
    [response setValue:[home.entity valueForKey:@"mediaCount"] forKey:kMediaCount];
    [response setValue:[home.entity valueForKey:@"mediaLinks"] forKey:kMediaLinks];
    [response setValue:home.entityId forKey:@"entityid"];
    [response setValue:home.note forKey:kMessage];
    [response setValue:home.type forKey:kType];
    [response setValue:home.entity forKey:kEntity];
    [response setValue:home.mediaId  forKey:kMediaId];
    if ([home.type  isEqualToString:kProduct])
    {
        [response setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kLocation];
        [response setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
    }else
    {
        [response setValue:[home.entity objectForKey:kPosition] forKey:kLocation];
        [response setValue:[home.entity objectForKey:kLocality] forKey:kLocality];
        [response setValue:[home.entity objectForKey:kPhone] forKey:kPhone];
        [response setValue:[home.entity objectForKey:kWebSite] forKey:kWeb];
    }
    return  response;
}


- (void)pushSelfMePageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    NSMutableDictionary *dictionary = nil;
    if ([self getUserDetailWithIndexPath:indexPath userType:0 detail:&dictionary])
    {
        MeViewController *vctr = [[MeViewController alloc]initWithUser:@"Guest" userDetail:dictionary];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}

- (void)pushGuestMePageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    NSMutableDictionary *dictionary = nil;
    [self getUserDetailWithIndexPath:indexPath userType:1 detail:&dictionary];
}

- (BOOL)getUserDetailWithIndexPath:(NSIndexPath *)indexPath userType:(NSUInteger )usetType detail:(NSMutableDictionary **)detail
{
    NSMutableDictionary *userDetail = [NSMutableDictionary dictionaryWithCapacity:1];
    Home *home = (Home *)((self.homeDetails.homeType == viewEntity)?[[self.homeDetails.homeDetails objectForKey:kHomeViewEntities] objectAtIndex:indexPath.row]:(self.homeDetails.homeType == viewRefer)?[[self.homeDetails.homeDetails objectForKey:kHomeViewRefer] objectAtIndex:indexPath.row]:[[self.homeDetails.homeDetails objectForKey:kHomeViewAsk] objectAtIndex:indexPath.row]);
    BOOL isGuest;
    if (self.homeDetails.homeType  == viewRefer || self.homeDetails.homeType  == viewEntity)
    {
        if (usetType ==0)
        {
            isGuest = [[home.from objectForKey:kGuest] boolValue];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"refers"]] forKey:kReferCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"askCount"]] forKey:kAskCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"entityReferCount"]] forKey:kFeedsCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"connections"]] forKey:kFriendsCount];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
            [userDetail setValue:[NSString stringWithFormat:@"%@",[home.from objectForKey:@"number"]] forKey:kNumber];
            [userDetail setValue:[home.from objectForKey:kName] forKey:kName];
            [userDetail setValue:home.from   forKey:kFrom];
            [userDetail setValue:home.toUser   forKey:kToUser];
        }else if (usetType ==1)
        {
            NSMutableArray *refreeUser = [[NSMutableArray alloc]init];
            for ( int i =0; i < [home.toUser count]; i++)
            {
                if([[[home.toUser objectAtIndex:i]objectForKey:kGuest] boolValue])
                {
                    
                }else
                {
                    [refreeUser addObject:[home.toUser objectAtIndex:i]];
                }
            }
            if ([refreeUser count] > 0)
            {
                [self referListWithDetail:refreeUser];
                
            }
        }
        if (isGuest)
            return NO;
    }else if (self.homeDetails.homeType  == viewAsk)
    {
        isGuest = [[home.user objectForKey:kGuest] boolValue];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"refers"]] forKey:kReferCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"askCount"]] forKey:kAskCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"entityReferCount"]] forKey:kFeedsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"connections"]] forKey:kFriendsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[home.user objectForKey:@"number"]] forKey:kNumber];
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
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:kConnections]] forKey:kFriendsCount];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"pointsEarned"]] forKey:kPointsEarned];
    [userDetail setValue:[NSString stringWithFormat:@"%@",[user objectForKey:@"pointsBurnt"]] forKey:kPointsBurnt];
    [userDetail setValue:[NSNumber numberWithBool:YES] forKey:kToUser];
    [userDetail setValue:[user objectForKey:kName] forKey:kName];
    [userDetail setValue:[[NSArray alloc] initWithObjects:user, nil]   forKey:kToUser];
    MeViewController *vctr = [[MeViewController alloc]initWithUser:@"Guest" userDetail:userDetail];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)referListWithDetail:(NSMutableArray *)referList
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    view.tag = 80000;
    [view setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(8.0/255.0) blue:(8.0/255.0) alpha:0.8f]];
    [self.view addSubview:view];
    CGFloat height = frame.size.height - 200.0;
    CGFloat width = view.frame.size.width - 24.0;
    CGFloat yPos = roundf((view.frame.size.height- height)/2);
    CGFloat xPos = roundf((view.frame.size.width - width)/2);
    Users *addContact  = [[Users alloc]initWithViewFrame:CGRectMake(xPos, yPos, width, height) delegate:self users:referList];
    [addContact.layer setCornerRadius:5.0];
    [addContact.layer setMasksToBounds:YES];
    [view addSubview:addContact];
    width = 26.0;
    height = 26.0;
    xPos = view.frame.size.width - (width + 3.0);
    yPos = yPos - 16.0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:crossBtnImg];
    [view addSubview:imageView];
    width = 50.0;
    height = 38.0;
    xPos = view.frame.size.width - width;
    yPos = yPos - 15.0;
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [closeBtn setBackgroundColor:[UIColor clearColor]];
    [closeBtn addTarget:self action:@selector(closeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
}


- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath
{
    Home *query = (Home *)[[self.homeDetails.homeDetails objectForKey:kHomeViewAsk] objectAtIndex:indexPath.row];
    if ([query.referrals count] > 0)
    {
        NSMutableDictionary *referals = [[NSMutableDictionary alloc]init];
        [referals setValue:query.referrals forKey:@"response"];
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

- (void)responseEntityPageWithDetails:(NSDictionary *)details
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    [response setValue:[[details valueForKey:kEntity] valueForKey:kName] forKey:kName];
    [response setValue:[[details valueForKey:kEntity] valueForKey:kCategory] forKey:kCategory];
    [response setValue:[[details valueForKey:kEntity] valueForKey:@"referCount"] forKey:kReferCount];
    [response setValue:[[details valueForKey:@"entity"] valueForKey:@"mediaCount"] forKey:kMediaCount];
    [response setValue:[[details valueForKey:@"entity"] valueForKey:@"mediaLinks"] forKey:kMediaLinks];
    [response setValue:[details valueForKey:kEntityId] forKey:@"entityid"];
    [response setValue:[details valueForKey:@"note"] forKey:kMessage];
    [response setValue:[details valueForKey:kType] forKey:kType];
    [response setValue:[details valueForKey:kEntity] forKey:kEntity];
    [response setValue:[details valueForKey:@"mediaId"]  forKey:kMediaId];
    if ([[details valueForKey:@"type"]  isEqualToString:@"product"])
    {
        [response setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kLocation];
        [response setValue:[[[[details valueForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
        [response setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [response setValue:[[[[details valueForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
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
    [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kEntityId] forKey:kEntityId];
    if ([[dictionary valueForKey:kType]  isEqualToString:kProduct])
    {
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
        [dictionary setValue:[[[[details valueForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocation];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWebSite];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCity] forKey:kAddress];
        [dictionary setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCity] forKey:kFromWhere];
        if ([[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] count] > 0)
        {
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
        }
    }else
    {
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kCity] forKey:kAddress];
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kLocality] forKey:kLocation];
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[[details valueForKey:kEntity] objectForKey:kWebSite] forKey:kWebSite];
        if ([[details valueForKey:@"location"] count] > 0)
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
    [dict setValue:[[details valueForKey:kEntity] valueForKey:@"mediaCount"] forKey:kMediaCount];
    [dict setValue:[[details valueForKey:kEntity] valueForKey:kName] forKey:kName];
    [dict setValue:[details valueForKey:@"note"] forKey:kMessage];
    [dict setValue:[details valueForKey:kType] forKey:kType];
    if ([[details valueForKey:kType] isEqualToString:kProduct])
    {
        [dict setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude
         ];
        [dict setValue:[NSString stringWithFormat:@"%@",[[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
        [dict setValue:[details valueForKey:@"mediaId"] forKey:kImage];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kCity] forKey:kCity];
        [dict setValue:[[[[details valueForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kLocality] forKey:kLocality];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kPhone] forKey:kPhone];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCategory] forKey:kCategory];
        [dict setValue:[[[[details valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCity] forKey:kFromWhere];
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
        isGuest = [[[details valueForKey:kFrom] objectForKey:kGuest] boolValue];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:@"refers"]] forKey:kFeedsCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom] objectForKey:@"askCount"]] forKey:kAskCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom]objectForKey:@"entityReferCount"]] forKey:kReferCount];
        [userDetail setValue:[NSString stringWithFormat:@"%@",[[details valueForKey:kFrom]objectForKey:@"connections"]] forKey:kFriendsCount];
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

- (void)getCarouselDetailWithIndex:(NSInteger)index
{
    [self.tableView endEditing:YES];
    Carousel *carousel = (Carousel *)[self.homeDetails.carousel objectAtIndex:index];
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    [response setValue:carousel.name forKey:kName];
    [response setValue:carousel.category forKey:kCategory];
    [response setValue:carousel.locality forKey:kLocality];
    [response setValue:carousel.city forKey:kCity];
    [response setValue:@"" forKey:kPhone];
    [response setValue:carousel.website forKey:kWeb];
    [response setValue:carousel.referCount forKey:kReferCount];
    [response setValue:carousel.mediaCount forKey:kMediaCount];
    [response setValue:carousel.mediaLinks forKey:kMediaLinks];
    [response setValue:carousel.entityId forKey:@"entityid"];
    [response setValue:[carousel.dp objectForKey:@"mediaId"] forKey:kMediaId];
    [response setValue:carousel.type forKey:kType];
    [response setValue:carousel.position forKey:kLocation];
    [response setValue:[NSNumber numberWithBool:YES] forKey:@"carousel"];
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:response];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)askPost
{
    [self.homeDetails.homeDetails setValue:@"ask" forKey:@"menutype"];
    [self getAsk];
//    [self updateQueryQueryType:segment];
}

- (void)enableSegmentWithIndex:(NSInteger)index subViews:(NSArray *)subViews
{
    UILabel *refer = [subViews objectAtIndex:0];
    UILabel *ask = [subViews objectAtIndex:1];
    switch (index) {
        case 0:
            [refer setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
            [refer setTextColor:[UIColor whiteColor]];
            [ask setBackgroundColor:[UIColor clearColor]];
            [ask setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
            break;
        case 1:
            [ask setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
            [ask setTextColor:[UIColor whiteColor]];
            [refer setBackgroundColor:[UIColor clearColor]];
            [refer setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        default:
            break;
    }
}

- (void)pushToViewControllerWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            CategoryListViewController *vctr = [[CategoryListViewController alloc]init];
            [self.navigationController pushViewController:vctr animated:YES];
            break;
        }
        case 1:
        {
            ContactViewController *vctr = [[ContactViewController alloc]init];
            [self.navigationController  pushViewController:vctr animated:YES];
            break;
        }
        case 2:
        {
            [[YoReferMedia shareMedia] setMediaWithDelegate:self title:@"Select Picture"];
            break;
        }
        case 3:
        {
            MapViewController *vctr = [[MapViewController alloc]initWithResponse:nil type:@"Offers" isCurrentOffers:YES];
            [self.navigationController pushViewController:vctr animated:YES];
            break;
        }
        case 4:
        {
            WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:@"http://www.google.com"] title:@"Web" refer:YES categoryType:@""];
            [self.navigationController pushViewController:vctr animated:YES];
            break;
        }
        case 5:
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
            
            ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:nil];
            [self.navigationController pushViewController:vctr animated:YES];
            break;
        }
        case 6:
        {
            /*
            QueryNowViewController *vctr = [[QueryNowViewController alloc]initWithQueryDetail:[self setQueryDefaultValue] delegate:self];
            [self.navigationController pushViewController:vctr animated:YES];
            */
            break;
        }
            
        default:
            break;
    }
    
}



#pragma mark - Button delegate
- (IBAction)closeBtnTapped:(id)sender
{
    [(UIView *)[self.view viewWithTag:80000] removeFromSuperview];
}

- (IBAction)locationBtnTapped:(id)sender
{
    alertView(@"Location",khomeSearchHomeAlertMessage, self, @"Yes", @"No", khomeSearchAlertTag);
}

- (IBAction)addressBtnTapped:(id)sender
{
    [self.tableView endEditing:YES];
    UIButton *button = (UIButton *)sender;
    CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.view];
    [self.homeDetails.homeDetails setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    UIView *view = [self.tableView viewWithTag:khomeSearchHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    UITextField *textField = (UITextField *)[subViews objectAtIndex:1];
    if ([textField.text length] > 0 && button.tag == khomeSearchLocationButtonEnableTag)
    {
        textField.text = [textField.text substringToIndex:3];
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                button.tag = khomeSearchLocationButtonDisableTag;
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
//                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        button.tag = khomeSearchLocationButtonEnableTag;
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
        if ([[UserManager shareUserManager] getLocationService])
        {
            [(UITextField *)[subViews objectAtIndex:1] setText:[[UserManager shareUserManager] currentCity]];
            self.homeDetails.locationText = [[UserManager shareUserManager] currentCity];
            [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
        }else
        {
            [(UITextField *)[subViews objectAtIndex:1] setText:@""];
            [(UIButton *)[subViews objectAtIndex:2] setHidden:NO];
        }
        
    }
}

#pragma mark - Location Update
- (void)locationUpdate:(NSNotification *)notification
{
    UIView *view = [self.tableView viewWithTag:khomeSearchHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    if ([[UserManager shareUserManager] getLocationService])
    {
        if ([[[notification valueForKey:@"userInfo"] valueForKey:@"locationUpdated"] boolValue])
        {
            [(UITextField *)[subViews objectAtIndex:1] setText:[[UserManager shareUserManager] currentCity]];
            self.homeDetails.locationText = [[UserManager shareUserManager] currentCity];
            [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
            
        }else
        {
            [self currentLocation];
        }
    }else
    {
        [(UITextField *)[subViews objectAtIndex:1] setText:@""];
        [(UIButton *)[subViews objectAtIndex:2] setHidden:NO];
    }
    [self hideHUD];
}

- (void)updateLocation
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self locationUpdate];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
}

- (void)getLoaction:(NSDictionary *)location
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIView *view = [self.tableView viewWithTag:khomeSearchHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    if ([[UserManager shareUserManager] getLocationService])
    {
        [(UITextField *)[subViews objectAtIndex:1] setText:[location objectForKey:@"description"]];
        [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
        [(UIButton *)[subViews objectAtIndex:3] setTag:khomeSearchLocationButtonEnableTag];
    }else
    {
        [(UITextField *)[subViews objectAtIndex:1] setText:@""];
        [(UIButton *)[subViews objectAtIndex:2] setHidden:NO];
    }
    self.homeDetails.locationText = [location objectForKey:@"description"];
    [[UserManager shareUserManager] setCurrentCity:[location objectForKey:@"description"]];
    [[LocationManager shareLocationManager] getCurrentLocationAddressFromPlaceId:[location valueForKey:@"place_id"] :^(NSMutableDictionary *dictionary)
     {
         [[UserManager shareUserManager]setLatitude:[NSString stringWithFormat:@"%@",[dictionary valueForKey:kLatitude]]];
         [[UserManager shareUserManager]setLongitude:[NSString stringWithFormat:@"%@",[dictionary valueForKey:kLongitude]]];
         [[UserManager shareUserManager]setCurrentAddress:[dictionary valueForKey:@"currentAddress"]];
     }];
}

#pragma mark - niDropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}
-(void)rel
{
    self.nIDropDown = nil;
}
#pragma mark - Alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        BOOL isLocation = [[LocationManager shareLocationManager] CheckForLocationService];
        if (!isLocation)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }else
        {
            [[UserManager shareUserManager] enableLocation];
            [self currentLocation];
        }
    }else
    {
    }
}


#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIView *view = [self.tableView viewWithTag:khomeSearchHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    [(UITextField *)[subViews objectAtIndex:1] setText:[[UserManager shareUserManager] currentCity]];
    self.homeDetails.locationText = [[UserManager shareUserManager] currentCity];
    [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self.tableView endEditing:YES];
    if (self.tableView.contentOffset.y > 500.0)
    {
        [[self.view viewWithTag:khomeSearchBeginTag] setHidden:NO];
        
    }else
    {
        [[self.view viewWithTag:khomeSearchBeginTag] setHidden:YES];
    }
}

#pragma mark - Pull to refers
- (void)pullToRefresh
{
    if (self.homeDetails.homeType == viewRefer)
    {
        [[CoreData shareData] deleteReferWithLoginId:[[UserManager shareUserManager] number]];
        [self getRefer];
    }else if (self.homeDetails.homeType == viewAsk)
    {
        [[CoreData shareData]deleteAskWithLoginId:[[UserManager shareUserManager] number]];
        [self getAsk];
    }
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
    [[CoreData shareData] deleteCategoryWithLoginId:[[UserManager shareUserManager] number]];
//    [self getCarousel];
}

#pragma mark - HeareView

-(void) headerView
{
    [self.view setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    [self.tableView.tableHeaderView setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    
    CGRect frame = [self bounds];
    CGFloat xPos = 10.0;
    CGFloat Ypos = 75.0;
    CGFloat width = frame.size.width - 20.0;
    CGFloat height = 40.0;
    UIView *segmentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [segmentView setTag:101010];
    [segmentView setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    [segmentView.layer setCornerRadius:20.0];
    [segmentView.layer setMasksToBounds:YES];
    [self.view addSubview:segmentView];
    
    //Refers
    xPos = 2.0;
    Ypos = 2.0;
    width = round(segmentView.frame.size.width /2) - 70.0;
    height = segmentView.frame.size.height - 4.0;
    UILabel *refer = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [refer setText:@"Refers"];
    //    [refer setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [refer setTextAlignment:NSTextAlignmentCenter];
    [refer.layer setCornerRadius:18.0];
    [refer.layer setMasksToBounds:YES];
    [refer setUserInteractionEnabled:YES];
    UITapGestureRecognizer *referGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewRefersTapped:)];
    [refer addGestureRecognizer:referGestureRecognizer];
    [segmentView addSubview:refer];
    
    //Asks
    xPos = refer.frame.size.width + 7.0;
    UILabel *ask = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [ask setText:@"Asks"];
    //    [ask setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [ask setTextAlignment:NSTextAlignmentCenter];
    [ask.layer setCornerRadius:18.0];
    [ask.layer setMasksToBounds:YES];
    [ask setUserInteractionEnabled:YES];
    UITapGestureRecognizer *askGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewAskTapped:)];
    [ask addGestureRecognizer:askGestureRecognizer];
    [segmentView addSubview:ask];
    
    //Entity
    xPos = refer.frame.size.width + 138.0;
    UILabel *entity = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [entity setText:@"Entities"];
    //    [entity setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [entity setTextAlignment:NSTextAlignmentCenter];
    [entity.layer setCornerRadius:18.0];
    [entity.layer setMasksToBounds:YES];
    [entity setUserInteractionEnabled:YES];
    UITapGestureRecognizer *entityGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewEntitiesTapped:)];
    [entity addGestureRecognizer:entityGestureRecognizer];
    [segmentView addSubview:entity];
    
    if ([menuType isEqualToString:kAsk])
    {
        [refer setBackgroundColor:[UIColor clearColor]];
        [refer setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        [entity setBackgroundColor:[UIColor clearColor]];
        [entity setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        [ask setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [ask setTextColor:[UIColor whiteColor]];
        
        
    }else
    {
        [ask setBackgroundColor:[UIColor clearColor]];
        [ask setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        [entity setBackgroundColor:[UIColor clearColor]];
        [entity setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        [refer setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [refer setTextColor:[UIColor whiteColor]];
    }
    
}


#pragma mark  - Handler
- (void)viewRefersTapped
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    
    menuType = @"viewRefer";
    self.homeDetails.homeType = viewRefer;
    [self.tableView setHidden:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:searchBarString forKey:@"query"];
    //    [params setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
    [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    
    [[YoReferAPI sharedAPI] getViewRefersSearchWithParam:params completionHandler:^(NSDictionary *response ,NSError *error)
     {
         [self didReceiveViewRefersSearchWithResponse:response error:error];
         
     }];
    
}

- (void)didReceiveViewRefersSearchWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
        }else
        {
            //            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
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
            
            refer = [response valueForKey:@"response"];
            
            if ([refer count] > 0)
            {
                NSMutableArray *placesRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    Home *me = [Home getReferFromResponse:dictionary];
                    [placesRefer addObject:me];
                    
                }
                [self.homeDetails.homeDetails setValue:placesRefer forKey:kHomeViewRefer];
                [self.tableView setHidden:NO];
                 [self reloadTableView];
            }
            
        }else
        {
            
        }
    }
   
}


- (void)viewAsksTapped
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    
    menuType = @"viewAsks";
    self.homeDetails.homeType = viewAsk;
    [self.tableView setHidden:YES];


    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:searchBarString forKey:@"query"];
    [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    
    [[YoReferAPI sharedAPI] getAsksSearchWithParam:params completionHandler:^(NSDictionary *response ,NSError *error)
     {
         [self didReceiveAsksSearchWithResponse:response error:error];
         
     }];
    
}

- (void)didReceiveAsksSearchWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            //            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
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
            
            refer = [response valueForKey:@"response"];
            
            if ([refer count] > 0)
            {
                NSMutableArray *productRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    Home *me = [Home getAskFromResponse:dictionary];
                    [productRefer addObject:me];
                    
                }
                [self.homeDetails.homeDetails setValue:productRefer forKey:kHomeViewAsk];
                [self.tableView setHidden:NO];
                 [self reloadTableView];
            }
            
        }
    }
   
}

- (void)viewEntitiesTapped
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    
    menuType = @"viewEntities";
    self.homeDetails.homeType = viewEntity;
    [self.tableView setHidden:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:searchBarString forKey:@"query"];
    //    [params setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
    [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    
    [[YoReferAPI sharedAPI] getEntitiesSearchWithParam:params completionHandler:^(NSDictionary *response ,NSError *error)
     {
         [self didReceiveEntitiesSearchWithResponse:response error:error];
         
     }];
    
}

- (void)didReceiveEntitiesSearchWithResponse:(NSDictionary *)response error:(NSError *)error
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
            //            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMeError, @""), nil, @"Ok", nil, 0);
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
            
            refer = [response valueForKey:@"response"];
            
            if ([refer count] > 0)
            {
                NSMutableArray *serviceRefer = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictionary in refer)
                {
                    Home *me = [Home getEntitySearchFromResponse:dictionary];
                    [serviceRefer addObject:me];
                }
                [self.homeDetails.homeDetails setValue:serviceRefer forKey:kHomeViewEntities];
                [self.tableView setHidden:NO];
                [self reloadTableView];
            }
        }else
        {
//            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(@"Not Found", @""), nil, @"Ok", nil, 0);

        }
    }
    
}


- (void)viewRefersTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self activeSectionWithCategories:101 view:[gestureRecognizer.view superview]];
    [self viewRefersTapped];
    
}

- (void)viewAskTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self activeSectionWithCategories:102 view:[gestureRecognizer.view superview]];
    [self viewAsksTapped];
    
}

- (void)viewEntitiesTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self activeSectionWithCategories:103 view:[gestureRecognizer.view superview]];
    [self viewEntitiesTapped];
    
}


- (void)activeSectionWithCategories:(int)type view:(UIView *)view
{
    NSArray *subViews = [view subviews];
    switch (type) {
        case 101:
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            break;
        case 102:
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor grayColor]];
            break;
        case 103:
            [(UILabel *)[subViews objectAtIndex:2]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[subViews objectAtIndex:2]setTextColor:[UIColor whiteColor]];
            [(UILabel *)[subViews objectAtIndex:1]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor grayColor]];
            [(UILabel *)[subViews objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[subViews objectAtIndex:0]setTextColor:[UIColor grayColor]];
            break;
            
        default:
            break;
    }
    
}

/*
- (CGFloat)setMeTableViewHeightWithDetails:(MeType)details
{
    CGFloat height;
    height = 175.0;
    return height;
}

- (NSInteger)getMeCountWithMeType:(homeSearchingType)meType
{
    NSInteger count = 0;
    switch (meType)
    {
        case Refers:
            count = [self getReferCountWithMeType: self.homeDetails.homeType];
            break;
        default:
            break;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getMeCountWithMeType: self.homeDetails.homeType];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.homeDetails.homeType == Asks)
    {
        return 185.0;
    }else if ( self.homeDetails.homeType == Friends)
    {
        return 50.0;
    }else if ( self.homeDetails.homeType == Feeds)
    {
        return 419.0;
    }
    return 130.0;
}


- (HomeTableViewCell *)getMeTableViewCellWithMeType:(homeSearchingType)meType indexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch (meType) {
        case ViewRefers:
            cell = [self getReferTableViewCellWithCategories: self.homeDetails.homeType indexPath:indexPath];
            break;
        case ViewAsks:
            cell = [self getQueriesTableViewCellIndexPath:indexPath];
            break;
        case Entities:
            cell = [self getReferTableViewCellWithCategories: self.homeDetails.homeType indexPath:indexPath];
            break;
        
        default:
            break;
    }
    return cell;
    
}
- (HomeTableViewCell *)getReferTableViewCellWithCategories:(homeSearchingType)categories indexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch (categories)
    {
        case ViewRefers:
                cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.homeDetails.homeDetails objectForKey:@"Place"] meType:Refers];
            break;
            
        case ViewAsks:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.homeDetails.homeDetails objectForKey:@"Product"] meType:Refers];
            break;
        case Entities:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.homeDetails.homeDetails objectForKey:@"Service"] meType:Refers];
            break;
        default:
            break;
    }
    return cell;
}


- (HomeTableViewCell *)getQueriesTableViewCellIndexPath:(NSIndexPath *)indexPath
{
    MeTableViewCell *cell;
    switch ( self.homeDetails.homeType)
    {
        case ViewAsks:
            cell = [[MeTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:[self.homeDetails.homeDetails objectForKey:@"ask"] meType:Asks];
            break;
        default:
            break;
    }
    return cell;
}
*/

- (void)pushAskPageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    if (indexPath == nil)
    {
        QueryNowViewController *vctr = [[QueryNowViewController alloc]initWithQueryDetail:[self setQueryDefaultValue] delegate:self];
        [self.navigationController pushViewController:vctr animated:YES];
    }else
    {
        ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:(indexPath)?[self getQueryDetailWithIndexPath:indexPath]:nil delegate:self];
        [self.navigationController pushViewController:vctr animated:YES];
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
    
    // Dev...Earlier it was setting the full current address...
    //    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kAddress];
    
    //Dev...Now shorten address is set...
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] cCityState]:@"" forKey:kAddress];
    
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:kCity];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"searchtext"];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
    return dictionary;
}

- (NSMutableDictionary *)getQueryDetailWithIndexPath:(NSIndexPath *)indexPath
{
//    Home *query = (Home *)[[self.homeDetails.homeDetails objectForKey:kAsk] objectAtIndex:indexPath.row];
    Home *query = (Home *)[[self.homeDetails.homeDetails objectForKey:kHomeViewAsk] objectAtIndex:indexPath.row];

    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:query.type forKey:kCategorytype];
    [dictionary setValue:query.entityName forKey:kName];
    [dictionary setValue:query.category forKey:kCategory];
    [dictionary setValue:query.askId forKey:kAskId];
    [dictionary setValue:[query valueForKey:kCity] forKey:kCity];
    [dictionary setValue:[query valueForKey:kCity] forKey:@"searchtext"];
    [dictionary setValue:@"" forKey:kLocation];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[query.location objectAtIndex:1]] forKey:kLatitude];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[query.location objectAtIndex:0]] forKey:kLongitude];
    [dictionary setValue:[query.user objectForKey:kNumber] forKey:kReferPhone];
    [dictionary setValue:[query.user    valueForKey:kName]forKey:kReferName];
    [dictionary setValue:@"" forKey:kPhone];
    [dictionary setValue:@"" forKey:kName];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
    // [dictionary setValue:[NSString stringWithFormat:@"%@",query.fourSquareCategoryId] forKey:@"categoryid"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsAsk];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kContactCategory];
    return dictionary;
}

- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
//    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:(indexPath)?(self.homeDetails.homeType == viewAsk)?[self setReferWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]]:[self getReferDetailWithIndexPath:indexPath]:[self setReferDefaultValue] delegate:self];
    
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self getReferDetailWithIndexPath:indexPath] delegate:self];    
    [self.navigationController pushViewController:vctr animated:YES];
}

-(NSMutableDictionary *)setReferWithCategoryList:(NSDictionary *)categoryList
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[categoryList objectForKey:@"type"] forKey:kCategorytype];
    [dictionary setValue:[categoryList objectForKey:kCategory] forKey:kCategory];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:@"foursquareCategoryId"] forKey:kCategoryid];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kName] forKey:kName];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kCity] forKey:kAddress];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKey:kLocality] forKey:@"location"];
    if ([[[categoryList objectForKey:kEntity] objectForKey:kPosition] count] > 0)
    {
        [dictionary setValue:[[[categoryList objectForKey:kEntity] objectForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
        [dictionary setValue:[[[categoryList objectForKey:kEntity] objectForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
    }
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kPhone] forKey:kPhone];
    if ([[[categoryList valueForKey:kEntity] objectForKey:kDp] objectForKey:@"mediaId"] != nil && [[[[categoryList valueForKey:kEntity] objectForKey:kDp] objectForKey:@"mediaId"] length] > 0)
        [dictionary setValue:[[[categoryList valueForKey:kEntity] objectForKey:kDp] objectForKey:@"mediaId"] forKey:kReferimage];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kWebSite] forKey:kWebSite];
    [dictionary setValue:[[categoryList objectForKey:kEntity]  objectForKey:kEntityId] forKey:kEntityId];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    return dictionary;
}

- (NSMutableDictionary *)setReferDefaultValue
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
    [dictionary setValue:category.categoryID forKey:kCategoryid];
    //([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@""
    BOOL isLocation = [[UserManager shareUserManager] getLocationService];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:kCity];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"searchtext"];
    //([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentAddress]:@""
    [dictionary setValue:@"" forKey:kLocation];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
    [dictionary setValue:@"place" forKey:kCategorytype];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    return dictionary;
}

- (NSMutableDictionary *)getReferDetailWithIndexPath:(NSIndexPath *)indexPath
{
    Home *refer = (Home *)((self.homeDetails.homeType == viewRefer)?[[self.homeDetails.homeDetails objectForKey:kHomeViewRefer] objectAtIndex:indexPath.row]:[[self.homeDetails.homeDetails objectForKey:kHomeViewEntities] objectAtIndex:indexPath.row]);
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    if ([[refer.entity objectForKey:kType] isEqualToString:kWeb])
    {
        [dictionary setValue:[refer.entity valueForKey:kCategory] forKey:kCategory];
        [dictionary setValue:@"Weblink" forKey:kAddress];
        [dictionary setValue:refer.note forKey:kMessage];
        [dictionary setValue:[refer.entity valueForKey:kName] forKey:kName];
        [dictionary setValue:[refer.entity valueForKey:kWebSite] forKey:kWebSite];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[refer.entity valueForKey:@"entityId"] forKey:kEntityId];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
    }else
    {
        [dictionary setValue:refer.mediaId forKey:kReferimage];
        [dictionary setValue:refer.type forKey:kCategorytype];
        [dictionary setValue:refer.entityName forKey:kName];
        [dictionary setValue:[refer.entity objectForKey:@"category"] forKey:kCategory];
        [dictionary setValue:refer.note forKey:kMessage];
        [dictionary setValue:[refer.entity objectForKey:@"entityId"] forKey:kEntityId];
        if ([refer.type  isEqualToString:@"product"])
        {
            [dictionary setValue:[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
            [dictionary setValue:[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocation];
            [dictionary setValue:[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
            [dictionary setValue:[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWebSite];
            [dictionary setValue:[refer.entity valueForKey:kCity] forKey:kCity];
            [dictionary setValue:[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kName] forKey:kFromWhere];
            if ([[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] count] > 0)
            {
                [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
                [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
            }
        }else
        {
            [dictionary setValue:[refer.entity objectForKey:kCity] forKey:kCity];
            [dictionary setValue:[refer.entity objectForKey:kLocality] forKey:kLocation];
            [dictionary setValue:[refer.entity objectForKey:kPhone] forKey:kPhone];
            [dictionary setValue:[refer.entity objectForKey:kWebSite] forKey:kWebSite];
            if ([refer.location count] > 0)
            {
                [dictionary setValue:[NSString stringWithFormat:@"%@",[refer.location objectAtIndex:0]] forKey:kLongitude];
                [dictionary setValue:[NSString stringWithFormat:@"%@",[refer.location objectAtIndex:1]] forKey:kLatitude];
                
            }
            [dictionary setValue:refer.entity forKey:kEntity];
        }
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    }
    return dictionary;
}

- (void)refersWithIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSMutableArray *array = [self getReferWithCategories: self.homeDetails.categories];
    
    // Here to implement Shorten Url method for Entity View Controller...
    
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithCategory:(Home *)[array objectAtIndex:indexPath.row]]];
    [self.navigationController pushViewController:vctr animated:YES];
    */
    
}


#pragma mark  - TableView datasource and Delegate
-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    CGFloat tableViewHeight = 40.0;
    
    self.tableView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height - tableViewHeight);
    [self.view layoutIfNeeded];
}


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

@implementation HomeSearchDetails
@end

