//
//  MeTableViewCell.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/12/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "MeTableViewCell.h"
#import "MeViewController.h"
#import "Configuration.h"
#import "YoReferUserDefaults.h"
#import "BaseViewController.h"
#import "DocumentDirectory.h"
#import "UserManager.h"
#import "LazyLoading.h"
#import "MeModel.h"
#import "Constant.h"

NSString * const kMeCell               = @"me";
NSString * const kMeRefersIdentifier   = @"Refers";
NSString * const kMeAsksIdentifier     = @"Asks";
NSString * const kMeFeedsIdentifier    = @"Feeds";
NSString * const kMeFriendssIdentifier = @"Friends";

@implementation MeTableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<Me>)delegate response:(NSMutableArray *)response meType:(MeType)meType

{
    self  = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIndentifierWithMeType:meType]];
    if (self)
    {
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([response count] > 0)
        {
            [self setMeWithMeType:meType response:response indexPath:indexPath];
        }
    }
    return self;
}

- (NSString *)getCellIndentifierWithMeType:(MeType)meType
{
    NSString *indentifier;
    switch (meType)
    {
        case Refers:
            indentifier = kMeRefersIdentifier;
            break;
        case Asks:
            indentifier = kMeAsksIdentifier;
            break;
        case Feeds:
            indentifier = kMeFeedsIdentifier;
            break;
        case Friends:
            indentifier = kMeFriendssIdentifier;
            break;
        default:
            break;
    }
    return indentifier;
}

- (void)setMeWithMeType:(MeType)meType response:(NSMutableArray *)response indexPath:(NSIndexPath *)indexPath
{
    switch (meType)
    {
        case Refers:
            [self refersWithIndexPath:indexPath response:response];
            break;
        case Asks:
            [self asksWithIndexPath:indexPath response:response];
            break;
        case Feeds:
            [self feedsWithIndexPath:indexPath response:response];
            break;
        case Friends:
            [self friendsWithIndexPath:indexPath response:response];
            break;
        default:
            break;
    }
}

#pragma mark - Refers
- (void)refersWithIndexPath:(NSIndexPath *)indexPath response:(NSMutableArray *)response
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 3.0;
    CGFloat height = 125.0;
    CGFloat width = frame.size.width - 12.0;
    view_Main = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view_Main.tag = indexPath.row;
    view_Main.backgroundColor = [UIColor whiteColor];
    view_Main.layer.cornerRadius = 5;
    view_Main.layer.masksToBounds = YES;
    [self.contentView addSubview:view_Main];
    UITapGestureRecognizer *maintGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainGestureTapped:)];
    [view_Main addGestureRecognizer:maintGestureRecognizer];
    xPos = 0.0;
    yPos = 0.0;
    width = 110.0;
    UIImageView *imageDP = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageDP.contentMode = UIViewContentModeScaleAspectFit;

    NSArray *imageDPArray ;
    NSString *imageName;
    if (![[[response objectAtIndex:indexPath.row]valueForKey:kDp] isKindOfClass:[NSNull class]])
    {
          imageDPArray = [[[response objectAtIndex:indexPath.row]valueForKey:kDp] componentsSeparatedByString:@"/"];
         imageName = [imageDPArray objectAtIndex:[imageDPArray count]-1];
    }else
    {
        imageDPArray = [[NSMutableArray alloc]init];
        imageName = @"";
    }
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageDP path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
    }else
    {
        if ([imageName length] > 0)
        {
             [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:([[[response objectAtIndex:indexPath.row]valueForKey:kDp] isKindOfClass:[NSNull class]])?@"":[[response objectAtIndex:indexPath.row]valueForKey:kDp]] imageView:imageDP];
        }else
        {
            if ([[[response objectAtIndex:indexPath.row]valueForKey:kType] isEqualToString:kPlace])
            {
                imageDP.image = placeImg;
                [imageDP setFrame:CGRectMake(imageDP.frame.origin.x, imageDP.frame.origin.y + 12.0, 90.0, 100.0)];
            }
            else  if ([[[response objectAtIndex:indexPath.row]valueForKey:kType] isEqualToString:kProduct])
            {
                imageDP.image = productImg;
                [imageDP setFrame:CGRectMake(imageDP.frame.origin.x + 14.0, imageDP.frame.origin.y + 14.0, 90.0, 100.0)];
            }else  if ([[[response objectAtIndex:indexPath.row]valueForKey:kType] isEqualToString:kWeb])
            {
                imageDP.image = webLinkImg;
                 [imageDP setFrame:CGRectMake(imageDP.frame.origin.x + 18.0, imageDP.frame.origin.y + 22.0, 78.0, 80.0)];
            }
            else  if ([[[response objectAtIndex:indexPath.row]valueForKey:kType] isEqualToString:kService])
            {
                imageDP.image = serviceImg;
                [imageDP setFrame:CGRectMake(imageDP.frame.origin.x + 18.0, imageDP.frame.origin.y + 14.0, 80.0, 90.0)];
            }
            else
                imageDP.image = noPhotoImg;
        }
        
    }
    [view_Main addSubview:imageDP];
    height = 25;
    width = view_Main.frame.size.width - 20.0;
    xPos = 120.0;
    yPos = 5.0;
    UILabel *category = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    category.textAlignment = NSTextAlignmentLeft;
    category.text = [NSString stringWithFormat:@"%@",[[response objectAtIndex:indexPath.row] valueForKey:kCategory]];
    category.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    [view_Main addSubview:category];
    xPos = 120.0;
    yPos = category.frame.size.height - 5.0;
    width = view_Main.frame.size.width - 20.0;
    height = 25;
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    name.textAlignment = NSTextAlignmentLeft;
    name.text = [NSString stringWithFormat:@"%@",[[response objectAtIndex:indexPath.row] valueForKey:kName]];
    name.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:14.0];
    [view_Main addSubview:name];
    
    xPos = 120.0;
    yPos = category.frame.size.height + name.frame.size.height - 10.0;
    width = view_Main.frame.size.width - 120.0;
    height = 50;
    
    location = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    NSString *locality;
    if ([[[response objectAtIndex:indexPath.row] valueForKey:kType] isEqualToString:kProduct])
    {
        locality = [[[[[response objectAtIndex:indexPath.row] valueForKey:kEntity] valueForKey:kPurchasedFrom]valueForKey:kDetail] valueForKey:kLocality];
    }
    else if ([[[response objectAtIndex:indexPath.row] valueForKey:kType] isEqualToString:kWeb])
    {
        locality = [[[response objectAtIndex:indexPath.row] valueForKey:kEntity] valueForKey:@"website"];
        /*
        [self shortenMapUrl:locality];
        [location setHidden:YES];
        */
    }
    else{
        locality = [[response objectAtIndex:indexPath.row] valueForKey:kLocality];
    }
    
    location.textAlignment = NSTextAlignmentLeft;
    location.font = [[Configuration shareConfiguration] yoReferFontWithSize:12.0];
    location.text = [NSString stringWithFormat:@"%@",locality];
    location.numberOfLines = 4;
    [location sizeToFit];
    [view_Main addSubview:location];
    
    xPos = 120.0;
    yPos = view_Main.frame.size.height - 25.0;
    width = 100.0;
    height = 20.0;
    UILabel *referCount = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    referCount.textAlignment = NSTextAlignmentLeft;
    NSString *stringReferCount = [NSString stringWithFormat:@"%@ Refers",[[[response valueForKey:kEntity] valueForKey:@"referCount"] objectAtIndex:indexPath.row]];
    [referCount setUserInteractionEnabled:YES];
    referCount.text = NSLocalizedString(stringReferCount, @"");
    referCount.textColor = [UIColor grayColor];
    referCount.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    [view_Main addSubview:referCount];
    width = 70.0;
    height = 20.0;
    xPos = view_Main.frame.size.width - 75.0;
    yPos = view_Main.frame.size.height - 25.0;
    UIButton *referNowBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNowBtn.layer setCornerRadius:10.0];
    [referNowBtn.layer setMasksToBounds:YES];
    referNowBtn.titleLabel.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0];
    referNowBtn.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
    [referNowBtn setTitle:@"Refer Now" forState:UIControlStateNormal];
    [referNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [referNowBtn.layer setBorderWidth:2.0];
    [referNowBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNowBtn addTarget:self action:@selector(referNowTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNowBtn.bounds];
    referNowBtn.layer.masksToBounds = NO;
    referNowBtn.layer.shadowColor = [UIColor grayColor].CGColor;
    referNowBtn.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNowBtn.layer.shadowOpacity = 0.3f;
    referNowBtn.layer.shadowPath = shadowPath.CGPath;
    [view_Main addSubview:referNowBtn];
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
    
    [location setHidden:NO];
    
    if ([returnData hasPrefix:@"http://tinyurl.com"]) {
        location.text = [NSString stringWithFormat:@"%@",returnData];
    }
    
    NSLog(@"location.text: %@", location.text);
}


#pragma mark - Asks
- (void)asksWithIndexPath:(NSIndexPath *)indexPath response:(NSMutableArray *)response
{
    MeModel *meModule = (MeModel *)[response objectAtIndex:indexPath.row];
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 3.0;
    CGFloat height = 180.0;
    CGFloat width = frame.size.width - 12.0;
    UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewMain.tag = indexPath.row;
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
    if ([meModule.user objectForKey:kDp] != nil && [[meModule.user objectForKey:kDp] length] > 0)
    {
        NSArray *referArray= [[NSString stringWithFormat:@"%@",[meModule.user objectForKey:kDp]] componentsSeparatedByString:@"/"];
        NSString *referImageName = [referArray objectAtIndex:[referArray count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageDP path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImageName]];
        }else if ([referArray count] > 1)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[meModule.user objectForKey:kDp]] imageView:imageDP];
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
    NSString *stringName = [[[[response objectAtIndex:indexPath.row] valueForKey:kUser] valueForKey:kName] capitalizedString];
    profileName.text = NSLocalizedString(stringName, @"");
    [profileName setNumberOfLines:2];
    [profileName setTextAlignment:NSTextAlignmentCenter];
    profileName.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0];
    [viewMain addSubview:profileName];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE d MMM yyyy, hh:mm a "];
    [inputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[[[response objectAtIndex:indexPath.row] valueForKey:@"askedAt"] doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    xPos = imageDP.frame.size.width + 25.0;
    yPos = 10.0;
    width = viewMain.frame.size.width - 25.0;
    height = 12.0;
    UILabel *timeLine = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    timeLine.textAlignment = NSTextAlignmentLeft;
    timeLine.text = NSLocalizedString(time, @"");
    timeLine.textColor = [UIColor grayColor];
    timeLine.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    [viewMain addSubview:timeLine];
    xPos = imageDP.frame.size.width + 25.0;
    yPos = timeLine.frame.size.height + 5.0;
    width = viewMain.frame.size.width - 25.0;
    height = 25.0;
    UILabel *category = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    category.textAlignment = NSTextAlignmentLeft;
    NSString *stringCategory = [NSString stringWithFormat:@"Asked for \"%@\"",[[response objectAtIndex:indexPath.row] valueForKey:kCategory]];
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
    yPos = timeLine.frame.size.height + category.frame.size.height;
    width = viewMain.frame.size.width - 80.0;
    height = 50.0;
    UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    address.textAlignment = NSTextAlignmentLeft;
    NSString *stringAddress = [NSString stringWithFormat:@"@ \"%@\"",[[response objectAtIndex:indexPath.row] valueForKey:kAddress]];
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
    NSString *stringComment = ([[[response objectAtIndex:indexPath.row] valueForKey:@"comment"] length] > 0)? [[response objectAtIndex:indexPath.row] valueForKey:@"comment"]:[NSString stringWithFormat:@"%@ is looking for \"%@\" near \"%@\"",[[[[response objectAtIndex:indexPath.row] valueForKey:@"user"] valueForKey:kName] capitalizedString],[[response objectAtIndex:indexPath.row] valueForKey:kCategory],[[response objectAtIndex:indexPath.row] valueForKey:kAddress]];
   // NSString *stringComment = [[response objectAtIndex:indexPath.row] valueForKey:@"comment"];
    comment.text = NSLocalizedString(stringComment, @"");
    comment.textColor = [UIColor blackColor];
    comment.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    comment.numberOfLines = 5;
    [viewMain addSubview:comment];
    xPos = 0.0;
    yPos = comment.frame.size.height + comment.frame.origin.y + 10.0;
    width = viewMain.frame.size.width;
    height = 1.0;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor colorWithRed:(242.0/255.0) green:(242.0/255.0) blue:(242.0/255.0) alpha:1.0];
    [viewMain addSubview:viewLine];
    xPos = 5.0;
    yPos = viewLine.frame.origin.y + 10.0;
    width = viewMain.frame.size.width/2;
    height = 20.0;
    UILabel *referCount = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    referCount.textAlignment = NSTextAlignmentLeft;
    NSString *stringReferCount = [NSString stringWithFormat:@"%lu Refers",[[[response objectAtIndex:indexPath.row] valueForKey:@"referrals"] count]];
    referCount.text = NSLocalizedString(stringReferCount, @"");
    referCount.textColor = [UIColor grayColor];
    [referCount setUserInteractionEnabled:YES];
    referCount.font = [[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    xPos = referCount.frame.size.width - 5.0;
    yPos = viewLine.frame.origin.y + 10.0;
    width = viewMain.frame.size.width/2;
    height = 20.0;
    UILabel *comments = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    comments.textAlignment = NSTextAlignmentRight;
//    comments.text = [NSString stringWithFormat:@"%lu Response(s)",[[[response objectAtIndex:indexPath.row] valueForKey:@"referrals"] count]];
    
    if ([[[response objectAtIndex:indexPath.row] valueForKey:@"responseCount"] integerValue] > 1) {
        comments.text = [NSString stringWithFormat:@"%@ Replies(s)",[[response objectAtIndex:indexPath.row] valueForKey:@"responseCount"]];
    }
    else{
        comments.text = [NSString stringWithFormat:@"%@ Reply(s)",[[response objectAtIndex:indexPath.row] valueForKey:@"responseCount"]];
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
    referNow.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0];
    [referNow setTitle:NSLocalizedString(@"Respond Now", @"") forState:UIControlStateNormal];
    referNow.titleLabel.font = ([[UIScreen mainScreen] bounds].size.height > 570.0)?[[Configuration shareConfiguration] yoReferFontWithSize:16.0]:[[Configuration shareConfiguration] yoReferFontWithSize:11.0];
    [referNow addTarget:self action:@selector(queryNowTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNow.bounds];
    referNow.layer.masksToBounds = NO;
    referNow.layer.shadowColor = [UIColor grayColor].CGColor;
    referNow.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNow.layer.shadowOpacity = 0.3f;
    referNow.layer.shadowPath = shadowPath.CGPath;
    [viewMain addSubview:referNow];
}

#pragma mark - Friends

- (void)friendsWithIndexPath:(NSIndexPath *)indexPath response:(NSMutableArray *)response
{
    MeModel *me = (MeModel *)[response objectAtIndex:indexPath.row];
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 3.0;
    CGFloat height = 50.0;
    CGFloat width = frame.size.width;
    UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewMain.tag = indexPath.row;
    viewMain.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:viewMain];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(friendsGestureTapped:)];
    [viewMain addGestureRecognizer:gestureRecognizer];
    xPos = 15.0;
    yPos = 5.0;
    width = 40.0;
    height = 40.0;
    UIImageView *imageDP = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if (me.dp != nil && [me.dp length] > 0)
    {
        NSArray *referArray= [[NSString stringWithFormat:@"%@",me.dp] componentsSeparatedByString:@"/"];
        NSString *referImageName = [referArray objectAtIndex:[referArray count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageDP path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImageName]];
        }else if ([referArray count] > 1)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:me.dp] imageView:imageDP];
        }else
        {
            [imageDP setImage:profilePic];
        }
    }else
    {
        [imageDP setImage:profilePic];
    }
    imageDP.layer.cornerRadius = 20.0;
    imageDP.layer.masksToBounds = YES;
    [viewMain addSubview:imageDP];
    xPos = imageDP.frame.size.width + 25.0;
    yPos = 0.0;
    width = viewMain.frame.size.width - imageDP.frame.size.width - 25.0;
    height = 50.0;
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    name.textAlignment = NSTextAlignmentLeft;
    NSString *guestName = [NSString stringWithFormat:@"%@",me.name];
    name.text = NSLocalizedString(guestName, @"");
    name.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
    [viewMain addSubview:name];
    xPos = 0.0;
    yPos = 48.0;
    width = viewMain.frame.size.width;
    height = 2.0;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor colorWithRed:(242.0/255.0) green:(242.0/255.0) blue:(242.0/255.0) alpha:1.0];
    [viewMain addSubview:viewLine];
}

#pragma mark - Feeds
- (void)feedsWithIndexPath:(NSIndexPath *)indexPath response:(NSMutableArray *)response
{
    MeModel *me = (MeModel *)[response objectAtIndex:indexPath.row];
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 3.0;
    CGFloat width = frame.size.width - 12.0;
    CGFloat height = 414.0;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:5.0];
    [contentView.layer setMasksToBounds:YES];
    [self.contentView addSubview:contentView];
    UITapGestureRecognizer *contentViewGestureRecognizer  =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentGesturedTapped:)];
    [contentView addGestureRecognizer:contentViewGestureRecognizer];
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
    UIImageView *profileImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if ([me.from objectForKey:kDp] != nil && [[me.from objectForKey:kDp] length] > 0)
    {
        NSArray *arraySelfImage = [[me.from objectForKey:kDp] componentsSeparatedByString:@"/"];
        NSString *selfImageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],selfImageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:profileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],selfImageName]];
        }else if ([arraySelfImage count] > 1)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[me.from objectForKey:kDp]] imageView:profileImg];
        }else
        {
            [profileImg setImage:profilePic];
        }
    }else
    {
        [profileImg setImage:profilePic];
    }
    [profileImg.layer setCornerRadius:27.0];
    [profileImg.layer setMasksToBounds:YES];
    [profileView addSubview:profileImg];
    profileImg.userInteractionEnabled = YES;
    //profile name
    width = 60.0;
    height = 30.0;
    xPos = profileView.frame.origin.x;
    yPos = profileImg.frame.size.height + profileImg.frame.origin.y;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *userName = [me.from  valueForKey:kName];
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
    xPos = profileImg.frame.size.width + 24.0;
    yPos = round(profileImg.frame.size.height /2) + 4.0;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [rightArrow setImage:homeArrow];
    [profileView addSubview:rightArrow];
    //refer image
    width = 55.0;
    height = 55.0;
    xPos = profileImg.frame.size.width + rightArrow.frame.size.width + 40.0;
    yPos = 10.0;
    UIImageView *referProfileImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referProfileImg.layer setCornerRadius:27.0];
    [referProfileImg.layer setMasksToBounds:YES];
    [profileView addSubview:referProfileImg];
    referProfileImg.userInteractionEnabled = YES;
    //profile name
    width = 70.0;
    height = 30.0;
    xPos = referProfileImg.frame.origin.x - 5.0;
    yPos = referProfileImg.frame.size.height + referProfileImg.frame.origin.y;
    UILabel *referLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *profileName = [[[me.toUsers objectAtIndex:0] valueForKey:kName] capitalizedString];
    [referLbl setBackgroundColor:[UIColor clearColor]];
    [referLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [referLbl setNumberOfLines:2];
    [referLbl setTextAlignment:NSTextAlignmentCenter];
    [profileView addSubview:referLbl];
    //refer gesture view
    width = 62.0;
    height = profileView.frame.size.height;
    xPos = referProfileImg.frame.size.width + rightArrow.frame.size.width + 38.0;
    yPos = profileView.frame.origin.y;
    UIView *refergestureView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [refergestureView setBackgroundColor:[UIColor clearColor]];
    [profileView addSubview:refergestureView];
    UITapGestureRecognizer *guestProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guestProfileGestureTapped:)];
    [refergestureView addGestureRecognizer:guestProfileGesture];
    if ([ me.toUsers  count] > 0)
    {
        width = 20.0;
        height = 20.0;
        xPos = (referProfileImg.frame.origin.x + referProfileImg.frame.size.width) - width;
        yPos = 2.0;
        UILabel *notificationLbl =[[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[ me.toUsers  count]];
        [notificationLbl setText:NSLocalizedString(count, @"")];
        UIImage *image;
        if ([me.channel isEqualToString:kWhatsapp])
        {
            profileName = @"WhatsApp User";
            image = whatsappImg;
        }
        else if ([me.channel isEqualToString:kFacebook])
        {
            profileName = @"facebook Users";
            image = facebookImg;
        }
        else if ([me.channel isEqualToString:kTwitter])
        {
            profileName = @"twitter Users";
            image = twitterImg;
        }
        else
        {
             profileName = ([[[response objectAtIndex:indexPath.row] valueForKey:@"toUsers"]  count] > 1)?[NSString stringWithFormat:@"%@ and others",profileName]:[[NSString stringWithFormat:@"%@",profileName] capitalizedString];
        }
        [referLbl setText:NSLocalizedString(profileName, @"")];
        [notificationLbl setTextAlignment:NSTextAlignmentCenter];
        [notificationLbl setTextColor:[UIColor whiteColor]];
        [notificationLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [notificationLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [notificationLbl.layer setCornerRadius:10.0];
        [notificationLbl.layer setMasksToBounds:YES];
        [profileView addSubview:notificationLbl];
        [notificationLbl setHidden:([[[response objectAtIndex:indexPath.row] valueForKey:@"toUsers"]  count] > 1)?NO:YES];
        //right image
        if ([me.toUsers count] > 0)
        {
            if ([[me.toUsers objectAtIndex:0] objectForKey:kDp] != nil && [[[me.toUsers objectAtIndex:0] objectForKey:kDp] length] > 0)
            {
                NSArray *arraySelfImage = [[[me.toUsers objectAtIndex:0] objectForKey:kDp] componentsSeparatedByString:@"/"];
                NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:referProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                    
                }else if ([arraySelfImage count] > 1)
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[me.toUsers objectAtIndex:0] objectForKey:kDp]] imageView:referProfileImg];
                }else
                {
                    if (image !=nil)
                    {
                        referProfileImg.image = image;
                        
                    }else
                    {
                        [referProfileImg setImage:([[[response objectAtIndex:indexPath.row] valueForKey:@"toUsers"]  count] > 1)?groupPic:profilePic];
                    }
                }
            }else
            {
                if (image !=nil)
                {
                    referProfileImg.image = image;
                    
                }else
                {
                    [referProfileImg setImage:([[[response objectAtIndex:indexPath.row] valueForKey:@"toUsers"]  count] > 1)?groupPic:profilePic];
                }
                
            }
            
        }
    }else
    {
        [referProfileImg setImage:profilePic];
        [referLbl setText:NSLocalizedString(profileName, @"")];
    }
    //UIlabel
    width = profileView.frame.size.width - (referProfileImg.frame.origin.x + referProfileImg.frame.size.width);
    height = 20.0;
    xPos = referProfileImg.frame.origin.x + referProfileImg.frame.size.width + 6.0;
    yPos = round((referProfileImg.frame.size.height - height)/2) - 3.0;
    UILabel *headerInfo = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE d MMM yyyy, hh:mm a "];
    [inputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[me.referredAt doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    NSString *category = [me.entity objectForKey:kCategory];
    NSString *name = ([[me.entity valueForKey:kType] isEqualToString:kProduct])?[me.entity valueForKey:kName]:[me.entity valueForKey:kName];
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
    NSArray *referImgArray = [me.mediaId componentsSeparatedByString:@"/"];
    NSString *referImgImageName = [referImgArray objectAtIndex:[referImgArray count]-1];
    [referView addSubview:referImg];
    //refer button
    width = 100.0;
    height = 30.0;
    xPos = round((profileView.frame.size.width - width)/2) + 6.0;
    yPos = (referImg.frame.size.height - height) + (height - 21.0);
    UIButton *referNow = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNow setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [referNow setTitle:@"Refer Now" forState:UIControlStateNormal];
    [referNow.layer setBorderWidth:2.0];
    [referNow.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNow.layer setCornerRadius:15.0];
    [referNow.layer setMasksToBounds:YES];
    [referNow.layer setBorderWidth:2.0];
    [referNow.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNow.titleLabel setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [referNow addTarget:self action:@selector(referNowTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNow.bounds];
    referNow.layer.masksToBounds = NO;
    referNow.layer.shadowColor = [UIColor grayColor].CGColor;
    referNow.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNow.layer.shadowOpacity = 0.3f;
    referNow.layer.shadowPath = shadowPath.CGPath;
    [referView addSubview:referNow];
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImgImageName]] && (referImgImageName != nil && [referImgImageName length] > 0))
        
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:referImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImgImageName]];
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:backgroundImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],referImgImageName]];
        
    }else{
        if (me.mediaId !=nil && [me.mediaId length] > 0)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:me.mediaId] imageView:referImg];
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:me.mediaId] imageView:backgroundImg];
        }else
        {
            
            if ([me.type isEqualToString:kPlace])
            {
                referImg.image = placeImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 8.0, 90.0, 100.0)];
                backgroundImg.image = placeImg;
                [referNow setFrame:CGRectMake(referNow.frame.origin.x, referNow.frame.origin.y, referNow.frame.size.width, referNow.frame.size.height)];
            }
            else  if ([me.type isEqualToString:kProduct])
            {
                referImg.image = productImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 14.0, 90.0, 100.0)];
                backgroundImg.image = productImg;
            }else  if ([me.type isEqualToString:kWeb])
            {
                referImg.image = webLinkImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 22.0, 78.0, 80.0)];
                backgroundImg.image = webLinkImg;
            }
            
            else  if ([me.type isEqualToString:kService])
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
    yPos = referNow.frame.size.height + referNow.frame.origin.y + 30.0;
    width = referView.frame.size.width - 12.0;
    height = referView.frame.size.height - (referNow.frame.size.height + referImg.frame.size.height);
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *note = me.note;
    [title setText:NSLocalizedString(note, @"")];
    [title setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [title setNumberOfLines:3];
    [title sizeToFit];
    [referView addSubview:title];
    //Address
    height = 158.0;
    width = contentView.frame.size.width ;
    xPos = 0.0;
    yPos = contentView.frame.size.height - (height - 26.0);
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
    [mapImg setImage:([[me.entity valueForKey:kType]isEqualToString:kWeb])?webImage:mapImage];
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
    NSString *categoryName = [NSString stringWithFormat:@"%@\n",([[me.entity valueForKey:kType] isEqualToString:kProduct])?[[[me.entity valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kName]:[me.entity valueForKey:kName]];
    if (categoryName != nil && [categoryName length] > 0)
    {
        NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:categoryName];
        [titleStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] range:NSMakeRange(0, titleStr.length)];
        [attributedString appendAttributedString:titleStr];
    }
    NSString *categoryAddress;
    if ([[me.entity valueForKey:kType] isEqualToString:kWeb])
    {
        categoryAddress = [me.entity valueForKey:kWebSite];
        
    }else if ([me.type isEqualToString:kProduct])
    {
        categoryAddress = [[[me.entity objectForKey:@"purchasedFrom"] objectForKey:kDetail] objectForKey:kLocality];
    }else
    {
        categoryAddress = [me.entity objectForKey:kLocality];
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
    // [addressView addSubview:upperLine];
    xPos = 8.0;
    yPos = upperLine.frame.size.height + upperLine.frame.origin.y - 2.0;
    width = frame.size.width - xPos * 2;
    height = 30.0;
    UILabel *pointLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [pointLbl setText:NSLocalizedString(@"Earn 10 Point", @"")];
    [pointLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [pointLbl setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [pointLbl setTextAlignment:NSTextAlignmentCenter];
    // [pointLbl setNumberOfLines:2];
    //[pointLbl sizeToFit];
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
    NSString *referCount = [NSString stringWithFormat:@"%@ Refers",[me.entity  objectForKey:@"referCount"]];
    [refersLbl setText:NSLocalizedString(referCount, @"")];
    [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [refersLbl setTextColor:[UIColor grayColor]];
    [refersLbl setUserInteractionEnabled:YES];
    [addressView addSubview:refersLbl];
    UITapGestureRecognizer *referalGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ReferalGestureTapped:)];
    [refersLbl addGestureRecognizer:referalGestureRecognizer];
}

#pragma mark - Button delegate
- (IBAction)referNowTapped:(id)sender
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

- (IBAction)queryNowTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if([self.delegate respondsToSelector:@selector(pushToQueryPageWithIndexPath:)])
    {
        [self.delegate pushToQueryPageWithIndexPath:indexPath];
    }
}


#pragma mark  - Gesture Recognizer

- (void)friendsGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(getFriendProfileWithIndexPath:)])
    {
        [self.delegate getFriendProfileWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}


- (void)askReferalGestureTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(getAskReferalsWithIndexPath:)])
    {
        [self.delegate getAskReferalsWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}
- (void)ReferalGestureTapped:(UITapGestureRecognizer *) gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(getReferalsWithIndexPath:)])
    {
        [self.delegate getReferalsWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)mapGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushToMapPageWithIndexPath:)])
    {
        [self.delegate pushToMapPageWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
        
    }
}

- (void)contentGesturedTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(feedsWithIndexPath:)])
        
    {
        [self.delegate feedsWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
    }
}

- (void)mainGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(refersWithIndexPath:)])
        
    {
        [self.delegate refersWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
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

#pragma mark - indexPathWithGestureRecognizer
- (NSIndexPath *)indexPathWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    return indexPath;
}

#pragma mak -
- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
