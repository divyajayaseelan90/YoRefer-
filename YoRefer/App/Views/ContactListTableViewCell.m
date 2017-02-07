//
//  ContactListTableViewCell.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/21/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ContactListTableViewCell.h"
#import "ContactViewController.h"
#import "Configuration.h"
#import "YoReferUserDefaults.h"
#import "BaseViewController.h"
#import "UserManager.h"
#import "CoreData.h"

NSString * const kContactCell        = @"category";
NSString * const kContactIdentifier  = @"identifier";

@implementation ContactListTableViewCell

@synthesize delegate = _delegate;

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ContactList>)delegate response:(NSDictionary *)response

{
    self  = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactIdentifier];
    if (self)
    {
        
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setContactWithCategoryType:response indexPath:indexPath];
        
        
        
    }
    
    return self;
}

- (void)setContactWithCategoryType:(NSDictionary *)response indexPath:(NSIndexPath *)indexPath
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 10.0;
    CGFloat yPos = 0.0;
    CGFloat height = 50.0;
    CGFloat width = frame.size.width;
    UILabel *labelList = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelList.tag = indexPath.row;
    NSString *list = [NSString stringWithFormat:@"%@ %@",([[response valueForKey:@"Firstname"] length] > 0)?[response  valueForKey:@"Firstname"]:@"",([[response valueForKey:@"Lastname"] length] > 0)?[response valueForKey:@"Lastname"]:([[response valueForKey:@"Phonenumbers"] count] > 0)?[[response valueForKey:@"Phonenumbers"] objectAtIndex:0]:@""];
    labelList.text = NSLocalizedString(list, @"");
    labelList.font = [[Configuration shareConfiguration] yoReferFontWithSize:13.0];
    labelList.textColor = [UIColor blackColor];
    [self.contentView addSubview:labelList];
    
//    xPos = 20.0;
//    yPos = 5.0;
//    width = 40.0;
//    height = 40.0;
//    //199199204
//    UIImageView *contactImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
//    //contactImage.image = [UIImage imageNamed:@"icon_profile.png"];
//    contactImage.layer.cornerRadius = 20.0;
//    contactImage.layer.borderColor = [[UIColor whiteColor] CGColor];
//    contactImage.layer.borderWidth = 1.0;
//    contactImage.layer.masksToBounds = YES;
//    [self.contentView addSubview:contactImage];
//    
//    UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
//    [nameLbl setText:[NSString stringWithFormat:@"%@%@",([[response valueForKey:@"Firstname"] length] > 0)?[[response  valueForKey:@"Firstname"] substringToIndex:1]:@"",([[response valueForKey:@"Lastname"] length] > 0)?[[response  valueForKey:@"Lastname"] substringToIndex:1]:@""]];
//    [nameLbl setBackgroundColor:[UIColor colorWithRed:(199.0/255.0) green:(199.0/255.0) blue:(204.0/255.0) alpha:1.0]];
//    [nameLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
//    [nameLbl setTextAlignment:NSTextAlignmentCenter];
//    [contactImage addSubview:nameLbl];

    
    xPos = 0.0;
    yPos = labelList.frame.size.height - 2.0;
    height = 2.0;
    width = frame.size.width;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:viewLine];
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
