//
//  CategoryListViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "CategoryListViewController.h"
#import "Configuration.h"
#import "UserManager.h"
#import "CoreData.h"c
#import "Utility.h"
#import "YoReferAPI.h"
#import "UserManager.h"
#import "EntityViewController.h"
#import "YoReferUserDefaults.h"
#import "WebViewController.h"

NSString    *   const kCategoryListNowError        = @"Unable to get carousel";
NSString    *   const kCategoryListLoading         = @"Loading...";
NSUInteger      const kCategoryPageLimit           = 30;
NSString    *   const kCategoryError                  = @"Unable to get carousel";

@interface CategoryListViewController ()<UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, readwrite) categoryList   categoriesList;
@property (nonatomic, strong) NSArray          *place, *product, *service ,*web;
@property (nonatomic, strong) NSMutableDictionary *category,*categoryList,*categoryListType;
@property (nonatomic, strong) NSMutableArray *referResponse;
@property (nonatomic ,strong) UIBarButtonItem * rightButton;
@property (nonatomic ,strong) NSMutableArray *toolbarButtons;
@property (nonatomic, strong) NSString *selectedName;
@property (nonatomic, readwrite) NSInteger isPage;

@property (nonatomic, strong) UISearchBar                 *searchBar;
@property (nonatomic, strong) NSMutableDictionary *dictToBeUsed;


@end

@implementation CategoryListViewController


#pragma mark - instancetype
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
    
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolbarButtons = [self.toolbarItems mutableCopy];
    self.isPage = 0;
    
    self.navigationItem.title = NSLocalizedString(@"Category List", @"");
    self.categoryList = [[NSMutableDictionary alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    self.tableView.tableFooterView = [UIView new];
    self.categoriesList = PlacesList;
    self.place = [[NSArray alloc]init];
    self.product = [[NSArray alloc]init];
    self.service = [[NSArray alloc]init];
    self.web = [[NSArray alloc]init];
    [self createHeaderView];
    [self getCategory];
    
   
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITabBarController *tabBarController = (id)self.revealViewController.frontViewController;
    [tabBarController.tabBar setHidden:NO];
    [self.appDelegate DCButtonWithStatus:NO];
    
    
}

- (void)referPost
{
    
}

-(void)viewDidLayoutSubviews
{
    
    CGRect frame  = [self bounds];
    
    //self.searchBar.frame = CGRectMake(frame.origin.x, self.navigationController.navigationBar.frame.size.height+20, frame.size.width, 44);
    self.searchBar.frame = CGRectMake(frame.origin.x+15, self.navigationController.navigationBar.frame.size.height+28, frame.size.width-30, 45);

    self.tableView.frame = CGRectMake(frame.origin.x, 120.0, frame.size.width, frame.size.height-136.0);
    [self.view layoutIfNeeded];
    
    
}


- (void)createHeaderView
{
       
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 55.0;
    CGFloat width = frame.size.width;
    CGFloat height = 120.0;
    
    
    UIView *categoryView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [categoryView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    [self.view addSubview:categoryView];
    
//    height = 190.0;
//    UIImageView *bannerImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
//    bannerImage.image = [UIImage imageNamed:@"icon_banner.png"];
    //[view addSubview:bannerImage];
    
    yPos = 69.0;
    height = 40.0;
    xPos = 10.0;
    width = categoryView.frame.size.width - 2 * xPos;
    UIView *viewCategories = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewCategories.backgroundColor = [UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(6.0/255.0) alpha:1.0f];
    viewCategories.tag = 10;
    viewCategories.layer.cornerRadius = 18.0;
    viewCategories.layer.masksToBounds = YES;
    [categoryView addSubview:viewCategories];
    
    //place label
    width = viewCategories.frame.size.width/4;
    height = viewCategories.frame.size.height - 2.0;
    xPos = 1.0;
    yPos = 1.0;
    UILabel *placeLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Places"];
    placeLabel.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
    placeLabel.userInteractionEnabled = YES;
    placeLabel.tag = PlacesList;
    placeLabel.textColor = [UIColor whiteColor];
    placeLabel.layer.cornerRadius = 17.0;
    placeLabel.layer.masksToBounds = YES;
    [viewCategories addSubview:placeLabel];
    //product label
    xPos = placeLabel.frame.size.width + 3.0;
    yPos = 1.0;
    width = (viewCategories.frame.size.width/4) - 1.0;
    height = viewCategories.frame.size.height - 2.0;
    UILabel *productLabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Products"];
    productLabel.userInteractionEnabled = YES;
    productLabel.tag = ProductList;
    productLabel.backgroundColor = [UIColor clearColor];
    productLabel.textColor = [UIColor grayColor];
    productLabel.layer.cornerRadius = 17.0;
    productLabel.layer.masksToBounds = YES;
    [viewCategories addSubview:productLabel];
    //service label
    xPos = productLabel.frame.size.width + productLabel.frame.origin.x + 7.0;
    yPos = 1.0;
    width = (viewCategories.frame.size.width/4);
    height = viewCategories.frame.size.height - 3.0;
    UILabel *servicelabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Services", nil)];
    servicelabel.userInteractionEnabled = YES;
    servicelabel.tag = ServicesList;
    servicelabel.backgroundColor = [UIColor clearColor];
    servicelabel.textColor = [UIColor grayColor];
    servicelabel.layer.cornerRadius = 17.0;
    servicelabel.layer.masksToBounds = YES;
    [viewCategories addSubview:servicelabel];
    //web label
    xPos = servicelabel.frame.size.width + servicelabel.frame.origin.x;
    yPos = 1.0;
    width = (viewCategories.frame.size.width/4) - 10.0;
    height = viewCategories.frame.size.height - 2.0;
    UILabel *weblabel = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:NSLocalizedString(@"Web", nil)];
    weblabel.userInteractionEnabled = YES;
    weblabel.tag = WebList;
    weblabel.backgroundColor = [UIColor clearColor];
    weblabel.textColor = [UIColor grayColor];
    weblabel.layer.cornerRadius = 17.0;
    weblabel.layer.masksToBounds = YES;
    [viewCategories addSubview:weblabel];
    
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

    [self.view addSubview:_searchBar]; // I think this should have loaded the searchBar but doesn't
    
    
    //GestureRecognizer
    UITapGestureRecognizer *placeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeListGestureTapped:)];
    [placeLabel addGestureRecognizer:placeGestureRecognizer];
    
    UITapGestureRecognizer *productGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(productListGestureTapped:)];
    [productLabel addGestureRecognizer:productGestureRecognizer];
    
    UITapGestureRecognizer *serviceGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(serviceListGestureTapped:)];
    [servicelabel addGestureRecognizer:serviceGestureRecognizer];
    
    UITapGestureRecognizer *webGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webListGestureTapped:)];
    [weblabel addGestureRecognizer:webGestureRecognizer];
    
//    xPos = 0.0;
//    yPos = 0.0;
//    height = viewCategories.frame.size.height;
//    width = viewCategories.frame.size.width/4;
//    UIView *viewPlace = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewPlace.backgroundColor = [UIColor clearColor];
//    [viewCategories addSubview:viewPlace];
//    
//    UILabel *labelPlace = [self createLabelWithFrame:viewPlace.frame text:NSLocalizedString(@"Place", @"")];
//    labelPlace.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0];
//    [viewPlace addSubview:labelPlace];
//    
//    xPos = viewPlace.frame.size.width;
//    yPos = 0.0;
//    height = viewCategories.frame.size.height;
//    width = 1.0;
//    UIView *viewPlaceLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewPlaceLine.backgroundColor = [UIColor grayColor];
//    [viewCategories addSubview:viewPlaceLine];
//    
//    xPos = viewPlace.frame.size.width;
//    height = viewCategories.frame.size.height;
//    width = viewCategories.frame.size.width/4;
//    UIView *viewProduct = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewProduct.backgroundColor = [UIColor clearColor];
//    [viewCategories addSubview:viewProduct];
//    
//    UILabel *labelProduct = [self createLabelWithFrame:viewPlace.frame text:NSLocalizedString(@"Product", @"")];
//    labelProduct.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0];
//    [viewProduct addSubview:labelProduct];
//    
//    xPos = viewPlace.frame.size.width + viewProduct.frame.size.width;
//    yPos = 0.0;
//    height = viewCategories.frame.size.height;
//    width = 1.0;
//    UIView *viewProductLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewProductLine.backgroundColor = [UIColor grayColor];
//    [viewCategories addSubview:viewProductLine];
//    
//    xPos = viewPlace.frame.size.width + viewProduct.frame.size.width;
//    height = viewCategories.frame.size.height;
//    width = viewCategories.frame.size.width/4;
//    UIView *viewService = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewService.backgroundColor = [UIColor clearColor];
//    [viewCategories addSubview:viewService];
//    
//    UILabel *labelService = [self createLabelWithFrame:viewPlace.frame text:NSLocalizedString(@"Service", @"")];
//    labelService.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0];
//    [viewService addSubview:labelService];
//    
//    xPos = viewPlace.frame.size.width + viewProduct.frame.size.width + viewService.frame.size.width;
//    height = viewCategories.frame.size.height;
//    width = viewCategories.frame.size.width/4;
//    UIView *viewWeb = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewWeb.backgroundColor = [UIColor clearColor];
//    [viewCategories addSubview:viewWeb];
//    
//    UILabel *labelWeb = [self createLabelWithFrame:CGRectMake(0.0, 0.0, viewCategories.frame.size.width/4,viewWeb.frame.size.height) text:NSLocalizedString(@"Web", @"")];
//    labelWeb.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0];
//    [viewWeb addSubview:labelWeb];
//    
//    xPos = viewService.frame.size.width - 2.0;
//    yPos = 0.0;
//    height = viewCategories.frame.size.height;
//    width = 1.0;
//    UIView *viewServiceLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewServiceLine.backgroundColor = [UIColor grayColor];
//    [viewService addSubview:viewServiceLine];
//    
//    width = 42.0;
//    yPos  = viewPlace.frame.size.height - 6.0;
//    height = 2.0;
//    xPos = (viewPlace.frame.size.width - width)/2;
//    UIView *placeLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    placeLine.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
//    placeLine.tag = PlacesList;
//    [viewPlace addSubview:placeLine];
//    
//    width = 60.0;
//    yPos  = viewProduct.frame.size.height - 6.0;
//    xPos = (viewProduct.frame.size.width - width)/2;
//    UIView *productLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    productLine.tag = ProductList;
//    productLine.backgroundColor = [UIColor clearColor];
//    [viewProduct addSubview:productLine];
//    
//    width = 57.0;
//    yPos  = viewService.frame.size.height - 6.0;
//    xPos = (viewService.frame.size.width - width)/2;
//    UIView *serviceLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    serviceLine.tag = ServicesList;
//    serviceLine.backgroundColor = [UIColor clearColor];
//    [viewService addSubview:serviceLine];
//    
//    width = 42.0;
//    yPos  = viewWeb.frame.size.height - 6.0;
//    xPos = (viewWeb.frame.size.width - width)/2;
//    UIView *viewWebLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
//    viewWebLine.tag = WebList;
//    viewWebLine.backgroundColor = [UIColor clearColor];
//    [viewWeb addSubview:viewWebLine];
//    
//    UITapGestureRecognizer *placeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeListGestureTapped:)];
//    [viewPlace addGestureRecognizer:placeGestureRecognizer];
//    
//    UITapGestureRecognizer *productGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(productListGestureTapped:)];
//    [viewProduct addGestureRecognizer:productGestureRecognizer];
//    
//    UITapGestureRecognizer *serviceGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(serviceListGestureTapped:)];
//    [viewService addGestureRecognizer:serviceGestureRecognizer];
//    
//    UITapGestureRecognizer *webGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webListGestureTapped:)];
//    [viewWeb addGestureRecognizer:webGestureRecognizer];
    
    
}





- (UIView *)createViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    return view;
    
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



#pragma mark - Handler

- (void)getCategory
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    
    self.categoryListType = (NSMutableDictionary *)[[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    
    self.categoryList =  [self getCategoryWithList:(NSDictionary *)[[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]]];
    
    if ([self.categoryList  count] > 0)
    {
        
         self.categoriesList = PlacesList;
        
//        NSArray *place = [categoryListType valueForKey:@"place"];
//        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//        NSArray  *sortArray = [place sortedArrayUsingDescriptors:@[sort]];
//        self.place = sortArray;
         [self reloadTableView];
        [self hideHUD];
        
    }else
    {
        
        [[YoReferAPI sharedAPI] getCategoryWithCompletionHandler:^(NSDictionary * response, NSError * error){
            
            [self didReceiveCategoryWithResponse:response error:error];
            
        }];
        
    }
    
}

- (void)didReceiveCategoryWithResponse:(NSDictionary *)response error:(NSError *)error{
    
    
    [self hideHUD];
    
    if (error !=nil)
    {
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kCategoryListNowError, @""), nil, @"Ok", nil, 0);
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else
    {
        
        [[CoreData shareData] setCategoryWithLoginId:[[UserManager shareUserManager] number] response:response];
        
        self.categoryListType = (NSMutableDictionary *)[[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
        
        self.categoryList =  [self getCategoryWithList:(NSDictionary *)[[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]]];
        
        if ([self.categoryList  count] > 0)
        {
            
            self.categoriesList = PlacesList;
            
            //        NSArray *place = [categoryListType valueForKey:@"place"];
            //        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            //        NSArray  *sortArray = [place sortedArrayUsingDescriptors:@[sort]];
            //        self.place = sortArray;
            [self reloadTableView];
            [self hideHUD];
            
        }
        
        
    }
    
    
    
}


- (void)categoryListWithIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - 

- (NSMutableDictionary *)getCategoryWithList:(NSDictionary *)categoryList
{
    NSMutableDictionary *categoryType = [[NSMutableDictionary alloc]init];
    
    for (NSString *key in categoryList) {
        
        NSArray *indexTitle = [self getIndexTitle];
        NSArray *listvalue = [categoryList objectForKey:key];
        
        NSMutableDictionary *category = [[NSMutableDictionary alloc]init];
        
        for (int i =0; i < [indexTitle count]; i++) {
            
            NSMutableArray *array = [[NSMutableArray alloc]init];
            
            for (int j =0; j < [listvalue count]; j++) {
                
                if([[[[[listvalue objectAtIndex:j] objectForKey:@"name"] substringToIndex:1] capitalizedString] isEqualToString:[indexTitle objectAtIndex:i]])
                {
                    
                    [array addObject:[listvalue objectAtIndex:j]];
                    
                }
                
            }
            
            if([array count] > 0)
                [category setValue:array forKey:[indexTitle objectAtIndex:i]];
            
        }
        
        [categoryType setValue:category forKey:key];
        
    }
    
    return categoryType;
    
}
- (NSArray *)getIndexTitle
{
    
    static NSArray *indexTitle = nil;
    
    if(indexTitle==nil){
        
        indexTitle = [[NSArray alloc]initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
        
    }
    
    return indexTitle;
    
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

#pragma mark - Handler
- (void)searchWithText:(NSString *)text
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:text forKey:@"query"];
//    [params setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
    [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    
    // http://54.165.84.198:8080/irefer/api/refer/entitylookup?query=dunkin
    
    
    [[YoReferAPI sharedAPI] searchCategoryByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
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
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kCategoryError, @""), nil, @"Ok", nil, 0);
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
        self.navigationItem.title = self.selectedName;
        self.referResponse = [[NSMutableArray alloc]init];
        self.referResponse = [response objectForKey:@"response"];
        
        NSMutableDictionary *referals = [[NSMutableDictionary alloc]init];
        NSMutableArray *referalArray = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dictionary in self.referResponse) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[dictionary objectForKey:@"dp"] forKey:@"dp"];
            [dic setValue:[[dictionary objectForKey:@"entity"]objectForKey:@"name"] forKey:@"name"];
            [dic setValue:[[dictionary objectForKey:@"entity"]objectForKey:@"locality"] forKey:@"locality"];
            
            
            [referalArray addObject:dic];
            
        }
        
        [referals setValue:referalArray forKey:@"response"];
        
        
        
        UIView *categoryView  = [[CategoriesView alloc] initWithViewFrame:self.view.frame categoryList:response delegate:self isResponse:NO];
        [[YoReferUserDefaults shareUserDefaluts] setValue:@"Hide" forKey:@"Header"];
        categoryView.tag = 40000;
        [categoryView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:categoryView];
        categoryView.frame = CGRectMake(0.0, [self bounds].size.height - 59.0, [self bounds].size.width, [self bounds].size.height - 60.0);
        
        categoryView.frame = CGRectMake(0.0, 59.0, [self bounds].size.width, [self bounds].size.height - 60.0);
        self.rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_plusmall.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
        self.navigationItem.rightBarButtonItem = self.rightButton;
        [self.toolbarButtons addObject:self.rightButton];
        [self setToolbarItems:self.toolbarButtons animated:NO];
        //            [UIView animateWithDuration:0.4
        //                                  delay:0.0
        //                                options: UIViewAnimationOptionCurveEaseIn
        //                             animations:^{
        //                                 categoryView.frame = CGRectMake(0.0, 59.0, [self bounds].size.width, [self bounds].size.height - 60.0);
        //                                 self.rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_plusmall.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
        //                                 self.navigationItem.rightBarButtonItem = self.rightButton;
        //                                  [self.toolbarButtons addObject:self.rightButton];
        //                                 [self setToolbarItems:self.toolbarButtons animated:NO];
        //                             }
        //                             completion:^(BOOL finished){
        //                             }];
        //
        //
    }
}


#pragma mark - GestureRecognizer

- (void)selectCategoryWithCategoryList:(categoryList)categoryList
{
    
    switch (categoryList) {
        case PlacesList:
            [(UILabel *)[self.view viewWithTag:PlacesList] setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setTextColor:[UIColor whiteColor]];
            [(UILabel *)[self.view viewWithTag:ProductList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:ProductList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:ServicesList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:ServicesList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setTextColor:[UIColor grayColor]];
            break;
        case ProductList:
            [(UILabel *)[self.view viewWithTag:ProductList] setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[self.view viewWithTag:ProductList] setTextColor:[UIColor whiteColor]];
            [(UILabel *)[self.view viewWithTag:ServicesList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:ServicesList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setTextColor:[UIColor grayColor]];
            break;
        case ServicesList:
            [(UILabel *)[self.view viewWithTag:ServicesList] setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[self.view viewWithTag:ServicesList] setTextColor:[UIColor whiteColor]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:ProductList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:ProductList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setTextColor:[UIColor grayColor]];
            break;
        case WebList:
            [(UILabel *)[self.view viewWithTag:ServicesList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:ServicesList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:PlacesList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:ProductList] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[self.view viewWithTag:ProductList] setTextColor:[UIColor grayColor]];
            [(UILabel *)[self.view viewWithTag:WebList] setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[self.view viewWithTag:WebList] setTextColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
    
    
}
- (void)placeListGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.categoriesList = PlacesList;
    [self selectCategoryWithCategoryList:self.categoriesList];
    NSArray *categoryListType = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    
    NSArray *place = [categoryListType valueForKey:@"place"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray  *sortArray = [place sortedArrayUsingDescriptors:@[sort]];
    
    self.place = sortArray;
    
   
    
    
    [self reloadTableView];
    
}

- (void)productListGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.categoriesList = ProductList;
    [self selectCategoryWithCategoryList:self.categoriesList];
    NSArray *categoryListType = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSArray *product = [categoryListType valueForKey:@"product"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray  *sortArray = [product sortedArrayUsingDescriptors:@[sort]];
    self.product = sortArray;
    [self reloadTableView];
    
}

- (void)webListGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.categoriesList = WebList;
    [self selectCategoryWithCategoryList:self.categoriesList];
     NSArray *categoryListType = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSArray *service = [categoryListType valueForKey:@"web"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray  *sortArray = [service sortedArrayUsingDescriptors:@[sort]];
    self.web = sortArray;
    [self reloadTableView];
}

- (void)serviceListGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.categoriesList = ServicesList;
    [self selectCategoryWithCategoryList:self.categoriesList];
    NSArray *categoryListType = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    
    NSArray *service = [categoryListType valueForKey:@"service"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray  *sortArray = [service sortedArrayUsingDescriptors:@[sort]];
    self.service = sortArray;
    
    [self reloadTableView];
    
}



#pragma mark - tableview datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return  [[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] count];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSection"]]];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{

    return [[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] indexOfObject:title];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40.0;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
   return [[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] objectForKey:[[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
    
    
}

- (CategoryListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CategoryListTableViewCell *cell;
    
    if (cell == nil)
    {
        NSDictionary *dic = [[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] objectForKey:[[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        if (self.categoriesList == PlacesList) {
            
            cell = [[CategoryListTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:dic categorytype:self.categoriesList];
        }else if (self.categoriesList == ProductList){
            cell = [[CategoryListTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:dic categorytype:self.categoriesList];
        }else if (self.categoriesList == ServicesList){
            cell = [[CategoryListTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:dic categorytype:self.categoriesList];
        }else{
            cell = [[CategoryListTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:dic categorytype:self.categoriesList];
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
    }
    
    return cell;
    
}


- (NSMutableDictionary *)getReferNowDetailWithCategoryListType:(categoryList)categoryListType indexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    switch (categoryListType) {
        case PlacesList:
            [dictionary setValue:[[self.place objectAtIndex:indexPath.row] objectForKey:@"type"] forKey:@"categorytype"];
            [dictionary setValue:[[self.place objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"category"];
            [dictionary setValue:[[self.place objectAtIndex:indexPath.row] objectForKey:@"categoryId"] forKey:@"categoryid"];
            //categoryid
            break;
        case ProductList:
            [dictionary setValue:[[self.product objectAtIndex:indexPath.row] objectForKey:@"type"] forKey:@"categorytype"];
            [dictionary setValue:[[self.product objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"category"];
            [dictionary setValue:[[self.product objectAtIndex:indexPath.row] objectForKey:@"categoryId"] forKey:@"categoryid"];
            break;
            
        case ServicesList:
            [dictionary setValue:[[self.service objectAtIndex:indexPath.row] objectForKey:@"type"] forKey:@"categorytype"];
            [dictionary setValue:[[self.service objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"category"];
            [dictionary setValue:[[self.service objectAtIndex:indexPath.row] objectForKey:@"categoryId"] forKey:@"categoryid"];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"contactcategory"];
            break;
        default:
            break;
    }
    
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:@"address"];
    [dictionary setValue:[[UserManager shareUserManager] currentAddress] forKey:@"location"];
    [dictionary setValue:[[UserManager shareUserManager] latitude] forKey:@"latitude"];
    [dictionary setValue:[[UserManager shareUserManager] longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"newrefer"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isentiyd"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refer"];

    return dictionary;
    
    
}

- (NSMutableDictionary *)setDefaultRefer
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[self.category objectForKey:@"categorytype"] forKey:@"categorytype"];
    [dictionary setValue:[self.category objectForKey:@"category"] forKey:@"category"];
    [dictionary setValue:[self.category objectForKey:@"categoryId"] forKey:@"categoryid"];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:kCity];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:@"searchtext"];
    [dictionary setValue:@"" forKey:@"location"];
    [dictionary setValue:[[UserManager shareUserManager] latitude] forKey:@"latitude"];
    [dictionary setValue:[[UserManager shareUserManager] longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"newrefer"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isentiyd"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refer"];
    
    
    return dictionary;
    
    
}

- (NSMutableDictionary *)setReferWithCategoryList:(NSDictionary *)categoryList
{
    
     NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    [dictionary setValue:[categoryList objectForKey:@"type"] forKey:@"categorytype"];
    [dictionary setValue:[categoryList objectForKey:@"category"] forKey:@"category"];
    [dictionary setValue:[categoryList objectForKey:@"categoryId"] forKey:@"categoryid"];
    [dictionary setValue:[categoryList objectForKey:@"name"] forKey:@"name"];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:kCity];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:@"searchtext"];
    [dictionary setValue:[[UserManager shareUserManager] currentAddress] forKey:@"location"];
    [dictionary setValue:[[UserManager shareUserManager] latitude] forKey:@"latitude"];
    [dictionary setValue:[[UserManager shareUserManager] longitude] forKey:@"longitude"];
    [dictionary setValue:[[categoryList objectForKeyedSubscript:@"entity"] objectForKeyedSubscript:@"city"] forKey:@"address"];
    [dictionary setValue:[categoryList objectForKeyedSubscript:@"locality"] forKey:@"location"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"newrefer"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isentiyd"];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[[categoryList objectForKey:@"position"] objectAtIndex:1]] forKey:@"latitude"];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[[categoryList objectForKey:@"position"] objectAtIndex:0]] forKey:@"longitude"];
    [dictionary setValue:[[categoryList objectForKey:@"entity"] objectForKeyedSubscript:@"phone"] forKey:@"phone"];
    
    if ([categoryList objectForKey:@"dp"] != nil && [[categoryList objectForKey:@"dp"] isKindOfClass:[NSString class]] > 0)
        [dictionary setValue:[categoryList objectForKey:@"dp"] forKey:@"referimage"];
    
    [dictionary setValue:[[categoryList objectForKey:@"entity"] objectForKeyedSubscript:@"website"] forKey:@"website"];
    [dictionary setValue:[[[categoryList objectForKey:@"entity"] objectForKeyedSubscript:@"dp"] objectForKey:@"entityId"] forKey:@"entityId"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refer"];
    
    return dictionary;
    
}

-(NSInteger)returnIndexWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSArray *array = [self.categoryListType objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"];
    
    for ( int i=0; i < [array count]; i++) {
        
        NSDictionary *category = [array objectAtIndex:i];
        
         NSDictionary *selectedCategory = [[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] objectForKey:[[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        
        if ([[category objectForKey:@"name"] isEqualToString:[selectedCategory objectForKey:@"name"]])
        {
            
            return i;
            
        }
        
    }
    
    return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    NSDictionary *dic = [[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] objectForKey:[[[[self.categoryList objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    self.selectedName = [dic valueForKey:@"name"];
    
    NSInteger selectedIndexPath = [self returnIndexWithIndexPath:indexPath];
    
    NSString *categoryType, *category ,*categoryId;
    [self showHUDWithMessage:@""];
    
    NSArray *categoryListType = [self.categoryListType objectForKey:(self.categoriesList == PlacesList)?@"place":(self.categoriesList == ProductList)?@"product":(self.categoriesList == ServicesList)?@"service":@"web"];
    
    NSDictionary *dictionary = [categoryListType objectAtIndex:selectedIndexPath];
    
    if (self.categoriesList == PlacesList) {
        categoryType = @"place";
        category = [dictionary valueForKey:@"name"];
        categoryId  = [dictionary objectForKey:@"categoryId"];
    }else if (self.categoriesList == ProductList){
        categoryType = @"product";
        category = [dictionary valueForKey:@"name"];
        categoryId  = [dictionary objectForKey:@"categoryId"];
    }else if (self.categoriesList == ServicesList){
        categoryType = @"service";
        category = [dictionary valueForKey:@"name"];
        categoryId  = [dictionary objectForKey:@"categoryId"];
    }else{
        categoryType = @"web";
        category = [dictionary valueForKey:@"name"];
        categoryId  = [dictionary objectForKey:@"categoryId"];
    }
    
    
    
    
    if (!self.category)
        self.category = [[NSMutableDictionary alloc]init];
    
    
    [self.category setValue:categoryType  forKey:@"categorytype"];
    [self.category setValue:category forKey:@"category"];
    [self.category setValue:categoryId forKey:@"categoryid"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    NSArray *array = [[NSArray alloc]initWithObjects: [[UserManager shareUserManager]latitude], [[UserManager shareUserManager]longitude], nil];
    [params setValue:array forKey:@"location"];
    [params setValue:categoryType forKey:@"type"];
    [params setValue:category forKey:@"category"];
    [params setValue:@"-1" forKey:@"radius"];
    //[params setValue:[NSNumber numberWithInteger:self.isPage] forKey:@"page"];
    //[params setValue:[NSNumber numberWithInteger:kCategoryPageLimit] forKey:@"limit"];
    //limit page
    //radius -1
    [[YoReferAPI sharedAPI] categoryWithParams:params completionHandler:^(NSDictionary *response ,NSError *error){
        
        [self didReceiveCategoryReferWithResponse:response error:error];
        
    }];
    
}

- (NSMutableDictionary *)getEntityDetailWithCategoryList:(NSDictionary *)categoryList
{
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
   
    [response setValue:[categoryList objectForKey:@"name"] forKey:@"name"];
    [response setValue:[categoryList objectForKey:@"category"] forKey:@"category"];
    [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"referCount"] forKey:@"refercount"];
    [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"mediaCount"] forKey:@"mediacount"];
    [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"mediaLinks"] forKey:@"medialinks"];
    [response setValue:[categoryList objectForKey:@"entityId"] forKey:@"entityid"];
    [response setValue:[categoryList objectForKey:@"type"] forKey:@"type"];
    [response setValue:[categoryList objectForKey:@"entity"] forKey:@"entity"];
    [response setValue:[[[categoryList valueForKey:@"entity"] objectForKey:@"dp"] objectForKey:@"mediaId"] forKey:@"mediaid"];
    
    if ([[categoryList objectForKey:@"type"]  isEqualToString:@"product"])
    {
        [response setValue:[[[[categoryList valueForKey:@"entity"] objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"position"] forKey:@"position"];
        [response setValue:[[[[categoryList valueForKey:@"entity"] objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"locality"] forKey:@"locality"];
        [response setValue:[[[[categoryList valueForKey:@"entity"] objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"phone"] forKey:@"phone"];
        [response setValue:[[[[categoryList valueForKey:@"entity"] objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"website"] forKey:@"web"];
        
        
    }else
    {
        [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"position"] forKey:@"position"];
        [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"locality"] forKey:@"locality"];
        [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"phone"] forKey:@"phone"];
        [response setValue:[[categoryList valueForKey:@"entity"] objectForKey:@"website"] forKey:@"web"];
    }
    
    
    return  response;
    
}



- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath
{
    
//    NSMutableDictionary *dictionary = [self getReferNowDetailWithCategoryListType:self.categoriesList indexPath:indexPath];
    
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self setReferWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]] delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath
{
//    self.navigationItem.rightBarButtonItem = self.rightButton;
//    [self.toolbarButtons addObject:self.rightButton];
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]]];
    [self.navigationController pushViewController:vctr animated:YES];
    
    
}


- (void)didReceiveCategoryReferWithResponse:(NSDictionary *)response error:(NSError *)error
{
   
    [self hideHUD];
    
    if (error !=nil)
    {
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kCategoryListNowError, @""), nil, @"Ok", nil, 0);
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else
    {
        if ([[response objectForKeyedSubscript:@"response"] count] <=0)
        {
            
            //You would be making the first entry for the category "category name"
            
            NSString *alertMessage = [NSString stringWithFormat:@"You would be making the first entry for the category \'%@\'",self.selectedName];
            
            alertView([[Configuration shareConfiguration] appName], NSLocalizedString(alertMessage, @""), self, @"Cancel", @"Proceed", 0);
            
            return;
            
        }else
        {
            self.navigationItem.title = self.selectedName;
            self.referResponse = [[NSMutableArray alloc]init];
            self.referResponse = [response objectForKey:@"response"];
            
            NSMutableDictionary *referals = [[NSMutableDictionary alloc]init];
            NSMutableArray *referalArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dictionary in self.referResponse) {
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setValue:[dictionary objectForKey:@"dp"] forKey:@"dp"];
                [dic setValue:[[dictionary objectForKey:@"entity"]objectForKey:@"name"] forKey:@"name"];
                [dic setValue:[[dictionary objectForKey:@"entity"]objectForKey:@"locality"] forKey:@"locality"];
                
                
                [referalArray addObject:dic];
                
            }
            
            [referals setValue:referalArray forKey:@"response"];
            
            
            
            UIView *categoryView  = [[CategoriesView alloc] initWithViewFrame:self.view.frame categoryList:response delegate:self isResponse:NO];
            [[YoReferUserDefaults shareUserDefaluts] setValue:@"Hide" forKey:@"Header"];
            categoryView.tag = 40000;
            [categoryView setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:categoryView];
            categoryView.frame = CGRectMake(0.0, [self bounds].size.height - 59.0, [self bounds].size.width, [self bounds].size.height - 60.0);
            
            categoryView.frame = CGRectMake(0.0, 59.0, [self bounds].size.width, [self bounds].size.height - 60.0);
            self.rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_plusmall.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
            self.navigationItem.rightBarButtonItem = self.rightButton;
            [self.toolbarButtons addObject:self.rightButton];
            [self setToolbarItems:self.toolbarButtons animated:NO];
//            [UIView animateWithDuration:0.4
//                                  delay:0.0
//                                options: UIViewAnimationOptionCurveEaseIn
//                             animations:^{
//                                 categoryView.frame = CGRectMake(0.0, 59.0, [self bounds].size.width, [self bounds].size.height - 60.0);
//                                 self.rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_plusmall.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
//                                 self.navigationItem.rightBarButtonItem = self.rightButton;
//                                  [self.toolbarButtons addObject:self.rightButton];
//                                 [self setToolbarItems:self.toolbarButtons animated:NO];
//                             }
//                             completion:^(BOOL finished){
//                             }];
//            
//            
            }
            
        }
    

}

- (void)addData
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self setDefaultRefer] delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (self.categoriesList == WebList)
        {
            WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:@"http://www.google.com"] title:@"Web" refer:YES categoryType:[self.category valueForKey:kCategory]];
            [self.navigationController pushViewController:vctr animated:YES];
            
        }else
        {
            ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self setDefaultRefer] delegate:self];
            [self.navigationController pushViewController:vctr animated:YES];
        }
    }else
    {
        
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
