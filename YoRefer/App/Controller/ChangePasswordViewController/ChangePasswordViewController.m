//
//  ChangePasswordViewController.m
//  YoRefer
//
//  Created by SELMA  on 15/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Configuration.h"
#import "Helper.h"
#import "Utility.h"
#import "YoReferAPI.h"

typedef enum {
    
    CurrentPwd = 5000,
    ChangePwd,
    ConfirmPwd
}Fieldtype;


@interface PasswordDetail : NSObject

@property (nonatomic, strong) NSString  *currentPassword;
@property (nonatomic, strong) NSString  *changePassword;
@property (nonatomic, strong) NSString  *confirmPassword;

@end


@interface ChangePasswordViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) PasswordDetail *passwordDetail;

@end

@implementation ChangePasswordViewController

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        
    }
    
    return self;
    
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Change Password";
    self.passwordDetail = [[PasswordDetail alloc]init];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self changePwdView];
    
    // Do any additional setup after loading the view.
}

- (CGRect)bounds
{
    
    return [[UIScreen mainScreen] bounds];
    
}

- (void)changePwdView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = [self bounds].size.width;
    CGFloat height = [self bounds].size.height/2;
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor clearColor]];
    self.tableView.tableHeaderView = view;
    self.tableView.tableFooterView = [UIView new];
    
    //current password
    xPos = 20.0;
    yPos = 10.0;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *currentPwdView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:currentPwdView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = currentPwdView.frame.size.width;
    height = currentPwdView.frame.size.height;
    UITextField *currentPwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Current Password" fieldType:CurrentPwd];
    currentPwdTxtField.secureTextEntry = YES;
    [currentPwdView addSubview:currentPwdTxtField];
    
    xPos = currentPwdView.frame.origin.x;
    yPos = currentPwdView.frame.origin.y+currentPwdView.frame.size.height;
    width = currentPwdView.frame.size.width;
    height = 2.0;
    UIView *lineView1 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView1];
    
    //change password
    xPos = 20.0;
    yPos = lineView1.frame.origin.y+lineView1.frame.size.height;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *changePwdView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:changePwdView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = changePwdView.frame.size.width;
    height = changePwdView.frame.size.height;
    UITextField *changePwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"New Password" fieldType:ChangePwd];
    changePwdTxtField.secureTextEntry = YES;
    [changePwdView addSubview:changePwdTxtField];
    
    xPos = changePwdView.frame.origin.x;
    yPos = changePwdView.frame.origin.y+changePwdView.frame.size.height;
    width = changePwdView.frame.size.width;
    height = 2.0;
    UIView *lineView2 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView2];
    
    //confirm password
    xPos = 20.0;
    yPos = lineView2.frame.origin.y+lineView2.frame.size.height;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *confirmPwdView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:confirmPwdView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = confirmPwdView.frame.size.width;
    height = confirmPwdView.frame.size.height;
    UITextField *confirmPwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Confirm Password" fieldType:ConfirmPwd];
    confirmPwdTxtField.secureTextEntry = YES;
    [confirmPwdView addSubview:confirmPwdTxtField];
    
    xPos = confirmPwdView.frame.origin.x;
    yPos = confirmPwdView.frame.origin.y+confirmPwdView.frame.size.height;
    width = confirmPwdView.frame.size.width;
    height = 2.0;
    UIView *lineView3 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView3];
    
    //update Button
    xPos = [self bounds].size.width/3;
    yPos = lineView3.frame.origin.y+lineView3.frame.size.height+20.0;
    width = [self bounds].size.width/3;
    height = 40.0;
    UIButton *updateBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    [updateBtn setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [updateBtn.layer setCornerRadius:20.0];
    [updateBtn.layer setMasksToBounds:YES];
    [updateBtn.layer setBorderWidth:2.0];
    [updateBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [updateBtn addTarget:self action:@selector(updateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:updateBtn];
    
    
    
}

- (UIView *)createViewWithFrame:(CGRect)frame color:(UIColor *)color
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:color];
    return view;
}

- (UITextField *)createTextFieldWithFrame:(CGRect)frame text:(NSString *)text fieldType:(Fieldtype)fieldType
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:fieldType];
    [textField setDelegate:self];
    [textField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    //[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setPlaceholder: NSLocalizedString(text, @"")];
    return textField;
    
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
    
    [self.view endEditing:YES];
    
    
    
    
}

- (IBAction)doneButtonTapped:(id)sender
{
    
    
    [self.view endEditing:YES];
    
    
    
    
}

#pragma mark - textfiled delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    //[self setTextBar:textField];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self populatedTextFromTextFiled:textField filedType:(Fieldtype)textField.tag];
    
    //  [self animateTextField:textField isUp:NO];
    
}

- (void)populatedTextFromTextFiled:(UITextField *)textField filedType:(Fieldtype)filedType
{
    
    switch (filedType) {
        case CurrentPwd:
            self.passwordDetail.currentPassword = textField.text;
            break;
        case ChangePwd:
            self.passwordDetail.changePassword = textField.text;
            break;
        case ConfirmPwd:
            self.passwordDetail.confirmPassword = textField.text;
            break;
            
        default:
            break;
    }
    
    
}

- (UITextField *)getNextFiledFromCurrentField:(UITextField *)textField
{
    
    UITextField *nextField = nil;
    
    Fieldtype filedType = (Fieldtype)textField.tag;
    
    switch (filedType) {
        case CurrentPwd:
            nextField = (UITextField *)[self.view viewWithTag:ChangePwd];
            break;
        case ChangePwd:
            nextField = (UITextField *)[self.view viewWithTag:ConfirmPwd];
            nextField.returnKeyType = UIReturnKeyDone;
            break;
        case ConfirmPwd:
            
            break;
            
        default:
            break;
    }
    
    return nextField;
    
}

#pragma mark  - Button delegate

- (IBAction)updateButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    UITextField *changePassword = (UITextField *)[self.view viewWithTag:ChangePwd];
    UITextField *confirmPassword = (UITextField *)[self.view viewWithTag:ConfirmPwd];
    
    NSArray *error = nil;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:self.passwordDetail.currentPassword forKey:@"oldPassword"];
    [params setValue:self.passwordDetail.changePassword forKey:@"newPassword"];
    [params setValue:self.passwordDetail.confirmPassword forKey:@"confirmPassword"];
    
    BOOL isvlidate = [[Helper shareHelper] validateChangePwdAllEnteriesWithError:&error params:params];
    if (!isvlidate)
    {
        NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
        alertView([[Configuration shareConfiguration] errorMessage], errorMessage, nil, @"Ok", nil, 0);
        return;
        
    }
    
    if ([changePassword.text isEqualToString:confirmPassword.text]) {
        
    }else{
        alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(@"Passwords did not matched", @""), nil, @"Ok", nil, 0);
        return;
    }
    
    [params removeObjectForKey:@"confirmPassword"];
    
    [self showHUDWithMessage:@""];
    
    [[YoReferAPI sharedAPI] changePasswordWithParams:params completionHandler:^(NSDictionary *response ,NSError *error){
        
        [self didReceiveLoginWithResponse:response error:error];
        
    }];
    
    
}

- (void)didReceiveLoginWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    
    [self hideHUD];
    if ([[resonse valueForKey:@"code"] isEqualToString:@"1000"]) {
        alertView([[Configuration shareConfiguration] appName], NSLocalizedString(@"Passwords changed successfully", @""), self, @"Ok", nil, 9119);
    }else{
        
    }
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    
    if (alertView.tag == 9119) {
        if (buttonIndex == 0) {
            [[UserManager shareUserManager]logOut];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


@implementation PasswordDetail



@end
