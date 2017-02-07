//
//  MenuViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 05/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//
#import "MenuViewController.h"
#import "Configuration.h"
#import "SWRevealViewController.h"
#import "UIManager.h"
#import "YoReferUserDefaults.h"
#import "HomeViewController.h"
#import "FeaturedViewController.h"
#import "ReferViewController.h"
#import "MenuViewController.m"
#import "SettingsViewController.h"
#import "Configuration.h"
#import "UserManager.h"
#import "ContactViewController.h"
#import "MapViewController.h"
#import "CategoryListViewController.h"
#import "DocumentDirectory.h"
#import "LazyLoading.h"
#import "Utility.h"

CGFloat     const headerWidth            = 260.0;
CGFloat     const headerheight           = 160.0;
CGFloat     const headerImageWidth       = 80.0;
CGFloat     const headerImageHeight      = 80.0;
CGFloat     const headerSectionHeight    = 44.0;
NSInteger   const menuCount              = 6;
NSInteger   const subMenuCount           = 6;
NSInteger   const KprofilePage           = 10000;
NSInteger   const KprofileName           = 20000;

typedef enum
{
    MenuHome,
    MenuFeatured,
    ReferNow,
    Points,
    Settings,
    LogOut,
    ProfilePage
    
}menuType;

typedef enum
{
    
    HomeCategory,
    HomeContact,
    HomePhoto,
    HomeLocation,
    HomeWeb,
    HomeNew
    
}subMenuType;


@interface MenuViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)       UITableView *tableview;
@property (nonatomic, strong)       NSMutableArray *isRowBool;
@property (nonatomic, strong)       SWRevealViewController *revealViewController;
@property (nonatomic, readwrite)    menuType menuType;
@property (nonatomic, readwrite)    subMenuType subMenuType;

@end

@implementation MenuViewController


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.isRowBool = [[NSMutableArray alloc]init];
    
    for (int i=0; i < subMenuCount; i++) {
        
        [self.isRowBool addObject:[NSNumber numberWithBool:NO]];
        
    }
    
    [self headerView];
    [self reloadTableView];
    
    // Do any additional setup after loading the view.
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateProfilePage];
     [self reloadTableView];
    //[self headerView];
    
    
    
    
    
}

- (void)updateProfilePage
{
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:KprofilePage];
    
    NSArray *array = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
    
    if ([array count] > 1)
    {
        
        NSString *imageName = [array objectAtIndex:[array count]-1];
        
        
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
            
        }else{
            
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[UserManager shareUserManager] dp]] imageView:imageView];
        }
        
        
    }else
    {
        
        imageView.image = [UIImage imageNamed:@"icon_profile.png"];
        
    }
    
    //Update name
    
    [(UILabel *)[self.view viewWithTag:KprofileName] setText:[[UserManager shareUserManager] name]];

    
    
}


- (CGRect)bounds
{
    
    return [[UIScreen mainScreen] bounds];
    
}


- (UIImageView *)createImageViewWithFrame:(CGRect)frame menuType:(menuType)menuType
{
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    [imageView setImage:[self headerImageWithMenuType:menuType]];
    return imageView;
    
    
}


- (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setFont:font];
    [label setText:text];
    [label sizeToFit];
    return label;
}


- (void)headerView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = headerWidth;
    CGFloat height = headerheight;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    headerView.backgroundColor = [UIColor clearColor];
    
    //imageView
    
    width = headerImageWidth;
    height = headerImageHeight;
    xPos = roundf((headerView.frame.size.width - width)/2);
    yPos = roundf((headerView.frame.size.height - height)/2);
    UIImageView *imageView = [self createImageViewWithFrame:CGRectMake(xPos, yPos, width, height) menuType:ProfilePage];
    imageView.tag = KprofilePage;
    
    //
    NSArray *array = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
    
    if ([array count] > 1)
    {
        
        NSString *imageName = [array objectAtIndex:[array count]-1];
        
        
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
            
        }else{
            
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[UserManager shareUserManager] dp]] imageView:imageView];
        }

        
    }else
    {
        
        imageView.image = [UIImage imageNamed:@"icon_profile.png"];
        
    }
    
    
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    [headerView addSubview:imageView];
    
    //labelUsername
    xPos = headerView.frame.origin.x;
    yPos = imageView.frame.size.height + imageView.frame.origin.y;
    width = headerView.frame.size.width;
    height = 40.0;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    label.tag = KprofileName;
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:21.0]];
    [label setText:[[UserManager shareUserManager]name]];
    label.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label];
    
    //lineView
    width = headerView.frame.size.width - 40.0;
    height = 1.0;
    xPos = roundf((headerView.frame.size.width - width)/2);
    yPos = label.frame.size.height + label.frame.origin.y - 4.0;
    width = headerView.frame.size.width - 40.0;
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    line.backgroundColor = [UIColor colorWithRed:(231.0/255.0) green:(232.0/255.0) blue:(232.0/255.0) alpha:1.0f];
    line.layer.opacity = 0.8;
    [headerView addSubview:line];
    [self.view addSubview:headerView];
    
    [self createTableView];
    
    
}

- (void)reloadTableView
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview reloadData];
}

- (void)createTableView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = headerheight;
    CGFloat width = headerWidth;
    CGFloat height = [self bounds].size.height - headerheight;
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorColor = [UIColor clearColor];
    //self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.tableFooterView = [UIView new];
    [self.view addSubview:self.tableview];
    
}

- (UIImage *)headerImageWithMenuType:(menuType)menuType
{
    
    UIImage *image = nil;
    
    switch (menuType) {
        case MenuHome:
            image = [UIImage imageNamed:@"icon_home.png"];
            break;
        case MenuFeatured:
            image = [UIImage imageNamed:@"icon_featured.png"];
            break;
        case ReferNow:
            image = [UIImage imageNamed:@"icon_refer_menu.png"];
            break;
        case Points:
            image = [UIImage imageNamed:@"icon_user.png"];
            break;
        case Settings:
            image = [UIImage imageNamed:@"icon_settings.png"];
            break;
        case LogOut:
            image = [UIImage imageNamed:@"icon_logout.png"];
            break;
        case ProfilePage:
            image = [UIImage imageNamed:@"icon_userprofile.png"];
            break;
            
        default:
            break;
    }
    
    return image;
    
}


- (NSString *)headerTitleWithMenuType:(menuType)menuType
{
    
    NSString *string = nil;
    
    switch (menuType) {
        case MenuHome:
            string = @"Home";
            break;
        case MenuFeatured:
            string = @"Featured";
            break;
        case ReferNow:
            string = @"Refer Now";
            break;
        case Points:
            string = @"Me";
            break;
        case Settings:
            string = @"Settings";
            break;
        case LogOut:
            string = @"Log Out";
            break;
            
        default:
            break;
    }
    
    return NSLocalizedString(string, @"") ;
    
}

- (NSString *)subTitleWithMenuType:(subMenuType)subMenuType
{
    
    NSString *string = nil;
    
    switch (subMenuType) {
        case HomeCategory:
            string = @"Category";
            break;
        case HomeContact:
            string = @"Contact";
            break;
        case HomePhoto:
            string = @"Photo";
            break;
        case HomeLocation:
            string = @"Location";
            break;
        case HomeWeb:
            string = @"Web";
            break;
        case HomeNew:
            string = @"New";
            break;
        default:
            break;
    }
    
    return NSLocalizedString(string, @"") ;
    
}

- (void)activeCellWithMenuType:(menuType)menutype
{
    
    
    
    
    switch (menutype) {
        case MenuHome:
            
            
            
            
            break;
            
        default:
            break;
    }
    
}

- (NSInteger)activeTag:(menuType)menuType
{
    
    switch (menuType) {
        case MenuHome:
            return MenuHome;
            break;
        case MenuFeatured:
            return MenuFeatured;
            break;
        case ReferNow:
            return ReferNow;
            break;
        case Points:
            return Points;
            break;
        case Settings:
            return Settings;
            break;
        default:
            break;
            
    }
    
    return 0;
    
}

- (void)activeTabWithMenuType:(menuType)menuType tag:(NSInteger)tag view:(UIView *)view
{
    
    switch (menuType) {
        case MenuHome:
            [[UIManager sharedManager]getActiveMenuHomePageWithTag:tag view:view];
            break;
        case MenuFeatured:
            [[UIManager sharedManager]getActiveMenuFeaturedPageWithTag:tag view:view];
            break;
        case ReferNow:
            [[UIManager sharedManager]getActiveMenuReferPageWithTag:tag view:view];
            break;
        case Points:
            [[UIManager sharedManager]getActiveMenuMePageWithTag:tag view:view];
            break;
        case Settings:
            [[UIManager sharedManager]getActiveSettingsMePageWithTag:tag view:view];
            break;
            
        default:
            break;
    }
    
}




#pragma mark - tableview Datasource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return menuCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return headerSectionHeight;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = self.tableview.frame.size.width;
    CGFloat height = 42.0;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    headerView.tag = section;
    headerView.backgroundColor = [UIColor whiteColor];
    width = 21.0;
    height = 20.0;
    xPos = 10.0;
    yPos = roundf((headerView.frame.size.height - height)/2);
    
    UIImageView *imageView  = [self createImageViewWithFrame:CGRectMake(xPos, yPos, width, height) menuType:(menuType)section];
    [headerView addSubview:imageView];
    
    xPos = imageView.frame.size.width + 20.0;
    width = headerView.frame.size.width - imageView.frame.size.width;
    height = headerView.frame.size.height ;
    yPos = roundf((headerView.frame.size.width - width)/2) ;
    
    UILabel *label = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0] text:[self headerTitleWithMenuType:(menuType)section]];
    [headerView addSubview:label];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognizer:)];
    [headerView addGestureRecognizer:gestureRecognizer];
    
    xPos = 0.0;
    yPos = headerView.frame.size.height - 2.0;
    height = 0.5;
    width = headerView.frame.size.width;
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:lineView];
    
    
    
    [self activeTabWithMenuType:(menuType)section tag:[self activeTag:(menuType)[[[YoReferUserDefaults shareUserDefaluts] valueForKey:@"ActiveTab"] integerValue]]view:headerView];
    
    return headerView;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ReferNow) {
        
        return subMenuCount;
        
    }
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.isRowBool objectAtIndex:indexPath.section]boolValue]){
        
        if (indexPath.section == ReferNow) {
            
            return 40.0;
            
        }
        
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"identifier";
    
    UITableViewCell *cell ;
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    if([[self.isRowBool objectAtIndex:indexPath.section]boolValue]){
        
        CGFloat xPos = 0.0;
        CGFloat yPos = 0.0;
        CGFloat width = tableView.frame.size.width;
        CGFloat height = 40.0;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        xPos = 50.0;
        yPos = 10.0;
        UILabel *label = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) font:[[Configuration shareConfiguration] yoReferFontWithSize:16.0] text:[self subTitleWithMenuType:(subMenuType)indexPath.row]];
        [view addSubview:label];
        xPos = 0.0;
        yPos = cell.frame.size.height - 4.0;
        height = 0.5;
        UIView *linrView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [linrView setBackgroundColor:[UIColor lightGrayColor]];
        [view addSubview:linrView];
        [cell.contentView addSubview:view];
        
    }
    
    return cell;
    
    
}


#pragma mark - Geature Recognizer
- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSString stringWithFormat:@"%ld",gestureRecognizer.view.tag] forKey:@"ActiveTab"];
    
    if (gestureRecognizer.view.tag == 2) {
        
        NSIndexPath *row = [NSIndexPath indexPathForRow:0 inSection:2];
        
        if(row.row == 0){
            
            BOOL boolvalue = [[self.isRowBool objectAtIndex:row.section]boolValue];
            boolvalue = !boolvalue;
            [self.isRowBool replaceObjectAtIndex:row.section withObject:[NSNumber numberWithBool:boolvalue]];
            NSRange range = NSMakeRange(row.section, 1);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableview reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }else
    {
        
        [self pushToViewControllerWithMenuType:(menuType)gestureRecognizer.view.tag];
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self pushToViewControllerWithIndexPath:indexPath];
    
}


- (void)pushToViewControllerWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    
    if (indexPath.row == 0){
        [userInfo setValue:@"category" forKey:@"submenu"];
    }else if (indexPath.row == 1){
        [userInfo setValue:@"contact" forKey:@"submenu"];
    }else if (indexPath.row == 2){
        [userInfo setValue:@"photo" forKey:@"submenu"];
    }else if (indexPath.row == 3){
        [userInfo setValue:@"location" forKey:@"submenu"];
    }else if (indexPath.row == 4){
        [userInfo setValue:@"web" forKey:@"submenu"];
    }else if (indexPath.row == 5){
        [userInfo setValue:@"new" forKey:@"submenu"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menu" object:nil userInfo:userInfo];
    
    [[UIManager sharedManager] gotoReferPage];
    
    
}

- (void)pushToViewControllerWithMenuType:(menuType)menutype
{
    
    switch (menutype) {
        case MenuHome:
            [[UIManager sharedManager]gotoHomePageWitnMenuAnimated:YES];
            break;
        case MenuFeatured:
            [[UIManager sharedManager]goToFeaturedPageWithMenuAnimated:YES];
            break;
        case Points:
            [[UIManager sharedManager]goToMePageWithMenuAnimated:YES];
            break;
        case Settings:
            [[UIManager sharedManager]goToSettingdPageWithMenuAnimated:YES];
            break;
        case LogOut:
            alertView([[Configuration shareConfiguration] appName], @"Do you want to Logout?", self, @"Yes", @"No", 0);
            break;
            
        default:
            break;
    }
}

#pragma Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 0)
    {
        
        [[UserManager shareUserManager]logOut];
        [[UIManager sharedManager]gotoHomePageWitnMenuAnimated:YES];
        
        
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
