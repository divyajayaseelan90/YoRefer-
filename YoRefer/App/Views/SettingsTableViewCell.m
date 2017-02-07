//
//  SettingsTableViewCell.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "Configuration.h"
#import "UserManager.h"
#import "LocationManager.h"

NSString * const kSettingsIdentifier = @"Identifire";


@implementation SettingsTableViewCell

@synthesize delegate = _delegate;


#pragma mark - instancetype

- (instancetype)initWihtIndexPath:(NSIndexPath *)indexPath delegate:(id<settings>)delegate
{
    
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSettingsIdentifier];
    if (self)
    {
        
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createSettingsViewWithIndexPath:indexPath];
        
        
    }
    
    return self;
    
    
}

- (void)createSettingsViewWithIndexPath:(NSIndexPath *)indexPath
{
    
    CGRect frame = [self bounds];
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = self.frame.size.height;
    //titile
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = indexPath.row;
    [self.contentView addSubview:view];
    xPos = 6.0;
    height = self.frame.size.height;
    width = 200.0;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [label setText:[self titleFromSettingsType:(settingsType)indexPath.row]];
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:16.0]];
    [view addSubview:label];
    //line view
    xPos = 0.0;
    yPos = 44.0;
    width = frame.size.width;
    height = 1.0;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(settingsGestureTapped:)];
    [view addGestureRecognizer:gestureRecognizer];
    [view addSubview:viewLine];
    //disclosureIndicator.
    
    width = 16.0;
    height = 16.0;
    xPos = view.frame.size.width - (width + 10.0);
    yPos = round((view.frame.size.height - height)/2);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:[UIImage imageNamed:@"icon_disclosureIndicator.png"]];
    [view addSubview:imageView];
    
    if (indexPath.row == 2) {
        
        imageView.hidden = YES;
        CGFloat xPos = frame.size.width - 60.0;
        CGFloat yPos = 7.0;
        CGFloat width = 50.0;
        CGFloat height = 50.0;
        UISwitch *locationSwitchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
        
        
        if ([[UserManager shareUserManager] getLocationService])
            [locationSwitchBtn setOn:YES animated:NO];
        else
            [locationSwitchBtn setOn:NO animated:NO];
        [locationSwitchBtn addTarget:self action:@selector(switchState:) forControlEvents:UIControlEventValueChanged];
        [locationSwitchBtn setOnTintColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
        [view addSubview:locationSwitchBtn];
        
    }
    else if (indexPath.row == 7)
    {
        imageView.hidden = YES;
        NSString *version=[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
        xPos = frame.size.width - 70.0;
        yPos = 0.0;
        height = self.frame.size.height;
        width = 60.0;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [label setTextColor:[UIColor grayColor]];
        [label setText:version];
        label.textAlignment = NSTextAlignmentRight;
        [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:16.0]];
        [view addSubview:label];
    }
    
}



- (NSString *)titleFromSettingsType:(settingsType)settingsType
{
    
    NSString *string;
    
    switch (settingsType) {
        case SettingsProfile:
            string = @"Change Profile";
            break;
        case ChangePassword:
            string = @"Change Password";
            break;
        case NearByLocationServices:
            string = @"Nearby Location Services";
            break;
        case ReferChannels:
            string = @"Refer Channels";
            break;
        case TermsAndConditions:
            string = @"Terms Of Use";
            break;
        case PrivacyPolicy:
            string = @"Privacy Policy";
            break;
        case AboutUs:
            string = @"About Us";
            break;
        case YoreferVersion:
            string = @"Yorefer Version";
            break;
        case SendFeedBack:
            string = @"Send Us Feedback";
            break;
        case SettingsLogOut:
            string = @"Log Out";
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

#pragma mark - Button delegate
- (IBAction)switchState:(UISwitch *)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    
    if ([mySwitch isOn]) {
       
        
        BOOL isLocation = [[LocationManager shareLocationManager] CheckForLocationService];
        if (!isLocation){
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }else
        {
            [[UserManager shareUserManager] enableLocation];
        }
        
    } else {
        
        [[UserManager shareUserManager] disableLocation];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationupdating" object:nil userInfo:nil];
    
}





#pragma mark  -
- (void)settingsGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([self.delegate respondsToSelector:@selector(pushSettingType:)])
    {
        
        [self.delegate pushSettingType:(settingsType)gestureRecognizer.view.tag];
        
    }
    
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
