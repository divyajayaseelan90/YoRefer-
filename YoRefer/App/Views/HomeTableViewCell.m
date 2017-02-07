//
//  HomeTableViewCell.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "Carousel.h"
#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "UserManager.h"
#import "Constant.h"

#pragma mark - const

NSString * const kHomeCarouselReuseIdentifier   = @"carousel";
NSString * const kHomeReferAskReuseIdentifier   = @"referask";
NSString * const kHomeSegmentReuseIdentifier    = @"segment";
NSString * const kHomeReferReuseIdentifier      = @"referreuse";
NSString * const kHomeAskReuseIdentifier        = @"ask";
NSString * const kHomeSearchReuseIdentifier     = @"search";
NSString * const kHomeWhatsAppUser              = @"WhatsApp User";
NSString * const kHomeFacebookUsers             = @"facebook Users";
NSString * const kHomeTwitterUsers              = @"twitter Users";
NSUInteger const kScrollViewTag       = 2000;
CGFloat    const kSecounds            = 8.0;

static NSString *menuType;

#pragma mark - Interface

@interface HomeTableViewCell ()<UIScrollViewDelegate>

@property (nonatomic, readwrite) NSInteger currentPage;

@end

#pragma mark - Implementation

@implementation HomeTableViewCell

- (instancetype)initWithDelegate:(id<homeTableViewCell>)delegate response:(NSDictionary *)response homeType:(HomeType)homeType indexPath:(NSIndexPath *)indexPath
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifireWithHomeType:homeType indexPath:indexPath]];
    if (self)
    {
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self homeTableViewCellWithType:homeType response:response];
    }
    return self;
}


#pragma mark - ReuseIdentifier
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
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",(long)indexPath.row,kHomeReferReuseIdentifier];
            break;
        case ask:
            cellIdentification = [NSString stringWithFormat:@"%ld_%@",(long)indexPath.row,kHomeAskReuseIdentifier];
            break;
        case search:
            cellIdentification = kHomeSearchReuseIdentifier;
            break;
        default:
            break;
    }
    
    return cellIdentification;
    
}


- (void)homeTableViewCellWithType:(HomeType)homeType response:(NSDictionary *)response
{
    switch (homeType) {
        case carousel:
            [self carouselWithresponse:response];
            break;
        case referAsk:
            [self referAsk];
            break;
        case segment:
            [self segmentView];
            break;
        case refer:
            [self referFeedWithResponse:response];
            break;
        case ask:
            [self asksViewWithresponse:response];
            break;
        case search:
//            [self searchSegmentView];
//            [self searchReferFeedWithResponse:response];
            [self referFeedWithResponse:response];

            break;
        default:
            break;
    }
    
}

#pragma mark - carlose
- (void)carouselWithresponse:(NSDictionary *)response
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = [self bounds].size.width;
    CGFloat height = 142.0;
    UIView *carloseView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    carloseView.tag = carousel;
    [carloseView setBackgroundColor:[UIColor lightTextColor]];
    dispatch_async(dispatch_get_main_queue(),
                   ^{         [carloseView addSubview:[self createScrollViewWithFrame:carloseView.frame carousel:[response valueForKey:@"carousel"]]];
                   });
    
    self.currentPage = 0;
    width = 60.0;
    height = 60.0;
    xPos = carloseView.frame.size.width - 60.0;
    yPos = (carloseView.frame.size.height - height)/2;
    UIView *viewNext = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [carloseView addSubview:viewNext];
    self.currentPage ++;
    UITapGestureRecognizer *next = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nextImage:)];
    [viewNext addGestureRecognizer:next];
    
    [NSTimer scheduledTimerWithTimeInterval: kSecounds target: self
                                   selector: @selector(pushToNextCarousel:) userInfo: nil repeats: YES];
    [self.contentView addSubview:carloseView];

}

- (UIScrollView *)createScrollViewWithFrame:(CGRect)frame carousel:(NSMutableArray *)response
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    scrollView.tag = kScrollViewTag;
    int xPos = 0;
    CGFloat yPos = 0.0;
    for (int i = 0; i < [response count]; i++) {
        Carousel * carousel = (Carousel *)[response objectAtIndexedSubscript:i];
        if ([[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"]!= nil && [[[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"] isKindOfClass:[NSString class]])
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos,frame.size.width, frame.size.height)];
            view.tag = i;
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(carouselGestureTapped:)];
            [view addGestureRecognizer:gestureRecognizer];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0,view.frame.size.width, view.frame.size.height)];
            if ([[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"]!= nil && [[[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"] length] > 0)
                
            {
                NSArray *array = [[[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"] componentsSeparatedByString:@"/"];
                NSString *imageName = [array objectAtIndex:[array count]-1];
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                    
                }else{
                    [imageView setBackgroundColor:[UIColor colorWithRed:(159.0/255.0) green:(179.0/255.0) blue:(188.0/255.0) alpha:1.0]];
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[carousel valueForKey:@"_dp"] valueForKey:@"mediaId"]] imageView:imageView];
                }
            }
            //name
            CGFloat height = 20.0;
            UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(4.0, 2.0, view.frame.size.width, height)];
            [name setText:(carousel.name != nil && [carousel.name length] > 0)?carousel.name:@""];
            [name setBackgroundColor:[UIColor clearColor]];
            [name setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
            [name setTextColor:[UIColor whiteColor]];
            [name setTextAlignment:NSTextAlignmentLeft];
            //address
            height = 20.0;
            CGFloat padding = 4.0;
            UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(0.0, (view.frame.size.height - height), view.frame.size.width - padding, height)];
            [address setText:([carousel valueForKey:@"_locality"] != nil && [[carousel valueForKey:@"_locality"] length] > 0)?[carousel valueForKey:@"_locality"]:@""];
            [address setBackgroundColor:[UIColor clearColor]];
            [address setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
            [address setTextColor:[UIColor whiteColor]];
            [address setTextAlignment:NSTextAlignmentRight];
            [view addSubview:imageView];
            [view addSubview:address];
            [view addSubview:name];
            [scrollView addSubview:view];
            xPos = xPos + view.frame.size.width;
        }
    }
    scrollView.contentSize = CGSizeMake(xPos, scrollView.frame.size.height);
    scrollView.delegate  = self;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    return scrollView;
}
- (void)nextImage:(UITapGestureRecognizer *)gestureRecognizer
{
    CGRect frame = [(UIScrollView *)[self viewWithTag:kScrollViewTag] frame];
    frame.origin.x = frame.size.width * self.currentPage;
    frame.origin.y = 0;
    [(UIScrollView *)[self viewWithTag:kScrollViewTag] scrollRectToVisible:frame animated:YES];
    self.currentPage ++;
}

- (void)pushToNextCarousel:(NSTimer *)timer
{
    CGRect frame = [(UIScrollView *)[self viewWithTag:kScrollViewTag] frame];
    frame.origin.x = frame.size.width * self.currentPage;
    frame.origin.y = 0;
    [(UIScrollView *)[self viewWithTag:kScrollViewTag] scrollRectToVisible:frame animated:(self.currentPage == 0)?NO:YES];
    self.currentPage ++;
    
    if (self.currentPage  == [[(UIScrollView *)[self viewWithTag:kScrollViewTag] subviews] count])
    {
        self.currentPage = 0;
    }
}

#pragma mark - ReferAsk
- (void)referAsk
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 148.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = referAsk;
    [view setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:view];
    
    xPos = 10.0;
    yPos = 0.0;
    width = frame.size.width  - (xPos * 2);
    height = 48.0;
    UIView *referAsk = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view addSubview:referAsk];
    xPos = 0.0;
    height = referAsk.frame.size.height - 8.0;
    width = roundf(referAsk.frame.size.width / 2) - 2.0;
    yPos =  roundf((referAsk.frame.size.height - height)/2);
    //ReferNow
    UIView *referNowView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNowView setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [referNowView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [referNowView.layer setBorderWidth:0.8];
    [referNowView.layer setCornerRadius:20.0];
    [referNowView.layer setMasksToBounds:YES];
    UITapGestureRecognizer *referNowGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referNowTapped:)];
    [referNowView addGestureRecognizer:referNowGesture];
    [referAsk addSubview:referNowView];
    
    //Ask Now
    xPos = referNowView.frame.size.width + 6.0;
    UIView *askNowView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askNowView setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [askNowView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [askNowView.layer setBorderWidth:0.8];
    [askNowView.layer setCornerRadius:20.0];
    [askNowView.layer setMasksToBounds:YES];
    UITapGestureRecognizer *askNowViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(askGestureTapped:)];
    [askNowView addGestureRecognizer:askNowViewGesture];
    [referAsk addSubview:askNowView];
    
    //referimage
    height = 26.0;
    width = 26.0;
    yPos = roundf((referNowView.frame.size.height - height)/2);
    xPos = roundf((referNowView.frame.size.width / 2 - width)/2) - ((frame.size.width > 320)?6.0:14.0);
    UIImageView *referImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referImageView setImage:[UIImage imageNamed:@"icon_home_refer.png"]];
    [referNowView addSubview:referImageView];
    //ask image
    UIImageView *askImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askImageView setImage:[UIImage imageNamed:@"icon_home_ask.png"]];
    [askNowView addSubview:askImageView];
    
    //label
    width = 80.0;
    height = 42.0;
    yPos = 0.0;
    xPos = roundf((referNowView.frame.size.width  - width)/ 2) + 8.0;
    UILabel *referLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referLbl setText:@"Refer Now"];
    [referLbl setTextColor:[UIColor whiteColor]];
    [referLbl setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [referNowView addSubview:referLbl];
    UILabel *askLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askLbl setText:@"Ask Now"];
    [askLbl setTextColor:[UIColor whiteColor]];
    [askLbl setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [askNowView addSubview:askLbl];
    
    //List of Refers
    xPos = 10.0;
    yPos = referAsk.frame.size.height;
    height = 48.0;
    width = frame.size.width - (xPos * 3);
    UIView *refers = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [refers setTag:23200];
    [refers setHidden:YES];
    [refers setBackgroundColor:[UIColor clearColor]];
    [view addSubview:refers];
    
    NSArray *refersArray = [[NSArray alloc]initWithObjects:@"Category",@"Contact",@"Photo",@"Location",@"Web",@"New",nil];
    __block float xPosBlock = 0.0;
    yPos = 0.0;
    width = refers.frame.size.width / 6;
    height = refers.frame.size.height;
    [refersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop)
    {
        CGFloat blockXPos,blockYPos,blockWidth,blockHeight;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPosBlock, yPos, width, height)];
        [view setTag:idx];
        UITapGestureRecognizer *menuGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuGestureTapped:)];
        [view addGestureRecognizer:menuGesture];
        [view setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [view.layer setCornerRadius:8.0];
        [view.layer setMasksToBounds:YES];
        [view.layer setBorderColor:[UIColor whiteColor].CGColor];
        [view.layer setBorderWidth:0.8];
        [refers addSubview:view];
        //label
        blockXPos = 0.0;
        blockWidth = view.frame.size.width;
        blockHeight = 20.0;
        blockYPos = view.frame.size.height - blockHeight;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(blockXPos, blockYPos, blockWidth, blockHeight)];
        [label setText:obj];
        [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:9.0]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [view addSubview:label];
        CGSize size = [self referSizeWithIndex:idx];
        blockWidth = size.width;
        blockHeight = size.height;
        blockXPos = roundf((view.frame.size.width - blockWidth)/2);
        blockYPos = roundf((view.frame.size.height - blockHeight)/2) - 6.0;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(blockXPos, blockYPos, blockWidth, blockHeight)];
        [imageView setImage:[self refersImageWithIndex:idx]];
        [view addSubview:imageView];
        xPosBlock = xPosBlock + view.frame.size.width + 2.0;
    }];
    
    
    /* //Title
    width = view.frame.size.width;
    xPos = round((frame.size.width - width)/2);
    height = 30.0;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [title setText:[NSString stringWithFormat:@"Welcome %@!",([[UserManager shareUserManager] name] !=nil && [[[UserManager shareUserManager] name] length] >0)?[[[UserManager shareUserManager] name] capitalizedString]:@""]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[[Configuration shareConfiguration]yoReferBoldFontWithSize:19.0]];
    [title setTextColor:[UIColor whiteColor]];
    [view addSubview:title];
    
    //top line
    xPos = 0.0;
    yPos = title.frame.size.height;
    width = view.frame.size.width;
    height = 1.0;
    UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    topline.backgroundColor = [UIColor whiteColor];
    [view addSubview:topline];
    
    //refer Label
    xPos = 0.0;
    yPos = topline.frame.origin.y + topline.frame.size.height;
    width = view.frame.size.width * 0.75;
    height = 30.0;
    UILabel *referLabel = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referLabel setText:@"Refer"];
    referLabel.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0];
    [referLabel setTextAlignment:NSTextAlignmentCenter];
    [referLabel setFont:[[Configuration shareConfiguration]yoReferBoldFontWithSize:16.0]];
    [referLabel setTextColor:[UIColor whiteColor]];
    [view addSubview:referLabel];
    
    //middle line
    xPos = referLabel.frame.size.width;
    yPos = topline.frame.origin.y + topline.frame.size.height;
    width = 1.0;
    height = view.frame.size.height - yPos;
    UIView *middleline = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    middleline.backgroundColor = [UIColor whiteColor];
    [view addSubview:middleline];
    
    xPos = middleline.frame.origin.x + middleline.frame.size.width;
    yPos = topline.frame.origin.y + topline.frame.size.height;
    width = view.frame.size.width - xPos;
    height = 30.0;
    UILabel *askLabel = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askLabel setText:@"Ask"];
    [askLabel setTextAlignment:NSTextAlignmentCenter];
    [askLabel setFont:[[Configuration shareConfiguration]yoReferBoldFontWithSize:16.0]];
    [askLabel setTextColor:[UIColor whiteColor]];
    askLabel.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0];
    [view addSubview:askLabel];

    //bottom line
    xPos = 0.0;
    yPos = referLabel.frame.origin.y + referLabel.frame.size.height;
    width = view.frame.size.width;
    height = 1.0;
    UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    bottomline.backgroundColor = [UIColor whiteColor];
    [view addSubview:bottomline];

    //Refer Menu View
    xPos = 0.0;
    yPos = bottomline.frame.origin.y + bottomline.frame.size.height;
    width = referLabel.frame.size.width;
    height = view.frame.size.height - yPos;
    UIView *refer = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    refer.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0];
    [view addSubview:refer];
    
    //menus
    CGFloat y = 0.0;
    for (int i = 0; i < 2; i++) {
        CGFloat x = 0.0;
        for (int j = 0; j < 3; j++) {
            NSString *title;
            UIImage *img;
            int index = j + i * 3;
            switch (index) {
                case 0:
                    title = @"Category";
                    img = [UIImage imageNamed:@"icon_home_category.png"];
                    break;
                case 1:
                    title = @"Contact";
                    img = [UIImage imageNamed:@"icon_home_contact.png"];
                    break;
                case 2:
                    title = @"Photo";
                    img = [UIImage imageNamed:@"icon_home_camera.png"];
                    break;
                case 3:
                    title = @"Location";
                    img = [UIImage imageNamed:@"icon_home_location.png"];
                    break;
                case 4:
                    title = @"Web";
                    img = [UIImage imageNamed:@"icon_home_web.png"];
                    break;
                case 5:
                    title = @"New";
                    img = [UIImage imageNamed:@"icon_home_new.png"];
                    break;
                default:
                    break;
            }

            
            xPos = x;
            yPos = y;
            width = refer.frame.size.width / 3.0;
            height = refer.frame.size.height / 2.0;
            UIView *menuview = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            menuview.tag = index;
            [refer addSubview:menuview];
            
            UITapGestureRecognizer *menuGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuGestureTapped:)];
            [menuview addGestureRecognizer:menuGesture];

            if ([title isEqualToString:@"Photo"]) {
                width = 36.0;
                height = 30.0;
            }
            else if ([title isEqualToString:@"Location"])
            {
                width = 20.0;
                height = 30.0;
            }
            else if ([title isEqualToString:@"Web"])
            {
                width = 28.0;
                height = 30.0;
            }
            else if ([title isEqualToString:@"New"])
            {
                width = 29.0;
                height = 30.0;
            }

            else
            {
                width = 30.0;
                height = 30.0;
            }
            
            xPos = (menuview.frame.size.width - width) / 2.0;
            yPos = 5.0;
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            [imgView setImage:img];
            [menuview addSubview:imgView];
            
            yPos = imgView.frame.origin.y + imgView.frame.size.height;
            width = 60.0;
            height = menuview.frame.size.height - yPos;
            xPos = (menuview.frame.size.width - width) / 2.0;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
            [label setText:title];
            label.backgroundColor = [UIColor clearColor];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[[Configuration shareConfiguration]yoReferBoldFontWithSize:12.0]];
            [label setTextColor:[UIColor whiteColor]];
            label.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0];
            [menuview addSubview:label];

            x = x + menuview.frame.size.width;
        }
        y = y + refer.frame.size.height / 2.0;
    }
    
    xPos = askLabel.frame.origin.x;
    yPos = bottomline.frame.origin.y + bottomline.frame.size.height;
    width = view.frame.size.width - xPos;
    height = view.frame.size.height - yPos;
    UIView *ask = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    ask.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0];
    ask.tag = 6;
    [view addSubview:ask];
    
     UITapGestureRecognizer *askGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuGestureTapped:)];
    [ask addGestureRecognizer:askGesture];
    
    width = 40.0;
    height = 40.0;
    xPos = (ask.frame.size.width - width) / 2.0;
    yPos = (ask.frame.size.height - height) / 2.0;
    UIImageView *askImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [askImg setImage:homeAsk];
    [ask addSubview:askImg];*/
}

- (CGSize)referSizeWithIndex:(NSUInteger)index
{
    CGSize size;
    switch (index) {
        case 0:
            size = CGSizeMake(30.0, 30.0);
            break;
        case 1:
            size = CGSizeMake(30.0, 30.0);
            break;
        case 2:
            size = CGSizeMake(36.0, 30.0);
            break;
        case 3:
            size = CGSizeMake(20.0, 30.0);
            break;
        case 4:
            size = CGSizeMake(28.0, 30.0);
            break;
        case 5:
            size = CGSizeMake(29.0, 30.0);
            break;
        default:
            break;
    }
    return size;
}


- (UIImage *)refersImageWithIndex:(NSUInteger)index
{
    UIImage *image = nil;
    switch (index) {
        case 0:
            image = [UIImage imageNamed:@"icon_home_category.png"];
            break;
        case 1:
            image = [UIImage imageNamed:@"icon_home_contact.png"];
            break;
        case 2:
            image = [UIImage imageNamed:@"icon_home_camera.png"];
            break;
        case 3:
            image = [UIImage imageNamed:@"icon_home_location.png"];
            break;
        case 4:
            image = [UIImage imageNamed:@"icon_home_web.png"];
            break;
        case 5:
            image = [UIImage imageNamed:@"icon_home_new.png"];
            break;
        default:
            break;
    }
    return image;
}

#pragma mark - Segment
- (void)segmentView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 10.0;
    CGFloat Ypos = 5.0;
    CGFloat width = frame.size.width - 20.0;
    CGFloat height = 40.0;
    UIView *segmentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [segmentView setTag:segment];
    [segmentView setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    [segmentView.layer setCornerRadius:20.0];
    [segmentView.layer setMasksToBounds:YES];
    [self.contentView addSubview:segmentView];
    //Refers
    xPos = 2.0;
    Ypos = 2.0;
    width = round(segmentView.frame.size.width /2) - 3.0;
    height = segmentView.frame.size.height - 4.0;
    UILabel *refer = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [refer setText:@"View Refers"];
    [refer setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [refer setTextAlignment:NSTextAlignmentCenter];
    [refer.layer setCornerRadius:18.0];
    [refer.layer setMasksToBounds:YES];
    [refer setUserInteractionEnabled:YES];
    UITapGestureRecognizer *referGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refer:)];
    [refer addGestureRecognizer:referGestureRecognizer];
    [segmentView addSubview:refer];
    //Asks
    xPos = refer.frame.size.width + 4.0;
    UILabel *ask = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [ask setText:@"View Asks"];
    [ask setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [ask setTextAlignment:NSTextAlignmentCenter];
    [ask.layer setCornerRadius:18.0];
    [ask.layer setMasksToBounds:YES];
    [ask setUserInteractionEnabled:YES];
    UITapGestureRecognizer *askGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ask:)];
    [ask addGestureRecognizer:askGestureRecognizer];
    [segmentView addSubview:ask];
    if ([menuType isEqualToString:kAsk])
    {
        [refer setBackgroundColor:[UIColor clearColor]];
        [refer setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        [ask setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [ask setTextColor:[UIColor whiteColor]];
        
    }else
    {
        [ask setBackgroundColor:[UIColor clearColor]];
        [ask setTextColor:[UIColor colorWithRed:(163.0/255.0) green:(153.0/255.0) blue:(136.0/255.0) alpha:1.0]];
        [refer setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [refer setTextColor:[UIColor whiteColor]];
    }
}

- (void)searchSegmentView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 10.0;
    CGFloat Ypos = 5.0;
    CGFloat width = frame.size.width - 20.0;
    CGFloat height = 40.0;
    UIView *segmentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [segmentView setTag:segment];
    [segmentView setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    [segmentView.layer setCornerRadius:20.0];
    [segmentView.layer setMasksToBounds:YES];
    [self.contentView addSubview:segmentView];
    //Refers
    xPos = 2.0;
    Ypos = 2.0;
    width = round(segmentView.frame.size.width /2) - 70.0;
    height = segmentView.frame.size.height - 4.0;
    UILabel *refer = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [refer setText:@"View Refers"];
    [refer setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [refer setTextAlignment:NSTextAlignmentCenter];
    [refer.layer setCornerRadius:18.0];
    [refer.layer setMasksToBounds:YES];
    [refer setUserInteractionEnabled:YES];
    UITapGestureRecognizer *referGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refer:)];
    [refer addGestureRecognizer:referGestureRecognizer];
    [segmentView addSubview:refer];
    //Asks
    xPos = refer.frame.size.width + 7.0;
    UILabel *ask = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [ask setText:@"View Asks"];
    [ask setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [ask setTextAlignment:NSTextAlignmentCenter];
    [ask.layer setCornerRadius:18.0];
    [ask.layer setMasksToBounds:YES];
    [ask setUserInteractionEnabled:YES];
    UITapGestureRecognizer *askGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ask:)];
    [ask addGestureRecognizer:askGestureRecognizer];
    [segmentView addSubview:ask];
    //Entity
    xPos = refer.frame.size.width + 138.0;
    UILabel *entity = [[UILabel alloc]initWithFrame:CGRectMake(xPos, Ypos, width, height)];
    [entity setText:@"Entities"];
    [entity setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [entity setTextAlignment:NSTextAlignmentCenter];
    [entity.layer setCornerRadius:18.0];
    [entity.layer setMasksToBounds:YES];
    [entity setUserInteractionEnabled:YES];
    UITapGestureRecognizer *entityGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ask:)];
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

#pragma mark - Scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.currentPage  == [[scrollView subviews] count])
    {
        self.currentPage = 0;
    }
}
#pragma mark - Refer feeds
- (void)referFeedWithResponse:(NSDictionary *)response
{
    Home *home = (Home *)response;
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width - 12.0;
    CGFloat height = 414.0;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [contentView setTag:refer];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:5.0];
    [contentView.layer setMasksToBounds:YES];
    [self.contentView addSubview:contentView];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentGestureTapped:)];
    [contentView addGestureRecognizer:gestureRecognizer];
    //profile
    xPos = 0.0;
    yPos = 0.0;
    height = 95.0;
    UIView *profileView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [profileView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:profileView];
    //profile image
    width = 55.0;
    height = 55.0;
    xPos = 6.0;
    yPos = 10.0;
    UIImageView *selfProfileImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if ([home.from objectForKey:kDp] != nil && [[home.from objectForKey:kDp] length] > 0)
    {
        NSArray *arraySelfImage = [[home.from objectForKey:kDp] componentsSeparatedByString:@"/"];
        NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:selfProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        }else if ([arraySelfImage count] > 1){
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[home.from objectForKey:kDp]] imageView:selfProfileImg];
        }else
        {
            [selfProfileImg setImage:profilePic];
        }
    }else
    {
        [selfProfileImg setImage:profilePic];
    }
    [selfProfileImg.layer setCornerRadius:27.0];
    [selfProfileImg.layer setMasksToBounds:YES];
    [profileView addSubview:selfProfileImg];
    selfProfileImg.userInteractionEnabled = YES;
    //profile name
    width = 60.0;
    height = 30.0;
    xPos = profileView.frame.origin.x;
    yPos = selfProfileImg.frame.size.height + selfProfileImg.frame.origin.y;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *userName = [home.from objectForKey:kName];
    [label setText:NSLocalizedString(userName, @"")];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [label setNumberOfLines:2];
    [profileView addSubview:label];
    //self gesture view
    width = 64.0;
    height = profileView.frame.size.height;
    xPos = 0.0;
    yPos = profileView.frame.origin.y;
    UIView *gestureView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [gestureView setBackgroundColor:[UIColor clearColor]];
    [profileView addSubview:gestureView];
    UITapGestureRecognizer *selfProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfProfileGestureTapped:)];
    [gestureView addGestureRecognizer:selfProfileGesture];
    //right arrow
    width = 15.0;
    height = 15.0;
    xPos = selfProfileImg.frame.size.width + 24.0;
    yPos = round(selfProfileImg.frame.size.height /2) + 4.0;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [rightArrow setImage:homeArrow];
    [profileView addSubview:rightArrow];
    //refer image
    width = 55.0;
    height = 55.0;
    xPos = selfProfileImg.frame.size.width + rightArrow.frame.size.width + 40.0;
    yPos = 10.0;
    UIImageView *guestReferProfileImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [profileView addSubview:guestReferProfileImg];
    [guestReferProfileImg.layer setCornerRadius:27.0];
    [guestReferProfileImg.layer setMasksToBounds:YES];
    guestReferProfileImg.userInteractionEnabled = YES;
    //profile name
    width = 70.0;
    height = 30.0;
    xPos = guestReferProfileImg.frame.origin.x - 5.0;
    yPos = guestReferProfileImg.frame.size.height + guestReferProfileImg.frame.origin.y;
    UILabel *referLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *profileName;
    UIImage *image;
    if ([home.channel isEqualToString:kWhatsapp])
    {
        profileName = kHomeWhatsAppUser;
        image = whatsappImg;
    }
    else if ([home.channel isEqualToString:kFacebook])
    {
        profileName = kHomeFacebookUsers;
        image = facebookImg;
    }
    else if ([home.channel isEqualToString:kTwitter])
    {
        profileName = kHomeTwitterUsers;
        image = twitterImg;
    }
    else{
        profileName = [[[home.toUser objectAtIndex:0] objectForKey:@"name"] capitalizedString];
    }
    [referLbl setTextAlignment:NSTextAlignmentCenter];
    [referLbl setBackgroundColor:[UIColor clearColor]];
    [referLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [referLbl setNumberOfLines:2];
    [profileView addSubview:referLbl];
    //refer gesture view
    width = 62.0;
    height = profileView.frame.size.height;
    xPos = selfProfileImg.frame.size.width + rightArrow.frame.size.width + 38.0;
    yPos = profileView.frame.origin.y;
    UIView *refergestureView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [refergestureView setBackgroundColor:[UIColor clearColor]];
    [profileView addSubview:refergestureView];
    UITapGestureRecognizer *guestProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guestProfileGestureTapped:)];
    [refergestureView addGestureRecognizer:guestProfileGesture];
    if ([home.toUser count] > 0)
    {
        width = 20.0;
        height = 20.0;
        xPos = (guestReferProfileImg.frame.origin.x + guestReferProfileImg.frame.size.width) - width;
        yPos = 2.0;
        UILabel *notificationLbl =[[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[home.toUser count]];
        [notificationLbl setText:NSLocalizedString(count, @"")];
        profileName = ([home.toUser count] >1)?[NSString stringWithFormat:@"%@ and others",profileName]:[NSString stringWithFormat:@"%@",profileName];
        [referLbl setText:NSLocalizedString(profileName, @"")];
        [notificationLbl setTextAlignment:NSTextAlignmentCenter];
        [notificationLbl setTextColor:[UIColor whiteColor]];
        [notificationLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [notificationLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [notificationLbl.layer setCornerRadius:10.0];
        [notificationLbl.layer setMasksToBounds:YES];
        [profileView addSubview:notificationLbl];
        [notificationLbl setHidden:([home.toUser count] > 1)?NO:YES];
        //right image
        if ([home.toUser count] > 0)
        {
            if ([[home.toUser objectAtIndex:0] objectForKey:kDp] != nil && [[[home.toUser objectAtIndex:0] objectForKey:kDp] length] > 0)
            {
                NSArray *arraySelfImage = [[[home.toUser objectAtIndex:0] objectForKey:kDp] componentsSeparatedByString:@"/"];
                NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:guestReferProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                }else if ([arraySelfImage count] > 1){
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[home.toUser objectAtIndex:0] objectForKey:kDp]] imageView:guestReferProfileImg];
                }else
                {
                    if (image !=nil)
                    {
                        guestReferProfileImg.image = image;
                        
                    }else
                    {
                        [guestReferProfileImg setImage:([home.toUser count] > 1)?groupPic:profilePic];
                    }

                }
            }else
            {
                if (image !=nil)
                {
                    guestReferProfileImg.image = image;
                    
                }else
                {
                    [guestReferProfileImg setImage:([home.toUser count] > 1)?groupPic:profilePic];
                }
            }
        }
    }else
    {
        [guestReferProfileImg setImage:profilePic];
        [referLbl setText:NSLocalizedString(profileName, @"")];
    }
    //UIlabel
    width = profileView.frame.size.width - (guestReferProfileImg.frame.origin.x + selfProfileImg.frame.size.width);
    height = 20.0;
    xPos = guestReferProfileImg.frame.origin.x + guestReferProfileImg.frame.size.width + 6.0;
    yPos = round((guestReferProfileImg.frame.size.height - height)/2) - 3.0;
    UILabel *headerInfo = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //TODO:Need to change
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE d MMM yyyy, hh:mm a "];
    [inputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[home.referredAt doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    NSString *category = [home.entity objectForKey:kCategory];
    NSString *name = ([[home.entity valueForKey:kType] isEqualToString:kProduct])?[home.entity valueForKey:kName] :[home.entity valueForKey:kName];
    NSString *header = [NSString stringWithFormat:@"%@\n%@\n%@",time,category,name];
    [headerInfo setFont:([self bounds].size.width > 320 ?[[Configuration shareConfiguration] yoReferFontWithSize:12.0] :[[Configuration shareConfiguration] yoReferFontWithSize:10.0])];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
    NSRange selectedRange = NSMakeRange(time.length + category.length + 2, name.length);
    [string beginEditing];
    // [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName
                   value:([self bounds].size.width > 320 ?[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] :[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0])
                   range:selectedRange];
    [string endEditing];
    [headerInfo setAttributedText:string];
    [headerInfo setTextColor:[UIColor blackColor]];
    [headerInfo setNumberOfLines:0];
    [headerInfo sizeToFit];
    [profileView addSubview:headerInfo];
    //refer Image
    xPos = 0.0;
    yPos = profileView.frame.size.height;
    height = 130.0;
    width = frame.size.width - 20.0;
    UIView *referView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:referView];
    //background image
    xPos = 4.0;
    yPos = 0.0;
    width = referView.frame.size.width;
    height = referView.frame.size.height - 6.0;
    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [backgroundImg setTag:340000];
    [backgroundImg.layer setCornerRadius:5.0];
    [backgroundImg.layer setMasksToBounds:YES];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = backgroundImg.bounds;
    [backgroundImg addSubview:visualEffectView];
    [referView addSubview:backgroundImg];
    height = 124.0;
    yPos = 0.0;
    width = 140.0;
    xPos = (frame.size.width - width)/2;
    UIImageView *referImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSArray *array = [[NSString stringWithFormat:@"%@",home.mediaId] componentsSeparatedByString:@"/"];
    NSString *imageName = [array objectAtIndex:[array count]-1];
    [referView addSubview:referImg];
    //refer button
    width = 100.0;
    height = 30.0;
    xPos = round((profileView.frame.size.width - width)/2) + 6.0;
    yPos = (referImg.frame.size.height - height) + (height - 21.0);
    UIButton *referNow = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNow addTarget:self action:@selector(referButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [referNow setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [referNow setTitle:@"Refer Now" forState:UIControlStateNormal];
    [referNow.layer setBorderWidth:2.0];
    [referNow.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNow.layer setCornerRadius:15.0];
    [referNow.layer setMasksToBounds:YES];
    [referNow.titleLabel setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNow.bounds];
    referNow.layer.masksToBounds = NO;
    referNow.layer.shadowColor = [UIColor grayColor].CGColor;
    referNow.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNow.layer.shadowOpacity = 0.3f;
    referNow.layer.shadowPath = shadowPath.CGPath;
    [referView addSubview:referNow];
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:referImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:backgroundImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
    }else{
        if (home.mediaId != nil && [home.mediaId length] > 0) {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",home.mediaId]] imageView:referImg];
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",home.mediaId]] imageView:backgroundImg];
        }else{
            if ([home.type isEqualToString:kPlace])
            {
                referImg.image = placeImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 8.0, 90.0, 100.0)];
                backgroundImg.image = placeImg;
                [referNow setFrame:CGRectMake(referNow.frame.origin.x, referNow.frame.origin.y, referNow.frame.size.width, referNow.frame.size.height)];
            }
            else  if ([home.type isEqualToString:kProduct])
            {
                referImg.image = productImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 14.0, 90.0, 100.0)];
                backgroundImg.image = productImg;
            }else  if ([home.type isEqualToString:kWeb])
            {
                referImg.image = webLinkImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 22.0, 78.0, 80.0)];
                backgroundImg.image = webLinkImg;
            }
            
            else  if ([home.type isEqualToString:kService])
            {
                referImg.image = serviceImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 12.0, 80.0, 90.0)];
                backgroundImg.image = serviceImg;
            }
            else
                referImg.image = noPhotoImg;
        }
    }
    //title
    xPos = 10.0;
    yPos = referNow.frame.size.height + referNow.frame.origin.y;
    width = referView.frame.size.width - 12.0;
    height = 100.0;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *note = home.note;
    [title setText:NSLocalizedString(note, @"")];
   // [title setBackgroundColor:[UIColor greenColor]];
    [title setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [title setNumberOfLines:3];
    [title sizeToFit];
    CGRect newFrame = title.frame;
    newFrame.size = CGSizeMake(width, title.frame.size.height);
    title.frame = newFrame;
    [referView addSubview:title];
    //Address
    height = 158.0;
    width = contentView.frame.size.width ;
    xPos = 0.0;
    yPos = contentView.frame.size.height - (height - 26.0);//referView.frame.size.height + referView.frame.origin.y + 10.0;
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:addressView];
    //image
    xPos = 6.0;
    yPos = 4.0;
    width = addressView.frame.size.width - 12.0;
    height = 66.0;
    UIView *referImgView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referImgView setBackgroundColor:[UIColor clearColor]];
    [referImgView.layer setBorderWidth:0.5];
    [referImgView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [addressView addSubview:referImgView];
    //referImage
    xPos = 0.0;
    yPos = 16.0;
    width = 40.0;
    height = 40.0;//referImgView.frame.size.height;
    UIImageView *referSmallImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referImgView addSubview:referSmallImg];
    //map image
    xPos = referImgView.frame.size.width - 46.0;
    UIImageView *mapImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mapImg setImage:([[home.entity valueForKey:kType]isEqualToString:kWeb])?webImage:mapImage];
    [referImgView addSubview:mapImg];
    [mapImg setUserInteractionEnabled:YES];
    UITapGestureRecognizer *mapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapGestureTapped:)];
    [mapImg addGestureRecognizer:mapGesture];
    //title and address
    width = referImgView.frame.size.width - (mapImg.frame.size.width + 10.0);
    height = referImgView.frame.size.height - 4.0;
    yPos = 4.0;
    xPos = 5.0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
    
    NSString *categoryName = [NSString stringWithFormat:@"%@\n",([[home.entity valueForKey:kType] isEqualToString:kProduct])?[[[home.entity valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kName]:[home.entity valueForKey:kName]];
    if (categoryName != nil && [categoryName length] > 0)
    {
        NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:categoryName];
        [titleStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] range:NSMakeRange(0, titleStr.length)];
        [attributedString appendAttributedString:titleStr];
    }
    NSString *categoryAddress;
    if ([[home.entity valueForKey:kType] isEqualToString:kWeb])
    {
        categoryAddress = [home.entity valueForKey:kWebSite];
        
    }else if ([home.type isEqualToString:kProduct])
    {
        categoryAddress = [[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality];
    }else
    {
        categoryAddress = [home.entity objectForKey:kLocality];
    }
    if (categoryAddress != nil && [categoryAddress length] > 0)
    {
        NSMutableAttributedString *addressStr = [[NSMutableAttributedString alloc]initWithString:categoryAddress];
        [addressStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, addressStr.length)];
        [addressStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferFontWithSize:10.5]:[[Configuration shareConfiguration] yoReferFontWithSize:12.0] range:NSMakeRange(0, addressStr.length)];
        [attributedString appendAttributedString:addressStr];
    }
    UILabel *titleAddressLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [titleAddressLbl setBackgroundColor:[UIColor clearColor]];
    [titleAddressLbl setAttributedText:attributedString];
    [titleAddressLbl setNumberOfLines:4];
    [titleAddressLbl sizeToFit];
    [referImgView addSubview:titleAddressLbl];
    //line
    xPos = 0.0;
    yPos = referImgView.frame.size.height + 10.0;
    width = contentView.frame.size.width;
    height = 0.5;
    UIView *upperLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [upperLine setBackgroundColor:[UIColor colorWithRed:(162.0/255.0) green:(162.0/255.0) blue:(162.0/255.0) alpha:1.0]];
    xPos = 8.0;
    yPos = upperLine.frame.size.height + upperLine.frame.origin.y - 2.0;
    width = frame.size.width - xPos * 2;
    height = 30.0;
    UILabel *pointLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *points = [NSString stringWithFormat:@"Earn %@ Point",[home.entity valueForKey:@"points"]];
    [pointLbl setText:NSLocalizedString(points, @"")];
    [pointLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [pointLbl setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [pointLbl setTextAlignment:NSTextAlignmentCenter];
    [addressView addSubview:pointLbl];
    //line
    xPos = 6.0;
    yPos = pointLbl.frame.size.height + pointLbl.frame.origin.y;
    width = contentView.frame.size.width - xPos * 2;
    height = 0.5;
    UIView *lowerLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [lowerLine setBackgroundColor:[UIColor colorWithRed:(162.0/255.0) green:(162.0/255.0) blue:(162.0/255.0) alpha:1.0]];
    [addressView addSubview:lowerLine];
    //refer
    width = 68.0;
    height = 20.0;
    xPos = frame.size.width - width;
    yPos = lowerLine.frame.origin.y + lowerLine.frame.size.height + 4.0;
    UILabel *refersLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *referCount = [NSString stringWithFormat:@"%@ Refers",[home.entity  objectForKey:@"referCount"]];
    [refersLbl setText:NSLocalizedString(referCount, @"")];
    [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [refersLbl setTextColor:[UIColor grayColor]];
    [refersLbl setUserInteractionEnabled:YES];
    [addressView addSubview:refersLbl];
    UITapGestureRecognizer *referalGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ReferalGestureTapped:)];
    [refersLbl addGestureRecognizer:referalGestureRecognizer];
}

- (void)searchReferFeedWithResponse:(NSDictionary *)response
{
    Home *home = (Home *)response;
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 60.0;
    CGFloat width = frame.size.width - 12.0;
    CGFloat height = 414.0;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [contentView setTag:refer];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:5.0];
    [contentView.layer setMasksToBounds:YES];
    [self.contentView addSubview:contentView];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentGestureTapped:)];
    [contentView addGestureRecognizer:gestureRecognizer];
    //profile
    xPos = 0.0;
    yPos = 0.0;
    height = 95.0;
    UIView *profileView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [profileView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:profileView];
    //profile image
    width = 55.0;
    height = 55.0;
    xPos = 6.0;
    yPos = 10.0;
    UIImageView *selfProfileImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if ([home.from objectForKey:kDp] != nil && [[home.from objectForKey:kDp] length] > 0)
    {
        NSArray *arraySelfImage = [[home.from objectForKey:kDp] componentsSeparatedByString:@"/"];
        NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:selfProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        }else if ([arraySelfImage count] > 1){
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[home.from objectForKey:kDp]] imageView:selfProfileImg];
        }else
        {
            [selfProfileImg setImage:profilePic];
        }
    }else
    {
        [selfProfileImg setImage:profilePic];
    }
    [selfProfileImg.layer setCornerRadius:27.0];
    [selfProfileImg.layer setMasksToBounds:YES];
    [profileView addSubview:selfProfileImg];
    selfProfileImg.userInteractionEnabled = YES;
    //profile name
    width = 60.0;
    height = 30.0;
    xPos = profileView.frame.origin.x;
    yPos = selfProfileImg.frame.size.height + selfProfileImg.frame.origin.y;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *userName = [home.from objectForKey:kName];
    [label setText:NSLocalizedString(userName, @"")];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [label setNumberOfLines:2];
    [profileView addSubview:label];
    //self gesture view
    width = 64.0;
    height = profileView.frame.size.height;
    xPos = 0.0;
    yPos = profileView.frame.origin.y;
    UIView *gestureView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [gestureView setBackgroundColor:[UIColor clearColor]];
    [profileView addSubview:gestureView];
    UITapGestureRecognizer *selfProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfProfileGestureTapped:)];
    [gestureView addGestureRecognizer:selfProfileGesture];
    //right arrow
    width = 15.0;
    height = 15.0;
    xPos = selfProfileImg.frame.size.width + 24.0;
    yPos = round(selfProfileImg.frame.size.height /2) + 4.0;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [rightArrow setImage:homeArrow];
    [profileView addSubview:rightArrow];
    //refer image
    width = 55.0;
    height = 55.0;
    xPos = selfProfileImg.frame.size.width + rightArrow.frame.size.width + 40.0;
    yPos = 10.0;
    UIImageView *guestReferProfileImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [profileView addSubview:guestReferProfileImg];
    [guestReferProfileImg.layer setCornerRadius:27.0];
    [guestReferProfileImg.layer setMasksToBounds:YES];
    guestReferProfileImg.userInteractionEnabled = YES;
    //profile name
    width = 70.0;
    height = 30.0;
    xPos = guestReferProfileImg.frame.origin.x - 5.0;
    yPos = guestReferProfileImg.frame.size.height + guestReferProfileImg.frame.origin.y;
    UILabel *referLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *profileName;
    UIImage *image;
    if ([home.channel isEqualToString:kWhatsapp])
    {
        profileName = kHomeWhatsAppUser;
        image = whatsappImg;
    }
    else if ([home.channel isEqualToString:kFacebook])
    {
        profileName = kHomeFacebookUsers;
        image = facebookImg;
    }
    else if ([home.channel isEqualToString:kTwitter])
    {
        profileName = kHomeTwitterUsers;
        image = twitterImg;
    }
    else{
        profileName = [[[home.toUser objectAtIndex:0] objectForKey:@"name"] capitalizedString];
    }
    [referLbl setTextAlignment:NSTextAlignmentCenter];
    [referLbl setBackgroundColor:[UIColor clearColor]];
    [referLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [referLbl setNumberOfLines:2];
    [profileView addSubview:referLbl];
    //refer gesture view
    width = 62.0;
    height = profileView.frame.size.height;
    xPos = selfProfileImg.frame.size.width + rightArrow.frame.size.width + 38.0;
    yPos = profileView.frame.origin.y;
    UIView *refergestureView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [refergestureView setBackgroundColor:[UIColor clearColor]];
    [profileView addSubview:refergestureView];
    UITapGestureRecognizer *guestProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guestProfileGestureTapped:)];
    [refergestureView addGestureRecognizer:guestProfileGesture];
    if ([home.toUser count] > 0)
    {
        width = 20.0;
        height = 20.0;
        xPos = (guestReferProfileImg.frame.origin.x + guestReferProfileImg.frame.size.width) - width;
        yPos = 2.0;
        UILabel *notificationLbl =[[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[home.toUser count]];
        [notificationLbl setText:NSLocalizedString(count, @"")];
        profileName = ([home.toUser count] >1)?[NSString stringWithFormat:@"%@ and others",profileName]:[NSString stringWithFormat:@"%@",profileName];
        [referLbl setText:NSLocalizedString(profileName, @"")];
        [notificationLbl setTextAlignment:NSTextAlignmentCenter];
        [notificationLbl setTextColor:[UIColor whiteColor]];
        [notificationLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [notificationLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [notificationLbl.layer setCornerRadius:10.0];
        [notificationLbl.layer setMasksToBounds:YES];
        [profileView addSubview:notificationLbl];
        [notificationLbl setHidden:([home.toUser count] > 1)?NO:YES];
        //right image
        if ([home.toUser count] > 0)
        {
            if ([[home.toUser objectAtIndex:0] objectForKey:kDp] != nil && [[[home.toUser objectAtIndex:0] objectForKey:kDp] length] > 0)
            {
                NSArray *arraySelfImage = [[[home.toUser objectAtIndex:0] objectForKey:kDp] componentsSeparatedByString:@"/"];
                NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:guestReferProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                }else if ([arraySelfImage count] > 1){
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[home.toUser objectAtIndex:0] objectForKey:kDp]] imageView:guestReferProfileImg];
                }else
                {
                    if (image !=nil)
                    {
                        guestReferProfileImg.image = image;
                        
                    }else
                    {
                        [guestReferProfileImg setImage:([home.toUser count] > 1)?groupPic:profilePic];
                    }
                    
                }
            }else
            {
                if (image !=nil)
                {
                    guestReferProfileImg.image = image;
                    
                }else
                {
                    [guestReferProfileImg setImage:([home.toUser count] > 1)?groupPic:profilePic];
                }
            }
        }
    }else
    {
        [guestReferProfileImg setImage:profilePic];
        [referLbl setText:NSLocalizedString(profileName, @"")];
    }
    //UIlabel
    width = profileView.frame.size.width - (guestReferProfileImg.frame.origin.x + selfProfileImg.frame.size.width);
    height = 20.0;
    xPos = guestReferProfileImg.frame.origin.x + guestReferProfileImg.frame.size.width + 6.0;
    yPos = round((guestReferProfileImg.frame.size.height - height)/2) - 3.0;
    UILabel *headerInfo = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //TODO:Need to change
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE d MMM yyyy, hh:mm a "];
    [inputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[home.referredAt doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    NSString *category = [home.entity objectForKey:kCategory];
    NSString *name = ([[home.entity valueForKey:kType] isEqualToString:kProduct])?[home.entity valueForKey:kName] :[home.entity valueForKey:kName];
    NSString *header = [NSString stringWithFormat:@"%@\n%@\n%@",time,category,name];
    [headerInfo setFont:([self bounds].size.width > 320 ?[[Configuration shareConfiguration] yoReferFontWithSize:12.0] :[[Configuration shareConfiguration] yoReferFontWithSize:10.0])];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
    NSRange selectedRange = NSMakeRange(time.length + category.length + 2, name.length);
    [string beginEditing];
    // [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName
                   value:([self bounds].size.width > 320 ?[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] :[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0])
                   range:selectedRange];
    [string endEditing];
    [headerInfo setAttributedText:string];
    [headerInfo setTextColor:[UIColor blackColor]];
    [headerInfo setNumberOfLines:0];
    [headerInfo sizeToFit];
    [profileView addSubview:headerInfo];
    //refer Image
    xPos = 0.0;
    yPos = profileView.frame.size.height;
    height = 130.0;
    width = frame.size.width - 20.0;
    UIView *referView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:referView];
    //background image
    xPos = 4.0;
    yPos = 0.0;
    width = referView.frame.size.width;
    height = referView.frame.size.height - 6.0;
    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [backgroundImg setTag:340000];
    [backgroundImg.layer setCornerRadius:5.0];
    [backgroundImg.layer setMasksToBounds:YES];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = backgroundImg.bounds;
    [backgroundImg addSubview:visualEffectView];
    [referView addSubview:backgroundImg];
    height = 124.0;
    yPos = 0.0;
    width = 140.0;
    xPos = (frame.size.width - width)/2;
    UIImageView *referImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSArray *array = [[NSString stringWithFormat:@"%@",home.mediaId] componentsSeparatedByString:@"/"];
    NSString *imageName = [array objectAtIndex:[array count]-1];
    [referView addSubview:referImg];
    //refer button
    width = 100.0;
    height = 30.0;
    xPos = round((profileView.frame.size.width - width)/2) + 6.0;
    yPos = (referImg.frame.size.height - height) + (height - 21.0);
    UIButton *referNow = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNow addTarget:self action:@selector(referButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [referNow setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [referNow setTitle:@"Refer Now" forState:UIControlStateNormal];
    [referNow.layer setBorderWidth:2.0];
    [referNow.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNow.layer setCornerRadius:15.0];
    [referNow.layer setMasksToBounds:YES];
    [referNow.titleLabel setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNow.bounds];
    referNow.layer.masksToBounds = NO;
    referNow.layer.shadowColor = [UIColor grayColor].CGColor;
    referNow.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNow.layer.shadowOpacity = 0.3f;
    referNow.layer.shadowPath = shadowPath.CGPath;
    [referView addSubview:referNow];
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:referImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:backgroundImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
    }else{
        if (home.mediaId != nil && [home.mediaId length] > 0) {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",home.mediaId]] imageView:referImg];
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",home.mediaId]] imageView:backgroundImg];
        }else{
            if ([home.type isEqualToString:kPlace])
            {
                referImg.image = placeImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 8.0, 90.0, 100.0)];
                backgroundImg.image = placeImg;
                [referNow setFrame:CGRectMake(referNow.frame.origin.x, referNow.frame.origin.y, referNow.frame.size.width, referNow.frame.size.height)];
            }
            else  if ([home.type isEqualToString:kProduct])
            {
                referImg.image = productImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 14.0, 90.0, 100.0)];
                backgroundImg.image = productImg;
            }else  if ([home.type isEqualToString:kWeb])
            {
                referImg.image = webLinkImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 22.0, 78.0, 80.0)];
                backgroundImg.image = webLinkImg;
            }
            
            else  if ([home.type isEqualToString:kService])
            {
                referImg.image = serviceImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 12.0, 80.0, 90.0)];
                backgroundImg.image = serviceImg;
            }
            else
                referImg.image = noPhotoImg;
        }
    }
    //title
    xPos = 10.0;
    yPos = referNow.frame.size.height + referNow.frame.origin.y;
    width = referView.frame.size.width - 12.0;
    height = 100.0;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *note = home.note;
    [title setText:NSLocalizedString(note, @"")];
    // [title setBackgroundColor:[UIColor greenColor]];
    [title setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [title setNumberOfLines:3];
    [title sizeToFit];
    CGRect newFrame = title.frame;
    newFrame.size = CGSizeMake(width, title.frame.size.height);
    title.frame = newFrame;
    [referView addSubview:title];
    //Address
    height = 158.0;
    width = contentView.frame.size.width ;
    xPos = 0.0;
    yPos = contentView.frame.size.height - (height - 26.0);//referView.frame.size.height + referView.frame.origin.y + 10.0;
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:addressView];
    //image
    xPos = 6.0;
    yPos = 4.0;
    width = addressView.frame.size.width - 12.0;
    height = 66.0;
    UIView *referImgView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referImgView setBackgroundColor:[UIColor clearColor]];
    [referImgView.layer setBorderWidth:0.5];
    [referImgView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [addressView addSubview:referImgView];
    //referImage
    xPos = 0.0;
    yPos = 16.0;
    width = 40.0;
    height = 40.0;//referImgView.frame.size.height;
    UIImageView *referSmallImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referImgView addSubview:referSmallImg];
    //map image
    xPos = referImgView.frame.size.width - 46.0;
    UIImageView *mapImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mapImg setImage:([[home.entity valueForKey:kType]isEqualToString:kWeb])?webImage:mapImage];
    [referImgView addSubview:mapImg];
    [mapImg setUserInteractionEnabled:YES];
    UITapGestureRecognizer *mapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapGestureTapped:)];
    [mapImg addGestureRecognizer:mapGesture];
    //title and address
    width = referImgView.frame.size.width - (mapImg.frame.size.width + 10.0);
    height = referImgView.frame.size.height - 4.0;
    yPos = 4.0;
    xPos = 5.0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
    
    NSString *categoryName = [NSString stringWithFormat:@"%@\n",([[home.entity valueForKey:kType] isEqualToString:kProduct])?[[[home.entity valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kName]:[home.entity valueForKey:kName]];
    if (categoryName != nil && [categoryName length] > 0)
    {
        NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:categoryName];
        [titleStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] range:NSMakeRange(0, titleStr.length)];
        [attributedString appendAttributedString:titleStr];
    }
    NSString *categoryAddress;
    if ([[home.entity valueForKey:kType] isEqualToString:kWeb])
    {
        categoryAddress = [home.entity valueForKey:kWebSite];
        
    }else if ([home.type isEqualToString:kProduct])
    {
        categoryAddress = [[[home.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality];
    }else
    {
        categoryAddress = [home.entity objectForKey:kLocality];
    }
    if (categoryAddress != nil && [categoryAddress length] > 0)
    {
        NSMutableAttributedString *addressStr = [[NSMutableAttributedString alloc]initWithString:categoryAddress];
        [addressStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, addressStr.length)];
        [addressStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferFontWithSize:10.5]:[[Configuration shareConfiguration] yoReferFontWithSize:12.0] range:NSMakeRange(0, addressStr.length)];
        [attributedString appendAttributedString:addressStr];
    }
    UILabel *titleAddressLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [titleAddressLbl setBackgroundColor:[UIColor clearColor]];
    [titleAddressLbl setAttributedText:attributedString];
    [titleAddressLbl setNumberOfLines:4];
    [titleAddressLbl sizeToFit];
    [referImgView addSubview:titleAddressLbl];
    //line
    xPos = 0.0;
    yPos = referImgView.frame.size.height + 10.0;
    width = contentView.frame.size.width;
    height = 0.5;
    UIView *upperLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [upperLine setBackgroundColor:[UIColor colorWithRed:(162.0/255.0) green:(162.0/255.0) blue:(162.0/255.0) alpha:1.0]];
    xPos = 8.0;
    yPos = upperLine.frame.size.height + upperLine.frame.origin.y - 2.0;
    width = frame.size.width - xPos * 2;
    height = 30.0;
    UILabel *pointLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *points = [NSString stringWithFormat:@"Earn %@ Point",[home.entity valueForKey:@"points"]];
    [pointLbl setText:NSLocalizedString(points, @"")];
    [pointLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [pointLbl setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [pointLbl setTextAlignment:NSTextAlignmentCenter];
    [addressView addSubview:pointLbl];
    //line
    xPos = 6.0;
    yPos = pointLbl.frame.size.height + pointLbl.frame.origin.y;
    width = contentView.frame.size.width - xPos * 2;
    height = 0.5;
    UIView *lowerLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [lowerLine setBackgroundColor:[UIColor colorWithRed:(162.0/255.0) green:(162.0/255.0) blue:(162.0/255.0) alpha:1.0]];
    [addressView addSubview:lowerLine];
    //refer
    width = 68.0;
    height = 20.0;
    xPos = frame.size.width - width;
    yPos = lowerLine.frame.origin.y + lowerLine.frame.size.height + 4.0;
    UILabel *refersLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *referCount = [NSString stringWithFormat:@"%@ Refers",[home.entity  objectForKey:@"referCount"]];
    [refersLbl setText:NSLocalizedString(referCount, @"")];
    [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [refersLbl setTextColor:[UIColor grayColor]];
    [refersLbl setUserInteractionEnabled:YES];
    [addressView addSubview:refersLbl];
    UITapGestureRecognizer *referalGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ReferalGestureTapped:)];
    [refersLbl addGestureRecognizer:referalGestureRecognizer];
}

#pragma mark - Ask feed

- (void)asksViewWithresponse:(NSDictionary *)response
{
    Home *home = (Home *)response;
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 0.0;
    CGFloat height = 180.0;
    CGFloat width = frame.size.width - 12.0;
    UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [viewMain setTag:ask];
    viewMain.backgroundColor = [UIColor whiteColor];
    viewMain.layer.cornerRadius = 5;
    viewMain.layer.masksToBounds = YES;
    [self.contentView addSubview:viewMain];
    xPos = 15.0;
    yPos = 10.0;
    width = 50.0;
    height = 50.0;
    UIImageView *imageDP = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageDP.layer.cornerRadius = 25.0;
    imageDP.layer.masksToBounds = YES;
    imageDP.backgroundColor = [UIColor colorWithRed:(242.0/255.0) green:(242.0/255.0) blue:(242.0/255.0) alpha:1.0];
    [viewMain addSubview:imageDP];
    [imageDP setUserInteractionEnabled:YES];
    //self gesture
    xPos = 0.0;
    yPos = 0.0;
    width = 68.0;
    height = 84.0;
    UIView *selfGesture = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [selfGesture setBackgroundColor:[UIColor clearColor]];
    [viewMain addSubview:selfGesture];
    UITapGestureRecognizer *selfProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfProfileGestureTapped:)];
    [selfGesture addGestureRecognizer:selfProfileGesture];
    if ([home.user objectForKey:kDp] != nil && [[home.user objectForKey:kDp] length] > 0)
    {
        NSArray *referArray= [[NSString stringWithFormat:@"%@",[home.user objectForKey:kDp]] componentsSeparatedByString:@"/"];
        NSString *referImageName = [referArray objectAtIndex:[referArray count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageDP path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImageName]];
        }else if ([referArray count] > 1)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[home.user objectForKey:kDp]] imageView:imageDP];
        }else
        {
            [imageDP setImage:profilePic];
        }
    }else
    {
        [imageDP setImage:profilePic];
    }
    xPos = 15.0;
    yPos = imageDP.frame.size.height + 5.0;
    width = imageDP.frame.size.width;
    height = 40.0;
    UILabel *profileName = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    profileName.textAlignment = NSTextAlignmentCenter;
    NSString *stringName = [[home.user objectForKey:kName] capitalizedString];
    profileName.text = NSLocalizedString(stringName, @"");
    profileName.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0];
    [profileName setNumberOfLines:2];
    [profileName setTextAlignment:NSTextAlignmentCenter];
    [viewMain addSubview:profileName];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE d MMM yyyy, hh:mm a "];
    [inputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[home.askedAt doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    xPos = imageDP.frame.size.width + 25.0;
    yPos = 12.0;
    width = viewMain.frame.size.width - 25.0;
    height = 12.0;
    UILabel *timeLine = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    timeLine.textAlignment = NSTextAlignmentLeft;
    timeLine.text = NSLocalizedString(time, @"");
    timeLine.textColor = [UIColor grayColor];
    timeLine.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    [viewMain addSubview:timeLine];
    xPos = imageDP.frame.size.width + 25.0;
    yPos = timeLine.frame.size.height + 10.0;
    width = viewMain.frame.size.width - 25.0;
    height = 25.0;
    UILabel *category = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    category.textAlignment = NSTextAlignmentLeft;
    NSString *stringCategory = [NSString stringWithFormat:@"Asked for \"%@\"",home.category];
    category.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:stringCategory];
    NSRange selectedRange = NSMakeRange(0, 10);
    [string beginEditing];
    [string addAttribute:NSFontAttributeName
                   value:([[Configuration shareConfiguration] yoReferBoldFontWithSize:11.0])
                   range:selectedRange];
    [string endEditing];
    category.attributedText = string;
    category.textColor = [UIColor grayColor];
    [viewMain addSubview:category];
    xPos = imageDP.frame.size.width + 25.0;
    yPos = timeLine.frame.size.height + category.frame.size.height + 8.0;
    width = viewMain.frame.size.width - 80.0;
    height = 50.0;
    UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    address.textAlignment = NSTextAlignmentLeft;
    NSString *stringAddress = [NSString stringWithFormat:@"@ \"%@\"",home.address];
    address.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    NSMutableAttributedString *addrString = [[NSMutableAttributedString alloc] initWithString:stringAddress];
    NSRange selectedAddrRange = NSMakeRange(0, 2);
    [addrString beginEditing];
    [addrString addAttribute:NSFontAttributeName
                       value:([[Configuration shareConfiguration] yoReferBoldFontWithSize:13.0])
                       range:selectedAddrRange];
    [addrString endEditing];
    address.attributedText = addrString;
    address.textColor = [UIColor grayColor];
    address.numberOfLines = 3;
    [address sizeToFit];
    [viewMain addSubview:address];
    xPos = 8.0;
    yPos = imageDP.frame.size.height + imageDP.frame.origin.y + 25.0;
    width = viewMain.frame.size.width - 10.0;
    height = 50.0;
    UILabel *comment = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    comment.textAlignment = NSTextAlignmentLeft;
    NSString *stringComment = ([home.comment length] > 0)? home.comment:[NSString stringWithFormat:@"%@ is looking for \"%@\" near \"%@\"",[[home.user objectForKey:kName] capitalizedString],home.category,home.address];
    comment.text = NSLocalizedString(stringComment, @"");
    comment.textColor = [UIColor blackColor];
    comment.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    comment.numberOfLines = 5;
    [viewMain addSubview:comment];
    xPos = 0.0;
    yPos = comment.frame.size.height + comment.frame.origin.y + 12.0;
    width = viewMain.frame.size.width;
    height = 1.0;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor colorWithRed:(242.0/255.0) green:(242.0/255.0) blue:(242.0/255.0) alpha:1.0];
    [viewMain addSubview:viewLine];
    xPos = 5.0;
    yPos = viewLine.frame.origin.y;
    width = viewMain.frame.size.width/2;
    height = 40.0;
    UILabel *referCount = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    referCount.textAlignment = NSTextAlignmentLeft;
    NSString *stringReferCount = [NSString stringWithFormat:@"%ld Refers",(unsigned long)[home.referrals count]];
    [referCount setUserInteractionEnabled:YES];
    referCount.text = NSLocalizedString(stringReferCount, @"");
    referCount.textColor = [UIColor grayColor];
    referCount.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    xPos = referCount.frame.size.width - 5.0;
    yPos = viewLine.frame.origin.y + 10.0;
    width = viewMain.frame.size.width/2;
    height = 20.0;
    UILabel *comments = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    comments.textAlignment = NSTextAlignmentRight;
    
    /*
    comments.text = [NSString stringWithFormat:@"%ld Responses",(unsigned long)[home.referrals count]];//NSLocalizedString(@"View Response", @"");
    */
    
    
    if ([[response valueForKey:@"responseCount"] integerValue] > 1) {
        comments.text = [NSString stringWithFormat:@"%@ Replies(s)",[response valueForKey:@"responseCount"]];
    }
    else{
        comments.text = [NSString stringWithFormat:@"%@ Reply(s)",[response valueForKey:@"responseCount"]];
    }
    

    
    comments.textColor = [UIColor grayColor];
    [comments setUserInteractionEnabled:YES];
    comments.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    [viewMain addSubview:comments];
    UITapGestureRecognizer *commentsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(askReferalGestureTapped:)];
    [comments addGestureRecognizer:commentsGestureRecognizer];
    width = (viewMain.frame.size.width/2) - 65.0;
    xPos = (viewMain.frame.size.width - width)/2;
    yPos = viewLine.frame.origin.y - 15.0;
    height = 30.0;
    UIButton *referNow = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    referNow.layer.cornerRadius = 15.0;
    referNow.layer.borderColor = [[UIColor whiteColor] CGColor];
    referNow.layer.borderWidth = 2.0;
    referNow.layer.masksToBounds = YES;
    referNow.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
    [referNow setTitle:NSLocalizedString(@"Respond Now", @"") forState:UIControlStateNormal];
    referNow.titleLabel.font = ([self bounds].size.height > 570.0)?[[Configuration shareConfiguration] yoReferFontWithSize:16.0]:[[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    [referNow addTarget:self action:@selector(askNowTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNow.bounds];
    referNow.layer.masksToBounds = NO;
    referNow.layer.shadowColor = [UIColor grayColor].CGColor;
    referNow.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNow.layer.shadowOpacity = 0.3f;
    referNow.layer.shadowPath = shadowPath.CGPath;
    [viewMain addSubview:referNow];
}


#pragma  mark - Button Delegate
- (IBAction)referButtonTaped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if([self.delegate respondsToSelector:@selector(pushToReferPageWithIndexPath:)])
    {
        [self.delegate pushToReferPageWithIndexPath:indexPath];
    }
}

- (IBAction)askNowTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if([self.delegate respondsToSelector:@selector(pushAskPageWithIndexPath:)])
    {
        [self.delegate pushAskPageWithIndexPath:indexPath];
    }
}


#pragma mark - GestureRecognizer

- (void)referNowTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(referNowTappedWithView:)])
    {
        [self.delegate referNowTappedWithView:gestureRecognizer];
    }
}

- (void)carouselGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(getCarouselDetailWithIndex:)])
    {
        [self.delegate getCarouselDetailWithIndex:gestureRecognizer.view.tag];
    }
}

- (void)referGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if([self.delegate respondsToSelector:@selector(pushToReferPageWithIndexPath:)])
    {
        [self.delegate pushToReferPageWithIndexPath:nil];
    }
}

- (void)askGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if([self.delegate respondsToSelector:@selector(pushAskPageWithIndexPath:)])
    {
        [self.delegate pushAskPageWithIndexPath:nil];
    }
}

- (void)refer:(UITapGestureRecognizer *)gestureRecognizer
{
    NSArray *subViews = [gestureRecognizer.view.superview subviews];
    [self enableSegmentWithIndex:0 subViews:subViews];
    if ([self.delegate respondsToSelector:@selector(getRefer)])
    {
        [self.delegate getRefer];
    }
}

- (void)ask:(UITapGestureRecognizer *)gestureRecognizer
{
    NSArray *subViews = [gestureRecognizer.view.superview subviews];
    [self enableSegmentWithIndex:1 subViews:subViews];
    if ([self.delegate respondsToSelector:@selector(getAsk)])
    {
        [self.delegate getAsk];
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

- (void)contentGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushToEntityPageWithIndexPath:)])
    {
        [self.delegate pushToEntityPageWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)selfProfileGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushSelfMePageWithIndexPath:)])
    {
        [self.delegate pushSelfMePageWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)guestProfileGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushGuestMePageWithIndexPath:)])
    {
        [self.delegate pushGuestMePageWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
    
}
- (void)mapGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushToMapPageWithIndexPath:)])
    {
        [self.delegate pushToMapPageWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)ReferalGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(getReferalsWithIndexPath:)])
        
    {
        [self.delegate getReferalsWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)askReferalGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(getAskReferalsWithIndexPath:)])
    {
        [self.delegate getAskReferalsWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)menuGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushToViewControllerWithIndex:)]) {
        [self.delegate pushToViewControllerWithIndex:gestureRecognizer.view.tag];
    }
}

#pragma mark - indexPathWithGestureRecognizer
- (NSIndexPath *)indexPathWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    return indexPath;
}

#pragma mark - Bounds
- (CGRect)bounds
{
    return  [[UIScreen mainScreen] bounds];
}

@end
