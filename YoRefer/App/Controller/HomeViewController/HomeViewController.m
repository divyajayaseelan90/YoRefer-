//
//  HomeViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//
#import "HomeViewController.h"
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

NSUInteger      const numberOfSection             = 1;
CGFloat         const sectionHeight               = 85.0;
NSInteger       const kHeaderView                 = 50000;
NSInteger       const kAlertTag                   = 60000;
NSUInteger      const kLocationButtonEnableTag    = 13212;
NSUInteger      const kLocationButtonDisableTag   = 13213;
NSUInteger      const kBeginTag                   = 23124;
NSString    *   const kSearchPlaceHolder          = @"Places, Products or Services";
NSString    *   const klocationPlaceHolder        = @"Select Location";
NSString    *   const kHomeRefer                  = @"refer";
NSString    *   const kHomeAsk                    = @"ask";
NSString    *   const kHomeSearch                 = @"search";
NSString    *   const kHomeSearchText             = @"searchtext";
NSString    *   const kHomeError                  = @"Unable to get carousel";
NSString    *   const kHomeAlertMessage           = @"Yorefer would like to use your location";

@interface HomeDetails : NSObject

@property (nonatomic, strong)    NSMutableArray        * carousel;
@property (nonatomic, strong)    NSMutableDictionary   * homeDetails;
@property (nonatomic, readwrite) HomeType                homeType;
@property (nonatomic, strong)    NSString              * locationText;
@property (nonatomic, assign)    CGFloat                 referRowHeight;

@end

@interface HomeViewController ()<UISearchBarDelegate,Query,Refer,UITextFieldDelegate,NIDropDownDelegate,LocationManger,CategoryView,Users,UIAlertViewDelegate>

@property (nonatomic, strong)    HomeDetails                * homeDetails;
@property (nonatomic, strong)    NIDropDown                 * nIDropDown;
@property (nonatomic, strong)    NSArray                    * referResponse;
@property (nonatomic, strong)    NSMutableDictionary        * category;
@property (strong, nonatomic)    UIView                     * dropDownView;
@property (strong, nonatomic)    UIRefreshControl           * refreshControl;
@property (nonatomic, strong)    NSTimer                    * splashTimer;

@end

#pragma mark - implementation
@implementation HomeViewController

#pragma mark - Code Refactoring
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self currentLocation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.homeDetails = [[HomeDetails alloc]init];
    self.homeDetails.homeDetails = [[NSMutableDictionary alloc]init];
    self.homeDetails.referRowHeight = 48.0;
    //Begain Update
    [self BeginPage];
    //Carousel
    [self getCarousel];
    //Refer
    [self getRefer];
    [self reloadTableView];
    [self splashScreen];
    //Pull to referesh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:@"locationupdating" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefresh) name:@"pullToReferesh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTop) name:@"scrollToTop" object:nil];
}

- (void)BeginPage
{
    CGFloat xPos,yPos,width,height;
    CGRect frame = [self bounds];
    width = 65.0;
    height = 48.0;
    xPos = frame.size.width - width;
    yPos = frame.size.height - (height + 78.0);
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setTag:kBeginTag];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollToTop)];
    [view addGestureRecognizer:gestureRecognizer];
    [view setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    width = 32.0;
    height = 32.0;
    xPos = roundf((view.frame.size.width - width)/2);
    yPos = roundf((view.frame.size.height - height)/2);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:[UIImage imageNamed:@"icon_menu-up-arrow.png"]];
    [view addSubview:imageView];
    [self.view addSubview:view];
}

- (void)scrollToTop
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

#pragma mark - Splash screen
- (void)splashScreen
{
    
    if ([[UserManager shareUserManager] getSplash])
    {
        self.splashTimer =  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(tapToHome:) userInfo:nil repeats:NO];
        CGRect frame = [self bounds];
        CGFloat xPos = 0.0;
        CGFloat yPos = 0.0;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.navigationController.navigationBarHidden = YES;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [view setBackgroundColor:[UIColor blackColor]];
        view.tag = 9009;
        [self.view addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToHome:)];
        [view addGestureRecognizer:tap];
        
        UIImageView *splash = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        splash.image = [UIImage imageNamed:@"icon_splash"];
        [view addSubview:splash];
        
    }else
    {
        
    }
    
}


- (void)tapToHome:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.splashTimer invalidate];
    [[UserManager shareUserManager] setSplashWithBool:NO];
    UIView *view = (UIView *) [self.view viewWithTag:9009];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.frame = CGRectMake(0.0, [self bounds].size.height, 0.0, 0.0);
                     }
                     completion:^(BOOL finished){
                         UITabBarController *tabBarControllers = (id)self.revealViewController.frontViewController;
                         [tabBarControllers.tabBar setHidden:NO];
                         [self.appDelegate DCButtonWithStatus:NO];
                         
                     }];
    
    self.navigationController.navigationBarHidden = NO;
    
}

#pragma mark - tableview datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = sectionHeight;
   
    //background View
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = kHeaderView;
    [view setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    
    //location view
    xPos = 16.0;
    yPos = 5.0;
    height = round((sectionHeight - 5)/2) - 10.0;
    width = view.frame.size.width - (xPos * 2);
    
    UIView *locationView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    locationView.backgroundColor = [UIColor clearColor];
    [locationView.layer setBorderWidth:0.6];
    [locationView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [locationView.layer setCornerRadius:5.0];
    [locationView.layer setMasksToBounds:YES];
    [view addSubview:locationView];
    //downarrow image
    width = 25.0;
    height = 25.0;
    xPos = locationView.frame.size.width - width;
    yPos = round((locationView.frame.size.height - height)/2);
   
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [image setImage:downarraow];
    [locationView addSubview:image];
    //textfield
    xPos = 0.0;
    yPos = 2.0;
    width = locationView.frame.size.width - image.frame.size.width;
    
    UITextField *addressTxtField = [[UITextField alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressTxtField setBackgroundColor:[UIColor clearColor]];
    [addressTxtField setTextColor:[UIColor whiteColor]];
    [addressTxtField setReturnKeyType:UIReturnKeySearch];
    [addressTxtField setDelegate:self];
    [addressTxtField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [addressTxtField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [addressTxtField setTextAlignment:NSTextAlignmentCenter];
    [addressTxtField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    if ([addressTxtField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        addressTxtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:klocationPlaceHolder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }else {
    }
    [addressTxtField setText:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@""];
    [locationView addSubview:addressTxtField];
    //button
    xPos = 0.0;
    yPos = 0.0;
    width = locationView.frame.size.width;
    height = locationView.frame.size.height;
    
    UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [locationBtn setBackgroundColor:[UIColor clearColor]];
    [locationBtn addTarget:self action:@selector(locationBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [locationView addSubview:locationBtn];
    //enableanddisbale location button
    [locationBtn setHidden:([[UserManager shareUserManager] getLocationService])?YES:NO];
    
    
    //downarrow button
    xPos = locationView.frame.size.width - image.frame.size.width;
    yPos = 0.0;
    width = 40.0;
    height = 40.0;
   
    UIButton *addressBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressBtn setTag:kLocationButtonEnableTag];
    [addressBtn setBackgroundColor:[UIColor clearColor]];
    [addressBtn addTarget:self action:@selector(addressBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [locationView addSubview:addressBtn];
    
    //searchBar
    xPos = 16.0;
    yPos = locationView.frame.origin.y + locationView.frame.size.height + 5.0;
    width = view.frame.size.width - (xPos * 2);
    height = sectionHeight - yPos - 5.0;
   
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [searchBar setDelegate:self];
    //[searchBar setTintColor:[UIColor whiteColor]];
    [searchBar setText:(self.homeDetails.homeType == search)?[self.homeDetails.homeDetails valueForKey:kHomeSearchText]:@"" ];
    [searchBar setPlaceholder:kSearchPlaceHolder];
    searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    [searchBar setBarTintColor:[UIColor whiteColor]];
    [searchBar setBackgroundColor:[UIColor whiteColor]];
    searchBar.layer.cornerRadius = 8.0;
    searchBar.layer.masksToBounds = YES;
    [view addSubview:searchBar];

//    for (UIView *subView in searchBar.subviews){
//        for (UIView *subSubView in subView.subviews){
//            if ([subSubView isKindOfClass:[UITextField class]])
//            {
//                UITextField *searchBarTextField = (UITextField *)subSubView;
//                searchBarTextField.frame = CGRectMake(searchBarTextField.frame.origin.x, searchBarTextField.frame.origin.y, searchBarTextField.frame.size.width, searchBarTextField.frame.size.height + 20.0);
//                break;
//            }
//        }
//    }
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self setNumberOfRowInSectionWitHomeType:self.homeDetails.homeType];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self rowHeightWithIndexPath:indexPath];
}

- (NSInteger)setNumberOfRowInSectionWitHomeType:(HomeType)homeType
{
    NSInteger count = 0;
    switch (homeType) {
        case refer:
            count = [[self.homeDetails.homeDetails objectForKey:kHomeRefer] count] + 3;
            break;
        case ask:
            count = [[self.homeDetails.homeDetails objectForKey:kHomeAsk] count] + 3;
            break;
        case search:
            count = [[self.homeDetails.homeDetails objectForKey:kHomeSearch] count];
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
    switch (indexPath.row) {
        case carousel:
            height = (self.homeDetails.homeType == search)?419.0:142.0;
            break;
        case referAsk:
            height = (self.homeDetails.homeType == search)?419.0:self.homeDetails.referRowHeight;
            break;
        case segment:
            height = (self.homeDetails.homeType == search)?419.0:51.0;
            break;
        default:
            if (self.homeDetails.homeType == refer)
                height = 419.0;
            if (self.homeDetails.homeType == ask)
                height = 186.0;
            if (self.homeDetails.homeType == search)
                height = 419.0;
            break;
    }
    return height;
}

-(HomeTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(self.homeDetails.homeType == search)?nil:[self getCellIdentifireWithHomeType:(indexPath.row == 0)?referAsk:(indexPath.row == 1)?carousel:(indexPath.row == 2)?segment:self.homeDetails.homeType indexPath:indexPath]];
    if (cell == nil)
    {
        cell = [self setHomeCellWithHomeWithIndexPath:indexPath];
        [cell setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    }
    return cell;
    
}

- (HomeTableViewCell *)setHomeCellWithHomeWithIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell;
    switch (indexPath.row) {
        case carousel:
            cell = (self.homeDetails.homeType == search)?[[HomeTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row] homeType:search indexPath:indexPath]:[[HomeTableViewCell alloc]initWithDelegate:self response:[NSDictionary dictionaryWithObjectsAndKeys:self.homeDetails.carousel,@"carousel", nil] homeType:carousel indexPath:indexPath];
            break;
        case referAsk:
            cell = (self.homeDetails.homeType == search)?[[HomeTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row] homeType:search indexPath:indexPath]:[[HomeTableViewCell alloc]initWithDelegate:self response:nil homeType:referAsk indexPath:indexPath];
            break;
        case segment:
            cell = (self.homeDetails.homeType == search)?[[HomeTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row] homeType:search indexPath:indexPath]:[[HomeTableViewCell alloc]initWithDelegate:self response:nil homeType:segment indexPath:indexPath];
            break;
        default:
            if (self.homeDetails.homeType == search)
                cell = [[HomeTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row] homeType:search indexPath:indexPath];
            else if (self.homeDetails.homeType == refer)
                cell = [[HomeTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeRefer] objectAtIndex:(indexPath.row - 3)] homeType:refer indexPath:indexPath];
            else if (self.homeDetails.homeType == ask)
                cell = [[HomeTableViewCell alloc]initWithDelegate:self response:[[self.homeDetails.homeDetails objectForKey:kHomeAsk] objectAtIndex:(indexPath.row - 3)] homeType:ask indexPath:indexPath];
            break;
    }
    return cell;
}
- (NSString *)getCellIdentifireWithHomeType:(HomeType)homeType indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentification = nil;
    switch (homeType) {
        case carousel:
            cellIdentification = kHomeCarouselReuseIdentifier;
            break;
        case referAsk:
            cellIdentification = kHomeReferAskReuseIdentifier;
            break;
        case segment:
            cellIdentification = kHomeSegmentReuseIdentifier;
            break;
        case refer:
            cellIdentification = nil;//[NSString stringWithFormat:@"%d_%@",indexPath.row,kHomeReferReuseIdentifier];
            break;
        case ask:
            cellIdentification =nil; //[NSString stringWithFormat:@"%d_%@",indexPath.row,kHomeAskReuseIdentifier];
            break;
        case search:
            cellIdentification = kHomeSearchReuseIdentifier;
            break;
        default:
            break;
    }
    return cellIdentification;
}
//last row
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.homeDetails.homeDetails objectForKey:kHomeRefer ] count] > 0 &&[[self.homeDetails.homeDetails objectForKey:kHomeRefer ] count] + 3 == (indexPath.row+1) && self.homeDetails.homeType == refer)
    {
        Home *home =(Home *)[[self.homeDetails.homeDetails objectForKey:kHomeRefer] objectAtIndex:[[self.homeDetails.homeDetails objectForKey:kHomeRefer ] count] -1] ;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:@"5" forKey:@"limit"];
        [params setValue:home.referredAt forKey:@"before"];
        [params setValue:@"true" forKey:@"inMyCircle"];
        [[YoReferAPI sharedAPI] referWithParams:params completionHandler:^(NSDictionary *response, NSError *error)
        {
            [self didRecevieNextReferWithResponse:response error:error];
            
        }];
    }else if ([[self.homeDetails.homeDetails objectForKey:kHomeAsk ] count] > 0 &&[[self.homeDetails.homeDetails objectForKey:kHomeAsk ] count] + 3 == (indexPath.row+1) && self.homeDetails.homeType == ask)
    {
        Home *home =(Home *)[[self.homeDetails.homeDetails objectForKey:kHomeAsk] objectAtIndex:[[self.homeDetails.homeDetails objectForKey:kHomeAsk ] count] -1] ;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:@"5" forKey:@"limit"];
        [params setValue:home.askedAt forKey:@"before"];
        [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
        [[YoReferAPI sharedAPI] askWithParams:params completionHandler:^(NSDictionary *response, NSError *error)
        {
            
            [self didRecevieNextAskWithResponse:response error:error];
            
        }];
    }
}


#pragma mark - Search Bar delegate
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
    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
//    [self.homeDetails.homeDetails setValue:searchBar.text forKey:kHomeSearchText];
    [self searchWithText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
    searchBar.text = @"";
    self.homeDetails.homeType = refer;
    [self.homeDetails.homeDetails setValue:@"" forKey:kHomeSearchText];
    [self.homeDetails.homeDetails setValue:@"" forKey:kHomeSearch];
    [self reloadTableView];
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

#pragma mark - Textfiled delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     CGRect frame = [[textField superview].superview convertRect:[textField superview].frame toView:self.view];
    [self.homeDetails.homeDetails setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.homeDetails.locationText length] - 2 == [textField.text length] && [self.homeDetails.locationText length] > 0 && [string length] <= 0)
    {
        textField.text = @"";
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    if ([textField.text length] > 3)
    {
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length] > 3)
    {
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)LocationWithDetails:(NSMutableArray *)details
{
    if(self.nIDropDown == nil) {
        UIView *view = [self.tableView viewWithTag:kHeaderView];
        CGFloat yPostion = [[self.homeDetails.homeDetails valueForKey:kYPostion] floatValue] + 26.0;
        CGFloat changedHeight = [UIScreen mainScreen].bounds.size.height - (view.frame.size.height + 52.0);
        self.dropDownView = [[UIView alloc]initWithFrame:CGRectMake(6.0, yPostion, view.frame.size.width - 30.0, ((details.count * 44.0)> changedHeight)?changedHeight:details.count * 100.0)];
        UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(-10.0, 0.0, self.dropDownView.frame.size.width, self.dropDownView.frame.size.height)];
        CGRect btnFrame=locationBtn.frame;
        btnFrame.origin.y=0.0;
        btnFrame.origin.x = 0.0;
        btnFrame.size.height=0.0;
        locationBtn.frame=btnFrame;
        locationBtn.backgroundColor=[UIColor clearColor];
        CGFloat f = changedHeight;//([UIScreen mainScreen].bounds.size.height > 480.0)?([UIScreen mainScreen].bounds.size.height > 568.0)?220.0:171.0:83.0;
        self.nIDropDown = [[NIDropDown alloc]showDropDown:locationBtn :f :details :nil :@"down" type:YES];
        self.nIDropDown.delegate = self;
        [self.dropDownView addSubview:self.nIDropDown];
        [self.view addSubview:self.dropDownView];
    }
}

#pragma mark - Handler
- (void)searchWithText:(NSString *)text
{
    [self hideHUD];
    HomeSearchViewController *vctr = [[HomeSearchViewController alloc]init];
    [vctr setSearchBarString:text];
    [self.navigationController pushViewController:vctr animated:YES];
    
    /*
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"5" forKey:@"limit"];
    [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"before"];
    [params setValue:text forKey:@"query"];
    [params setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
    [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    [[YoReferAPI sharedAPI] searchByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
         [self didReceiveSearchResponse:response error:error];
         
     }];
    */

}

- (void)didReceiveSearchResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    [self.refreshControl endRefreshing];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kHomeError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else if([[response objectForKey:@"response"] count] <=0)
    {
        alertView([[Configuration shareConfiguration] appName], @"No result found", nil, @"Ok", nil, 0);
        return;
    }else
    {
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [response valueForKey:@"response"])
        {
            Home *home = [Home getReferFromResponse:dictionary];
            [array addObject:home];
        }
        [self.homeDetails.homeDetails setValue:array forKey:kHomeSearch];
        self.homeDetails.homeType = search;
        [self reloadTableView];
        
    }
}

- (void)getCarousel
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    NSArray *array = [[CoreData shareData]
                      getCarouselWithLoginId:[[UserManager shareUserManager] number]];
    if ([array count] > 0)
    {
        self.homeDetails.carousel = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in array)
        {
            Carousel *carousel = [Carousel getCarouselFromResponse:dictionary];
            [self.homeDetails.carousel addObject:carousel];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *indexPaths = [[NSArray alloc]initWithObjects:indexPath, nil];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:0];
        [self hideHUD];
    }else
    {
        [[YoReferAPI sharedAPI] carouselWithParam:nil completionHandler:^(NSDictionary *response , NSError *error)
         {
             [self didReceiveCarouselWithResponse:response error:error];

         }];
    }
}

- (void)didReceiveCarouselWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    [self.refreshControl endRefreshing];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kHomeError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        self.homeDetails.carousel = [[NSMutableArray alloc]init];
        if ([[response valueForKey:@"response"] count] > 0)
        {
            [[CoreData shareData] setCarouselWithLoginId:[[UserManager shareUserManager]number] response:response];
            NSArray *array = [[CoreData shareData]
                              getCarouselWithLoginId:[[UserManager shareUserManager] number]];
            for (NSDictionary *dictionary in array)
            {
                Carousel *carousel = [Carousel getCarouselFromResponse:dictionary];
                [self.homeDetails.carousel addObject:carousel];
            }
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        NSArray *indexPaths = [[NSArray alloc]initWithObjects:indexPath, nil];
       [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)getRefer
{
    [self.tableView endEditing:YES];
    self.homeDetails.homeType = refer;
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    NSArray *refer = [[CoreData shareData] getHomeReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([refer count] >0)
    {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in refer)
        {
            Home *home = [Home getReferFromResponse:dictionary];
            [array addObject:home];
        }
        [self.homeDetails.homeDetails setValue:array forKey:kHomeRefer];
        [self reloadTableView];
        [self hideHUD];
    }else
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:@"5" forKey:@"limit"];
        [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"before"];
        [params setValue:@"true" forKey:@"inMyCircle"];
        [[YoReferAPI sharedAPI] referWithParams:params completionHandler:^(NSDictionary *response, NSError *error)
        {
            [self didReceiveReferWithResponse:response error:error];
            
        }];
    }
}

- (void)didReceiveReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    [self.refreshControl endRefreshing];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kHomeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        if ([[response valueForKey:@"response"] count] > 0)
        {
            [[CoreData shareData] setHomeReferWithLoginId:[[UserManager shareUserManager] number] response:response];
            NSArray *home = [[CoreData shareData] getHomeReferWithLoginId:[[UserManager shareUserManager] number]];
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in home)
            {
                Home *home = [Home getReferFromResponse:dictionary];
                [array addObject:home];
            }
            [self.homeDetails.homeDetails setValue:array forKey:kHomeRefer];
            [self reloadTableView];
        }
    }
//     [self reloadTableView];
}

- (void)didRecevieNextReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self.refreshControl endRefreshing];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kHomeError, @""), nil, @"Ok", nil, 0);
            return;
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        NSMutableArray *referArray = [NSMutableArray arrayWithArray:[self.homeDetails.homeDetails objectForKey:kHomeRefer]];
        for (NSDictionary *dictionary in [response objectForKey:@"response"])
        {
            Home *home = [Home getReferFromResponse:dictionary];
            [referArray addObject:home];
        }
        [self.homeDetails.homeDetails setValue:referArray forKey:kHomeRefer];
        [self reloadTableView];
    }
}

- (void)getAsk
{
    [self.tableView endEditing:YES];
    [self.homeDetails.homeDetails setValue:@"ask" forKey:@"menutype"];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    self.homeDetails.homeType = ask;
    NSArray *ask = [[CoreData shareData] getHomeAskWithLoginId:[[UserManager shareUserManager] number]];
    if ([ask count] > 0)
    {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in ask)
        {
            Home *home = [Home getAskFromResponse:dictionary];
            [array addObject:home];
        }
        [self.homeDetails.homeDetails setValue:array forKey:kHomeAsk];
        [self hideHUD];
        [self reloadTableView];
    }else
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:@"5" forKey:@"limit"];
        [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"before"];
        [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
        [[YoReferAPI sharedAPI] askWithParams:params completionHandler:^(NSDictionary *response, NSError *error)
        {
            [self didReceiveAskWithResponse:response error:error];
            
        }];
    }
}
- (void)didReceiveAskWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    [self.refreshControl endRefreshing];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kHomeError, @""), nil, @"Ok", nil, 0);
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        if ([[response valueForKey:@"response"] count] > 0)
        {
            [[CoreData shareData] setHomeAskWithLoginId:[[UserManager shareUserManager] number] response:response];
            NSArray *ask = [[CoreData shareData] getHomeAskWithLoginId:[[UserManager shareUserManager] number]];
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in ask)
            {
                Home *home = [Home getAskFromResponse:dictionary];
                [array addObject:home];
            }
            [self.homeDetails.homeDetails setValue:array forKey:kHomeAsk];
            [self reloadTableView];


        }
    }
//    [self reloadTableView];
}

- (void)didRecevieNextAskWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    [self.refreshControl endRefreshing];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kHomeError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        NSMutableArray *askArray = [NSMutableArray arrayWithArray:[self.homeDetails.homeDetails objectForKey:kHomeAsk]];
        for (NSDictionary *dictionary in [response objectForKey:@"response"])
        {
            Home *home = [Home getAskFromResponse:dictionary];
            [askArray addObject:home];
        }
        [self.homeDetails.homeDetails setValue:askArray forKey:kHomeAsk];
        [self reloadTableView];
    }
}

#pragma mark - Protocol

- (void)referNowTappedWithView:(UITapGestureRecognizer *)GestureRecognizer
{
    if (self.homeDetails.referRowHeight == 48.0)
    {
        self.homeDetails.referRowHeight = 100.0;
        
    }else if (self.homeDetails.referRowHeight == 100.0)
    {
        self.homeDetails.referRowHeight = 48.0;
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self updateReferListType:referAsk];
}


- (void)updateReferListType:(HomeType)queryType
{
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (HomeTableViewCell  * cell in tableSubViews)
        {
            NSArray *cellSubViews = [cell subviews];
            if ([cellSubViews count] > 0)
            {
                NSArray *subView = [[cellSubViews objectAtIndex:0] subviews];
                if ([subView count] > 0)
                {
                    UIView *view = [subView objectAtIndex:0];
                    if (view.tag == queryType )
                    {
                        NSArray *subViews = [view subviews];
                        UIView *referListView = [subViews objectAtIndex:1];
                        if (self.homeDetails.referRowHeight == 100.0)
                            [referListView setHidden:NO];
                        else if (self.homeDetails.referRowHeight == 48.0)
                            [referListView setHidden:YES];
                       
                    }
                }
            }
        }
    }
}


- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:(indexPath)?(self.homeDetails.homeType == ask)?[self setReferWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]]:[self getReferDetailWithIndexPath:indexPath]:[self setReferDefaultValue] delegate:self];
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

- (NSMutableDictionary *)getReferDetailWithIndexPath:(NSIndexPath *)indexPath
{
    Home *refer = (Home *)((self.homeDetails.homeType == search)?[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row]:[[self.homeDetails.homeDetails objectForKey:kHomeRefer] objectAtIndex:indexPath.row - 3]);
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
            
            [dictionary setValue:[[[refer.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kEmail] forKey:kEmail];

            
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
            
            [dictionary setValue:[refer.entity objectForKey:kEmail] forKey:kEmail];

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
    Home *query = (Home *)[[self.homeDetails.homeDetails objectForKey:kAsk] objectAtIndex:indexPath.row - 3];
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
- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:(self.homeDetails.homeType == ask)?[self getEntityDetailWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]]:[self getEntityDetailWithIndexPath:indexPath]];
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
    Home *home = (Home *)((self.homeDetails.homeType == search)?[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row]:[[self.homeDetails.homeDetails objectForKey:kHomeRefer] objectAtIndex:indexPath.row - 3]);
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
    Home *home = (Home *)((self.homeDetails.homeType == search)?[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row]:(self.homeDetails.homeType == refer)?[[self.homeDetails.homeDetails objectForKey:kHomeRefer] objectAtIndex:indexPath.row - 3]:[[self.homeDetails.homeDetails objectForKey:kHomeAsk] objectAtIndex:indexPath.row - 3]);
    BOOL isGuest;
    if (self.homeDetails.homeType  == refer || self.homeDetails.homeType  == search)
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
    }else if (self.homeDetails.homeType  == ask)
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

- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    Home *home = (Home *)((self.homeDetails.homeType == search)?[[self.homeDetails.homeDetails objectForKey:kHomeSearch] objectAtIndex:indexPath.row]:[[self.homeDetails.homeDetails objectForKey:kHomeRefer] objectAtIndex:indexPath.row - 3]);
    [dict setValue:[home.entity  objectForKey:kEntityId] forKey:@"entityid"];
    [dict setValue:[home.entity valueForKey:@"referCount"] forKey:kReferCount];
    [dict setValue:[home.entity valueForKey:@"mediaCount"] forKey:@"mediaCount"];
    [dict setValue:[home.entity valueForKey:kName] forKey:kName];
    [dict setValue:home.entity forKey:kEntity];
    [dict setValue:home.note forKey:kMessage];
    [dict setValue:home.type forKey:kType];
    if ([[home.entity valueForKey:kType]isEqualToString:kWeb])
    {
        WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[home.entity valueForKey:kWebSite]] title:@"Web" refer:YES categoryType:@""];
        [self.navigationController pushViewController:vctr animated:YES];
        
    }else
    {
        if ([home.type isEqualToString:kProduct])
        {
            [dict setValue:[NSString stringWithFormat:@"%@",[[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude
             ];
            [dict setValue:[NSString stringWithFormat:@"%@",[[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
            [dict setValue:home.mediaId forKey:kImage];
            [dict setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kCity] forKey:kCity];
            [dict setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kLocality] forKey:kLocality];
            [dict setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kPhone] forKey:kPhone];
            [dict setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
            [dict setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCategory] forKey:kCategory];
            [dict setValue:[[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kName] forKey:kFromWhere];
        }else
        {
            [dict setValue:[home.location objectAtIndex:0] forKey:kLongitude];
            [dict setValue:[home.location objectAtIndex:1] forKey:kLatitude];
            [dict setValue:home.mediaId forKey:kImage];
            [dict setValue:[home.entity  valueForKey:kLocality] forKey:kLocality];
            [dict setValue:[home.entity  valueForKey:kCity] forKey:kCity];
            [dict setValue:[home.entity  valueForKey:kPhone] forKey:kPhone];
            [dict setValue:[home.entity objectForKey:kWebSite] forKey:kWeb];
            [dict setValue:[home.entity   objectForKey:kCategory] forKey:kCategory];
        }
        NSMutableArray *mapArray = [[NSMutableArray alloc]initWithObjects:dict, nil];
        MapViewController *vctr=[[MapViewController alloc]initWithResponse:mapArray type:@"Others" isCurrentOffers:NO];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}

- (void)getAskReferalsWithIndexPath:(NSIndexPath *)indexPath
{
    Home *query = (Home *)[[self.homeDetails.homeDetails objectForKey:kHomeAsk] objectAtIndex:indexPath.row - 3];
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
    [self updateQueryQueryType:segment];
}


- (void)updateQueryQueryType:(HomeType)queryType
{
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (HomeTableViewCell  * cell in tableSubViews)
        {
            NSArray *cellSubViews = [cell subviews];
            if ([cellSubViews count] > 0)
            {
                NSArray *subView = [[cellSubViews objectAtIndex:0] subviews];
                if ([subView count] > 0)
                {
                    UIView *view = [subView objectAtIndex:0];
                    if (view.tag == queryType)
                    {
                        [self enableSegmentWithIndex:(self.homeDetails.homeType == ask)?1:0 subViews:[view subviews]];
                    }
                }
            }
        }
    }
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
            QueryNowViewController *vctr = [[QueryNowViewController alloc]initWithQueryDetail:[self setQueryDefaultValue] delegate:self];
            [self.navigationController pushViewController:vctr animated:YES];
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
    alertView(@"Location",kHomeAlertMessage, self, @"Yes", @"No", kAlertTag);
}

- (IBAction)addressBtnTapped:(id)sender
{
    [self.tableView endEditing:YES];
    UIButton *button = (UIButton *)sender;
    CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.view];
    [self.homeDetails.homeDetails setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    UIView *view = [self.tableView viewWithTag:kHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    UITextField *textField = (UITextField *)[subViews objectAtIndex:1];
    if ([textField.text length] > 0 && button.tag == kLocationButtonEnableTag)
    {
        textField.text = [textField.text substringToIndex:3];
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                button.tag = kLocationButtonDisableTag;
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        button.tag = kLocationButtonEnableTag;
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
//- (void)getCurrentLocationWithAddress:(NSDictionary *)address latitude:(NSString *)latitude logitude:(NSString *)logitude
//{
//    
//}

- (void)locationUpdate:(NSNotification *)notification
{
    UIView *view = [self.tableView viewWithTag:kHeaderView];
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
    UIView *view = [self.tableView viewWithTag:kHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    if ([[UserManager shareUserManager] getLocationService])
    {
        [(UITextField *)[subViews objectAtIndex:1] setText:[location objectForKey:@"description"]];
        [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
        [(UIButton *)[subViews objectAtIndex:3] setTag:kLocationButtonEnableTag];
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
    UIView *view = [self.tableView viewWithTag:kHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    [(UITextField *)[subViews objectAtIndex:1] setText:[[UserManager shareUserManager] currentCity]];
    self.homeDetails.locationText = [[UserManager shareUserManager] currentCity];
    [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self.tableView endEditing:YES];
    if (self.tableView.contentOffset.y > 500.0)
    {
        [[self.view viewWithTag:kBeginTag] setHidden:NO];
        
    }else
    {
        [[self.view viewWithTag:kBeginTag] setHidden:YES];
    }
}

#pragma mark - Pull to refers
- (void)pullToRefresh
{
    if (self.homeDetails.homeType == refer)
    {
        [[CoreData shareData] deleteReferWithLoginId:[[UserManager shareUserManager] number]];
        [self getRefer];
    }else if (self.homeDetails.homeType == ask)
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
    [self getCarousel];
}

@end

@implementation HomeDetails
@end
