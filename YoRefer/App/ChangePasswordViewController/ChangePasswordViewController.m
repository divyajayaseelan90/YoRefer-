//
//  ChangePasswordViewController.m
//  YoRefer
//
//  Created by SELMA  on 15/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

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
    UITextField *currentPwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Current Password"];
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
    UITextField *changePwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Change Password"];
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
    UITextField *confirmPwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Confirm Password"];
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
    [updateBtn setBackgroundColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
    [updateBtn.layer setCornerRadius:10.0];
    [updateBtn.layer setMasksToBounds:YES];
    //[updateBtn addTarget:self action:@selector(sendPassword:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:updateBtn];
    


}

- (UIView *)createViewWithFrame:(CGRect)frame color:(UIColor *)color
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:color];
    return view;
}

- (UITextField *)createTextFieldWithFrame:(CGRect)frame text:(NSString *)text
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [textField setReturnKeyType:UIReturnKeyDone];
    //[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setPlaceholder: NSLocalizedString(text, @"")];
    return textField;
    
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
