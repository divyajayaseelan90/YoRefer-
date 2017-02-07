//
//  ReferChannelsTableViewCell.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ReferChannelsTableViewCell.h"
#import "Configuration.h"
#import "YoReferUserDefaults.h"
#import "YoReferSocialChannels.h"

NSString * const kReferChannel = @"referchannel";

typedef enum
{
    SMS,
    Email,
    Whatsapp,
    Facebook,
    Twitter,
    Pointerest
    
}ReferchannelsType;

NSString * const kReferChannelIdentifier = @"identifier";

@implementation ReferChannelsTableViewCell

@synthesize delegate = _delegate;


- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ReferChannel>)delegate

{
    self  = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReferChannelIdentifier];
    if (self)
    {
        
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createReferChannelsWithIndexPath:indexPath];
        
        
    }
    
    return self;
}



- (void)createReferChannelsWithIndexPath:(NSIndexPath *)indexPath
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = self.frame.size.height;
    CGFloat width = frame.size.width;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = indexPath.row;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referChannelGestureTapped:)];
    [view addGestureRecognizer:gestureRecognizer];
    [self.contentView addSubview:view];
    //titile
    xPos = 6.0;
    width = 100.0;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [label setText:[self titleWithReferChannelType:(ReferchannelsType)indexPath.row]];
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [view addSubview:label];
    
    //line view
    xPos = 0.0;
    yPos = 44.0;
    width = frame.size.width;
    height = 1.0;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:viewLine];
    
    //track
    width = 24.0;
    height = 24.0;
    xPos = frame.size.width - (width + 10.0);
    yPos = roundf((self.frame.size.height - height)/2);
    NSLog(@"%ld",indexPath.row);
    UIImageView *imageTick = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    if ([self getSocialSahringWithReferChannelType:(ReferchannelsType)indexPath.row]){
        
        imageTick.image = [UIImage imageNamed:@"icon_tick.png"];
    }else
    {
        imageTick.image = [UIImage imageNamed:@""];
    }
    imageTick.backgroundColor = [UIColor whiteColor];
    imageTick.layer.cornerRadius = 12.0;
    imageTick.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    imageTick.layer.borderWidth = 1.0;
    imageTick.layer.masksToBounds = YES;
    [view addSubview:imageTick];

    
}


- (NSString *)titleWithReferChannelType:(ReferchannelsType)referChannelsType
{
    
    NSString *string;
    
    switch (referChannelsType) {
        case Facebook:
            string = @"Facebook";
            break;
        case Twitter:
            string = @"Twitter";
            break;
        case Whatsapp:
            string = @"Whatsapp";
            break;
        case SMS:
            string = @"SMS";
            break;
        case Email:
            string = @"Email";
            break;
        case Pointerest:
            string = @"Pointerest";
            break;
        default:
            break;
    }
    
    return NSLocalizedString(string, nil);
}


- (CGRect)bounds
{
    
    return [[UIScreen mainScreen] bounds];
    
}

#pragma mark - 
- (void)referChannelGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    
    NSArray *array = [gestureRecognizer.view subviews];
    
    UIImageView *imageView = (UIImageView *)[array objectAtIndex:2];
    
    if (imageView.image)
    {
        [imageView setImage:[UIImage imageNamed:@""]];
        [self setSocialSahringWithReferChannelType:(ReferchannelsType)gestureRecognizer.view.tag];
        
    }else
    {
        
        [imageView setImage:[UIImage imageNamed:@"icon_tick.png"]];
        [self setSocialSahringWithReferChannelType:(ReferchannelsType)gestureRecognizer.view.tag];
        
    }
    
    
    
}

#pragma amrk - social sharing

- (void)setSocialSahringWithReferChannelType:(ReferchannelsType)referChannelType
{
    
    switch (referChannelType) {
        case Facebook:
            [[YoReferSocialChannels shareYoReferSocial]setFaceBookSharing];
            break;
        case Twitter:
            [[YoReferSocialChannels shareYoReferSocial]setTwitterSharing];
            break;
        case Whatsapp:
            [[YoReferSocialChannels shareYoReferSocial]setWhatsappSharing];
            break;
        case SMS:
            [[YoReferSocialChannels shareYoReferSocial]setSmsSharing];
            break;
        case Email:
            [[YoReferSocialChannels shareYoReferSocial]setEmailSharing];
            break;
        case Pointerest:
            [[YoReferSocialChannels shareYoReferSocial]setPointerestSharing];
            break;
            
        default:
            break;
    }
    
    
}

- (BOOL)getSocialSahringWithReferChannelType:(ReferchannelsType)referChannelType
{
    
    BOOL sharing = NO;
    
    switch (referChannelType) {
        case Facebook:
           sharing =  [[YoReferSocialChannels shareYoReferSocial]getFaceBookSahring];
            break;
        case Twitter:
            sharing = [[YoReferSocialChannels shareYoReferSocial]getTwitterSahring];
            break;
        case Whatsapp:
            sharing = [[YoReferSocialChannels shareYoReferSocial]getWhatsappSahring];
            break;
        case SMS:
            sharing = [[YoReferSocialChannels shareYoReferSocial]getSmsSahring];
            break;
        case Email:
            sharing = [[YoReferSocialChannels shareYoReferSocial]getEmailSahring];
            break;
        case Pointerest:
            sharing = [[YoReferSocialChannels shareYoReferSocial]getPointerestSahring];
            break;
            
        default:
            break;
    }
    
    return sharing;
    
}

#pragma mark - awakeFromNib
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
