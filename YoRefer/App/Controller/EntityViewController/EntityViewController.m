//
//  EntityViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 13/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "EntityViewController.h"
#import "Configuration.h"
#import "YoReferAPI.h"
#import "Utility.h"
#import "Entity.h"
#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "UserManager.h"
#import "ReferNowViewController.h"
#import "MapViewController.h"
#import "MeViewController.h"
#import "WebViewController.h"
#import "Constant.h"
#import <MessageUI/MessageUI.h>
#import "BBImageManipulator.h"
#import "PhotoViewController.h"



NSUInteger const refersCountTag = 10000;
NSUInteger const photoCountTag  = 20000;

NSInteger       const kEntityFeeds                  = 419.0;
NSInteger       const kEntityPhotos                 = 110.0;
NSString    *   const kNotavailable                 = @"Not available";
NSString    *   const kEntityWebsite                = @"Website not available";
NSString    *   const kEntityEmail                  = @"Email-Id not available";
NSString    *   const kEntityPhone                  = @"Phone number not available";
NSString    *   const kEntityCall                   = @"Do you want to call?";
NSString    *   const kEntitySendEmail              = @"Do you want to send an Email?";
NSString    *   const kEntityError                  = @"Unable to get carousel";

@interface EntityViewController ()<UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic,strong) NSMutableDictionary *entityDetail;
@property (nonatomic,readwrite) EntityType entityType;
@property (nonatomic, strong)   NSMutableArray *entity,*mediaLinks;
@property (nonatomic, strong) UIImageView *offerImg;
@property (nonatomic, strong) NSMutableArray *photoUrlsArr;

@end

@implementation EntityViewController

- (instancetype)initWithentityDetail:(NSMutableDictionary *)entityDetail
{
    self = [super init];
    if (self)
    {
        self.entityDetail = entityDetail;
    }
    return self;
}
#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entity  = [[NSMutableArray alloc]init];
    [self createTableHeaderView];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    //Entity list
    [self getEnityWitEntityId:[self.entityDetail objectForKey:@"entityid"]];
    // Do any additional setup after loading the view.
}
- (void)createTableHeaderView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 420.0;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [headerView setBackgroundColor:[UIColor clearColor]];

    self.tableView.tableHeaderView = headerView;
    height = round(headerView.frame.size.height/2) - 10.0;
    
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [topView setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:topView];
    
    
    UIImageView *backGroundImg = [[UIImageView alloc]initWithFrame:topView.frame];
    NSArray *array = [[self.entityDetail objectForKey:kMediaId] componentsSeparatedByString:@"/"];
    NSString *imageName = [array objectAtIndex:[array count]-1];
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:backGroundImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
    }else if ([array count] > 1)
    {
        if ([self.entityDetail objectForKey:kMediaId] != nil && [[self.entityDetail objectForKey:kMediaId] length] > 0)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[self.entityDetail objectForKey:kMediaId]] imageView:backGroundImg];
        }
    }
    [topView addSubview:backGroundImg];
    if ([self.entityDetail objectForKey:kMediaId] != nil && [[self.entityDetail objectForKey:kMediaId] length] > 0)
    {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = backGroundImg.bounds;
        [backGroundImg addSubview:visualEffectView];
    }else
    {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = backGroundImg.bounds;
        [backGroundImg addSubview:visualEffectView];
        if ([[self.entityDetail objectForKey:kType] isEqualToString:kPlace])
        {
            backGroundImg.image = placeImg;
        }
        else  if ([[self.entityDetail objectForKey:kType] isEqualToString:kProduct])
        {
            backGroundImg.image = productImg;
        }else  if ([[self.entityDetail objectForKey:kType] isEqualToString:kWeb])
        {
            backGroundImg.image = webLinkImg;
        }
        else  if ([[self.entityDetail objectForKey:kType] isEqualToString:kService])
        {
            backGroundImg.image = serviceImg;
        }
        else
            backGroundImg.image = noPhotoImg;
    }
    width = 80.0;
    height = 80.0;
    xPos = round((topView.frame.size.width - width)/2);
    yPos = 4.0;
    
    //------------ Top Image ----------------------------------
    _offerImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [_offerImg setBackgroundColor:[UIColor clearColor]];
    [_offerImg.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_offerImg.layer setBorderWidth:1.0];
    
    
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:_offerImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
    }else
    {
        if ([self.entityDetail objectForKey:kMediaId] != nil && [[self.entityDetail objectForKey:kMediaId] length] > 0)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[self.entityDetail objectForKey:kMediaId]] imageView:_offerImg];
        }else
        {
            _offerImg.image = backGroundImg.image;
        }
    }
    [_offerImg.layer setCornerRadius:40.0];
    [_offerImg.layer setMasksToBounds:YES];
    [topView addSubview:_offerImg];
    
    UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
    [topView addGestureRecognizer:profileGestureRecognizer];

    
    xPos = 0.0;
    yPos = _offerImg.frame.size.height + _offerImg.frame.origin.y;
    width  = topView.frame.size.width;
    height = 24.0;
    UILabel *topTitleLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [topTitleLbl setText:[self.entityDetail objectForKey:kName]];
    [topTitleLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0]];
    [topTitleLbl setNumberOfLines:2];
    [topTitleLbl setTextColor:([self.entityDetail objectForKey:kMediaId] != nil && [[self.entityDetail objectForKey:kMediaId] length] > 0)?[UIColor whiteColor]:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
    [topTitleLbl setTextAlignment:NSTextAlignmentCenter];
    [topView addSubview:topTitleLbl];
    
    
    
    width = 100.0;
    height = 28.0;
    yPos = topTitleLbl.frame.origin.y + topTitleLbl.frame.size.height;
    xPos = roundf((topView.frame.size.width - width)/2);
    UIButton *referBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referBtn.layer setBorderWidth:2.0];
    [referBtn setTitle:@"Refer Now" forState:UIControlStateNormal];
    [referBtn.titleLabel setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:14.0]];
    [referBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referBtn.layer setCornerRadius:15.0];
    [referBtn.layer setMasksToBounds:YES];
    [referBtn setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [referBtn addTarget:self action:@selector(referButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:referBtn];
    
    
    xPos = 0.0;
    yPos = topView.frame.size.height;
    width = frame.size.width;
    height = round(headerView.frame.size.height/2) + 10.0;
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [bottomView setBackgroundColor:[UIColor yellowColor]];
    [headerView addSubview:bottomView];
   
    
    xPos = 0.0;
    yPos = 0.0;
    height = round(bottomView.frame.size.height /2);
    width = bottomView.frame.size.width;
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressView setBackgroundColor:[UIColor whiteColor]];
    [bottomView addSubview:addressView];
    
    
    //map
    width = 36.0;
    height = 32.0;
    xPos = addressView.frame.size.width - (width +2.0);
    yPos = 2.0;
    UIImageView *mapImg  =[[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mapImg setUserInteractionEnabled:YES];
    [mapImg setImage:([[self.entityDetail valueForKey:@"type"] isEqualToString:kWeb])?webImage:mapImage];
    [addressView addSubview:mapImg];
    UITapGestureRecognizer *mapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapGestureTapped:)];
    [mapImg addGestureRecognizer:mapGestureRecognizer];
    
    
    
    //address
    xPos = 4.0;
    yPos = 0.0;
    width = addressView.frame.size.width - (mapImg.frame.size.width + 8.0);
    height = addressView.frame.size.height;
    UILabel *addressLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressLbl setBackgroundColor:[UIColor whiteColor]];
    [addressLbl setText:([[self.entityDetail valueForKey:kType] isEqualToString:kProduct])?[[[[self.entityDetail valueForKey:kEntity] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kLocality]:[self.entityDetail objectForKey:kLocality]];
    // [[[[self.entityDetail valueForKey:kEntity] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kEmail]
    
    [addressLbl setTextAlignment:NSTextAlignmentLeft];
    [addressLbl setFont:([self bounds].size.width  > 320? [[Configuration shareConfiguration] yoReferFontWithSize:12.5]:[[Configuration shareConfiguration] yoReferFontWithSize:10.5])];
    [addressLbl setNumberOfLines:3];
    [addressLbl sizeToFit];
    [addressView addSubview:addressLbl];
    
    
    //PhoneView
    xPos = 0.0;
    height = 35.0;
    width = bottomView.frame.size.width;
    yPos = addressView.frame.size.height - height - 30;
    UIView *phoneNumberView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [phoneNumberView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [phoneNumberView.layer setBorderWidth:1.0];
    [phoneNumberView setBackgroundColor:[UIColor whiteColor]];
    [bottomView addSubview:phoneNumberView];
    
    
    //phoneNumber
    xPos = 0.0;
    yPos = 0.0;
    height = phoneNumberView.frame.size.height;
    width  = roundf((phoneNumberView.frame.size.width)/2);
    UIView *phone = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    phone.tag =[[self.entityDetail objectForKey:kPhone] integerValue];
    UITapGestureRecognizer *phoneGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(phoneGestureTapped:)];
    [phone addGestureRecognizer:phoneGestureRecognizer];
    [phone setBackgroundColor:[UIColor whiteColor]];
    [phoneNumberView addSubview:phone];
    
    
    
    height = 22.0;
    width = 10.0;
    yPos = roundf((phone.frame.size.height - height)/2);
    xPos = 5.0;
    UIImageView *phoneImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if([[self.entityDetail objectForKey:kPhone] length] <= 0)
    {
        phoneImg.image = [mobileImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [phoneImg setTintColor:[UIColor lightGrayColor]];
    }else
    {
        phoneImg.image = [mobileImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [phoneImg setTintColor:[UIColor blueColor]];
    }
    [phone addSubview:phoneImg];
    
    
    xPos = phoneImg.frame.size.width + 6.0;
    yPos = 0.0;
    height = phone.frame.size.height;
    width = phone.frame.size.width - phoneImg.frame.size.width;
    UILabel *phoneLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if([[self.entityDetail objectForKey:kPhone] length] <= 0)
    {
        [phoneLbl setText:kNotavailable];
        [phoneLbl setTextColor:[UIColor grayColor]];
        
    }else
    {
        [phoneLbl setText:[NSString stringWithFormat:@" %@",[self.entityDetail objectForKey:kPhone]]];
        [phoneLbl setTextColor:[UIColor blueColor]];
    }
    [phoneLbl setBackgroundColor:[UIColor whiteColor]];
    [phoneLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [phone addSubview:phoneLbl];
    
    
    // EmailView
    xPos = phone.frame.size.width;
    height = 35.0;
    width = bottomView.frame.size.width;
    yPos = addressView.frame.size.height - height - 30;
    UIView *emailView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [emailView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [emailView.layer setBorderWidth:1.0];
    [emailView setBackgroundColor:[UIColor whiteColor
                                   ]];
    [bottomView addSubview:emailView];
    
    
    //Email
    xPos = 0.0;
    yPos = 0.0;
    height = phoneNumberView.frame.size.height;
    width  = roundf((phoneNumberView.frame.size.width)/2);
    UIView *email = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    if ([[self.entityDetail valueForKey:kType] isEqualToString:kProduct]){
         email.tag =  ([[[[[self.entityDetail valueForKey:kEntity] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kEmail] length]>0)?1:0; // [[[self.entityDetail valueForKey:kEntity] valueForKey:@"email"] integerValue];
    }
    else
    {
        email.tag =  ([[[self.entityDetail valueForKey:kEntity] valueForKey:@"email"] length]>0)?1:0; // [[[self.entityDetail valueForKey:kEntity] valueForKey:@"email"] integerValue];
    }
    
    
    
    
    UITapGestureRecognizer *emailGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emailGestureTapped:)];
    [email addGestureRecognizer:emailGestureRecognizer];
    [email setBackgroundColor:[UIColor whiteColor]];
    [emailView addSubview:email];
    
    
    
    height = 22.0;
    width = 22.0;
    yPos = roundf((phone.frame.size.height - height)/2);
    xPos = 5.0;
    UIImageView *emaillImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if([[self.entityDetail objectForKey:kEmail] length] <= 0)
    {
        emaillImg.image = [emailImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [emaillImg setTintColor:[UIColor lightGrayColor]];
    }else
    {
        emaillImg.image = [emailImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [emaillImg setTintColor:[UIColor blueColor]];
    }
    [email addSubview:emaillImg];
    
    
    xPos = emaillImg.frame.size.width + 6.0;
    yPos = 0.0;
    height = email.frame.size.height;
    width = email.frame.size.width - emaillImg.frame.size.width;
    UILabel *emailLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
     if ([[self.entityDetail valueForKey:kType] isEqualToString:kProduct]) {
         
         if([[[[[self.entityDetail valueForKey:kEntity] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kEmail] length] <= 0)
         {
             [emailLbl setText:kNotavailable];
             [emailLbl setTextColor:[UIColor grayColor]];
             
         }else
         {
             [emailLbl setText:[NSString stringWithFormat:@" %@",[[[[self.entityDetail valueForKey:kEntity] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kEmail]]];
             [emailLbl setTextColor:[UIColor blueColor]];
         }
     }
    else
    {
        
        if([[[self.entityDetail valueForKey:kEntity] valueForKey:@"email"] length] <= 0)
        {
            [emailLbl setText:kNotavailable];
            [emailLbl setTextColor:[UIColor grayColor]];
            
        }else
        {
            [emailLbl setText:[NSString stringWithFormat:@" %@",[[self.entityDetail valueForKey:kEntity] valueForKey:@"email"]]];
            [emailLbl setTextColor:[UIColor blueColor]];
        }
    }
    
    [emailLbl setBackgroundColor:[UIColor whiteColor]];
    [emailLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:13.0]];
    emailLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    [email addSubview:emailLbl];
    
    
    
    //web
    xPos = 0;
    yPos = 80.0;
    height = phoneNumberView.frame.size.height;
    width = roundf((phoneNumberView.frame.size.width));
    UIView *webView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [webView setBackgroundColor:[UIColor whiteColor]];
    [webView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [webView.layer setBorderWidth:1.0];
//    [phone addSubview:webView];
    [bottomView addSubview:webView];
    UITapGestureRecognizer *webGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webViewGestureTapped:)];
    [webView addGestureRecognizer:webGestureRecognizer];
    
    
    height = 23.0;
    width = 23.0;
    yPos = roundf((webView.frame.size.height - height)/2);
    xPos = 4.0;
    UIImageView *webImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if([[self.entityDetail objectForKey:kWeb] length] <= 0)
    {
         webImg.image = [([[self.entityDetail valueForKey:kType] isEqualToString:kService])?websiteImg:websiteImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [webImg setTintColor:[UIColor lightGrayColor]];
        
    }else
    {
        webImg.image = [([[self.entityDetail valueForKey:kType] isEqualToString:kService])?websiteImg:websiteImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [webImg setTintColor:[UIColor blueColor]];
    }
    [webView addSubview:webImg];
   
    
    xPos = webImg.frame.size.width + 6.0;
    yPos = 0.0;
    height = webView.frame.size.height;
    width = webView.frame.size.width - phoneImg.frame.size.width;
    
    UILabel *webLinkLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if([[self.entityDetail objectForKey:kWeb] length] <= 0)
    {
        [webLinkLbl setText:kNotavailable];
        [webLinkLbl setTextColor:[UIColor grayColor]];
        
    }else
    {
        /*
        [self shortenMapUrl:[NSString stringWithFormat:@" %@",[self.entityDetail objectForKey:kWeb]]];
        [webLinkLbl setHidden:YES];
        */
        [webLinkLbl setText:[NSString stringWithFormat:@" %@",[self.entityDetail objectForKey:kWeb]]];
        [webLinkLbl setTextColor:[UIColor blueColor]];
    }
    [webLinkLbl setBackgroundColor:[UIColor whiteColor]];
    [webLinkLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [webView addSubview:webLinkLbl];
    
    
    xPos = roundf(phoneNumberView.frame.size.width/2);
    height = phoneNumberView.frame.size.height;
    width = 1.0;
    yPos = 0.0;
    UIView *middLineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [middLineView setBackgroundColor:[UIColor lightGrayColor]];
    [phoneNumberView addSubview:middLineView];
    
    
    
    xPos = 0.0;
    height = round(bottomView.frame.size.height /2) + 6.0;
    width = bottomView.frame.size.width;
    yPos = addressView.frame.size.height + addressView.frame.origin.y + 5;
    UIView *offersView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [offersView setBackgroundColor:[UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f]];
    [bottomView addSubview:offersView];
    
    
    
    //Title
    xPos = 0.0;
    yPos = 0.0;
    height = roundf(addressView.frame.size.height/2);
    width = addressView.frame.size.width;
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    [offersView addSubview:titleView];
    
    
    
    yPos = 0.0;
    width = titleView.frame.size.width;
    height = titleView.frame.size.height - yPos;
    xPos = 0.0;
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [titleLbl setTextAlignment:NSTextAlignmentCenter];
    NSString *points = [NSString stringWithFormat:@"%@",[[self.entityDetail valueForKey:kEntity] valueForKey:@"points"]];
    points = ([points isEqualToString:@"(null)"])?@"0":points;
    NSString *referCount = [NSString stringWithFormat:@"!! Offers !! \nGet %@ points for each referal",(points != nil && [points length] > 0 )?points:@"0"];
    [titleLbl setText:NSLocalizedString(referCount, @"")];
    [titleLbl setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:1.0]];
    [titleLbl setNumberOfLines:2];
    [titleLbl setFont:([self bounds].size.width > 320 ?  [[Configuration shareConfiguration] yoReferFontWithSize:16.0]:[[Configuration shareConfiguration] yoReferFontWithSize:12.0])];
    [offersView addSubview:titleLbl];
    
    
    
    yPos = titleView.frame.size.height + 10.0;
    xPos = 6.0;
    width = offersView.frame.size.width - 12.0;
    height = 40.0;
    UIView *actionView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [actionView setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    [actionView.layer setCornerRadius:(height/2)];
    [actionView.layer setMasksToBounds:YES];
    [offersView addSubview:actionView];
    width = roundf(actionView.frame.size.width/2);
    height = actionView.frame.size.height - 4;
    
    
    yPos = 2.0;
    xPos = 2.0;
    UIView *feedsView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    feedsView.tag  = refersCountTag;
    [feedsView setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [feedsView.layer setCornerRadius:height /2];
    [feedsView.layer setMasksToBounds:YES];
    [actionView addSubview:feedsView];
    UITapGestureRecognizer *feedsgestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedsGestureTapped:)];
    [feedsView addGestureRecognizer:feedsgestureRecognizer];
    
    
    xPos = 0.0;
    yPos = -6.0;
    width = feedsView.frame.size.width ;
    height = feedsView.frame.size.height + 10.0;
    UILabel *feedsLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [feedsLbl setText:[NSString stringWithFormat:@"%@  Refers",[NSString stringWithFormat:@"%@",[self.entityDetail objectForKey:kReferCount]]]];
    [feedsLbl setNumberOfLines:2];
    [feedsLbl setTextColor:[UIColor whiteColor]];
    [feedsLbl setTextAlignment:NSTextAlignmentCenter];
    [feedsLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    self.entityType = EntityFeeds;
    [feedsView addSubview:feedsLbl];
    
    
    
    //lineview
    xPos = feedsView.frame.size.width - 3.0;
    yPos = 0.0;
    width = 1.0;
    height =feedsView.frame.size.height;
    UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //[lineView setBackgroundColor:[UIColor whiteColor]];
    [actionView addSubview:lineView];
   
    
    
    xPos = feedsView.frame.size.width + 1.0;
    width = roundf(actionView.frame.size.width/2) - 3.0;
    height = actionView.frame.size.height - 4.0;
    yPos = 2.0;
    UIView *photosView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    photosView.tag  = photoCountTag;
    [photosView setBackgroundColor:[UIColor clearColor]];
    [photosView.layer setCornerRadius:(height/2)];
    [photosView.layer setMasksToBounds:YES];
    [actionView addSubview:photosView];
    UITapGestureRecognizer *photogestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photosGestureTapped:)];
    [photosView addGestureRecognizer:photogestureRecognizer];
    
    
    
    xPos = 0.0;
    yPos = -6.0;
    width =photosView.frame.size.width;
    height = photosView.frame.size.height + 10.0;
    //MediaLinks
    self.mediaLinks = [[NSMutableArray alloc]init];
    NSArray *mediaLinks = [[self.entityDetail valueForKey:kEntity] valueForKey:@"mediaLinks"];
    
    
    // Dev changed... =============================================
    NSMutableArray *mediaUrls = [[NSMutableArray alloc]init];
    
    for (int i=0; i < mediaLinks.count; i++) {
        if (mediaUrls.count==0) {
            [mediaUrls addObject:[mediaLinks objectAtIndex:i]];
            
        }
        else if ([[mediaUrls valueForKey:@"mediaId" ] containsObject:[[mediaLinks objectAtIndex:i] valueForKey:@"mediaId"]])
        {
            NSLog(@"Same object");
        }
        else
        {
            [mediaUrls addObject:[mediaLinks objectAtIndex:i]];
        }
    }
    //=============================================================

    
    
    
    [mediaUrls enumerateObjectsUsingBlock:^(id obj, NSUInteger objc, BOOL * stop)
     {
         NSString *mediaLink = [obj valueForKey:@"mediaId"];
         if (mediaLink != nil && [mediaLink length] > 0)
         {
             [self.mediaLinks addObject:obj];
         }
         
     }];

    UILabel *photosLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [photosLbl setText:[NSString stringWithFormat:@"%@  Photos",[NSString stringWithFormat:@"%lu",(unsigned long)[self.mediaLinks count]]]];
    [photosLbl setNumberOfLines:2];
    [photosLbl setTextColor:[UIColor whiteColor]];
    [photosLbl setTextAlignment:NSTextAlignmentCenter];
    [photosLbl setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
    [photosLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [photosView addSubview:photosLbl];
}




#pragma mark- Shorten URL Method

-(void)shortenMapUrl:(NSString*)originalURL {
    
    NSString* googString = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",originalURL];
    NSURL* googUrl = [NSURL URLWithString:googString];
    
    NSMutableURLRequest* googReq = [NSMutableURLRequest requestWithURL:googUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [googReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString* longUrlString = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}",originalURL];
    
    NSData* longUrlData = [longUrlString dataUsingEncoding:NSUTF8StringEncoding];
    [googReq setHTTPBody:longUrlData];
    [googReq setHTTPMethod:@"POST"];
    
    NSURLConnection* connect = [[NSURLConnection alloc] initWithRequest:googReq delegate:self];
    connect = nil;
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSString* returnData = [NSString stringWithUTF8String:[data bytes]];
    
    /*
    [webLinkLbl setHidden:NO];
    [webLinkLbl setText:[NSString stringWithFormat:@" %@",returnData]];
    NSLog(@"location.text: %@", webLinkLbl.text);
    */
}


#pragma mark- Preview ZOom Image

-(void)zoomImagePreview:(UITapGestureRecognizer*) gesture
{
    NSLog(@"Phot Url === %@",self.photoUrlsArr);
    
    PhotoViewController *vctr = [[PhotoViewController alloc] init];
    vctr.pageImages = self.photoUrlsArr;
    [self.navigationController pushViewController:vctr animated:YES];

    // kick things off by making the first page
}

#pragma mark- Zoom Image 

-(void)zoomImage:(UITapGestureRecognizer*) gesture{
    NSData *milestoneImageData = UIImagePNGRepresentation(_offerImg.image);
    NSData *noImageData = UIImagePNGRepresentation([UIImage imageNamed:@"no_image"]);
    NSData *loadingImageData = UIImagePNGRepresentation([UIImage imageNamed:@"loading"]);
    if (![milestoneImageData isEqual:noImageData] && ![milestoneImageData isEqual:loadingImageData]) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        BBImageManipulator *controller = [BBImageManipulator loadController:_offerImg.image];
//        [controller setRotatableByButton:YES];
        [controller setZoomable:YES];
        [controller setDoubleTapZoomable:YES];
        [controller setupUIAndGestures];
        [self.view addSubview:controller];
    }
}


#pragma mark - Handler
- (void)getEnityWitEntityId:(NSString *)entityId
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    NSMutableDictionary *params  =[NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:limit forKey:kLimit];
    [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:kBefore];
    [[YoReferAPI sharedAPI] entityWithParams:params entityId:[self.entityDetail objectForKey:@"entityid"] completionHandler:^(NSDictionary * response, NSError * error)
    {
        [self didReceiveEnityWithResponse:response error:error];
        
    }];
}
- (void)didReceiveEnityWithResponse:(NSDictionary *)response error:(NSError *)error
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
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kEntityError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        for (NSDictionary *dictionary in [response objectForKey:@"response"])
        {
            Entity *entity = [Entity getentityByResponse:dictionary];
            [self.entity addObject:entity];
        }
    }
    [self reloadTableView];
}

#pragma mark  - tableView Datasource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRownInSection:self.entityType];
}
- (NSInteger)numberOfRownInSection:(EntityType)entityType
{
    NSInteger numberOfRow;
    switch (entityType)
    {
        case EntityFeeds:
            numberOfRow  = [self.entity count];
            break;
        case EntityPhotos:
            numberOfRow = [[self getMediaArrayWithArray:[self.entityDetail objectForKey:@"medialinks"]] count];
        default:
            break;
            
    }
    return numberOfRow;
}
- (NSMutableArray *)getMediaArrayWithArray:(NSMutableArray *)array
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
    self.photoUrlsArr = [[NSMutableArray alloc]init];

    if (self.photoUrlsArr.count < 1 || self.photoUrlsArr == nil) {
        for (int i = 0; i < array.count; i++) {
            [self.photoUrlsArr addObject: [[array objectAtIndex:i] objectForKey:@"mediaId"]];
        }
    }
    
    return featured;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.entityType == EntityFeeds)?kEntityFeeds:kEntityPhotos;
}

- (EntityTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EntityTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:(self.entityType == EntityFeeds)?[self getEntityIdentifierWithEntityType:self.entityType indexPath:indexPath]:nil];
    if (cell == nil)
    {
        cell = [[EntityTableViewCell alloc]initEntityType:self.entityType response:(self.entityType == EntityFeeds)?[[self getResponseWithentityType:self.entityType] objectAtIndex:indexPath.row]:[self getResponseWithentityType:self.entityType] indexPath:indexPath delegate:self type:[self.entityDetail valueForKey:@"type"]];
        [cell setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
    }
    
    if (self.entityType == EntityPhotos) {
        UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImagePreview:)];
        [cell addGestureRecognizer:profileGestureRecognizer];
    }
   
    return cell;
}



- (NSString *)getEntityIdentifierWithEntityType:(EntityType)entityType indexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    switch (entityType) {
        case EntityFeeds:
            identifier = [NSString stringWithFormat:@"%@_%ld",kEntityFeedsReuseIdentifier,indexPath.row];
            break;
        case EntityPhotos:
            identifier = [NSString stringWithFormat:@"%@_%ld",kEntityPhotosReuseIdentifier,indexPath.row];
            break;
        default:
            break;
    }
    return identifier;
}

- (NSArray *)getResponseWithentityType:(EntityType)entityType
{
    NSArray *response = nil;
    switch (entityType) {
        case EntityFeeds:
            response =  self.entity;
            break;
        case EntityPhotos:
            response = [self.entityDetail objectForKey:@"medialinks"];

            break;
        default:
            break;
    }
    return  response;
}

#pragma mark - Protocol
- (NSMutableDictionary *)getReferDetailWithIndexPath:(NSIndexPath *)indexPath
{
    Entity *refer = (Entity *)[self.entity objectAtIndex:indexPath.row];
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
        [dictionary setValue:[refer.entity valueForKey:@"entityId"] forKey:@"entityId"];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
    }else
    {
        [dictionary setValue:refer.mediaId forKey:kReferimage];
        [dictionary setValue:refer.type forKey:kCategorytype];
        [dictionary setValue:refer.entityName forKey:kName];
        [dictionary setValue:[refer.entity objectForKey:kCategory] forKey:kCategory];
        [dictionary setValue:refer.note forKey:kMessage];
        [dictionary setValue:[refer.entity objectForKey:@"entityId"] forKey:kEntityId];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
        if ([refer.type  isEqualToString:kProduct])
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
        }
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    }
    return dictionary;
}


- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self getReferDetailWithIndexPath:indexPath]delegate:nil];
    [self.navigationController pushViewController:vctr animated:YES];
}
- (void)pushToMapPageWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    Entity *entity = (Entity *)[self.entity objectAtIndex:indexPath.row];
    [dict setValue:[entity.entity  objectForKey:kEntityId] forKey:@"entityid"];
    [dict setValue:[entity.entity valueForKey:@"referCount"] forKey:kReferCount];
    [dict setValue:[entity.entity valueForKey:@"mediaCount"] forKey:kMediaCount];
    [dict setValue:[entity.entity valueForKey:@"name"] forKey:kName];
    [dict setValue:entity.entity forKey:kEntity];
    [dict setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
    [dict setValue:[entity.entity valueForKey:@"type"] forKey:kType];
    if ([[entity.entity valueForKey:kType]isEqualToString:kWeb])
    {
        WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[entity.entity valueForKey:kWebSite]] title:@"Web" refer:YES categoryType:@""];
        [self.navigationController pushViewController:vctr animated:YES];
        
    }else
    {
        if ([entity.type isEqualToString:kProduct])
        {
            [dict setValue:[NSString stringWithFormat:@"%@",[[[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
            [dict setValue:[NSString stringWithFormat:@"%@",[[[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
            [dict setValue:entity.mediaId forKey:kImage];
            [dict setValue:[[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kLocality] forKey:kLocality];
            [dict setValue:[[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kPhone] forKey:kPhone];
            [dict setValue:[[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
            [dict setValue:[[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCategory] forKey:kCategory];
        }else
        {
            [dict setValue:[entity.location objectAtIndex:0] forKey:kLongitude];
            [dict setValue:[entity.location objectAtIndex:1] forKey:kLatitude];
            [dict setValue:entity.mediaId forKey:kImage];
            [dict setValue:[entity.entity  valueForKey:kLocality] forKey:kLocality];
            [dict setValue:[entity.entity  valueForKey:kPhone] forKey:kPhone];
            [dict setValue:[entity.entity objectForKey:kWebSite] forKey:kWeb];
            [dict setValue:[entity.entity   objectForKey:kCategory] forKey:kCategory];
            
        }
        NSMutableArray *mapArray = [[NSMutableArray alloc]initWithObjects:dict, nil];
        MapViewController *vctr=[[MapViewController alloc]initWithResponse:mapArray type:@"Others" isCurrentOffers:NO];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}


#pragma mark- Button delegate
- (IBAction)referButtonTapped:(id)sender
{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    if ([[self.entityDetail objectForKey:@"ismap"]boolValue])
    {
        [dictionary setValue:[self.entityDetail objectForKey:@"mediaid"] forKey:kReferimage];
        [dictionary setValue:[self.entityDetail objectForKey:kCategorytype] forKey:kCategorytype];
        [dictionary setValue:[self.entityDetail valueForKey:kName] forKey:kName];
        [dictionary setValue:[self.entityDetail objectForKey:kCategory] forKey:kCategory];
        [dictionary setValue:[self.entityDetail objectForKey:kMessage] forKey:kMessage];
        [dictionary setValue:[self.entityDetail objectForKey:@"entityid"] forKey:@"entityId"];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[self.entityDetail valueForKey:kCity] forKey:kCity];
        [dictionary setValue:[self.entityDetail valueForKey:kLocality] forKey:kLocation];
        [dictionary setValue:[self.entityDetail valueForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[self.entityDetail valueForKey:kWeb] forKey:kWebSite];
        [dictionary setValue:[self.entityDetail valueForKey:kLongitude] forKey:kLongitude];
        [dictionary setValue:[self.entityDetail valueForKey:kLatitude] forKey:kLatitude];
        [dictionary setValue:[self.entityDetail valueForKey:kType] forKey:kCategorytype];
        [dictionary setValue:[self.entityDetail valueForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[self.entityDetail valueForKey:kFromWhere] forKey:kFromWhere];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
    }else if ([[self.entityDetail objectForKey:@"carousel"]boolValue])
    {
        [dictionary setValue:[self.entityDetail valueForKey:kMediaId] forKey:kReferimage];
        [dictionary setValue:[self.entityDetail objectForKey:kType] forKey:kCategorytype];
        [dictionary setValue:[self.entityDetail valueForKey:kName] forKey:kName];
        [dictionary setValue:[self.entityDetail objectForKey:kCategory] forKey:kCategory];
        [dictionary setValue:[self.entityDetail objectForKey:kMessage] forKey:kMessage];
        [dictionary setValue:[self.entityDetail objectForKey:@"entityid"] forKey:@"entityId"];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[self.entityDetail valueForKey:kCity] forKey:kCity];
        [dictionary setValue:[self.entityDetail valueForKey:kLocality] forKey:kLocation];
        [dictionary setValue:[self.entityDetail valueForKey:kPhone] forKey:kPhone];
        [dictionary setValue:[self.entityDetail valueForKey:kWeb] forKey:kWebSite];
        NSArray *latLng = [self.entityDetail valueForKey:kLocation];
        [dictionary setValue:[NSString stringWithFormat:@"%@",[latLng objectAtIndex:1]] forKey:kLongitude];
        [dictionary setValue:[NSString stringWithFormat:@"%@",[latLng objectAtIndex:0]] forKey:kLatitude];
        [dictionary setValue:[self.entityDetail valueForKey:kFromWhere] forKey:kFromWhere];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
    }else if ([[[self.entityDetail objectForKey:kEntity]objectForKey:kType] isEqualToString:kWeb])
    {
        [dictionary setValue:[[self.entityDetail valueForKey:kEntity] valueForKey:kCategory] forKey:kCategory];
        [dictionary setValue:@"Weblink" forKey:kAddress];
        [dictionary setValue:[self.entityDetail valueForKey:kMessage] forKey:kMessage];
        [dictionary setValue:[self.entityDetail valueForKey:kName]  forKey:kName];
        [dictionary setValue:[[self.entityDetail  valueForKey:kEntity] valueForKey:kWebSite] forKey:kWebSite];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
        [dictionary setValue:[[self.entityDetail valueForKey:kEntity] valueForKey:@"entityId"] forKey:@"entityId"];
        [dictionary setValue:[self.entityDetail valueForKey:kLongitude] forKey:kLongitude];
        [dictionary setValue:[self.entityDetail valueForKey:kLatitude] forKey:kLatitude];
    }else
    {
        [dictionary setValue:[self.entityDetail objectForKey:kMediaId] forKey:kReferimage];
        [dictionary setValue:[[self.entityDetail objectForKey:kEntity]objectForKey:kType] forKey:kCategorytype];
        [dictionary setValue:[[self.entityDetail objectForKey:kEntity]objectForKey:kName] forKey:kName];
        [dictionary setValue:[self.entityDetail objectForKey:kCategory] forKey:kCategory];
        [dictionary setValue:[self.entityDetail objectForKey:kMessage] forKey:kMessage];
        [dictionary setValue:[[self.entityDetail objectForKey:kEntity]objectForKey:@"entityId"] forKey:@"entityId"];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:[[self.entityDetail objectForKey:kEntity]objectForKey:kCity] forKey:kCity];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
        if ([[[self.entityDetail objectForKey:kEntity]objectForKey:kType]  isEqualToString:kProduct])
        {
            [dictionary setValue:[[[[self.entityDetail objectForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kPosition];
            [dictionary setValue:[[[[self.entityDetail objectForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocation];
            [dictionary setValue:[[[[self.entityDetail objectForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
            [dictionary setValue:[[[[self.entityDetail objectForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWebSite];
            [dictionary setValue:[[[[self.entityDetail objectForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCity] forKey:kAddress];
            [dictionary setValue:[[[[self.entityDetail objectForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kName] forKey:kFromWhere];
            if ([[[[[self.entityDetail objectForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] count] > 0)
            {
                [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[[self.entityDetail objectForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
                [dictionary setValue:[NSString stringWithFormat:@"%@",[[[[[self.entityDetail objectForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
            }
        }else
        {
            [dictionary setValue:[[self.entityDetail objectForKey:kEntity]objectForKey:kCity] forKey:kCity];
            [dictionary setValue:[[self.entityDetail objectForKey:kEntity] objectForKey:kLocality] forKey:kLocation];
            [dictionary setValue:[[self.entityDetail objectForKey:kEntity] objectForKey:kPhone] forKey:kPhone];
            [dictionary setValue:[[self.entityDetail objectForKey:kEntity] objectForKey:kWebSite] forKey:kWebSite];
            if ([[[self.entityDetail objectForKey:kEntity] objectForKey:kPosition] count] > 0) {
                
                [dictionary setValue:[NSString stringWithFormat:@"%@",[[[self.entityDetail objectForKey:kEntity] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
                [dictionary setValue:[NSString stringWithFormat:@"%@",[[[self.entityDetail objectForKey:kEntity] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
            }
        }
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    }
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:nil];
    [self.navigationController pushViewController:vctr animated:YES];
}
- (IBAction)closeBtnTapped:(id)sender
{
    [(UIView *)[self.view viewWithTag:80000] removeFromSuperview];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 300) {
        if (buttonIndex == 0)
        {
            if ([MFMailComposeViewController canSendMail]) {
                
                MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
                [mailComposer setMailComposeDelegate:self];
                [mailComposer setSubject:@"Feedback"];
                [mailComposer setToRecipients:[NSArray arrayWithObject:[[[[self.entityDetail valueForKey:kEntity] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kEmail]]];
                [mailComposer setMessageBody:@"" isHTML:NO];
                [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
                
            }else{
                
            }

        }
        else if (buttonIndex == 1)
        {
            
        }

    }
    else{
        if (buttonIndex == 0)
        {
            
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[self.entityDetail objectForKey:kPhone]]]];
        }
        else if (buttonIndex == 1)
        {
            
        }

    }
}

#pragma mark - GestureRecognize
- (BOOL)getUserDetailWithIndexPath:(NSIndexPath *)indexPath userType:(NSUInteger )usetType detail:(NSMutableDictionary **)detail
{
    NSMutableDictionary *userDetail = [NSMutableDictionary dictionaryWithCapacity:1];
    Entity *home = (Entity *)[self.entity  objectAtIndex:indexPath.row];
    BOOL isGuest;
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
        for ( int i =0; i < [home.toUsers count]; i++) {
            if([[[home.toUsers objectAtIndex:i]objectForKey:kGuest] boolValue])
            {
            }else
            {
                [refreeUser addObject:[home.toUsers objectAtIndex:i]];
            }
        }
        if ([refreeUser count] > 0)
        {
            [self referListWithDetail:refreeUser];
        }
    }
    if (isGuest)
        return NO;
    *detail = userDetail;
    return YES;
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
    [userDetail setValue:[[NSArray alloc] initWithObjects:user, nil]   forKey:@"touser"];
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
- (void)mapGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([[self.entityDetail valueForKey:@"ismap"] boolValue])
        
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([[self.entityDetail valueForKey:@"type"]isEqualToString:kWeb])
    {
        WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[self.entityDetail valueForKey:kWeb]] title:@"Web" refer:YES categoryType:@""];
        [self.navigationController pushViewController:vctr animated:YES];
        
        
    }else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        if ([[self.entityDetail valueForKey:@"carousel"] boolValue])
        {
            [dict setValue:[self.entityDetail valueForKey:@"entityid"]forKey:@"entityid"];
            [dict setValue:[self.entityDetail valueForKey:kReferCount] forKey:kReferCount];
            [dict setValue:[self.entityDetail valueForKey:kMediaCount] forKey:@"mediaCount"];
            [dict setValue:[self.entityDetail valueForKey:kName] forKey:kName];
            [dict setValue:[self.entityDetail valueForKey:kType] forKey:kType];
            [dict setValue:[[self.entityDetail valueForKey:kLocation] objectAtIndex:1] forKey:kLatitude];
            [dict setValue:[self.entityDetail valueForKey:kEntity] forKey:kEntity];
            [dict setValue:[[self.entityDetail valueForKey:kLocation] objectAtIndex:0] forKey:kLongitude];
            [dict setValue:[self.entityDetail valueForKey:kMediaId] forKey:kImage];
            [dict setValue:[self.entityDetail valueForKey:kCategory]forKey:kCategory];
        }else if ([[self.entityDetail valueForKey:@"ismap"] boolValue])
        {
            [dict setValue:[self.entityDetail valueForKey:@"entityid"]forKey:@"entityid"];
            [dict setValue:[self.entityDetail valueForKey:kReferCount] forKey:kReferCount];
            [dict setValue:[self.entityDetail valueForKey:kEntity] forKey:kEntity];
            [dict setValue:[self.entityDetail valueForKey:kMediaCount] forKey:@"mediaCount"];
            [dict setValue:[self.entityDetail valueForKey:kName] forKey:kName];
            [dict setValue:[self.entityDetail valueForKey:kType] forKey:kType];
            [dict setValue:[self.entityDetail valueForKey:kLatitude] forKey:kLatitude];
            [dict setValue:[self.entityDetail valueForKey:kLongitude] forKey:kLongitude];
            [dict setValue:([[self.entityDetail valueForKey:kMediaId] length] > 0)?[self.entityDetail valueForKey:kMediaId]:@"" forKey:kImage];
            [dict setValue:[self.entityDetail valueForKey:kCategory]forKey:kCategory];
        }else
        {
            [dict setValue:[[self.entityDetail valueForKey:kEntity]  objectForKey:kEntityId] forKey:@"entityid"];
            [dict setValue:[self.entityDetail valueForKey:kEntity] forKey:kEntity];
            [dict setValue:[[self.entityDetail valueForKey:kEntity] valueForKey:@"referCount"] forKey:kReferCount];
            [dict setValue:[[self.entityDetail valueForKey:kEntity] valueForKey:@"mediaCount"] forKey:kMediaCount];
            [dict setValue:[[self.entityDetail valueForKey:kEntity] valueForKey:kName] forKey:kName];
            [dict setValue:[self.entityDetail  valueForKey:kType] forKey:kType];
            if ([[self.entityDetail valueForKey:kType] isEqualToString:kProduct])
            {
                [dict setValue:[NSString stringWithFormat:@"%@",[[[[[self.entityDetail valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude
                 ];
                [dict setValue:[NSString stringWithFormat:@"%@",[[[[[self.entityDetail valueForKey:kEntity]objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
                [dict setValue:[[[self.entityDetail valueForKey:kEntity] objectForKey:kDp] objectForKey:@"mediaId"] forKey:kImage];
                [dict setValue:[[[[self.entityDetail valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kLocality] forKey:kLocality];
                [dict setValue:[[[[self.entityDetail valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] valueForKey:kPhone] forKey:kPhone];
                [dict setValue:[[[[self.entityDetail valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
                [dict setValue:[[[[self.entityDetail valueForKey:kEntity] objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCategory] forKey:kCategory];
            }else
            {
                [dict setValue:[[self.entityDetail valueForKey:kLocation] objectAtIndex:0] forKey:kLongitude];
                [dict setValue:[[self.entityDetail valueForKey:kLocation] objectAtIndex:1] forKey:kLatitude];
                [dict setValue:[self.entityDetail objectForKey:kMediaId] forKey:kImage];
                [dict setValue:[self.entityDetail valueForKey:kEntity] forKey:kEntity];
                [dict setValue:[[self.entityDetail valueForKey:kEntity]  valueForKey:kLocality] forKey:kLocality];
                [dict setValue:[[self.entityDetail valueForKey:kEntity]  valueForKey:kPhone] forKey:kPhone];
                [dict setValue:[[self.entityDetail valueForKey:kEntity] objectForKey:kWebSite] forKey:kWeb];
                [dict setValue:[[self.entityDetail valueForKey:kEntity]  objectForKey:kCategory] forKey:kCategory];
            }
        }
        [dict setValue:[NSNumber numberWithBool:YES] forKey:kIsEntity];
        NSMutableArray *mapArray = [[NSMutableArray alloc]initWithObjects:dict, nil];
        MapViewController *vctr=[[MapViewController alloc]initWithResponse:mapArray type:@"Others" isCurrentOffers:NO];
        [self.navigationController pushViewController:vctr animated:YES];
    }
}

- (void)webViewGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    /*
    if ([[self.entityDetail valueForKey:kType] isEqualToString:kService])
    {
        
        if ([self.entityDetail objectForKey:kWeb] != nil && [[self.entityDetail objectForKey:kWeb] length] > 0)
        {
            if ([MFMailComposeViewController canSendMail]) {
                
                MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
                [mailComposer setMailComposeDelegate:self];
                [mailComposer setSubject:@"Feedback"];
                [mailComposer setToRecipients:[NSArray arrayWithObject:[self.entityDetail valueForKey:kWeb]]];
                [mailComposer setMessageBody:@"" isHTML:NO];
                [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
                
            }else{
                
            }

            
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], kEntityEmail, nil, @"Ok", nil, 0);
            return;
        }

        
    }else
    {
    */
        if ([self.entityDetail objectForKey:kWeb] != nil && [[self.entityDetail objectForKey:kWeb] length] > 0)
        {
            WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[self.entityDetail objectForKey:kWeb]] title:@"Web" refer:NO categoryType:@""];
            [self.navigationController pushViewController:vctr animated:YES];
            
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], kEntityWebsite, nil, @"Ok", nil, 0);
            return;
        }

//    }

}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    
    if (result==MFMailComposeResultCancelled) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (void)phoneGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view.tag == 0)
    {
        alertView([[Configuration shareConfiguration] errorMessage], kEntityPhone, nil, @"Ok", nil, 0);
        return;
        
    }else
    {
        alertView([[Configuration shareConfiguration] appName],kEntityCall, self, @"Yes", @"No", 100);
    }
}

- (void)emailGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view.tag == 0)
    {
        alertView([[Configuration shareConfiguration] errorMessage], kEntityEmail, nil, @"Ok", nil, 0);
        return;
        
    }else
    {
        alertView([[Configuration shareConfiguration] appName],kEntitySendEmail, self, @"Yes", @"No", 300);
    }
}


- (void)feedsGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.entityType = EntityFeeds;
    [self setEntityType];
    [self reloadTableView];
}
- (void)photosGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    self.entityType = EntityPhotos;
    [self setEntityType];
    [self.entityDetail setValue:self.mediaLinks forKey:@"medialinks"];
    [self reloadTableView];
}

- (void)setEntityType
{
    switch (self.entityType) {
        case EntityFeeds:
            [(UILabel *)[[[self.view viewWithTag:refersCountTag] subviews] objectAtIndex:0] setTextColor:[UIColor whiteColor]];
            [(UILabel *)[[[self.view viewWithTag:photoCountTag] subviews] objectAtIndex:0] setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
            [(UIView *)[self.view viewWithTag:photoCountTag] setBackgroundColor:[UIColor clearColor]];
            [(UIView *)[self.view viewWithTag:refersCountTag] setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
            break;
        case EntityPhotos:
            [(UIView *)[self.view viewWithTag:photoCountTag] setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
            [(UIView *)[self.view viewWithTag:refersCountTag] setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[self.view viewWithTag:refersCountTag] subviews] objectAtIndex:0] setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
            [(UILabel *)[[[self.view viewWithTag:photoCountTag] subviews] objectAtIndex:0] setTextColor:[UIColor whiteColor]];
            break;
        default:
            break;
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
