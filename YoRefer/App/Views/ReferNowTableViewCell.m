
//
//  ReferNowTableViewCell.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/15/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ReferNowTableViewCell.h"
#import "ReferNowViewController.h"
#import "Configuration.h"
#import "YoReferUserDefaults.h"
#import "UserManager.h"
#import "CoreData.h"
#import "CategoryType.h"
#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "Helper.h"
#import "Utility.h"
#import "LocationManager.h"

#define LIMIT  @"20"
#define RADIUS @"20000"

static NSString * prevPlaceHolder = nil;

NSString * const kReferNowIdentifier                =  @"identifier";
NSString    *   const   kReferMessagePlaceHolder    =  @"Enter Your Message (Optional)";
NSString    *   const   kReferWebSitePlaceHolder    =  @"Enter WebSite";
NSString    *   const   kReferLocationPlaceHolder   = @"Enter Address";
NSUInteger      const   kClearViewTag               = 90000;

NSString    *   const kReferAlertMessage           = @"Yorefer would like to use your location";


UILabel *referPlaceCircleDot;
UILabel *referProductCircleDot;
UILabel *referServiceCircleDot;
CGFloat referShiftForKeyboard;
NSMutableArray *mediaArray;
NSInteger     imageCnt , selectedIndex;
UIScrollView  *imageScroll;
UIImageView *next, *previous;
BOOL isNotification;

NSString    *   const   kReferImage             = @"referimage";
NSString    *   const   kReferAddress           = @"address" ;
NSString    *   const   kRefernowCategoryType   = @"categorytype";
NSString    *   const   kReferNowName           = @"name";
NSString    *   const   kReferNowCategory       = @"category";
NSString    *   const   kReferLatitude          = @"latitude";
NSString    *   const   kReferLongitude         = @"longitude";
NSString    *   const   kReferEntityId          = @"entityId";
NSString    *   const   kReferisEntiyId         = @"isentiyd";
NSString    *   const   kReferPoint             = @"referpoint";
NSString    *   const   kReferCategoryId        = @"categoryid";
NSString    *   const   kReferCity              = @"refercity";
NSString    *   const   kReferCountry           = @"refercountry";
NSString    *   const   kMedia                  = @"Select Media";
NSString    *   const   kLocationMessage        = @"Enter Address";
NSUInteger      const   kLocDropDownShow        = 60000;
NSUInteger      const   kLocDropDownHide        = 70000;
NSUInteger      const   kDefaultImage           = 80000;
NSInteger               currentPage             = 0;

@interface ReferNowTableViewCell   ()<UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic ,strong) CALayer * imagelayer;
@property (nonatomic ,strong) UIImageView *imageSelectImage;

@end

@implementation ReferNowTableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<referNowTableViewCell>)delegate referDetail:(NSMutableDictionary *)referDetail
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifireWithReferType:(ReferNowType)indexPath.row indexPath:indexPath]];
    if (self)
    {
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self referWithIndexPath:indexPath referDetail:referDetail];
    }
    return self;
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


- (void)referWithIndexPath:(NSIndexPath *)indexPath referDetail:(NSMutableDictionary *)referDetail
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 10.0;
    CGFloat yPos = 10.0;
    CGFloat height = 140.0;
    CGFloat width = frame.size.width - 20.0;
    if (indexPath.row == ReferLocations)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 33.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferLocations text:[referDetail valueForKey:kCity] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferLocations;
        viewMain.backgroundColor = [UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        if ([[referDetail objectForKey:kWeb] boolValue])
        {
            xPos = 5.0;
            yPos = 0.0;
            width = viewMain.frame.size.width - 30.0;
            UILabel *textAddress = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            [textAddress  setText:NSLocalizedString([referDetail objectForKey:kReferAddress], @"")];
            [textAddress setBackgroundColor:[UIColor clearColor]];
            [textAddress setTextColor:[UIColor blackColor]];
            [textAddress setTextAlignment:NSTextAlignmentCenter];
            [textAddress setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
            [viewMain addSubview:textAddress];
            viewMain.backgroundColor = [UIColor whiteColor];
        }else
        {
            xPos = 5.0;
            yPos = 0.0;
            width = viewMain.frame.size.width - 30.0;
            UITextField *textAddress = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) ReferNowType:ReferLocations text:([referDetail valueForKey:kCity]!= nil && [[referDetail valueForKey:kCity] length] > 0)?[referDetail valueForKey:kCity]:@"" isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue] categoryType:[referDetail valueForKey:kCategorytype]];
            [textAddress setBackgroundColor:[UIColor clearColor]];
            [textAddress setTextColor:[UIColor whiteColor]];
            [viewMain addSubview:textAddress];
            UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, viewMain.frame.size.width, viewMain.frame.size.height)];
            [locationBtn addTarget:self action:@selector(locationBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [viewMain addSubview:locationBtn];
            //enableanddisbale location button
            [locationBtn setHidden:([[UserManager shareUserManager] getLocationService])?YES:NO];
            xPos = viewMain.frame.size.width - 35.0;
            width = 25.0;
            height = 25.0;
            yPos = round((viewMain.frame.size.height - height)/2);
            UIImageView *imageDownArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            imageDownArrow.image = ([[referDetail valueForKey:kNewRefer] boolValue])?downarraow:[UIImage imageNamed:@""];
            [viewMain addSubview:imageDownArrow];
            xPos = viewMain.frame.size.width - 40.0;
            yPos = 0.0;
            width = 40.0;
            height = 40.0;
            UIButton *addressBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            [addressBtn setBackgroundColor:[UIColor clearColor]];
            [addressBtn setTag:13212];
            [addressBtn addTarget:self action:@selector(addressBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [viewMain addSubview:addressBtn];
        }
    }else if (indexPath.row == ReferCategoryType)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 30.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferCategoryType text:[referDetail valueForKey:kCategorytype] isNewRefer:([[referDetail valueForKey:kIsAsk] boolValue])?NO:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferCategoryType;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        [viewMain setHidden:([[referDetail objectForKey:@"web"] boolValue])?YES:NO];
        xPos = 0.0;
        yPos = 0.0;
        width = viewMain.frame.size.width/4;
        UIView *viewPlace = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [viewMain addSubview:viewPlace];
        xPos = viewPlace.frame.size.width - 4.0;
        UIView *viewProduct = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [viewMain addSubview:viewProduct];
        xPos = viewPlace.frame.size.width + viewProduct.frame.size.width;
        UIView *viewService = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [viewMain addSubview:viewService];
        xPos = viewPlace.frame.size.width + viewProduct.frame.size.width + viewService.frame.size.width;
        UIView *viewWeb = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [viewMain addSubview:viewWeb];
        xPos = viewPlace.frame.size.width/2 - 15.0;
        width = viewPlace.frame.size.width/2 + 20.0;
        UILabel *place = [[UILabel alloc]initWithFrame:CGRectMake(xPos + 1.0, yPos, width, height)];
        place.text = @"Place";
        place.textAlignment = NSTextAlignmentLeft;
        place.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        place.textColor = [UIColor blackColor];
        [viewPlace addSubview:place];
        UILabel *product = [[UILabel alloc]initWithFrame:CGRectMake(xPos - 6.0, yPos, width, height)];
        product.text = @"Product";
        product.textAlignment = NSTextAlignmentLeft;
        product.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        product.textColor = [UIColor blackColor];
        [viewProduct addSubview:product];
        UILabel *service = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        service.text = @"Service";
        service.textAlignment = NSTextAlignmentLeft;
        service.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        service.textColor = [UIColor blackColor];
        [viewService addSubview:service];
        UILabel *web = [[UILabel alloc]initWithFrame:CGRectMake(xPos + 4.0, yPos, width, height)];
        web.text = @"Web";
        web.textAlignment = NSTextAlignmentLeft;
        web.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        web.textColor = [UIColor blackColor];
        [viewWeb addSubview:web];
        xPos = place.frame.origin.x - 20.0;
        width = 16.0;
        height = 16.0;
        yPos = 7.0;
        UILabel *placeCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        placeCircle.layer.cornerRadius = 8.0;
        placeCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        placeCircle.layer.borderWidth = 1.0;
        placeCircle.layer.masksToBounds = YES;
        [viewPlace addSubview:placeCircle];
        xPos = product.frame.origin.x - 20.0;
        UILabel *productCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        productCircle.layer.cornerRadius = 8.0;
        productCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        productCircle.layer.borderWidth = 1.0;
        productCircle.layer.masksToBounds = YES;
        [viewProduct addSubview:productCircle];
        xPos = service.frame.origin.x - 20.0;
        UILabel *serviceCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        serviceCircle.layer.cornerRadius = 8.0;
        serviceCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        serviceCircle.layer.borderWidth = 1.0;
        serviceCircle.layer.masksToBounds = YES;
        [viewService addSubview:serviceCircle];
        UILabel *webCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos + 4.0, yPos, width, height)];
        webCircle.layer.cornerRadius = 8.0;
        webCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        webCircle.layer.borderWidth = 1.0;
        webCircle.layer.masksToBounds = YES;
        [viewWeb addSubview:webCircle];
        xPos = 5;
        width = 6.0;
        height = 6.0;
        yPos = 5.0;
        UILabel *referPlaceCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        referPlaceCircleDot.tag = ReferPlaces;
        referPlaceCircleDot.layer.cornerRadius = 3.0;
        referPlaceCircleDot.layer.masksToBounds = YES;
        referPlaceCircleDot.backgroundColor = [UIColor clearColor];
        [placeCircle addSubview:referPlaceCircleDot];
        UILabel *referProductCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        referProductCircleDot.tag = ReferProduct;
        referProductCircleDot.layer.cornerRadius = 3.0;
        referProductCircleDot.layer.masksToBounds = YES;
        referProductCircleDot.backgroundColor = [UIColor clearColor];
        [productCircle addSubview:referProductCircleDot];
        UILabel *referServiceCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        referServiceCircleDot.tag = ReferServices;
        referServiceCircleDot.layer.cornerRadius = 3.0;
        referServiceCircleDot.layer.masksToBounds = YES;
        referServiceCircleDot.backgroundColor = [UIColor clearColor];
        [serviceCircle addSubview:referServiceCircleDot];
        UILabel *webServiceCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        webServiceCircleDot.tag = ReferServices;
        webServiceCircleDot.layer.cornerRadius = 3.0;
        webServiceCircleDot.layer.masksToBounds = YES;
        webServiceCircleDot.backgroundColor = [UIColor clearColor];
        [webCircle addSubview:webServiceCircleDot];
        UITapGestureRecognizer *placeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeMark:)];
        [viewPlace addGestureRecognizer:placeGestureRecognizer];
        UITapGestureRecognizer *productGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(productMark:)];
        [viewProduct addGestureRecognizer:productGestureRecognizer];
        UITapGestureRecognizer *serviceGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(serviceMark:)];
        [viewService addGestureRecognizer:serviceGestureRecognizer];
        UITapGestureRecognizer *webGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webMark:)];
        [viewWeb addGestureRecognizer:webGestureRecognizer];
        if ([[referDetail valueForKey:kNewRefer] boolValue] && ![[referDetail valueForKey:kIsAsk] boolValue])
        {
            if ([[referDetail valueForKey:kCategorytype] isEqualToString:kPlace])
            {
                referPlaceCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
                
            }else if ([[referDetail valueForKey:kCategorytype] isEqualToString:kProduct])
            {
               
                referProductCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
                
            }else if ([[referDetail valueForKey:kCategorytype] isEqualToString:kService])
            {
                referServiceCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
                
            }
        }else
        {
            if ([[referDetail valueForKey:kCategorytype] isEqualToString:kPlace])
            {
                referPlaceCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
            }else if ([[referDetail valueForKey:kCategorytype] isEqualToString:kProduct])
            {
                referProductCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
            }else if ([[referDetail valueForKey:kCategorytype] isEqualToString:kService])
            {
                referServiceCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
            }
            [viewPlace setAlpha:0.6];
            [viewProduct setAlpha:0.6];
            [viewService setAlpha:0.6];
            [viewWeb setAlpha:0.6];
            [place setTextColor:[UIColor grayColor]];
            [product setTextColor:[UIColor grayColor]];
            [service setTextColor:[UIColor grayColor]];
            [web setTextColor:[UIColor grayColor]];
        }
        
    }else if (indexPath.row == ReferCategories)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 42.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferCategories text:[referDetail valueForKey:kCategory] isNewRefer:([[referDetail valueForKey:kIsAsk] boolValue])?NO:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferCategories;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        xPos = 5.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 40.0;
        UITextField *textCategory = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) ReferNowType:ReferCategories text:([referDetail valueForKey:kCategory] != nil && [[referDetail valueForKey:kCategory] length] > 0)?[referDetail valueForKey:kCategory]:@"" isNewRefer:([[referDetail valueForKey:kIsAsk] boolValue])?NO:[[referDetail valueForKey:kNewRefer] boolValue]categoryType:[referDetail valueForKey:kCategorytype]];
        textCategory.userInteractionEnabled = YES;
        [viewMain addSubview:textCategory];
        UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, viewMain.frame.size.width, viewMain.frame.size.height)];
        [categoryBtn addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [viewMain addSubview:categoryBtn];
        width = 25.0;
        height = 25.0;
        xPos = viewMain.frame.size.width - 35.0;
        yPos = roundf((viewMain.frame.size.height - height)/2);
        UIImageView *imageDownArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        imageDownArrow.image = ([[referDetail valueForKey:kNewRefer] boolValue] && ![[referDetail valueForKey:kIsAsk] boolValue])?downArrowImg:disableDownImg;
        [viewMain addSubview:imageDownArrow];
    }else if (indexPath.row == ReferName)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 42.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferName text:[referDetail valueForKey:kName] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferName;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        xPos = 5.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 13.0;
        UITextField *textCategory = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) ReferNowType:ReferName text:[referDetail valueForKey:kName] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]categoryType:[referDetail valueForKey:kCategorytype]];
        [viewMain addSubview:textCategory];
        //Button
        xPos = 0.0;
        yPos = 0.0;
        width = viewMain.frame.size.width;
        height = viewMain.frame.size.height;
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [button addTarget:self action:@selector(nameBtnTpped:) forControlEvents:UIControlEventTouchUpInside];
        [button setHidden:([[referDetail valueForKey:kCategorytype]isEqualToString:kService])?NO:YES];
        [viewMain addSubview:button];
    }else if (indexPath.row == ReferMessage)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 55.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferMessage text:kMessage isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferMessage;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        xPos = 5.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 34.0;
        UITextView * textEnterDetails = [self createTextViewWithFrame:CGRectMake(xPos, yPos, width, height) ReferNowType:ReferMessage text:[referDetail valueForKey:kMessage] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue] categoryType:[referDetail valueForKey:kCategorytype]];
        [textEnterDetails setUserInteractionEnabled:YES];
        [viewMain addSubview:textEnterDetails];
        height = viewMain.frame.size.height;
        width = 30.0;
        xPos = viewMain.frame.size.width - width;
        yPos = roundf((viewMain.frame.size.height - height)/2);
        UIView *crossView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [crossView setHidden:YES];
        [crossView setBackgroundColor:[UIColor clearColor]];
        [viewMain addSubview:crossView];
        UITapGestureRecognizer *clearGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearGestureTapped:)];
        [crossView addGestureRecognizer:clearGesture];
        width =14.0;
        height = 14.0;
        xPos = 0.0;
        yPos = roundf((crossView.frame.size.height - height)/2);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [imageView setImage:crossIconImg];
        [crossView addSubview:imageView];
    }else if (indexPath.row == ReferFromWhere)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 30.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferFromWhere text:kFromWhere isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferFromWhere;
        [viewMain setBackgroundColor:[UIColor whiteColor]];
        [viewMain.layer setCornerRadius:5.0];
        [viewMain.layer setMasksToBounds:YES];
        [self.contentView addSubview:viewMain];
        xPos = 5.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 30.0;
        UITextField *textCategory = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, viewMain.frame.size.width, height) ReferNowType:ReferFromWhere text:[referDetail valueForKey:kFromWhere] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]categoryType:[referDetail valueForKey:kCategorytype]];
        textCategory.userInteractionEnabled = YES;
        [viewMain addSubview:textCategory];
        if ([[referDetail objectForKey:kCategorytype] isEqualToString:kProduct])
            [viewMain setHidden:NO];
        else
            [viewMain setHidden:YES];
    }else if (indexPath.row == ReferAddress)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = 63.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferAddress text:kAddress isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferAddress;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        [viewMain setHidden:([[referDetail objectForKey:kWeb] boolValue])?YES:NO];
        xPos = 5.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 85.0;
        UITextView *textEnterDetails = [self createTextViewWithFrame:CGRectMake(xPos, yPos, width, height) ReferNowType:ReferAddress text:[referDetail valueForKey:kLocation] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue] categoryType:[referDetail valueForKey:kCategorytype]];
        [viewMain addSubview:textEnterDetails];
        width = 55.0;
        height = viewMain.frame.size.height - 10.0;
        xPos = viewMain.frame.size.width - (width + 4.0);
        yPos = round((viewMain.frame.size.height - height)/2);
        UIImageView *imageMap = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        imageMap.image = mapImage;
        [viewMain addSubview:imageMap];
        UITapGestureRecognizer *mapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapGestureTapped:)];
        [imageMap setUserInteractionEnabled:([[referDetail valueForKey:kNewRefer] boolValue])?YES:NO];
        [imageMap setAlpha:([[referDetail valueForKey:kNewRefer] boolValue])?1.0:0.4];
        [imageMap addGestureRecognizer:mapGestureRecognizer];
        height = viewMain.frame.size.height;
        width = 30.0;
        xPos = viewMain.frame.size.width - (imageMap.frame.size.width + 26.0);
        yPos = roundf((viewMain.frame.size.height - height)/2);
        UIView *crossView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [crossView setTag:kClearViewTag];
        [crossView setHidden:YES];
        [crossView setBackgroundColor:[UIColor clearColor]];
        [viewMain addSubview:crossView];
        UITapGestureRecognizer *clearGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearGestureTapped:)];
        [crossView addGestureRecognizer:clearGesture];
        width =14.0;
        height = 14.0;
        xPos = 0.0;
        yPos = roundf((crossView.frame.size.height - height)/2);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [imageView setImage:crossIconImg];
        [crossView addSubview:imageView];
        //enable and disable view
        if ([referDetail valueForKey:kLocation] != nil && [[referDetail valueForKey:kLocation] length] > 0 && ![[referDetail valueForKey:kNewRefer] boolValue])
        {
            [viewMain setUserInteractionEnabled:YES];
            [textEnterDetails setEditable:NO];
        }
    }else if (indexPath.row == ReferPhoneAndWebSite)
    {
        xPos = 10.0;
        yPos = 5.0;
        height = [[referDetail objectForKey:kWeb] boolValue]?80.0:85.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferPhoneAndWebSite text:([[referDetail valueForKey:kPhone] length] > 0)?[referDetail valueForKey:kPhone]:([[referDetail valueForKey:kWebSite] length] > 0)?[referDetail valueForKey:kWebSite]:@"" isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]];
        viewMain.tag = ReferPhoneAndWebSite;
        [self.contentView addSubview:viewMain];
        if ([[referDetail objectForKey:kWeb] boolValue])
        {
            xPos = 0.0;
            yPos = 0.0;
            width = viewMain.frame.size.width - 4.0;
            height = 80.0;
            UIView *viewPhone = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            viewPhone.tag = ReferPhoneAndWebSite;
            viewPhone.backgroundColor = [UIColor whiteColor];
            viewPhone.layer.cornerRadius = 5;
            viewPhone.layer.masksToBounds = YES;
            [viewMain addSubview:viewPhone];
            
            
            xPos = 5.0;
            yPos = 0.0;
            width = viewPhone.frame.size.width - 44.0;
            
            NSLog(@"%@",[referDetail valueForKey:kWebSite]);
            
            // For shorten url...
            /*
            [self shortenMapUrl:[referDetail valueForKey:kWebSite]];
            [_websiteShortenUrl setHidden:YES];
            */
            
            _websiteShortenUrlTxtField = [self createTextViewWithFrame:CGRectMake(xPos, yPos, width, height) ReferNowType:Website text:[referDetail valueForKey:kWebSite] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue] categoryType:[referDetail valueForKey:kCategorytype]];
            _websiteShortenUrlTxtField.tag= ReferPhoneAndWebSite;
            [viewPhone addSubview:_websiteShortenUrlTxtField];
            
            
            width = 40.0;
            height = 40.0;
            xPos = viewPhone.frame.size.width - (width + 4.0);
            yPos = roundf((viewPhone.frame.size.height - height)/2);
            UIImageView *webReferImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            [webReferImage setUserInteractionEnabled:YES];
            [webReferImage setImage:webImage];
            [viewPhone addSubview:webReferImage];
            UITapGestureRecognizer *webGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webGestureTapped:)];
            [webReferImage addGestureRecognizer:webGestureRecognizer];
            if ([referDetail valueForKey:kWebSite] != nil && [[referDetail valueForKey:kWebSite] length] > 0 && ![[referDetail valueForKey:kNewRefer] boolValue])
            {
                [viewMain setUserInteractionEnabled:YES];
                [_websiteShortenUrlTxtField setEditable:NO];
            }
        }else
        {
            yPos = 0.0;
            width = (viewMain.frame.size.width/2) - 4.0;
            height = viewMain.frame.size.height;
            xPos = 0.0;
            
            UIView *viewPhone = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height/2)];
            viewPhone.backgroundColor = [UIColor whiteColor];
            viewPhone.layer.cornerRadius = 5;
            viewPhone.layer.masksToBounds = YES;
            [viewMain addSubview:viewPhone];
            xPos = viewPhone.frame.size.width + 8.0;
            width = (viewMain.frame.size.width/2) - 4.0;
           
            UIView *viewWebSite = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height/2)];
            viewWebSite.backgroundColor = [UIColor whiteColor];
            viewWebSite.layer.cornerRadius = 5;
            viewWebSite.layer.masksToBounds = YES;
            [viewMain addSubview:viewWebSite];
           
            UIView *viewEmailID = [[UIView alloc]initWithFrame:CGRectMake(0.0, yPos+52, (viewMain.frame.size.width), height/2)];
            viewEmailID.backgroundColor = [UIColor whiteColor];
            viewEmailID.layer.cornerRadius = 5;
            viewEmailID.layer.masksToBounds = YES;
            [viewMain addSubview:viewEmailID];
            
            
            xPos = 5.0;
            yPos = 0.0;
            width = viewPhone.frame.size.width;
            UITextField *textPhone = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height/2) ReferNowType:Phone text:[referDetail valueForKey:kPhone] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]categoryType:[referDetail valueForKey:kCategorytype]];
            [viewPhone addSubview:textPhone];
            UITextField *textWebsite  = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width*2, height/2) ReferNowType:Website text:[referDetail valueForKey:kWebSite] isNewRefer:[[referDetail valueForKey:kNewRefer]boolValue]categoryType:[referDetail valueForKey:kCategorytype]];
//            [viewWebSite addSubview:textWebsite];
            [viewEmailID addSubview:textWebsite];
            
            UITextField *textEmailID  = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, viewMain.frame.size.width, height/2) ReferNowType:ReferEmailID text:[referDetail valueForKey:kEmail] isNewRefer:[[referDetail valueForKey:kNewRefer] boolValue]categoryType:[referDetail valueForKey:kCategorytype]];
//            [viewEmailID addSubview:textEmailID];
            [viewWebSite addSubview:textEmailID];
            
        }
    }else if (indexPath.row == ReferImage)
    {
        
        xPos = 0.0;
//        yPos = 6.0;
        yPos = -10.0;
        height = 84.0;
        width = frame.size.width;
        UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) referNowType:ReferImage text:kImage isNewRefer:YES];
        UITapGestureRecognizer *imageGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newImageGestureTapped:)];
        [viewMain addGestureRecognizer:imageGestureRecognizer];
        viewMain.tag = ReferImage;
        [self.contentView addSubview:viewMain];
        [viewMain setHidden:([[referDetail objectForKey:kWeb] boolValue])?YES:NO];
        xPos = 10.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - xPos * 2;
        height = viewMain.frame.size.height - 3.0;
        //BackgorundImage
        UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [backgroundImg setBackgroundColor:[UIColor whiteColor]];
        [viewMain addSubview:backgroundImg];
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = backgroundImg.bounds;
        [backgroundImg addSubview:visualEffectView];
        width = backgroundImg.frame.size.height - 6.0;
        xPos = roundf((viewMain.frame.size.width - width)/2);
        yPos = 3.0;
        [backgroundImg.layer setCornerRadius:7.0];
        [backgroundImg.layer setMasksToBounds:YES];
        height = backgroundImg.frame.size.height - 6.0;
        //cameraImage
        width = 60.0;
        height = 60.0;
        xPos = (viewMain.frame.size.width - width)/2;
        yPos = (viewMain.frame.size.height - height)/2;
        UIImageView *imageCamera = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        imageCamera.image = cameraImg;
        [imageCamera setUserInteractionEnabled:YES];
        [imageCamera setHidden:([[referDetail valueForKey:kNewRefer] boolValue])?NO:YES];
        viewMain.backgroundColor = [UIColor clearColor];
        [viewMain addSubview:imageCamera];
       //SelectImage
        width = 80.0;
        height = viewMain.frame.size.height - 10.0;
        xPos = roundf((viewMain.frame.size.width - width)/2);
        yPos = roundf((viewMain.frame.size.height - height)/2) - 3.0;
        UIImageView *referImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [referImage setHidden:([[referDetail valueForKey:kNewRefer] boolValue] && ![[referDetail valueForKey:kReferImage] isKindOfClass:[UIImage class]])?YES:NO];
        [referImage.layer setMasksToBounds:YES];
        [referImage.layer setCornerRadius:20.0];
        [referImage.layer setBorderWidth:2.0];
        [referImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [referImage setUserInteractionEnabled: YES];
//        UITapGestureRecognizer *referImageGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newImageGestureTapped:)];
//        [referImage addGestureRecognizer:referImageGestureRecognizer];
        [viewMain addSubview:referImage];
        //add name
        if ([[referDetail valueForKey:kReferImage] isKindOfClass:[NSString class]])
        {
            NSArray *array = [[NSString stringWithFormat:@"%@",[referDetail valueForKey:kReferImage]] componentsSeparatedByString:@"/"];
            NSString *imageName = [array objectAtIndex:[array count]-1];
            if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
            {
                [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:backgroundImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:referImage path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                
            }else{
                
                if ([NSString stringWithFormat:@"%@",[referDetail valueForKey:kReferImage]] != nil && [[NSString stringWithFormat:@"%@",[referDetail valueForKey:kReferImage]] length] > 0)
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[referDetail valueForKey:kReferImage]]] imageView:backgroundImg];
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[referDetail valueForKey:kReferImage]]] imageView:referImage];
                }else
                {
                    if ([imageName isEqualToString:@""])
                    {
                        xPos = 10.0;
                        yPos = 0.0;
                        width = viewMain.frame.size.width - xPos * 2;
                        height = viewMain.frame.size.height - 3.0;
                        [backgroundImg setFrame:CGRectMake(xPos, yPos, width, height)];
                        width = backgroundImg.frame.size.height - 6.0;
                        height = backgroundImg.frame.size.height - 6.0;
                        xPos = roundf((viewMain.frame.size.width - width)/2);
                        yPos = 3.0;
                        [referImage setFrame:CGRectMake(xPos, yPos, width, height)];
                        if ([[referDetail valueForKey:kCategorytype] isEqualToString:kPlace])
                        {
                            [referImage setImage:placeImg];
                            [referImage setTag:kDefaultImage];
                            [backgroundImg setImage:placeImg];
                        }
                        else  if ([[referDetail valueForKey:kCategorytype] isEqualToString:kProduct])
                        {
                            [referImage setImage:productImg];
                            [referImage setTag:kDefaultImage];
                            [backgroundImg setImage:productImg];
                        }else  if ([[referDetail valueForKey:kCategorytype] isEqualToString:kWeb])
                        {
                            [referImage setImage:webLinkImg];
                            [referImage setTag:kDefaultImage];
                            [backgroundImg setImage:webLinkImg];
                        }else  if ([[referDetail valueForKey:kCategorytype] isEqualToString:kService])
                        {
                            [referImage setImage:serviceImg];
                            [referImage setTag:kDefaultImage];
                            [backgroundImg setImage:serviceImg];
                        }
                        else
                            [referImage setImage:noPhotoImg];
                            [referImage setTag:kDefaultImage];
                    }
                    else
                    {
                        width = 68.0;
                        height = 68.0;
                        xPos = roundf((viewMain.frame.size.width - width)/2);
                        yPos = (viewMain.frame.size.height - height)/2;
                        [referImage setFrame:CGRectMake(xPos, yPos, width, height)];
                        [referImage setImage:cameraImg];
                    }
                }
            }
        }else
        {
            
            if ([[referDetail objectForKey:kReferImage] isKindOfClass:[UIImage class]])
            {
                backgroundImg.image = [referDetail valueForKey:kReferImage];
                referImage.image = [referDetail valueForKey:kReferImage];
                
            }else
            {
                //self.imagelayer.hidden = YES;
                xPos = 10.0;
                yPos = 0.0;
                width = viewMain.frame.size.width - xPos * 2;
                height = viewMain.frame.size.height - 3.0;
                [backgroundImg setFrame:CGRectMake(xPos, yPos, width, height)];
                width = backgroundImg.frame.size.height - 6.0;
                height = backgroundImg.frame.size.height - 6.0;
                xPos = roundf((viewMain.frame.size.width - width)/2);
                yPos = 3.0;
                [referImage setFrame:CGRectMake(xPos, yPos, width, height)];
                if ([[referDetail valueForKey:kCategorytype] isEqualToString:kPlace] && ![[referDetail valueForKey:kNewRefer] boolValue])
                {
                    [referImage setImage:placeImg];
                    [referImage setTag:kDefaultImage];
                    [backgroundImg setImage:placeImg];
                }
                else  if ([[referDetail valueForKey:kCategorytype] isEqualToString:kProduct])
                {
                    [referImage setImage:productImg];
                    [referImage setTag:kDefaultImage];
                    [backgroundImg setImage:productImg];
                }else  if ([[referDetail valueForKey:kCategorytype] isEqualToString:kWeb])
                {
                    [referImage setImage:webLinkImg];
                    [referImage setTag:kDefaultImage];
                    [backgroundImg setImage:webLinkImg];
                }else  if ([[referDetail valueForKey:kCategorytype] isEqualToString:kService])
                {
                    [referImage setImage:serviceImg];
                    [referImage setTag:kDefaultImage];
                    [backgroundImg setImage:serviceImg];
                }
                else
                    [referImage setImage:noPhotoImg];
                [referImage setTag:kDefaultImage];
//                backgroundImg.image = [referDetail valueForKey:kReferImage];
//                self.imageSelectImage.image = [referDetail valueForKey:kReferImage];
            }
            
            
        }

    }
}


#pragma mark- Shorten URL Method
/*
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
    
    [_websiteShortenUrl setHidden:NO];
    _websiteShortenUrl.text = [NSString stringWithFormat:@"%@",returnData];
    
    NSLog(@"location.text: %@", _websiteShortenUrl.text);
}
*/

- (BOOL)setUserInteractionWithReferNowType:(ReferNowType)referNowType view:(UIView *)view text:(NSString *)text isNewRefer:(BOOL)isNewRefer
{
    BOOL isUserIntraction;
    switch (referNowType)
    {
        case ReferImage:
            break;
        case ReferLocations:
            if (text != nil && [text length] > 0 )
            {
//                isUserIntraction = NO;
                isUserIntraction = YES;
                
            }else
            {
                isUserIntraction = YES;
                
            }
            break;
        case ReferCategoryType:
            
            if (text != nil && [text length] > 0)
            {
                isUserIntraction = NO;
            }else
            {
                isUserIntraction = YES;
            }
            break;
        case ReferCategories:
            if (text != nil && [text length] > 0)
            {
                isUserIntraction = NO;
                
            }else
            {
                isUserIntraction = YES;
                
            }
            break;
        case ReferName:
            
            if (text != nil && [text length] > 0)
            {
                isUserIntraction = NO;
            }else
            {
                isUserIntraction = YES;
            }
            break;
        case ReferMessage:
            isUserIntraction = YES;
            break;
        case ReferFromWhere:
            if (text != nil && [text length] > 0)
            {
                isUserIntraction = NO;
                
            }else
            {
                isUserIntraction = YES;
                
            }
            break;
        case ReferAddress:
           if (text != nil && [text length] > 0)
            {
//                isUserIntraction = NO;
                isUserIntraction = YES;

            }else
            {
                isUserIntraction = YES;
            }
            break;
        case ReferPhoneAndWebSite:
            if (text != nil && [text length] > 0)
            {
                isUserIntraction = NO;
                
            }else
            { 
                isUserIntraction = (isNewRefer)?YES:NO;
                
            }
            
            break;
        default:
            break;
    }
    
    return isUserIntraction;
}

- (UIView *)createViewWithFrame:(CGRect)frame referNowType:(ReferNowType)referNowType text:(NSString *)text isNewRefer:(BOOL)isNewRefer
{
    /*
    if (isNewRefer == YES) {
        isnameFieldBlank = @"YES";
    }
    else if (isNewRefer == NO){
        isnameFieldBlank = @"NO";
    }
    */

    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setUserInteractionEnabled:(isNewRefer)?YES:[self setUserInteractionWithReferNowType:referNowType view:view text:text isNewRefer:isNewRefer]];
    view.tag = referNowType;
    return view;
    
}

- (void)imageWithDetail:(NSDictionary *)details
{
    
}
- (UITextView *)createTextViewWithFrame:(CGRect)frame ReferNowType:(ReferNowType)referNowType text:(NSString *)text isNewRefer:(BOOL)isNewRefer categoryType:(NSString *)categoryType
{
    UITextView *textView = [[UITextView alloc]initWithFrame:frame];
    textView.returnKeyType = UIReturnKeyDone;
    textView.text = ([text length] > 0)?text:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType];
    textView.delegate = self;
    textView.tag = referNowType;
    textView.textColor = ([text length] > 0)?[UIColor blackColor]:(!isNewRefer && referNowType != ReferMessage )?[UIColor lightGrayColor]:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0];
    textView.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    [textView setAlpha:(isNewRefer)?1.0:([text length] > 0 && !(textView.tag == ReferMessage))?0.3:1.0];
    return textView;
}

- (UITextField *)createTextFieldWithFrame:(CGRect)frame ReferNowType:(ReferNowType)referNowType text:(NSString *)text isNewRefer:(BOOL)isNewRefer categoryType:(NSString *)categoryType
{
    UITextField *textView = [[UITextField alloc]initWithFrame:frame];
    textView.returnKeyType = UIReturnKeyDone;
    textView.text = ([text length] > 0)?text:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType];
    textView.delegate = self;
    textView.tag = referNowType;
    textView.textColor = ([text length] > 0)?[UIColor blackColor]:(!isNewRefer && referNowType != ReferMessage )?[UIColor lightGrayColor]:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0];
    textView.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    [textView setAlpha:(isNewRefer)?1.0:([text length] > 0 && !(textView.tag == ReferMessage))?0.3:1.0];
    return textView;
}


- (UITextField *)createTextFiledWithFrame:(CGRect)frame ReferNowType:(ReferNowType)referNowType text:(NSString *)text isNewRefer:(BOOL)isNewRefer categoryType:(NSString *)categoryType
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:referNowType];
    [textField setDelegate:self];
    [textField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [textField setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [textField.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:0.0];
    [textField.layer setMasksToBounds:YES];
    [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setTextAlignment:(referNowType == ReferLocations)?NSTextAlignmentCenter:NSTextAlignmentLeft];
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
        if (!isNewRefer) {
            
            if (referNowType == Phone) {
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            }else if (referNowType == Website){
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            }else if (referNowType == ReferLocations){
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
            }else if (referNowType == ReferFromWhere){
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            }
            else if (referNowType == ReferEmailID){
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            }else{
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]}];
            }
            
        }else{
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType] attributes:@{NSForegroundColorAttributeName:(referNowType == ReferLocations)?[UIColor whiteColor]:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]}];
        }
        
    } else {
        
    }
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 4.0, textField.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftView;
    [textField setKeyboardType:[self setKeyBoardTypeWithReferNowType:referNowType]];
    [textField setPlaceholder:[self setPlaceHolderWithReferNowType:referNowType categoryType:categoryType]];
    [textField setText:text];
    
    if (referNowType == ReferName || referNowType == ReferLocations || referNowType == ReferFromWhere)
        textField.returnKeyType = UIReturnKeySearch;
    else
        textField.returnKeyType = UIReturnKeyDone;
    (isNewRefer)?[textField setAlpha:1.0]:([textField.text length] > 0 && textField.tag != ReferMessage)?[textField setAlpha:0.3]:(textField.tag == Website)?[textField setAlpha:1.0]:[textField setAlpha:1.0];
    return textField;
}

- (UIKeyboardType)setKeyBoardTypeWithReferNowType:(ReferNowType)referNowType
{
    UIKeyboardType keyboardType;
    switch (referNowType) {
        case Phone:
            keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            keyboardType = UIKeyboardTypeDefault;
            break;
    }
    return keyboardType;
}

- (NSString *)setPlaceHolderWithReferNowType:(ReferNowType)referNowType categoryType:(NSString *)categoryType
{
    NSString *string = nil;
    
    NSLog(@"ReferNow Type=== %u", referNowType);
    
    switch (referNowType) {
        case ReferMessage:
            string = kReferMessagePlaceHolder;
            break;
        case ReferNowcategory:
            string = @"Category";
            break;
        case ReferName:
            string = @"Enter Name";
            break;
        case ReferLocations:
            string = @"Select Location";
            break;
        case Phone:
            string = @"Phone (Optional)";
            break;
        case Website:
//            string = ([categoryType isEqualToString:kService])?@"Email (Optional)":@"Website (Optional)";
            string = ([categoryType isEqualToString:kService])?@"Website (Optional)":@"Website (Optional)";

            break;
        case ReferAddress:
            string = ([categoryType isEqualToString:kService] || [categoryType isEqualToString:kProduct])?@"Enter Address (Optional)":@"Enter Address";
            break;
        case ReferFromWhere:
            string = @"Where did you get this from? (Optional)";
            break;
        case ReferPhoneAndWebSite:
            string = kReferWebSitePlaceHolder;
            break;
        case ReferEmailID:
            string = @"Email ID (Optional)";
            break;
        default:
            break;
    }
    return NSLocalizedString(string, @"");
}

#pragma mark - TextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(TextFieldWithAnimation:textField:)])
    {
        [self.delegate TextFieldWithAnimation:YES textField:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(textFieldshouldChangeCharactersWithTextField:string:)])
        {
            [self.delegate textFieldshouldChangeCharactersWithTextField:textField string:string] ;
        }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(TextFieldWithAnimation:textField:)])
    {
        [self.delegate TextFieldWithAnimation:NO textField:textField];
    }
//    if ([[textField superview] superview].tag == ReferPhoneAndWebSite)
//    {
        if ([self.delegate respondsToSelector:@selector(phoneWesiteWithText:referRtype:)])
        {
            [self.delegate phoneWesiteWithText:textField.text referRtype:(int)textField.tag];
        }
    //}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(clearTextWithTextFiled:)])
    {
        [self.delegate clearTextWithTextFiled:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
     [textField resignFirstResponder];
    if ([textField superview].tag == ReferName || [textField superview].tag == ReferFromWhere || [textField superview].tag == ReferLocations)
    {
        if ([self.delegate respondsToSelector:@selector(placeSearchWithTextField:)])
        {
            [self.delegate placeSearchWithTextField:textField];
        }
    }
    return YES;
}

#pragma mark - TextView delegate
- (void)textViewDidEndEditing:(UITextView * _Nonnull)textView
{
    [textView resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(TextViewdWithAnimation:textView:)])
    {
        [self.delegate TextViewdWithAnimation:NO textView:textView];
    }
    [self enableClearButton:YES isClearText:NO referType:(ReferNowType)[textView superview].tag];
    if ([textView.text  isEqual: @""])
    {
        textView.text = ([textView superview].tag == ReferMessage)?kReferMessagePlaceHolder:(textView.tag == ReferPhoneAndWebSite)?kReferWebSitePlaceHolder:([prevPlaceHolder isEqualToString:@"Enter Address (Optional)"])?@"Enter Address (Optional)":kReferLocationPlaceHolder;
        prevPlaceHolder = nil;
        [textView setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]];
        textView.text = @"";
    }
    if ([self.delegate respondsToSelector:@selector(textWithMessageLocation:referType:)])
    {
        [self.delegate textWithMessageLocation:([textView.text isEqualToString:kReferMessagePlaceHolder] || [textView.text isEqualToString:kReferLocationPlaceHolder] || [textView.text isEqualToString:kReferWebSitePlaceHolder])?@"":textView.text referType:(ReferNowType)[textView superview].tag];
    }
}

- (void)textViewDidBeginEditing:(UITextView * _Nonnull)textView
{
    if ([self.delegate respondsToSelector:@selector(TextViewdWithAnimation:textView:)])
    {
        [self.delegate TextViewdWithAnimation:YES textView:textView];
    }
    ([textView.text length] > 0)?[self enableClearButton:NO isClearText:NO referType:[textView superview].tag]:[self enableClearButton:YES isClearText:NO referType:[textView superview].tag];
    if ([textView.text isEqualToString:kReferMessagePlaceHolder] || [textView.text isEqualToString:kReferLocationPlaceHolder] || [textView.text isEqualToString:@"Enter Address (Optional)"]|| [textView.text isEqualToString:kReferWebSitePlaceHolder])
    {
        prevPlaceHolder = textView.text;
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView * _Nonnull)textView
{
    if ([textView.text  isEqual: @""])
    {
        textView.text = ([textView superview].tag == ReferMessage)?kReferMessagePlaceHolder:(textView.tag == ReferPhoneAndWebSite)?kReferWebSitePlaceHolder:([prevPlaceHolder isEqualToString:@"Enter Address (Optional)"])?@"Enter Address (Optional)":kReferLocationPlaceHolder;
        prevPlaceHolder = nil;
        [textView setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]];
    }
    [self enableClearButton:YES isClearText:NO referType:[textView superview].tag];
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView * _Nonnull)textView
{
    if ([textView.text isEqualToString:kReferMessagePlaceHolder] || [textView.text isEqualToString:kReferLocationPlaceHolder] ||[textView.text isEqualToString:@"Enter Address (Optional)"] || [textView.text isEqualToString:kReferWebSitePlaceHolder])
    {
        prevPlaceHolder = textView.text;
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    [self enableClearButton:NO isClearText:NO referType:[textView superview].tag];
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        if ([textView.text isEqual: @""]) {
            textView.text = ([textView superview].tag == ReferMessage)?kReferMessagePlaceHolder:(textView.tag == ReferPhoneAndWebSite)?kReferWebSitePlaceHolder:([prevPlaceHolder isEqualToString:@"Enter Address (Optional)"])?@"Enter Address (Optional)":kReferLocationPlaceHolder;
            prevPlaceHolder = nil;
            [textView setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]];
            [self enableClearButton:YES isClearText:NO referType:[textView superview].tag];
        }
        return NO;
    }
    return YES;
}

- (void)enableClearButton:(BOOL)isEnable isClearText:(BOOL)isClearText referType:(ReferNowType)referType
{
    NSArray *subViews = [[[[self getTableView] subviews] objectAtIndex:0] subviews];
    if ([subViews count] > 0)
    {
        for (ReferNowTableViewCell  * cell in subViews)
        {
            NSArray *cellSubViews = [cell subviews];
            if ([cellSubViews count] > 0)
            {
                NSArray *subView = [[[cell subviews] objectAtIndex:0] subviews];
                if ([subView count] > 0)
                {
                    UIView *view = [subView objectAtIndex:0];
                    
                    if (referType == ReferMessage && view.tag == ReferMessage)
                    {
                        NSArray * subViews = [view subviews];
                        if (isClearText)
                            [(UITextView *)[subViews objectAtIndex:0] setText:@""];
                        [(UIView *)[subViews objectAtIndex:1] setHidden:isEnable];
                    }else if (referType == ReferAddress && view.tag == ReferAddress)
                    {
                        NSArray * subViews = [view subviews];
                        if (isClearText)
                            [(UITextView *)[subViews objectAtIndex:0] setText:@""];
                        [(UIView *)[subViews objectAtIndex:2] setHidden:isEnable];
                    }
                    
                }
            }
        }
    }
}

- (UITableView *)getTableView
{
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO)
    {
        view = [view superview];
    }
    UITableView *superView = (UITableView *)view;
    return superView;
}


#pragma mark - Button delegate
- (IBAction)nameBtnTpped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(serviceNameWithButton:)])
    {
        [self.delegate serviceNameWithButton:(UIButton *)sender];
    }
}
- (IBAction)locationBtnTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(enableLocationWithButton:)])
    {
        [self.delegate enableLocationWithButton:(UIButton *)sender];
    }
}

- (IBAction)addressBtnTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(locationSearchWithButton:)])
    {
        [self.delegate locationSearchWithButton:(UIButton *)sender];
    }
}

- (IBAction)categoryButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(categoriesWithButton:)])
    {
        [self.delegate categoriesWithButton:(UIButton *)sender];
    }
}

- (void)newImageGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    NSArray *subViews = [gestureRecognizer.view subviews];
    UIImageView *imageView = (UIImageView *)[subViews objectAtIndex:2];
    
    
    if ([[subViews objectAtIndex:2]isHidden]) {
        if ([self.delegate respondsToSelector:@selector(newImage)])
        {
            [self.delegate newImage];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(viewImageWithImage:defaultImage:)])
        {
            [self.delegate viewImageWithImage:(imageView.tag == kDefaultImage)?nil:imageView.image defaultImage:(imageView.tag == kDefaultImage)?YES:NO];
        }
    }
    
}
#pragma mark - GestureRecognizer
- (void)clearGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self enableClearButton:YES isClearText:YES referType:[gestureRecognizer.view superview].tag];
}

- (void)webGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(webLink)])
    {
        [self.delegate webLink];
    }
}

- (void)placeMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(placeWithSpuerView:)])
    {
        [self.delegate placeWithSpuerView:[gestureRecognizer.view superview]];
    }
}

- (void)productMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(productWithSpuerView:)])
    {
        [self.delegate productWithSpuerView:[gestureRecognizer.view superview]];
    }
}

- (void)serviceMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(serviceWithSpuerView:)])
    {
        [self.delegate serviceWithSpuerView:[gestureRecognizer.view superview]];
    }
}

- (void)webMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(webWithSpuerView:)])
    {
        [self.delegate webWithSpuerView:[gestureRecognizer.view superview]];
    }
}

- (void)mapGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushToMapPage)])
    {
        [self.delegate pushToMapPage];
    }
}

#pragma mark  -
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
