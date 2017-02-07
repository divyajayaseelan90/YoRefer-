//
//  BaseViewController.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCPathItemButton.h"
#import "DCPathButton.h"
#import "MBProgressHUD.h"
#import <AddressBook/AddressBook.h>
#import "CoreData.h"
#import "UserManager.h"
#import "YoReferMedia.h"
#import "Configuration.h"
#import "Constant.h"
#import "YoReferAppDelegate.h"



@interface BaseViewController : UIViewController<DCPathButtonDelegate,MBProgressHUDDelegate,Media>
{
    DCPathButton *dcPathButton;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (CGRect)bounds;

- (void)reloadTableView;

- (void)showHUDWithMessage:(NSString *)message;

- (void)showSuccessHUDWithMessage:(NSString *)message;

- (void)showErrorHUDWithMessage:(NSString *)message;

- (void)hideHUD;

- (void)rightBarBackButton;

+(bool)isNetworkAvailable;

- (void)currentLocation;

- (void)locationUpdate;

@property (nonatomic, strong) YoReferAppDelegate *appDelegate;


@end
