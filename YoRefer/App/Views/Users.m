//
//  Users.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Users.h"
#import "Configuration.h"
#import "Home.h"
#import "DocumentDirectory.h"
#import "UserManager.h"
#import "LazyLoading.h"
#import "Constant.h"

NSInteger   const    kUserTableViewTag   = 40000;
NSString *  const    kRefreeList         = @"Referee list";


@interface Users ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *users;

@end

@implementation Users

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Users>)delegate users:(NSMutableArray *)users

{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.users = users;
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
        [self setBackgroundColor:[UIColor colorWithRed:(251.0/255.0) green:(235.0/255.0) blue:(200.0/255.0) alpha:1.0f]];
        [self createView];
    }
    return self;
}

- (void)createView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    tableView.tag = kUserTableViewTag;
    [tableView setUserInteractionEnabled:YES];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView reloadData];
    [self addSubview:tableView];
}

#pragma mark - TabelView data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = self.frame.size.width;
    CGFloat height = 44.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor colorWithRed:(204.0/255.0) green:(99.0/255.0) blue:(75.0/255.0) alpha:1.0]];
    UILabel *label = [[UILabel alloc]initWithFrame:view.frame];
    [label setText:kRefreeList];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:18.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60.0;
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
    CGFloat xPos = 4.0;
    CGFloat yPos = 4.0;
    CGFloat width = 50.0;
    CGFloat height = 50.0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView.layer setCornerRadius:25.0];
    [imageView.layer setMasksToBounds:YES];
    [cell.contentView addSubview:imageView];
    if ([[self.users objectAtIndex:indexPath.row] valueForKey:kDp] != nil && [[[self.users objectAtIndex:indexPath.row] valueForKey:kDp] length] > 0)
    {
        NSArray *imageDPArray = [[[self.users objectAtIndex:indexPath.row] valueForKey:@"dp"] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageDPArray objectAtIndex:[imageDPArray count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        }else{
            
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[self.users objectAtIndex:indexPath.row] valueForKey:@"dp"]] imageView:imageView];
        }
        
    }else
    {
        [imageView setImage:profilePic];
    }
    xPos = imageView.frame.origin.x + imageView.frame.size.width + 4.0;
    yPos = 4.0;
    width = cell.frame.size.width - width;
    height = 50.0;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [label setText:[[self.users objectAtIndex:indexPath.row] valueForKey:@"name"]];
    [cell.contentView addSubview:label];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(getReferUserWithDetail:)])
    {
        [self.delegate getReferUserWithDetail:[self.users objectAtIndex:indexPath.row]];
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
