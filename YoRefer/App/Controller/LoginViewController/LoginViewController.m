//
//  LoginViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 06/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "LoginViewController.h"
#import "Configuration.h"
#import "YoReferAPI.h"
#import "Utility.h"
#import "MBProgressHUD.h"
#import "UserManager.h"
#import "YoReferSocial.h"
#import "WebViewController.h"
#import "SWRevealViewController.h"
#import "UIManager.h"
#import "YoReferSocialChannels.h"

NSString    *  const appName                        = @"Yorefer";
NSString    *  const thought                        = @"Share your favorites to your buddies";
NSInteger      const tableViewTag                   = 1000;
NSInteger      const downArrowTag                   = 2000;
NSInteger      const scrollViewTag                  = 3000;
NSInteger      const signUpTag                      = 4000;
NSInteger      const numberOfRowSection             = 1;
NSString    *  const activityMesssage               = @"Loading...";
NSString    *  const signUpError                    = @" - Unable to sign up,please try agian";
NSString    *  const forgotPasswordError            = @" - Fail to send a password,please try agian";
NSString    *  const alreadyPhoneNumberRegistered   = @" - Phone number already registered";

typedef enum {
    SignUp = 10000,
    Login,
    ForgotPassword,
    EnterOTP
}AuthType;

@interface LoginViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,MBProgressHUDDelegate,Scocial,UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *facebookDic;
@property (nonatomic, readwrite) AuthType authType;
@property (nonatomic, strong) SWRevealViewController *revealViewController;
@property (nonatomic,readwrite) CGFloat shiftForKeyboard;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation LoginViewController

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    [self headerView];
    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (CGRect)bounds
{
    return [[UIScreen mainScreen] bounds];
}
- (void)headerView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 240.0;
    CGFloat padding = 10.0;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //[self.view addSubview:headerView];
    //ImageView
    height = headerView.frame.size.height - padding * 5;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:[UIImage imageNamed:@"icon_loginheader.png"]];
    [headerView addSubview:imageView];
    //appName
    // CGFloat padding = headerView.frame.size.height / 6;
    width = 80.0;
    height = padding * 3;
    xPos = roundf((headerView.frame.size.width - width)/2);
    yPos = padding * 4;
    UIImageView *appIcon = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [appIcon setImage:[UIImage imageNamed:@"icon_locin_appicon.png"]];
    [headerView addSubview:appIcon];
//    width = headerView.frame.size.width;
//    height = padding * 4;
//    xPos = roundf((headerView.frame.size.width - width)/2);
//    yPos = padding * 4;
//    UILabel *appNamelbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
//    [appNamelbl setText:appName];
//    [appNamelbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:24.0]];
//    [appNamelbl setTextColor:[UIColor whiteColor]];
//    [appNamelbl setTextAlignment:NSTextAlignmentCenter];
//    [headerView addSubview:appNamelbl];
    //thought
    width = headerView.frame.size.width;
    height = padding * 4;
    xPos = roundf((headerView.frame.size.width - width)/2);
    yPos = appIcon.frame.origin.y + appIcon.frame.size.height + padding;
    UILabel *thoughtsLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [thoughtsLbl setText:thought];
    [thoughtsLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0]];
    [thoughtsLbl setTextColor:[UIColor whiteColor]];
    [thoughtsLbl setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:thoughtsLbl];
    height = padding * 5;
    yPos = headerView.frame.size.height - height;
    UIView *headerSubView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [headerSubView addSubview:[self horizpontalScrollWithFrame:headerSubView.frame]];
    [headerView addSubview:headerSubView];
    [self createTableViewWithHeaderView:headerView];
}
- (UIScrollView *)horizpontalScrollWithFrame:(CGRect)frame
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    int xPos = 0;
    CGFloat yPos = 0.0;
    for (int i = 0; i < 3; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, frame.size.width, frame.size.height)];
        [view setBackgroundColor:[UIColor colorWithRed:(218.0/255.0) green:(33.0/255.0) blue:(18.0/255.0) alpha:1.0]];
        [self loginViewWithTag:i view:view];
        [scrollView addSubview:view];
        xPos += view.frame.size.width;
    }
    scrollView.tag = scrollViewTag;
    scrollView.contentSize = CGSizeMake(xPos, scrollView.frame.size.height);
    scrollView.delegate  = self;
    scrollView.scrollEnabled = NO;
    scrollView.pagingEnabled = YES;
    return scrollView;
}
- (void)loginViewWithTag:(NSInteger)tag view:(UIView *)view
{
    switch (tag) {
        case 0:
            [self createSignUpLoginWithView:view];
            break;
        case 1:
            [self createForGotPasswordWithView:view];
            break;
        case 2:
            [self createOTPWithView:view];
            break;
        default:
            break;
    }
}

- (void)createOTPWithView:(UIView *)view
{
    CGFloat height = 40.0;
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    UILabel *otpLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, view.frame.size.width, height)];
    [otpLbl setText:NSLocalizedString(@"Enter OTP", @"")];
    [otpLbl setTextColor:[UIColor whiteColor]];
    [otpLbl setTextAlignment:NSTextAlignmentCenter];
    [otpLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [view addSubview:otpLbl];
}

- (void)createForGotPasswordWithView:(UIView *)view
{
    CGFloat height = 40.0;
    CGFloat xPos = 0.0;
    CGFloat yPos = (view.frame.size.height - height)/2;
    CGFloat width = 20.0;
    UILabel *forgotPasswordLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, view.frame.size.width, height)];
    [forgotPasswordLbl setText:NSLocalizedString(@"Forgot Password", @"")];
    [forgotPasswordLbl setTextColor:[UIColor whiteColor]];
    [forgotPasswordLbl setTextAlignment:NSTextAlignmentCenter];
    [forgotPasswordLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [view addSubview:forgotPasswordLbl];
    xPos = 0.0;
    width = 50.0;
    height = forgotPasswordLbl.frame.size.height;
    yPos = (view.frame.size.height - height)/2;
    UIView *viewBack = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view addSubview:viewBack];
    xPos = 15.0;
    width = 20.0;
    height = 16.0;
    yPos = (viewBack.frame.size.height - height)/2;
    UIImageView *imageBack = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageBack.image = [UIImage imageNamed:@"back-arrow.png"];
    imageBack.userInteractionEnabled = YES;
    [viewBack addSubview:imageBack];
    
    UITapGestureRecognizer *goBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(login:)];
    [viewBack addGestureRecognizer:goBack];
}

- (void)createSignUpLoginWithView:(UIView *)view
{
    //signUp
    CGFloat width = roundf(view.frame.size.width/2);
    UIView *signUp = [[UIView alloc]initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height)];
    signUp.tag = signUpTag;
    [view addSubview:signUp];
    CGFloat xPos = 0.0;
    UILabel *signUpLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, signUp.frame.origin.x, signUp.frame.size.width, signUp.frame.size.height)];
    [signUpLbl setText:NSLocalizedString(@"Sign Up", @"")];
    [signUpLbl setTextColor:[UIColor whiteColor]];
    [signUpLbl setTextAlignment:NSTextAlignmentCenter];
    [signUpLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [signUp addSubview:signUpLbl];
    UITapGestureRecognizer *signUpGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signUp:)];
    [signUp addGestureRecognizer:signUpGestureRecognizer];
    //Login
    xPos = signUp.frame.size.width;
    width = roundf(view.frame.size.width/2);
    UIView *login = [[UIView alloc]initWithFrame:CGRectMake(xPos,view.frame.origin.y, width, view.frame.size.height)];
    login.tag = Login;
    xPos = 0.0;
    UILabel *loginLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos,login.frame.origin.y, login.frame.size.width, login.frame.size.height)];
    [loginLbl setText:NSLocalizedString(@"Login", @"")];
    [loginLbl setTextColor:[UIColor whiteColor]];
    [loginLbl setTextAlignment:NSTextAlignmentCenter];
    [loginLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    [login addSubview:loginLbl];
    UITapGestureRecognizer *loginGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(login:)];
    [login addGestureRecognizer:loginGestureRecognizer];
    [view addSubview:login];
    width = 20.0;
    CGFloat height = 14.0;
    xPos = roundf((view.frame.size.width - width)/2);
    CGFloat yPos = signUpLbl.frame.size.height - height;
    UIImageView *arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    arrowImg.tag = downArrowTag;
    [arrowImg setImage:[UIImage imageNamed:@"icon_login_arrow.png"]];
    [view addSubview:arrowImg];
}



- (void)termsAndConditions
{
    [[UIManager sharedManager] goWebPageWithAnimated:YES title:@"Terms and Conditions" url:[NSURL URLWithString:[[Configuration shareConfiguration] getTermsAndConditions]]];
}

- (void)privacyPolicy
{
    [[UIManager sharedManager] goWebPageWithAnimated:YES title:@"Privacy Policy" url:[NSURL URLWithString:[[Configuration shareConfiguration] getPrivacyPolicy]]];
}
- (void)createTableViewWithHeaderView:(UIView *)headerView
{
    CGRect frame = [self bounds];
    CGFloat xPos = frame.origin.x;
    CGFloat yPos = frame.origin.y;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [tableView setTag:tableViewTag];
    tableView.tableHeaderView = headerView;
    [tableView setTableFooterView:[UIView new]];
    [self.view addSubview:tableView];
    [self login:nil];
}

- (void)reloadTableView
{
    [(UITableView *)[self.view viewWithTag:tableViewTag] setDataSource:self];
    [(UITableView *)[self.view viewWithTag:tableViewTag] setDelegate:self];
    [(UITableView *)[self.view viewWithTag:tableViewTag] reloadData];
}


- (void)pushArrowImageWithView:(UIView *)view
{
    UIImageView *imageview = (UIImageView *)[self.view viewWithTag:downArrowTag];
    CGFloat xPos = view.frame.origin.x + roundf((view.frame.size.width - imageview.frame.size.width)/2);
    [UIView animateWithDuration:0.5 animations:^{
        [imageview setFrame:CGRectMake(xPos, imageview.frame.origin.y, imageview.frame.size.width, imageview.frame.size.height)];
    }completion:^(BOOL finished)
     {
         [self reloadTableView];
     }];
}


- (void)createViewWithAuthType:(AuthType)authType tableViewCell:(UITableViewCell *)cell frame:(CGRect)frame
{
    if (authType == SignUp)
    {
        SignUpView *view = [[SignUpView alloc]initWithViewFrame:frame delegate:self];
        [cell.contentView addSubview:view];
    }else if (authType == Login)
    {
        LoginView *view = [[LoginView alloc]initWithViewFrame:frame delegate:self];
        [cell.contentView addSubview:view];
        
    }else if (authType == ForgotPassword)
    {
        ForgotPasswordView *view = [[ForgotPasswordView alloc]initWithViewFrame:frame delegate:self];
        [cell.contentView addSubview:view];
    }else if (authType == EnterOTP)
    {
        EnterOTPView *view = [[EnterOTPView alloc]initWithViewFrame:frame delegate:self];
        [cell.contentView addSubview:view];
    }
}
#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag != scrollViewTag)
        return;
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    switch (page) {
        case 0:
            self.authType = (self.authType == SignUp)?SignUp:Login;
            (self.authType == Login)?[self pushArrowImageWithView:(UIView *)[self.view viewWithTag:Login]]:@"";
            break;
        default:
        case 1:
            self.authType = ForgotPassword;
            break;
        case 2:
            self.authType = EnterOTP;
            break;
    }
    [self reloadTableView];
}

#pragma mark - tableView datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numberOfRowSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightWithAuthType:self.authType];
}

- (CGFloat)heightWithAuthType:(AuthType)authType
{
    CGFloat height;
    switch (authType) {
        case Login:
            height = 580.0;
            break;
        case SignUp:
            height = 620.0;
            break;
        case ForgotPassword:
            height = 440.0;
            break;
        case EnterOTP:
            height = 260.0;
            break;
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    CGRect frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 800.0);
    [self createViewWithAuthType:self.authType tableViewCell:cell frame:frame];
    return cell;
}

#pragma mark - GestureRecognizer
- (void)signUp:(UITapGestureRecognizer *)gestureRecognizer
{
    self.authType = SignUp;
    UIView *view = (UIView *)[self.view viewWithTag:signUpTag];
    [self pushArrowImageWithView:view];
}

- (void)login:(UITapGestureRecognizer *)gestureRecognizer
{
    CGRect frame = [(UIScrollView *)[self.view viewWithTag:scrollViewTag] frame];
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    [(UIScrollView *)[self.view viewWithTag:scrollViewTag] scrollRectToVisible:frame animated:YES];
    self.authType = Login;
    [self pushArrowImageWithView:(UIView *)[self.view viewWithTag:Login]];
}


-(void)animateTextField:(UITextField*)textField isUp:(BOOL)isUp
{
    UIView *view = [textField superview];
    if (isUp)
    {
        CGRect textFieldRect = [self.view convertRect:view.bounds fromView:textField];
        CGFloat bottomEdge = ([UIScreen mainScreen].bounds.size.width == 320)?(textField.tag == 1000 || textField.tag == 0)?304.0:textFieldRect.origin.y + textFieldRect.size.height:textFieldRect.origin.y + textFieldRect.size.height;
        CGFloat keyboardYpos = self.view.frame.size.height - 200;
        if (bottomEdge >= keyboardYpos)
        {
        CGRect viewFrame = self.view.frame;
        CGFloat edge = (textField.tag == 3)?290.0:220.0;
        self.shiftForKeyboard = bottomEdge - edge;
        viewFrame.origin.y -= self.shiftForKeyboard;
        [self.view setFrame:viewFrame];
        }else
        {
        self.shiftForKeyboard = 0.0f;
        }
    }else
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += self.shiftForKeyboard;
        self.shiftForKeyboard = 0.0f;
        [self.view setFrame:viewFrame];
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

#pragma mark - Protocol
- (void)showAnimatedWithTextFiled:(UITextField *)textFiled
{
    [self animateTextField:textFiled isUp:YES];
}
- (void)hideAnimatedWithTextFiled:(UITextField *)textFiled
{
    [self animateTextField:textFiled isUp:NO];
}
- (void)ForgotPassword
{
    CGRect frame = [(UIScrollView *)[self.view viewWithTag:scrollViewTag] frame];
    frame.origin.x = frame.size.width * 1;
    frame.origin.y = 0;
    [(UIScrollView *)[self.view viewWithTag:scrollViewTag] scrollRectToVisible:frame animated:YES];
    self.authType = ForgotPassword;
    [self reloadTableView];
}
- (void)loginWithParams:(NSMutableDictionary*)params
{
    [[YoReferUserDefaults shareUserDefaluts] setValue:params forKey:@"login"];
    [self showHUDWithMessage:@""];
    [[YoReferAPI sharedAPI] loginWithParams:params completionHandler:^(NSDictionary *response ,NSError *error)
    {
        [self didReceiveLoginWithResponse:response error:error];
        
    }];
}
- (void)signUpWithParams:(NSMutableDictionary*)params
{
    [self showHUDWithMessage:@""];
    [[YoReferAPI sharedAPI] signUpWithParams:params completionHandler:^(NSDictionary *response ,NSError *error)
    {
        NSLog(@"SignUp Response === %@", response);
        [self didReceiveWithSignUpResponse:response error:error parmas:params];
        
    }];
}
- (void)forgotPasswordWithParams:(NSMutableDictionary *)params
{
    [self showHUDWithMessage:@""];
    [[YoReferAPI sharedAPI] forgotPasswordWithParam:params completionHandler:^(NSDictionary *response,NSError *error)
     {
         [self didReceiveWithForgotPasswordResponse:response error:error];
         
     }];
}
- (void)enterOPTWithParams:(NSMutableDictionary *)params
{
}


- (void)faceBook
{
    [[YoReferSocial shareYoReferSocial] faceBookWithDelegate:self];
}

- (void)faceBookUser:(NSDictionary *)userInfo
{
    self.facebookDic = [[NSMutableDictionary alloc]init];
    if ( userInfo != nil && [userInfo isKindOfClass:[NSDictionary class]])
    {
//        NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [userInfo objectForKey:@"facebookId"]];

        
        [self.facebookDic setValue:[userInfo objectForKey:@"emailId"] forKey:@"emailId"];
        [self.facebookDic setValue:[userInfo objectForKey:@"name"] forKey:@"name"];
        [self.facebookDic setValue:[userInfo objectForKey:@"facebookId"] forKey:@"number"];
        [self.facebookDic setValue:[userInfo objectForKey:@"dp"] forKey:@"dp"];
        
        [[YoReferAPI sharedAPI] facebookLoginWithParams:userInfo completionHandler:^(NSDictionary *response ,NSError *error)
        {
            [self didReceiveFacebookLoginWithResponse:response error:error];
            
        }];
    }else
    {
        alertView([[Configuration shareConfiguration] errorMessage], @"Unable to login in facebook,please try agin", nil, @"Ok", nil, 0);
        return;
    }
}

#pragma mark - API Response
- (void)didReceiveFacebookLoginWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }
        
    }else if ([[resonse objectForKey:@"message"] length ] > 0)
    {
        alertView([[Configuration shareConfiguration] errorMessage],([[resonse objectForKey:@"message"] isEqualToString:@"invalid_credentials"]?NSLocalizedString(@"Invalid Credentials",@""):NSLocalizedString([resonse objectForKey:@"message"], @"")), nil, @"Ok", nil, 0);
        return;
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        [self.facebookDic setValue:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"] forKey:@"sessionToken"];
        [[UserManager shareUserManager] populateUserInfoFromResponse:self.facebookDic sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
        
        [[UserManager shareUserManager] enableLocation];
        [[UserManager shareUserManager] populateUserInfoFromResponse:[[resonse objectForKey:@"response"] objectForKey:@"user"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        [dictionary setValue:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"] forKey:@"sessionToken"];
        [dictionary setValue:[[[resonse objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"facebookId"] forKey:@"number"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginIn" object:self userInfo:dictionary];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *myString = [prefs stringForKey:@"deviceToken"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        [param setValue:myString forKey:@"deviceToken"];
        [param setValue:@"ios" forKey:@"platform"];
        [[YoReferAPI sharedAPI] tokenWithParams:param completionHandler:^(NSDictionary *response ,NSError *error)
         {
             [self didReceiveTokenWithResponse:response error:error];
             
         }];

        
        /*
         NSMutableDictionary *loginParams = [NSMutableDictionary dictionaryWithCapacity:2];
         [loginParams setValue:[resonse valueForKey:@"number"] forKey:@"number"];
         [loginParams setValue:[resonse valueForKey:@"password"] forKey:@"password"];
         [self loginWithParams:loginParams];
         */
        /*
         NSMutableDictionary *loginParams = [NSMutableDictionary dictionaryWithCapacity:2];
         [loginParams setValue:@"+918817569622" forKey:@"number"];
         [loginParams setValue:@"12345678" forKey:@"password"];
         [self loginWithParams:loginParams];
         */
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
        }
        
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else if ([[resonse objectForKey:@"message"] length ] > 0)
    {
        alertView([[Configuration shareConfiguration] errorMessage],([[resonse objectForKey:@"message"] isEqualToString:@"invalid_credentials"]?NSLocalizedString(@"Invalid Login or Passowrd. Please try again.",@""):NSLocalizedString([resonse objectForKey:@"message"], @"")), nil, @"Ok", nil, 0);
        return;
        
    }else
    {
//        [[YoReferSocialChannels shareYoReferSocial] setDefaultSharing];
        [[UserManager shareUserManager] enableLocation];
        [[UserManager shareUserManager] populateUserInfoFromResponse:[[resonse objectForKey:@"response"] objectForKey:@"user"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        [dictionary setValue:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"] forKey:@"sessionToken"];
        [dictionary setValue:[[[resonse objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"number"] forKey:@"number"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginIn" object:self userInfo:dictionary];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *myString = [prefs stringForKey:@"deviceToken"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        [param setValue:myString forKey:@"deviceToken"];
        [param setValue:@"ios" forKey:@"platform"];
        [[YoReferAPI sharedAPI] tokenWithParams:param completionHandler:^(NSDictionary *response ,NSError *error)
        {
            [self didReceiveTokenWithResponse:response error:error];
            
        }];
        
    }
}

- (void)didReceiveTokenWithResponse:(NSDictionary *)response error:(NSError *)error
{
}
- (void)didReceiveWithSignUpResponse:(NSDictionary *)resonse error:(NSError *)error parmas:(NSMutableDictionary *)params
{
    [self hideHUD];
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(signUpError, @""), nil, @"Ok", nil, 0);
        }
        return;
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        if ([[resonse objectForKey:@"message"] length] > 0 && [resonse objectForKey:@"message"]!= nil)
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(alreadyPhoneNumberRegistered, @""), nil, @"Ok", nil, 0);
            return;
            
        }else
        {
            //[[UserManager shareUserManager] populateUserInfoFromResponse:[resonse objectForKey:@"response"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
            NSMutableDictionary *loginParams = [NSMutableDictionary dictionaryWithCapacity:2];
            [loginParams setValue:[params valueForKey:@"number"] forKey:@"number"];
            [loginParams setValue:[params valueForKey:@"password"] forKey:@"password"];
            [self loginWithParams:loginParams];
        }
    }
}



- (void)didReceiveWithForgotPasswordResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(forgotPasswordError, @""), nil, @"Ok", nil, 0);
        }
        return;
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        if ([[response objectForKey:@"message"] isEqualToString:@"phone_number_not_found"])
        {
            alertView([[Configuration shareConfiguration] errorMessage], @" - Invalid phone number", nil, @"Ok", nil, 0);
            return;
        }else if ([[response objectForKey:@"message"] isEqualToString:@"server_error_message"])
        {
            alertView([[Configuration shareConfiguration] errorMessage], forgotPasswordError, nil, @"Ok", nil, 0);
            return;

        }else
        {
             alertView([[Configuration shareConfiguration] appName], @"Passwords changed successfully", self, @"Ok", nil, 12321);
        }
    }
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 12321)
    {
        [self login:nil];
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
