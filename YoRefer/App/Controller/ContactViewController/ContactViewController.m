//
//  ContactViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ContactViewController.h"
#import "Configuration.h"
#import "UserManager.h"
#import "ReferNowViewController.h"
#import "Helper.h"
#import "Utility.h"


NSUInteger  const contactListSection        = 1;
CGFloat     const contactListRowHeight      = 50.0;
CGFloat     const contactListSectionHeight  = 120.0;


@interface ContactViewController ()<UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate >

@property (nonatomic, strong) NSArray              *contacts;
@property (nonatomic, strong) NSMutableDictionary         *contactsList;
@property (nonatomic, strong) UISearchBar                 *searchBar;

@property (nonatomic, strong) NSString                    *stringSearch;
@property (nonatomic, strong) NSArray              *arrayTableData;

@property (nonatomic, strong) NSMutableDictionary *dictToBeUsed;
@property (nonatomic, strong) NSArray              *contactsFiltered;

@property (nonatomic, strong) UIView *viewBg;


@end

@implementation ContactViewController


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
    self.navigationItem.title = NSLocalizedString(@"Contacts", @"");
    
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
        
        self.tableView.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
        //[self tableHeader];
        [self tableHeaderInitiate];
        self.tableView.tableFooterView = [UIView new];
        self.contacts = [[NSMutableArray alloc]init];
        self.contactsList = [[NSMutableDictionary alloc]init];
        
        self.contacts = [self getAllContacts];
        self.contactsList = [self getContactInSection];
        
        [self reloadTableView];

    }else
    {
        alertView([[Configuration shareConfiguration] appName],@"This app requires access to your device's Contacts.\n\nPlease enable Contacts access for this app in Settings / Yorefer / Contacts", self, @"Ok", nil, 100);
        return;
    }

    // Do any additional setup after loading the view.
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
}


-(void)viewDidLayoutSubviews
{
    
    CGRect frame  = [self bounds];
    //self.searchBar.frame = CGRectMake(frame.origin.x, self.navigationController.navigationBar.frame.size.height+20, frame.size.width, 44);
    self.searchBar.frame = CGRectMake(frame.origin.x+15, self.navigationController.navigationBar.frame.size.height+28, frame.size.width-30, 45);
    self.tableView.frame = CGRectMake(frame.origin.x, self.searchBar.frame.origin.y+self.searchBar.frame.size.height-50, frame.size.width, frame.size.height-80.0);
    [self.view layoutIfNeeded];
    
    self.viewBg.frame = CGRectMake(frame.origin.x, self.navigationController.navigationBar.frame.size.height, frame.size.width, 75);

    
}


- (void)tableHeader
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = 10.0;
    
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *bannerImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    bannerImage.image = [UIImage imageNamed:@"icon_banner.png"];
    [view addSubview:bannerImage];
    
    [self.view addSubview:view];
    
}

-(void)tableHeaderInitiate
{
    _viewBg = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, 44)];
    [_viewBg setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    [self.view  addSubview:_viewBg];

    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"Search Contacts";
    [_searchBar setBarStyle:UIBarStyleDefault];
    [_searchBar setTintColor:[UIColor lightGrayColor]];
    [_searchBar setDelegate:self];
    [_searchBar setBarTintColor:[UIColor whiteColor]];
    [_searchBar setBackgroundColor:[UIColor whiteColor]];
    _searchBar.layer.cornerRadius = 8.0;
    _searchBar.layer.masksToBounds = YES;

    [self.view setBackgroundColor:[UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f]];
    /*
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchDisplayController.delegate = self;
    */
    
    [self.view addSubview:_searchBar]; // I think this should have loaded the searchBar but doesn't
    
}

        
- (NSMutableDictionary *)getContactInSection
{
    
    NSArray *indexTitle = [self getIndexTitle];
    NSArray *listvalue = self.contacts;
    
    __block NSInteger count = 0;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [indexTitle enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop){
        NSString *title = obj;
        NSMutableArray *lists = [[NSMutableArray alloc]init];
        [listvalue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([([[obj valueForKey:@"Firstname"] length] > 0)?[[obj valueForKey:@"Firstname"] substringToIndex:1]:@"" isEqualToString:title])
            {
                [lists addObject:obj];
                [tempArray addObject:obj];
            }
        }];
        if ([lists count] > 0)
        {
            count = count + [lists count];
            [self.contactsList setValue:lists forKey:title];
        }
        
    }];
    
    
    NSMutableArray *spinArray = [NSMutableArray arrayWithArray:listvalue];
    if (count != listvalue.count) {
        [spinArray removeObjectsInArray:tempArray];
        NSLog(@"spinner %@",spinArray);
        [self.contactsList setValue:spinArray forKey:@"#"];
    }
    return self.contactsList;
    
}

- (NSMutableDictionary *)getContactInSectionFiltered
{
    
    NSArray *indexTitle = [self getIndexTitle];
    NSArray *listvalue = self.contactsFiltered;
    
    __block NSInteger count = 0;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [indexTitle enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop){
        NSString *title = obj;
        NSMutableArray *lists = [[NSMutableArray alloc]init];
        [listvalue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([([[obj valueForKey:@"Firstname"] length] > 0)?[[obj valueForKey:@"Firstname"] substringToIndex:1]:@"" isEqualToString:title])
            {
                [lists addObject:obj];
                [tempArray addObject:obj];
            }
        }];
        if ([lists count] > 0)
        {
            count = count + [lists count];
            [self.contactsList setValue:lists forKey:title];
        }
        
    }];
    
    
    NSMutableArray *spinArray = [NSMutableArray arrayWithArray:listvalue];
    if (count != listvalue.count) {
        [spinArray removeObjectsInArray:tempArray];
        NSLog(@"spinner %@",spinArray);
        [self.contactsList setValue:spinArray forKey:@"#"];
    }
    return self.contactsList;
    
}


- (NSArray *)getIndexTitle
{
    
    static NSArray *indexTitle = nil;
    
    if(indexTitle==nil){
        
        indexTitle = [[NSArray alloc]initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",@"#", nil];
        
    }
    
    return indexTitle;
    
}


-(NSMutableArray *)getAllContacts
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
            
//            if ((firstName || lastName)) {
            
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
                        [phoneNumbers addObject:[NSString stringWithString:strippedNumber]];
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
                
                
                if ((firstName != nil && [firstName length] > 0) || (lastName != nil && [lastName length] > 0)) {
                        [contactList addObject:contact];
                }
            //}
            CFRelease(phones);
            CFRelease(ref);
        }
        CFRelease(allPeople);
    }
    
    else {
    }
    
    _dictToBeUsed = [[NSMutableDictionary alloc]init];
    _dictToBeUsed = [contactList mutableCopy];

    return contactList;
    
}

- (UIView *)createViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    return view;
    
}


#pragma mark - tableview datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
   return  [[[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSection"]]];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return contactListRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] indexOfObject:title];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.contactsList objectForKey:[[[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}


- (ContactListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ContactListTableViewCell *cell;
    
    if (cell == nil)
    {
        
        NSDictionary *dictionary = [[self.contactsList objectForKey:[[[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        cell = [[ContactListTableViewCell alloc]initWithIndexPath:indexPath delegate:self response:dictionary];
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
    }
    
    return cell;
    
}


#pragma mark - SearchBar Delegate Methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    if (searchText.length == 0) {

        self.contacts = [_dictToBeUsed mutableCopy];

        self.contactsList = [[NSMutableDictionary alloc]init];
        self.contactsList = [self getContactInSection];
        
        [self.tableView reloadData];

    }
    else
    {
        NSLog(@"%@", self.contacts);
        
        NSPredicate * myPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF['Firstname'] contains '%@' || SELF['Lastname'] contains '%@'",searchText,searchText]];

        self.contactsFiltered = [self.contacts filteredArrayUsingPredicate:myPredicate];
        
        self.contactsList = [[NSMutableDictionary alloc]init];
        self.contactsList = [self getContactInSectionFiltered];
        
        NSLog(@"%@", self.contactsList);
        
        [self.tableView reloadData];

    }

}



-(NSInteger)returnIndexWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSArray *array = self.contacts;
    
    for ( int i=0; i < [array count]; i++) {
        
        NSDictionary  *contactList = [array objectAtIndex:i];
        
        NSDictionary *dictionary = [[self.contactsList objectForKey:[[[self.contactsList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSString *contactName , *selContatName;
        if ([[contactList valueForKey:@"Firstname"] length] > 0)
        {
             contactName = [NSString stringWithFormat:@"%@ %@",[contactList valueForKey:@"Firstname"],[contactList valueForKey:@"Lastname"]];
        }else if ([[contactList valueForKey:@"Phonenumbers"] count] > 0)
        {
            contactName = [[contactList valueForKey:@"Phonenumbers"] objectAtIndex:0];
        }
        
        if ([[dictionary valueForKey:@"Firstname"] length] > 0)
        {
            selContatName = [NSString stringWithFormat:@"%@ %@",[dictionary valueForKey:@"Firstname"],[dictionary valueForKey:@"Lastname"]];
        }else if ([[dictionary valueForKey:@"Phonenumbers"] count] > 0)
        {
            selContatName = [[dictionary valueForKey:@"Phonenumbers"] objectAtIndex:0];
        }

        //[([[contactList valueForKey:@"Firstname"] length] > 0)?[contactList objectForKey:@"Firstname"]:([[contactList valueForKey:@"Phonenumbers"] count] > 0)?[[contactList valueForKey:@"Phonenumbers"] objectAtIndex:0]:@"" isEqualToString:([[dictionary objectForKey:@"Firstname"] length] <= 0 && [[dictionary valueForKey:@"Phonenumbers"] count] >  0)?[[dictionary valueForKey:@"Phonenumbers"] objectAtIndex:0]:([[dictionary objectForKey:@"Firstname"] length] > 0)?[dictionary objectForKey:@"Firstname"]:@""]
        
        if ([contactName isEqualToString:selContatName])
        {
            
            return i;
            
        }
        
    }
    
    return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:[self getReferNowDetailWithIndexPath:[self returnIndexWithIndexPath:indexPath]]delegate:nil
                                    ];
    [self.navigationController pushViewController:vctr animated:YES];
    
    
}

- (NSMutableDictionary *)getReferNowDetailWithIndexPath:(NSInteger)indexPathRow
{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    [dictionary setValue:[NSString stringWithFormat:@"%@%@",([[[self.contacts objectAtIndex:indexPathRow] objectForKey:@"Firstname"] length] > 0 ?[[self.contacts objectAtIndex:indexPathRow] objectForKey:@"Firstname"]:@""),([[[self.contacts objectAtIndex:indexPathRow] objectForKey:@"Lastname"] length] > 0 ?[[self.contacts objectAtIndex:indexPathRow] objectForKey:@"Lastname"]:@"" )] forKey:@"name"];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:kCity];
    [dictionary setValue:[[UserManager shareUserManager] currentCity] forKey:@"searchtext"];
    [dictionary setValue:@"" forKey:@"location"];
    [dictionary setValue:[[UserManager shareUserManager] latitude] forKey:@"latitude"];
    [dictionary setValue:[[UserManager shareUserManager] longitude] forKey:@"longitude"];
    NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSMutableArray *array;

    if ([categoryArray  count] > 0)
    {
        array = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [categoryArray valueForKey:kService])
        {
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
        }
    }
    CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
    [dictionary setValue:category.categoryName forKey:kCategory];
    [dictionary setValue:category.categoryID forKey:kCategoryid];
    [dictionary setValue:([[[self.contacts objectAtIndex:indexPathRow] objectForKey:@"Phonenumbers"] count] > 0)?[[[self.contacts objectAtIndex:indexPathRow] objectForKey:@"Phonenumbers"] objectAtIndex:0]:@"" forKey:@"phone"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isentiyd"];
    [dictionary setValue:@"service" forKey:@"categorytype"];
    [dictionary setValue:[[self.contacts objectAtIndex:indexPathRow]valueForKey:@"Email"] forKey:kWebSite];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"contactcategory"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"newrefer"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"refer"];
    
    return dictionary;
    
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
