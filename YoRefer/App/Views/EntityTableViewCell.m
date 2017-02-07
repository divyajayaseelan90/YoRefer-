//
//  EntityTableViewCell.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 13/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "EntityTableViewCell.h"
#import "Configuration.h"
#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "UserManager.h"
#import "Entity.h"
#import "Constant.h"
#import "BBImageManipulator.h"
#import "EntityViewController.h"

NSString * const kEntityFeedsReuseIdentifier  = @"Feedsidentifier";
NSString * const kEntityPhotosReuseIdentifier = @"PhotoIdentifier";
NSString * const kEntityWhatsAppUser          = @"WhatsApp User";
NSString * const kEntityFacebookUsers         = @"facebook Users";
NSString * const kEntityTwitterUsers          = @"twitter Users";

@implementation EntityTableViewCell

- (instancetype)initEntityType:(EntityType)entityType response:(NSDictionary *)response indexPath:(NSIndexPath *)indexPath delegate:(id<Entity>)delegate type:(NSString *)type
{
    self  = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getEntityIdentifierWithEntityType:entityType indexPath:indexPath]];
    if (self)
    {
        self.delegate = delegate;
        [self setEntityWithType:entityType response:response indexPath:indexPath type:type];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (NSString *)getEntityIdentifierWithEntityType:(EntityType)entityType indexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    switch (entityType) {
        case EntityFeeds:
            identifier = [NSString stringWithFormat:@"%@_%ld",kEntityFeedsReuseIdentifier,indexPath.row];
            break;
        case EntityPhotos:
            identifier = [NSString stringWithFormat:@"%@_%ld",kEntityPhotosReuseIdentifier,indexPath.row] ;
            break;
        default:
            break;
    }
    return identifier;
}


- (void)setEntityWithType:(EntityType)entityType response:(NSDictionary *)response indexPath:(NSIndexPath *)indexPath type:(NSString *)type
{
    switch (entityType) {
        case EntityFeeds:
            [self createEntitlWithResponse:response];
            break;
        case EntityPhotos:
            [self createPhotEntityWithResponse:(NSMutableArray *)response indexPath:indexPath type:type];
            break;
            
        default:
            break;
    }
    
}

- (NSMutableArray *)getMediaArrayWithArray:(NSArray *)array
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


#pragma mark  -
- (void)createEntitlWithResponse:(NSDictionary *)response
{
    Entity *entity = (Entity *)response;
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width - 12.0;
    CGFloat height = 414.0;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:5.0];
    [contentView.layer setMasksToBounds:YES];
    [self.contentView addSubview:contentView];
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
    if ([entity.from objectForKey:kDp] != nil && [[entity.from objectForKey:kDp] length] > 0)
    {
        NSArray *arraySelfImage = [[entity.from objectForKey:kDp] componentsSeparatedByString:@"/"];
        NSString *selfImageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
       if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],selfImageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:profileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],selfImageName]];
        }else if ([arraySelfImage count] > 1)
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[entity.from objectForKey:kDp]] imageView:profileImg];
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
    //profile name
    width = 60.0;
    height = 30.0;
    xPos = profileView.frame.origin.x;
    yPos = profileImg.frame.size.height + profileImg.frame.origin.y;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *userName = [entity.from  valueForKey:kName];
    [label setText:NSLocalizedString(userName, @"")];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [label setNumberOfLines:2];
    [profileView addSubview:label];
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
    
    NSString *profileName = ([entity.toUsers count] > 0)?[NSString stringWithFormat:@"%@",[[[entity.toUsers objectAtIndex:0] valueForKey:kName] capitalizedString]]:@""; //[[[entity.toUsers objectAtIndex:0] valueForKey:kName] capitalizedString];
    [referLbl setTextAlignment:NSTextAlignmentCenter];
    [referLbl setBackgroundColor:[UIColor clearColor]];
    [referLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [referLbl setNumberOfLines:2];
    [profileView addSubview:referLbl];
    //refer gesture view
    width = 62.0;
    height = profileView.frame.size.height;
    xPos = profileImg.frame.size.width + rightArrow.frame.size.width + 38.0;
    yPos = profileView.frame.origin.y;
    UIView *refergestureView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [refergestureView setBackgroundColor:[UIColor clearColor]];
    [profileView addSubview:refergestureView];
    UITapGestureRecognizer *guestProfileGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guestProfileGestureTapped:)];
    [refergestureView addGestureRecognizer:guestProfileGesture];
    if ([ entity.toUsers  count] > 0)
    {
        width = 20.0;
        height = 20.0;
        xPos = (referProfileImg.frame.origin.x + referProfileImg.frame.size.width) - width;
        yPos = 2.0;
        UILabel *notificationLbl =[[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[ entity.toUsers  count]];
        [notificationLbl setText:NSLocalizedString(count, @"")];
        UIImage *image;
        if ([entity.channel isEqualToString:kWhatsapp])
        {
            profileName = kEntityWhatsAppUser;
            image = whatsappImg;
        }
        else if ([entity.channel isEqualToString:kFacebook])
        {
            profileName = kEntityFacebookUsers;
            image = facebookImg;
        }
        else if ([entity.channel isEqualToString:kTwitter])
        {
            profileName = kEntityTwitterUsers;
            image = twitterImg;
        }
        else
        {
            profileName = ([entity.toUsers count] > 1)?[NSString stringWithFormat:@"%@ and others",profileName]:[[NSString stringWithFormat:@"%@",profileName] capitalizedString];
        }
        [referLbl setText:NSLocalizedString(profileName, @"")];
        [notificationLbl setTextAlignment:NSTextAlignmentCenter];
        [notificationLbl setTextColor:[UIColor whiteColor]];
        [notificationLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [notificationLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [notificationLbl.layer setCornerRadius:10.0];
        [notificationLbl.layer setMasksToBounds:YES];
        [profileView addSubview:notificationLbl];
        [notificationLbl setHidden:([entity.toUsers count] > 1)?NO:YES];
        if ([entity.toUsers count] > 0)
        {
            // Dev ========== Handeled Crashing while toUsers is having <null> value ====================
            if (![[[entity.toUsers  objectAtIndex:0] valueForKey:kDp] isEqual:[NSNull null]]) {
                
                if ([[entity.toUsers objectAtIndex:0] valueForKey:kDp] != nil && [[[entity.toUsers  objectAtIndex:0] valueForKey:kDp] length] > 0)
                {
                    NSArray *arraySelfImage = [[[entity.toUsers objectAtIndex:0] valueForKey:kDp] componentsSeparatedByString:@"/"];
                    NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
                    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                    {
                        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:referProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                    }else if ([arraySelfImage count] > 1)
                    {
                        [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[entity.toUsers objectAtIndex:0] valueForKey:kDp]] imageView:referProfileImg];
                    }else
                    {
                        if (image !=nil)
                        {
                            referProfileImg.image = image;
                            
                        }else
                        {
                            [referProfileImg setImage:([entity.toUsers count] > 1)?groupPic:profilePic];
                        }
                    }
                }else
                {
                    if (image !=nil)
                    {
                        referProfileImg.image = image;
                        
                    }else
                    {
                        [referProfileImg setImage:([entity.toUsers count] > 1)?groupPic:profilePic];
                    }
                    
                }
            }
        }
        }else
        {
            [referProfileImg setImage:profilePic];
          [referLbl setText:NSLocalizedString(profileName, @"")];
    }
    //UIlabel
    width = profileView.frame.size.width - (referProfileImg.frame.origin.x + profileImg.frame.size.width);
    height = 20.0;
    xPos = referProfileImg.frame.origin.x + referProfileImg.frame.size.width + 6.0;
    yPos = round((referProfileImg.frame.size.height - height)/2) - 3.0;
    UILabel *headerInfo = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE d MMM yyyy, hh:mm a "];
    [inputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[[entity valueForKey:@"referredAt"] doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    NSString *category = [entity.entity valueForKey:kCategory];
    NSString *name = ([[entity.entity valueForKey:kType] isEqualToString:kProduct])?[entity.entity valueForKey:kName]:[entity.entity valueForKey:kName];
    NSString *header = [NSString stringWithFormat:@"%@\n%@\n%@",time,category,name];
    [headerInfo setFont:([self bounds].size.width > 320 ?[[Configuration shareConfiguration] yoReferFontWithSize:12.0] :[[Configuration shareConfiguration] yoReferFontWithSize:10.0])];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
    NSRange selectedRange = NSMakeRange(time.length + category.length + 2, name.length);
    [string beginEditing];
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
    NSArray *array = [[NSString stringWithFormat:@"%@",[entity valueForKey:@"mediaId"]] componentsSeparatedByString:@"/"];
    NSString *imageName = [array objectAtIndex:[array count]-1];
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
    [referNow.titleLabel setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [referNow addTarget:self action:@selector(referNowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    }else
    {
        if ([entity valueForKey:@"mediaId"] !=nil && [[entity valueForKey:@"mediaId"] length] > 0 )
            
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[entity valueForKey:@"mediaId"]]] imageView:referImg];
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[entity valueForKey:@"mediaId"]]] imageView:backgroundImg];
        }else
        {
            if ([entity.type isEqualToString:kPlace])
            {
                referImg.image = placeImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 8.0, 90.0, 100.0)];
                backgroundImg.image = placeImg;
                [referNow setFrame:CGRectMake(referNow.frame.origin.x, referNow.frame.origin.y, referNow.frame.size.width, referNow.frame.size.height)];
            }
            else  if ([entity.type isEqualToString:kProduct])
            {
                referImg.image = productImg;
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 14.0, 90.0, 100.0)];
                backgroundImg.image = productImg;
            }else  if ([entity.type isEqualToString:kWeb])
            {
                referImg.image = webLinkImg;
                 [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 22.0, 78.0, 80.0)];
                backgroundImg.image = webLinkImg;
            }else  if ([entity.type isEqualToString:kService])
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
    NSString *note = [response valueForKey:@"note"];
    [title setText:NSLocalizedString(note, @"")];
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
    yPos = contentView.frame.size.height - (height - 26.0);;
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
    [referImgView addSubview:referSmallImg];    //map image
    xPos = referImgView.frame.size.width - 46.0;
    UIImageView *mapImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mapImg setImage:([[entity.entity valueForKey:kType]isEqualToString:kWeb])?webImage:mapImage];
    [referImgView addSubview:mapImg];
    [mapImg setUserInteractionEnabled:YES];
    UITapGestureRecognizer *mapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapGestureTapped:)];
    [mapImg addGestureRecognizer:mapGesture];
    width = referImgView.frame.size.width - (mapImg.frame.size.width + 10.0);
    height = referImgView.frame.size.height - 4.0;
    yPos = 4.0;
    xPos = 5.0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
    NSString *categoryName = [NSString stringWithFormat:@"%@\n",([[entity.entity valueForKey:kType] isEqualToString:kProduct])?[[[entity.entity valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kName]:[entity.entity valueForKey:kName]];
    if (categoryName != nil && [categoryName length] > 0)
    {
        NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:categoryName];
        [titleStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] range:NSMakeRange(0, titleStr.length)];
        [attributedString appendAttributedString:titleStr];
    }
    NSString *categoryAddress;
    if ([[entity.entity valueForKey:kType] isEqualToString:kWeb])
    {
        categoryAddress = [entity.entity valueForKey:kWebSite];
        
    }else if ([entity.type isEqualToString:kProduct])
    {
        categoryAddress = [[[entity.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality];
    }else
    {
        categoryAddress = [entity.entity objectForKey:kLocality];
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
    NSString *points = [NSString stringWithFormat:@"Earn %@ Point",[entity.entity valueForKey:@"points"]];
    [pointLbl setText:NSLocalizedString(points, @"")];
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
    NSString *referCount = [NSString stringWithFormat:@"%@ Refers",[entity.entity  objectForKey:@"referCount"]];
    [refersLbl setText:NSLocalizedString(referCount, @"")];
    [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [refersLbl setTextColor:[UIColor grayColor]];
    [refersLbl setUserInteractionEnabled:YES];
    [addressView addSubview:refersLbl];
}
- (void)createPhotEntityWithResponse:(NSMutableArray *)response indexPath:(NSIndexPath *)indexPath type:(NSString *)type
{
    NSMutableArray *mediaLink = [self getMediaArrayWithArray:response];
    CGRect frame = [self bounds];
    CGFloat xPos = 8.0;
    CGFloat yPos  = 6.0;
    CGFloat width = frame.size.width - 18.0;
    CGFloat height = 104.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:view];
    //begin
    xPos = 0.0;
    yPos = 0.0;
    height = view.frame.size.height;
    width = roundf((view.frame.size.width/2)) - 8.0;
    UIView *beginView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [beginView setBackgroundColor:[UIColor whiteColor]];
    [beginView.layer setCornerRadius:8.0];
    [beginView.layer setMasksToBounds:YES];
    [view addSubview:beginView];
    _beginImg = [[UIImageView alloc]initWithFrame:beginView.frame];
    if ([[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"begin"] objectForKey:@"mediaId"] != nil && [[[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"begin"] objectForKey:@"mediaId"] length] > 0)
    {
        NSArray *beginArray= [[NSString stringWithFormat:@"%@",[[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"begin"] objectForKey:@"mediaId"]] componentsSeparatedByString:@"/"];
        NSString *beginImageName = [beginArray objectAtIndex:[beginArray count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],beginImageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:_beginImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],beginImageName]];
        }else
        {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"begin"] objectForKey:@"mediaId"]] imageView:_beginImg];
        }
    }
    else{
        if (self.bounds.size.height == 736) {
            width = _beginImg.frame.size.width - 110.0;
            height = _beginImg.frame.size.height - 20.0;
        }
        else if (self.bounds.size.height == 667) {
            width = _beginImg.frame.size.width - 100.0;
            height = _beginImg.frame.size.height - 20.0;
        }
        else
        {
            width = _beginImg.frame.size.width - 70.0;
            height = _beginImg.frame.size.height - 32.0;

        }
        xPos = (beginView.frame.size.width - width) / 2.0;
        yPos = (beginView.frame.size.height - height) / 2.0;
        [_beginImg setFrame:CGRectMake(xPos, yPos, width, height)];
        if ([type isEqualToString:kPlace])
        {
            [_beginImg setImage:placeImg];
        }else if ([type isEqualToString:kProduct])
        {
            [_beginImg setImage:productImg];
        }else if ([type isEqualToString:kWeb])
        {
            [_beginImg setImage:webLinkImg];
        }else if ([type isEqualToString:kService])
        {
            [_beginImg setImage:serviceImg];
        }
    }
    xPos = beginView.frame.size.width;
    yPos = beginView.frame.origin.y;
    width = 1.0;
    height = beginView.frame.size.height;
    UIView *imageLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageLine setBackgroundColor:[UIColor lightGrayColor]];
    //[beginView addSubview:imageLine];
    [beginView addSubview:_beginImg];
    
    /*
    UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
    [view addGestureRecognizer:profileGestureRecognizer];
    */
    
    if ([[mediaLink objectAtIndex:indexPath.row]valueForKey:@"end"] != nil && [[[mediaLink objectAtIndex:indexPath.row]valueForKey:@"end"] isKindOfClass:[NSDictionary class]])
    {
        //end
        xPos = beginView.frame.size.width + 8.0;
        yPos = 0.0;
        height = view.frame.size.height;
        width = roundf((view.frame.size.width/2));
        UIView *endView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [endView setBackgroundColor:[UIColor whiteColor]];
        [endView.layer setCornerRadius:8.0];
        [endView.layer setMasksToBounds:YES];
        [view addSubview:endView];
        xPos = 0.0;
        yPos = 0.0;
        height = endView.frame.size.height;
        width = endView.frame.size.width;
        UIImageView *endImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        if ([[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"end"] objectForKey:@"mediaId"] != nil && [[[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"end"] objectForKey:@"mediaId"] length] > 0){
            NSArray *endArray= [[NSString stringWithFormat:@"%@",[[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"end"] objectForKey:@"mediaId"]] componentsSeparatedByString:@"/"];
            NSString *endImageName = [endArray objectAtIndex:[endArray count]-1];
            if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],endImageName]])
            {
                [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:endImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],endImageName]];
                
            }else{
                
                [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[[mediaLink objectAtIndex:indexPath.row] objectForKey:@"end"] objectForKey:@"mediaId"]] imageView:endImg];
                
            }
        }else{
            //[endView setBackgroundColor:[UIColor colorWithRed:(252.0/255.0) green:(238.0/255.0) blue:(196.0/255.0) alpha:1.0]];
            if (self.bounds.size.height == 736) {
                width = endImg.frame.size.width - 110.0;
                height = endImg.frame.size.height - 20.0;
            }
            else if (self.bounds.size.height == 667) {
                width = endImg.frame.size.width - 100.0;
                height = endImg.frame.size.height - 20.0;
            }
            else
            {
                width = endImg.frame.size.width - 70.0;
                height = endImg.frame.size.height - 20.0;
                
            }
            xPos = (endView.frame.size.width - width) / 2.0;
            yPos = (endView.frame.size.height - height) / 2.0;
            [endImg setFrame:CGRectMake(xPos, yPos, width, height)];
            
            if ([type isEqualToString:kPlace])
            {
                [endImg setImage:placeImg];
            }else if ([type isEqualToString:kProduct])
            {
                [endImg setImage:productImg];
            }else if ([type isEqualToString:kService])
            {
                [endImg setImage:serviceImg];
            }
            
        }
        [endView addSubview:endImg];
 
    }
}

#pragma mark - bounds
- (CGRect)bounds
{
    return [[UIScreen mainScreen] bounds];
}

#pragma mark - GestureRecognizer
- (void)mapGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(pushToMapPageWithIndexPath:)])
    {
        [self.delegate pushToMapPageWithIndexPath:[self indexPathWithGestureRecognizer:gestureRecognizer]];
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

#pragma mark - Button delegate
- (IBAction)referNowButtonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if ([self.delegate respondsToSelector:@selector(pushToReferPageWithIndexPath:)])
    {
        [self.delegate pushToReferPageWithIndexPath:indexPath];
    }
}

#pragma mark -
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
