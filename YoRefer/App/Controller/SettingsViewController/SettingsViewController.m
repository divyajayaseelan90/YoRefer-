//
//  SettingsViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "SettingsViewController.h"
#import "ReferChannelsViewController.h"
#import "WebViewController.h"
#import "ChangePasswordViewController.h"
#import "ChangeProfileViewController.h"
#import "Configuration.h"
#import <MessageUI/MessageUI.h>
#import "UserManager.h"
#import "WebViewController.h"
#import "Utility.h"
#import "LocationManager.h"

NSInteger const rowCount = 10;
NSString  * const termsAndConditions = @"Terms Of Use";
NSString  * const privacyPolicy = @"Privacy Policy";
NSString  * const aboutUs = @"About Us";

@interface SettingsViewController ()<MFMailComposeViewControllerDelegate,UIAlertViewDelegate>

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        
        
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    [self reloadTableView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self updateLocation];
    
}


- (void)updateLocation
{
    
    BOOL isLocation = [[UserManager shareUserManager] getLocationService];
    if ([[UserManager shareUserManager] getLocationService])
        [[UserManager shareUserManager]enableLocation];
    else
        [[UserManager shareUserManager]disableLocation];
    
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    NSArray *cellSubViews = [cell subviews];
    
    if ([cellSubViews count] > 0)
    {
        NSArray *subView = [[[cell subviews] objectAtIndex:0] subviews];
        if ([subView count] > 0)
        {
            
            UIView *view = [subView objectAtIndex:0];
            NSArray *views = [view subviews];
            
            if ( isLocation)
                [(UISwitch *)[views objectAtIndex:3] setOn:YES animated:YES];
            else
                [(UISwitch *)[views objectAtIndex:3] setOn:NO animated:YES];
            
        }
        
        
    }

}




#pragma mark - tableView datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return rowCount;
    
}


- (SettingsTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsIdentifier];
    
    if (cell == nil)
    {
        
        cell = [[SettingsTableViewCell alloc]initWihtIndexPath:indexPath delegate:self];
        [cell setBackgroundColor:[UIColor clearColor]];
        
    }
    
    return cell;
    
    
}


#pragma  mark - Protocol

- (void)pushSettingType:(settingsType)settingsType
{
    switch (settingsType) {
        case SettingsProfile:
            [self changeProfile];
            break;
        case ChangePassword:
            [self changePassword];
            break;
        case ReferChannels:
            [self pushToReferChannel];
            break;
        case TermsAndConditions:
            [self termsAndConditions];
            break;
        case PrivacyPolicy:
            [self privacyPolicy];
            break;
        case SendFeedBack:
            [self feedBack];
            break;
        case YoreferVersion:
            //[self feedBack];
            break;
        case AboutUs:
            [self abouUs];
            break;
        case SettingsLogOut:
            [self logOut];
            break;
        default:
            break;
    }
    
}

#pragma mark - Setting type

- (void)changeProfile
{
    ChangeProfileViewController *vctr = [[ChangeProfileViewController alloc]init];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)changePassword
{
    ChangePasswordViewController *vctr = [[ChangePasswordViewController alloc]init];
    [self.navigationController pushViewController:vctr animated:YES];
}

- (void)pushToReferChannel
{
    
    ReferChannelsViewController *vctr = [[ReferChannelsViewController alloc]init];
    [self.navigationController pushViewController:vctr animated:YES];
    
    
}

- (void)termsAndConditions
{
    
    WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[[Configuration shareConfiguration] getTermsAndConditions]] title:NSLocalizedString(termsAndConditions, @"") refer:NO categoryType:@""];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (void)privacyPolicy
{
    WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[[Configuration shareConfiguration] getPrivacyPolicy]] title:NSLocalizedString(privacyPolicy, @"") refer:NO categoryType:@""];
    [self.navigationController pushViewController:vctr animated:YES];
}



- (void)abouUs
{
    
    WebViewController *vctr = [[WebViewController alloc]initWithUrl:[NSURL URLWithString:[[Configuration shareConfiguration] getAboutUs]] title:NSLocalizedString(aboutUs, @"") refer:NO categoryType:@""];
    [self.navigationController pushViewController:vctr animated:YES];
    
}

- (void)feedBack
{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:@"Yorefer Feedback"];
        [mailComposer setToRecipients:[NSArray arrayWithObject:[[Configuration shareConfiguration] getFeedBackRecipient]]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
        
    }else{
        
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    
    if (result==MFMailComposeResultCancelled) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (void)logOut
{
    
    alertView([[Configuration shareConfiguration] appName], @"Do you want to Logout?", self, @"Yes", @"No", 0);
    
}

#pragma Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 0)
    {
        
        [[UserManager shareUserManager]logOut];
    }
    else if (buttonIndex == 1)
    {
        
    }
    
}


#pragma mark - didReceiveMemoryWarning
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
