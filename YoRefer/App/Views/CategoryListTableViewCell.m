//
//  CategoryListTableViewCell.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "CategoryListTableViewCell.h"
#import "CategoryListViewController.h"
#import "Configuration.h"
#import "YoReferUserDefaults.h"
#import "BaseViewController.h"
#import "UserManager.h"
#import "CoreData.h"

NSString * const kCategoryCell        = @"category";
NSString * const kCategoryIdentifier  = @"identifier";

@implementation CategoryListTableViewCell

@synthesize delegate = _delegate;

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<CategoryList>)delegate response:(NSDictionary *)response categorytype:(categoryList)categorytype

{
    self  = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCategoryIdentifier];
    if (self)
    {
        
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
            [self setCategoryWithCategoryType:categorytype response:response indexPath:indexPath];
            
        
        
    }
    
    return self;
}


- (void)setCategoryWithCategoryType:(categoryList)categoryType response:(NSDictionary *)response indexPath:(NSIndexPath *)indexPath
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 20.0;
    CGFloat yPos = 0.0;
    CGFloat height = 40.0;
    CGFloat width = frame.size.width;
    UILabel *labelList = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    labelList.tag = indexPath.row;
    NSString *list = [response  objectForKey:@"name"];
    labelList.text = NSLocalizedString(list, @"");
    labelList.font = [[Configuration shareConfiguration] yoReferFontWithSize:13.0];
    labelList.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:labelList];
    
    xPos = 0.0;
    yPos = labelList.frame.size.height - 2.0;
    height = 2.0;
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
