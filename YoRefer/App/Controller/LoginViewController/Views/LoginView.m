//
//  Login.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 07/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "LoginView.h"
#import "Configuration.h"
#import "Helper.h"
#import "Utility.h"

typedef enum {
    
    EmailPhoneNo = 1000,
    Password
    
}Filedtype;


@interface LoginDetail : NSObject

@property (nonatomic, strong) NSString  *emialPhonNo;
@property (nonatomic, strong) NSString  *password;


@end


@interface LoginView () <UITextFieldDelegate>

@property (nonatomic, strong)LoginDetail *loginDetail;

@end


@implementation LoginView

@synthesize delegate = _delegate;


- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Login>)delegate
{
    self = [super init];
    
    if (self)
    {
        self.loginDetail = [[LoginDetail alloc]init];
        [self LoginWithFrame:frame];
        self.delegate = delegate;
        self.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        
    }
    return self;
    
}

- (void)LoginWithFrame:(CGRect)frame
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
    UITextField *emailTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height)filedType:EmailPhoneNo];
    [emailView addSubview:emailTxt];
    //[emailTxt becomeFirstResponder];
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
    UIView *passwordView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:passwordView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = emailView.frame.size.width;
    height = 40.0;
    UITextField *passwordTxt = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height)filedType:Password];
    [passwordView addSubview:passwordTxt];
    //line
    xPos = 0.0;
    yPos = emailTxt.frame.size.height + 1.0;
    height = 2.0;
    UIView *passwordLineView  = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(226./255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
    [passwordView addSubview:passwordLineView];
    
    
    //forgot password
    xPos = 10.0;
    yPos = passwordView.frame.size.height + passwordView.frame.origin.y + 2.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *forgotPswword = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:forgotPswword];
    
    UITapGestureRecognizer *forgotPswwordGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgotPasswordTapped:)];
    [forgotPswword addGestureRecognizer:forgotPswwordGestureRecognizer];
    
    width = 130.0;
    height = 30.0;
    xPos = roundf((forgotPswword.frame.size.width - width)/2) + 4.0;
    yPos = roundf((forgotPswword.frame.size.height - height)/2);
    UILabel *passwordLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Forgot password?" textColor:[UIColor grayColor]font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [forgotPswword addSubview:passwordLbl];
    
    //login Button
    xPos = 10.0;
    yPos = forgotPswword.frame.size.height + forgotPswword.frame.origin.y + 8.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *loginButtonView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:loginButtonView];
    
    width = 150.0;
    height = 40.0;
    xPos = round((loginButtonView.frame.size.width - width)/2);
    yPos = round((loginButtonView.frame.size.height - height)/2);
    UIButton *loginBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Login" backgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [loginBtn.layer setCornerRadius:20.0];
    [loginBtn.layer setMasksToBounds:YES];
    [loginBtn.layer setBorderWidth:2.0];
    [loginBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [loginBtn addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [loginButtonView addSubview:loginBtn];
    
    //Facebook button
    xPos = 10.0;
    yPos = loginButtonView.frame.size.height + loginButtonView.frame.origin.y + 10.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *faceBookButtonView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:faceBookButtonView];
    width = 150.0;
    height = 40.0;
    xPos = round((faceBookButtonView.frame.size.width - width)/2);
    yPos = round((faceBookButtonView.frame.size.height - height)/2);
    UIButton *faceBookBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Facebook" backgroundColor:[UIColor colorWithRed:(47.0/255.0) green:(62.0/255.0) blue:(136.0/255.0) alpha:1.0]];
    [faceBookBtn.layer setCornerRadius:20.0];
    [faceBookBtn.layer setMasksToBounds:YES];
    [faceBookBtn.layer setBorderWidth:2.0];
    [faceBookBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [faceBookBtn addTarget:self action:@selector(faceBookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [faceBookButtonView addSubview:faceBookBtn];
    
    //Don't have an account?
    xPos = 10.0;
    yPos = faceBookButtonView.frame.size.height + faceBookButtonView.frame.origin.y + 14.0;
    width = view.frame.size.width - 20.0;
    height = 40.0;
    UIView *accountView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [view addSubview:accountView];
    UITapGestureRecognizer *accountGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accountViewTapped:)];
    [accountView addGestureRecognizer:accountGestureRecognizer];
    
    
    width = 160.0;
    height = 30.0;
    xPos = roundf((forgotPswword.frame.size.width - width)/2) + 4.0;
    yPos = roundf((forgotPswword.frame.size.height - height)/2);
    UILabel *accountLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Don't have an account?" textColor:[UIColor blackColor]font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [accountView addSubview:accountLbl];
    
    //
    //    //condition
    //    xPos = 10.0;
    //    yPos = accountView.frame.size.height + accountView.frame.origin.y + 14.0;
    //    width = view.frame.size.width - 20.0;
    //    height = 40.0;
    //    UIView *conditionsView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    //    [view addSubview:conditionsView];
    //    width = conditionsView.frame.size.width;
    //    height = 30.0;
    //    xPos = roundf((forgotPswword.frame.size.width - width)/2);
    //    yPos = roundf((forgotPswword.frame.size.height - height)/2);
    //    UILabel *conditionLbl = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"By clicking the \"Sign Up\" you are agree to our Terms and Conditions" textColor:[UIColor lightGrayColor]   font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    //    [conditionLbl setTextAlignment:NSTextAlignmentCenter];
    //    [conditionLbl setNumberOfLines:0];
    //    [conditionLbl sizeToFit];
    //    [conditionsView addSubview:conditionLbl];
    
    
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
    if (filedType == Password)
    {
        return UIReturnKeyDone;
    }
    
    return UIReturnKeyDefault;
}


- (UITextField *)createTextFiledWithFrame:(CGRect)frame filedType:(Filedtype)filedType
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:filedType];
    [textField setReturnKeyType:[self returnTypeWithFieldType:filedType]];
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
    [textField setSecureTextEntry:[self setSecuretextWithFiledType:filedType]];
    
    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, textField.frame.size.height)];
    //    leftView.backgroundColor = [UIColor clearColor];
    //    textField.leftViewMode = UITextFieldViewModeAlways;
    //    textField.leftView = leftView;
    
   
    
    return textField;
    
}

- (NSString *)setPlaceHolderWithFiledType:(Filedtype)fieldType
{
    NSString *string = nil;
    
    switch (fieldType) {
        case EmailPhoneNo:
            string = @"Email/Phone number";
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
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


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    [textField resignFirstResponder];
    return NO;
}


- (void)populatedTextFromTextFiled:(UITextField *)textField filedType:(Filedtype)filedType
{
    
    switch (filedType) {
        case EmailPhoneNo:
            self.loginDetail.emialPhonNo = textField.text;
            break;
        case Password:
            self.loginDetail.password = textField.text;
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
        case EmailPhoneNo:
            nextField = (UITextField *)[self viewWithTag:Password];
            break;
        case Password:
            
            break;
            
        default:
            break;
    }
    
    return nextField;
    
}

#pragma mark - GestureRecognizer

- (void)forgotPasswordTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([self.delegate respondsToSelector:@selector(ForgotPassword)])
    {
        [self.delegate ForgotPassword];
    }
    
}

- (IBAction)faceBookButtonTapped:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(faceBook)])
    {
        [self.delegate faceBook];
    }
    
    
}

#pragma  mark  - Protocol
- (void)accountViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([self.delegate respondsToSelector:@selector(signUp:)])
    {
        [self.delegate signUp:nil];
        
    }
    
}

#pragma mark  - Button delegate

- (IBAction)loginButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
    NSArray *error = nil;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:self.loginDetail.emialPhonNo forKey:@"number"];
    [params setValue:self.loginDetail.password forKey:@"password"];
    
    BOOL isvlidate = [[Helper shareHelper] validateLoginAllEnteriesWithError:&error params:params];
    if (!isvlidate)
    {
        NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
        alertView([[Configuration shareConfiguration] errorMessage], errorMessage, nil, @"Ok", nil, 0);
        return;
        
    }
    
    [params setValue:([[Helper shareHelper] emailValidationWithEmail:self.loginDetail.emialPhonNo])?self.loginDetail.emialPhonNo:[NSString stringWithFormat:@"%@%@",[[Helper shareHelper] getLocalCountryCode],self.loginDetail.emialPhonNo] forKey:@"number"];
    
    if ([self.delegate respondsToSelector:@selector(loginWithParams:)])
    {
        
        [self.delegate loginWithParams:params];
        
    }
    
    
    
    
}

#pragma mark - error helper



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */



@end

@implementation LoginDetail



@end
