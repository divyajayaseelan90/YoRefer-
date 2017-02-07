        //
//  WebViewController.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/6/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "WebViewController.h"
#import "Configuration.h"
#import "MBProgressHUD.h"
#import "CategoryType.h"
#import "ReferNowViewController.h"

NSString * const loading = @"";

@interface WebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong)       NSURL           * url;
@property (nonatomic, strong)       NSString        * navigationTitle,*categoryType;
@property (nonatomic,strong)        UIWebView       * webView;
@property (nonatomic,strong)        NSString        * webTitle,*webUrl;
@property (nonatomic, readwrite)    BOOL              isRefer;

@property (nonatomic,strong)        NSString        *shortenUrlString;
@property (nonatomic,strong)        NSMutableDictionary * dictionaryContain;

@end

#pragma maek - implementation

@implementation WebViewController

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title refer:(BOOL)isRefer categoryType:(NSString *)categoryType
{
    self = [super init];
    if(self)
    {
        self.url = url;
        self.navigationTitle = title;
        self.isRefer = isRefer;
        self.categoryType = categoryType;
    }
    return self;
}
#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(self.navigationTitle, @"");
    [self createWebView];
    if (self.isRefer)
        [self.view addSubview:[self fotterView]];
    // Do any additional setup after loading the view.
}

- (CGRect)bounds
{
    return [[UIScreen mainScreen] bounds];
}
- (UIView *)fotterView
{
    CGRect frame = [self bounds];
    CGFloat width = frame.size.width;
    CGFloat height = 60.0;
    CGFloat xPos = 0.0;
    CGFloat yPos = frame.size.height - height;
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [footerView setBackgroundColor:[UIColor colorWithRed:(247.0/255.0) green:(247.0/255.0) blue:(247.0/255.0) alpha:1.0]];
    [self.view addSubview:footerView];
    xPos = 0.0;
    yPos = 0.0;
    width = 44.0;
    height = footerView.frame.size.height;
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [footerView addSubview:leftView];
    UITapGestureRecognizer *leftGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftGestureTapped:)];
    [leftView addGestureRecognizer:leftGesture];
    width = 40.0;
    height = 40.0;
    xPos = 0.0;
    yPos = roundf((leftView.frame.size.height - height)/2);
    UIImageView *leftImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [leftImg setImage:leftIconImg];
    [leftView addSubview:leftImg];
    xPos = leftView.frame.size.width;
    yPos = 0.0;
    width = 44.0;
    height = footerView.frame.size.height;
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [footerView addSubview:rightView];
    UITapGestureRecognizer *rightGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rightGestureTapped:)];
    [rightView addGestureRecognizer:rightGesture];
    width = 40.0;
    height = 40.0;
    xPos = 4.0;
    yPos = roundf((rightView.frame.size.height - height)/2);
    UIImageView *rightImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [rightImg setImage:rightIconImg];
    [rightView addSubview:rightImg];
    width = 50.0;
    height = footerView.frame.size.height;
    xPos  = footerView.frame.size.width - (width + 10.0);
    yPos = 0.0;
    UIView *referView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [footerView addSubview:referView];
    UITapGestureRecognizer *referGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referGestureTapped:)];
    [referView addGestureRecognizer:referGesture];
    width = 50.0;
    height = 50.0;
    xPos = roundf((referView.frame.size.width - width)/2) + 5.0;
    yPos = roundf((referView.frame.size.height - height)/2);
    UIImageView *referImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referImage setImage:referIconImg];
    [referView addSubview:referImage];
    return  footerView;
}

- (void)createWebView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 63.0;
    CGFloat width = [self bounds].size.width;
    CGFloat padding = 0.0;
    if (self.isRefer)
        padding = 44.0;
    else
        padding = 1.0;
    CGFloat height = [self bounds].size.height - (yPos + padding);
    /*
     self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self.view addSubview:self.webView];
    */
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    self.webView.delegate = self;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",self.url];
    
    if([urlStr hasPrefix:@"https://"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", urlStr]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView setScalesPageToFit:YES];
        [self.webView loadRequest:request];
        [self.view addSubview:self.webView];
    }
    else if([urlStr hasPrefix:@"http://"]) {
    
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", urlStr]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView setScalesPageToFit:YES];
        [self.webView loadRequest:request];
        [self.view addSubview:self.webView];
    }
    else{
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlStr]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView setScalesPageToFit:YES];
        [self.webView loadRequest:request];
        [self.view addSubview:self.webView];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showHUDWithMessage:@""];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideHUD];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self hideHUD];
}

#pragma mark - Gesture Recognizer

- (void)rightGestureTapped:(UITapGestureRecognizer *)recognizer
{
    if ([self.webView canGoForward])
    {
        [self.webView   goForward];
    }
}


- (void)leftGestureTapped:(UITapGestureRecognizer *)recognizer
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
    }
}

- (void)referGestureTapped:(UITapGestureRecognizer *)recognizer
{
        self.webUrl = [NSString stringWithFormat:@"%@",self.webView.request.URL];
        _dictionaryContain = [[NSMutableDictionary alloc]init];
        NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
        NSMutableArray *array;
        if ([categoryArray  count] > 0)
        {
            array = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in [categoryArray valueForKey:@"web"])
            {
                
                CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
                [array addObject:places];
                
            }
        }
        CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
        [_dictionaryContain setValue:(self.categoryType != nil && [self.categoryType length] > 0)?self.categoryType:category.categoryName forKey:kCategory];
        [_dictionaryContain setValue:category.categoryID forKey:kCategoryid];
        [_dictionaryContain setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] currentCity]:@"" forKey:kAddress];
        [_dictionaryContain setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kLocation];
        [_dictionaryContain setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
        [_dictionaryContain setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
        [_dictionaryContain setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
        [_dictionaryContain setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
        [_dictionaryContain setValue:kWeb forKey:kCategorytype];
        [_dictionaryContain setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [_dictionaryContain setValue:[self.webTitle stringByReplacingOccurrencesOfString:@"- Google Search" withString:@""] forKey:kName];
    
    // For shorten url...
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:self.webUrl forKey:@"longUrl"];
    [[YoReferAPI sharedAPI] getShortenUrlWithParam:params completionHandler:^(NSDictionary *response ,NSError *error)
     {
         [self didRecevieWithShortenUrl:response error:error];
         
     }];

}

- (void)didRecevieWithShortenUrl:(NSDictionary *)response error:(NSError *)error
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
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        return;
    }else
    {
        
        [_dictionaryContain setValue:[response valueForKey:@"id"] forKey:kWebSite];
        [_dictionaryContain setValue:[response valueForKey:@"id"] forKey:kAddress];
        [_dictionaryContain setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
        
        ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:_dictionaryContain delegate:nil];
        [self.navigationController pushViewController:vctr animated:YES];

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
