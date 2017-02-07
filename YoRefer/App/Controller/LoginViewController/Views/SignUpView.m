//
//  SignUp.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "SignUpView.h"
#import "Configuration.h"
#import "Helper.h"
#import "Utility.h"
#import "YoReferAPI.h"
#import <DigitsKit/DigitsKit.h>
#import "LoginViewController.h"

NSInteger const profilePictureTag        = 10000;
NSInteger const camerImgTag              = 20000;
NSInteger const conditionsImageTag       = 100;
NSInteger const kSignUpView              = 1400;
NSString    *   const kSignUpNowError        = @"Unable to get carousel";
NSString    *   const kSignUpLoading      = @"Loading...";

#define MAX_LENGTH 10


typedef enum {
    
    Name,
    UserEmail,
    Phone,
    Password,
    CountyCode
    
}Filedtype;


@interface SignUpDetail : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *dp;
@property (nonatomic, strong) NSString *countryCode;

@property (nonatomic, readwrite) BOOL  isValidPhoneNumber;

@end

@interface SignUpView ()<UITextFieldDelegate>

@property (nonatomic, strong) SignUpDetail *signUpDetail;

@end

@implementation SignUpView

@synthesize delegate = _delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<SignUp>)delegate
{
    self = [super init];
    
    if (self)
    {
        self.signUpDetail = [[SignUpDetail alloc]init];
        [self signUpWithFrame:frame];
        self.delegate = delegate;
        self.signUpDetail.isValidPhoneNumber = NO;
        self.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        
    }
    return self;
    
}

-(NSDictionary *)dictCountryCodes{
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"93", @"AF",@"20",@"EG", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    return dictCodes;
}


- (void)signUpWithFrame:(CGRect)frame
{
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view setTag:kSignUpView];
    [self addSubview:view];
    
    //Name
    xPos = 10.0;
    yPos = 30.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *nameView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:nameView];
    
    
    //camera view
    width = 40.0;
    height = 40.0;
    xPos = nameView.frame.size.width - width;
    yPos = 0.0;
    
    UIImageView *cameraImgView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    cameraImgView.tag = profilePictureTag;
    [cameraImgView setUserInteractionEnabled:YES];
    [cameraImgView setBackgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [cameraImgView.layer setCornerRadius:20.0];
    [cameraImgView.layer setMasksToBounds:YES];
    [nameView addSubview:cameraImgView];
    
    UITapGestureRecognizer *cameraGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cameraGestureTapped:)];
    [cameraImgView addGestureRecognizer:cameraGestureRecognizer];
    
    
    //
    //    UIView * cameraView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    //    [cameraView.layer setCornerRadius:20.0];
    //    [cameraView.layer setMasksToBounds:YES];
    //    [nameView addSubview:cameraView];
    //camera imageView
    width = 24.0;
    height = 18.0;
    xPos = round((cameraImgView.frame.size.width - width)/2);
    yPos = round((cameraImgView.frame.size.height - height)/2);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageView.tag = camerImgTag;
    [imageView setImage:[UIImage imageNamed:@"icon_camera.png"]];
    [cameraImgView addSubview:imageView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = nameView.frame.size.width - cameraImgView.frame.size.width;
    height = 40.0;
    UITextField *nameTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:Name];
    [nameView addSubview:nameTxt];
    
    //line
    xPos = 0.0;
    yPos = nameTxt.frame.size.height + 1.0;
    width = nameView.frame.size.width + cameraImgView.frame.size.width;
    height = 2.0;
    UIView *lineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [nameView addSubview:lineView];
    
    
    
    
    //Email
    xPos = 10.0;
    yPos = nameView.frame.size.height + nameView.frame.origin.y + 2.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *emailView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:emailView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = emailView.frame.size.width - 46.0;
    height = 40.0;
    UITextField *emailTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:UserEmail];
    [emailView addSubview:emailTxt];
    //line
    xPos = 0.0;
    yPos = emailTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *emailLineView  = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [emailView addSubview:emailLineView];
    
    
    //phone Number
    xPos = 10.0;
    yPos = emailView.frame.size.height + emailView.frame.origin.y + 2.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *phoneNumberView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:phoneNumberView];
    
    //Init
    xPos = 2.0;
    yPos = 0.0;
    width = 10.0;
    height = 40.0;
    
    
    UILabel *phoneInit = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"+" textColor:[UIColor grayColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [phoneNumberView addSubview:phoneInit];
    
    //Init
    xPos = 12.0;
    yPos = 0.0;
    width = 40.0;
    height = 40.0;

    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSDictionary *dict = [self dictCountryCodes];
    NSString *localNumberCode = dict[countryCode];
    NSString *numberWithContry = [NSString stringWithFormat:@"+%@",localNumberCode];

    
    //UIText filed
    UITextField *initCode = [[UITextField alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    initCode.tag = CountyCode;
    initCode.delegate = self;
    [initCode setText:[numberWithContry stringByReplacingOccurrencesOfString:@"+" withString:@""]];
    [initCode setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [initCode setTextColor:[UIColor grayColor]];
    [phoneNumberView addSubview:initCode];
    
    
    
    
    //verify
    width = 80.0;
    height = 35.0;
    xPos = phoneNumberView.frame.size.width - width;
    yPos = 0.0;
    UIButton *button = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Verify" backgroundColor:[UIColor colorWithRed:(3.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0]];
    [button.layer setCornerRadius:18.0];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:2.0];
    [button.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [button addTarget:self action:@selector(verifyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [phoneNumberView addSubview:button];
    
    
    xPos = initCode.frame.size.width;
    yPos = 0.0;
    width = phoneNumberView.frame.size.width - (initCode.frame.size.width + button.frame.size.width);
    height = 40.0;
    UITextField *phoneNumberTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:Phone];
    [phoneNumberView addSubview:phoneNumberTxt];
    //line
    xPos = 0.0;
    yPos = phoneNumberTxt.frame.size.height + 1.0;
    width = phoneNumberView.frame.size.width;
    height = 2.0;
    UIView *phoneNumberLineView  = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [phoneNumberView addSubview:phoneNumberLineView];
    
    //pawword
    xPos = 10.0;
    yPos = phoneNumberView.frame.size.height + phoneNumberView.frame.origin.y + 2.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *passwordview = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:passwordview];
    xPos = 0.0;
    yPos = 0.0;
    width = passwordview.frame.size.width - 46.0;
    height = 40.0;
    UITextField *passwordTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:Password];
    [passwordview addSubview:passwordTxt];
    //line
    xPos = 0.0;
    yPos = phoneNumberTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *passwordLineView  = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [passwordview addSubview:passwordLineView];
    
    //condition
    xPos = 0.0;
    yPos = passwordview.frame.size.height + passwordview.frame.origin.y + 20.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *conditionsView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:conditionsView];
    
    width = 15.0;
    height = 15.0;
    xPos = 20.0;
    yPos = 1.0;
    UIView *conditionsViewCheck = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    conditionsViewCheck.layer.borderColor = [[UIColor blackColor] CGColor];
    conditionsViewCheck.layer.borderWidth = 1.0;
    conditionsViewCheck.layer.masksToBounds = YES;
    [conditionsView addSubview:conditionsViewCheck];
    
    width = 15.0;
    height = 15.0;
    xPos = 20.0;
    yPos = 1.0;
    UIImageView *imageCheckMark = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageCheckMark.image = [UIImage imageNamed:@"icon_checkbox.png"];
    imageCheckMark.tag = conditionsImageTag;
    [conditionsView addSubview:imageCheckMark];
    
    width = conditionsView.frame.size.width - 30.0;
    height = 17.0;
    xPos = conditionsViewCheck.frame.size.width + conditionsViewCheck.frame.origin.x + 10.0;
    yPos = 0.0;
    UIView *conditionsLabels = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [conditionsView addSubview:conditionsLabels];
    
    NSString *iAgree = @"I agreed to YoRefer";
    NSString *tC = @" T & C";
    NSString *and = @" and ";
    NSString *privacy = @" Privacy Policies";
    
    CGFloat fontSize = ([self bounds].size.height > 520)?14.0:12.5;
    
    UIFont *font=[[Configuration shareConfiguration] yoReferFontWithSize:fontSize];
    CGSize iAgr = [iAgree sizeWithAttributes:@{NSFontAttributeName:font}];
    CGSize terms = [tC sizeWithAttributes:@{NSFontAttributeName:font}];
    CGSize an = [and sizeWithAttributes:@{NSFontAttributeName:font}];
    CGSize pri = [privacy sizeWithAttributes:@{NSFontAttributeName:font}];
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    xPos = 0.0;
    width = iAgr.width;
    UILabel *YoRefer = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:iAgree textColor:[UIColor blackColor]   font:[[Configuration shareConfiguration] yoReferFontWithSize:fontSize]];
    [YoRefer setTextAlignment:NSTextAlignmentCenter];
    [conditionsLabels addSubview:YoRefer];
    
    xPos = YoRefer.frame.size.width;
    width = terms.width;
    UILabel *tAndC = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:tC textColor:[UIColor blueColor]   font:[[Configuration shareConfiguration] yoReferFontWithSize:fontSize]];
    tAndC.attributedText = [[NSAttributedString alloc] initWithString:tC attributes:underlineAttribute];
    [tAndC setTextAlignment:NSTextAlignmentCenter];
    tAndC.userInteractionEnabled = YES;
    [conditionsLabels addSubview:tAndC];
    
    UITapGestureRecognizer *trms = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(termsAndConditions:)];
    [tAndC addGestureRecognizer:trms];
    
    xPos = YoRefer.frame.size.width + tAndC.frame.size.width;
    width = an.width;
    UILabel *aND = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:and textColor:[UIColor blackColor]   font:[[Configuration shareConfiguration] yoReferFontWithSize:fontSize]];
    [aND setTextAlignment:NSTextAlignmentCenter];
    [conditionsLabels addSubview:aND];
    
    xPos = YoRefer.frame.size.width + tAndC.frame.size.width + aND.frame.size.width;
    width = pri.width;
    UILabel *policy = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:privacy textColor:[UIColor blueColor]   font:[[Configuration shareConfiguration] yoReferFontWithSize:fontSize]];
    policy.attributedText = [[NSAttributedString alloc] initWithString:privacy attributes:underlineAttribute];
    policy.userInteractionEnabled = YES;
    [policy setTextAlignment:NSTextAlignmentCenter];
    [conditionsLabels addSubview:policy];
    
    UITapGestureRecognizer *plcy = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(privacyPolicy:)];
    [policy addGestureRecognizer:plcy];
    
    UITapGestureRecognizer *conditionsRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(conditionsViewTapped:)];
    [conditionsViewCheck addGestureRecognizer:conditionsRecognizer];
    
    //Signup Button
    xPos = 10.0;
    yPos = conditionsView.frame.size.height + conditionsView.frame.origin.y;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *loginButtonView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:loginButtonView];
    
    width = 173.0;
    height = 40.0;
    xPos = round((loginButtonView.frame.size.width - width)/2) - 10.0;
    yPos = round((loginButtonView.frame.size.height - height)/2);
    UIButton *loginBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Sign Up" backgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [loginBtn.layer setCornerRadius:20.0];
    [loginBtn.layer setMasksToBounds:YES];
    [loginBtn.layer setBorderWidth:2.0];
    [loginBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [loginBtn addTarget:self action:@selector(signUpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [loginButtonView addSubview:loginBtn];
    
    //Already have an account?
    xPos = 10.0;
    yPos = loginButtonView.frame.size.height + loginButtonView.frame.origin.y + 14.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *accountView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:accountView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accountViewTapped:)];
    [accountView addGestureRecognizer:gestureRecognizer];
    
    width = 168.0;
    height = 30.0;
    xPos = roundf((accountView.frame.size.width - width)/2);
    yPos = roundf((accountView.frame.size.height - height)/2);
    UILabel *accountLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Already have an account?" textColor:[UIColor blackColor]font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [accountView addSubview:accountLbl];
    
    
}

- (void)termsAndConditions:(UITapGestureRecognizer *)gestureRecognizer
{
    LoginViewController *obj = [[LoginViewController alloc]init];
    [obj termsAndConditions];
    
}

- (void)privacyPolicy:(UITapGestureRecognizer *)gestureRecognizer
{
    LoginViewController *obj = [[LoginViewController alloc]init];
    [obj privacyPolicy];
    
}

- (UIButton *)createButtonWithFrame:(CGRect)frame titil:(NSString *)title backgroundColor:(UIColor *)backgroundColor
{
    
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    [button setBackgroundColor:backgroundColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button.layer setCornerRadius:16.0];
    [button.titleLabel setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:14.0]];
    [button.layer setMasksToBounds:YES];
    return button;
    
    
}

- (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textCOlor font:(UIFont *)font
{
    
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setText:NSLocalizedString(text, @"")];
    [label setFont:font];
    [label setTextColor:textCOlor];
    return label;
    
}

- (UIView *)createViewWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor
{
    
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:backgroundColor];
    return view;
    
}

- (UIReturnKeyType )returnTypeWithFieldType:(Filedtype)filedType
{
    if (filedType == Password) {
        return UIReturnKeyDone;
    }
    return UIReturnKeyDefault;
}

- (UITextField *)createTextFiledWithFrame:(CGRect)frame  filedType:(Filedtype)filedType
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:filedType];
    [textField setDelegate:self];
    [textField setReturnKeyType:[self returnTypeWithFieldType:filedType]];
    [textField setSecureTextEntry:[self setSecuretextWithFiledType:filedType]];
    [textField setPlaceholder:[self placeHoldeWithfildType:filedType]];
    [textField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    //[textField setValue:[UIColor grayColor] forKey:@"_placeholderLabel.textColor"];
    [textField setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [textField.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:0.0];
    [textField.layer setMasksToBounds:YES];
    [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setTextAlignment:NSTextAlignmentCenter];
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self placeHoldeWithfildType:filedType] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    } else {
        
        
    }
    
    [textField setKeyboardType:[self setKeyBoardWithFiledType:filedType]];
    
    
    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, textField.frame.size.height)];
    //    leftView.backgroundColor = [UIColor clearColor];
    //    textField.leftViewMode = UITextFieldViewModeAlways;
    //    textField.leftView = leftView;
    //[textField becomeFirstResponder];
    return textField;
    
}

- (UIKeyboardType)setKeyBoardWithFiledType:(Filedtype)filedType
{
    
    UIKeyboardType keyBoardType;
    
    switch (filedType) {
        case Phone:
            keyBoardType = UIKeyboardTypeNumberPad;
            break;
        default:
            keyBoardType = UIKeyboardTypeAlphabet;
            break;
    }
    
    return keyBoardType;
}



- (NSString *)placeHoldeWithfildType:(Filedtype)filedType
{
    NSString *placeHolder = nil;
    
    switch (filedType) {
        case Name:
            placeHolder = @"Name";
            break;
        case UserEmail:
            placeHolder = @"Email(Optional)";
            break;
        case Phone:
            placeHolder = @"Mobile Number";
            break;
        case Password:
            placeHolder = @"Password";
            break;
            
            
        default:
            break;
    }
    
    return NSLocalizedString(placeHolder, @"");
    
}

- (BOOL)setSecuretextWithFiledType:(Filedtype)fieldType
{
    
    return (fieldType == Password);
    
}


#pragma mark - textfiled delegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    [textField resignFirstResponder];
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *nextField =[self getNextFiledFromCurrentField:textField];
    if (nextField != nil) {
        
        [nextField becomeFirstResponder];
        return NO;
    }
    else
    {
        if(textField.tag == Password)
        {
            [textField resignFirstResponder];
            //[self signUpButtonTapped:nil];
        }
        
    }
    
    
    [textField resignFirstResponder];
    
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    [self setToolBarWithFiledType:(Filedtype)textField.tag textFiled:textField];
    
    if ([self.delegate respondsToSelector:@selector(showAnimatedWithTextFiled:)])
    {
        [self.delegate showAnimatedWithTextFiled:textField];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == CountyCode)
    {
        if (textField.text.length >= 3 && range.length == 0) {
            return NO; // Change not allowed
        } else {
            return YES; // Change allowed
        }
    }
    
    // Dev changed for 10 digits allowed to be entered in Phone field. ==========================

    if (textField.tag ==  Phone) {
        
        if (textField.text.length >= MAX_LENGTH && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else
        {
            return YES;
        }
    }
    //===========================================================================================
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(hideAnimatedWithTextFiled:)])
    {
        [self.delegate hideAnimatedWithTextFiled:textField];
    }
    
    [self setTextFromTextFiled:textField filedType:(Filedtype)textField.tag];
    
    //  [self animateTextField:textField isUp:NO];
    
    
    
}


- (void)setTextFromTextFiled:(UITextField *)textField filedType:(Filedtype)filedType
{
    
    
    switch (filedType) {
        case Name:
            self.signUpDetail.userName = textField.text;
            break;
        case UserEmail:
            self.signUpDetail.userEmail = textField.text;
            break;
        case Phone:
            self.signUpDetail.phoneNumber = textField.text;
            break;
        case Password:
            self.signUpDetail.password = textField.text;
            break;
        case CountyCode:
            self.signUpDetail.countryCode = textField.text;
            break;
        default:
            break;
    }
    
}

- (UITextField *)getNextFiledFromCurrentField:(UITextField *)textField
{
    
    UITextField *nextField = nil;
    
    Filedtype filedType = (Filedtype)textField.tag;
    
    switch (filedType) {
        case Name:
            nextField = (UITextField *)[self viewWithTag:UserEmail];
            break;
        case UserEmail:
            nextField = (UITextField *)[self viewWithTag:Phone];
            nextField.returnKeyType = UIReturnKeyDone;
            break;
        case Password:
            break;
            
        default:
            break;
    }
    
    return nextField;
    
}



- (void)setToolBarWithFiledType:(Filedtype)filedType textFiled:(UITextField *)textField
{
    
    if(textField.tag == Phone ){
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleDefault;
        
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTapped:)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)],
                               nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
    }
    
    
}


- (IBAction)cancelButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
}

- (IBAction)doneButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
}


#pragma mark  - GestureRecognizer
- (void)accountViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([self.delegate respondsToSelector:@selector(login:)])
    {
        [self.delegate login:nil];
        
    }
    
}

#pragma mark  - Button delegate

- (IBAction)signUpButtonTapped:(id)sender
{
    [self endEditing:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:self.signUpDetail.dp forKey:@"dp"];
    [params setValue:self.signUpDetail.userName forKey:@"name"];
    [params setValue:self.signUpDetail.userEmail forKey:@"emailId"];
//    [params setValue:[NSString stringWithFormat:@"+%@%@",self.signUpDetail.countryCode,self.signUpDetail.phoneNumber] forKey:@"number"];
    [params setValue:[NSString stringWithFormat:@"%@",self.signUpDetail.phoneNumber] forKey:@"number"];

    [params setValue:self.signUpDetail.password forKey:@"password"];
    
    NSArray *error = nil;
    BOOL isValidate = [[Helper shareHelper] validateSignUpAllEnteriesWithError:&error params:params];
    if (!isValidate)
    {
        
        NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
        alertView([[Configuration shareConfiguration] errorMessage], errorMessage, nil, @"Ok", nil, 0);
        return;
        
    }
    
    /*
    if (![[Helper shareHelper] emailValidationWithEmail:self.signUpDetail.userEmail])
    {
        alertView([[Configuration shareConfiguration] errorMessage], @"Please enter valid E-mail address", nil, @"Ok", nil, 0);
        return;
    }
    */
    
    if (!self.signUpDetail.isValidPhoneNumber)
    {
        alertView([[Configuration shareConfiguration] errorMessage], @"Please verify your phone number", nil, @"Ok", nil, 0);
        return;
    }

    NSLog(@"Signup Params === %@", params);
    
    if ([self.delegate respondsToSelector:@selector(signUpWithParams:)])
    {
        
        [self.delegate signUpWithParams:params];
        
    }
    
}


- (IBAction)verifyButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
    Digits *digits = [Digits sharedInstance];
    
    [digits authenticateWithPhoneNumber:self.signUpDetail.phoneNumber digitsAppearance:nil viewController:nil title:@"Yorefer" completion:^(DGTSession *session, NSError *error) {
        
        NSLog(@"authToken=%@ authTokenSecret=%@ userID=%@ phoneNumber=%@",session.authToken,session.authTokenSecret,session.userID,session.phoneNumber);
        [digits logOut];
        
        if (session.authToken != nil && [session.authToken length] >0 && session.phoneNumber !=nil && [session.phoneNumber length] > 0){
            NSArray *array = [[self viewWithTag:kSignUpView] subviews];
            UIButton *button = [[(UIButton *)[array objectAtIndex:2] subviews] objectAtIndex:2];
            [button setUserInteractionEnabled:NO];
            [button setAlpha:0.25];
            self.signUpDetail.isValidPhoneNumber = YES;
            self.signUpDetail.phoneNumber = session.phoneNumber;
            
        }
        
        // Country selector will be set to Spain and phone number field will be set to 5555555555
    }];
    
    
}

#pragma mark - Protocol

- (void)getProfilePicture:(NSMutableDictionary *)profilePicture
{
    self.signUpDetail.dp = @"Uploaded";
    
    [(UIImageView *)[self viewWithTag:camerImgTag] setHidden:YES];
    [(UIImageView *)[self viewWithTag:profilePictureTag] setImage:[profilePicture objectForKey:@"image"]];
    
    UIImage *scaleImage = [[Helper shareHelper] scaleImage:[profilePicture objectForKey:@"image"] toSize:CGSizeMake(320.0,320.0)];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
    [param setValue:scaleImage forKey:@"profileImage"];
    
    [[YoReferAPI sharedAPI] uploadImageWithParam:param completionHandler:^(NSDictionary *response , NSError *error)
     {
         
         [self didReceiveWithImageResponse:response error:error];
         
         
     }];

}

- (void)didReceiveWithImageResponse:(NSDictionary *)response error:(NSError *)error
{
    
    if (error !=nil)
    {
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }else
        {
            
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kSignUpNowError, @""), nil, @"Ok", nil, 0);
            
        }
    }else
    {
        self.signUpDetail.dp = [response objectForKey:@"response"];
        
    }
    
}

#pragma mark - GestureRecognizer

- (void)cameraGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [[YoReferMedia shareMedia] setMediaWithDelegate:self title:@"Select Picture"];
    
}


#pragma mark -

- (void)conditionsViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([(UIImageView *)[self viewWithTag:conditionsImageTag] image] == nil) {
        
        [(UIImageView *)[self viewWithTag:conditionsImageTag] setImage:[UIImage imageNamed:@"icon_checkbox.png"]];
        
    }else{
        [(UIImageView *)[self viewWithTag:conditionsImageTag] setImage:[UIImage imageNamed:@""]];
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

@implementation SignUpDetail


@end
