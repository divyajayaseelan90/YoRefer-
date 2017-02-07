//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import "Configuration.h"


@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imageList;
@property (nonatomic, readwrite) BOOL location , isCategory,isContactList;
@property (nonatomic, strong) NSMutableDictionary *category;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize imageList;
@synthesize delegate;
@synthesize animationDirection;

- (id)showDropDown:(UIButton *)b:(CGFloat)height:(NSArray *)arr:(NSArray *)imgArr:(NSString *)direction type:(BOOL)isLocation {
    btnSender = b;
    animationDirection = direction;
    self.category = [[NSMutableDictionary alloc]init];
    self.location = isLocation;
    self.table = (UITableView *)[super init];
    if (self) {
        // Initialization code
        CGRect btn = b.frame;
        
        self.list = [NSArray arrayWithArray:arr];
        if (!isLocation)
        {
            if ([[list objectAtIndex:0] isKindOfClass:[NSDictionary class]])
            {
                self.isCategory = NO;
                self.isContactList = YES;
                [self getContactListWithSortOrder];
                
            }else
            {
                [self sortArray];
                self.isCategory = YES;
                self.isContactList = NO;
            }
        }else
        {
            self.isCategory = NO;
            self.isContactList = NO;
        }
        
        self.imageList = [NSArray arrayWithArray:imgArr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width , 0.0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width + 20.0 , 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 6.0, btn.size.width, 0.0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        //table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        table.backgroundColor = [UIColor clearColor];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        table.tableFooterView = [UIView new];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y-height, btn.size.width, height);
        } else if([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width + 18.0, height);
        }
        table.frame = CGRectMake(10.0, 6.0, btn.size.width, height);
        [UIView commitAnimations];
        [b.superview addSubview:self];
        [self addSubview:table];
    }
    return self;
}


- (void)getContactListWithSortOrder
{
    
    NSArray *indexTitle = [self getIndexTitle];
    NSArray *listvalue = self.list;
    
    //TODO: Change
    for (int i =0; i < [indexTitle count]; i++) {
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        for (int j =0; j < [listvalue count]; j++) {
            
            NSDictionary *dictionary = [listvalue objectAtIndex:j];
            
            if ([dictionary objectForKey:@"Firstname"] != nil && [[dictionary objectForKey:@"Firstname"] length] > 0)
            {
                
                if([[[dictionary objectForKey:@"Firstname"] substringToIndex:1]isEqualToString:[indexTitle objectAtIndex:i]])
                    [array addObject:[listvalue objectAtIndex:j]];

                
            }
            
        }
        if([array count] > 0)
            [self.category setValue:array forKey:[indexTitle objectAtIndex:i]];
    }
    
    
}

- (void)sortArray
{
    NSArray *indexTitle = [self getIndexTitle];
    NSArray *listvalue = self.list;
    
    //TODO: Change
    for (int i =0; i < [indexTitle count]; i++) {
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        for (int j =0; j < [listvalue count]; j++) {
            
            
            CategoryType *category = (CategoryType *)[listvalue objectAtIndex:j];
            
            if([[category.categoryName substringToIndex:1]isEqualToString:[indexTitle objectAtIndex:i]])
                [array addObject:[listvalue objectAtIndex:j]];
            
        }
        if([array count] > 0)
            [self.category setValue:array forKey:[indexTitle objectAtIndex:i]];
    }
    
}

- (NSArray *)getIndexTitle
{
    
    static NSArray *indexTitle = nil;
    
    if(indexTitle==nil){
        
        indexTitle = [[NSArray alloc]initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
        
    }
    
    return indexTitle;
    
}


-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0.0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0.0);
    }
    table.frame = CGRectMake(10.0, 6.0, btn.size.width, 0.0);
    [UIView commitAnimations];
}

#pragma mark - Table view datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.isCategory){
        return  [[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] count];
    }
    else{
        
        if (self.isContactList)
        {
            
            return  [[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] count];
            
        }else
        {
            return 1;
        }
        
    }
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isCategory){
        return [[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    }
    else{
        
        if (self.isContactList)
        {
            return [[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
            
        }else
        {
            return @"";
        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor whiteColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSection"]]];
    
}



- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.isCategory){
        return [[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    else{
        
        if (self.isContactList)
        {
            
            return [[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            
        }else
        {
            return nil;
        }
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    if (self.isCategory){
        return [[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] indexOfObject:title];
    }
    else{
        if (self.isContactList)
        {
            
            return [[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] indexOfObject:title];
            
        }else
        {
            return 0.0;
        }
        
        
    }
    
    
}





-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isCategory){
        
        return [[self.category objectForKey:[[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
    }
    
    else{
        
        if (self.isContactList)
        {
            
            return [[self.category objectForKey:[[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
            
        }else
        {
            return (self.location && [[list objectAtIndex:0] valueForKey:@"description"])?([self.list count] + 1):[self.list count];
        }
        
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if ([self.imageList count] < [self.list count]) {
        
        if (self.location)
        {
            
            if ([[[list objectAtIndex:(indexPath.row == 0)?0:(indexPath.row - 1)] valueForKey:@"description"] length] > 0)
            {
                if (indexPath.row == 0)
                {
                   cell.textLabel.text = @"Current Location";
                }
                else
                {
                    cell.textLabel.text = [[list objectAtIndex:(indexPath.row == 0)?0:(indexPath.row - 1)] valueForKey:@"description"];
                }
                
                
            }else
            {
                cell.textLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:@"name"];
                cell.detailTextLabel.text=[[[[list objectAtIndex:indexPath.row] valueForKey:@"location"] valueForKey:@"formattedAddress"] componentsJoinedByString:@","];
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                
            }
            
            
            
        }else
        {
            
            if ([[list objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
            {
                
                if (self.isContactList)
                {
                    NSDictionary *dic = [[self.category objectForKey:[[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                    
                    NSString *name = [NSString stringWithFormat:@"%@ %@",([[dic objectForKey:@"Firstname"] length]>0)?[dic objectForKey:@"Firstname"]:@"",([[dic objectForKey:@"Lastname"] length]>0)?[dic objectForKey:@"Lastname"]:@""];
                    cell.textLabel.text = name;
                    
                }
                
            }else
            {
                
                CategoryType *categoryType = (CategoryType *) [[self.category objectForKey:[[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                cell.textLabel.text =categoryType.categoryName;
                
                
            }
            
            
        }
        
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    }
    
    cell.textLabel.textColor = (self.location && indexPath.row == 0 && [[list objectAtIndex:0] valueForKey:@"description"])?[UIColor blueColor]:[UIColor blackColor];

    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = v;
    
    return cell;
}


-(NSInteger)returnContactListIndexWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSArray *array = self.list;
    
    for ( int i=0; i < [array count]; i++) {
        
        NSDictionary *contactList = [array objectAtIndex:i];
        
        NSDictionary *selectedContact = [[self.category objectForKey:[[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSString *contactName , *selContatName;
        if ([[contactList valueForKey:@"Firstname"] length] > 0)
        {
            contactName = [NSString stringWithFormat:@"%@ %@",[contactList valueForKey:@"Firstname"],[contactList valueForKey:@"Lastname"]];
        }else if ([[contactList valueForKey:@"Phonenumbers"] count] > 0)
        {
            contactName = [[contactList valueForKey:@"Phonenumbers"] objectAtIndex:0];
        }
        
        if ([[selectedContact valueForKey:@"Firstname"] length] > 0)
        {
            selContatName = [NSString stringWithFormat:@"%@ %@",[selectedContact valueForKey:@"Firstname"],[selectedContact valueForKey:@"Lastname"]];
        }else if ([[selectedContact valueForKey:@"Phonenumbers"] count] > 0)
        {
            selContatName = [[selectedContact valueForKey:@"Phonenumbers"] objectAtIndex:0];
        }

        
        if ([contactName isEqualToString:selContatName])
        {
            
            return i;
            
        }
        
    }
    
    return 0;
    
}


-(NSInteger)returnIndexWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSArray *array = self.list;
    
    for ( int i=0; i < [array count]; i++) {
        
        CategoryType *category = [array objectAtIndex:i];
        
        CategoryType *categoryList = [[self.category objectForKey:[[[self.category allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        if ([category.categoryName isEqualToString:categoryList.categoryName])
        {
            
            return i;
            
        }
        
    }
    
    return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:btnSender];
    
    //    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    //    [btnSender setTitle:c.textLabel.text forState:UIControlStateNormal];
    
    for (UIView *subview in btnSender.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    if (self.location)
    {
        if ([[[list objectAtIndex:(indexPath.row == 0)?0:(indexPath.row - 1)] objectForKey:@"description"] length] > 0)
        {
            if (indexPath.row == 0)
                [self.delegate updateLocation];
            else
                [self.delegate getLoaction:[list objectAtIndex:(indexPath.row == 0)?0:(indexPath.row - 1)]];
        }else
        {
            
            [self.delegate getPlacesWithDetail:[list objectAtIndex:indexPath.row]];
            
        }
        
    }else
        
    {
        
        if ([[list objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            
            [self.delegate getPersonContact:[list objectAtIndex:[self returnContactListIndexWithIndexPath:indexPath]]];
            
        }else
        {
            
            [self.delegate getCategory:(CategoryType *)[self.list objectAtIndex:[self returnIndexWithIndexPath:indexPath]]];
            
        }
        
        
    }
    
    
    
    //    imgView.image = c.imageView.image;
    //    imgView = [[UIImageView alloc] initWithImage:c.imageView.image];
    imgView.frame = CGRectMake(5, 5, 25, 25);
    [btnSender addSubview:imgView];
    [self myDelegate];
}

- (void) myDelegate {
    [self.delegate niDropDownDelegateMethod:self];
}

-(void)dealloc {
    //    [super dealloc];
    //    [table release];
    //    [self release];
}

@end
