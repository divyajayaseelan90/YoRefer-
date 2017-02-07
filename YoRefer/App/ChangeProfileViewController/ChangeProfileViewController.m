//
//  ChangeProfileViewController.m
//  YoRefer
//
//  Created by SELMA  on 15/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ChangeProfileViewController.h"
#import "UserManager.h"

CGFloat     const imageWidth       = 80.0;
CGFloat     const imageHeight      = 80.0;

@interface ChangeProfileViewController ()

@end

@implementation ChangeProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Change Profile";
    [self profileView];
    // Do any additional setup after loading the view.
}

- (CGRect)bounds
{
    
    return [[UIScreen mainScreen] bounds];
    
}

- (void)profileView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = [self bounds].size.width;
    CGFloat height = [self bounds].size.height/2;
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor clearColor]];
    self.tableView.tableHeaderView = view;
    self.tableView.tableFooterView = [UIView new];
    
    //image view
    xPos = 0.0;
    yPos = 0.0;
    width = [self bounds].size.width;
    height = view.frame.size.height/2;
    UIView *imageView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor grayColor]];
    [view addSubview:imageView];
    
    xPos = imageView.frame.size.width/2-imageWidth/2;
    yPos = imageView.frame.size.height/4;
    width = imageWidth;
    height = imageHeight;
    UIImageView *profileImage=[[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    profileImage.image = [UIImage imageNamed:@"icon_userprofile.png"];
    [imageView addSubview:profileImage];
    
    //change picture label
    xPos = 20.0;
    yPos = profileImage.frame.origin.y+profileImage.frame.size.height+5.0;
    width = imageView.frame.size.width/2-30.0;
    height = 40.0;
    UILabel *changePicLbl=[self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Change Picture"];
    [imageView addSubview:changePicLbl];
    
    //remove picture label
    xPos = changePicLbl.frame.origin.x+changePicLbl.frame.size.width+20.0;
    yPos = profileImage.frame.origin.y+profileImage.frame.size.height+5.0;
    width = imageView.frame.size.width/2-30.0;
    height = 40.0;
    UILabel *removePicLbl=[self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Remove Picture"];
    [imageView addSubview:removePicLbl];
    
    //profile name
    xPos = 20.0;
    yPos = imageView.frame.origin.y+imageView.frame.size.height;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *profileView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:profileView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = profileView.frame.size.width;
    height = profileView.frame.size.height;
    UITextField *nameTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]name]]];
    nameTxtField.text = [NSString stringWithFormat:@"%@",[[UserManager shareUserManager]name]];
    [profileView addSubview:nameTxtField];
    
    xPos = profileView.frame.origin.x;
    yPos = profileView.frame.origin.y+profileView.frame.size.height;
    width = profileView.frame.size.width;
    height = 2.0;
    UIView *lineView1 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView1];
    
    //location
    xPos = 20.0;
    yPos = lineView1.frame.origin.y+lineView1.frame.size.height;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *locationView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:locationView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = locationView.frame.size.width;
    height = locationView.frame.size.height;
    UITextField *changePwdTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Location"];
    [changePwdTxtField setPlaceholder: NSLocalizedString(@"Location", @"")];
    [locationView addSubview:changePwdTxtField];
    
    xPos = locationView.frame.origin.x;
    yPos = locationView.frame.origin.y+locationView.frame.size.height;
    width = locationView.frame.size.width;
    height = 2.0;
    UIView *lineView2 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView2];
    
    //update button
    xPos = [self bounds].size.width/3;
    yPos = lineView2.frame.origin.y+lineView2.frame.size.height+20.0;
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

- (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:14.0f]];
    label.text = NSLocalizedString(text, @"");
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 3;
    return label;
    
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
