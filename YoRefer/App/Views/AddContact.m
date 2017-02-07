//
//  AddContact.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/2/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "AddContact.h"
#import "Configuration.h"
#include "Helper.h"
#import "Utility.h"
#import "CoreData.h"
#import "UserManager.h"


typedef enum {
    
    Name = 10000,
    PhoneEmail
    
}ContactType;

@interface AddContact ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *referContact,*newlyAdded,*referdContacts;
@property (nonatomic, strong) NSString *nameTxt,*phoneEmailTxt;
@property (nonatomic, readwrite) BOOL isMessage,isCancel;
@property (nonatomic, strong) NSMutableDictionary *indexPaths;


@end

@implementation AddContact

- (instancetype)initWithViewFrame:(CGRect)frame type:(NSString *)type delegate:(id<Contact>)delegate referContact:(NSMutableArray *)referContact

{
    
    self = [super init];
    
    if (self)
        
    {
        self.delegate = delegate;
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
        [self setBackgroundColor:[UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f]];
        
        if ([type isEqualToString: @"Message"])
        {
            self.isMessage = YES;
            
        }else
        {
            self.isMessage = NO;
        }
        
        self.referdContacts = referContact;
        
        [self createContactView];
        
        
        
    }
    
    return self;
    
}

- (void)createContactView
{
    //header view
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = 160.0;
    CGFloat width = self.frame.size.width;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [headerView setUserInteractionEnabled:YES];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:headerView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = headerView.frame.size.width;
    height = 30.0;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [label setText:@"Add New Contacts"];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor colorWithRed:(211.0/255.0) green:(91.0/255.0) blue:(61.0/255.0) alpha:1.0]];
    [headerView addSubview:label];
    
    yPos = 40.0;
    width = headerView.frame.size.width - 30.0;
    xPos = roundf((headerView.frame.size.width - width)/2);
    height = 35.0;
    
    UITextField *name = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) contactType:Name];
    [headerView addSubview:name];
    
    yPos = name.frame.origin.y + name.frame.size.height + 6.0;
    UITextField *phone = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) contactType:PhoneEmail];
    [headerView addSubview:phone];
    
    //Add button
    
    xPos = phone.frame.origin.x;
    yPos = phone.frame.origin.y + phone.frame.size.height + 6.0;
    width = phone.frame.size.width;
    height = 35.0;
    UIButton *addBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) title:@"Add"];
    [addBtn.layer setCornerRadius:17.0];
    [addBtn.layer setMasksToBounds:YES];
    [addBtn.layer setBorderWidth:2.0];
    [addBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [addBtn addTarget:self action:@selector(addBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addBtn];
    
    //   //Clear button
    //    xPos = addBtn.frame.size.width + 20.0;
    //    UIButton *clearBtn = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) title:@"Clear"];
    //     [clearBtn addTarget:self action:@selector(clearBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [headerView addSubview:clearBtn];
    
    //MiddView
    xPos = 0.0;
    yPos = headerView.frame.origin.y + headerView.frame.size.height;
    width = self.frame.size.width;
    height = self.frame.size.height - headerView.frame.size.height;
    UIView *midView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [midView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:midView];
    [midView setUserInteractionEnabled:YES];
    
    xPos = 0.0;
    yPos = 4.0;
    width = midView.frame.size.width;
    height = midView.frame.size.height - 48.0;
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    tableView.tag = 40000;
    // tableView.scrollEnabled = YES;
    //tableView.showsVerticalScrollIndicator = YES;
    [tableView setUserInteractionEnabled:YES];
    // [tableView setShowsVerticalScrollIndicator:NO];
    //tableView.translatesAutoresizingMaskIntoConstraints = NO;
    //tableView.rowHeight = UITableViewAutomaticDimension;
    [midView addSubview:tableView];
    
    tableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    
    xPos = 2.0;
    yPos = tableView.frame.origin.y + tableView.frame.size.height + 2.0;
    width = midView.frame.size.width - 4.0;
    height = 40.0;
    UIButton *addButton = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) title:@"Proceed"];
    [addButton.layer setCornerRadius:20.0];
    [addButton.layer setMasksToBounds:YES];
    [addButton.layer setBorderWidth:2.0];
    [addButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [addButton addTarget:self action:@selector(doneBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [midView addSubview:addButton];
    
    [self getContact];
    
}

- (void)getContact
{
    
    if (!self.referContact)
        self.referContact = [[NSMutableArray alloc]init];
    
    if (self.isMessage)
    {
        NSMutableArray *message = [NSMutableArray arrayWithArray:[[CoreData shareData] getContactAskWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] number]] type:@"message"]];
        [self.referContact setArray:[self sortArrayWithArray:message]];
        
    }else
    {
        
        NSMutableArray *email = [NSMutableArray arrayWithArray:[[CoreData shareData] getContactAskWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager] number]] type:@"email"]];
        [self.referContact setArray:[self sortArrayWithArray:email]];
        
    }
    
    if (!self.indexPaths)
        self.indexPaths = [[NSMutableDictionary alloc]init];
    
    
    for (int i = 0; i < [self.referContact count]; i++) {
        
        
        for (int j = 0; j < [self.referdContacts count]; j++) {
            
            if ([[[self.referContact objectAtIndex:i] objectForKey:@"firstname"]  isEqualToString:[[self.referdContacts objectAtIndex:j] objectForKey:@"firstname"]] && (self.isMessage)?[[[[self.referContact objectAtIndex:i] objectForKey:@"phonenumber"] objectAtIndex:0] isEqualToString:[[[self.referdContacts objectAtIndex:j] objectForKey:@"phonenumber"] objectAtIndex:0]]:[[[self.referContact objectAtIndex:i] objectForKey:@"email"] isEqualToString:[[self.referdContacts objectAtIndex:j] objectForKey:@"email"]])
            {
                
                [self.indexPaths setValue:[NSIndexPath indexPathForRow:i inSection:0] forKey:[NSString stringWithFormat:@"%ld",(long)i]];
                
            }
            
        }
        
    }
    
    
    self.newlyAdded = [[NSMutableArray alloc]init];
    
    for (int i =0; i < [self.referdContacts count]; i++) {
        
        [self.newlyAdded addObject:[self.referdContacts objectAtIndex:i]];
        
        
    }
    
    [self reloadData];
    
}

- (NSArray *)sortArrayWithArray:(NSMutableArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstname" ascending:YES];
    
    return [array sortedArrayUsingDescriptors:@[sort]];
    
}

- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title
{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    [btn setTitle:NSLocalizedString(title, @"") forState:UIControlStateNormal];
    [btn.titleLabel setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:18.0]];
    [btn setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [btn.layer setCornerRadius:5.0];
    [btn.layer setMasksToBounds:YES];
    // [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return  btn;
    
}

- (UITextField *)createTextFiledWithFrame :(CGRect)frame contactType:(ContactType)contactType
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setTag:contactType];
    [textField setDelegate:self];
    [textField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    //[textField setValue:[UIColor grayColor] forKey:@"_placeholderLabel.textColor"];
    [textField setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [textField.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:8.0];
    [textField.layer setMasksToBounds:YES];
    [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setTextAlignment:NSTextAlignmentLeft];
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: [self setPlaceHolderWithcontactType:contactType]attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    } else {
        
        
    }
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 4.0, textField.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftView;
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [textField setKeyboardType:[self setKeyBoardTypeWithReferNowType:contactType]];
    [textField setPlaceholder:[self setPlaceHolderWithcontactType:contactType]];
    [self setTextWithContactType:contactType textFiled:textField];
    
    textField.returnKeyType  = UIReturnKeyDone;
    
    return textField;
    
    
}

- (void)setToolBarWithFiledType:(ContactType)filedType textFiled:(UITextField *)textField
{
    
    UIToolbar* numberToolbar;
    if (self.isMessage && textField.tag == PhoneEmail)
    {
         numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleDefault;
        
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTapped:)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)],
                               nil];
        [numberToolbar sizeToFit];
       

        
        
    }else
    {
       
         numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleDefault;
        
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTapped:)],
                               nil];
        [numberToolbar sizeToFit];
        
    }
   
    
     textField.inputAccessoryView = numberToolbar;
    
    
}


- (UIKeyboardType)setKeyBoardTypeWithReferNowType:(ContactType)contactType
{
    UIKeyboardType keyboardType;
    switch (contactType) {
        case PhoneEmail:
            keyboardType = (self.isMessage)?UIKeyboardTypeNumbersAndPunctuation:UIKeyboardTypeEmailAddress;
            break;
            
        default:
            keyboardType = UIKeyboardTypeDefault;
            break;
    }
    
    return keyboardType;
}

- (void)setTextWithContactType:(ContactType)contactType textFiled:(UITextField *)textFiled
{
    
    
    switch (contactType) {
            
        case Name:
            
            if (self.isCancel){
                
                self.isCancel = NO;
                textFiled.text = self.nameTxt;
                
            }else{
                
                self.nameTxt = textFiled.text;
            }
            
            
            break;
            
        case PhoneEmail:
            
            if (self.isCancel){
                
                self.isCancel = NO;
                textFiled.text = @"";
                textFiled.text = self.phoneEmailTxt;
                
                
            }else{
                
                self.phoneEmailTxt = textFiled.text;
                
            }


            break;
            
    }
}


- (NSString *)setPlaceHolderWithcontactType:(ContactType)contactType
{
    NSString *string = nil;
    
    switch (contactType) {
        case Name:
            string = @"Enter Name";
            break;
        case PhoneEmail:
            string = (self.isMessage)?@"Enter Phone number":@"Enter email";
            break;
            
            
        default:
            break;
    }
    
    return NSLocalizedString(string, @"");
    
}

#pragma mark - TabelView data source and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.referContact count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *idnetifier = @"Indentifier";
    
    UITableViewCell *cell;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idnetifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 10.0;
    CGFloat yPos = 13.0;
    CGFloat width = 24.0;
    CGFloat height = 24.0;
    UILabel *lableCircle = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    lableCircle.layer.cornerRadius = 12.0;
    lableCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    lableCircle.layer.borderWidth = 1.0;
    lableCircle.layer.masksToBounds = YES;
    [cell.contentView addSubview:lableCircle];
    
    xPos = 0.0;
    yPos = 0.0;
    
    UIImageView *tick = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    if ([[self.indexPaths objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] isKindOfClass:[NSIndexPath class]])
    {
        tick.image = [UIImage imageNamed:@"icon_tick.png"];
        
    }else
    {
        tick.image = [UIImage imageNamed:@""];
        
    }
    
    [lableCircle addSubview:tick];
    
    xPos = 50.0;
    yPos = 5.0;
    width = frame.size.width - 60.0;
    height = 25.0;
    UILabel *name = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:[[self.referContact objectAtIndex:indexPath.row] objectForKey:@"firstname"] textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [name setBackgroundColor:[UIColor clearColor]];
    name.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:name];
    
    xPos = 50.0;
    yPos = 20.0;
    width = frame.size.width - 60.0;
    height = 25.0;
    UILabel *details = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    details.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:details];
    
    if (self.isMessage)
    {
        details.text = [[[self.referContact objectAtIndex:indexPath.row] objectForKey:@"phonenumber"] objectAtIndex:0];
        
        
        
    }else
    {
        
        details.text = [[self.referContact objectAtIndex:indexPath.row] objectForKey:@"email"];
        
        
    }
    
    [details setTextColor:[UIColor lightGrayColor]];
    
    
    xPos = frame.size.width - 60.0;
    yPos = 13.0;
    width = 20.0;
    height = 20.0;
    UILabel *circle = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"" textColor:[UIColor blackColor] font:[[Configuration shareConfiguration] yoReferFontWithSize:18.0]];
    circle.backgroundColor = [UIColor lightGrayColor];
    circle.layer.cornerRadius = 10.0;
    circle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    circle.layer.borderWidth = 1.0;
    circle.layer.masksToBounds = YES;
    [cell.contentView addSubview:circle];
    
    xPos = circle.frame.origin.x + 3.0;
    yPos = 16.0;
    width = 14.0;
    height = 14.0;
    UIImageView *delete = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    delete.image = [UIImage imageNamed:@"icon_account_delete.png"];
    delete.image = [[UIImage imageNamed:@"icon_account_delete.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [delete setTintColor:[UIColor whiteColor]];
    [cell.contentView addSubview:delete];
    
    xPos = circle.frame.origin.x - 5.0;
    yPos = 8.0;
    width = 30.0;
    height = 30.0;
    UIButton *deleteName = [self createButtonWithFrame:CGRectMake(xPos, yPos, width, height) title:@""];
    deleteName.backgroundColor = [UIColor clearColor];
    [deleteName addTarget:self action:@selector(deleteTapped:) forControlEvents:UIControlEventTouchUpInside];
    deleteName.tag = indexPath.row;
    [cell.contentView addSubview:deleteName];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!self.indexPaths)
        self.indexPaths = [[NSMutableDictionary alloc]init];
    
     NSDictionary *dictionary = [self.referContact objectAtIndex:indexPath.row];
    
    if ([[self.indexPaths objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] isKindOfClass:[NSIndexPath class]])
    {
        
        
        [self.indexPaths removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
        //Remove newly added index
        
       
        
        for (int i = 0; i < [self.newlyAdded count]; i++) {
            
            if ([[dictionary objectForKey:@"firstname"]  isEqualToString:[[self.newlyAdded objectAtIndex:i] objectForKey:@"firstname"]] &&  [(self.isMessage)?[[dictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]:[dictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"] isEqualToString:([[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"] isKindOfClass:[NSArray class]])?[[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]:[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"]])
            {
                
                [self.newlyAdded removeObjectAtIndex:i];
                
            }

            
        }
        
        
    }else
        
    {
        
        [self.newlyAdded addObject:dictionary];
        
        [self.indexPaths setValue:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
    }
    

    
    
    NSArray *indexPaths = [[NSArray alloc]initWithObjects:indexPath, nil];
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    
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



#pragma mark - TextFiled delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    [self setToolBarWithFiledType:(ContactType)textField.tag textFiled:textField];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self setTextWithContactType:(ContactType)textField.tag textFiled:textField];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Button delegate

- (IBAction)doneButtonTapped:(id)sender
{
    [self endEditing:YES];
    
    
    
}

- (IBAction)cancelButtonTapped:(id)sender
{
     self.isCancel = YES;
    [self endEditing:YES];
    
   
    
    
}


- (void)reloadData
{
    [(UITableView *)[self viewWithTag:40000] setDataSource:self];
    [(UITableView *)[self viewWithTag:40000] setDelegate:self];
    [(UITableView *)[self viewWithTag:40000] reloadData];
    
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


- (IBAction)addBtnTapped:(id)sender
{
    [self endEditing:YES];
    
    NSArray *error = nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [dictionary setValue:self.nameTxt forKey:@"firstname"];
    
    if (self.isMessage){
    
        if (self.phoneEmailTxt.length > 10) {
            [dictionary setValue:self.phoneEmailTxt forKey:@"emailphonenumber"];

        }
        else{
            
            NSLocale *locale = [NSLocale currentLocale];
            NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
            NSDictionary *dict = [self dictCountryCodes];
            NSString *localNumberCode = dict[countryCode];
            NSString *numberWithContry = [NSString stringWithFormat:@"+%@",localNumberCode];
            
            [dictionary setValue:[NSString stringWithFormat:@"%@%@",numberWithContry,self.phoneEmailTxt] forKey:@"emailphonenumber"];
        }

    }
    else{
        [dictionary setValue:self.phoneEmailTxt forKey:@"emailphonenumber"];
    }
    
    if (self.isMessage){
        
        if (self.phoneEmailTxt.length > 10) {
            [dictionary setValue:self.phoneEmailTxt forKey:@"referphonnumber"];
        }
        else{
            
            NSLocale *locale = [NSLocale currentLocale];
            NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
            NSDictionary *dict = [self dictCountryCodes];
            NSString *localNumberCode = dict[countryCode];
            NSString *numberWithContry = [NSString stringWithFormat:@"+%@",localNumberCode];
            
            [dictionary setValue:[NSString stringWithFormat:@"%@%@",numberWithContry,self.phoneEmailTxt] forKey:@"referphonnumber"];
        }
        
        
    }
    
    BOOL isvlidate = [[Helper shareHelper] validateAddContactAllEnteriesWithError:&error    contacts:dictionary isMessage:self.isMessage];
    if (!isvlidate)
    {
        NSString *errorMessage = [[Helper shareHelper] getErrorStringFromErrorDescription:error];
        alertView([[Configuration shareConfiguration] appName], errorMessage, nil, @"Ok", nil, 0);
        return;
        
    }
    
    if (!self.isMessage)
    {
        BOOL isValidEmail = [[Helper shareHelper] emailValidationWithEmail:self.phoneEmailTxt];
        if (!isValidEmail)
        {
            
            alertView([[Configuration shareConfiguration] appName], @"Please enter valid email", 0, @"Ok", nil, 0);
            return;
            
        }
        
        
    }
    
    
    if (!self.referContact)
        self.referContact = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *contact = [NSMutableDictionary dictionaryWithCapacity:2];
    if (self.nameTxt != nil && [self.nameTxt length] > 0)
        [contact setValue:self.nameTxt forKey:@"firstname"];
    
    if (self.isMessage)
    {
        /*
        if (self.phoneEmailTxt != nil && [self.phoneEmailTxt length] > 0){
            NSArray *arrayContact = [[NSArray alloc]initWithObjects:self.phoneEmailTxt, nil];
            [contact setValue:self.phoneEmailTxt forKey:@"referphonnumber"];
            [contact setValue:arrayContact forKey:@"phonenumber"];
        }
        */
        
        if (self.phoneEmailTxt != nil)
        {
            if (self.phoneEmailTxt.length > 10) {
                //[dictionary setValue:self.phoneEmailTxt forKey:@"referphonnumber"];
                
                NSArray *arrayContact = [[NSArray alloc]initWithObjects:self.phoneEmailTxt, nil];
                [contact setValue:self.phoneEmailTxt forKey:@"referphonnumber"];
                [contact setValue:arrayContact forKey:@"phonenumber"];
                
            }
            else{
                
                NSLocale *locale = [NSLocale currentLocale];
                NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
                NSDictionary *dict = [self dictCountryCodes];
                NSString *localNumberCode = dict[countryCode];
                NSString *numberWithContry = [NSString stringWithFormat:@"+%@",localNumberCode];
                
                // [dictionary setValue:[NSString stringWithFormat:@"%@%@",numberWithContry,self.phoneEmailTxt] forKey:@"referphonnumber"];
                
                NSArray *arrayContact = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@%@",numberWithContry,self.phoneEmailTxt], nil];
                [contact setValue:[NSString stringWithFormat:@"%@%@",numberWithContry,self.phoneEmailTxt] forKey:@"referphonnumber"];
                [contact setValue:arrayContact forKey:@"phonenumber"];
            }
        }
        
    }else
    {
        if (self.phoneEmailTxt != nil && [self.phoneEmailTxt length] > 0){
            
            [contact setValue:self.phoneEmailTxt forKey:@"email"];
            
        }
    }
    
    
    
    if ([contact count] > 0)
        [self.referContact addObject:contact];
    
    [self.referContact setArray:[self sortArrayWithArray:self.referContact]];
    
    
    [(UITextField *)[self viewWithTag:Name] setText:@""];
    [(UITextField *)[self viewWithTag:PhoneEmail] setText:@""];
    self.nameTxt = @"";
    self.phoneEmailTxt = @"";
    
    //Newly added Contacts
    if (!self.newlyAdded)
            self.newlyAdded = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *newlyAddedDic = [[NSMutableDictionary alloc]init];
    [newlyAddedDic setValue:[dictionary objectForKey:@"firstname"] forKey:@"firstname"];
    [newlyAddedDic setValue:[dictionary objectForKey:@"emailphonenumber"] forKey:(self.isMessage)?@"phonenumber":@"email"];
    [self.newlyAdded addObject:newlyAddedDic];
    
    
    self.indexPaths = [[NSMutableDictionary alloc]init];
    
    
    
    for (int i = 0; i < [self.referContact count]; i++) {
        
        NSDictionary *referdictionary = [self.referContact objectAtIndex:i];
        
        //[[referdictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]
        
        for (int j = 0; j < [self.newlyAdded count]; j++) {
            
            if ([[referdictionary objectForKey:@"firstname"]  isEqualToString:[[self.newlyAdded objectAtIndex:j] objectForKey:@"firstname"]] && [(self.isMessage)?[[referdictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]:[referdictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"] isEqualToString:([[[self.newlyAdded objectAtIndex:j] objectForKey:(self.isMessage)?@"phonenumber":@"email"] isKindOfClass:[NSArray class]])?[[[self.newlyAdded objectAtIndex:j] objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]:[[self.newlyAdded objectAtIndex:j] objectForKey:(self.isMessage)?@"phonenumber":@"email"]])
            {
                
                 [self.indexPaths setValue:[NSIndexPath indexPathForRow:i inSection:0] forKey:[NSString stringWithFormat:@"%ld",(long)i]];
                
            }
            
        }
        
    }

    
    NSArray *keys = [self.indexPaths allKeys];
    
    NSMutableArray *contacts = [[NSMutableArray alloc]init];
    
    for (int i=0; i < [keys count]; i++) {
        
        [contacts addObject:[self.referContact objectAtIndex:[[keys objectAtIndex:i] integerValue]]];
        
    }
    
    
    
    if (self.isMessage)
    {
        
        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:self.referContact type:@"message"];
        
        
    }else
    {
        
        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:self.referContact type:@"email"];
        
    }
    
    [self reloadData];
    
}

- (IBAction)clearBtnTapped:(id)sender
{
    
    [(UITextField *)[self viewWithTag:Name] setText:@""];
    [(UITextField *)[self viewWithTag:PhoneEmail] setText:@""];
    self.nameTxt = @"";
    self.phoneEmailTxt = @"";
    
    
}

- (IBAction)deleteTapped:(id)sender
{

    
    NSMutableArray *contacts = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *deleteDictionary = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < [self.referContact count]; i++) {
        
        
        if ([sender tag] == i)
        {
            deleteDictionary = [self.referContact objectAtIndex:i];
            
        }else
        {
            
            [contacts addObject:[self.referContact objectAtIndex:i]];
            
            
        }
        
    }
    
    //[[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]
    
    //removing refer contacts
    for (int i = 0; i < [self.newlyAdded count]; i++) {
        
        if ([[deleteDictionary objectForKey:@"firstname"]  isEqualToString:[[self.newlyAdded objectAtIndex:i] objectForKey:@"firstname"]] && [(self.isMessage)?[[deleteDictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]:[deleteDictionary objectForKey:(self.isMessage)?@"phonenumber":@"email"]  isEqualToString:([[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"] isKindOfClass:[NSArray class]])?[[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"] objectAtIndex:0]:[[self.newlyAdded objectAtIndex:i] objectForKey:(self.isMessage)?@"phonenumber":@"email"]])
        {
            
            [self.newlyAdded removeObjectAtIndex:i];
            
        }
        
        
    }

    
    
    
    if (self.isMessage)
    {
        
        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:contacts type:@"message"];
        
        
    }else
    {
        
        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:contacts type:@"email"];
        
    } 
    
    self.referContact = [[NSMutableArray alloc]init];

    self.referContact = contacts;
    
    
    self.indexPaths = [[NSMutableDictionary alloc]init];
    
    for (int i =0; i < [self.newlyAdded count]; i++) {
        
         [self.indexPaths setValue:[NSIndexPath indexPathForRow:i inSection:0] forKey:[NSString stringWithFormat:@"%ld",(long)i]];
        
    }
    
    [self reloadData];
    
    
}

- (IBAction)deleteBtnTapped:(id)sender
{
    
    if([self.indexPaths count] <=0)
    {
        
        alertView([[Configuration shareConfiguration] appName], @" - Select contacts to be delete", nil, @"Ok", nil, 0);
        return;
        
    }
    
    
    NSMutableArray *contacts = [[NSMutableArray alloc]init];
    
    
    
    for (int i = 0; i < [self.referContact count]; i++) {
        
        
        if ([[self.indexPaths objectForKey:[NSString stringWithFormat:@"%d",i]] isKindOfClass:[NSIndexPath class]])
        {
            
        }else
        {
            
            [contacts addObject:[self.referContact objectAtIndex:i]];
            
        }
        
    }
    
    
    if (self.isMessage)
    {
        
        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:contacts type:@"message"];
        
        
    }else
    {
        
        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:contacts type:@"email"];
        
    }
    
    
    self.referContact = [[NSMutableArray alloc]init];
    self.indexPaths = [[NSMutableDictionary alloc]init];
    self.referContact = contacts;
    [self reloadData];
    
    
}

- (IBAction)doneBtnTapped:(id)sender
{
    
    if([self.indexPaths count] <=0)
    {
        
//        alertView([[Configuration shareConfiguration] appName], @" - Select contacts to be refer", nil, @"Ok", nil, 0);
        
        NSMutableArray *contacts = [[NSMutableArray alloc]init];
        
        if ([self.delegate respondsToSelector:@selector(getCustomeContact:)])
            
        {
            [self.delegate getCustomeContact:[NSArray arrayWithArray:contacts]];
            
        }
        
        return;
        
    }
    
    NSArray *keys = [self.indexPaths allKeys];
    
    NSMutableArray *contacts = [[NSMutableArray alloc]init];
    
    for (int i=0; i < [keys count]; i++) {
        
        [contacts addObject:[self.referContact objectAtIndex:[[keys objectAtIndex:i] integerValue]]];
        
    }
    
    
    
//    if (self.isMessage)
//    {
//        
//        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:contacts type:@"message"];
//        
//        
//    }else
//    {
//        
//        [[CoreData shareData] setContactWithLoginId:[NSString stringWithFormat:@"%@",[[UserManager shareUserManager]number]] response:contacts type:@"email"];
//        
//    }
    
    
    if ([self.delegate respondsToSelector:@selector(getCustomeContact:)])
    {
        [self.delegate getCustomeContact:[NSArray arrayWithArray:contacts]];
        
    }
    
    
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
