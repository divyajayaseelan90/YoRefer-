    //
//  ReferNowViewController.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/15/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ReferNowViewController.h"
#import "Configuration.h"
#import "YoReferAPI.h"
#import "Utility.h"
#import "CoreData.h"
#import "UserManager.h"
#import "UIManager.h"
#import "NIDropDown.h"
#import "Helper.h"
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "DocumentDirectory.h"
#import "YoReferUserDefaults.h"
#import "MapViewController.h"
#import "YoReferSocialChannels.h"
#import "EntityViewController.h"
#import "MeTableViewCell.h"
#import "WebViewController.h"
#import "ImageViewController.h"

NSString            *isnameFieldBlank    =   @"";


typedef  void (^PlaceSearchHandler)(NSDictionary *dictionary);

typedef enum
{
    Message,
    Email,
    Whatsapp,
    Facebook,
    Twitter,
    PointSharing
}ShareType;

NSString    *   const kReferLocationMessage            = @"Yorefer would like to use your location";
NSString    *   const kReferNewImage                   = @"Select Picture";
NSInteger       const kReferLocationTag                = 60000;
NSUInteger      const kReferLocationButtonEnableTag    = 13212;
NSUInteger      const kReferLocationButtonDisableTag   = 13213;


NSString    *   const  kReferNowError        = @"Unable to get refer";
NSString    *   const  kReferNowLoading      = @"Loading...";
NSInteger       const  kReferScrollViewTag   = 3000;
NSInteger       const  kPopupViewTag         = 60000;
NSUInteger      const  kNumberOfRowInRefer   = 9;

MPMoviePlayerController *player;

//static NSString *const SHKFacebookAppID=@"218280681550716";
//static NSString* kAppId = @"218280681550716";


@interface ReferNowViewController ()<referNowTableViewCell,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate,UIScrollViewDelegate,MapRefer,NIDropDownDelegate, UIActionSheetDelegate>

@property (nonatomic, readwrite)    ReferNowType          referNowType;
@property (nonatomic,readwrite)     CGFloat               shiftForKeyboard;
@property (nonatomic, strong)       NSMutableDictionary * referDetail,*referMessages;
@property (nonatomic, readwrite)    BOOL                  isProduct;
@property (nonatomic, assign)       BOOL                  isDefaultImage;
@property (nonatomic, strong)       NSMutableArray      * contacts;
@property (nonatomic, strong)       NSString            * channelType,* entityId;
@property (retain)                  UIDocumentInteractionController   *documentInteractionController;
@property (nonatomic, strong)       ShareView           * shareRefer;
@property (nonatomic, strong)       NSMutableArray      * referResponse;
@property (nonatomic, strong)       NSArray             * localRefer;
@property (nonatomic, readwrite)    MeType                meType;
@property (strong, nonatomic)       UIView              * dropDownView;
@property (nonatomic, strong)       NIDropDown          * nIDropDown;
@property (nonatomic, strong)       UIImage             * preViewImage;

@end

@implementation ReferNowViewController

- (instancetype)initWithReferDetail:(NSMutableDictionary *)referDetail delegate:(id<Refer>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.referDetail = referDetail;
        
    }
    return self;
}

#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //shareView
    [self shareView];
    NSArray *category = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    
    /*
    if ([category count] == 0)
        [self getCategory];
    else
        [self reloadTableView];
    */
    
    //Dev changed here...
    if ([category count] == 0){
        if (self.referDetail && [self.referDetail objectForKey:@"category"]) {
            [self reloadTableView];
        }
        else
            [self getCategory];
    }
    else
        [self reloadTableView];
    
    [self getMessages];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:@"locationupdating" object:nil];
    // Do any additional setup after loading the view.
}

- (UIView *)beignView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = 60.0;
    CGFloat width = frame.size.width;
    UIView *viewSharing = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //button
    width = viewSharing.frame.size.width - 30.0;
    height = 46.0;
    xPos = round((viewSharing.frame.size.width - width)/2);
    yPos = round((viewSharing.frame.size.height - height)/2);
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [shareButton setTitle:NSLocalizedString(@"Refer Now", @"") forState:UIControlStateNormal];
    [shareButton.titleLabel setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:18.0]];
    [shareButton.layer setCornerRadius:23.0];
    [shareButton.layer setMasksToBounds:YES];
    [shareButton.layer setBorderWidth:2.0];
    [shareButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [shareButton setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [viewSharing addSubview:shareButton];
    return viewSharing;
}

- (UIView *)endView
{
    _referOptionCount = 0;
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = 64.0;
    CGFloat width = frame.size.width;
    
    UIView *viewSharing = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [viewSharing setBackgroundColor:[UIColor whiteColor]];
    xPos = 0.0;
    yPos = 0.0;
    width = viewSharing.frame.size.width/5;
    height = viewSharing.frame.size.height;
    
    UIView *message = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    message.tag = Message;
    message.backgroundColor = [UIColor clearColor];
    [self setDefaultReferChannleWithShareType:Message view:message];
    [viewSharing addSubview:message];
    xPos = message.frame.size.width;
    
    UIView *email = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    email.backgroundColor = [UIColor clearColor];
    [self setDefaultReferChannleWithShareType:Email view:email];
    [viewSharing addSubview:email];
    xPos = message.frame.size.width * 2;
    
    UIView *whatsApp = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    whatsApp.backgroundColor = [UIColor clearColor];
    [viewSharing addSubview:whatsApp];
    [self setDefaultReferChannleWithShareType:Whatsapp view:whatsApp];
    xPos = message.frame.size.width * 3;
    
    UIView *facebook = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    facebook.backgroundColor = [UIColor clearColor];
    [self setDefaultReferChannleWithShareType:Facebook view:facebook];
    [viewSharing addSubview:facebook];
    xPos = message.frame.size.width * 4;
   
    UIView *twitter = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    twitter.backgroundColor = [UIColor clearColor];
    [self setDefaultReferChannleWithShareType:Twitter view:twitter];
    [viewSharing addSubview:twitter];
    width = (frame.size.width < 400)?message.frame.size.width / 2:((message.frame.size.width / 2) - 6.0);
    height = message.frame.size.height /2;
    xPos = roundf((message.frame.size.width - width)/2);
    yPos = roundf((message.frame.size.height - height)/2) - 10.0;
   
    UIImageView *imageMessage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageMessage.image = [UIImage imageNamed:@"icon_message.png"];
    [message addSubview:imageMessage];
    UIImageView *imageEmail = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageEmail.image = [UIImage imageNamed:@"icon_email.png"];
    [email addSubview:imageEmail];
    UIImageView *imageWhatsApp = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageWhatsApp.image = [UIImage imageNamed:@"icon_whatsapp.png"];
    [whatsApp addSubview:imageWhatsApp];
    UIImageView *imageFacebook = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageFacebook.image = [UIImage imageNamed:@"icon_facebook.png"];
    [facebook addSubview:imageFacebook];
    UIImageView *imageTwitter = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageTwitter.image = [UIImage imageNamed:@"icon_twitter.png"];
    [twitter addSubview:imageTwitter];
    
    xPos = 0.0;
    yPos = imageMessage.frame.size.height - 2.0;
    width = message.frame.size.width;
    height = 30.0;
    UILabel *labelMessage = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelMessage.text = NSLocalizedString(@"Message", @"");
    labelMessage.textAlignment = NSTextAlignmentCenter;
    labelMessage.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    labelMessage.textColor = [UIColor blackColor];
    [message addSubview:labelMessage];
    UILabel *labelEmail = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelEmail.text = NSLocalizedString(@"Email", @"");
    labelEmail.textAlignment = NSTextAlignmentCenter;
    labelEmail.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    labelEmail.textColor = [UIColor blackColor];
    [email addSubview:labelEmail];
    UILabel *labelWhatsapp = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelWhatsapp.text = NSLocalizedString(@"Whatsapp", @"");
    labelWhatsapp.textAlignment = NSTextAlignmentCenter;
    labelWhatsapp.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    labelWhatsapp.textColor = [UIColor blackColor];
    [whatsApp addSubview:labelWhatsapp];
    UILabel *labelFacebook = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelFacebook.text = NSLocalizedString(@"Facebook", @"");
    labelFacebook.textAlignment = NSTextAlignmentCenter;
    labelFacebook.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    labelFacebook.textColor = [UIColor blackColor];
    [facebook addSubview:labelFacebook];
    UILabel *labelTwitter = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelTwitter.text = NSLocalizedString(@"Twitter", @"");
    labelTwitter.textAlignment = NSTextAlignmentCenter;
    labelTwitter.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    labelTwitter.textColor = [UIColor blackColor];
    [twitter addSubview:labelTwitter];
   
    
    
    UITapGestureRecognizer *tapMessage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(message:)];
    [message addGestureRecognizer:tapMessage];
    UITapGestureRecognizer *tapEmail = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(email:)];
    [email addGestureRecognizer:tapEmail];
    UITapGestureRecognizer *tapWhatsApp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whatsapp:)];
    [whatsApp addGestureRecognizer:tapWhatsApp];
    UITapGestureRecognizer *tapFacebook = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(facebook:)];
    [facebook addGestureRecognizer:tapFacebook];
    UITapGestureRecognizer *tapTwitter = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twitter:)];
    [twitter addGestureRecognizer:tapTwitter];
    return viewSharing;
}
- (void)setDefaultReferChannleWithShareType:(ShareType)shareType view:(UIView *)view
{
    switch (shareType) {
        case Message:
            if ([[YoReferSocialChannels shareYoReferSocial] getSmsSahring])
            {
                _referOptionCount++;
                [view setUserInteractionEnabled:YES];
                [view setAlpha:1.0];
                
            }else
            {
                [view setAlpha:0.3];
            }
            break;
        case Twitter:
            if ([[YoReferSocialChannels shareYoReferSocial] getTwitterSahring])
            {
                _referOptionCount++;
                [view setUserInteractionEnabled:YES];
                [view setAlpha:1.0];
                
            }else
            {
                [view setAlpha:0.3];
            }
            break;
        case Whatsapp:
            if ([[YoReferSocialChannels shareYoReferSocial] getWhatsappSahring])
            {
                _referOptionCount++;
                [view setUserInteractionEnabled:YES];
                [view setAlpha:1.0];
                
            }else
            {
                [view setAlpha:0.3];
                
            }
            break;
        case Email:
            if ([[YoReferSocialChannels shareYoReferSocial] getEmailSahring])
            {
                _referOptionCount++;
                [view setUserInteractionEnabled:YES];
                [view setAlpha:1.0];
                
            }else
            {
                [view setAlpha:0.3];
                
            }
            break;
        case Facebook:
            if ([[YoReferSocialChannels shareYoReferSocial] getFaceBookSahring])
            {
                _referOptionCount++;
                [view setUserInteractionEnabled:YES];
                [view setAlpha:1.0];
                
            }else
            {
                [view setAlpha:0.3];
            }
            break;
        default:
            break;
    }
}

- (void)shareView
{
    CGRect frame = [self bounds];
    CGFloat height = 85.0;
    CGFloat width = frame.size.width;
    CGFloat xPos = 0.0;
    CGFloat yPos = frame.size.height - 60.0;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
    xPos = 0;
    yPos = 0.0;
    for (int i = 0; i < 2; i++)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos,frame.size.width, frame.size.height)];
        [view setBackgroundColor:[UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f]];
        view.tag = i;
        [view addSubview:(i == 0)?[self beignView]:[self endView]];
        [scrollView addSubview:view];
        xPos += view.frame.size.width;
        
    }
    scrollView.contentSize = CGSizeMake(xPos, scrollView.frame.size.height);
    scrollView.tag = kReferScrollViewTag;
    scrollView.delegate  = self;
    scrollView.scrollEnabled = NO;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
}

- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath
{
    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:[self getEntityDetailWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]]];
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
    [response setValue:[categoryList objectForKey:@"entityId"] forKey:@"entityid"];
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
- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath
{
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self setReferWithCategoryList:[self.referResponse objectAtIndex:indexPath.row]] delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
}
-(NSMutableDictionary *)setReferWithCategoryList:(NSDictionary *)categoryList
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[categoryList objectForKeyedSubscript:kType] forKey:kCategorytype];
    [dictionary setValue:[categoryList objectForKeyedSubscript:kCategory] forKey:kCategory];
    [dictionary setValue:@"" forKey:@"categoryid"];
    [dictionary setValue:[categoryList objectForKey:kName] forKey:kName];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:kAddress];
    [dictionary setValue:[[UserManager shareUserManager] currentAddress] forKey:kLocation];
    [dictionary setValue:[[UserManager shareUserManager] latitude] forKey:kLatitude];
    [dictionary setValue:[[UserManager shareUserManager] longitude] forKey:kLongitude];
    [dictionary setValue:[[categoryList objectForKeyedSubscript:@"entity"] objectForKeyedSubscript:kCity] forKey:kAddress];
    [dictionary setValue:[categoryList objectForKeyedSubscript:kLocality] forKey:kLocation];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[[categoryList objectForKey:kPosition] objectAtIndex:1]] forKey:kLatitude];
    [dictionary setValue:[NSString stringWithFormat:@"%@",[[categoryList objectForKey:kPosition] objectAtIndex:0]] forKey:kLongitude];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kPhone] forKey:kPhone];
    if ([categoryList objectForKey:kDp] != nil && [[categoryList objectForKey:kDp] isKindOfClass:[NSString class]] > 0)
        [dictionary setValue:[categoryList objectForKey:kDp] forKey:kReferimage];
    [dictionary setValue:[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kWebSite] forKey:kWebSite];
    [dictionary setValue:[[[categoryList objectForKey:kEntity] objectForKeyedSubscript:kDp] objectForKey:@"entityId"] forKey:@"entityId"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    return dictionary;
}

- (void)getReferChannel:(NSDictionary *)referChannel
{
    if ([[self.referDetail valueForKey:kIsAsk] boolValue])
    {
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[referChannel valueForKey:kReferName],@"firstname",[referChannel valueForKey:kReferPhone],@"referphonnumber", nil];
        NSArray *referContacts = [[NSArray alloc]initWithObjects:dic, nil];
//      [self messageWithContacts:referContacts referChannel:referChannel];

        
        if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"WhatsApp"])
        {
            [self wahtsUpWithContacts:referContacts referChannel:self.referDetail];
            
        }else if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"FaceBook"])
        {
            [self facebookShare:referContacts referChannel:self.referDetail];
            
        }else if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"Twitter"])
        {
            [self twitterShare:referContacts referChannel:self.referDetail];
            
        }
        else if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"email"])
        {
            [self mailWithContacts:referContacts referChannel:self.referDetail];
            
        }
        else if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"Message"])
        {
            [self messageWithContacts:referContacts referChannel:referChannel];
            
        }
        
    }else
    {
        [self hideShowNavigationRightButtonWithBool:NO];
        [[UserManager shareUserManager] setReferPage];
        
        if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"WhatsApp"])
        {
            [self wahtsUpWithContacts:nil referChannel:self.referDetail];
            
        }else if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"FaceBook"])
        {
            [self facebookShare:nil referChannel:self.referDetail];
            
        }else if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"Twitter"])
        {
            [self twitterShare:nil referChannel:self.referDetail];
            
        }else
        {
            UIView *shareRefer  = [[ShareView alloc]initWithViewFrame:[self bounds] delegate:self referChannel:referChannel];
            shareRefer.tag = 40000;
            [shareRefer setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:shareRefer];
            shareRefer.frame = CGRectMake(0.0, [self bounds].size.height - 85.0, [self bounds].size.width, [self bounds].size.height - 65.0);
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 shareRefer.frame = CGRectMake(0.0, 59.0, [self bounds].size.width, [self bounds].size.height - 40.0);
                             }
                             completion:^(BOOL finished){
                             }];
        }
    }
}

- (void)dismissShareView
{
    UIView *view = (UIView *)[self.view viewWithTag:40000];
    if (view == nil)
    {
        [[UIManager sharedManager] goToHomePageWithAnimated:YES];
        
    }else
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             view.frame = CGRectMake(0.0, [self bounds].size.height, [self bounds].size.width, [self bounds].size.height - 64.0);
                         }
                         completion:^(BOOL finished){
                             
                             for (UIView *subView in self.view.subviews)
                             {
                                 if (subView.tag == 40000)
                                 {
                                     [subView removeFromSuperview];
                                 }
                             }
                             
                             
                         }];
    }
}
- (void)hidereferView:(NSNotification *)notification
{
    UIView *view = (UIView *)[self.view viewWithTag:50000];
    if (view == nil)
    {
        [[UIManager sharedManager] goToHomePageWithAnimated:YES];
        
    }else
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             view.frame = CGRectMake(0.0, [self bounds].size.height, [self bounds].size.width, [self bounds].size.height - 64.0);
                         }
                         completion:^(BOOL finished){
                             
                             for (UIView *subView in self.view.subviews)
                             {
                                 if (subView.tag == 40000)
                                 {
                                     [subView removeFromSuperview];
                                 }
                             }
                             
                             
                         }];
    }
}

#pragma mark - Handler
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
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kReferNowError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        [[CoreData shareData] setCategoryWithLoginId:[[UserManager shareUserManager] number] response:response];
        NSMutableArray *array = [self getCategoryWithCategoryType:([[self.referDetail valueForKey:kCategorytype] isEqualToString:kWeb])?kWeb:[[self.referDetail valueForKey:kCategorytype] isEqualToString:kProduct]?kProduct:[[self.referDetail valueForKey:kCategorytype] isEqualToString:kService]?kService:kPlace];
        CategoryType *category = (CategoryType *)[array objectAtIndex:0];
        [self.referDetail setValue:category.categoryName forKey:kCategory];
        [self.referDetail setValue:category.categoryID forKey:kCategoryid];
        [self reloadTableView];
    }
}

- (void)getMessages
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showHUDWithMessage:NSLocalizedString(@"", @"")];
        [[YoReferAPI sharedAPI] getMessagesWithCompletionHandler:^(NSDictionary * response, NSError * error){
            
            [self didReceiveMessagesWithResponse:response error:error];
            
        }];

    });
    
}

- (void)didReceiveMessagesWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        self.referMessages = [NSMutableDictionary dictionaryWithDictionary:response];
    }
}

#pragma mark - Tableview Data Source and Delegate
-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    self.tableView.frame = CGRectMake(frame.origin.x, 0.0, frame.size.width, frame.size.height - 60.0);
    [self.view layoutIfNeeded];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowInRefer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self rowHeightWithIndexPath:indexPath];
}
- (NSInteger)rowHeightWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 0.0;
    switch (indexPath.row) {
        case ReferLocations:
            height = 40.0;
            break;
        case ReferCategoryType:
            height = ([[self.referDetail objectForKey:kWeb] boolValue])?0.0:40.0;
            break;
        case ReferCategories:
            height = 51.0;
            break;
        case ReferName:
            height = 51.0;
            break;
        case ReferMessage:
            height = 65.0;
            break;
        case ReferFromWhere:
            height = ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kProduct])?40.0:0.0;
            break;
        case ReferAddress:
            height = ([[self.referDetail objectForKey:kWeb] boolValue])?0.0:73.0;
            break;
        case ReferPhoneAndWebSite:
            height = ([[self.referDetail objectForKey:kWeb] boolValue])?80.0:120.0;
            break;
        case ReferImage:
            height = ([[self.referDetail objectForKey:kWeb] boolValue])?0.0:90.0;
            break;
        default:
            break;
    }
    return height;
}
- (ReferNowTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReferNowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self getCellIdentifireWithReferType:(ReferNowType)indexPath.row indexPath:indexPath]];
    if (cell == nil)
    {
        cell = [[ReferNowTableViewCell alloc]initWithIndexPath:indexPath delegate:self referDetail:self.referDetail];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (NSString *)getCellIdentifireWithReferType:(ReferNowType)referType indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentification = nil;
    switch (referType) {
        case ReferLocations:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferCategoryType:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferCategories:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferName:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferMessage:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferFromWhere:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferAddress:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferPhoneAndWebSite:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
            break;
        case ReferImage:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",indexPath.row,kReferNowIdentifier];
        default:
            break;
    }
    return cellIdentification;

}


#pragma mark - Protocol
- (void)categoriesWithButton:(UIButton *)button
{
    [self.tableView endEditing:YES];
    if (self.nIDropDown == nil)
    {
        NSArray *array = [self getCategoryWithCategoryType:[self.referDetail valueForKey:kCategorytype]];
        CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.tableView];
        [self.referDetail setValue:[NSString stringWithFormat:@"%f",(frame.origin.y + 2.0)] forKey:kYPostion];
        [self nIDropDownWithDetails:array view:[button superview] isLocation:NO];
        
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    
    [self updateQueryWithText:[self.referDetail valueForKey:@"category"] queryType:ReferCategories];
}

- (void)getCategory:(CategoryType *)category
{
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self.referDetail setValue:category.categoryName forKey:kCategory];
    [self.referDetail setValue:(category.categoryID != nil && [category.categoryID isKindOfClass:[NSString class]] ? category.categoryID:@"") forKey:kCategoryid];
    [self updateQueryWithText:category.categoryName queryType:ReferCategories];
}

- (void)enableLocationWithButton:(UIButton *)button
{
    alertView(@"Location",kReferLocationMessage, self, @"Yes", @"No", kReferLocationTag);
}
- (void)locationSearchWithButton:(UIButton *)button
{
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.tableView];
    [self.referDetail setValue:[NSString stringWithFormat:@"%f",(frame.origin.y - 6.0)] forKey:kYPostion];
    NSArray *subViews = [[button superview] subviews];
    UITextField *textField = [subViews objectAtIndex:0];
    if ([textField.text length] > 0 && button.tag == kReferLocationButtonEnableTag)
    {
        textField.text = [textField.text substringToIndex:3];
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                button.tag = kReferLocationButtonDisableTag;
                [self nIDropDownWithDetails:locationDetails view:[button superview] isLocation:YES];
            }
        }];
    }else
    {
        button.tag = kReferLocationButtonEnableTag;
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
        if ([[UserManager shareUserManager] getLocationService])
        {
            [(UITextField *)[subViews objectAtIndex:0] setText:[self.referDetail valueForKey:@"searchtext"]];
        }else
        {
            [(UITextField *)[subViews objectAtIndex:0] setText:@""];
        }
        
    }
}

- (void)nIDropDownWithDetails:(NSArray *)details view:(UIView *)view isLocation:(BOOL)isLocation
{
    if(self.nIDropDown == nil)
    {
        CGFloat yPostion = [[self.referDetail valueForKey:kYPostion] floatValue] + 36.0;
        CGFloat changedHeight = [UIScreen mainScreen].bounds.size.height - (view.frame.size.height + (yPostion + 84.0));
        self.dropDownView = [[UIView alloc]initWithFrame:CGRectMake(10.0, yPostion, view.frame.size.width, changedHeight)];
        UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, self.dropDownView.frame.size.width, self.dropDownView.frame.size.height)];
        CGRect btnFrame=locationBtn.frame;
        btnFrame.origin.y=0.0;
        btnFrame.origin.x = -10.0;
        btnFrame.size.height=0.0;
        locationBtn.frame=btnFrame;
        locationBtn.backgroundColor=[UIColor clearColor];
        CGFloat f = changedHeight;
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
    [self.referDetail setValue:[location objectForKey:@"description"] forKey:@"searchtext"];
    [self.referDetail setValue:[location objectForKey:@"description"] forKey:kCity];
    [self.referDetail setValue:@"" forKey:@"entityId"];
    [self updateQueryWithText:[location objectForKey:@"description"] queryType:ReferLocations];
    [[LocationManager shareLocationManager] getCurrentLocationAddressFromPlaceId:[location objectForKey:@"place_id"] :^(NSMutableDictionary *dictionary)
     {
         [self.referDetail setValue:[NSString stringWithFormat:@"%@",[dictionary valueForKey:kLatitude]] forKey:kLatitude];
         [self.referDetail setValue:[NSString stringWithFormat:@"%@",[dictionary valueForKey:kLongitude]] forKey:kLongitude];
         [self.referDetail setValue:[dictionary valueForKey:@"currentAddress"] forKey:kLocation];
         [self updateQueryWithText:[dictionary valueForKey:@"currentAddress"] queryType:ReferAddress];
     }];
}

- (void)updateLocation
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self locationUpdate];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
}




- (void)placeWithSpuerView:(UIView *)supverView
{
    isnameFieldBlank = @"YES";
    
    [self.tableView endEditing:YES];
    NSMutableArray *array = [self getCategoryWithCategoryType:kPlace];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.referDetail setValue:kPlace forKey:kCategorytype];
    [self.referDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Places];
    [self updateQueryWithText:category.categoryName queryType:ReferCategoryType];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIButton *button =  [self getCategoryButtonWithQueryType:ReferCategories];
    [self categoriesWithButton:button];
    [self.tableView reloadData];
    
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    
    [self updateQueryWithText:@"" queryType:ReferFromWhere];
    
    
//    [self updateQueryWithText:[self.referDetail valueForKey:kCategorytype] queryType:ReferFromWhere];
//    [self updateQueryWithText:[self.referDetail valueForKey:@"name"] queryType:ReferName];
//    [self updateQueryWithText:[self.referDetail valueForKey:kEmail] queryType:ReferPhoneAndWebSite];
//    [self updateQueryWithText:[self.referDetail valueForKey:@"phone"] queryType:Phone];

    
    /*
    [self updateQueryWithText:@"" queryType:ReferFromWhere];
    [self updateQueryWithText:@"" queryType:ReferName];
    [self updateQueryWithText:@"" queryType:ReferAddress];
    [self updateQueryWithText:@"" queryType:ReferPhoneAndWebSite];
    */
    
    /*
    [self updateQueryWithText:[self.referDetail valueForKey:kFromWhere] queryType:ReferFromWhere];
    [self updateQueryWithText:[self.referDetail valueForKey:kReferName] queryType:ReferName];
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    [self updateQueryWithText:[self.referDetail valueForKey:kWebSite] queryType:ReferPhoneAndWebSite];
     */
}

- (void)productWithSpuerView:(UIView *)supverView
{
    isnameFieldBlank = @"YES";
    
    [self.tableView endEditing:YES];
    NSMutableArray *array = [self getCategoryWithCategoryType:kProduct];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.referDetail setValue:kProduct forKey:kCategorytype];
    [self.referDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Product];
    [self updateQueryWithText:category.categoryName queryType:ReferCategoryType];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIButton *button =  [self getCategoryButtonWithQueryType:ReferCategories];
    [self categoriesWithButton:button];
    [self.tableView reloadData];
    
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    [self updateQueryWithText:@"" queryType:ReferFromWhere];
    
    /*
    [self updateQueryWithText:@"" queryType:ReferFromWhere];
    [self updateQueryWithText:@"" queryType:ReferName];
    [self updateQueryWithText:@"" queryType:ReferAddress];
    [self updateQueryWithText:@"" queryType:ReferPhoneAndWebSite];
    */
    
    /*
    [self updateQueryWithText:[self.referDetail valueForKey:kFromWhere] queryType:ReferFromWhere];
    [self updateQueryWithText:[self.referDetail valueForKey:kReferName] queryType:ReferName];
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    [self updateQueryWithText:[self.referDetail valueForKey:kWebSite] queryType:ReferPhoneAndWebSite];
    */

}

- (void)serviceWithSpuerView:(UIView *)supverView
{
     isnameFieldBlank = @"YES";
    
    [self.tableView endEditing:YES];
    NSMutableArray *array = [self getCategoryWithCategoryType:kService];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.referDetail setValue:kService forKey:kCategorytype];
    [self.referDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Services];
    [self updateQueryWithText:category.categoryName queryType:ReferCategoryType];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    UIButton *button =  [self getCategoryButtonWithQueryType:ReferCategories];
    [self categoriesWithButton:button];
    [self.tableView reloadData];
    
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    [self updateQueryWithText:@"" queryType:ReferFromWhere];

    /*
    [self updateQueryWithText:@"" queryType:ReferFromWhere];
    [self updateQueryWithText:@"" queryType:ReferName];
    [self updateQueryWithText:@"" queryType:ReferAddress];
    [self updateQueryWithText:@"" queryType:ReferPhoneAndWebSite];
    */
    /*
    [self updateQueryWithText:[self.referDetail valueForKey:kFromWhere] queryType:ReferFromWhere];
    [self updateQueryWithText:[self.referDetail valueForKey:kReferName] queryType:ReferName];
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    [self updateQueryWithText:[self.referDetail valueForKey:kWebSite] queryType:ReferPhoneAndWebSite];
     */

}

- (void)webWithSpuerView:(UIView *)supverView
{
    
    [self.tableView endEditing:YES];
   [self activeCategoriesWithSubViews:[supverView subviews] categories:Web];
    NSMutableArray *array = [self getCategoryWithCategoryType:kWeb];
    CategoryType *category = (CategoryType *)[array objectAtIndex:0];
    [self.referDetail setValue:kPlace forKey:kCategorytype];
    [self.referDetail setValue:category.categoryName forKey:kCategory];
    [self activeCategoriesWithSubViews:[supverView subviews] categories:Places];
    [self updateQueryWithText:category.categoryName queryType:ReferCategoryType];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];

    //    UIButton *button =  [self getCategoryButtonWithQueryType:ReferCategories];
    //    [self categoriesWithButton:button];
   
    [self.tableView reloadData];
    
    /*
    [self updateQueryWithText:@"" queryType:ReferFromWhere];
    [self updateQueryWithText:@"" queryType:ReferName];
    */
    
    [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
    
    WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:@"http://www.google.com"] title:@"Web" refer:YES categoryType:@""];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (UIButton *)getCategoryButtonWithQueryType:(ReferNowType)queryType
{
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (ReferNowTableViewCell  * cell in tableSubViews)
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
                        return (UIButton *)[views objectAtIndex:1];
                    }
                }
            }
        }
    }
    return nil;
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
            
            CategoryType *product = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:product];
            
        }
        
    }else if ( [categoryType isEqualToString:kService])
    {
        for (NSDictionary *dictionary in [category valueForKey:kService]) {
            
            CategoryType *service = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:service];
            
        }
        
    }else if ( [categoryType isEqualToString:kWeb])
    {
        for (NSDictionary *dictionary in [category valueForKey:kWeb]) {
            
            CategoryType *web = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:web];
            
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
            [(UILabel *)[[[[[subViews objectAtIndex:3]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            break;
        case Product:
            [(UILabel *)[[[[[subViews objectAtIndex:0]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:1]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            [(UILabel *)[[[[[subViews objectAtIndex:2]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:3]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            break;
        case Services:
            [(UILabel *)[[[[[subViews objectAtIndex:0]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:1]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:2]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
             [(UILabel *)[[[[[subViews objectAtIndex:3]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            break;
        case Web:
            [(UILabel *)[[[[[subViews objectAtIndex:0]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:1]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:2]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)[[[[[subViews objectAtIndex:3]subviews]objectAtIndex:1] subviews] objectAtIndex:0]setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
            break;
        default:
            break;
    }
    
}

- (void)pushToMapPage
{
    [self.tableView endEditing:YES];
    MapViewController *vctr = [[MapViewController alloc]initWithResponse:nil type:@"Offers" isCurrentOffers:YES];
    [self.navigationController pushViewController:vctr animated:YES];
    /*NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[self.referDetail objectForKey:kLongitude] forKey:kLatitude];
    [dictionary setValue:[self.referDetail objectForKey:kLatitude] forKey:kLatitude];
    [dictionary setValue:[self.referDetail objectForKey:kName] forKey:kName];
    [dictionary setValue:[self.referDetail objectForKey:kReferimage] forKey:kImage];
    [dictionary setValue:[self.referDetail valueForKey:kNewRefer] forKey:kNewRefer];
    [dictionary setValue:[self.referDetail valueForKey:kIsEntity] forKey:kIsEntity];
    [dictionary setValue:[self.referDetail valueForKey:kCategorytype] forKey:kType];
    [dictionary setValue:([[self.referDetail valueForKey:kLocation] length] > 0)?[NSNumber numberWithBool:NO]:[NSNumber numberWithBool:YES] forKey:@"isCurrentLocation"];
    [dictionary setValue:[[self.referDetail valueForKey:kEntity] valueForKey:kLocality] forKey:kLocality];
    [dictionary setValue:[self.referDetail objectForKey:kCategory] forKey:kCategory];
    [dictionary setValue:[self.referDetail valueForKey:kEntity] forKey:kEntity];
    NSMutableArray *mapArray = [[NSMutableArray alloc]initWithObjects:dictionary, nil];
    MapViewController *vctr=[[MapViewController alloc]initWithResponse:mapArray type:@"Others" isCurrentOffers:NO];
    vctr.delegate = self;
    [self.navigationController pushViewController:vctr animated:YES];*/
}

- (void)newImage
{
    [[YoReferMedia shareMedia]setMediaWithDelegate:self title:kReferNewImage];
}

- (void)viewImageWithImage:(UIImage *)image defaultImage:(BOOL)isDefaultImage
{
    self.preViewImage = image;
    if (isDefaultImage && image == nil)
    {
        [self newImage];
        
    }else
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"View Picture",
                                @"New Picture",
                                nil];
        popup.tag = 1;
        [popup showInView:self.view];
    }
}

- (void)getProfilePicture:(NSMutableDictionary *)dictionary
{
    [self.referDetail setValue:[dictionary valueForKey:kImage] forKey:kReferimage];
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (ReferNowTableViewCell  * cell in tableSubViews)
        {
            NSArray *cellSubViews = [cell subviews];
            if ([cellSubViews count] > 0)
            {
                NSArray *subView = [[cellSubViews objectAtIndex:0] subviews];
                if ([subView count] > 0)
                {
                    UIView *view = [subView objectAtIndex:0];
                    if (view.tag == ReferImage)
                    {
                        NSArray *views = [view subviews];
                        [(UIImageView *)[views objectAtIndex:0] setImage:[dictionary valueForKey:kImage]];
                        [(UIImageView *)[views objectAtIndex:2] setImage:[dictionary valueForKey:kImage]];
                        [(UIImageView *)[views objectAtIndex:2] setTag:90000];
                        [(UIImageView *)[views objectAtIndex:2] setHidden:NO];
                        [(UIImageView *)[views objectAtIndex:1] setHidden:NO];
                    }
                }
            }
        }
    }

}

- (void)getPlacesWithDetail:(NSDictionary *)detail
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    //[self.referDetail setValue:[[[detail valueForKey:@"location"] valueForKey:@"formattedAddress"] componentsJoinedByString:@","] forKey:kAddress];
    [self.referDetail setValue:[[detail valueForKey:@"location"] valueForKey:@"lat"] forKey:kLatitude];
    [self.referDetail setValue:[[detail valueForKey:@"location"] valueForKey:@"lng"] forKey:kLongitude];
    [self.referDetail setValue:[detail valueForKey:@"id"] forKey:@"entityId"];
    [self.referDetail setValue:[[detail valueForKey:@"contact"] valueForKey:@"phone"] forKey:kPhone];
    [self.referDetail setValue:[detail valueForKey:@"url"] forKey:kWebSite];
    if ([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
        [self.referDetail setValue:[detail valueForKey:@"name"] forKey:kFromWhere];
    else
        [self.referDetail setValue:[detail valueForKey:@"name"] forKey:kName];
    if ([[detail objectForKey:@"location"] isKindOfClass:[NSDictionary class]])
    {
        NSString  *localCoordinates=[NSString stringWithFormat:@"%f,%f",[[self.referDetail valueForKey:kLatitude] floatValue],[[self.referDetail valueForKey:kLongitude] floatValue]];
        
        [[LocationManager shareLocationManager] getAddressFromLocationString:localCoordinates :^(NSMutableDictionary * dictionary){
            
             [self.referDetail setValue:[dictionary valueForKey:@"address"] forKey:kLocation];
            [self.referDetail setValue:[dictionary valueForKey:@"countryName"] forKey:@"countryName"];
          //  [self.referDetail setValue:[dictionary valueForKey:@"cityName"] forKey:kCity];
            [self updateQueryWithText:[self.referDetail valueForKey:kLocation] queryType:ReferAddress];
        }];
        
    }
    //Update UI
    [self updateQueryWithText:[self.referDetail valueForKey:([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])?kFromWhere:kName] queryType:([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])?ReferFromWhere:ReferName];
    [self updateQueryWithText:[NSString stringWithFormat:@"%@!%@",([self.referDetail valueForKey:kPhone] != nil && [[self.referDetail valueForKey:kPhone] length] > 0)?[self.referDetail valueForKey:kPhone]:@"",([self.referDetail valueForKey:kWebSite] != nil && [[self.referDetail valueForKey:kWebSite] length] > 0)?[self.referDetail valueForKey:kWebSite]:@""] queryType:ReferPhoneAndWebSite];
}

- (void)getPersonContact:(NSDictionary *)contact
{
    //name
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    NSString *name = [NSString stringWithFormat:@"%@ %@",([[contact objectForKey:@"Firstname"] length]>0)?[contact objectForKey:@"Firstname"]:@"",([[contact objectForKey:@"Lastname"] length]>0)?[contact objectForKey:@"Lastname"]:@""];
    [self.referDetail setValue:name forKey:kName];
    [self.referDetail setValue:([[contact objectForKey:@"Phonenumbers"] count] > 0)?[self getPersonPhoneNumberFromContact:[[contact objectForKey:@"Phonenumbers"] objectAtIndex:0]]:@"" forKey:kPhone];
    [self.referDetail setValue:[contact valueForKey:@"Email"] forKey:@"email"];
    //[[contact objectForKey:@"Phonenumbers"] objectAtIndex:0]
//    [self.referDetail setValue:([[contact objectForKey:@"Phonenumbers"] count] > 0)?[self getPersonPhoneNumberFromContact:[[contact objectForKey:@"Phonenumbers"] objectAtIndex:0]]:[contact valueForKey:@"Email"] forKey:@"entityId"];
    [self updateQueryWithText:[self.referDetail valueForKey:kName] queryType:ReferName];
    [self updateQueryWithText:[NSString stringWithFormat:@"%@!%@",([self.referDetail valueForKey:kPhone] != nil && [[self.referDetail valueForKey:kPhone] length] > 0)?[self.referDetail valueForKey:kPhone]:@"",([self.referDetail valueForKey:@"email"]!= nil && [[self.referDetail valueForKey:@"email"] length] > 0)?[self.referDetail valueForKey:@"email"]:@""] queryType:ReferPhoneAndWebSite];
    
    isnameFieldBlank = @"NO";
    
}

- (NSString *)getPersonPhoneNumberFromContact:(NSString *)contactNumber
{
    NSString *phoneNumber =  [[Helper shareHelper] getExactPhoneNumberWithNumber:contactNumber];
    return phoneNumber;
}
- (void)pushToReferScreen:(NSArray *)array
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width;
    UIView *popupView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    popupView.tag = kPopupViewTag;
    popupView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:popupView];
    if([[array valueForKey:@"type"] isEqualToString:@"image"])
    {
        UIImageView *popupImage = [[UIImageView alloc]initWithFrame:CGRectMake(width/2, height/2, 0.0, 0.0)];
        popupImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        [UIView animateWithDuration:0.7
                         animations:^{
                             popupImage.frame = CGRectMake(xPos, yPos, width, height);
                         } completion:^(BOOL finished) {
                         }];
        popupImage.image = [array valueForKey:@"image"];
        [popupView addSubview:popupImage];
    }
    else
    {
//        player = [[MPMoviePlayerController alloc] initWithContentURL:[array valueForKey:@"url"]];
//        player.view.frame = CGRectMake(xPos, yPos, width, height);
//        [player prepareToPlay];
//        player.controlStyle = MPMovieControlStyleDefault;
//        player.shouldAutoplay = NO;
//        [popupView addSubview:player.view];
//        [player play];
    }
}
- (void)hideNavigation:(NSNotification *)notification
{
    if ([[[notification object] objectForKey:@"navigationbar"] isEqualToString:@"no"])
    {
        [self hideShowNavigationRightButtonWithBool:NO];
        
    }else
    {
        [self hideShowNavigationRightButtonWithBool:YES];
        
    }
}

- (void)hideShowNavigationRightButtonWithBool:(BOOL)isHide
{
    if (isHide)
    {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
    }else
    {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)getCurrentAddressDetail:(NSDictionary *)currentAddress

{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLocation" object:nil userInfo:currentAddress];
}

- (void)twitterShare:(NSArray *)array referChannel:(NSDictionary *)referChannel
{
    NSString * msg = [self shareTwitterTextWithReferChannel:referChannel];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:NSLocalizedString(msg, @"")];
//        [tweetSheet setInitialText:@"https://itunes.apple.com/us/app/yorefer/id1163510190?mt=8"];
       // [tweetSheet addImage:[UIImage imageNamed:@"icon_twitter_yorefer.png"]];
        if ([[referChannel objectForKey:@"referimage"] isKindOfClass:[UIImage class]])
        {
            [tweetSheet addImage:[referChannel objectForKey:@"referimage"]];;
            
        }else
        {
            /*
            __block NSData *imageData;
            dispatch_queue_t backgroundQueue  = dispatch_queue_create("com.razeware.imagegrabber.bgqueue", NULL);
            // Dispatch a background thread for download
            dispatch_async(backgroundQueue, ^(void) {
                imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[referChannel objectForKey:@"referimage"]]];
                UIImage *imageLoad;
                imageLoad = [[UIImage alloc] initWithData:imageData];
                // Update UI on main thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    [tweetSheet addImage:imageLoad];
                    
                });
            });
            */
            
            NSData *imageData;
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[referChannel objectForKey:@"referimage"]]];
            UIImage *imageLoad;
            imageLoad = [[UIImage alloc] initWithData:imageData];
            [tweetSheet addImage:imageLoad];
            
        }
        [self presentViewController:tweetSheet animated:YES completion:nil];
        self.contacts = [[NSMutableArray alloc]init];
        self.channelType = @"twitter";
        if (![BaseViewController isNetworkAvailable])
        {
            [self localReferWithDetails:(NSMutableDictionary *)self.referDetail];
            
        }else
        {
            self.contacts = [[NSMutableArray alloc]init];
            self.channelType = @"twitter";
            NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@",[[Helper shareHelper] currentTimeWithMilliSecound],[[UserManager shareUserManager] number]],@"identifier",@"twitter Users",@"name", nil];
            [self.contacts addObject:dictionary];
            [self showHUDWithMessage:@""];
            if ([self.referDetail objectForKey:kReferimage] != nil && [[self.referDetail objectForKey:kReferimage]isKindOfClass:[UIImage class]])
            {
                [self postImageWithImge];
                
            }else
            {
                [self getReferCode];
                
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device have an Twitter account" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Facebook posting

 - (FBSDKShareDialog *)getShareDialogWithContentURL:(NSURL *)objectURL
{
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.shareContent = [self getShareLinkContentWithContentURL:objectURL];
    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"fbauth2://app"]]){
        shareDialog.mode = FBSDKShareDialogModeNative;
    }else{
        shareDialog.mode = FBSDKShareDialogModeFeedWeb;
    }
    
    shareDialog.mode = FBSDKShareDialogModeFeedWeb;
    
    return shareDialog;

}

 - (FBSDKShareLinkContent *)getShareLinkContentWithContentURL:(NSURL *)objectURL
 {
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     content.imageURL = objectURL;
//     content.contentDescription = _msg;
     content.quote = _msg;
     content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/yorefer/id1163510190?mt=8"];
     return content;
 }


 #pragma mark - FBSDKSharingDelegate

 - (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
 {
     NSLog(@"completed share:%@", results);
     
     if ([results valueForKey:@"postId"]) {
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] message:@"Sharing successfully !!!" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
         [alert show];
     }

//     [self getReferCode];
 }
 
 - (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
     NSLog(@"sharing error:%@", error);
     NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
     @"There was a problem sharing, please try again later.";
     NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
     
     [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}
 
 - (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"share cancelled");
}


- (void)facebookShare:(NSArray *)array referChannel:(NSDictionary *)referChannel
{
    _msg = [self shareTextWithReferChannel:referChannel];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share" message:@"Please do long press and PASTE for a preset message." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _msg;
        */
        self.contacts = [[NSMutableArray alloc]init];
        self.channelType = @"facebook";
        if (![BaseViewController isNetworkAvailable])
        {
            [self localReferWithDetails:(NSMutableDictionary *)self.referDetail];
            
        }else
        {
            self.contacts = [[NSMutableArray alloc]init];
            self.channelType = @"facebook";
            NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@",[[Helper shareHelper] currentTimeWithMilliSecound],[[UserManager shareUserManager] emailId]],@"identifier",@"facebook Users",@"name", nil];
            [self.contacts addObject:dictionary];
            [self showHUDWithMessage:@""];
            if ([self.referDetail objectForKey:kReferimage] != nil && [[self.referDetail objectForKey:kReferimage]isKindOfClass:[UIImage class]])
            {
                [self postImageWithImge];
            }
            else if ([[referChannel objectForKey:@"referimage"] isKindOfClass:[NSString class]] && [[referChannel objectForKey:@"referimage"] length] > 0)
            {
                FBSDKShareDialog *shareDialog = [self getShareDialogWithContentURL:[NSURL URLWithString:[referChannel objectForKey:@"referimage"]]];
                shareDialog.delegate = self;
                [shareDialog show];
                
                [self getReferCode];
                
            }
            else{
                
                FBSDKShareDialog *shareDialog = [self getShareDialogWithContentURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/yorefer/id1163510190?mt=8"]];
                shareDialog.delegate = self;
                [shareDialog show];
                
                [self getReferCode];
                
            }

        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't share right now, make sure your device have an Facebook account setup" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)webLink
{
    WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[self.referDetail valueForKey:@"website"]] title:@"Web" refer:NO categoryType:@""];
    [self.navigationController pushViewController:vctr animated:YES];
}

#pragma mark - nIDropDown delegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}
-(void)rel
{
    self.nIDropDown = nil;
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (alertView.tag == kReferLocationTag)
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

#pragma mark - Update View
- (void)updateQueryWithText:(NSString *)text queryType:(ReferNowType)referType
{
    NSArray *tableSubViews = [[[self.tableView subviews] objectAtIndex:0] subviews];
    if ([tableSubViews count] > 0)
    {
        for (ReferNowTableViewCell  * cell in tableSubViews)
        {
            NSArray *cellSubViews = [cell subviews];
            if ([cellSubViews count] > 0)
            {
                NSArray *subView = [[cellSubViews objectAtIndex:0] subviews];
                if ([subView count] > 0)
                {
                    UIView *view = [subView objectAtIndex:0];
                    if (view.tag == referType)
                    {
                        [self updateSuperViewWithQueryType:referType view:view text:text];
                    }
                }
            }
        }
    }
}

- (void)updateSuperViewWithQueryType:(ReferNowType)queryType  view:(UIView *)view text:(NSString *)text
{
    NSArray *views = [view subviews];
    NSArray *phoneWebsite;
    switch (queryType) {
        case ReferLocations:
            if ([views count] > 2)
            {
                [(UITextField *)[views objectAtIndex:0]setText:text];
                [(UIButton *)[views objectAtIndex:3] setTag:kReferLocationButtonEnableTag];
                if ([[UserManager shareUserManager] getLocationService])
                {
                    [(UIButton *)[views objectAtIndex:1] setHidden:YES];
                    [(UITextField *)[views objectAtIndex:0]setText:([text length] > 0)?text:[[UserManager shareUserManager] currentCity]];
                    if ([text length] <= 0)
                    {
                        [self.referDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] latitude]] forKey:kLatitude];
                        [self.referDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] longitude]] forKey:kLongitude];
                        [self.referDetail setValue:[[UserManager shareUserManager] currentAddress] forKey:kAddress];
                    }
                }else
                {
                    [(UIButton *)[views objectAtIndex:1] setHidden:NO];
                    [(UITextField *)[views objectAtIndex:0] setText:@""];
                }
            }
            break;
        case ReferCategories:
            [(UITextField *)[views objectAtIndex:0]setText:text];
            break;
        case ReferAddress:
            if ([[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"product"] || [[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"service"])
            {
                [(UITextView *)[views objectAtIndex:0] setText:@"Enter Address (Optional)"];
                [(UIImageView *)[views objectAtIndex:1] setAlpha:0.4];
                [(UIImageView *)[views objectAtIndex:1] setUserInteractionEnabled:NO];
            }else
            {
                [(UITextView *)[views objectAtIndex:0] setText:@"Enter Address"];
                [(UIImageView *)[views objectAtIndex:1] setAlpha:1.0];
                [(UIImageView *)[views objectAtIndex:1] setUserInteractionEnabled:YES];
            }
            if (text != nil && [text length] > 0)
            {
                [(UITextView *)[views objectAtIndex:0]setText:text];
                [(UITextView *)[views objectAtIndex:0]setTextColor:[UIColor blackColor]];
            }
            break;
        case ReferPhoneAndWebSite:
            phoneWebsite = [text componentsSeparatedByString:@"!"];
            [(UITextField *)[[[views objectAtIndex:0] subviews] objectAtIndex:0]setText:([phoneWebsite objectAtIndex:0] != nil && [[phoneWebsite objectAtIndex:0] length] > 0)?[phoneWebsite objectAtIndex:0]:@""];
            if ([phoneWebsite count] > 1)
            {
//              [(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setText:([phoneWebsite objectAtIndex:1] != nil && [[phoneWebsite objectAtIndex:1] length] > 0)?[phoneWebsite objectAtIndex:1]:@""];
                
                [(UITextField *)[[[views objectAtIndex:2] subviews] objectAtIndex:0]setText:([phoneWebsite objectAtIndex:1] != nil && [[phoneWebsite objectAtIndex:1] length] > 0)?[phoneWebsite objectAtIndex:1]:@""];
            }
            if ([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"service"])
            {
                //[(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setPlaceholder:@"Email (Optional)"];
                
//                [(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Email (Optional)" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]}]];
                
                [(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Website (Optional)" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]}]];

                
            }else
            {
//                [(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Website (Optional)" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]}]];
                
                [(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Email ID (Optional)" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]}]];

                
                 //[(UITextField *)[[[views objectAtIndex:1] subviews] objectAtIndex:0]setPlaceholder:@"Website (Optional)"];
            }
            break;
        case ReferName:
            if ([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"service"])
            {
                [(UITextView *)[views objectAtIndex:0]setText:text];
                [(UIButton *)[views objectAtIndex:1] setHidden:NO];
                
            }else
            {
                [(UITextView *)[views objectAtIndex:0]setText:text];
                [(UIButton *)[views objectAtIndex:1] setHidden:YES];
            }
            break;
        case ReferFromWhere:
            if ([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
            {
                [view setHidden:NO];
                [(UITextView *)[views objectAtIndex:0]setText:text];
            }
            else
                [view setHidden:YES];
            break;
        default:
            break;
    }
}

#pragma mark - TextField delegate
- (void)TextFieldWithAnimation:(BOOL)animation textField:(UITextField *)textField
{
    
   [self.dropDownView removeFromSuperview];
    self.nIDropDown = nil;
    CGRect frame = [[textField superview].superview convertRect:[textField superview].frame toView:self.tableView];
    CGFloat padding = ([textField superview].tag == ReferLocations)?6.0:([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])?10.0:-2.0;
    [self.referDetail setValue:[NSString stringWithFormat:@"%f",(frame.origin.y - padding)] forKey:kYPostion];

    if (animation)
    {
        CGRect textFieldRect =
        [self.view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect =
        [self.view.window convertRect:self.view.bounds fromView:self.view];
        
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator =
        midline - viewRect.origin.y
        - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator =
        (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
        * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        
        UIInterfaceOrientation orientation =    [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            self.shiftForKeyboard = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
            //+ 40.0;
        }
        else
        {
            self.shiftForKeyboard = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
            //+ 40.0;
        }
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= self.shiftForKeyboard;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
        for (id navigBar in [self.view subviews])
        {
            if ([navigBar isKindOfClass:[UINavigationBar class]])
            {
                [self.view bringSubviewToFront:navigBar];
            }
        }
        
        
        
    }else
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += self.shiftForKeyboard;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
    }

//    [self.dropDownView removeFromSuperview];
//    self.nIDropDown = nil;
//    CGRect frame = [[textField superview].superview convertRect:[textField superview].frame toView:self.tableView];
//    CGFloat padding = ([textField superview].tag == ReferLocations)?6.0:([[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])?10.0:-2.0;
//    [self.referDetail setValue:[NSString stringWithFormat:@"%f",(frame.origin.y - padding)] forKey:kYPostion];
    //[[KeyboardHelper sharedKeyboardHelper] animateTextField:textField isUp:animation View:self.tableView postions:frame.origin.y];
}

- (void)clearTextWithTextFiled:(UITextField *)textField
{
    if (textField.tag == ReferName && ![[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
    {
        [self.referDetail setValue:@"" forKey:kName];
        
    }else if (textField.tag == ReferFromWhere && [[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
    {
        [self.referDetail setValue:@"" forKey:kFromWhere];
    }
}

- (void)textFieldshouldChangeCharactersWithTextField:(UITextField *)textField string:(NSString *)string
{
    if (textField.tag == Phone)
    {
        [self.referDetail setValue:textField.text forKey:kPhone];
    }else if (textField.tag == Website)
    {
        [self.referDetail setValue:textField.text forKey:kWebSite];
    }
    else if (textField.tag == ReferEmailID)
    {
//        [self.referDetail setValue:textField.text forKey:kEmail];
        [self.referDetail setValue:[textField.text stringByAppendingString:string] forKey:kEmail];
    }
    else
    {
        if ([[self.referDetail valueForKey:kCategorytype] isEqualToString:kWeb])
        {
            
        }else if( [textField superview].tag == ReferLocations)
        {
            if ([[self.referDetail objectForKey:@"searchtext"] length] > 0 && [[self.referDetail objectForKey:@"searchtext"] length] - 2 == [textField.text length] && [string length] <= 0 )
            {
                textField.text = @"";
                [self.dropDownView removeFromSuperview];
                self.nIDropDown = nil;
                return;
            }
            if ([textField.text length] > 3)
            {
                [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails)
                 {
                     if ([locationDetails count] > 0)
                     {
                         self.nIDropDown = nil;
                         [self.dropDownView removeFromSuperview];
                         NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
                         NSArray  *array = [locationDetails sortedArrayUsingDescriptors:@[sort]];
                         [self nIDropDownWithDetails:array view:textField.superview isLocation:YES];
                     }
                 }];
            }else
            {
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
            }
            
        }else if ([textField superview].tag == ReferName && ![[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
        {
            if ([textField.text length] > 3)
            {
                [self placeSearchWithText:textField.text :^(NSDictionary *dictionary)
                 {
                     self.nIDropDown = nil;
                     [self.dropDownView removeFromSuperview];
                     [self nIDropDownWithDetails:[dictionary valueForKey:@"venues"] view:[textField superview] isLocation:YES];
                 }];
                
            }
        }else if ([textField superview].tag == ReferFromWhere && [[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
        {
            {
                if ([textField.text length] > 3)
                {
                    
                    [self placeSearchWithText:textField.text :^(NSDictionary *dictionary)
                     {
                         self.nIDropDown = nil;
                         [self.dropDownView removeFromSuperview];
                        [self nIDropDownWithDetails:[dictionary valueForKey:@"venues"] view:[textField superview] isLocation:YES];
                     }];
                    

                }
            }
            
        }else if ([textField superview].tag == ReferName)
        {
            [self.referDetail setValue:[textField.text stringByAppendingString:string] forKey:kName];
        }
 
        /*
        if ([textField superview].tag == ReferName && textField.text.length > 0) {
            isnameFieldBlank = @"NO";
        }
        else{
            isnameFieldBlank = @"YES";
        }
        */
    }

}

- (void)placeSearchWithTextField:(UITextField *)textField
{
    if ([[self.referDetail valueForKey:kCategorytype] isEqualToString:kWeb])
        return;
    if ([textField superview].tag == ReferName && ![[self.referDetail valueForKey:kCategorytype] isEqualToString:kProduct])
    {
        if ([textField.text length] > 0)
        {
            self.nIDropDown = nil;
            [self.dropDownView removeFromSuperview];
            [self placeSearchWithText:textField.text :^(NSDictionary *dictionary)
             {
                 [self nIDropDownWithDetails:[dictionary valueForKey:@"venues"] view:[textField superview] isLocation:YES];
             }];
            
        }
    }else if ([textField superview].tag == ReferFromWhere && [[self.referDetail valueForKey:kCategorytype] isEqualToString:@"product"])
    {
        if ([textField.text length] > 0)
        {
            self.nIDropDown = nil;
            [self.dropDownView removeFromSuperview];
            [self placeSearchWithText:textField.text :^(NSDictionary *dictionary)
             {
                 [self nIDropDownWithDetails:[dictionary valueForKey:@"venues"] view:[textField superview] isLocation:YES];
             }];
            
        }
    }else if ([textField superview].tag == ReferLocations && [[textField text] length] > 3)
    {
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails)
         {
             if ([locationDetails count] > 0)
             {
                 self.nIDropDown = nil;
                 [self.dropDownView removeFromSuperview];
                 NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
                 NSArray  *array = [locationDetails sortedArrayUsingDescriptors:@[sort]];
                 [self nIDropDownWithDetails:array view:textField.superview isLocation:YES];
             }
         }];
    }
}

- (void)phoneWesiteWithText:(NSString *)text referRtype:(ReferNowType)referType
{
    if (referType == Phone)
        [self.referDetail setValue:text forKey:kPhone];
    else if (referType == Website)
        [self.referDetail setValue:text forKey:kWebSite];
    else if (referType == ReferName)
        [self.referDetail setValue:text forKey:kName];
    else if (referType == ReferFromWhere)
        [self.referDetail setValue:text forKey:kFromWhere];
}
#pragma mark - TextView Delegate
- (void)TextViewdWithAnimation:(BOOL)animation textView:(UITextView *)textView
{
    [self.dropDownView removeFromSuperview];
    self.nIDropDown = nil;
    CGRect frame = [[textView superview].superview convertRect:[textView superview].frame toView:self.tableView];
    [self.referDetail setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    [[KeyboardHelper sharedKeyboardHelper] animateTextView:textView isUp:animation View:self.tableView postions:frame.origin.y];
}

- (void)textWithMessageLocation:(NSString *)messageLocation referType:(ReferNowType)referType
{
    if (referType == ReferMessage)
        [self.referDetail setValue:messageLocation forKey:kMessage];
    else if (referType == ReferAddress)
        [self.referDetail setValue:messageLocation forKey:kLocation];
    else if (referType == ReferPhoneAndWebSite)
        [self.referDetail setValue:messageLocation forKey:kWebSite];
}

#pragma mark - PlaceSearch
- (void)placeSearchWithText:(NSString *)text :(PlaceSearchHandler)placeSearch
{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
    [param setValue:text forKey:@"searchText"];
    [param setValue:[NSString stringWithFormat:@"%@,%@",[self.referDetail objectForKey:kLatitude],[self.referDetail objectForKey:kLongitude]] forKey:@"coordinates"];
    [param setValue:@"20" forKey:@"limit"];
    [param setValue:@"20000" forKey:@"radius"];
    [param setValue:([[self.referDetail valueForKey:kCategoryid] length] >0)?[self.referDetail valueForKey:kCategoryid]:@"" forKey:@"categoryId"];
    NSString *placeURL=[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%@&client_id=RCRIPGJKOV2GTNC00UQOVAPYEUET1PJMRUG2PYWVAMCZPQKU&client_secret=C5JUFJUS32SYSQTU0NYUBGOZF44NJ4AYKMFM0TVUOSIE4K4I&v=20140806&limit=%@&radius=%@&categoryId=%@",[param valueForKey:@"searchText"],[param valueForKey:@"coordinates"],[param valueForKey:@"limit"],[param valueForKey:@"radius"],[param valueForKey:@"categoryId"]];
    NSURL *url = [NSURL URLWithString:[placeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue",NULL);
    dispatch_async(imageQueue, ^{
        NSData *getData = [NSData dataWithContentsOfURL:url];
        NSString *strResponse;
        strResponse=[[NSString alloc]initWithData:getData encoding:NSStringEncodingConversionAllowLossy];
        if (!strResponse) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strResponse dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                if ([[[jsonObject valueForKey:@"response"] valueForKey:@"venues"] count])
                {
                    placeSearch([jsonObject valueForKey:@"response"]);
                    
                }else
                {
                }
            }
        });
        
    });

}

#pragma mark - Buton delegate
- (void)locationUpdate:(NSNotification *)notification
{
    if ([[UserManager shareUserManager] getLocationService])
    {
        if ([[[notification valueForKey:@"userInfo"] valueForKey:@"locationUpdated"] boolValue])
        {
            [self updateQueryWithText:[[UserManager shareUserManager] currentCity] queryType:ReferLocations];
            [self.referDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] latitude]] forKey:kLatitude];
            [self.referDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] longitude]] forKey:kLongitude];
            
        }else
        {
            [self currentLocation];
        }
    }else
    {
        [self updateQueryWithText:[[UserManager shareUserManager] currentCity] queryType:ReferLocations];
        [self.referDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] latitude]] forKey:kLatitude];
        [self.referDetail setValue:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] longitude]] forKey:kLongitude];
    }
    [self hideHUD];
    
}


- (void)serviceNameWithButton:(UIButton *)button
{
    if (self.nIDropDown == nil)
    {
        CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.tableView];
        CGFloat padding = -2.0;
        [self.referDetail setValue:[NSString stringWithFormat:@"%f",(frame.origin.y - padding)] forKey:kYPostion];
        NSMutableArray *getAllContacts = [[Helper shareHelper] getAllContacts];
        [self nIDropDownWithDetails:getAllContacts view:[button superview] isLocation:NO];
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    
}

- (IBAction)shareButtonTapped:(id)sender
{
    /*
    if ([self.referDetail objectForKey:@"name"]) {
        if ([[self.referDetail valueForKey:@"name"] length]>0) {
            isnameFieldBlank = @"NO";
        }
    }
    */
    
        if (_referOptionCount == 1) {
            
            if ([[YoReferSocialChannels shareYoReferSocial] getSmsSahring])
            {
                [self.tableView endEditing:YES];
                NSArray *error = nil;
                BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
                if (!isValidate)
                {
                    NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                    alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                    return;
                }else
                {
                    [self message:nil];
                }
                
            }
            
            if ([[YoReferSocialChannels shareYoReferSocial] getTwitterSahring])
            {
                [self.tableView endEditing:YES];
                NSArray *error = nil;
                BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
                if (!isValidate)
                {
                    NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                    alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                    return;
                }else
                {
                    [self twitter:nil];
                }
                
            }
            
            
            if ([[YoReferSocialChannels shareYoReferSocial] getWhatsappSahring])
            {
                [self.tableView endEditing:YES];
                NSArray *error = nil;
                BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
                if (!isValidate)
                {
                    NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                    alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                    return;
                }else
                {
                    [self whatsapp:nil];
                }
                
            }
            
            if ([[YoReferSocialChannels shareYoReferSocial] getEmailSahring])
            {
                [self.tableView endEditing:YES];
                NSArray *error = nil;
                BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
                if (!isValidate)
                {
                    NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                    alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                    return;
                }else
                {
                    [self email:nil];
                }
                
            }
            
            if ([[YoReferSocialChannels shareYoReferSocial] getFaceBookSahring])
            {
                [self.tableView endEditing:YES];
                NSArray *error = nil;
                BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
                if (!isValidate)
                {
                    NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                    alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                    return;
                }else
                {
                    [self facebook:nil];
                }
                
            }
        }
        else
        {
            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }else
            {
                /*
                if ([[self.referDetail valueForKey:kIsAsk] boolValue])
                {
                    [self message:nil];
                    
                }else
                {
                    CGRect frame = [(UIScrollView *)[self.view viewWithTag:kReferScrollViewTag] frame];
                    frame.origin.x = frame.size.width * 1;
                    frame.origin.y = 0;
                    [(UIScrollView *)[self.view viewWithTag:kReferScrollViewTag] scrollRectToVisible:frame animated:YES];
                }
                */
                
                CGRect frame = [(UIScrollView *)[self.view viewWithTag:kReferScrollViewTag] frame];
                frame.origin.x = frame.size.width * 1;
                frame.origin.y = 0;
                [(UIScrollView *)[self.view viewWithTag:kReferScrollViewTag] scrollRectToVisible:frame animated:YES];
            }
        }
}

#pragma mark - Scrollview Delegare
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     if ([[self.referDetail valueForKey:kNewRefer] boolValue] && ![[self.referDetail valueForKey:kWeb] boolValue])
         [self updateQueryWithText:[self.referDetail valueForKey:@"searchtext"] queryType:ReferLocations];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self.tableView endEditing:YES];
}

#pragma mark - GestureRecognizer
- (void)message:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"place"]) {
        if ([[self.referDetail valueForKey:@"location"] isEqualToString:@""] || [[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else
        {
            if ([[YoReferSocialChannels shareYoReferSocial] getSmsSahring])
            {
                [self.referDetail setValue:@"Message" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
            }
            
            else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  SMS as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }
        }
    }
    else{
        
        if ([[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else{
            
            if ([[YoReferSocialChannels shareYoReferSocial] getSmsSahring])
            {
                [self.referDetail setValue:@"Message" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
            }
            else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  SMS as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }

        
        }
    }
}

- (void)email:(UITapGestureRecognizer *)gestureRecognizer
{

    if ([[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"place"]) {
        if ([[self.referDetail valueForKey:@"location"] isEqualToString:@""] || [[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else
        {
            if ([[YoReferSocialChannels shareYoReferSocial] getEmailSahring])
            {
                [self.referDetail setValue:@"Email" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Email as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }
            
        }
    }
    else{
        
        if ([[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else{
        
            if ([[YoReferSocialChannels shareYoReferSocial] getEmailSahring])
            {
                [self.referDetail setValue:@"Email" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Email as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }

        }

    }

}

- (void)whatsapp:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"place"]) {
        if ([[self.referDetail valueForKey:@"location"] isEqualToString:@""] || [[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else
        {
            if ([[YoReferSocialChannels shareYoReferSocial] getWhatsappSahring])
            {
                [self.referDetail setValue:@"WhatsApp" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Whatsapp as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }
            
        }
    }
    else{
        
        if ([[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else{
        
            if ([[YoReferSocialChannels shareYoReferSocial] getWhatsappSahring])
            {
                [self.referDetail setValue:@"WhatsApp" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Whatsapp as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }

        }

    }

}

- (void)facebook:(UITapGestureRecognizer *)gestureRecognizer
{

    if ([[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"place"]) {
        if ([[self.referDetail valueForKey:@"location"] isEqualToString:@""] || [[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else
        {
            if ([[YoReferSocialChannels shareYoReferSocial] getFaceBookSahring])
            {
                [self.referDetail setValue:@"FaceBook" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Facebook as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }
            
        }
    }
    else{
        
        if ([[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else{
        
            if ([[YoReferSocialChannels shareYoReferSocial] getFaceBookSahring])
            {
                [self.referDetail setValue:@"FaceBook" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Facebook as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }

        }
    }

}

- (void)twitter:(UITapGestureRecognizer *)gestureRecognizer
{

    if ([[self.referDetail valueForKey:@"categorytype"] isEqualToString:@"place"]) {
        if ([[self.referDetail valueForKey:@"location"] isEqualToString:@""] || [[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else
        {
            if ([[YoReferSocialChannels shareYoReferSocial] getTwitterSahring   ])
            {
                [self.referDetail setValue:@"Twitter" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Twitter as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }
            
        }
    }
    else{
        
        
        if ([[self.referDetail valueForKey:@"name"] isEqualToString:@""]) {
            
            //            [self.tableView endEditing:YES];
            NSArray *error = nil;
            BOOL isValidate = [[Helper shareHelper] validateReferChannelEnteriesWithError:&error params:self.referDetail];
            if (!isValidate)
            {
                NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
                alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
                return;
            }
        }
        else{
        
            if ([[YoReferSocialChannels shareYoReferSocial] getTwitterSahring   ])
            {
                [self.referDetail setValue:@"Twitter" forKey:@"referchannel"];
                [self getReferChannel:self.referDetail];
                
            }else
            {
                alertView([[Configuration shareConfiguration] appName], @"Enable  Twitter as a refer channel in settings", nil, @"Ok", nil, 0);
                return;
            }

        }

    }

}

#pragma mark - LocationRefer
- (void)LocationReferWithDetail:(NSMutableDictionary *)details
{
    self.referDetail = details;
    [self.tableView reloadData];
}

#pragma mark - Local refer
- (void)localReferWithDetails:(NSMutableDictionary *)details
{
    [details removeObjectForKey:@"category"];
    [details setValue:self.channelType forKey:@"channeltype"];
    [details setValue:self.contacts forKey:@"to"];
    NSMutableArray *referDetails = [[NSMutableArray alloc]init];
    [referDetails addObject:details];
    NSArray *array = [[CoreData shareData] getLocalReferWithLoginId:[[UserManager shareUserManager] number]];
    if ([array count] > 0)
    {
        [referDetails addObjectsFromArray:array];
    }
    [[CoreData shareData] localReferWithLoginId:[[UserManager shareUserManager] number] response:referDetails];
    [[UIManager sharedManager] goToHomePageWithAnimated:YES];
}

- (void)getCategoryTypeWithCategories:(Categories)categories
{
    switch (categories) {
        case ReferPlaces:
            self.isProduct = NO;
            break;
        case ReferProduct:
            self.isProduct = YES;
            break;
        case ReferServices:
            self.isProduct = NO;
            break;
        default:
            break;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    NSArray *array = [[NSArray alloc]initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Message
- (void)messageWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel
{
    self.contacts = [[NSMutableArray alloc]init];
    self.contacts = [self getReferContact:array channel:1];
    self.channelType = @"phone";
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        [messageController setMessageComposeDelegate:self];
        [messageController setRecipients:[self getPhoneNumberFromContact:array]];
        [messageController setBody:[self shareTextWithReferChannel:referChannel]];
        [self presentViewController:messageController animated:NO completion:nil];
        
    }
}

- (NSMutableArray *)getPhoneNumberFromContact:(NSArray *)contact
{
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dictionary in contact)
    {
        NSString *phoneNumber =  [[Helper shareHelper] getExactPhoneNumberWithNumber:[dictionary valueForKey:@"referphonnumber"]];
        [phoneNumbers addObject:phoneNumber];
    }
    return phoneNumbers;
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result==MFMailComposeResultCancelled)
    {
        NSLog(@"cancel");
        
    }else
    {
        if (![BaseViewController isNetworkAvailable])
        {
            [self localReferWithDetails:(NSMutableDictionary *)self.referDetail];
            
        }else
        {
            [self showHUDWithMessage:@""];
            if ([self.referDetail objectForKey:kReferimage] != nil && [[self.referDetail objectForKey:kReferimage]isKindOfClass:[UIImage class]])
            {
                [self postImageWithImge];
                
            }else
            {
                [self getReferCode];
            }
 
        }
    }
}

#pragma mark - Mail
- (void)mailWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel
{
    self.contacts = [[NSMutableArray alloc]init];
    self.contacts = [self getReferContact:array channel:2];
    self.channelType = @"email";
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        
        [mailComposer setSubject:@"Reference"];
        [mailComposer setToRecipients:[self getEmailByReferChannle:array]];
        [mailComposer setMessageBody:[self shareTextWithReferChannel:referChannel] isHTML:NO];
        
        if ([referChannel objectForKey:kReferimage]) {
            
            if ([referChannel valueForKey:kReferimage] != nil && [[referChannel valueForKey:kReferimage]isKindOfClass:[UIImage class]])
            {
                UIImage* emailImage = [referChannel valueForKey:kReferimage];
                NSData *jpegData = UIImageJPEGRepresentation(emailImage, 1.0);
                NSString *fileName = @"test";
                fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
                [mailComposer addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:fileName];
            }else
            {
                NSLog(@"%@",[referChannel valueForKey:kReferimage]);
                [self showHUDWithMessage:@"Please Wait!!! Image is attaching"];
                
                NSURL *url = [NSURL URLWithString:[referChannel valueForKey:kReferimage]];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage* emailImage = [[UIImage alloc]initWithData:data];
                
                [self hideHUD];
                
                NSData *jpegData = UIImageJPEGRepresentation(emailImage, 1.0);
                NSString *fileName = @"test";
                fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
                if (jpegData != Nil) {
                    
                    [mailComposer addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:fileName];
                }
                
            }

        }
        
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    }
}
- (NSMutableArray *)getEmailByReferChannle:(NSArray *)array
{
    NSMutableArray *emails = [[NSMutableArray alloc]init];
    for (NSDictionary *dictionary in array)
    {
        [emails addObject:[dictionary objectForKey:@"email"]];
    }
    return emails;
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result==MFMailComposeResultCancelled) {

    }else
    {
        
        if (![BaseViewController isNetworkAvailable])
        {
            
            [self localReferWithDetails:(NSMutableDictionary *)self.referDetail];
            
        }else
        {
            [self showHUDWithMessage:@""];
            
            if ([self.referDetail objectForKey:kReferimage] != nil && [[self.referDetail objectForKey:kReferimage]isKindOfClass:[UIImage class]])
            {
                [self postImageWithImge];
                
            }else
            {
                
                [self getReferCode];
                
            }
        }
    }
}


#pragma mark - Whats up
- (void)wahtsUpWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel
{
    NSString * msg = [self shareTextWithReferChannel:referChannel];
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        if (![BaseViewController isNetworkAvailable])
        {
            [self localReferWithDetails:(NSMutableDictionary *)self.referDetail];
            
        }else
        {
            self.contacts = [[NSMutableArray alloc]init];
            self.channelType = @"whatsapp";
            NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@",[[Helper shareHelper] currentTimeWithMilliSecound],[[UserManager shareUserManager] number]],@"identifier",@"WhatsApp User",kName, nil];
            [self.contacts addObject:dictionary];
            [self showHUDWithMessage:@""];
            if ([self.referDetail objectForKey:kReferimage] != nil && [[self.referDetail objectForKey:kReferimage]isKindOfClass:[UIImage class]])
            {
                [self postImageWithImge];
                
            }else
            {
                [self getReferCode];
                
            }
        }
    }else
    {
        alertView(@"Error", @"WhatsApp not installed.", self, @"Ok", nil, 0);
        return;
    }
}

#pragma mark - Share text
- (NSString *)shareTextWithReferChannel:(NSDictionary *)referChannel
{
    NSMutableString *shareText = [[NSMutableString alloc]init];
    if (self.referMessages != nil &&[self.referMessages isKindOfClass:[NSDictionary class]] && [self.referMessages objectForKey:kPlace])
    {
        if ([[[referChannel valueForKey:kCategorytype] lowercaseString] isEqualToString:kPlace])
        {
            shareText =  [self plcaeMessageWithReferChannel:referChannel];
            
        }else if ([[[referChannel valueForKey:kCategorytype] lowercaseString] isEqualToString:kService])
        {
            shareText = [self serviceMessageWithReferChannel:referChannel];
            
        }else if ([[[referChannel valueForKey:kCategorytype] lowercaseString] isEqualToString:kProduct])
        {
            shareText =  [self productMessageWithReferChannel:referChannel];
            
        }else if ([[referChannel objectForKey:kWeb] boolValue])
        {
            shareText = [self webMessageWithReferChannel:referChannel];
        }

    }else
    {
        [shareText appendString:[NSString stringWithFormat:@"Hi,\n"]];
        if ([[referChannel objectForKey:kWeb] boolValue])
        {
            [shareText appendString:[NSString stringWithFormat:@"%@ referred \'%@\' under category \'%@\' to you.\n",[[[UserManager shareUserManager] name] capitalizedString],[referChannel objectForKey:kName],[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            //message
            if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)
            {
                //[shareText appendString:[NSString stringWithFormat:@"%@ says",[[[UserManager shareUserManager] name] capitalizedString]]];
                [shareText appendString:[NSString stringWithFormat:@" \"%@\".\n\nCheck the weblink below!\n",([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)?[[referChannel objectForKey:kMessage] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]:@""]];
                NSString *str;
                if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"WhatsApp"])
                {
                    NSString *string = [referChannel objectForKey:kWebSite];
                    str = [@"" stringByAppendingFormat:string];
                    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
                    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%and"];
                }else
                {
                    str = [referChannel objectForKey:kWebSite];
                }
                [shareText appendString:[NSString stringWithFormat:@"%@\n\n",str]];
            }else if ([referChannel objectForKey:kWebSite] != nil && [[referChannel objectForKey:kWebSite] length] > 0)
            {
                NSString *str;
                if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"WhatsApp"])
                {
                    NSString *string = [referChannel objectForKey:kWebSite];
                    str = [@"" stringByAppendingFormat:string];
                    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
                    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
                }else
                {
                    str = [referChannel objectForKey:kWebSite];
                }
                [shareText appendString:[NSString stringWithFormat:@"\nCheck the weblink below!\n"]];
                [shareText appendString:[NSString stringWithFormat:@"%@\n\n",str]];
            }
           // [shareText appendString:@"Check it out!\n\n"];
        }else
        {
            if ([[referChannel objectForKey:kCategorytype] isEqualToString:kProduct] && [[referChannel objectForKey:kFromWhere] length] > 0)
            {
                //name
                [shareText appendString:[NSString stringWithFormat:@"%@ referred \'%@\' under category \'%@\' ",[[[UserManager shareUserManager] name] capitalizedString],[referChannel objectForKey:kName],[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
                
                [shareText appendString:[NSString stringWithFormat:@"purchased from %@ to you.\n",[[referChannel objectForKey:kFromWhere] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            }else
            {
                //name
                [shareText appendString:[NSString stringWithFormat:@"%@ referred \'%@\' under category \'%@\' to you.\n",[[[UserManager shareUserManager] name] capitalizedString],[referChannel objectForKey:kName],[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            }
            //message
            if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)
            {
                //[shareText appendString:[NSString stringWithFormat:@"%@ says",[[[UserManager shareUserManager] name] capitalizedString]]];
                [shareText appendString:[NSString stringWithFormat:@" \"%@\".\n\nContact:\n",([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)?[[referChannel objectForKey:kMessage] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]:@""]];
            }else
            {
                [shareText appendString:@"\nContact:\n"];
            }
            if ([[referChannel objectForKey:kCategorytype] isEqualToString:kProduct] && [[referChannel objectForKey:kFromWhere] length] > 0)
            {
                [shareText appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kFromWhere] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            }else
            {
                [shareText appendString:[NSString stringWithFormat:@"%@",[[referChannel objectForKey:kName] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            }
            //locations
            if ([referChannel objectForKey:kLocation] != nil && [[referChannel objectForKey:kLocation] length] >0)
            {
                
                [shareText appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kLocation] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
                
            }
            //Phone and Website
            if ([referChannel objectForKey:kPhone] != nil && [[referChannel objectForKey:kPhone] length] >0 && [referChannel objectForKey:kWebSite] != nil && [[referChannel objectForKey:kWebSite] length] > 0)
            {
                [shareText appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
                [shareText appendString:[NSString stringWithFormat:@"Website : %@\n\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
                
            }else if ([referChannel objectForKey:kPhone] != nil && [[referChannel objectForKey:kPhone] length] >0)
            {
                [shareText appendString:[NSString stringWithFormat:@"Phone : %@\n\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            }else  if ([referChannel objectForKey:kWebSite] != nil && [[referChannel objectForKey:kWebSite] length] >0)
            {
                [shareText appendString:[NSString stringWithFormat:@"Website : %@\n\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
            }else
            {
                [shareText appendString:@"\n"];
                
            }
        }
        [shareText appendString:[NSString stringWithFormat:@"Install Yorefer to discover and refer your favorites to friends and earn rewards. http://iTunes.com"]];
    }
    if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"WhatsApp"])
    {
        NSString *str = [NSString stringWithFormat:@"%@",shareText];
        str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
        shareText = (NSMutableString *)str;
    }

    return shareText;
}
- (NSString *)shareTwitterTextWithReferChannel:(NSDictionary *)referChannel
{
    NSMutableString *shareText = [[NSMutableString alloc]init];
    [shareText appendString:[NSString stringWithFormat:@"#Yoreferapp https://goo.gl/3pbTP2"]];
    [shareText appendString:[NSString stringWithFormat:@"\n Try \'%@\' under \'%@\'",[referChannel objectForKey:kName],[self.referDetail valueForKey:kCategory]]];
    if ([[referChannel valueForKey:kCategorytype] isEqualToString:kProduct] && [[referChannel valueForKey:kFromWhere] isKindOfClass:[NSString class]]> 0)
    {
        if ([[referChannel valueForKey:kFromWhere] length] > 0)
        {
            [shareText appendString:[NSString stringWithFormat:@" from \'%@\'.",[referChannel valueForKey:kFromWhere]]];
        }
    }else
    {
        [shareText appendString:[NSString stringWithFormat:@"."]];
    }
    //phone number and web site
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] >0 && [referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] > 0)
    {
        [shareText appendString:[NSString stringWithFormat:@"\nPh:%@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        [shareText appendString:[NSString stringWithFormat:@"%@",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] >0 && [referChannel objectForKey:kEmail] != nil && [[[referChannel objectForKey:kEmail] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] > 0)
    {
        [shareText appendString:[NSString stringWithFormat:@"\n\n%@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        [shareText appendString:[NSString stringWithFormat:@"%@",[[referChannel objectForKey:kEmail] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] >0)
    {
        [shareText appendString:[NSString stringWithFormat:@"\nPh:%@",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else  if ([referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] >0)
    {
        [shareText appendString:[NSString stringWithFormat:@"\n%@",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        
    }else  if ([referChannel objectForKey:kEmail] != nil && [[[referChannel objectForKey:kEmail] stringByTrimmingCharactersInSet: set] isKindOfClass:[NSString class]] >0)
    {
        [shareText appendString:[NSString stringWithFormat:@"\n%@",[[referChannel objectForKey:kEmail] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        
    }else if ([referChannel valueForKey:kWebSite] != nil && [[referChannel valueForKey:kWebSite] isKindOfClass:[NSString class]])
    {
        [shareText appendString:[NSString stringWithFormat:@"\n%@",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    
    //message
    if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] isKindOfClass:[NSString class]] > 0)
    {
        if ([[referChannel objectForKey:kMessage] length] > 0)
        {
            [shareText appendString:[NSString stringWithFormat:@"\n\"%@\"",([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] isKindOfClass:[NSString class]] > 0)?[referChannel objectForKey:kMessage]:@""]];
        }
        
    }
    NSRange rangeString = {0,MIN([shareText length], 140)};
    rangeString = [shareText rangeOfComposedCharacterSequencesForRange:rangeString];
    NSString *shortString = [shareText substringWithRange:rangeString];
    return shortString;
}

- (NSMutableString *)webMessageWithReferChannel:(NSDictionary *)referChannel
{
    NSMutableString *referMessage = [NSMutableString stringWithString:[self.referMessages valueForKey:kWeb]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferredEntityName" withString:[NSString stringWithFormat:@"\'%@\'",[referChannel objectForKey:kName]]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##Category" withString:[NSString stringWithFormat:@"\'%@\'",[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    //message
    if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)
    {
        //referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
        referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)?[NSString stringWithFormat:@"\"%@\"\n\n",[[referChannel objectForKey:kMessage] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]:@""];
    }else
    {
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:@"\n"];
        
       // referMessage  = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"##RefererName says ##ReferMessage!"] withString:@""];
    }
    if ([referChannel objectForKey:kWebSite] != nil && [[referChannel objectForKey:kWebSite] length] > 0)
    {
        NSString *str;
        if ([[referChannel valueForKey:@"referchannel"] isEqualToString:@"WhatsApp"])
        {
            NSString *string = [referChannel objectForKey:kWebSite];
            str = [@"" stringByAppendingFormat:string];
            str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
            str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
        }else
        {
            str = [referChannel objectForKey:kWebSite];
        }
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##WebLink" withString:str];
    }
    return referMessage;
}

- (NSMutableString *)productMessageWithReferChannel:(NSDictionary *)referChannel
{
    NSMutableString *referMessage = [NSMutableString stringWithString:[self.referMessages valueForKey:kProduct]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferredEntityName" withString:[NSString stringWithFormat:@"\'%@\'",([referChannel objectForKey:kName] != nil && [[referChannel objectForKey:kName] length] > 0)?[referChannel objectForKey:kName]:@""]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##Category" withString:[NSString stringWithFormat:@"\'%@\'",[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    
    if ([[referChannel objectForKey:kCategorytype] isEqualToString:kProduct] && [[referChannel valueForKey:@"fromwhere"] length] > 0)
    {
         referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##EntityLocation" withString:[NSString stringWithFormat:@"\'%@\'",[[referChannel objectForKey:@"fromwhere"] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else
    {
        referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@" purchased from ##EntityLocation" withString:@""];
    }
    //message
    if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)
    {
        //referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
        referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)?[NSString stringWithFormat:@"\"%@\"\n\n",[[referChannel objectForKey:kMessage] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]:@""];
    }else
    {
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:@"\n"];
       // referMessage  = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ says ##ReferMessage",[[[UserManager shareUserManager] name] capitalizedString]] withString:@""];
    }
    
    NSMutableString *address = [[NSMutableString alloc]init];
      if ([[referChannel objectForKey:kCategorytype] isEqualToString:kProduct] && [[referChannel objectForKey:kFromWhere] length] > 0)
      {
           [address appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kFromWhere] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
      }
    //locations
    if ([referChannel objectForKey:kLocation] != nil && [[referChannel objectForKey:kLocation] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kLocation] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    //Phone and Website
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] length] >0 && [referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] length] > 0)
    {
        [address appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        [address appendString:[NSString stringWithFormat:@"Website : %@\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else  if ([referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Website : %@\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    if([address length] > 0)
    {
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##EntityAddress" withString:address];
    }else
    {
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"Contact:" withString:@""];
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##EntityAddress \n\n" withString:@""];
    }
    return referMessage;
}

- (NSMutableString *)serviceMessageWithReferChannel:(NSDictionary *)referChannel
{
    NSMutableString *referMessage = [NSMutableString stringWithString:[self.referMessages valueForKey:kService]];
    [referMessage stringByReplacingOccurrencesOfString:@"test" withString:@"##RefererName"];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferredEntityName" withString:[NSString stringWithFormat:@"\'%@\'",[referChannel objectForKey:kName]]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##Category" withString:[NSString stringWithFormat:@"\'%@\'",[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    //message
    if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)
    {
        //referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
        referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)?[NSString stringWithFormat:@"\"%@\"\n\n",[[referChannel objectForKey:kMessage] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]:@""];
    }else
    {
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:@"\n"];
       // referMessage  = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ says ##ReferMessage",[[[UserManager shareUserManager] name] capitalizedString]] withString:@""];
    }
    
    NSMutableString *address = [[NSMutableString alloc]init];
    [address appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kName] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    //locations
    if ([referChannel objectForKey:kLocation] != nil && [[referChannel objectForKey:kLocation] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kLocation] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    //Phone and Website
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone]stringByTrimmingCharactersInSet: set] length] >0 && [referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] length] > 0)
    {
        [address appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        [address appendString:[NSString stringWithFormat:@"Website : %@\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else if ([referChannel objectForKey:@"phone"] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    
    if ([referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] length] >0)
    {
//        [address appendString:[NSString stringWithFormat:@"\nWebsite : %@\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        
    }
    if ([referChannel objectForKey:kEmail] != nil && [[[referChannel objectForKey:kEmail] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Email : %@\n",[[referChannel objectForKey:kEmail] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        
    }

    referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##EntityAddress" withString:address];
    return referMessage;
}

- (NSMutableString *)plcaeMessageWithReferChannel:(NSDictionary *)referChannel
{
    NSMutableString *referMessage = [NSMutableString stringWithString:[self.referMessages valueForKey:kPlace]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
    referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferredEntityName" withString:[NSString stringWithFormat:@"\'%@\'",([referChannel objectForKey:@"name"] != nil && [[referChannel objectForKey:@"name"] length] > 0)?[referChannel objectForKey:@"name"]:@""]];
     referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##Category" withString:[NSString stringWithFormat:@"\'%@\'",[[self.referDetail valueForKey:kCategory] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    //message
    if ([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)
    {
          //referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##RefererName" withString:[[[UserManager shareUserManager] name] capitalizedString]];
         referMessage  = (NSMutableString *) [referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:([referChannel objectForKey:kMessage] != nil && [[referChannel objectForKey:kMessage] length] > 0)?[NSString stringWithFormat:@"\"%@\"\n\n",[[referChannel objectForKey:kMessage] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]:@""];
    }else
    {
        
        referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##ReferMessage" withString:@"\n"];
//         referMessage  = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ says ##ReferMessage",[[[UserManager shareUserManager] name] capitalizedString]] withString:@""];
    }
   
    NSMutableString *address = [[NSMutableString alloc]init];
    [address appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kName] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    //locations
    if ([referChannel objectForKey:kLocation] != nil && [[referChannel objectForKey:kLocation] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"%@\n",[[referChannel objectForKey:kLocation] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    
    //Phone and Website
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] length] >0 && [referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] length] > 0)
    {
        [address appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
        [address appendString:[NSString stringWithFormat:@"Website : %@\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else if ([referChannel objectForKey:kPhone] != nil && [[[referChannel objectForKey:kPhone] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Phone : %@\n",[[referChannel objectForKey:kPhone] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }else  if ([referChannel objectForKey:kWebSite] != nil && [[[referChannel objectForKey:kWebSite] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Website : %@\n",[[referChannel objectForKey:kWebSite] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
    /*
    if ([referChannel objectForKey:kFromWhere] != nil && [[[referChannel objectForKey:kFromWhere] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Email Id : %@\n",[[referChannel objectForKey:kFromWhere] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }
     */
    
    if ([referChannel objectForKey:kEmail] != nil && [[[referChannel objectForKey:kEmail] stringByTrimmingCharactersInSet: set] length] >0)
    {
        [address appendString:[NSString stringWithFormat:@"Email Id : %@\n",[[referChannel objectForKey:kEmail] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
    }

    referMessage = (NSMutableString *)[referMessage stringByReplacingOccurrencesOfString:@"##EntityAddress" withString:address];
    return referMessage;
}
- (NSMutableArray *)getReferContact:(NSArray *)contacts channel:(NSInteger)channel
{
    NSMutableArray *referContacts = [[NSMutableArray alloc]init];
    if (channel == 1)
    {
        for (NSDictionary *dictionary in contacts)
        {
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[dictionary objectForKey:@"firstname"],kName,[dictionary objectForKey:@"referphonnumber"],@"identifier", nil];
            [referContacts addObject:dic];
            
        }
    }else if (channel == 2)
    {
        for (NSDictionary *dictionary in contacts) {
            
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[dictionary objectForKey:@"firstname"],kName,[dictionary objectForKey:@"email"],@"identifier", nil];
            [referContacts addObject:dic];
        }
        
    }
    return referContacts;
}

#pragma mark - Button delegate

- (void)pushToShareView:(NSNotification *)notification
{
    [self.tableView endEditing:YES];
    if ([[self.referDetail valueForKey:kIsAsk] boolValue])
    {
        [self message:nil];
    }else
    {
        CGRect frame = [(UIScrollView *)[self.view viewWithTag:kReferScrollViewTag] frame];
        frame.origin.x = frame.size.width * 1;
        frame.origin.y = 0;
        [(UIScrollView *)[self.view viewWithTag:kReferScrollViewTag] scrollRectToVisible:frame animated:YES];
    }
}

#pragma mark-scaleImage
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Post image
- (void)postImageWithImge
{
    [[Helper shareHelper] isReferChannel:YES];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if ([[self.referDetail objectForKey:kReferimage] isKindOfClass:[UIImage class]])
    {
        [param setValue:[self.referDetail objectForKey:kReferimage] forKey:@"profileImage"];
        
    }else
    {
        NSArray *array = [[NSString stringWithFormat:@"%@",[self.referDetail objectForKey:kReferimage]] componentsSeparatedByString:@"/"];
        NSString *imageName = [array objectAtIndex:[array count]-1];
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        if ([[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
          [param setValue:[[DocumentDirectory shareDirectory] getImageFromDirectoryWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] forKey:@"profileImage"];
            
        }
        
    }
    UIImage *frontImage= [self scaleImage:[param valueForKey:@"profileImage"] toSize:CGSizeMake(600.0, 400.0)];
    NSData *pngData = UIImageJPEGRepresentation(frontImage, 1.0);
    //NSLog(@"Image size => %u",([pngData length]/2014));
    UIImage *compressImage = [UIImage imageWithData:pngData];
    [param setValue:compressImage forKey:@"profileImage"];
    [[YoReferAPI sharedAPI] uploadImageWithParam:param completionHandler:^(NSDictionary *response,NSError *error)
     {
         [self didReceiveImageWithResponse:response error:error];
     }];
}

- (void)didReceiveImageWithResponse:(NSDictionary *)response error:(NSError *)error
{
    if (error !=nil)
    {
        [self hideHUD];
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kReferNowError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        [self.referDetail setValue:[response objectForKey:@"response"] forKey:@"mediaLink"];
        
        if ([[self.referDetail valueForKey:@"referchannel"] isEqualToString:@"FaceBook"])
        {
            FBSDKShareDialog *shareDialog = [self getShareDialogWithContentURL:[NSURL URLWithString:[self.referDetail objectForKey:@"mediaLink"]]];
            shareDialog.delegate = self;
            [shareDialog show];
        }
        
        [self getReferCode];
    }
}

#pragma mark - Refer code
- (void)getReferCode
{
    [[Helper shareHelper] isReferChannel:YES];
    
    [[YoReferAPI sharedAPI] getReferCodeWithCompletionHandler:^(NSDictionary * response ,NSError *error)
    {
        [self didReceiveReferCodeWithResponse:response error:error];
    }];
}

- (void)didReceiveReferCodeWithResponse:(NSDictionary *)response error:(NSError *)error
{
    if (error !=nil)
    {
        [self hideHUD];
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kReferNowError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        [self.referDetail setValue:[response objectForKey:@"response"] forKey:@"refercode"];
        [self setReferChannel];
    }
}

#pragma mark - Refer channel
- (void)setReferChannel
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    if (![[self.referDetail objectForKey:@"isentiyd"] boolValue])
    {
        NSMutableDictionary *subParams;
        if ([[self.referDetail objectForKey:kWeb] boolValue])
        {
            subParams = [NSMutableDictionary dictionaryWithCapacity:4];
            [subParams setValue:[self.referDetail objectForKey:kName] forKey:kName];
            [subParams setValue:kWeb forKey:kType];
            [subParams setValue:[self.referDetail valueForKey:kCategory] forKey:kCategory];
            [subParams setValue:[self.referDetail objectForKey:kWebSite] forKey:kWebSite];
            
        }else
        {
            subParams = [NSMutableDictionary dictionaryWithCapacity:11];
            NSString *entityId = [NSString stringWithFormat:@"%@",([self.referDetail objectForKey:@"entityId"] != nil && [[self.referDetail objectForKey:@"entityId"] length] > 0)?[NSString stringWithFormat:@"%@%@",[self.referDetail objectForKey:@"entityId"],[[Helper shareHelper] currentTimeWithMilliSecound]]:@""];
            [subParams setValue:(entityId != nil && [entityId length] > 0)?entityId:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"entityId"];
            self.entityId = [subParams valueForKey:@"entityId"];
            if ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kProduct])
            {
                [subParams setValue:([self.referDetail objectForKey:kFromWhere] != nil && [[self.referDetail objectForKey:kFromWhere] length] >0)?[self.referDetail objectForKey:kFromWhere]:@"" forKey:kName];
                
            }else
            {
                [subParams setValue:([self.referDetail objectForKey:kName] != nil && [[self.referDetail objectForKey:kName] length] >0)?[self.referDetail objectForKey:kName]:@"" forKey:kName];
            }
            
            //[subParams setValue:kPlace forKey:kType];
            [subParams setValue:([[self.referDetail objectForKey:kCategorytype] isEqualToString:kProduct])?kPlace:[[self.referDetail objectForKey:kCategorytype]lowercaseString] forKey:kType];
            [subParams setValue:[self.referDetail valueForKey:kCategory] forKey:kCategory];
            
            [subParams setValue:[NSString stringWithFormat:@"%@",([self.referDetail objectForKey:kLocation] != nil && [[self.referDetail objectForKey:kLocation] length] > 0)?[self.referDetail objectForKey:kLocation]:@""] forKey:kLocality];
            
            [subParams setValue:[self.referDetail objectForKey:@"city"] forKey:kCity];
            
            [subParams setValue:([self.referDetail valueForKey:@"countryName"]!= nil && [[self.referDetail valueForKey:@"countryName"] length] > 0)?[self.referDetail valueForKey:@"countryName"]:@"" forKey:@"country"];
            
            [subParams setValue:([[self.referDetail valueForKey:kCategorytype] isEqualToString:kService])?[self.referDetail objectForKey:kWebSite]:[self.referDetail objectForKey:kWebSite] forKey:kWebSite];
            
            NSString *latitude = [NSString stringWithFormat:@"%@",[self.referDetail objectForKey:kLatitude]];
            
            NSString *longitude = [NSString stringWithFormat:@"%@",[self.referDetail objectForKey:kLongitude]];
            
            [subParams setValue:[NSArray arrayWithObjects:(longitude != nil && [longitude length] > 0)?longitude:@"0.0",(latitude != nil && [latitude length] > 0)?latitude:@"0.0", nil] forKey:kPosition];
            
            [subParams setValue:[self.referDetail objectForKey:kPhone] forKey:kPhone];
            
            [subParams setValue:[self.referDetail objectForKey:kEmail] forKey:kEmail];
            
            [subParams setValue:([[self.referDetail valueForKey:kCategoryid] length] > 0)?[self.referDetail valueForKey:kCategoryid]:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"foursquareCategoryId"];
            
        }
        if ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kProduct])
        {
            NSMutableDictionary *purchageDetail=[[NSMutableDictionary alloc]init];
            [purchageDetail setValue:subParams forKey:kDetail];
            NSMutableDictionary *product=[[NSMutableDictionary alloc]init];
            [product setValue:purchageDetail forKey:kPurchasedFrom];
            [product setValue:[[Helper shareHelper] getRandomEntityId] forKey:@"entityId"];
            self.entityId = [product valueForKey:@"entityId"];
            [product setValue:[self.referDetail objectForKey:kName] forKey:kName];
            [product setValue:[[self.referDetail objectForKey:kCategorytype] lowercaseString] forKey:kType];
            [product setValue:[self.referDetail valueForKey:kCategory] forKey:kCategory];
            [product setValue:[self.referDetail objectForKey:kCity] forKey:kCity];
            [params setValue:product forKey:kEntity];
            
        }else
        {
            [params setValue:subParams forKey:kEntity];
        }
    }else
    {
        NSMutableDictionary *subParams = [NSMutableDictionary dictionaryWithCapacity:1];
        [subParams setValue:[self.referDetail objectForKey:@"entityId"] forKey:@"entityId"];
        [subParams setValue:[self.referDetail objectForKey:kCategorytype] forKey:kType];

        self.entityId = [subParams valueForKey:@"entityId"];
        [params setValue:subParams forKey:kEntity];
    }
    
    
    if ([[self.referDetail objectForKey:kWeb] boolValue])
    {
    }else
    {
        if ([self.referDetail objectForKey:@"mediaLink"]!=nil && [[self.referDetail objectForKey:@"mediaLink"] length] > 0)
        {
            [params setValue:([self.referDetail objectForKey:@"mediaLink"]!=nil && [[self.referDetail objectForKey:@"mediaLink"] length] > 0)?[self.referDetail objectForKey:@"mediaLink"]:@"" forKey:@"mediaLink"];
            
        }else
        {
            if (![[self.referDetail objectForKey:kReferimage] isKindOfClass:NULL]) {
                
                [params setValue:([self.referDetail objectForKey:kReferimage]!=nil && [[self.referDetail objectForKey:kReferimage] length] > 0)?[self.referDetail objectForKey:kReferimage]:@"" forKey:@"mediaLink"];
            }
            
        }
    }
    
    
    if ([[self.referDetail valueForKey:@"isask"] boolValue]){
        [params setValue:([self.referDetail valueForKey:@"askId"])?[self.referDetail valueForKey:@"askId"]:[self.referDetail valueForKey:@"askid"] forKey:@"askId"];
    }
    
    /*
    if ([[self.referDetail valueForKey:@"isask"] boolValue]){
        [params setValue:[self.referDetail valueForKey:@"askid"] forKey:@"askId"];
    }
    */
    
    [params setValue:[self.referDetail objectForKey:@"refercode"] forKey:@"referCode"];
    [params setValue:([self.referDetail objectForKey:kMessage] != nil && [[self.referDetail objectForKey:kMessage] length] > 0)?[self.referDetail objectForKey:kMessage]:@"" forKey:@"note"];
    [params setValue:self.contacts forKey:@"to"];
    [params setValue:self.channelType forKey:@"channel"];
    
    /*
    if ([self.referDetail objectForKey:@"email"]) {
        [params setValue:[self.referDetail objectForKey:@"email"] forKey:@"email"];
    }
    */
    
    [[YoReferAPI sharedAPI] referChannelWithParams:params completionHandler:^(NSDictionary *response , NSError *error)
    {
        [self didReceiveReferChannelWithResponse:response error:error];
        
    }];
}

- (void)didReceiveReferChannelWithResponse:(NSDictionary *)response error:(NSError *)error
{
    if (error !=nil)
    {
        [self hideHUD];
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kReferNowError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [self hideHUD];
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        NSMutableDictionary *parmas = [[YoReferUserDefaults shareUserDefaluts] objectForKey:@"login"];
        [[YoReferAPI sharedAPI] loginWithParams:parmas completionHandler:^(NSDictionary *response ,NSError *error){
            [self didReceiveLoginWithResponse:response error:error];
        }];
    }

}

- (void)didReceiveLoginWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    [self hideHUD];
    [[Helper shareHelper] isReferChannel:NO];
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }
    }else
    {
        NSArray *feedData = @[@"300",@"301",@"302"];
        for (int i = 0; i< feedData.count; i++)
        {
            [[CoreData shareData] deleteFeedsWithLoginId:[[UserManager shareUserManager] number]feedsType:feedData[i]];
        }
        if ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kPlace])
        {
            [[CoreData shareData] deletePlaceReferWithLoginId:[[UserManager shareUserManager] number]];
        }else if ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kProduct])
        {
            [[CoreData shareData] deleteProductReferWithLoginId:[[UserManager shareUserManager] number]];
        }else if ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kService])
        {
            [[CoreData shareData] deleteServiceReferWithLoginId:[[UserManager shareUserManager] number]];
        }else if ([[self.referDetail objectForKey:kCategorytype] isEqualToString:kWeb])
        {
            [[CoreData shareData] deleteWebReferWithLoginId:[[UserManager shareUserManager] number]];
        }
        [[UserManager shareUserManager] populateUserInfoFromResponse:[[resonse objectForKey:@"response"] objectForKey:@"user"] sessionId:[[resonse objectForKey:@"response"] valueForKey:@"sessionToken"]];
        [[CoreData shareData] deleteReferWithLoginId:[[UserManager shareUserManager] number]];
        [[CoreData shareData]deleteAskWithLoginId:[[UserManager shareUserManager] number]];
        [[CoreData shareData] deleteQueriesWithLoginId:[[UserManager shareUserManager] number] ];
        [[CoreData shareData] deleteFriendsWithLoginId:[[UserManager shareUserManager] number]];
        [self getCurrentLocationOffer];
    }
}
- (void)getCurrentLocationOffer
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:[NSArray arrayWithObjects:[self.referDetail objectForKey:kLatitude],[self.referDetail objectForKey:kLongitude], nil] forKey:kLocation];
    [params setValue:@"30" forKey:@"radius"];
    [[YoReferAPI sharedAPI] currentLocationOfferWithParams:params completionHandler:^(NSDictionary *response , NSError * error)
     {
         [self didReceiveLocationOfferWithResponse:response error:error];
     }];
}
- (void)didReceiveLocationOfferWithResponse:(NSDictionary *)response error:(NSError *)error
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
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(@"Error", @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        if ([[response objectForKey:@"response"] count] <= 0)
        {
            [[UIManager sharedManager] goToHomePageWithAnimated:YES];
            
        }else
        {
            //[self dismissShareView];
            self.referResponse = [[NSMutableArray alloc]init];
            NSMutableArray *referResponse = [response objectForKey:@"response"];
            for (int i = 0; i < [referResponse count]; i++) {
                if ([self.entityId isEqualToString:[[referResponse objectAtIndex:i] valueForKey:@"entityId"]])
                {
                }else
                {
                    [self.referResponse addObject:[referResponse objectAtIndex:i]];
                }
            }
            NSMutableDictionary *referals = [[NSMutableDictionary alloc]init];
            NSMutableArray *referalArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dictionary in self.referResponse) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setValue:[dictionary objectForKey:kDp] forKey:kDp];
                [dic setValue:[[dictionary objectForKey:kEntity]objectForKey:kName] forKey:kName];
                [dic setValue:[[dictionary objectForKey:kEntity]objectForKey:kLocality] forKey:kLocality];
                [referalArray addObject:dic];
            }
            [referals setValue:self.referResponse forKey:@"response"];
            [[YoReferUserDefaults shareUserDefaluts] setValue:@"Show" forKey:@"Header"];
            UIView *categoryView  = [[CategoriesView alloc] initWithViewFrame:self.view.frame categoryList:referals delegate:self isResponse:NO];
            categoryView.tag = 50000;
            [categoryView setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:categoryView];
            categoryView.frame = CGRectMake(0.0,59.0, [self bounds].size.width, [self bounds].size.height - 85.0);
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
}

#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            ImageViewController *vctr = [[ImageViewController alloc]initWithImage:self.preViewImage];
            [self.navigationController pushViewController:vctr animated:YES];
            break;
        }
        case 1:
            [self newImage];
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
