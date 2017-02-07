//
//  CategoriesView.m
//  YoRefer
//
//  Created by Bhaskar C M on 11/2/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "CategoriesView.h"
#import "Configuration.h"
#import "DocumentDirectory.h"
#import "UserManager.h"
#import "LazyLoading.h"
#import "YoReferUserDefaults.h"
#import "Constant.h"

NSString  * const kCategoryView          = @"identifier";
NSString  * const kHeaderTitle           = @"You might also be interested in these";

CGFloat     const kSectionHeight         = 40.0;
CGFloat     const kRowHeight             = 136.0;
CGFloat     const kResponseHeight        = 419.0;

NSInteger   const kCategoryTableTag      = 10000;

@interface CategoriesView () <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrayCategories;
}
@property (nonatomic, readwrite) BOOL isResponse;
@end

@implementation CategoriesView

- (instancetype)initWithViewFrame:(CGRect)frame categoryList:(NSDictionary *)categoryList delegate:(id<CategoryView>)delegate isResponse:(BOOL)isResponse
{
    self = [super init];
    
    if (self)
    {
        self.delegate  = delegate;
        arrayCategories = [[NSMutableArray alloc]init];
        arrayCategories = [categoryList valueForKey:@"response"];
        self.isResponse = isResponse;
        [self CategoryViewWithFrame:frame];
    }
    
    return self;
    
}


- (void)CategoryViewWithFrame:(CGRect)frame
{
    [self setBackgroundColor:[UIColor greenColor]];
    CGFloat xPos = 0.0;
    CGFloat yPos = 6.0;
    CGFloat height = frame.size.height - 6.0;
    CGFloat width = frame.size.width;
    UIView *viewSharing = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [self addSubview:viewSharing];
    height = ([[[YoReferUserDefaults shareUserDefaluts] valueForKey:@"Header"] isEqualToString:@"Show"])?frame.size.height- 72.0:frame.size.height - 120.0;
    UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
    categoryTable.tag = kCategoryTableTag;
    categoryTable.backgroundColor = (self.isResponse)?[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]:[UIColor whiteColor];
    categoryTable.delegate = self;
    categoryTable.dataSource = self;
    [viewSharing addSubview:categoryTable];
    [categoryTable reloadData];
}


- (UIView *)createViewWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor
{
    
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:backgroundColor];
    return view;
    
}


#pragma mark - tableView datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [arrayCategories count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if ([[[YoReferUserDefaults shareUserDefaluts] valueForKey:@"Header"] isEqualToString:@"Show"]) {
        return kSectionHeight;
    }else{
        return 0;
    }
    
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 44.0;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *title = [[UILabel alloc]initWithFrame:view.frame];
    [title setText:NSLocalizedString(kHeaderTitle, @"")];
    [title setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0]];
    [title setNumberOfLines:2];
    [title setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:title];
    
    height = 0.5;
    yPos = view.frame.size.height - (height + 6.0);
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [line setBackgroundColor:[UIColor blackColor]];
    [view addSubview:line];
    
    return view;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    CGFloat height =  [self labelHeightWithText:[NSString stringWithFormat:@"%@%@",[[arrayCategories valueForKey:@"name"] objectAtIndex:indexPath.row],[[arrayCategories valueForKey:@"locality"] objectAtIndex:indexPath.row]]];
    
    return (self.isResponse)?kResponseHeight:kRowHeight;
    
}



- (CGFloat)labelHeightWithText:(NSString *)text
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 128.0;
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [name  setText:text];
    [name setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:16.0]];
    [name setNumberOfLines:0];
    [name sizeToFit];
    return name.frame.size.height;
    
}

- (UITableViewCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCategoryView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
    }
    if (self.isResponse)
        cell = [self viewResponseWithTableViewCell:cell indexPath:indexPath];
    else
        cell = [self categoryWithTableViewCell:cell indexPath:indexPath];
    
    
    return cell;
}

- (UITableViewCell *)viewResponseWithTableViewCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [arrayCategories objectAtIndex:indexPath.row];
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 6.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width - 12.0;
    CGFloat height = 414.0;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:5.0];
    [contentView.layer setMasksToBounds:YES];
    [cell.contentView addSubview:contentView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentGestureTapped:)];
    [contentView addGestureRecognizer:gestureRecognizer];
    //profile
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
    if ([[dictionary valueForKey:@"from"] objectForKey:@"dp"] != nil && [[[dictionary valueForKey:@"from"] objectForKey:@"dp"] length] > 0)
    {
        NSArray *arraySelfImage = [[[dictionary valueForKey:@"from"] objectForKey:@"dp"] componentsSeparatedByString:@"/"];
        NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:selfProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        }else if ([arraySelfImage count] > 1){
            
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[dictionary valueForKey:@"from"] objectForKey:@"dp"]] imageView:selfProfileImg];
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
    
    NSString *userName = [[dictionary valueForKey:@"from"] objectForKey:@"name"];
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
    [guestReferProfileImg.layer setCornerRadius:27.0];
    [guestReferProfileImg.layer setMasksToBounds:YES];
    [profileView addSubview:guestReferProfileImg];
    guestReferProfileImg.userInteractionEnabled = YES;
    
    //profile name
    width = 70.0;
    height = 30.0;
    xPos = guestReferProfileImg.frame.origin.x - 5.0;
    yPos = guestReferProfileImg.frame.size.height + guestReferProfileImg.frame.origin.y;
    UILabel *referLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *profileName = [[[[dictionary valueForKey:@"toUsers"] objectAtIndex:0] valueForKey:@"name"] capitalizedString];
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
    
    if ([[dictionary valueForKey:@"toUsers"] count] > 0)
    {
        width = 20.0;
        height = 20.0;
        xPos = (guestReferProfileImg.frame.origin.x + guestReferProfileImg.frame.size.width) - width;
        yPos = 2.0;
        UILabel *notificationLbl =[[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[dictionary valueForKey:@"toUsers"]];
        [notificationLbl setText:NSLocalizedString(count, @"")];
        
        
        UIImage *image;
        if ([[dictionary valueForKey:@"channel"]  isEqualToString:@"whatsapp"])
        {
            profileName = @"WhatsApp User";
            image = [UIImage imageNamed:@"icon_whatsapp.png"];
        }
        else if ([[dictionary valueForKey:@"channel"] isEqualToString:@"facebook"])
        {
            profileName = @"facebook Users";
            image = [UIImage imageNamed:@"icon_facebook.png"];
        }
        else if ([[dictionary valueForKey:@"channel"] isEqualToString:@"twitter"])
        {
            profileName = @"twitter Users";
            image = [UIImage imageNamed:@"icon_twitter.png"];
        }
        else{
            profileName = ([[dictionary valueForKey:@"toUsers"]count] >1)?[NSString stringWithFormat:@"%@ and others",profileName]:[[NSString stringWithFormat:@"%@",profileName]capitalizedString];
        }

        
        [referLbl setText:NSLocalizedString(profileName, @"")];
        [notificationLbl setTextAlignment:NSTextAlignmentCenter];
        [notificationLbl setTextColor:[UIColor whiteColor]];
        [notificationLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [notificationLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        [notificationLbl.layer setCornerRadius:10.0];
        [notificationLbl.layer setMasksToBounds:YES];
        [profileView addSubview:notificationLbl];
        
        [notificationLbl setHidden:([[dictionary valueForKey:@"toUsers"] count] > 1)?NO:YES];
        
        //right image
        
        if ([dictionary valueForKey:@"toUsers"] > 0)
        {
            
            if ([[[dictionary valueForKey:@"toUsers"] objectAtIndex:0] objectForKey:@"dp"] != nil && [[[[dictionary valueForKey:@"toUsers"] objectAtIndex:0] objectForKey:@"dp"] length] > 0)
            {
                
                NSArray *arraySelfImage = [[[[dictionary valueForKey:@"toUsers"] objectAtIndex:0] objectForKey:@"dp"] componentsSeparatedByString:@"/"];
                
                NSString *imageName = [arraySelfImage objectAtIndex:[arraySelfImage count]-1];
                
                
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && (imageName != nil && [imageName length] > 0))
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:guestReferProfileImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                    
                }else if ([arraySelfImage count] > 1){
                    
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[[dictionary valueForKey:@"toUsers"] objectAtIndex:0] objectForKey:@"dp"]] imageView:selfProfileImg];
                }else
                {
                    if (image !=nil)
                    {
                        guestReferProfileImg.image = image;
                        
                    }else
                    {
                        [guestReferProfileImg setImage:([[dictionary valueForKey:@"toUsers"] count] > 1)?groupPic:profilePic];
                    }
                }
                
            }else
            {
                if (image !=nil)
                {
                    guestReferProfileImg.image = image;
                    
                }else
                {
                     [guestReferProfileImg setImage:([[dictionary valueForKey:@"toUsers"] count] > 1)?groupPic:profilePic];
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
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"referredAt"] doubleValue]/1000];
    NSString *time = [inputFormatter stringFromDate:dateNow];
    NSString *category = [[dictionary valueForKey:@"entity"] objectForKey:@"category"];
    NSString *name = [[dictionary valueForKey:@"entity"] objectForKey:@"name"];
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
    
    NSArray *array = [[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"mediaId"]] componentsSeparatedByString:@"/"];
    
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
        
        if ([dictionary valueForKey:@"mediaId"] != nil && [[dictionary valueForKey:@"mediaId"] length] > 0) {
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"mediaId"]]] imageView:referImg];
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"mediaId"]]] imageView:backgroundImg];
            
        }else{
            
            if ([[dictionary valueForKey:@"type"]isEqualToString:@"place"])
            {
                referImg.image = [UIImage imageNamed:@"icon_place.png"];
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 8.0, 90.0, 100.0)];
                backgroundImg.image = [UIImage imageNamed:@"icon_place.png"];
                [referNow setFrame:CGRectMake(referNow.frame.origin.x, referNow.frame.origin.y, referNow.frame.size.width, referNow.frame.size.height)];
            }
            else  if ([[dictionary valueForKey:@"type"] isEqualToString:@"product"])
            {
                referImg.image = [UIImage imageNamed:@"icon_product.png"];
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 24.0, referImg.frame.origin.y + 14.0, 90.0, 100.0)];
                backgroundImg.image = [UIImage imageNamed:@"icon_product.png"];
            }else  if ([[dictionary valueForKey:@"type"] isEqualToString:@"web"])
            {
                referImg.image = [UIImage imageNamed:@"icon_weblink.png"];
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 22.0, 78.0, 80.0)];
                backgroundImg.image = [UIImage imageNamed:@"icon_weblink.png"];
            }
            
            else  if ([[dictionary valueForKey:@"type"] isEqualToString:@"service"])
            {
                referImg.image = [UIImage imageNamed:@"icon_service.png"];
                [referImg setFrame:CGRectMake(referImg.frame.origin.x + 30.0, referImg.frame.origin.y + 12.0, 80.0, 90.0)];
                backgroundImg.image = [UIImage imageNamed:@"icon_service.png"];

            }
            else
                referImg.image = [UIImage imageNamed:@"icon_nophoto.png"];
            
            
        }
        
    }

    //title
    xPos = 10.0;
    yPos = referNow.frame.size.height + referNow.frame.origin.y + 30.0;
    width = referView.frame.size.width - 12.0;
    height = referView.frame.size.height - (referNow.frame.size.height + referImg.frame.size.height);
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *note = [dictionary valueForKey:@"note"];
    [title setText:NSLocalizedString(note, @"")];
    [title setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [title setNumberOfLines:3];
    [title sizeToFit];
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
    [mapImg setImage:([[[dictionary valueForKey:@"entity"] valueForKey:@"type" ]isEqualToString:@"web"])?webImage:mapImage];
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
    NSString *categoryName = [NSString stringWithFormat:@"%@\n",[[dictionary valueForKey:@"entity"] objectForKey:@"name"]];
    if (categoryName != nil && [categoryName length] > 0)
    {
        
        NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:categoryName];
        [titleStr addAttribute:NSFontAttributeName value:(frame.size.height <= 640)?[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] range:NSMakeRange(0, titleStr.length)];
        [attributedString appendAttributedString:titleStr];
        
    }
    
    NSString *categoryAddress;
    
    if ([[[dictionary valueForKey:@"entity"] valueForKey:@"type"] isEqualToString:@"web"])
    {
        
        categoryAddress = [[dictionary valueForKey:@"entity"] valueForKey:@"website"];
        
        
    }else if ([[dictionary valueForKey:@"type"] isEqualToString:@"product"])
    {
        categoryAddress = [[[[dictionary valueForKey:@"entity"] objectForKey:@"purchasedFrom"] objectForKey:@"detail"] objectForKey:@"locality"];
    }else
    {
        categoryAddress = [[dictionary valueForKey:@"entity"] objectForKey:@"locality"];
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
    NSString *referCount = [NSString stringWithFormat:@"%@ Refers",[[dictionary valueForKey:@"entity"]  objectForKey:@"referCount"]];
    [refersLbl setText:NSLocalizedString(referCount, @"")];
    [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [refersLbl setTextColor:[UIColor grayColor]];
    [refersLbl setUserInteractionEnabled:YES];
    [addressView addSubview:refersLbl];
//    UITapGestureRecognizer *referalGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ReferalGestureTapped:)];
//    [refersLbl addGestureRecognizer:referalGestureRecognizer];
    
    return cell;
}

- (UITableViewCell *)categoryWithTableViewCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 5.0;
    CGFloat width = frame.size.width;
    CGFloat height = 128.0;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [cell addSubview:view];
    height = 80.0;
    width = 80.0;
    xPos = 4.0;
    yPos = roundf((view.frame.size.height - height)/2);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView.layer setCornerRadius:3.0];
    [imageView.layer setMasksToBounds:YES];
    [view addSubview:imageView];
    
    if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"] isKindOfClass:[NSNull class]])
    {
        if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"place"])
        {
            imageView.image = [UIImage imageNamed:@"icon_place.png"];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x , imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
        }
        else  if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"product"])
        {
            imageView.image = [UIImage imageNamed:@"icon_product.png"];
        }else  if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"web"])
        {
            imageView.image = [UIImage imageNamed:@"icon_weblink.png"];
        }
        
        else  if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"service"])
        {
            imageView.image = [UIImage imageNamed:@"icon_service.png"];
        }
        else
            imageView.image = [UIImage imageNamed:@"icon_nophoto.png"];
    
    }else
    {
        NSArray *imageDPArray ;
        NSString *imageName;
        if (![[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"] isKindOfClass:[NSNull class]])
        {
            imageDPArray = [[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"] componentsSeparatedByString:@"/"];
            imageName = [imageDPArray objectAtIndex:[imageDPArray count]-1];
        }else
        {
            imageDPArray = [[NSMutableArray alloc]init];
            imageName = @"";
        }
        
        
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && [imageName length] > 0)
            
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
            
        }else{
            
            if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"] isKindOfClass:[UIImage class]])
            {
                
                imageView.image = [[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"];
                
            }else
            {
                if ([imageName length] > 0)
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"] isKindOfClass:[NSNull class]])?@"":[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"dp"]] imageView:imageView];
                }else
                {
                    if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"place"])
                    {
                        imageView.image = [UIImage imageNamed:@"icon_place.png"];
                        [imageView setFrame:CGRectMake(imageView.frame.origin.x , imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
                    }
                    else  if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"product"])
                    {
                        imageView.image = [UIImage imageNamed:@"icon_product.png"];
                    }else  if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"web"])
                    {
                        imageView.image = [UIImage imageNamed:@"icon_weblink.png"];
                    }
                    
                    else  if ([[[arrayCategories objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"service"])
                    {
                        imageView.image = [UIImage imageNamed:@"icon_service.png"];
                    }
                    else
                        imageView.image = [UIImage imageNamed:@"icon_nophoto.png"];
                }
                
            }
            
            
        }
        
        
        
    }
    
    xPos = imageView.frame.size.width + 8.0;
    yPos = 6.0;
    width = view.frame.size.width - (imageView.frame.size.width + 20.0);
    height = 20.0;
    UILabel *Categoryname = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [Categoryname  setText:[[arrayCategories valueForKey:@"category"] objectAtIndex:indexPath.row]];
    if ([[[arrayCategories valueForKey:@"category"] objectAtIndex:indexPath.row] isKindOfClass:[NSString class]])
    {
        [Categoryname setFont:([self bounds].size.height > 580) ?[[Configuration shareConfiguration] yoReferFontWithSize:15.0]:[[Configuration shareConfiguration] yoReferFontWithSize:10.0]];
        [Categoryname setNumberOfLines:0];
        [Categoryname sizeToFit];
        [view addSubview:Categoryname];
        
    }
    
    xPos = imageView.frame.size.width + 8.0;
    yPos = Categoryname.frame.size.height + 10.0;
    width = view.frame.size.width - (imageView.frame.size.width + 20.0);
    height = 20.0;
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [name  setText:[[arrayCategories valueForKey:@"name"] objectAtIndex:indexPath.row]];
    [name setFont:([self bounds].size.height > 580) ?[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:13.0]];
    [name setNumberOfLines:0];
    [name sizeToFit];
    [view addSubview:name];
    
    yPos  = name.frame.origin.y + name.frame.size.height + 4.0;
    UILabel *locality = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [locality setText:[[arrayCategories valueForKey:@"locality"] objectAtIndex:indexPath.row]];
    [locality setFont:([self bounds].size.height > 580)?[[Configuration shareConfiguration] yoReferFontWithSize:12.0]:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [locality setNumberOfLines:4];
    //[locality setTextColor:[UIColor lightGrayColor]];
    [locality sizeToFit];
    [view addSubview:locality];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //    CGRect newFrame = view.frame;
    //    newFrame.size = CGSizeMake(view.frame.size.width, name.frame.size.height + locality.frame.size.height);
    //    view.frame = newFrame;
    
    
    width = 100.0;
    height = 42.0;
    xPos = view.frame.size.width - width;
    yPos = view.frame.size.height - (height + 6.0);
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view addSubview:   bottomView];
    
    
    height = 38.0;
    width = 100.0;
    xPos = 0.0;
    yPos = round((bottomView.frame.size.height - height)/2);
    UIView *referView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [bottomView addSubview:referView];
    
    UITapGestureRecognizer *referGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referGestureTapped:)];
    [referView addGestureRecognizer:referGesture];
    
    xPos = referView.frame.size.width;
    UIView *entityView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [bottomView addSubview:entityView];
    
    //    UITapGestureRecognizer *entityGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(entityGestureTapped:)];
    //    [entityView addGestureRecognizer:entityGesture];
    
    
    height = 20.0;
    width = 70.0;
    xPos = 25.0;
    yPos = round((referView.frame.size.height - height)/2) + 16.0;
    UILabel *referNowLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNowLbl setText:NSLocalizedString(@"Refer Now", @"")];
    [referNowLbl setTextAlignment:NSTextAlignmentCenter];
    [referNowLbl.layer setCornerRadius:10.0];
    [referNowLbl.layer setMasksToBounds:YES];
    [referNowLbl.layer setBorderWidth:2.0];
    [referNowLbl.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNowLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [referNowLbl setTextColor:[UIColor whiteColor]];
    [referNowLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNowLbl.bounds];
    //referNowLbl.layer.masksToBounds = NO;
    referNowLbl.layer.shadowColor = [UIColor grayColor].CGColor;
    referNowLbl.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNowLbl.layer.shadowOpacity = 0.3f;
    referNowLbl.layer.shadowPath = shadowPath.CGPath;
    [referView addSubview:referNowLbl];
    
    //refer
    width = 100.0;
    height = 15.0;
    xPos = 106.0;
    yPos = bottomView.frame.origin.y + 30.0;//imageView.frame.origin.y + imageView.frame.size.height;
    UILabel *refersLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    NSString *referCount = [NSString stringWithFormat:@"%@ Refers",[[[arrayCategories valueForKey:@"entity"] valueForKey:@"referCount"] objectAtIndex:indexPath.row]];
    [refersLbl setText:NSLocalizedString(referCount, @"")];
    [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    [refersLbl setTextColor:[UIColor grayColor]];
    [refersLbl setUserInteractionEnabled:YES];
    [view addSubview:refersLbl];
    
    
    
    
    //    width = 100.0;
    //    height = 40.0;
    //    xPos = referView.frame.origin.x;
    //    yPos = referView.frame.origin.y;
    //    UIButton *referNowBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //    //[referNowBtn setBackgroundColor:[UIColor redColor]];
    //    [referNowBtn addTarget:self action:@selector(referGestureTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [referView addSubview:referNowBtn];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:@"Hide" forKey:@"Header"];
    //[(UITableView *)[self viewWithTag:kCategoryTableTag] reloadData];
    
    if ([self.delegate respondsToSelector:@selector(pushToEntityPageWithIndexPath:)])
    {
        [self.delegate pushToEntityPageWithIndexPath:indexPath];
        
    }
}


#pragma mark - Gesture Recognizer

- (IBAction)referGestureTapped:(UIGestureRecognizer *)gestureRecognizer
{
    
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:(UITableView *)[self viewWithTag:kCategoryTableTag]];
    NSIndexPath *indexPath =[(UITableView *)[self viewWithTag:kCategoryTableTag] indexPathForRowAtPoint:point];
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:@"Hide" forKey:@"Header"];
    [(UITableView *)[self viewWithTag:kCategoryTableTag] reloadData];
    if ([self.delegate respondsToSelector:@selector(pushToReferPageWithIndexPath:)])
    {
        [self.delegate pushToReferPageWithIndexPath:indexPath];
        
    }
    
    
}

- (IBAction)entityGestureTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    CGPoint center = btn.center;
    CGPoint point = [btn.superview convertPoint:center toView:(UITableView *)[self viewWithTag:kCategoryTableTag]];
    NSIndexPath *indexPath =[(UITableView *)[self viewWithTag:kCategoryTableTag] indexPathForRowAtPoint:point];
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:@"Hide" forKey:@"Header"];
    [(UITableView *)[self viewWithTag:kCategoryTableTag] reloadData];
    
    if ([self.delegate respondsToSelector:@selector(pushToEntityPageWithIndexPath:)])
    {
        [self.delegate pushToEntityPageWithIndexPath:indexPath];
        
    }
    
    
}

- (void)contentGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)[self viewWithTag:kCategoryTableTag];
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if ([self.delegate respondsToSelector:@selector(responseEntityPageWithDetails:)])
    {
        [self.delegate responseEntityPageWithDetails:[arrayCategories objectAtIndex:indexPath.row]];
    }
}

- (void)mapGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)[self viewWithTag:kCategoryTableTag];
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if ([self.delegate respondsToSelector:@selector(responseMapPageWithDetails:)])
    {
        [self.delegate responseMapPageWithDetails:[arrayCategories objectAtIndex:indexPath.row]];
    }
}

- (void)selfProfileGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)[self viewWithTag:kCategoryTableTag];
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if ([self.delegate respondsToSelector:@selector(responseSelfPageWithDetails:userType:)])
    {
        [self.delegate responseSelfPageWithDetails:[arrayCategories objectAtIndex:indexPath.row] userType:0];
    }
}

- (void)guestProfileGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)[self viewWithTag:kCategoryTableTag];
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    if ([self.delegate respondsToSelector:@selector(responseSelfPageWithDetails:userType:)])
    {
        [self.delegate responseSelfPageWithDetails:[arrayCategories objectAtIndex:indexPath.row] userType:1];
    }
}

#pragma mark - Buttom delegate
- (IBAction)referButtonTaped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableView *tableView = (UITableView *)[self viewWithTag:kCategoryTableTag];
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    
    if([self.delegate respondsToSelector:@selector(responseReferPageWithDetails:)])
    {
        [self.delegate responseReferPageWithDetails:[arrayCategories objectAtIndex:indexPath.row]];
    }

}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
