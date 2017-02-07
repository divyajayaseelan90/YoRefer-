//
//  EnterOTP.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "EnterOTPView.h"
#import "Configuration.h"
#import "Helper.h"
#import "Utility.h"


typedef enum {
    
    OTP,
    Password,
    ResendOTP
    
}Filedtype;


@interface OTPDetail : NSObject

@property (nonatomic, strong) NSString *otp;
@property (nonatomic, strong) NSString *password;


@end

@interface EnterOTPView ()<UITextFieldDelegate>

@property (strong, nonatomic) OTPDetail *otpDetail;

@end


@implementation EnterOTPView
@synthesize delegate = _delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<OTP>)delegate
{
    self = [super init];
    
    if (self)
    {
        self.otpDetail = [[OTPDetail alloc]init];
        [self enterOTPWithFrame:frame];
        self.delegate = delegate;
        self.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        
    }
    return self;
    
}


- (void)enterOTPWithFrame:(CGRect)frame
{
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [self addSubview:view];
    
    //Email
    xPos = 10.0;
    yPos = 30.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *emailView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:emailView];
    xPos = 0.0;
    yPos = 0.0;
    width = emailView.frame.size.width;
    height = 40.0;
    UITextField *emailTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:OTP];
    [emailView addSubview:emailTxt];
    //line
    xPos = 0.0;
    yPos = emailTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *lineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [emailView addSubview:lineView];
    
    //password
    xPos = 10.0;
    yPos = emailView.frame.size.height + emailView.frame.origin.y + 2.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *mobileView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:mobileView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = emailView.frame.size.width;
    height = 40.0;
    UITextField *mobileTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height)filedType:Password];
    [mobileView addSubview:mobileTxt];
    //line
    xPos = 0.0;
    yPos = mobileTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *passwordLineView  = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [mobileView addSubview:passwordLineView];
    
    //resend OTP
    xPos = 10.0;
    yPos = mobileView.frame.size.height + mobileView.frame.origin.y + 15.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *resendOTPView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:resendOTPView];
    
    UITapGestureRecognizer *resendOTPGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resendOTPViewTapped:)];
    [resendOTPView addGestureRecognizer:resendOTPGestureRecognizer];
    
    width = 90.0;
    height = 30.0;
    xPos = roundf((resendOTPView.frame.size.width - width)/2);
    yPos = roundf((resendOTPView.frame.size.height - height)/2);
    UILabel *passwordLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Resend OTP" textColor:[UIColor grayColor]font:[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]];
    [resendOTPView addSubview:passwordLbl];
    
    //request password Button
    xPos = 10.0;
    yPos = resendOTPView.frame.size.height + resendOTPView.frame.origin.y + 20.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *loginButtonView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:loginButtonView];
    
    width = 160.0;
    height = 40.0;
    xPos = round((loginButtonView.frame.size.width - width)/2);
    yPos = round((loginButtonView.frame.size.height - height)/2);
    UIButton *loginBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Login" backgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [loginBtn.layer setCornerRadius:20.0];
    [loginBtn.layer setMasksToBounds:YES];
    [loginBtn.layer setBorderWidth:2.0];
    [loginBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [loginBtn addTarget:self action:@selector(loginBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [loginButtonView addSubview:loginBtn];
    

    
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

- (UITextField *)createTextFiledWithFrame:(CGRect)frame filedType:(Filedtype)filedType
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:filedType];
    [textField setDelegate:self];
    [textField setSecureTextEntry:[self setSecuretextWithFiledType:filedType]];
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
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithFiledType:filedType] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    } else {
        
        
    }
    
    [textField setPlaceholder:[self setPlaceHolderWithFiledType:filedType]];
    
    
    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, textField.frame.size.height)];
    //    leftView.backgroundColor = [UIColor clearColor];
    //    textField.leftViewMode = UITextFieldViewModeAlways;
    //    textField.leftView = leftView;
    //[textField becomeFirstResponder];
    return textField;
    
}

- (NSString *)setPlaceHolderWithFiledType:(Filedtype)fieldType
{
    NSString *string = nil;
    
    switch (fieldType) {
        case OTP:
            string = @"Enter OTP";
            break;
        case Password:
            string = @"Password";
            break;
        default:
            break;
    }
    
    return NSLocalizedString(string, @"");
    
}


- (BOOL)setSecuretextWithFiledType:(Filedtype)fieldType
{
    
    return (fieldType == Password);
    
}

#pragma mark - textfiled delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *nextField =[self getNextFiledFromCurrentField:textField];
    if (nextField != nil) {
        
        [nextField becomeFirstResponder];
        return NO;
    }
    else
    {
        [textField resignFirstResponder];
        
    }
    
    return YES;
    
}


- (void)setTextBar:(UITextField *)searchbar
{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTapped:)],
                           nil];
    [numberToolbar sizeToFit];
    searchbar.inputAccessoryView = numberToolbar;
    
    
}

- (IBAction)cancelButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    [self setTextBar:textField];
    
    if ([self.delegate respondsToSelector:@selector(showAnimatedWithTextFiled:)])
    {
        [self.delegate showAnimatedWithTextFiled:textField];
    }
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(hideAnimatedWithTextFiled:)])
    {
        [self.delegate hideAnimatedWithTextFiled:textField];
    }
    
    [self populatedTextFromTextFiled:textField filedType:(Filedtype)textField.tag];
    
    //  [self animateTextField:textField isUp:NO];
    
}

- (void)populatedTextFromTextFiled:(UITextField *)textField filedType:(Filedtype)filedType
{
    
    switch (filedType) {
        case OTP:
            self.otpDetail.otp = textField.text;
            break;
        case Password:
            self.otpDetail.password = textField.text;
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
        case OTP:
            nextField = (UITextField *)[self viewWithTag:Password];
            break;
        case Password:
            nextField = (UITextField *)[self viewWithTag:ResendOTP];
            break;
        case ResendOTP:
            break;
            
        default:
            break;
    }
    
    return nextField;
    
}


#pragma mark - GestureRecognizer

- (void)resendOTPViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([self.delegate respondsToSelector:@selector(ForgotPassword)])
    {
        [self.delegate ForgotPassword];
    }
    
}

#pragma mark - Button dlegate

- (IBAction)loginBtnTapped:(id)sender
{
 
    [self endEditing:YES];
    
    NSArray *error = nil;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:self.otpDetail.otp forKey:@"otp"];
    [params setValue:self.otpDetail.password forKey:@"password"];
    
    BOOL isvlidate = [[Helper shareHelper] validateOTPAllEnteriesWithError:&error params:params];
    if (!isvlidate)
    {
        NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
        alertView([[Configuration shareConfiguration] errorMessage], errorMessage, nil, @"Ok", nil, 0);
        return;
        
    }

    if ([self.delegate respondsToSelector:@selector(enterOPTWithParams:)])
    {
        
        [self.delegate enterOPTWithParams:params];
        
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


@implementation OTPDetail



@end