//
//  ForgotPassword.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ForgotPasswordView.h"
#import "Configuration.h"
#import "Helper.h"
#import "Utility.h"
#import <DigitsKit/DigitsKit.h>


typedef enum {
    
    UserPassword,
    UserConfPassword,
    Mobile
    
}Filedtype;

NSInteger const kForgotPasswordView = 14000;

@interface ForgotPasswordDetail : NSObject

@property (nonatomic, strong) NSString *userPassword, *userConformPassword;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, readwrite) BOOL  isValidPhoneNumber;


@end

@interface ForgotPasswordView ()<UITextFieldDelegate>

@property (nonatomic, strong) ForgotPasswordDetail *forgotPasswordDetail;

@end


@implementation ForgotPasswordView
@synthesize delegate = _delegate;


- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<ForgotPassword>)delegate
{
    self = [super init];
    
    if (self)
    {
        self.forgotPasswordDetail = [[ForgotPasswordDetail alloc]init];
        [self forgotPasswordWithFrame:frame];
        self.delegate = delegate;
        self.forgotPasswordDetail.isValidPhoneNumber = NO;
        self.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        
    }
    return self;
    
}


- (void)forgotPasswordWithFrame:(CGRect)frame
{
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view setTag:kForgotPasswordView];
    [self addSubview:view];
    
    //Password
    xPos = 10.0;
    yPos = 30.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *passwordView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:passwordView];
    xPos = 0.0;
    yPos = 0.0;
    width = passwordView.frame.size.width;
    height = 40.0;
    UITextField *passwordTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:UserPassword];
    [passwordView addSubview:passwordTxt];
    //line
    xPos = 0.0;
    yPos = passwordTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *passwordLineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [passwordView addSubview:passwordLineView];
    
    //ConfPassword
    xPos = 10.0;
    yPos = passwordView.frame.size.height + passwordView.frame.origin.y;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *confPasswordView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:confPasswordView];
    xPos = 0.0;
    yPos = 0.0;
    width = passwordView.frame.size.width;
    height = 40.0;
    UITextField *conPasswordTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) filedType:UserConfPassword];
    [confPasswordView addSubview:conPasswordTxt];
    //line
    xPos = 0.0;
    yPos = passwordTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *confPasswordLineView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [confPasswordView addSubview:confPasswordLineView];
    
    //Verfiy Button
    xPos = 10.0;
    yPos = confPasswordView.frame.size.height + confPasswordView.frame.origin.y + 2.0;
    width = view.frame.size.width - 20.0;
    height = 54.0;
    UIView *mobileView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:mobileView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = mobileView.frame.size.width;
    height = 40.0;
    UITextField *mobileTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height)filedType:Mobile];
    [mobileView addSubview:mobileTxt];
    
    width = 80.0;
    height = 35.0;
    xPos = mobileTxt.frame.size.width - width;
    yPos = 4.0;
    UIButton *button = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Verify" backgroundColor:[UIColor colorWithRed:(3.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0]];
    [button.layer setCornerRadius:18.0];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:2.0];
    [button.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [button addTarget:self action:@selector(verifyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mobileView addSubview:button];
    
    //line
    xPos = 0.0;
    yPos = mobileTxt.frame.size.height + 1.0;
    height = 2.0;
    width = mobileView.frame.size.width;
    UIView *passwordLineViewq  = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [mobileView addSubview:passwordLineViewq];
    
    
    //request password Button
    xPos = 10.0;
    yPos = mobileView.frame.size.height + mobileView.frame.origin.y + 5.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *loginButtonView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:loginButtonView];
    
    width = 160.0;
    height = 40.0;
    xPos = round((loginButtonView.frame.size.width - width)/2);
    yPos = round((loginButtonView.frame.size.height - height)/2);
    UIButton *requestBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Change Password" backgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [requestBtn.layer setCornerRadius:20.0];
    [requestBtn.layer setMasksToBounds:YES];
    [requestBtn.layer setBorderWidth:2.0];
    [requestBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [requestBtn addTarget:self action:@selector(requestButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [loginButtonView addSubview:requestBtn];
    
    
}


- (IBAction)verifyButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
    Digits *digits = [Digits sharedInstance];
    
    [digits authenticateWithPhoneNumber:self.forgotPasswordDetail.mobile digitsAppearance:nil viewController:nil title:@"Yorefer" completion:^(DGTSession *session, NSError *error) {
        NSLog(@"authToken=%@ authTokenSecret=%@ userID=%@ phoneNumber=%@",session.authToken,session.authTokenSecret,session.userID,session.phoneNumber);
        [digits logOut];
        
        if (session.authToken != nil && [session.authToken length] >0 && session.phoneNumber !=nil && [session.phoneNumber length] > 0){
            NSArray *array = [[self viewWithTag:kForgotPasswordView] subviews];
            UIButton *button = [[(UIButton *)[array objectAtIndex:2] subviews] objectAtIndex:1];
            [button setUserInteractionEnabled:NO];
            [button setAlpha:0.25];
            self.forgotPasswordDetail.isValidPhoneNumber = YES;
            self.forgotPasswordDetail.mobile = session.phoneNumber;
            
        }
        
        // Country selector will be set to Spain and phone number field will be set to 5555555555
    }];
    
    
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

- (UITextField *)createTextFiledWithFrame:(CGRect)frame  filedType:(Filedtype)filedType
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:filedType];
    [textField setDelegate:self];
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
    [textField setKeyboardType:[self setKeyBoardWithFiledType:filedType]];
    [textField setSecureTextEntry:[self setSecuretextWithFiledType:filedType]];
    
    
    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, textField.frame.size.height)];
    //    leftView.backgroundColor = [UIColor clearColor];
    //    textField.leftViewMode = UITextFieldViewModeAlways;
    //    textField.leftView = leftView;
    
    //[textField becomeFirstResponder];
    return textField;
    
}

- (BOOL)setSecuretextWithFiledType:(Filedtype)fieldType
{
    
    return (fieldType == UserPassword || fieldType == UserConfPassword );
    
}


- (NSString *)setPlaceHolderWithFiledType:(Filedtype)fieldType
{
    NSString *string = nil;
    
    switch (fieldType) {
        case Mobile:
            string = @"Mobile number";
            break;
        case UserPassword:
            string = @"New password";
            break;
        case UserConfPassword:
            string = @"Confirm new password";
            break;
        default:
            break;
    }
    
    return NSLocalizedString(string, @"");
    
}



- (UIKeyboardType)setKeyBoardWithFiledType:(Filedtype)filedType
{
    
    UIKeyboardType keyBoardType;
    
    switch (filedType) {
        case Mobile:
            keyBoardType = UIKeyboardTypeNumberPad;
            break;
        case UserPassword:
            keyBoardType = UIKeyboardTypeAlphabet;
            break;
        case UserConfPassword:
            keyBoardType = UIKeyboardTypeAlphabet;
            break;
            
        default:
            keyBoardType = UIKeyboardTypeAlphabet;
            break;
    }
    
    return keyBoardType;
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
        [textField resignFirstResponder];
        
    }
    
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
        case UserPassword:
            self.forgotPasswordDetail.userPassword = textField.text;
            break;
        case UserConfPassword:
            self.forgotPasswordDetail.userConformPassword = textField.text;
            break;
        case Mobile:
            self.forgotPasswordDetail.mobile = textField.text;
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
        case UserPassword:
            nextField = (UITextField *)[self viewWithTag:UserConfPassword];
            break;
        case UserConfPassword:
            nextField = (UITextField *)[self viewWithTag:Mobile];
            break;
        case Mobile:
            break;
            
        default:
            break;
    }
    
    return nextField;
    
}



- (void)setToolBarWithFiledType:(Filedtype)filedType textFiled:(UITextField *)textField
{
    
    if(textField.tag == Mobile ){
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

#pragma mark - Button delegate

- (IBAction)requestButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
    if (!self.forgotPasswordDetail.isValidPhoneNumber)
    {
         alertView([[Configuration shareConfiguration] errorMessage], @"Please verify your phone number", nil, @"Ok", nil, 0);
        return;
    }
    
    if (![self.forgotPasswordDetail.userPassword isEqualToString:self.forgotPasswordDetail.userConformPassword])
    {
        
        alertView([[Configuration shareConfiguration] errorMessage], @"Passwords did not matched", nil, @"Ok", nil, 0);
        return;
        
        
    }
    //[[Helper shareHelper] getLocalCountryCode]
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:self.forgotPasswordDetail.userPassword forKey:@"password"];
    [params setValue:[NSString stringWithFormat:@"%@",self.forgotPasswordDetail.mobile] forKey:@"resetToken"];
    NSData *data = [[params valueForKey:@"resetToken"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoding;
    if ([data respondsToSelector:@selector(initWithBase64EncodedString:options:)])
    {
        base64Encoding = [data base64EncodedStringWithOptions:kNilOptions];
    }
    [params setValue:base64Encoding forKey:@"resetToken"];
    NSArray *error = nil;
    
    BOOL isvlidate = [[Helper shareHelper] validateForgotPasswordAllEnteriesWithError:&error params:params];
    
    if (!isvlidate)
    {
        NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
        alertView([[Configuration shareConfiguration] errorMessage], errorMessage, nil, @"Ok", nil, 0);
        return;
        
    }
    
    if ([self.delegate respondsToSelector:@selector(forgotPasswordWithParams:)])
    {
        
        [self.delegate forgotPasswordWithParams:params];
        
    }
    
}



#pragma mark -

- (void)accountViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([self.delegate respondsToSelector:@selector(login:)])
    {
        [self.delegate login:nil];
        
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



@implementation ForgotPasswordDetail



@end
