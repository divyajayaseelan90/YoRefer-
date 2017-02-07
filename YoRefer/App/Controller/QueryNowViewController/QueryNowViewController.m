//
//  QueryNowViewController.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/14/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "QueryNowViewController.h"
#import "QueryTableViewCell.h"
#import "YoReferAPI.h"
#import "CategoryType.h"
#import "Utility.h"
#import "CoreData.h"
#import "Utility.h"
#import "UIManager.h"

NSString    *   const kQueryError                      = @"Unable to get carousel";
NSString    *   const kQueryLocationMessage            = @"Yorefer would like to use your location";
NSInteger       const kQueryLocationTag                   = 60000;
NSUInteger      const kQueryNumberOfRow                =  5;
NSUInteger      const kAskTag                          = 9000;
NSUInteger      const kQueryLocationButtonEnableTag    = 13212;
NSUInteger      const kQueryLocationButtonDisableTag   = 13213;

@interface QueryNowViewController ()<queryTableViewCell,UIAlertViewDelegate,NIDropDownDelegate>

@property (nonatomic, readwrite)    QueryType                   queryType;
@property (nonatomic, strong)       NSMutableDictionary     *   queryDetail;
@property (nonatomic,readwrite)     CGFloat                     shiftForKeyboard;
@property (strong, nonatomic)       UIView                  *   dropDownView;
@property (nonatomic, strong)       NIDropDown              *   nIDropDown;

@end

@implementation QueryNowViewController

- (instancetype)initWithQueryDetail:(NSMutableDictionary *)queryDetail delegate:(id<Query>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.queryDetail = queryDetail;
    }
    return self;
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *category = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    if ([category count] == 0)
        [self getCategory];
    else
        [self reloadTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:@"locationupdating" object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark - Category Handler
- (void)getCategory
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    [[YoReferAPI sharedAPI] getCategoryWithCompletionHandler:^(NSDictionary * response, NSError * error)
    {
        [self didReceiveCategoryWithResponse:response error:error];
        
    }];
}

- (void)didReceiveCategoryWithResponse:(NSDictionary *)response error:(NSError *)error
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
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kQueryError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        [[CoreData shareData] setCategoryWithLoginId:[[UserManager shareUserManager] number] response:response];
        NSMutableArray *array = [self getCategoryWithCategoryType:kPlace];
        CategoryType *category = (CategoryType *)[array objectAtIndex:0];
        [self.queryDetail setValue:category.categoryName forKey:kCategory];
        [self.queryDetail setValue:category.categoryID forKey:kCategoryid];
        [self.queryDetail setValue:category.categoryType forKey:kCategorytype];
        [self reloadTableView];
        [self reloadTableView];
    }
}

#pragma mark - tableView datasource and delegate

-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    self.tableView.frame = CGRectMake(frame.origin.x, 0.0, frame.size.width, frame.size.height);
    [self.view layoutIfNeeded];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kQueryNumberOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  [self rowHeightWithIndexPath:indexPath];
}

- (NSInteger)rowHeightWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case QueryMessage:
            return 100.0;
            break;
        case QueryCategoryType:
            return 50.0;
            break;
        case QueryCategory:
            return 50.0;
            break;
        case QueryLocation:
            return 50.0;
            break;
        case QueryAsk:
            return 100.0;
        default:
            break;
    }
    return 0.0;
}

- (QueryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQueryReuseIdentifier];
    if (cell == nil)
    {
        cell = [[QueryTableViewCell alloc]initWithIndexPath:indexPath delegate:self queryDetail:self.queryDetail];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark - Textfield Delegate

- (void)TextFieldWithAnimation:(BOOL)animation textField:(UITextField *)textField
{
    [self.dropDownView removeFromSuperview];
    self.nIDropDown = nil;
    CGRect frame = [[textField superview].superview convertRect:[textField superview].frame toView:self.tableView];
    [self.queryDetail setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    [[KeyboardHelper sharedKeyboardHelper] animateTextField:textField isUp:animation View:self.tableView postions:frame.origin.y];
    
}

- (void)textfieldshouldChangeCharactersWithTextField:(UITextField *)textField string:(NSString *)string
{
    if ([[self.queryDetail objectForKey:@"searchtext"] length] > 0 && [[self.queryDetail objectForKey:@"searchtext"] length] - 2 == [textField.text length] && [string length] <=0)
    {
        textField.text = @"";
        [self.dropDownView removeFromSuperview];
        self.nIDropDown = nil;
        return;
    }
    if ([textField.text length] > 3)
    {
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self nIDropDownWithDetails:locationDetails view:textField.superview isLocation:YES];
            }
        }];
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }

}

#pragma mark - TextView Delegate
- (void)TextViewdWithAnimation:(BOOL)animation textView:(UITextView *)textView
{
    [self.dropDownView removeFromSuperview];
    self.nIDropDown = nil;
    CGRect frame = [[textView superview].superview convertRect:[textView superview].frame toView:self.tableView];
    [self.queryDetail setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    [[KeyboardHelper sharedKeyboardHelper] animateTextView:textView isUp:animation View:self.tableView postions:frame.origin.y];
}

- (void)queryWithMessage:(NSString *)queryMessage
{
    [self.queryDetail setValue:queryMessage forKey:kMessage];
}

#pragma mark - Location search
- (void)nIDropDownWithDetails:(NSArray *)details view:(UIView *)view isLocation:(BOOL)isLocation
{
    if(self.nIDropDown == nil)
    {
        CGFloat yPostion = [[self.queryDetail valueForKey:kYPostion] floatValue] + 36.0;
        CGFloat changedHeight = [UIScreen mainScreen].bounds.size.height - (view.frame.size.height + (yPostion + 40.0));
        self.dropDownView = [[UIView alloc]initWithFrame:CGRectMake(0.0, yPostion, view.frame.size.width, changedHeight)];
        UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(-10.0, 0.0, self.dropDownView.frame.size.width, self.dropDownView.frame.size.height)];
        CGRect btnFrame=locationBtn.frame;
        btnFrame.origin.y=0.0;
        btnFrame.origin.x = 0.0;
        btnFrame.size.height=0.0;
        locationBtn.frame=btnFrame;
        locationBtn.backgroundColor=[UIColor clearColor];
        CGFloat f = changedHeight;//([UIScreen mainScreen].bounds.size.height > 480.0)?([UIScreen mainScreen].bounds.size.height > 568.0)?220.0:171.0:83.0;
        self.nIDropDown = [[NIDropDown alloc]showDropDown:locationBtn :f :details :nil :@"down" type:isLocation];
        self.nIDropDown.delegate = self;
        [self.dropDownView addSubview:self.nIDropDown];
        [self.tableView addSubview:self.dropDownView];
    }
}

- (void)getLoaction:(NSDictionary *)location
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self.queryDetail setValue:[location objectForKey:@"description"] forKey:@"searchtext"];
    [self.queryDetail setValue:[location objectForKey:@"description"] forKey:kCity];
    [self updateQueryWithText:[location objectForKey:@"description"] queryType:QueryLocation];
    [[LocationManager shareLocationManager] getCurrentLocationAddressFromPlaceId:[location objectForKey:@"place_id"] :^(NSMutableDictionary *dictionary)
     {
         [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[dictionary valueForKey:kLatitude]] forKey:kLatitude];
         [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[dictionary valueForKey:kLongitude]] forKey:kLongitude];
         [self.queryDetail setValue:[dictionary valueForKey:@"currentAddress"] forKey:kAddress];
     }];
}

- (void)locationSearchWithButton:(UIButton *)button
{
    CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.tableView];
    [self.queryDetail setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    NSArray *subViews = [[button superview] subviews];
    UITextField *textField = [subViews objectAtIndex:0];
    if ([textField.text length] > 0 && button.tag == kQueryLocationButtonEnableTag)
    {
        textField.text = [textField.text substringToIndex:3];
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                button.tag = kQueryLocationButtonDisableTag;
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self nIDropDownWithDetails:locationDetails view:[button superview] isLocation:YES];
            }
        }];
    }else
    {
        button.tag = kQueryLocationButtonEnableTag;
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
        if ([[UserManager shareUserManager] getLocationService])
        {
            [(UITextField *)[subViews objectAtIndex:0] setText:[self.queryDetail valueForKey:@"searchtext"]];
        }else
        {
            [(UITextField *)[subViews objectAtIndex:0] setText:@""];
        }
        
    }
}

- (void)enableLocationWithButton:(UIButton *)button
{
    alertView(@"Location",kQueryLocationMessage, self, @"Yes", @"No", kQueryLocationTag);
}

- (void)updateLocation
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self locationUpdate];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
}


- (void)locationUpdate:(NSNotification *)notification
{
    if ([[UserManager shareUserManager] getLocationService])
    {
        if ([[[notification valueForKey:@"userInfo"] valueForKey:@"locationUpdated"] boolValue])
        {
            [self updateQueryWithText:@"" queryType:QueryLocation];
            [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] latitude]] forKey:kLatitude];
            [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] longitude]] forKey:kLongitude];
            [self.queryDetail setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
            [self.queryDetail setValue:[[UserManager shareUserManager] currentAddress] forKey:@"address"];
            
        }else
        {
          [self currentLocation];
        }
    }else
    {
        [self updateQueryWithText:@"" queryType:QueryLocation];
        [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] latitude]] forKey:kLatitude];
        [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] longitude]] forKey:kLongitude];
        [self.queryDetail setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
        [self.queryDetail setValue:[[UserManager shareUserManager] currentAddress] forKey:@"address"];
    }
    [self hideHUD];
}
#pragma mark - Protocol

- (void)placeWithSpuerView:(UIView *)supverView
{
    [self.tableView endEditing:YES];
    NSMutableArray *array = [self getCategoryWithCategoryType:kPlace];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.queryDetail setValue:kPlace forKey:kCategorytype];
    [self.queryDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Places];
    [self updateQueryWithText:category.categoryName queryType:QueryCategory];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIButton *button =  [self getCategoryButtonWithQueryType:QueryCategory];
    [self categoriesWithButton:button];
}

- (void)productWithSpuerView:(UIView *)supverView
{
    [self.tableView endEditing:YES];
    NSMutableArray *array = [self getCategoryWithCategoryType:kProduct];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.queryDetail setValue:kProduct forKey:kCategorytype];
    [self.queryDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Product];
    [self updateQueryWithText:category.categoryName queryType:QueryCategory];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIButton *button =  [self getCategoryButtonWithQueryType:QueryCategory];
    [self categoriesWithButton:button];
}

- (void)serviceWithSpuerView:(UIView *)supverView
{
    [self.tableView endEditing:YES];
    NSMutableArray *array = [self getCategoryWithCategoryType:kService];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.queryDetail setValue:kService forKey:kCategorytype];
    [self.queryDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Services];
    [self updateQueryWithText:category.categoryName queryType:QueryCategory];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIButton *button =  [self getCategoryButtonWithQueryType:QueryCategory];
    [self categoriesWithButton:button];
}

- (void)categoriesWithButton:(UIButton *)button
{
    [self.tableView endEditing:YES];
    if (self.nIDropDown == nil)
    {
        NSArray *array = [self getCategoryWithCategoryType:[self.queryDetail valueForKey:kCategorytype]];
        CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.tableView];
        [self.queryDetail setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
        [self nIDropDownWithDetails:array view:[button superview] isLocation:NO];
        
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    
}

- (void)getCategory:(CategoryType *)category
{
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self.queryDetail setValue:category.categoryName forKey:kCategory];
    [self.queryDetail setValue:(category.categoryID != nil && [category.categoryID isKindOfClass:[NSString class]] ? category.categoryID:@"") forKey:kCategoryid];
    [self updateQueryWithText:category.categoryName queryType:QueryCategory];
}
- (NSMutableArray *)getCategoryWithCategoryType:(NSString *)categoryType
{
    NSArray *category = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if ([categoryType isEqualToString:kPlace])
    {
        for (NSDictionary *dictionary in [category valueForKey:kPlace])
        {
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
            
        }
    }else if ([categoryType isEqualToString:kProduct])
    {
        for (NSDictionary *dictionary in [category valueForKey:kProduct]) {
            
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
            
        }
        
    }else if ( [categoryType isEqualToString:kService])
    {
        for (NSDictionary *dictionary in [category valueForKey:kService]) {
            
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
            
        }
        
    }
    return array;
}

- (void)activeCategoriesWithSubViews:(NSArray *)subViews categories:(categories)categories
{
    switch (categories) {
        case Places:
            [(UILabel *)[[[[[subViews objectAtIndex:0]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[[[[[subViews objectAtIndex:1]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:2]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            break;
        case Product:
            [(UILabel *)[[[[[subViews objectAtIndex:0]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:1]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[[[[[subViews objectAtIndex:2]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            break;
        case Services:
            [(UILabel *)[[[[[subViews objectAtIndex:0]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:1]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:2]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            break;
        default:
            break;
    }
    
}

- (void)postQuery
{
    [self.tableView endEditing:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:7];
    [params setValue:[self.queryDetail valueForKey:kCategorytype] forKey:@"type"];
    [params setValue:[self.queryDetail valueForKey:kCategory] forKey:@"category"];
    [params setValue:[self.queryDetail valueForKey:kMessage] forKey:@"askText"];
    NSString *longitude = [self.queryDetail valueForKey:kLongitude];
    NSString *latitude = [self.queryDetail valueForKey:kLatitude];
    [params setValue:[[NSArray alloc] initWithObjects:longitude,latitude,nil] forKey:kLocation];
    [params setValue:[self.queryDetail valueForKey:kAddress] forKey:@"address"];
    [params setValue:[self.queryDetail valueForKey:kCity] forKey:@"city"];
    [params setValue:[self.queryDetail valueForKey:kCategoryid] forKey:@"foursquareCategoryId"];
    [self showHUDWithMessage:@""];
    [[YoReferAPI sharedAPI] queryWithParams:params completionHandler:^(NSDictionary *response , NSError *error)
     {
         [self didReceiveQueryWithResponse:response error:error];
         
     }];
}
#pragma mark - Update View
- (void)updateQueryWithText:(NSString *)text queryType:(QueryType)queryType
{
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (QueryTableViewCell  * cell in tableSubViews)
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
                        [self updateSuperViewWithQueryType:queryType view:view text:text];
                    }
                }
            }
        }
    }
}

- (UIButton *)getCategoryButtonWithQueryType:(QueryType)queryType
{
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (QueryTableViewCell  * cell in tableSubViews)
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
                        NSArray *views = [view subviews];
                        return (UIButton *)[views objectAtIndex:2];
                    }
                }
            }
        }
    }
    return nil;
}

- (void)updateSuperViewWithQueryType:(QueryType)queryType  view:(UIView *)view text:(NSString *)text
{
    NSArray *views = [view subviews];
    switch (queryType) {
        case QueryLocation:
            [(UITextField *)[views objectAtIndex:0]setText:text];
            [(UIButton *)[views objectAtIndex:2] setTag:kQueryLocationButtonEnableTag];
            if ([[UserManager shareUserManager] getLocationService])
            {
                [(UIButton *)[views objectAtIndex:3] setHidden:YES];
                [(UITextField *)[views objectAtIndex:0]setText:([text length] > 0)?text:[[UserManager shareUserManager] currentCity]];
                if ([text length] <= 0)
                {
                    [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] latitude]] forKey:kLatitude];
                    [self.queryDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] longitude]] forKey:kLongitude];
                    [self.queryDetail setValue:[[UserManager shareUserManager] address] forKey:kAddress];
                }
            }else
            {
                [(UIButton *)[views objectAtIndex:3] setHidden:NO];
                
            }
            break;
        case QueryCategory:
            [(UITextField *)[views objectAtIndex:0]setText:text];
            break;
            default:
            break;
    }
}

#pragma mark - DropDown delegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}
-(void)rel
{
    [self.view endEditing:YES];
    self.nIDropDown = nil;
}


//Need to check
#pragma mark - Local refer
- (void)localAskWithDetails:(NSMutableDictionary *)details
{
    NSMutableArray *askDetails = [[NSMutableArray alloc]init];
    [askDetails addObject:details];
    NSArray *array = [[CoreData shareData] getLocalAskWithLoginId:[[UserManager shareUserManager] number]];
    
    if ([array count] > 0)
    {
        [askDetails addObjectsFromArray:array];
    }
    
    [[CoreData shareData] localAskWithLoginId:[[UserManager shareUserManager] number] response:askDetails];
    [[UIManager sharedManager] goToHomePageWithAnimated:YES];
    
}

- (void)postAskWithParams:(NSMutableDictionary *)params
{
    
    if (![BaseViewController isNetworkAvailable]) {
        
        [self localAskWithDetails:params];
        
    }else
    {
    
    [self showHUDWithMessage:@""];
    
    [[YoReferAPI sharedAPI] queryWithParams:params completionHandler:^(NSDictionary *response , NSError *error)
     {
         
         [self didReceiveQueryWithResponse:response error:error];
         
     }];
        
    }
    
}

- (void)didReceiveQueryWithResponse:(NSDictionary *)response error:(NSError *)error
{
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kQueryError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        NSMutableDictionary *parmas = [[YoReferUserDefaults shareUserDefaluts] objectForKey:@"login"];
        [[YoReferAPI sharedAPI] loginWithParams:parmas completionHandler:^(NSDictionary *response ,NSError *error)
        {
            [self didReceiveLoginWithResponse:response error:error];
            
        }];
    }
}

- (void)didReceiveLoginWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }
    }else
    {
        [[UserManager shareUserManager] populateUserInfoFromResponse:[[resonse objectForKey:@"response"] objectForKey:@"user"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"meprofileupdated" object:self userInfo:nil];
        [[CoreData shareData] deleteAskWithLoginId:[[UserManager shareUserManager] number]];
        [[CoreData shareData] deleteQueriesWithLoginId:[[UserManager shareUserManager] number]];
        alertView(@"Success", @"Your ask has been posted successfully. You should receive responses from your friends soon. Thank You.", self, @"Ok", nil, kAskTag);
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (alertView.tag == kAskTag)
    {
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(askPost)])
        {
            [self.delegate askPost];
            
        }
    }else if (alertView.tag == kQueryLocationTag)
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
        }
    }
}
#pragma mark - Scrollview Delegare
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView endEditing:YES];
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
