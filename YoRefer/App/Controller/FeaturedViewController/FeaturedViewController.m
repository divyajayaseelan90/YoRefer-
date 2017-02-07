//
//  FeaturedViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "FeaturedViewController.h"
#import "Configuration.h"
#import "YoReferAPI.h"
#import "Utility.h"
#import "CoreData.h"
#import "UserManager.h"
#import "FeaturedData.h"
#import "Featured.h"
#import "EntityViewController.h"


NSUInteger      const categoryTag                  = 10000;
NSUInteger      const featuredscrollViewTag        = 20000;
NSString    *   const featuredCarouselError        = @"There are no featured entries currently. Please visit again later.";
NSString    *   const categoryLoading              = @"Loading...";
NSUInteger      const featuredNumberOfSection      = 2;
NSUInteger      const featuresSectionHeight        = 40.0;
NSString    *   const kFeaturedError                  = @"Unable to get carousel";

@interface FeaturedViewController ()<UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic,strong) NSMutableArray *popular;
@property (nonatomic,strong) NSMutableArray *nearBy;
@property (nonatomic,strong) NSMutableArray *rowExpand;

@property (nonatomic, strong) UISearchBar                 *searchBar;
@property (nonatomic, strong) NSMutableArray *arrayToBeUsed;
@property (nonatomic, strong) NSArray *arrayLocationResponce;

@end

#pragma mark -implementation

@implementation FeaturedViewController


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
    
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Featured";
    self.popular = [[NSMutableArray alloc]init];
    self.nearBy = [[NSMutableArray alloc]init];
    self.rowExpand = [[NSMutableArray alloc]init];
    
    for (int i =0; i < 2; i++) {
        
        [self.rowExpand addObject:[NSNumber numberWithBool:NO]];
        
    }
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"Search";
    [_searchBar setBarStyle:UIBarStyleDefault];
//    [_searchBar setTintColor:[UIColor lightGrayColor]];
    [_searchBar setDelegate:self];
    [_searchBar setBarTintColor:[UIColor whiteColor]];
    [_searchBar setBackgroundColor:[UIColor whiteColor]];
    _searchBar.layer.cornerRadius = 8.0;
    _searchBar.layer.masksToBounds = YES;
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];

    [self.view addSubview:_searchBar];
    
    //[self reloadTableView];
    self.tableView.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    [self getFeaturedList];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    //self.searchBar.frame = CGRectMake(frame.origin.x, self.navigationController.navigationBar.frame.size.height+20, frame.size.width, 44);
     self.searchBar.frame = CGRectMake(frame.origin.x+15, self.navigationController.navigationBar.frame.size.height+28, frame.size.width-30, 45);
    
    self.tableView.frame = CGRectMake(frame.origin.x, self.searchBar.frame.origin.y+self.searchBar.frame.size.height-70, frame.size.width, frame.size.height-0.0);
    [self.view layoutIfNeeded];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)referPost
{
    
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
    [self searchWithText:searchBar.text];
//    [self reloadTableView];
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

#pragma mark - Handler
- (void)searchWithText:(NSString *)text
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:text forKey:@"query"];
    [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    [[YoReferAPI sharedAPI] searchFeaturedbyCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
        [self didReceiveSearchResponse:response error:error];
         
     }];
    
}

- (void)didReceiveSearchResponse:(NSDictionary *)response error:(NSError *)error
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
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kFeaturedError, @""), nil, @"Ok", nil, 0);
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
        array = [response valueForKey:@"response"];
        
        if ([array count] > 0)
        {
        
            NSMutableArray *popular = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in [array valueForKey:@"popular"]) {
                
                Featured *featured = [Featured getPopularWithResponse:dictionary];
                [popular addObject:featured];
            }
            
            self.popular = [self getFeaturedArrayWithArray:popular];
            
            NSMutableArray *nearBy  = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dictionary in [array valueForKey:@"nearby"]) {
                
                Featured *featured = [Featured getNearByWithResponse:dictionary];
                [nearBy addObject:featured];
            }
            
            self.nearBy = [self getFeaturedArrayWithArray:nearBy];
            
            if ([self.popular count] > 0 && [self.nearBy count] > 0) {
                [self reloadTableView];
            }
            else if ([self.popular count] > 0 || [self.nearBy count] > 0)
            {
                [self reloadTableView];
            }
            else
            {
                alertView(@"No Found", NSLocalizedString(featuredCarouselError, @""), nil, @"Ok", nil, 0);
            }
            
            //        [self reloadTableView];
        }
    }
}


/*
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    
    if (searchText.length == 0) {
        
//        [self getFeaturedList];
//        [self.tableView reloadData];
    }
    else
    {
    
        NSPredicate * myPredicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@",searchText];
//        NSPredicate * myPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF['message'] contains %@",searchText]];

        _arrayToBeUsed = [[[_arrayLocationResponce valueForKey:@"nearby"] filteredArrayUsingPredicate:myPredicate] mutableCopy];

        
        NSLog(@"Array Location Responce...%@",[_arrayToBeUsed valueForKey:@"nearby"]);

        if ([[_arrayLocationResponce valueForKey:@"nearby"] count] == 0)
        {
            
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
            
            [param setValue:[[NSMutableArray alloc] initWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
            
            [[YoReferAPI sharedAPI] featuredWithParam:param completionHandler:^(NSDictionary *response , NSError *error)
             {
                 [self didReceiveFeaturedWithResponse:response error:error];
                 
             }];
        }else
        {
            
            NSMutableArray *popular = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in [_arrayLocationResponce valueForKey:@"popular"]) {
                
                Featured *featured = [Featured getPopularWithResponse:dictionary];
                [popular addObject:featured];
                
            }
            
            self.popular = [self getFeaturedArrayWithArray:popular];
            
            NSMutableArray *nearBy  = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dictionary in [_arrayLocationResponce valueForKey:@"nearby"]) {
                
                Featured *featured = [Featured getNearByWithResponse:dictionary];
                [nearBy addObject:featured];
            }
            
            self.nearBy = [self getFeaturedArrayWithArray:nearBy];
            
            [self.tableView reloadData];
            [self hideHUD];
        }
        
    }
}
*/

#pragma  mark -
- (void)createHeadrView
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 64.0;
    CGFloat width = frame.size.width;
    CGFloat height = 160.0;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag  = categoryTag;
    [view setBackgroundColor:[UIColor grayColor]];
    
    //Carousel
    height = 120.0;
    yPos = 0.0;
    UIView *carouselView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //[carouselView setBackgroundColor:[UIColor greenColor]];
    //[carouselView addSubview:[self createScrollViewWithFrame:carouselView.frame]];
    [view addSubview:carouselView];
    
    
    //category
    yPos = carouselView.frame.size.height;
    height = view.frame.size.height - carouselView.frame.size.height;
    UIView *category = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [category setBackgroundColor:[UIColor blueColor]];
    [view addSubview:category];
    
    //places
    xPos = 0.0;
    yPos = 0.0;
    width = round(category.frame.size.width/3);
    height = category.frame.size.height;
    UIView *placesView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //placesView.tag = Places;
    UITapGestureRecognizer *placeGestureRecognizer  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeGestureTapped:)];
    [placesView addGestureRecognizer:placeGestureRecognizer];
    [placesView setBackgroundColor:[UIColor whiteColor]];
    [category addSubview:placesView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = placesView.frame.size.width;
    height = placesView.frame.size.height - 4.0;
    UILabel *placesLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
   // [placesLbl setText:[self categoryTitleWithFeaturedType:Places]];
    [placesLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [placesLbl setTextAlignment:NSTextAlignmentCenter];
    [placesView addSubview:placesLbl];
    
    width = round((placesView.frame.size.width /2));
    height = 2.0;
    xPos = round((placesView.frame.size.width - width)/2);
    yPos = placesLbl.frame.size.height;
    UIView *placeLineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [placeLineView setBackgroundColor:[UIColor redColor]];
    [placesView addSubview:placeLineView];
    
    //rightline view
    xPos = placesView.frame.size.width - 4.0;
    yPos = 0.0;
    height = placesView.frame.size.height;
    width = 0.5;
    UIView *rightPlaceLineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [rightPlaceLineView setBackgroundColor:[UIColor grayColor]];
    [placesView addSubview:rightPlaceLineView];
    
    
    //product
    xPos = placesView.frame.size.width;
    yPos = 0.0;
    width = round(category.frame.size.width/3);
    height = category.frame.size.height;
    UIView *productView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
   /// productView.tag = Product;
    UITapGestureRecognizer *productGestureRecognizer  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(productGestureTapped:)];
    [productView addGestureRecognizer:productGestureRecognizer];
    [productView setBackgroundColor:[UIColor whiteColor]];
    [category addSubview:productView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = productView.frame.size.width;
    height = productView.frame.size.height - 4.0;
    UILabel *productLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
   // [productLbl setText:[self categoryTitleWithFeaturedType:Product]];
    [productLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [productLbl setTextAlignment:NSTextAlignmentCenter];
    [productView addSubview:productLbl];
    
    width = round((productView.frame.size.width /2));
    height = 2.0;
    xPos = round((productView.frame.size.width - width)/2);
    yPos = productLbl.frame.size.height;
    UIView *productLineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [productLineView setBackgroundColor:[UIColor whiteColor]];
    [productView addSubview:productLineView];
    
    //leftLine view
    xPos = productView.frame.size.width - 4.0;
    yPos = 0.0;
    height = productView.frame.size.height;
    width = 0.5;
    UIView *leftPlaceLneView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [leftPlaceLneView setBackgroundColor:[UIColor grayColor]];
    [productView addSubview:leftPlaceLneView];
    
    
    //services
    xPos = productView.frame.origin.x + productView.frame.size.width;
    yPos = 0.0;
    height = placesView.frame.size.height;
    width = round((category.frame.size.width /3));
    UIView *servicesView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
   // servicesView.tag = Service;
    UITapGestureRecognizer *servicesGestureRecognizer  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(servicesGestureTapped:)];
    [servicesView addGestureRecognizer:servicesGestureRecognizer];
    [servicesView setBackgroundColor:[UIColor whiteColor]];
    [category addSubview:servicesView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = servicesView.frame.size.width;
    height = servicesView.frame.size.height - 4.0;
    UILabel *serviceLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
   // [serviceLbl setText:[self categoryTitleWithFeaturedType:Service]];
    [serviceLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [serviceLbl setTextAlignment:NSTextAlignmentCenter];
    [servicesView addSubview:serviceLbl];
    
    width = round((servicesView.frame.size.width /2));
    height = 2.0;
    xPos = round((servicesView.frame.size.width - width)/2);
    yPos = serviceLbl.frame.size.height;
    UIView *servicesLineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [servicesLineView setBackgroundColor:[UIColor whiteColor]];
    [servicesView addSubview:servicesLineView];
    
    [self.view addSubview:view];
    
    
}


//- (UIScrollView *)createScrollViewWithFrame:(CGRect)frame
//{
//    
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//    
//    int xPos = 0;
//    CGFloat yPos = 0.0;
//    
//    for (int i = 0; i < [self.carousel count]; i++) {
//        
//        UIView *view = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos,frame.size.width, frame.size.height)];
//        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0,view.frame.size.width, view.frame.size.height)];
//        Carousel * carousel = (Carousel *)[self.carousel objectAtIndexedSubscript:i];
//        [self loadImageWithUrl:[NSURL URLWithString:[[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"]] imageView:imageView];
//        [view addSubview:imageView];
//        
//        //address
//        CGFloat height = 20.0;
//        CGFloat padding = 4.0;
//        UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(0.0, (view.frame.size.height - height), view.frame.size.width - padding, height)];
//        [address setText:[carousel valueForKey:@"_locality"]];
//        [address setBackgroundColor:[UIColor clearColor]];
//        [address setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
//        [address setTextColor:[UIColor whiteColor]];
//        [address setTextAlignment:NSTextAlignmentRight];
//        [view addSubview:address];
//        [scrollView addSubview:view];
//        xPos = xPos + view.frame.size.width;
//    }
//    
//    scrollView.tag = featuredscrollViewTag;
//    scrollView.contentSize = CGSizeMake(xPos, scrollView.frame.size.height);
//    scrollView.delegate  = self;
//    scrollView.scrollEnabled = YES;
//    scrollView.pagingEnabled = YES;
//    scrollView.showsHorizontalScrollIndicator = NO;
//    scrollView.showsVerticalScrollIndicator = NO;
//    scrollView.scrollsToTop = NO;
//
//    return scrollView;
//    
//}



#pragma mark - Handler

- (void)getFeaturedList
{
    
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    _arrayLocationResponce = [[CoreData shareData]getFeaturedWithLoginId:[[UserManager shareUserManager] number]];
    
    if ([[_arrayLocationResponce valueForKey:@"nearby"] count] == 0)
    {
        
        
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
        
        
        [param setValue:[[NSMutableArray alloc] initWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
        
        
        [[YoReferAPI sharedAPI] featuredWithParam:param completionHandler:^(NSDictionary *response , NSError *error)
         {
            [self didReceiveFeaturedWithResponse:response error:error];
             
         }];
    }else
    {
        
        
        NSMutableArray *popular = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [_arrayLocationResponce valueForKey:@"popular"]) {
            
            Featured *featured = [Featured getPopularWithResponse:dictionary];
            [popular addObject:featured];
            
        }
        
        self.popular = [self getFeaturedArrayWithArray:popular];
        
        NSMutableArray *nearBy  = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dictionary in [_arrayLocationResponce valueForKey:@"nearby"]) {
            
            Featured *featured = [Featured getNearByWithResponse:dictionary];
            [nearBy addObject:featured];
            
        }
        
        self.nearBy = [self getFeaturedArrayWithArray:nearBy];
        
        [self reloadTableView];
        [self hideHUD];
        
    }
    
    //======================== Array To be used ===============================
    _arrayToBeUsed = [[NSMutableArray alloc]init];
    _arrayToBeUsed = [_arrayLocationResponce mutableCopy];

    NSLog(@"Near By Locations...%@", self.nearBy);
}


- (NSMutableArray *)getFeaturedArrayWithArray:(NSMutableArray *)array
{
    NSMutableArray *featured = [[NSMutableArray alloc]init];
    
    for (int i=0; i < [array count]; i++) {
        if (i < [array count] - 1)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[array objectAtIndex:i] forKey:@"begin"];
            [dic setValue:[array objectAtIndex:i+1] forKey:@"end"];
            [featured addObject:dic];
            i = i + 1;
            
        }else
        {
            
            if (i == [array count] - 1)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setValue:[array objectAtIndex:i] forKey:@"begin"];
                [featured addObject:dic];
                
            }
            
        }
        
    }
    
    return featured;
    
}


#pragma mark - Carousel

- (void)didReceiveFeaturedWithResponse:(NSDictionary *)response error:(NSError *)error
{
    
    [self hideHUD];
    
    if (error !=nil)
    {
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else if ([[[response valueForKey:@"response"] valueForKey:@"nearby"] count] <=0){
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(featuredCarouselError, @""), nil, @"Ok", nil, 0);
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(featuredCarouselError, @""), nil, @"Ok", nil, 0);
            
        }
        
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else if ([[[response valueForKey:@"response"] valueForKey:@"nearby"] count] <=0){
        
        alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(featuredCarouselError, @""), nil, @"Ok", nil, 0);
        
    }else
    {
        
        [[CoreData shareData] setFeaturedWithLoginId:[[UserManager shareUserManager] number] response:response];
        
        NSArray *array = [[CoreData shareData]getFeaturedWithLoginId:[[UserManager shareUserManager] number]];
        
        NSMutableArray *popular = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [array valueForKey:@"popular"]) {
            
            Featured *featured = [Featured getPopularWithResponse:dictionary];
            [popular addObject:featured];
            
        }
        
        self.popular = [self getFeaturedArrayWithArray:popular];
        
        NSMutableArray *nearBy  = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dictionary in [array valueForKey:@"nearby"]) {
            
            Featured *featured = [Featured getNearByWithResponse:dictionary];
            [nearBy addObject:featured];
            
        }
        
        self.nearBy = [self getFeaturedArrayWithArray:nearBy];
        
        /*
        if ([self.popular count] > 0 && [self.nearBy count] > 0) {
            [self reloadTableView];
        }
        else if ([self.popular count] > 0 || [self.nearBy count] > 0)
        {
            [self reloadTableView];
        }
        */
        [self reloadTableView];
        
    }
    
}

#pragma mark - tableview datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return featuredNumberOfSection;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if ([[self.rowExpand objectAtIndex:section] boolValue])
        return [self numberOfRownInSection:(FeaturedType)section];
    else
        return 1;
    
    
    
}

- (NSInteger)numberOfRownInSection:(FeaturedType)featuredType
{
    
    NSInteger numberOfRow;
    
    switch (featuredType) {
            
        case Popular:
            numberOfRow =[self.popular count];

            break;
            
        case FeaturedNearBy:
            numberOfRow =[self.nearBy count];
            
        default:
            break;
            
    }
    
    return numberOfRow;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 188.0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return featuresSectionHeight;
    
    
}




- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 40.0;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = section;
    [view setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewAllGestureTapped:)];
    [view addGestureRecognizer:gestureRecognizer];
    

    //title
    width = 150.0;
    height = 20.0;
    xPos = 8.0;
    yPos = round(height /2);
    UILabel *popular = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [popular setText:[self categoryTitleWithFeaturedType:(FeaturedType)section]];
    [popular setFont:[[Configuration shareConfiguration] yoReferFontWithSize:16.0]];
    [view addSubview:popular];
    
    width = 120.0;
    xPos = view.frame.size.width - (width + 15.0);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if ([[self.rowExpand objectAtIndex:section] boolValue])
        [label setText:NSLocalizedString(@"View Summary", @"")];
    else
        [label setText:NSLocalizedString(@"View All", @"")];
    
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:16.0]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [view addSubview:label];
    

    return view;
    
}

- (NSString *)categoryTitleWithFeaturedType:(FeaturedType)featuredType
{
    NSString *title = nil;
    
    switch (featuredType) {
        case Popular:
            title = @"Popular Offers";
            break;
        case FeaturedNearBy:
            title = @"Nearby Offers  ";
            break;
        default:
            break;
            
    }
    
    return title;
    
}

- (NSString *)getIdentifierWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *indetifier = nil;
    
    switch (indexPath.section) {
        case 0:
            indetifier = kFeaturedPopularIdentifier;
            break;
            
        case 1:
            indetifier = kFeaturedFeaturedNearByIdentifier;
            break;
        default:
            break;
    }
    
    return indetifier;
    
}


- (FeaturedTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   // FeaturedTableViewCell *cell;
    FeaturedTableViewCell *cell;
//    = [tableView dequeueReusableCellWithIdentifier:[self getIdentifierWithIndexPath:indexPath]];
    
    if (cell == nil)
    {
        
        cell = [[FeaturedTableViewCell alloc]initWihtIndexPath:indexPath delegate:self response:[self getFeaturedWithIndexPath:indexPath featuredType:(FeaturedType)indexPath.section]];
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
    }
    
    return cell;
    
    
}


- (Featured *)getFeaturedWithIndexPath:(NSIndexPath *)indexPath featuredType:(FeaturedType)featuredType
{
    Featured *featured;
    
    switch (featuredType) {
        case Popular:
            
            if ([self.popular count] > 0) {
                return [self.popular objectAtIndex:indexPath.row];
            }
            
            break;
        case FeaturedNearBy:
            
            if ([self.nearBy count]>0) {
                return [self.nearBy objectAtIndex:indexPath.row];
            }
            
            break;
            
        default:
            break;
    }
    
    return featured;
}

#pragma mark - GestureRecognizer
- (void)placeGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [self setSelectionWithFeaturedTyp:(FeaturedType)gestureRecognizer.view.tag];
}

- (void)productGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [self setSelectionWithFeaturedTyp:(FeaturedType)gestureRecognizer.view.tag];
    
}

- (void)servicesGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [self setSelectionWithFeaturedTyp:(FeaturedType)gestureRecognizer.view.tag];
    
}



- (void)setSelectionWithFeaturedTyp:(FeaturedType)featuredtype
{

    
    
    switch (featuredtype) {
        case Popular:
            [(UIView *)[[[[[[[self.view viewWithTag:categoryTag] subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:1] setBackgroundColor:[UIColor redColor]];
            [(UIView *)[[[[[[[self.view viewWithTag:categoryTag] subviews] objectAtIndex:1] subviews] objectAtIndex:1] subviews] objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
            [(UIView *)[[[[[[[self.view viewWithTag:categoryTag] subviews] objectAtIndex:1] subviews] objectAtIndex:2] subviews] objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
            break;
        case FeaturedNearBy:
            [(UIView *)[[[[[[[self.view viewWithTag:categoryTag] subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
            [(UIView *)[[[[[[[self.view viewWithTag:categoryTag] subviews] objectAtIndex:1] subviews] objectAtIndex:1] subviews] objectAtIndex:1] setBackgroundColor:[UIColor redColor]];
            [(UIView *)[[[[[[[self.view viewWithTag:categoryTag] subviews] objectAtIndex:1] subviews] objectAtIndex:2] subviews] objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
    
}


#pragma mark - Gesture recognizer

- (void)viewAllGestureTapped:(UIGestureRecognizer *)gestureRecognizer
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    BOOL isBoll = [[self.rowExpand objectAtIndex:indexPath.section] boolValue];
    isBoll = !isBoll;
    [self.rowExpand replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:isBoll]];
    NSRange range = NSMakeRange(indexPath.section, 1);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    
}


#pragma mark  - Protocol

- (void)getBeginViewDetailWithIndexPath:(NSIndexPath *)indexPath
{
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithIndexPath:indexPath subIndex:@"begin"]];
    [self.navigationController pushViewController:vctr animated:YES];

    
}


- (void)getEndViewDetailWithIndexPath:(NSIndexPath *)indexPath
{
 
    
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithIndexPath:indexPath subIndex:@"end"]];
    [self.navigationController pushViewController:vctr animated:YES];
    
}


- (NSMutableDictionary *)getReferDetailWithIndexPath:(NSIndexPath *)indexPath subIndex:(NSString *)subIndex
{
    NSMutableArray *array = [self getSelctionFeaturedWithFeaturedTyep:(FeaturedType)indexPath.section];
    Featured *featured = (Featured *)[[array objectAtIndex:indexPath.row] valueForKey:subIndex];
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    if([[featured.entity valueForKey:@"mediaLinks"]count] > 0)
        [dictionary setValue:[[featured.entity valueForKey:@"dp"] objectForKey:@"mediaId"] forKey:@"referimage"];
    [dictionary setValue:featured.type forKey:@"categorytype"];
    [dictionary setValue:[featured.entity objectForKey:@"name"] forKey:@"name"];
    [dictionary setValue:[featured.entity objectForKey:@"category"] forKey:@"category"];
    [dictionary setValue:featured.message forKey:@"message"];
    [dictionary setValue:[featured.entity objectForKey:@"entityId"] forKey:@"entityId"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refer"];
    
    if ([featured.type  isEqualToString:@"product"])
    {
        
        [dictionary setValue:[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"position"] forKey:@"position"];
        [dictionary setValue:[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"locality"] forKey:@"location"];
        [dictionary setValue:[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"phone"] forKey:@"phone"];
        [dictionary setValue:[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"website"] forKey:@"website"];
        [dictionary setValue:[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"city"] forKey:@"address"];
        if ([[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"position"] count] > 0)
        {
            
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"position"] objectAtIndex:1]] forKey:@"latitude"];
            [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[featured.entity objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"position"] objectAtIndex:0]] forKey:@"longitude"];
            
        }
        
        
    }else
    {
        
        [dictionary setValue:[featured.entity objectForKey:@"city"] forKey:kCity];
        [dictionary setValue:[featured.entity objectForKey:@"city"] forKey:@"searchtext"];
        [dictionary setValue:[featured.entity objectForKey:@"locality"] forKey:@"location"];
        [dictionary setValue:[featured.entity objectForKey:@"phone"] forKey:@"phone"];
        [dictionary setValue:[featured.entity objectForKey:@"website"] forKey:@"website"];
        [dictionary setValue:[NSNumber numberWithBool:1] forKey:kIsEntity];
        if ([featured.location count] > 0)
        {
            
            [dictionary setValue:[NSString stringWithFormat:@"%@",[featured.location objectAtIndex:0]] forKey:@"longitude"];
            [dictionary setValue:[NSString stringWithFormat:@"%@",[featured.location objectAtIndex:1]] forKey:@"latitude"];
            
        }
        
        
    }
    
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isentiyd"];
    
    
    
    return dictionary;
    
    
}



- (void)getBeginReferNowWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self getReferDetailWithIndexPath:indexPath subIndex:@"begin"] delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)getEndRefrNowWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self getReferDetailWithIndexPath:indexPath subIndex:@"end"] delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)getBeginIndexPath:(NSIndexPath *)indexPath
{
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithIndexPath:indexPath subIndex:@"begin"]];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (NSMutableDictionary *)getEntityDetailWithIndexPath:(NSIndexPath *)indexPath subIndex:(NSString *)subIndex
{
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    NSMutableArray *array = [self getSelctionFeaturedWithFeaturedTyep:(FeaturedType)indexPath.section];
    Featured *featured = (Featured *)[[array objectAtIndex:indexPath.row] valueForKey:subIndex];
    [response setValue:[featured.entity valueForKey:@"name"] forKey:@"name"];
    [response setValue:featured.entity forKey:@"entity"];
    [response setValue:featured.type forKey:@"type"];
    [response setValue:[featured.entity valueForKey:@"category"] forKey:@"category"];
    [response setValue:[featured.entity objectForKey:@"locality"] forKey:@"locality"];
    [response setValue:[featured.entity objectForKey:@"phone"] forKey:@"phone"];
    [response setValue:[featured.entity objectForKey:@"position"] forKey:@"location"];
    [response setValue:[featured.entity objectForKey:@"website"] forKey:@"web"];
    [response setValue:featured.message forKey:@"message"];
    [response setValue:[featured.entity valueForKey:@"referCount"] forKey:@"refercount"];
    [response setValue:[featured.entity valueForKey:@"mediaCount"] forKey:@"mediacount"];
    [response setValue:[featured.entity valueForKey:@"mediaLinks"] forKey:@"medialinks"];
    [response setValue:featured.entityId forKey:@"entityid"];
    [response setValue:[[featured.entity objectForKey:@"dp"] objectForKey:@"mediaId"] forKey:@"mediaid"];

   
    
    return  response;
    
}

- (void)getEndIndexPath:(NSIndexPath *)indexPath
{
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithIndexPath:indexPath subIndex:@"end"]];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (NSMutableArray *)getSelctionFeaturedWithFeaturedTyep:(FeaturedType)featuredType
{
    NSMutableArray * featured = nil;
    
    switch (featuredType) {
        case Popular:
            featured = self.popular;
            break;
        case FeaturedNearBy:
            featured = self.nearBy;
            break;
            
        default:
            break;
    }
    
    return featured;
    
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
