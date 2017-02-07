//
//  ShareView.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/22/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ShareView.h"
#import "Configuration.h"
#import <AddressBook/AddressBook.h>
#import "Helper.h"
#import "Utility.h"
#import "Constant.h"
#import "AlertView.h"
#import "CoreData.h"
#import "UserManager.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "BaseViewController.h"
#import "UIManager.h"

typedef enum {
    
    Message = 8000,
    Email,
    WhatsApp,
    FaceBook,
    Twitter
    
}ShareType;

NSString  * const kShareIdentifier         = @"identifier";
NSString  * const kReferMessage            = @"message";
NSString  * const kReferPhoneContactNumber = @"phonecontact";
NSString  * const kReferNewlyAddedNumber   = @"newlyaddednumber";
NSString  * const kReferPhoneContactEmail  = @"phoneemial";
NSString  * const kReferNewlyAddedEmail    = @"newlyaddedemail";
NSString  * const kReferEmail              = @"email";
NSString  * const kReferWhatsUp            = @"wahtsup";
NSString  * const kReferFaceBook           = @"facebook";
NSString  * const kReferTwitter            = @"twitter";
NSString  * const kReferFilter             = @"filter";
NSString  * const kReferSearchText         = @"searchtext";

NSUInteger  const kNewReferCount               = 100000;
NSUInteger  const kUnselectTag              = 200000;
NSUInteger  const kReferSearchTag           = 300000;
NSUInteger  const kReferMessageTag          = 400000;
NSUInteger  const kReferEmailTag            = 500000;
NSUInteger  const kReferWhatsUpTag          = 600000;
NSUInteger  const kReferFaceBookTag         = 700000;
NSUInteger  const kReferTwitterUpTag        = 800000;
NSUInteger  const kReferWhatsAppTag         = 900000;
NSUInteger  const kSelectTag                = 250000;
NSUInteger  const kMainHeaderViewTag        = 260000;
NSUInteger  const kTableHeaderViewTag       = 280000;


UIImageView *selectAllTick;

@interface ShareView () <UITextFieldDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,Alert,UIAlertViewDelegate>

@property (nonatomic, strong)  UITableView             *tableView;
@property (nonatomic, strong)  NSMutableDictionary     *dictionary;
@property (nonatomic, strong)  NSMutableDictionary     *filterSearch;
@property (nonatomic, strong)  NSMutableDictionary     *indexPaths;
@property (nonatomic, strong)  NSIndexPath             *indexPath;
@property (nonatomic, strong)  NSString                *selcPhoneNumber;
@property (nonatomic, readwrite) ShareType  shareType;
@property (nonatomic, strong)  NSDictionary            * referChannel;
@property (nonatomic, readwrite) BOOL                  isMessageExpand,isMailExpand,isHeight;
@property (nonatomic,readwrite) CGFloat shiftForKeyboard;
@property (nonatomic ,strong) NSArray *data;
@property (nonatomic ,strong) NSMutableArray *phonesData;
@property (nonatomic ,strong) NSArray *phonenum;
@property (nonatomic ,strong) NSIndexPath *phoneindex;
@property (nonatomic ,strong) UITableView *myTable;
@property (nonatomic ,strong) UIView *BaseView;


@property (readwrite) int k;
@end


@implementation ShareView

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Share>)delegate referChannel:(NSDictionary *)referChannel

{
    self = [super init];
    
    if (self)
    {
        self.delegate = delegate;
        self.referChannel = referChannel;
        
        
        ABAddressBookRef m_addressbook =  ABAddressBookCreateWithOptions(NULL, NULL);
        
        __block BOOL accessGranted = NO;
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                }
            });
            
            ABAddressBookRequestAccessWithCompletion(m_addressbook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        
        if (accessGranted) {
            
            [self getContactListWithContact:[self getContacts]];
            [self ShareViewWithFrame:frame];
            self.frame = CGRectMake(0.0, 64.0, frame.size.width, frame.size.height - 70.0);
            [self setBackgroundColor:[UIColor greenColor]];
            
        }else
        {
             alertView([[Configuration shareConfiguration] appName],@"This app requires access to your device's Contacts.\n\nPlease enable Contacts access for this app in Settings / Yorefer / Contacts", self, @"Ok", nil, 100);
        }
    }
    return self;
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
}

- (void)getContactListWithContact:(NSMutableArray *)contacts
{
    
    self.dictionary = [[NSMutableDictionary alloc]init];
    self.indexPaths = [[NSMutableDictionary alloc]init];
    self.filterSearch = [[NSMutableDictionary alloc]init];
    
    
    NSMutableArray *contactsArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dictionary in contacts) {
        
        //Phone number
        NSMutableDictionary *contact = [[NSMutableDictionary alloc]init];
        
        if ([[dictionary objectForKey:@"Phonenumbers"] count ] > 0)
        {
            if([[[dictionary objectForKey:@"Phonenumbers"] objectAtIndex:0] length] > 0)
            {
                [contact setValue:[dictionary objectForKey:@"Phonenumbers"] forKey:@"phonenumber"];
                [contact setValue:[dictionary objectForKey:@"Firstname"] forKey:@"firstname"];
                [contact setValue:[dictionary objectForKey:@"Lastname"] forKey:@"lastname"];
                
                if ([[dictionary objectForKey:@"Phonenumbers"] count] > 1)
                {
                     [contact setValue:@"" forKey:@"referphonnumber"];
                }else
                {
                    [contact setValue:[[dictionary objectForKey:@"Phonenumbers"] objectAtIndex:0] forKey:@"referphonnumber"];
                }

            
            }
            
            if ([contact count] > 0)
            {
                
                [contactsArray addObject:contact];
                
            }
        }
       
    }
    
    self.phonesData = [[NSMutableArray alloc]init];
    
    [self.dictionary setValue:[NSDictionary dictionaryWithObjectsAndKeys:[self sortArrayWithArray:contactsArray],kReferPhoneContactNumber, nil] forKey:kReferMessage];
    [self.dictionary setValue:[NSDictionary dictionaryWithObjectsAndKeys:[self sortArrayWithArray:contactsArray],kReferPhoneContactNumber, nil] forKey:kReferWhatsUp];
    
    NSMutableArray *emailArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dictionary in contacts) {
        
        //email
        NSMutableDictionary *contact = [[NSMutableDictionary alloc]init];
        if([[dictionary objectForKey:@"Email"] length] > 0)
        {
            [contact setValue:[dictionary objectForKey:@"Phonenumbers"] forKey:@"phonenumber"];
            [contact setValue:[dictionary objectForKey:@"Firstname"] forKey:@"firstname"];
            [contact setValue:[dictionary objectForKey:@"Lastname"] forKey:@"lastname"];
            [contact setValue:[dictionary objectForKey:@"Email"] forKey:@"email"];
            
        }
        if ([contact count] > 0)
        {
            
            [emailArray addObject:contact];
           // [self.phonesData addObject:[contact valueForKey:@"phonenumber"]];
            
        }
        
    }
    
    
    [self.dictionary setValue:[NSDictionary dictionaryWithObjectsAndKeys:[self sortArrayWithArray:emailArray],kReferPhoneContactEmail, nil] forKey:kReferEmail];
    
    
        NSArray *allKeys = [self.dictionary allKeys];
    
        for (int i =0; i < [allKeys count]; i++) {
    
            NSDictionary *dic = [self.dictionary objectForKey:[allKeys objectAtIndex:i]];
            [self.filterSearch setValue:dic forKey:[NSString stringWithFormat:@"%@%@",kReferFilter,[allKeys objectAtIndex:i]]];
    
        }
    
    
}

- (NSArray *)sortArrayWithArray:(NSMutableArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstname" ascending:YES];
    
    
    
    return [array sortedArrayUsingDescriptors:@[sort]];
    
}

- (void)addReferItem:(NSNotification *)notification
{
    
    //
    //    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.frame.origin.x, 0.0, self.frame.size.width, self.frame.size.height)];
    //    view.tag = 80000;
    //    [view setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(8.0/255.0) blue:(8.0/255.0) alpha:0.8f]];
    //    [self addSubview:view];
    //
    //    CGFloat height = 400.0;
    //    CGFloat width = view.frame.size.width - 12.0;
    //    CGFloat yPos = roundf((view.frame.size.height- height)/2);
    //    CGFloat xPos = roundf((view.frame.size.width - width)/2);
    //
    //    NSString *type = (self.shareType == Message)?@"Message":@"email";
    //
    //    AddContact *addContact  = [[AddContact alloc]initWithViewFrame:CGRectMake(xPos, yPos, width, height)type:type delegate:self];
    //    [addContact.layer setCornerRadius:5.0];
    //    [addContact.layer setMasksToBounds:YES];
    //    [view addSubview:addContact];
    //
    //    width = 26.0;
    //    height = 26.0;
    //    xPos = view.frame.size.width - (width + 3.0);
    //    yPos = yPos - 18.0;
    //    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //    [imageView setImage:[UIImage imageNamed:@"cross.png"]];
    //    [view addSubview:imageView];
    //
    //    width = 50.0;
    //    height = 38.0;
    //    xPos = view.frame.size.width - width;
    //    yPos = yPos - 16.0;
    //    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //    [closeBtn setBackgroundColor:[UIColor clearColor]];
    //    [closeBtn addTarget:self action:@selector(closeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [view addSubview:closeBtn];
    
}


- (IBAction)closeBtnTapped:(id)sender
{
    
    [(UIView *)[self viewWithTag:80000] removeFromSuperview];
    
    
}


- (void)getCustomeContact:(NSArray *)array
{
    
    [(UIView *)[self viewWithTag:80000] removeFromSuperview];
    
    if ([array count] > 0)
    {
        
        if (self.shareType == Message)
        {
            
            NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber]];
            
            for (NSDictionary *dictionary in array) {
    
                [contacts addObject:dictionary];
                
            }
            
            NSMutableArray *uniqueArray = [NSMutableArray array];
            
            [uniqueArray addObjectsFromArray:[[NSSet setWithArray:contacts] allObjects]];
            
            [uniqueArray setArray:[self sortArrayWithArray:uniqueArray]];
            
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferPhoneContactNumber] forKey:kReferPhoneContactNumber];
            [dictionary setValue:uniqueArray forKey:kReferNewlyAddedNumber];
            
            [self.dictionary setValue:dictionary forKey:kReferMessage];
            
        }else
        {
            
            NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail]];
            
            for (NSDictionary *dictionary in array) {
                
                [contacts addObject:dictionary];
                
            }
            
            
            NSMutableArray *uniqueArray = [NSMutableArray array];
            
            [uniqueArray addObjectsFromArray:[[NSSet setWithArray:contacts] allObjects]];
            
            [uniqueArray setArray:[self sortArrayWithArray:uniqueArray]];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferPhoneContactEmail] forKey:kReferPhoneContactEmail];
            [dictionary setValue:uniqueArray forKey:kReferNewlyAddedEmail];
            
            [self.dictionary setValue:dictionary forKey:kReferEmail];
            
        }
        
        NSString *key = [self getKeyWithShareType:self.shareType];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (int j=0; j < 1; j++) {
            
            NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
            
            NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
            
            for (int i =0; i < [contacts count]; i++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
                [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
                
            }
            
            if ([indexs count] >0)
            {
                
                [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
                
                
            }
            
            
        }
        
        [self.indexPaths setValue:dictionary forKey:key];
        
        
//        NSArray *allKeys = [self.dictionary allKeys];
//        
//        
//        for (int i =0; i < [allKeys count]; i++) {
//            
//            NSDictionary *dic = [self.dictionary objectForKey:[allKeys objectAtIndex:i]];
//            [self.filterSearch setValue:dic forKey:[NSString stringWithFormat:@"%@%@",kReferFilter,[allKeys objectAtIndex:i]]];
//            
//        }

        
    }else
    {
        
    }
    
    
    [self reloadData];
    
    
}

- (CGRect)bounds
{
    return [[UIScreen mainScreen] bounds];
}


- (void)reloadData
{
   
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
}

- (void)ShareViewWithFrame:(CGRect)frame
{
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = 85.0;
    CGFloat width = frame.size.width;
    xPos = 0.0;
    yPos = 0.0;
    width = frame.size.width;
    height = 2.0;
    UIView *viewLine = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor lightGrayColor]];
    [self addSubview:viewLine];
    
    xPos = 0.0;
    yPos = 0.0;
    width = frame.size.width;
    height = 50.0;
    UIView *search = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [self addSubview:search];
    
    xPos = 4.0;
    yPos = 8.0;
    width = search.frame.size.width - 50.0;
    height = 36.0;
    UISearchBar *searchName = [[UISearchBar alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    searchName.delegate = self;
    searchName.tag = kReferSearchTag;
    searchName.searchBarStyle = UISearchBarStyleMinimal;
    searchName.layer.cornerRadius = 18.0;
    searchName.layer.masksToBounds = YES;
    searchName.placeholder = NSLocalizedString(@"Phone Contacts", @"");
    [search addSubview:searchName];
    
    width = 24.0;
    height = 24.0;
    xPos = searchName.frame.origin.x + searchName.frame.size.width + 8.0;
    yPos = roundf((search.frame.size.height - height)/2);
    UIImageView *plusImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [plusImg setImage:[UIImage imageNamed:@"icon_plus.png"]];
    plusImg.image = [[UIImage imageNamed:@"icon_plus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [plusImg setTintColor:[UIColor colorWithRed:(214.0/255.0) green:(95.0/255.0) blue:(59.0/255.0) alpha:1.0f]];

    [search addSubview:plusImg];
    
    yPos = 0.0;
    width = search.frame.size.width - (searchName.frame.origin.x + searchName.frame.size.width);
    height = search.frame.size.height;
    UIButton *plusBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [plusBtn addTarget:self action:@selector(addContactBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [search addSubview:plusBtn];
    
    
    
    
    xPos = 0.0;
    yPos = search.frame.size.height - 2.0;
    width = frame.size.width;
    height = 2.0;
    UIView *viewLine1 = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor lightGrayColor]];
    [search addSubview:viewLine1];
    
    xPos = 0.0;
    yPos = search.frame.size.height + search.frame.origin.y;
    width = frame.size.width;
    height = 45.0;
    UIView *selectAll = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    [self addSubview:selectAll];
    
    UITapGestureRecognizer *selectAllGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectAllGestureTapped:)];
    [selectAll addGestureRecognizer:selectAllGesture];
    
    xPos = 10.0;
    yPos = 0.0;
    width = frame.size.width - 60.0;
    self.shareType = Message;
    
    //[NSString stringWithFormat:@"Select All (%ld)", [[self.dictionary objectForKey:kReferMessage] count]];
    UILabel *lableSelect = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Select All" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    lableSelect.tag = kNewReferCount;
    lableSelect.textAlignment = NSTextAlignmentLeft;
    [selectAll addSubview:lableSelect];
    
    xPos = frame.size.width - 40.0;
    yPos = 10.0;
    width = 24.0;
    height = 24.0;
    UILabel *lableCircle = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    lableCircle.layer.cornerRadius = 12.0;
    lableCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    lableCircle.layer.borderWidth = 1.0;
    lableCircle.layer.masksToBounds = YES;
    [selectAll addSubview:lableCircle];
    
    xPos = 0.0;
    yPos = 0.0;
    selectAllTick = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    selectAllTick.tag = kUnselectTag;
    selectAllTick.image = [UIImage imageNamed:@""];
    [lableCircle addSubview:selectAllTick];
    
    xPos = 0.0;
    yPos = selectAll.frame.size.height - 2.0;
    width = frame.size.width;
    height = 2.0;
    UIView *viewLine2 = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor lightGrayColor]];
    [selectAll addSubview:viewLine2];
    
    xPos = 0.0;
    yPos = frame.size.height - 145.0;
    width = frame.size.width;
    height = 120.0;
    UIView *referNow = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f]];
    [self addSubview:referNow];
    
    xPos = 0.0;
    yPos = 0.0;
    width = frame.size.width;
    height = 2.0;
    UIView *viewLine3 = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor lightGrayColor]];
    [referNow addSubview:viewLine3];
    
   
    xPos = 0.0;
    yPos = selectAll.frame.origin.y + selectAll.frame.size.height;
    width = frame.size.width;
    height = 36.0;
    UIView * mainHeaderView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mainHeaderView setHidden:YES];
    [mainHeaderView setTag:kMainHeaderViewTag];
    mainHeaderView.backgroundColor = [UIColor colorWithRed:(211.0/255.0) green:(91.0/255.0) blue:(61.0/255.0) alpha:1.0];
    
    xPos = 0.0;
    yPos = 0.0;
    width = (frame.size.width - 30.0);
    height = 36.0;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [label setText:@"Selected Recipients"];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [mainHeaderView addSubview:label];
    
    width = 32.0;
    height = 32.0;
    xPos = mainHeaderView.frame.size.width - (width + 12.0);
    yPos = round((36 - height)/2);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:[UIImage imageNamed:@"icon_up_arrow.png"]];
    [mainHeaderView addSubview:imageView];
    
    [self addSubview:mainHeaderView];
    
    UITapGestureRecognizer *mainHeaderViewRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainHeaderGestureTapped:)];
    [mainHeaderView addGestureRecognizer:mainHeaderViewRecognizer];
    
    
    width = frame.size.width - 30.0;
    height = 46.0;
    xPos = roundf((referNow.frame.size.width - width)/2);
    yPos =  roundf((referNow.frame.size.height - height)/2);
    UIButton *referNowButton = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Refer Now" backgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [referNowButton.layer setCornerRadius:23.0];
    [referNowButton.layer setMasksToBounds:YES];
    [referNowButton.layer setBorderWidth:2.0];
    [referNowButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNowButton addTarget:self action:@selector(referNowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    referNowButton.titleLabel.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:14.0];
    [referNow addSubview:referNowButton];
    
    xPos = 0.0;
    yPos = selectAll.frame.origin.y + selectAll.frame.size.height;
    width = frame.size.width;
    height = frame.size.height - 120.0 - yPos;
    UIView *table = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor clearColor]];
    table.tag = kTableHeaderViewTag;
    [self addSubview:table];
    
    self.isMailExpand = NO;
    self.isMessageExpand = NO;
    self.isHeight = NO;
    xPos = 0.0;
    yPos = 0.0;
    width = table.frame.size.width;
    height = table.frame.size.height;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [self reloadData];
    self.tableView.tableFooterView = [UIView new];
    [table addSubview:self.tableView];
    
    [self setReferActiveWithShareType:[self retrunShareTypeFromReferChannel:[self.referChannel objectForKey:@"referchannel"]]];
    
    [self postReferChannelWithShareType:[self retrunShareTypeFromReferChannel:[self.referChannel objectForKey:@"referchannel"]]];
    
}

- (void)postReferChannelWithShareType:(ShareType)shareType
{
    
    switch (shareType) {
        case Message:
            [self message:nil];
            break;
        case Email:
            [self email:nil];
            break;
        case WhatsApp:
            [self whatsapp:nil];
            break;
        case FaceBook:
            [self facebook:nil];
            break;
        case Twitter:
            [self twitter:nil];
            break;
            
        default:
            break;
    }
    
}

- (ShareType)retrunShareTypeFromReferChannel:(NSString *)referChannel
{
    ShareType shareType;
    
    if ([referChannel isEqualToString:@"Message"])
    {
        shareType = Message;
    }else if ([referChannel isEqualToString:@"Email"])
    {
        shareType = Email;
    }else if ([referChannel isEqualToString:@"WhatsApp"])
    {
        shareType = WhatsApp;
    }else if ([referChannel isEqualToString:@"FaceBook"])
    {
        shareType = FaceBook;
    }else if ([referChannel isEqualToString:@"Twitter"])
    {
        shareType = Twitter;
    }
    
    return shareType;
    
}


- (NSString *)getKeyWithShareType:(ShareType)shareType
{
    
    NSString *key;
    switch (shareType) {
        case Message:
            key = kReferMessage;
            break;
        case Email:
            key = kReferEmail;
            break;
        case WhatsApp:
            key = kReferWhatsUp;
            break;
        case FaceBook:
            key = kReferFaceBook;
            break;
        case Twitter:
            key = kReferTwitter;
            break;
            
        default:
            break;
    }
    
    return key;
    
}

- (void)setReferActiveWithShareType:(ShareType)shareType
{
    
    
    NSArray *inActiveImages = [[NSArray alloc]initWithObjects:@"icon_message.png",@"icon_email.png",@"icon_whatsapp.png",@"icon_facebook.png",@"icon_twitter.png", nil];
    NSArray *activeImages = [[NSArray alloc]initWithObjects:@"icon_message_active.png",@"icon_email_active.png",@"icon_whatsappactive.png",@"icon_facebook_active.png",@"icon_twitter_active.png", nil];
    
    
    for (int i = 0; i < 5; i++) {
        
        UIView *view =  (UIView *)[self viewWithTag:(i == 0)?Message:(i == 1)?Email:(i == 2)? WhatsApp : (i == 3)?FaceBook:(i == 4)?Twitter:0];
        
        if (shareType == view.tag)
        {
            
            NSArray *subViews = [view subviews];
            [(UIImageView *)[subViews objectAtIndex:0]setImage:[UIImage imageNamed:[activeImages objectAtIndex:i]]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
            
        }else
        {
            
            
            NSArray *subViews = [view subviews];
            [(UIImageView *)[subViews objectAtIndex:0]setImage:[UIImage imageNamed:[inActiveImages objectAtIndex:i]]];
            [(UILabel *)[subViews objectAtIndex:1]setTextColor:[UIColor blackColor]];
            
            
        }
        
    }
    
    
}



#pragma mark - GestureRecognizer

- (void)message:(UITapGestureRecognizer *)gestureRecognizer
{
    
    NSDictionary *notification = [[NSDictionary alloc]initWithObjectsAndKeys:@"no",@"navigationbar",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiderightnvaigationbarbutton" object:notification];
    
    [self endEditing:YES];
    self.shareType = Message;
    [self setReferActiveWithShareType:self.shareType];
    
    //[NSString stringWithFormat:@"Select All (%lu)",[[self.dictionary objectForKey:kReferMessage] count]]
    [(UILabel *)[self viewWithTag:kNewReferCount] setText:@"Select All"];
    NSString *key = [self getKeyWithShareType:self.shareType];
    [(UISearchBar *)[self viewWithTag:kReferSearchTag] setText:[self.dictionary objectForKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]]];
    [self reloadData];
    
    [(UIView *)[self viewWithTag:kReferWhatsAppTag] removeFromSuperview];
    
}

- (void)email:(UITapGestureRecognizer *)gestureRecognizer
{
    
    NSDictionary *notification = [[NSDictionary alloc]initWithObjectsAndKeys:@"no",@"navigationbar",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiderightnvaigationbarbutton" object:notification];
    
    [self endEditing:YES];
    
    self.shareType = Email;
    
    [self setReferActiveWithShareType:self.shareType];
    //[NSString stringWithFormat:@"Select All (%lu)",[[self.dictionary objectForKey:kReferEmail] count]]
    [(UILabel *)[self viewWithTag:kNewReferCount] setText:@"Select All"];
    NSString *key = [self getKeyWithShareType:self.shareType];
    
    [(UISearchBar *)[self viewWithTag:kReferSearchTag] setText:[self.dictionary objectForKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]]];
    
    [self reloadData];
    
    [(UIView *)[self viewWithTag:kReferWhatsAppTag] removeFromSuperview];
    
    
}

- (void)whatsapp:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [self endEditing:YES];
    self.shareType = WhatsApp;
    [self setReferActiveWithShareType:self.shareType];
    
    NSDictionary *indexPaths =  [self getIndexPathsWithSahreType:self.shareType section:0];
    
    NSArray *keys = [indexPaths allKeys];
    
    NSArray *array = [self getContactsWithShareType:self.shareType section:0];
    
    NSMutableArray *shareViaMessage = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [keys  count]; i++) {
        
        [shareViaMessage addObject:[array objectAtIndex:[[keys objectAtIndex:i] integerValue]]];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(wahtsUpWithContacts:referChannel:)])
    {
        
        [self.delegate wahtsUpWithContacts:shareViaMessage referChannel:self.referChannel];
        
    }
    //    [(UILabel *)[self viewWithTag:kReferCount] setText:[NSString stringWithFormat:@"Select All (%ld)",[[self.dictionary objectForKey:kReferWhatsUp] count]]];
    //    NSString *key = [self getKeyWithShareType:self.shareType];
    
    //    [(UISearchBar *)[self viewWithTag:kReferSearchTag] setText:[self.dictionary objectForKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]]];
    //[self reloadData];
    [(UIView *)[self viewWithTag:kReferWhatsAppTag] removeFromSuperview];
    //[self whatsAppView];
    
}

- (void)whatsAppView
{
    NSDictionary *notification = [[NSDictionary alloc]initWithObjectsAndKeys:@"yes",@"navigationbar",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiderightnvaigationbarbutton" object:notification];
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 85.0;
    CGFloat height = frame.size.height - 85.0;
    CGFloat width = frame.size.width;
    UIView *whatsAppShare = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) backgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    whatsAppShare.tag = kReferWhatsAppTag;
    [self addSubview:whatsAppShare];
    
    width = 110.0;
    height = 110.0;
    xPos = (frame.size.width - width)/2;
    yPos = 60.0;
    UIImageView *whatsApp = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    if (self.shareType == Twitter) {
        whatsApp.image = [UIImage imageNamed:@"icon_twitter.png"];
        
    }else if (self.shareType == WhatsApp){
        whatsApp.image = [UIImage imageNamed:@"icon_whatsapp.png"];
        
    }else if (self.shareType == FaceBook){
        whatsApp.image = [UIImage imageNamed:@"icon_facebook.png"];
        
    }
    [whatsAppShare addSubview:whatsApp];
    
    width = 180.0;
    height = 60.0;
    xPos = (frame.size.width - width)/2;
    yPos = whatsApp.frame.size.height + whatsApp.frame.origin.y;
    UILabel *invite = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Invite your WhatsApp Friends" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:21.0]];
    if (self.shareType == Twitter) {
        invite.text = NSLocalizedString(@"Share with your Twitter Friends", @"");
    }else if (self.shareType == WhatsApp){
        invite.text = NSLocalizedString(@"Share with your WhatsApp Friends", @"");
    }else if (self.shareType == FaceBook){
        invite.text = NSLocalizedString(@"Share with your Facebook Friends", @"");
    }
    invite.numberOfLines = 2;
    invite.textAlignment = NSTextAlignmentCenter;
    [whatsAppShare addSubview:invite];
    
    width = 175.0;
    height = 40.0;
    xPos = (frame.size.width - width)/2;
    yPos = invite.frame.size.height + invite.frame.origin.y;
    UIButton *connectToWhatsApp = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) titil:@"Connect WhatsApp" backgroundColor:[UIColor clearColor]];
    [connectToWhatsApp addTarget:self action:@selector(whatsAppView:) forControlEvents:UIControlEventTouchUpInside];
    if (self.shareType == Twitter) {
        [connectToWhatsApp setTitle:NSLocalizedString(@"Tap to Share", @"") forState:UIControlStateNormal];
    }else if (self.shareType == WhatsApp){
        [connectToWhatsApp setTitle:NSLocalizedString(@"Connect WhatsApp", @"") forState:UIControlStateNormal];
    }else if (self.shareType == FaceBook){
        [connectToWhatsApp setTitle:NSLocalizedString(@"Tap to Share", @"") forState:UIControlStateNormal];
    }
    connectToWhatsApp.layer.cornerRadius = 20.0;
    connectToWhatsApp.layer.borderColor = [[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0] CGColor];
    connectToWhatsApp.layer.borderWidth = 1.0;
    connectToWhatsApp.layer.masksToBounds = YES;
    connectToWhatsApp.titleLabel.font = [[Configuration shareConfiguration] yoReferFontWithSize:16.0];
    [connectToWhatsApp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [whatsAppShare addSubview:connectToWhatsApp];
    
}

- (IBAction)whatsAppView:(id)sender
{
    
    NSDictionary *indexPaths =  [self getIndexPathsWithSahreType:self.shareType section:0];
    
    NSArray *keys = [indexPaths allKeys];
    
    NSArray *array = [self getContactsWithShareType:self.shareType section:0];
    
    NSMutableArray *shareViaMessage = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [keys  count]; i++) {
        
        [shareViaMessage addObject:[array objectAtIndex:[[keys objectAtIndex:i] integerValue]]];
        
    }
    
    if (self.shareType == Twitter) {
        
        if ([self.delegate respondsToSelector:@selector(twitterShare:referChannel:)])
        {
            
            [self.delegate twitterShare:shareViaMessage referChannel:self.referChannel];
            
        }
        
    }else if (self.shareType == WhatsApp){
        
        if ([self.delegate respondsToSelector:@selector(wahtsUpWithContacts:referChannel:)])
        {
            
            [self.delegate wahtsUpWithContacts:shareViaMessage referChannel:self.referChannel];
            
        }
        
    }else if (self.shareType == FaceBook){
        
        if ([self.delegate respondsToSelector:@selector(facebookShare:referChannel:)])
        {
            
            [self.delegate facebookShare:shareViaMessage referChannel:self.referChannel];
            
        }
        
    }
    
}

- (void)facebook:(UITapGestureRecognizer *)gestureRecognizer
{
    
    NSDictionary *notification = [[NSDictionary alloc]initWithObjectsAndKeys:@"yes",@"navigationbar",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiderightnvaigationbarbutton" object:notification];
    
    [self endEditing:YES];
    self.shareType = FaceBook;
    [self setReferActiveWithShareType:self.shareType];
    NSDictionary *indexPaths =  [self getIndexPathsWithSahreType:self.shareType section:0];
    
    NSArray *keys = [indexPaths allKeys];
    
    NSArray *array = [self getContactsWithShareType:self.shareType section:0];
    
    NSMutableArray *shareViaMessage = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [keys  count]; i++) {
        
        [shareViaMessage addObject:[array objectAtIndex:[[keys objectAtIndex:i] integerValue]]];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(facebookShare:referChannel:)])
    {
        
        [self.delegate facebookShare:shareViaMessage referChannel:self.referChannel];
        
    }
    

    
    //    NSString *key = [self getKeyWithShareType:self.shareType];
    //    [(UISearchBar *)[self viewWithTag:kReferSearchTag] setText:[self.dictionary objectForKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]]];
    //    [self reloadData];
    //[(UIView *)[self viewWithTag:kReferWhatsAppTag] removeFromSuperview];
    //[self whatsAppView];
    
}

- (void)twitter:(UITapGestureRecognizer *)gestureRecognizer
{

    
    
    NSDictionary *notification = [[NSDictionary alloc]initWithObjectsAndKeys:@"yes",@"navigationbar",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiderightnvaigationbarbutton" object:notification];
    
    [self endEditing:YES];
    self.shareType = Twitter;
    [self setReferActiveWithShareType:self.shareType];
    
    NSDictionary *indexPaths =  [self getIndexPathsWithSahreType:self.shareType section:0];
    
    NSArray *keys = [indexPaths allKeys];
    
    NSArray *array = [self getContactsWithShareType:self.shareType section:0];
    
    NSMutableArray *shareViaMessage = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [keys  count]; i++) {
        
        [shareViaMessage addObject:[array objectAtIndex:[[keys objectAtIndex:i] integerValue]]];
        
    }

    if ([self.delegate respondsToSelector:@selector(twitterShare:referChannel:)])
    {
        
        [self.delegate twitterShare:shareViaMessage referChannel:self.referChannel];
        
    }

    
    //    NSString *key = [self getKeyWithShareType:self.shareType];
    //    [(UISearchBar *)[self viewWithTag:kReferSearchTag] setText:[self.dictionary objectForKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]]];
    //    [self reloadData];
    [(UIView *)[self viewWithTag:kReferWhatsAppTag] removeFromSuperview];
    //[self whatsAppView];
    
}

- (NSArray *)getSearchContactsWithShareType:(ShareType)sharetype section:(NSInteger)section
{
    
     NSString *key =[self getKeyWithShareType:self.shareType];
    
    NSArray *contacts = nil;
    
    switch (sharetype) {
        case Message:
            contacts = (section == 1)?[[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]]  objectForKey:kReferPhoneContactNumber]:[[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] objectForKey:kReferNewlyAddedNumber];
            break;
        case Email:
            contacts = (section == 1)?[[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]]  objectForKey:kReferPhoneContactEmail]:[[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]]  objectForKey:kReferNewlyAddedEmail];
            break;
        case WhatsApp:
            contacts = [[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] objectForKey:kReferWhatsUp];
            break;
        case FaceBook:
            contacts = [[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] objectForKey:kReferFaceBook];
            break;
        case Twitter:
            contacts = [[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] objectForKey:kReferTwitter];
            break;
        default:
            break;
    }
    
    return contacts;
    
    
}


- (NSArray *)getContactsWithShareType:(ShareType)sharetype section:(NSInteger)section
{
    
    NSArray *contacts = nil;
    
    switch (sharetype) {
        case Message:
            contacts = (section == 1)?[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferPhoneContactNumber]:[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber];
            break;
        case Email:
            contacts = (section == 1)?[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferPhoneContactEmail]:[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail];
            break;
        case WhatsApp:
            contacts = [self.dictionary objectForKey:kReferWhatsUp];
            break;
        case FaceBook:
            contacts = [self.dictionary objectForKey:kReferFaceBook];
            break;
        case Twitter:
            contacts = [self.dictionary objectForKey:kReferTwitter];
            break;
        default:
            break;
    }
    
    return contacts;
    
    
}

- (void)selectAllGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    NSString *key = [self getKeyWithShareType:self.shareType];
    
    if(selectAllTick.tag == kUnselectTag)
    {
        selectAllTick.image = [UIImage imageNamed:@"icon_tick.png"];
        selectAllTick.tag = kSelectTag;
        
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (int j=0; j < 2; j++) {
            
            NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
            
            NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
            
            for (int i =0; i < [contacts count]; i++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
                [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
                
            }
            
            if ([indexs count] >0)
            {
                
                
                [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
                
                
            }
            
            
        }
        
        [self.indexPaths setValue:dictionary forKey:key];
        
        [self reloadData];
        
    }
    else
    {
        selectAllTick.image = [UIImage imageNamed:@""];
        selectAllTick.tag = kUnselectTag;
        
        [self.indexPaths setValue:nil forKey:key];
        
        
        NSString *key = [self getKeyWithShareType:self.shareType];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (int j=0; j < 1; j++) {
            
            NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
            
            NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
            
            for (int i =0; i < [contacts count]; i++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
                [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
                
            }
            
            if ([indexs count] >0)
            {
                
                [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
                
            }
            
            
        }
        
        NSMutableDictionary *selcDictionary = [[NSMutableDictionary alloc]init];
        
        [selcDictionary setValue:dictionary forKey:[NSString stringWithFormat:@"%d",0]];
        
        [selcDictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)1]] forKey:[NSString stringWithFormat:@"%ld",(long)1]];
        
        [self.indexPaths setValue:dictionary forKey:key];
        
        [self reloadData];
        
    }
    
    
    
}

- (UIButton *)createButtonWithFrame:(CGRect)frame titil:(NSString *)title backgroundColor:(UIColor *)backgroundColor
{
    
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    [button setBackgroundColor:backgroundColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button.layer setCornerRadius:17.0];
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
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
    
}

- (UIView *)createViewWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor
{
    
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:backgroundColor];
    return view;
    
}

- (UITextField *)createTextFiledWithFrame:(CGRect)frame
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setDelegate:self];
    [textField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [textField setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [textField.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:0.0];
    [textField.layer setMasksToBounds:YES];
    [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setTextAlignment:NSTextAlignmentCenter];
    
    [textField becomeFirstResponder];
    
    return textField;
    
}

- (CGFloat)returnHeightForHeaderSectionWithShareType:(ShareType)shareType section:(NSInteger)section
{
    CGFloat height = 0.0;
    
    
    
    switch (shareType) {
        case Message:
            
            height = (section == 1)?([[[self.dictionary objectForKey:kReferMessage]objectForKey:kReferPhoneContactNumber] count] >0)?36.0:0.0:([[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count])?2.0:0.0;
            
            break;
        case Email:
            
            height = (section == 1)?([[[self.dictionary objectForKey:kReferEmail]objectForKey:kReferPhoneContactEmail] count] >0)?36.0:0.0:([[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count])?2.0:0.0;
            break;
        case WhatsApp:
            height = [[self.dictionary objectForKey:kReferWhatsUp] count];
            break;
        case FaceBook:
            height = [[self.dictionary objectForKey:kReferFaceBook] count];
            break;
        case Twitter:
            height = [[self.dictionary objectForKey:kReferTwitter] count];
            break;
            
        default:
            break;
    }
    
    return height;
}


- (NSUInteger)returnNumberOfSectionWithShareType:(ShareType)shareType section:(NSInteger)section
{
    NSUInteger count = 0.0;
    
    switch (shareType) {
        case Message:
            
            count = (section == 1)?[[[self.dictionary objectForKey:kReferMessage]objectForKey:kReferPhoneContactNumber] count]:([[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count] > 0)?((self.shareType == Message)?self.isMessageExpand:self.isMailExpand)?[[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count]:0:0;
            
            break;
        case Email:
            
            count = (section == 1)?[[[self.dictionary objectForKey:kReferEmail]objectForKey:kReferPhoneContactEmail] count]:([[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count] > 0)?((self.shareType == Message)?self.isMessageExpand:self.isMailExpand)?[[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count]:0:0;
            
        
            break;
        case WhatsApp:
            count = [[self.dictionary objectForKey:kReferWhatsUp] count];
            break;
        case FaceBook:
            count = [[self.dictionary objectForKey:kReferFaceBook] count];
            break;
        case Twitter:
            count = [[self.dictionary objectForKey:kReferTwitter] count];
            break;
            
        default:
            break;
    }
    
    return count;
}



#pragma mark - tableView datasource and delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 2;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    
    
    return [self returnHeightForHeaderSectionWithShareType:self.shareType section:section];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = self.frame.size.width;
    CGFloat height = 36.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:(section == 0)?[UIColor clearColor]:[UIColor colorWithRed:(211.0/255.0) green:(91.0/255.0) blue:(61.0/255.0) alpha:1.0]];
    UILabel *label = [[UILabel alloc]initWithFrame:view.frame];
    [label setText:(section == 1)?@"Select from Phone Contacts":@""];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];

   
    
    if ((self.shareType == Message)?[[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count] > 0:[[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count] > 0)
    {
        
        UIView *headerView = (UIView *)[self viewWithTag:kMainHeaderViewTag];
        CGRect newFrame = headerView.frame;
        newFrame.size = CGSizeMake(headerView.frame.size.width, 36.0);
        headerView.frame = newFrame;
        [headerView setHidden:NO];
        [headerView setUserInteractionEnabled:YES];
        
        
        if (!self.isHeight)
        {
            self.isHeight = YES;
            UIView *tableHeaderView = (UIView *)[self viewWithTag:kTableHeaderViewTag];
            yPos = 42.0;
            NSArray *array = [tableHeaderView subviews];
            
            CGRect newTableViewFrame = tableHeaderView.frame;
            newTableViewFrame.origin = CGPointMake(tableHeaderView.frame.origin.x, tableHeaderView.frame.origin.y + yPos);
            tableHeaderView.frame = newTableViewFrame;
            
            CGRect newTableViewFrameSize = tableHeaderView.frame;
            newTableViewFrameSize.size = CGSizeMake(tableHeaderView.frame.size.width, tableHeaderView.frame.size.height - yPos);
            tableHeaderView.frame = newTableViewFrameSize;
            
            CGRect newTableFrameSize = [(UITableView *)[array objectAtIndex:0] frame];
            newTableFrameSize.size = CGSizeMake(tableHeaderView.frame.size.width, tableHeaderView.frame.size.height);
            [(UITableView *)[array objectAtIndex:0] setFrame:newTableFrameSize];
            
        }
       

//        CGRect tableNewFrame = self.tableView.frame;
//        tableNewFrame.origin = CGPointMake(tableHeaderView.frame.origin.x, yPos);
//        self.tableView.frame = tableNewFrame;
        

//        [self.tableView setContentInset:UIEdgeInsetsMake(0.0 + 40.0, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right)];

        [(UILabel *)[[headerView subviews]objectAtIndex:0] setText:[NSString stringWithFormat:@"Selected Recipients (%lu)",(self.shareType == Message)?[[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count]:[[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count]]];
        
//        xPos = 0.0;
//        yPos = [(UILabel *)[[headerView subviews]objectAtIndex:0] frame].size.height +[(UILabel *)[[headerView subviews]objectAtIndex:0] frame].origin.y;
//        width = headerView.frame.size.width;
//        height = 6.0;
//        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
//        [lineView setBackgroundColor:[UIColor greenColor]];
//        [headerView addSubview:lineView];

        
        UIImageView *imageView = (UIImageView *)[[headerView subviews]objectAtIndex:1];
        CGRect newImageFrame = imageView.frame;
        
        //((self.shareType == Message)?[[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count] > 1:[[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count] > 1)
        
        if ((self.shareType == Message)?self.isMessageExpand:self.isMailExpand)
        {
            
            BOOL isExpnad = NO;
            
            if (self.shareType == Message && [[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count] >0)
            {
                isExpnad = YES;
                
            }else if (self.shareType == Email && [[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count] >0)
            {
                isExpnad = YES;
            }
            
            if (isExpnad)
            {
                
                newImageFrame.size = CGSizeMake(32.0, 32.0);
                [imageView setImage:[UIImage imageNamed:@"icon_down_arrow.png"]];
                
            }else
            {
                newImageFrame.size = CGSizeMake(32.0, 32.0);
                [imageView setImage:[UIImage imageNamed:@"icon_up_arrow.png"]];
                
            }
            
        }else
        {
            newImageFrame.size = CGSizeMake(32.0, 32.0);
            [imageView setImage:[UIImage imageNamed:@"icon_up_arrow.png"]];
        }
        
        imageView.frame = newImageFrame;
        
    }else
    {
        
        UIView *headerView = (UIView *)[self viewWithTag:kMainHeaderViewTag];
        CGRect newFrame = headerView.frame;
        newFrame.size = CGSizeMake(headerView.frame.size.width, 0.0);
        headerView.frame = newFrame;
        [headerView setHidden:YES];

        
        if (self.isHeight)
            
        {
            self.isHeight = NO;
            UIView *tableHeaderView = (UIView *)[self viewWithTag:kTableHeaderViewTag];
            yPos = -42.0;
            NSArray *array = [tableHeaderView subviews];
            
            CGRect newTableViewFrame = tableHeaderView.frame;
            newTableViewFrame.origin = CGPointMake(tableHeaderView.frame.origin.x, tableHeaderView.frame.origin.y + yPos);
            tableHeaderView.frame = newTableViewFrame;
            
            CGRect newTableViewFrameSize = tableHeaderView.frame;
            newTableViewFrameSize.size = CGSizeMake(tableHeaderView.frame.size.width, tableHeaderView.frame.size.height - yPos);
            tableHeaderView.frame = newTableViewFrameSize;
            
            CGRect newTableFrameSize = [(UITableView *)[array objectAtIndex:0] frame];
            newTableFrameSize.size = CGSizeMake(tableHeaderView.frame.size.width, tableHeaderView.frame.size.height);
            [(UITableView *)[array objectAtIndex:0] setFrame:newTableFrameSize];
            
        }
        
    
//         [self.tableView setContentInset:UIEdgeInsetsMake(0.0 + 0.0, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right)];
        
    }
    
    
    return view;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self returnNumberOfSectionWithShareType:self.shareType section:section];

    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
        return 70.0;
    
    
}

- (UITableViewCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kShareIdentifier];
    
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kShareIdentifier];
    
        [self createShareViewWithTableViewCell:cell indexPath:indexPath];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.shareType == Message || self.shareType == Email)
    {
        cell.indentationLevel = cell.indentationLevel + 5.9;
    }
    else if(self.shareType == WhatsApp || self.shareType == FaceBook || self.shareType == Twitter)
    {
       // [cell.detailTextLabel removeFromSuperview];
    }
        
    
    
        return cell;
 

    
    
    
}



- (void)createShareViewWithTableViewCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 64.0;
    CGFloat yPos = 0.0;
    CGFloat height = 30.0;
    CGFloat width = frame.size.width;
    UILabel *labelList = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelList.tag = indexPath.row;
    
    NSString *list;
    NSArray *contacts = [self getContactsWithShareType:self.shareType section:indexPath.section];
    
    if (self.shareType == Message) {
        
        list = [NSString stringWithFormat:@"%@ %@",([[contacts objectAtIndex:indexPath.row] objectForKey:@"firstname"] != nil && [[[contacts objectAtIndex:indexPath.row] objectForKey:@"firstname"] length] >0)?[[contacts objectAtIndex:indexPath.row] objectForKey:@"firstname"]:@"",([[contacts objectAtIndex:indexPath.row] valueForKey:@"lastname"] != nil && [[[contacts objectAtIndex:indexPath.row] valueForKey:@"lastname"] length] > 0)?[[contacts objectAtIndex:indexPath.row] valueForKey:@"lastname"]:@""];
        
    }else if (self.shareType == Email){
        
        list = [NSString stringWithFormat:@"%@",[[contacts objectAtIndex:indexPath.row] valueForKey:@"email"]];
        
        
    }
    
    if (self.shareType == WhatsApp || self.shareType == FaceBook || self.shareType == Twitter)
    {
        yPos = 10.0;
        labelList.frame = CGRectMake(xPos, yPos, width, height);
    }
    
    labelList.text = NSLocalizedString(list, @"");
    labelList.font = [[Configuration shareConfiguration] yoReferFontWithSize:13.0];
    labelList.textColor = [UIColor blackColor];
    [cell.contentView addSubview:labelList];
    
    
    NSMutableString *phoneData;
    if (self.shareType  == WhatsApp)
    {
    }else
    {
        self.phonesData = [contacts valueForKey:@"phonenumber"];
        self.data = [[contacts objectAtIndex:indexPath.row] valueForKey:@"phonenumber"];
    }
    if (self.shareType == Message)
    {
        if (indexPath.section == 0)
        {
            cell.detailTextLabel.text = [[contacts objectAtIndex:indexPath.row] objectForKey:@"referphonnumber"];
            
        }else
        {
            for (int i =0; i<self.data.count; i++)
            {
                if (i == 0) {
                    phoneData =[NSMutableString stringWithFormat:@"%@" ,[self.data objectAtIndex:i]];
                }
                else
                {
                    phoneData =[NSMutableString stringWithFormat:@"%@,%@" ,phoneData,[self.data objectAtIndex:i]];
                }
            }
            
            cell.detailTextLabel.text = phoneData;
            
        }
        

    }
    else if (self.shareType == Email)
    {
       
        NSMutableArray *emailFNames = [[NSMutableArray alloc]init];
        NSMutableArray *emailLNames = [[NSMutableArray alloc]init];
        emailFNames =  ([[contacts objectAtIndex:indexPath.row] valueForKey:@"firstname"] != nil && [[[contacts objectAtIndex:indexPath.row] valueForKey:@"firstname"] isKindOfClass:[NSString class]])?[[contacts objectAtIndex:indexPath.row] valueForKey:@"firstname"]:@"";
        emailLNames  = ([[contacts objectAtIndex:indexPath.row] valueForKey:@"lastname"] != nil && [[[contacts objectAtIndex:indexPath.row] valueForKey:@"lastname"] isKindOfClass:[NSString class]])?[[contacts objectAtIndex:indexPath.row] valueForKey:@"lastname"]:@"";
       // NSMutableArray *Names = [[NSMutableArray alloc]init];
        
//        for (int i =0; i<emailFNames.count; i++)
//        {
//            
//            phoneData =[NSMutableString stringWithFormat:@"%@ %@" ,[emailFNames objectAtIndex:i],[emailLNames objectAtIndex:i]];
//            [Names addObject:phoneData ];
//            
//        }
//
//        
        labelList.text = [NSString stringWithFormat:@"%@ %@",emailFNames,emailLNames];
        cell.detailTextLabel.text =NSLocalizedString(list, nil);
        
    }
    else if(self.shareType == WhatsApp || self.shareType == FaceBook || self.shareType == Twitter)
    {
        [cell.detailTextLabel removeFromSuperview];
    }

    
    cell.detailTextLabel.numberOfLines = 3;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];

    
    
    xPos = 20.0;
    yPos = 5.0;
    width = 40.0;
    height = 40.0;
    UIImageView *contactImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    contactImage.image = profilePic;
    contactImage.layer.cornerRadius = 20.0;
    contactImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    contactImage.layer.borderWidth = 1.0;
    contactImage.layer.masksToBounds = YES;
    [cell.contentView addSubview:contactImage];
    
    xPos = 0.0;
    yPos = labelList.frame.size.height +38.0;
    height = 2.0;
    width = frame.size.width;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:viewLine];
    
    xPos = frame.size.width - 40.0;
    yPos = 7.0;
    width = 24.0;
    height = 24.0;
    UILabel *lableCircle = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    lableCircle.layer.cornerRadius = 12.0;
    lableCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    lableCircle.layer.borderWidth = 1.0;
    lableCircle.layer.masksToBounds = YES;
    
    if (self.shareType == WhatsApp || self.shareType == Twitter || self.shareType == FaceBook)
    {
        xPos = frame.size.width - 40.0;
        yPos = 12.0;
        width = 24.0;
        height = 24.0;
        lableCircle.frame = CGRectMake(xPos, yPos, width, height);
        labelList.textColor = [UIColor blackColor];
        labelList.font = [UIFont systemFontOfSize:18.0];
        //[self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    }
    [cell.contentView addSubview:lableCircle];
    xPos = 0.0;
    yPos = 0.0;
    
    UIImageView *tick = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    NSMutableDictionary *indexPaths = [self getIndexPathsWithSahreType:self.shareType section:indexPath.section];
    
    if ([indexPaths count] > 0 &&  [indexPaths objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] &&[(NSIndexPath *)[indexPaths objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]row] == indexPath.row)
    {
        tick.image = [UIImage imageNamed:@"icon_tick.png"];
        
    }else
    {
        tick.image = [UIImage imageNamed:@""];
    }
    
    [lableCircle addSubview:tick];
    
}



- (NSMutableDictionary *)getIndexPathsWithSahreType:(ShareType)shareType section:(NSInteger)section
{
    
    NSMutableDictionary *indexPaths = nil;
    
    switch (shareType) {
        case Message:
            indexPaths = [[self.indexPaths objectForKey:kReferMessage] objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
            break;
        case Email:
            indexPaths = [[self.indexPaths objectForKey:kReferEmail] objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
            break;
        case WhatsApp:
            indexPaths = [self.indexPaths objectForKey:kReferWhatsUp];
            break;
        case FaceBook:
            indexPaths = [self.indexPaths objectForKey:kReferFaceBook];
            break;
        case Twitter:
            indexPaths = [self.indexPaths objectForKey:kReferTwitter];
            break;
        default:
            break;
    }
    
    return indexPaths;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.shareType == Message)
    {
        self.phonenum =   [self.phonesData objectAtIndex:indexPath.row];
        if (indexPath.section == 0)
        {
            
            [self setIndexPathWithShareType:self.shareType indexPath:indexPath];
            
        }else
        {
            self.phonenum =   [self.phonesData objectAtIndex:indexPath.row];
            self.indexPath = indexPath;
            if ([self.phonenum count] == 1)
            {
                [self setIndexPathWithShareType:self.shareType indexPath:self.indexPath];
            }
            else
            {
                AlertView *alert = [[AlertView alloc]initWithViewFrame:[self bounds] delegate:self referChannel:self.phonenum];
                [alert setTag:180000];
                [self addSubview:alert];
            }
            
        }
        
    }
    else if (self.shareType == Email)
    {
        [self setIndexPathWithShareType:self.shareType indexPath:indexPath];
    }
    
}

-(void)selectedPhoneNumber:(NSString *)phoneNumber
{
    [(UIView *)[self viewWithTag:180000] removeFromSuperview];
    self.selcPhoneNumber = phoneNumber;
    [self setIndexPathWithShareType:self.shareType indexPath:self.indexPath];
}


- (void)setIndexPathWithShareType:(ShareType)shareType indexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *message = [self getIndexPathsWithSahreType:(ShareType)shareType section:indexPath.section];
    
    NSString *key = (shareType == Message)?kReferMessage:(shareType == Email)?kReferEmail:(shareType == WhatsApp)?kReferWhatsUp:(shareType == FaceBook)?kReferFaceBook:(shareType == Twitter)?kReferTwitter:@"";
    
    if([message objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
    {
        [message removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
        if ([message count] <= 0)
            message = [[NSMutableDictionary alloc]init];
        
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        if (indexPath.section == 0)
        {
            if ([message count] == 0){
              
                if (self.shareType == Message)
                    self.isMessageExpand = NO;
                else
                    self.isMailExpand = NO;
                
            }
            
            
            [dictionary setValue:message forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
            
            [dictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)1]] forKey:[NSString stringWithFormat:@"%ld",(long)1]];
            
            
        }else if(indexPath.section == 1)
        {
            
            [dictionary setValue:message forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
            
            [dictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)0]] forKey:[NSString stringWithFormat:@"%ld",(long)0]];
            
        }
        
        
        [self.indexPaths setValue:dictionary forKey:key];
        
        selectAllTick.image = [UIImage imageNamed:@""];
        selectAllTick.tag = kUnselectTag;
        
    }else
    {
        if (!message)
            message = [[NSMutableDictionary alloc]init];
        
        
        [message setValue:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        if (indexPath.section == 0)
        {
            
            [dictionary setValue:message forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
            
            [dictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)1]] forKey:[NSString stringWithFormat:@"%ld",(long)1]];
            
            
        }else if(indexPath.section == 1)
        {
            
            [dictionary setValue:message forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
            
            [dictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)0]] forKey:[NSString stringWithFormat:@"%ld",(long)0]];
            
        }
        
        [self.indexPaths setValue:dictionary forKey:key];
        
    }
    
//    if ([message count] == [self returnNumberOfSectionWithShareType:self.shareType section:indexPath.section])
//    {
//        selectAllTick.image = [UIImage imageNamed:@"icon_tick.png"];
//        selectAllTick.tag = kSelectTag;
//    }
    
//    NSArray *indexPaths = [[NSArray alloc]initWithObjects:indexPath, nil];
//    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    if (indexPath.section == 1)
        [self selectReferContactWithIndexPath:indexPath];
    else
        [self deSelectReferContactWithIndexPath:indexPath];
    
    
    [self reloadData];
    
}

- (BOOL)verifyingEmailsWithEmailId:(NSString *)emailId emails:(NSMutableArray *)emails
{
    
    BOOL isVerify = NO;
    
    for (int i = 0; i < [emails count]; i++) {
        
        if ([(self.shareType == Email)?[[emails objectAtIndex:i] objectForKey:@"email"]:[[[emails objectAtIndex:i] objectForKey:@"phonenumber"] objectAtIndex:0] isEqualToString:emailId])
       {
           isVerify = YES;
       }
        
        
    }
    
    return isVerify;
    
}


- (void)deSelectReferContactWithIndexPath:(NSIndexPath *)indexPath
{

     NSString *key = [self getKeyWithShareType:self.shareType];

    NSArray *array = [[self.dictionary objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
        
         NSMutableArray *emails = [[NSMutableArray alloc]init];
        
        for (int i =0; i < [array count]; i++) {
            
            [emails addObject:[array objectAtIndex:i]];
            
        }
        
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber]];
        
        
    if([self verifyingEmailsWithEmailId:(self.shareType == Email)?[[contacts objectAtIndex:indexPath.row] objectForKey:@"email"]:[[[contacts objectAtIndex:indexPath.row] objectForKey:@"phonenumber"] objectAtIndex:0] emails:[[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] objectForKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber]])
                [emails addObject:[contacts objectAtIndex:indexPath.row]];
        
        
        //remove contact
        
        NSMutableArray *addExistsEmail = [[NSMutableArray alloc]init];
        
        for (int i =0; i < [contacts count]; i++) {
            
            if (i == indexPath.row)
            {
                
            }else
            {
                [addExistsEmail addObject:[contacts objectAtIndex:i]];
                
            }
        }
        
        NSMutableArray *uniqueArray = [NSMutableArray array];
        
        [uniqueArray addObjectsFromArray:[[NSSet setWithArray:emails] allObjects]];
        
        [uniqueArray setArray:[self sortArrayWithArray:uniqueArray]];
        
        NSMutableDictionary *uniqueDictionary = [[NSMutableDictionary alloc]init];
        
    [uniqueDictionary setValue:uniqueArray forKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
    
    [uniqueDictionary setValue:addExistsEmail forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    [self.dictionary setValue:uniqueDictionary forKey:(self.shareType == Email)?kReferEmail:kReferMessage];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    for (int j=0; j < 1; j++) {
        
        NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
        
        NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
        
        for (int i =0; i < [contacts count]; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
            
        }
        
        if ([indexs count] >0)
        {
            
            [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
            
        }
        
        
    }
    
    NSMutableDictionary *selcDictionary = [[NSMutableDictionary alloc]init];
    
    [selcDictionary setValue:dictionary forKey:[NSString stringWithFormat:@"%d",1]];
    
    [selcDictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)0]] forKey:[NSString stringWithFormat:@"%ld",(long)0]];
    
    [self.indexPaths setValue:dictionary forKey:key];
    
    NSMutableDictionary *filterEmails = [[NSMutableDictionary alloc]init];
    
    [filterEmails setValue:[[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] objectForKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber] forKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
    
    [filterEmails setValue:addExistsEmail forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    [self.filterSearch setValue:filterEmails forKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]];
    
}

- (void)selectReferContactWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *emials = [[self.dictionary objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
        
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber]];
        
        if ([contacts count] <= 0)
            contacts = [[NSMutableArray alloc]init];
   if (self.selcPhoneNumber != nil && [self.selcPhoneNumber length] > 0)
    {
        [[emials objectAtIndex:indexPath.row ] setValue:self.selcPhoneNumber forKey:@"referphonnumber"];
        self.selcPhoneNumber = @"";

    }
    
        [contacts addObject:[emials objectAtIndex:indexPath.row ]];
        
        //remove contact
        
        NSMutableArray *addExistsEmail = [[NSMutableArray alloc]init];
        
        for (int i =0; i < [emials count]; i++) {
            
            if (i == indexPath.row)
            {
                
            }else
            {
                [addExistsEmail addObject:[emials objectAtIndex:i]];
                
            }
        }
        
        
        NSMutableArray *uniqueArray = [NSMutableArray array];
        
        [uniqueArray addObjectsFromArray:[[NSSet setWithArray:contacts] allObjects]];
        
        [uniqueArray setArray:[self sortArrayWithArray:uniqueArray]];
        
        NSMutableDictionary *uniqueDictionary = [[NSMutableDictionary alloc]init];
        
    [uniqueDictionary setValue:addExistsEmail forKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
    
    [uniqueDictionary setValue:uniqueArray forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    [self.dictionary setValue:uniqueDictionary forKey:(self.shareType == Email)?kReferEmail:kReferMessage];
    
    
    NSString *key = [self getKeyWithShareType:self.shareType];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    for (int j=0; j < 1; j++) {
        
        NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
        
        NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
        
        for (int i =0; i < [contacts count]; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
            
        }
        
        if ([indexs count] >0)
        {
            
            [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
            
        }
        
        
    }
    
    NSMutableDictionary *selcDictionary = [[NSMutableDictionary alloc]init];
    
    [selcDictionary setValue:dictionary forKey:[NSString stringWithFormat:@"%d",0]];
    
    [selcDictionary setValue:[[self.indexPaths objectForKey:key] objectForKey:[NSString stringWithFormat:@"%ld",(long)1]] forKey:[NSString stringWithFormat:@"%ld",(long)1]];
    
    [self.indexPaths setValue:dictionary forKey:key];
    
    //Get nely added contact
    
    NSMutableDictionary *email = [self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]];
    
    NSArray *phoneEmail = [email objectForKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
    
    NSMutableArray *newlyAddedEmail = [email objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    if ([newlyAddedEmail count] <=0)
          newlyAddedEmail = [[NSMutableArray alloc]init];
    
    for (int  i =0; i < [[[self.dictionary  objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber] count]; i++) {
        
        [newlyAddedEmail addObject:[[[self.dictionary  objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber] objectAtIndex:i]];
        
    }
    
    NSMutableDictionary *filterEmails = [[NSMutableDictionary alloc]init];
    [filterEmails setValue:phoneEmail forKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
    [filterEmails setValue:newlyAddedEmail forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    [self.filterSearch setValue:filterEmails forKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]];
    
    
}


- (NSString *)getAlertMessageWithShareType:(ShareType)shareType
{
    
    NSString *alertMessage;
    
    switch (shareType) {
        case Message:
            alertMessage = @"Please select contacts";
            break;
        case Email:
            alertMessage = @"Please select email";
            break;
        case WhatsApp:
            alertMessage = @"Please select contacts";
            break;
        case FaceBook:
            alertMessage = @"Please select friends";
            break;
        case Twitter:
            alertMessage = @"Please select friends";
            break;
            
        default:
            break;
    }
    
    return NSLocalizedString(alertMessage, @"") ;
}

#pragma mark - Button delegate

- (IBAction)addContactBtnTapped:(id)sender
{
    
    [self endEditing:YES];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.frame.origin.x, 0.0, self.frame.size.width, self.frame.size.height)];
    view.tag = 80000;
    [view setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(8.0/255.0) blue:(8.0/255.0) alpha:0.8f]];
    [self addSubview:view];
    
    CGFloat height = frame.size.height - 100.0;
    CGFloat width = view.frame.size.width - 24.0;
    CGFloat yPos = roundf((view.frame.size.height- height)/2);
    CGFloat xPos = roundf((view.frame.size.width - width)/2);
    
    NSString *type = (self.shareType == Message)?@"Message":@"email";
    
    NSMutableArray *referContacts = [[self.dictionary objectForKey:(self.shareType == Message)?kReferMessage:kReferEmail] objectForKey:(self.shareType == Message)?kReferNewlyAddedNumber:kReferNewlyAddedEmail];
    
    AddContact *addContact  = [[AddContact alloc]initWithViewFrame:CGRectMake(xPos, yPos, width, height)type:type delegate:self referContact:referContacts];
    [addContact.layer setCornerRadius:5.0];
    [addContact.layer setMasksToBounds:YES];
    [view addSubview:addContact];
    
    width = 26.0;
    height = 26.0;
    xPos = view.frame.size.width - (width + 3.0);
    yPos = yPos - 18.0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:[UIImage imageNamed:@"cross.png"]];
    [view addSubview:imageView];
    
    width = 50.0;
    height = 38.0;
    xPos = view.frame.size.width - width;
    yPos = yPos - 16.0;
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [closeBtn setBackgroundColor:[UIColor clearColor]];
    [closeBtn addTarget:self action:@selector(closeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
}


- (IBAction)referNowButtonTapped:(id)sender
{
    
    if ([self.indexPaths count] <=0)
    {
        
        alertView([[Configuration shareConfiguration] errorMessage],[self getAlertMessageWithShareType:self.shareType], nil, @"Ok", nil, 0);
        return;
        
    }
    
    
//    if (![BaseViewController isNetworkAvailable]) {
//        
//        NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:self.referChannel, nil];
//        
//        [[array objectAtIndex:0] removeObjectForKey:@"category"];
//        
//        [[CoreData shareData] setOfflineReferDetailsWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:array];
//        
//        [[UIManager sharedManager] goToHomePageWithAnimated:YES];
//        
//    }
    
    NSMutableArray *shareViaMessage = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 2; i++) {
        
        NSDictionary *indexPaths =  [self getIndexPathsWithSahreType:self.shareType section:i];
        
        NSArray *keys = [indexPaths allKeys];
        
        NSArray *array = [self getContactsWithShareType:self.shareType section:i];
        
        for (int j = 0; j < [keys  count]; j++) {
            
            [shareViaMessage addObject:[array objectAtIndex:[[keys objectAtIndex:j] integerValue]]];
            
        }
        
        
    }
    
    if (self.shareType == Message)
    {
        
        if ([self.delegate respondsToSelector:@selector(messageWithContacts:referChannel:)])
        {
            
            [self.delegate messageWithContacts:shareViaMessage referChannel:self.referChannel];
            
        }
        
    }else if (self.shareType == Email)
    {
        
        if ([self.delegate respondsToSelector:@selector(mailWithContacts:referChannel:)])
        {
            
            [self.delegate mailWithContacts:shareViaMessage referChannel:self.referChannel];
            
        }
        
        
    }else if (self.shareType == WhatsApp)
    {
        
        if ([self.delegate respondsToSelector:@selector(wahtsUpWithContacts:referChannel:)])
        {
            
            [self.delegate wahtsUpWithContacts:shareViaMessage referChannel:self.referChannel];
            
        }
        
        
    }
    
   

    
}


#pragma mark - GestureRecognizer
- (void)mainHeaderGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
     if ((self.shareType == Message)?[[[self.dictionary objectForKey:kReferMessage] objectForKey:kReferNewlyAddedNumber] count] > 0:[[[self.dictionary objectForKey:kReferEmail] objectForKey:kReferNewlyAddedEmail] count] > 0)
     {
         
         if ((self.shareType == Message)?self.isMessageExpand:self.isMailExpand){
             
             if (self.shareType == Message)
                 self.isMessageExpand = NO;
             else
                 self.isMailExpand = NO;
         }  else{
                 
                 if (self.shareType == Message)
                     self.isMessageExpand = YES;
                 else
                     self.isMailExpand = YES;
         }
         
         [self.tableView reloadData];
         
         if (self.isMessageExpand || self.isMailExpand)
         {
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];;
             
             [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
         }
        
         
         
     }
    
}


#pragma mark - GetContacts

-(NSMutableArray *)getContacts
{
    
    NSMutableArray *contactList = [[NSMutableArray alloc]init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = addressBookRef;
            NSLog(@"%@",addressBook);
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        CFIndex count = ABAddressBookGetPersonCount(addressBookRef);
        
        
        for (int i = 0; i < count; i++) {
            
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(ref, kABPersonLastNameProperty));
            
            firstName = (firstName != nil)?firstName:@"";
            lastName  = (lastName != nil)?lastName:@"";
            
            if ((firstName || lastName)) {
                
                NSArray *phoneNumbersRaw = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phones));
                
                NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithCapacity:phoneNumbersRaw.count];
                
                for (NSString *number in phoneNumbersRaw) {
                    //phone number must only contain numbers
                    NSMutableString *strippedNumber = [NSMutableString string];
                    
                    NSScanner *scanner = [NSScanner scannerWithString:number];
                    NSCharacterSet *numbers = [NSCharacterSet
                                               characterSetWithCharactersInString:@"0123456789"];
                    
                    while (![scanner isAtEnd]) {
                        NSString *buffer;
                        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
                            [strippedNumber appendString:buffer];
                            
                        } else {
                            [scanner setScanLocation:([scanner scanLocation] + 1)];
                        }
                    }
                    if (strippedNumber.length >0) {
                        
//                        [phoneNumbers addObject:[NSString stringWithString:strippedNumber]];
                        
                        if (strippedNumber.length > 10) {
                            [phoneNumbers addObject:[NSString stringWithString:strippedNumber]];
                        }
                        else
                        {
                            
                            NSLocale *locale = [NSLocale currentLocale];
                            NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
                            NSDictionary *dict = [self dictCountryCodes];
                            NSString *localNumberCode = dict[countryCode];
                            NSString *numberWithContry = [NSString stringWithFormat:@"+%@",localNumberCode];

                            [phoneNumbers addObject:[NSString stringWithFormat:@"%@%@",numberWithContry,[NSString stringWithString:strippedNumber]]];
                        }
                    }
                }
                
                NSString *email = @"";
                ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
                if (ABMultiValueGetCount(emails) > 0) {
                    email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, 0));
                }
                
                
                if ([[Helper shareHelper] emailValidationWithEmail:email]) {
                    [contact setObject:email forKey:@"Email"];
                }
                CFRelease(emails);
                
                if (!firstName) {
                    firstName = @"";
                }
                [contact setObject:firstName forKey:@"Firstname"];
                
                if (!lastName) {
                    lastName = @"";
                }
                [contact setObject:lastName forKey:@"Lastname"];
                [contact setObject:[NSArray arrayWithArray:phoneNumbers] forKey:@"Phonenumbers"];
                [contact setObject:[NSString stringWithFormat:@"%d",ABRecordGetRecordID(ref)] forKey:@"ABID"];
                
                
//                if (phoneNumbers.count != 0) {
                    [contactList addObject:contact];
                //}
            }
            CFRelease(phones);
            CFRelease(ref);
        }
        CFRelease(allPeople);
    }
    
    
    else {
        
    }
    
    return contactList;
    
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

- (void)getNewlyAddedContact
{
    
    
}

#pragma mark - Search Bar delegate


- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return YES;
}

-(void)animateSearchBar:(UISearchBar*)searchBar isUp:(BOOL)isUp
{
    UIView *view = [searchBar superview];
    
    
    if (isUp)
    {
        
        CGRect textFieldRect = [self convertRect:view.bounds fromView:searchBar];
        CGFloat bottomEdge = textFieldRect.origin.y + textFieldRect.size.height;
        //CGFloat keyboardYpos = self.frame.size.height - 200;
        
//        if (bottomEdge + 150.0 >= keyboardYpos) {
        
            CGRect viewFrame = self.frame;
            self.shiftForKeyboard = bottomEdge - 50.0f;
            viewFrame.origin.y -= self.shiftForKeyboard;
            [self setFrame:viewFrame];
            
//        }else{
//            
//            self.shiftForKeyboard = 0.0f;
//            
//        }
        
    }else
    {
        
        CGRect viewFrame = self.frame;
        viewFrame.origin.y += self.shiftForKeyboard;
        self.shiftForKeyboard = 0.0f;
        [self setFrame:viewFrame];
        
        
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    
}

- (void)setToolBarWithSearchBar:(UISearchBar *)searchBar
{
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTapped:)],
                           nil];
    [numberToolbar sizeToFit];
    searchBar.inputAccessoryView = numberToolbar;
    
}



- (IBAction)cancelButtonTapped:(id)sender
{
    
    [self endEditing:YES];
    
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    //[self animateSearchBar:searchBar isUp:YES];
    //[self setToolBarWithSearchBar:searchBar];
    
    return YES;
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    //[self animateSearchBar:searchBar isUp:NO];
    return YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
     [self enableDisableCancelWithsearchBar:searchBar Button:NO];
    
    [searchBar resignFirstResponder];
    
//    if ([searchBar.text length] == 0) {
//        
//        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
//    }
    
    NSString *key = [self getKeyWithShareType:self.shareType];
    
    NSString *searchKay = (self.shareType == Message)?@"firstname":(self.shareType == Email)?@"firstname":(self.shareType == WhatsApp)?@"firstname":(self.shareType == FaceBook)?@"firstname":(self.shareType == Twitter)?@"firstname":@"";
    
    
    // NSArray *contacts = [self getContactsWithShareType:self.shareType section:0];
    
    //    if(searchBar.text.length >= 3){
    
    
    
    [self.dictionary setValue:searchBar.text forKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    for (int i = 1; i < 2; i++) {
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        //NSArray *contacts = [self getSearchContactsWithShareType:self.shareType section:i];
        
        NSArray *filterArray = [self getFilterArray:[self getSearchContactsWithShareType:self.shareType section:i]];
        
        for (NSDictionary * dic in filterArray)
        {
            
            NSString *str;
            if (self.shareType == Message)
            {
                str = (self.shareType == Message ||self.shareType == Email )?([NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"firstname"],[dic objectForKey:@"lastname"]]):[dic objectForKey:searchKay];
                
            }
            else
            {
                str = (self.shareType == Message ||self.shareType == Email )?([NSString stringWithFormat:@"%@ %@ %@",[dic objectForKey:@"firstname"],[dic objectForKey:@"lastname"],[dic objectForKey:@"email"]]):[dic objectForKey:searchKay];
            }
            

            
            
            NSRange nameRange = [str rangeOfString:searchBar.text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            
            if (nameRange.length == [searchBar.text length])
            {
                NSLog(@"done");
                [array addObject:dic];
            }
            
            //                if(nameRange.location != NSNotFound)
            //                {
            //
            //                    [array addObject:dic];
            //
            //                }
        }
        
        if ([array count] >0)
            [dictionary setValue:array forKey:[NSString stringWithFormat:@"%@",(key == kReferEmail)?(i==0)?kReferNewlyAddedEmail:kReferPhoneContactEmail:(key == kReferMessage)?(i==0)?kReferNewlyAddedNumber:kReferPhoneContactNumber:@""]];
        
    }
    
    //Adding selected recepiants
    
    NSDictionary *filterDictionary = [self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]];
    
    
    NSMutableArray *uniquereferEmails = [NSMutableArray array];
    
    [uniquereferEmails addObjectsFromArray:[[NSSet setWithArray:[filterDictionary objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber]] allObjects]];
    
    [uniquereferEmails setArray:[self sortArrayWithArray:uniquereferEmails]];
    
    
    
    [dictionary setValue:uniquereferEmails forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    
    
    
    [self.dictionary setValue:dictionary forKey:key];
    
    
    
    NSMutableDictionary *keyDictionary = [[NSMutableDictionary alloc]init];
    
    for (int j=0; j < 1; j++) {
        
        NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
        
        NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
        
        for (int i =0; i < [contacts count]; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
            
        }
        
        if ([indexs count] >0)
        {
            
            [keyDictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
            
            
        }
        
        
    }
    
    [self.indexPaths setValue:keyDictionary forKey:key];
    
    
    [self reloadData];
    
}

- (NSMutableArray *)getFilterArray:(NSArray *)filterArray
{
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSArray *addedArray = [[self.dictionary objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage] objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    for (int i = 0; i < [filterArray count]; i++) {
        
        BOOL isRefer = NO;
        
        NSString *emailId = [NSString stringWithFormat:@"%@",(self.shareType == Email)?[[filterArray objectAtIndex:i] valueForKey:@"email"]:[[[filterArray objectAtIndex:i] valueForKey:@"phonenumber"] objectAtIndex:0]];
        
        for (int j = 0; j < [addedArray count]; j++) {
            
            NSString *referId = [NSString stringWithFormat:@"%@",(self.shareType == Email)?[[addedArray objectAtIndex:j] valueForKey:@"email"]:[[[addedArray objectAtIndex:j] valueForKey:@"phonenumber"] objectAtIndex:0]];
            
            if ([referId  isEqualToString:emailId])
            {
                
                isRefer = YES;
                
            }
            
            
        }
        
        if (!isRefer)
            [array addObject:[filterArray objectAtIndex:i]];
    }
    
    NSLog(@"%@",[array description]);
    
    
    return array;
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
//    if ([searchText length] == 0) {
//        [searchBar resignFirstResponder];
//        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
//    }
    
    NSString *key = [self getKeyWithShareType:self.shareType];
    
    NSString *searchKay = (self.shareType == Message)?@"firstname":(self.shareType == Email)?@"firstname":(self.shareType == WhatsApp)?@"firstname":(self.shareType == FaceBook)?@"firstname":(self.shareType == Twitter)?@"firstname":@"";
    
    
    // NSArray *contacts = [self getContactsWithShareType:self.shareType section:0];
    
    //    if(searchBar.text.length >= 3){
    
    
    
    [self.dictionary setValue:searchBar.text forKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    for (int i = 1; i < 2; i++) {
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        //NSArray *contacts = [self getSearchContactsWithShareType:self.shareType section:i];
        
        NSArray *filterArray = [self getFilterArray:[self getSearchContactsWithShareType:self.shareType section:i]];
        
        for (NSDictionary * dic in filterArray)
        {
            NSString *str;
            if (self.shareType == Message)
            {
                str = (self.shareType == Message ||self.shareType == Email )?([NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"firstname"],[dic objectForKey:@"lastname"]]):[dic objectForKey:searchKay];
                
            }
            else
            {
                str = (self.shareType == Message ||self.shareType == Email )?([NSString stringWithFormat:@"%@ %@ %@",[dic objectForKey:@"firstname"],[dic objectForKey:@"lastname"],[dic objectForKey:@"email"]]):[dic objectForKey:searchKay];
            }
            
            
            
            
            
            NSRange nameRange = [str rangeOfString:searchBar.text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            
            if (nameRange.length == [searchBar.text length])
            {
                NSLog(@"done");
                [array addObject:dic];
            }
            
            //                if(nameRange.location != NSNotFound)
            //                {
            //
            //                    [array addObject:dic];
            //
            //                }
        }
        
        if ([array count] >0)
            [dictionary setValue:array forKey:[NSString stringWithFormat:@"%@",(key == kReferEmail)?(i==0)?kReferNewlyAddedEmail:kReferPhoneContactEmail:(key == kReferMessage)?(i==0)?kReferNewlyAddedNumber:kReferPhoneContactNumber:@""]];
        
    }
    
    //Adding selected recepiants
    
    NSDictionary *filterDictionary = [self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]];
    
    
    NSMutableArray *uniquereferEmails = [NSMutableArray array];
    
    [uniquereferEmails addObjectsFromArray:[[NSSet setWithArray:[filterDictionary objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber]] allObjects]];
    
    [uniquereferEmails setArray:[self sortArrayWithArray:uniquereferEmails]];

    

    [dictionary setValue:uniquereferEmails forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
    
    
    
    [self.dictionary setValue:dictionary forKey:key];
    
    
    
    NSMutableDictionary *keyDictionary = [[NSMutableDictionary alloc]init];
    
    for (int j=0; j < 1; j++) {
        
        NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
        
        NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
        
        for (int i =0; i < [contacts count]; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
            
        }
        
        if ([indexs count] >0)
        {
            
            [keyDictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
            
            
        }
        
        
    }
    
    [self.indexPaths setValue:keyDictionary forKey:key];

      
    [self reloadData];

    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setText:@""];

    NSString *key =[self getKeyWithShareType:self.shareType];
    
    if ([[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] count] > 0){
        
        [self.dictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]];
        
        [self.dictionary setValue:[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] forKey:key];
        
        NSString *key = [self getKeyWithShareType:self.shareType];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (int j=0; j < 1; j++) {
            
            NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
            
            NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
            
            for (int i =0; i < [contacts count]; i++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
                [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
                
            }
            
            if ([indexs count] >0)
            {
                
                [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
                
                
            }
            
            
        }
        
        [self.indexPaths setValue:dictionary forKey:key];
        
        [self getSelctedContacts];
        
        [self reloadData];
        
    }

}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self enableDisableCancelWithsearchBar:searchBar Button:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self endEditing:YES];
    
}

- (void)enableDisableCancelWithsearchBar:(UISearchBar *)searchBar Button:(BOOL)isCancel
{
    searchBar.showsCancelButton = isCancel;
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar{
    
   [searchBar resignFirstResponder];
    
    NSString *key =[self getKeyWithShareType:self.shareType];
    
    if ([[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] count] > 0){
        
        [self.dictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@%@",kReferSearchText,key]];
        
        [self.dictionary setValue:[self.filterSearch objectForKey:[NSString stringWithFormat:@"%@%@",kReferFilter,key]] forKey:key];
        
        NSString *key = [self getKeyWithShareType:self.shareType];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (int j=0; j < 1; j++) {
            
            NSArray *contacts = [self getContactsWithShareType:self.shareType section:j];
            
            NSMutableDictionary *indexs = [[NSMutableDictionary alloc]init];
            
            for (int i =0; i < [contacts count]; i++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
                [indexs setValue:indexPath forKey:[NSString stringWithFormat:@"%d",i]];
                
            }
            
            if ([indexs count] >0)
            {
                
                [dictionary setValue:indexs forKey:[NSString stringWithFormat:@"%ld",(long)j]];
                
                
            }
            
            
        }
        
        [self.indexPaths setValue:dictionary forKey:key];
        
        [self getSelctedContacts];
    
        [self reloadData];
        
    }
    
}

- (void)getSelctedContacts

{
    
    NSMutableDictionary *emails = [self.dictionary objectForKey:(self.shareType == Email)?kReferEmail:kReferMessage];
    
    NSMutableArray *phoneEmails = [emails objectForKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
    NSArray *referEmails = [emails objectForKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
    
        NSMutableArray *newPhoneEmails = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [phoneEmails count]; i++) {
            
            BOOL isRefer = NO;
            
            NSString *emailId = [NSString stringWithFormat:@"%@",(self.shareType == Email)?[[phoneEmails objectAtIndex:i] valueForKey:@"email"]:[[[phoneEmails objectAtIndex:i] valueForKey:@"phonenumber"] objectAtIndex:0]];
            
            for (int j = 0; j < [referEmails count]; j++) {
                
                NSString *referId = [NSString stringWithFormat:@"%@",(self.shareType == Email)?[[referEmails objectAtIndex:j] valueForKey:@"email"]:[[[referEmails objectAtIndex:j] valueForKey:@"phonenumber"] objectAtIndex:0]];
                
                if ([referId  isEqualToString:emailId])
                {
                    
                    isRefer = YES;
                    
                }
                
                
            }
            
            if (!isRefer)
                [newPhoneEmails addObject:[phoneEmails objectAtIndex:i]];
        
        
        
        NSMutableArray *uniquenewPhoneEmails = [NSMutableArray array];
        
        [uniquenewPhoneEmails addObjectsFromArray:[[NSSet setWithArray:newPhoneEmails] allObjects]];
        
        [uniquenewPhoneEmails setArray:[self sortArrayWithArray:uniquenewPhoneEmails]];
        
        NSMutableArray *uniquereferEmails = [NSMutableArray array];
        
        [uniquereferEmails addObjectsFromArray:[[NSSet setWithArray:referEmails] allObjects]];
        
        [uniquereferEmails setArray:[self sortArrayWithArray:uniquereferEmails]];
        
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:uniquenewPhoneEmails forKey:(self.shareType == Email)?kReferPhoneContactEmail:kReferPhoneContactNumber];
            [dictionary setValue:uniquereferEmails forKey:(self.shareType == Email)?kReferNewlyAddedEmail:kReferNewlyAddedNumber];
        
            [self.dictionary setValue:dictionary forKey:(self.shareType == Email)?kReferEmail:kReferMessage];
        
        
    }
    
    
    
    
    
}





@end
