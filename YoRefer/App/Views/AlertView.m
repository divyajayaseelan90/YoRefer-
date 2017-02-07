//
//  AlertView.m
//  YoRefer
//
//  Created by Bathi Babu on 1/28/16.
//  Copyright © 2016 UDVI. All rights reserved.
//

#import "AlertView.h"
#import <UIKit/UIKit.h>

@interface AlertView ()<UITableViewDataSource,UITableViewDelegate>
//@property ( nonatomic ,strong) UITableView *myTable;
@property (nonatomic , strong) NSArray *phonenumbers;
@property (nonatomic , strong) NSIndexPath *IndexPath;
@property (readwrite) int selectedIndex;
@property (nonatomic ,strong) UIView *BaseView;

@end

@implementation AlertView


- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Alert>)delegate referChannel:(NSArray *)phoneNumbers{
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        self.phonenumbers = phoneNumbers;
        self.frame = frame;
        [self Alert];
        
        
        
    }
    return self;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.phonenumbers count];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat xPos,yPos,width,height;
    xPos = self.BaseView.frame.origin.x;
    yPos = self.BaseView.frame.origin.y;
    width = self.BaseView.frame.size.width;
    height = 30.0;
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    header.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:88.0/255.0 blue:62.0/255.0 alpha:1.0];
    
    xPos = 0;
    yPos = 0;
    UILabel *Text = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    Text.text = NSLocalizedString(@"Select Phone Number", );
    Text.font = [UIFont systemFontOfSize:14.0];
    Text.textAlignment = NSTextAlignmentCenter;
    Text.textColor = [UIColor whiteColor];
    [header addSubview:Text];
    
    return header;
}



- (UITableViewCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
        static NSString *simpleTableIdentifier = @"Cell";
        
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
       UILabel * lableCircle;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
    CGFloat xPos = cell.contentView.frame.size.width - 53.0;
    CGFloat yPos = 10.0;
    CGFloat width = 18.0;
    CGFloat height = 18.0;
    lableCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    lableCircle.layer.cornerRadius = 9.0;
    lableCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    lableCircle.layer.borderWidth = 3.0;
    lableCircle.layer.masksToBounds = YES;
    [cell.contentView addSubview:lableCircle];
    if (self.IndexPath.row == indexPath.row)
    {
        lableCircle.backgroundColor = [UIColor blackColor];
        
    }else
    {
        lableCircle.backgroundColor = [UIColor whiteColor   ];
        
    }
    
    tableView.separatorColor = [UIColor redColor];
    cell.textLabel.text = [self.phonenumbers objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.IndexPath = indexPath;
    [tableView reloadData];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSArray *subViews = [[[cell subviews] objectAtIndex:0] subviews];
//    
//    UILabel *lbl = [subViews objectAtIndex:0];
//    
//    
//   if (lbl.backgroundColor == [UIColor blackColor])
//    {
//        [lbl setBackgroundColor:[UIColor whiteColor]];
//    }
//    else
//    {
//       [lbl setBackgroundColor:[UIColor blackColor]];
//    }
    
}



- (void)Alert
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGFloat xPos,yPos,width,height;
    
    
    
    UIView *fullView = [[UIView alloc]initWithFrame:frame];
    fullView.alpha = 0.6;
    fullView.backgroundColor = [UIColor blackColor];
    fullView.tag = 9999;
    [self addSubview:fullView];
    
    xPos = frame.origin.x + 10.0;
    yPos = frame.size.height/3.2;
    width = frame.size.width - 20.0;
    height = frame.size.height/3;
    self.BaseView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    self.BaseView.layer.cornerRadius = 6.0;
    self.BaseView.layer.masksToBounds = YES;
    self.BaseView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:238.0/255.0 blue:196.0/255.0 alpha:1.0];
    self.BaseView.tag = 8888;
    [self addSubview:self.BaseView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = self.BaseView.frame.size.width;
    height = self.BaseView.frame.size.height - 40.0;
    UITableView * myTable = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
     myTable.tag = 400;
    myTable.tableFooterView = [UIView new];
    [self.BaseView addSubview:myTable];
    myTable.delegate   = self;
    myTable.dataSource = self ;
    myTable.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:238.0/255.0 blue:196.0/255.0 alpha:1.0];
   
    yPos = myTable.frame.origin.y + myTable.frame.size.height;
    width = (self.BaseView.frame.size.width/2);
    height = 40.0;
    UIButton *ok = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    ok.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:88.0/255.0 blue:62.0/255.0 alpha:1.0];
    [ok setTitle:@"OK" forState:UIControlStateNormal];
     [ok setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
     ok.tag = 7777;
    [self.BaseView addSubview:ok];
   
    xPos   = ok.frame.size.width - 2.0;
    yPos   = 0.0;
    width  = 2.0;
    height = ok.frame.size.height;
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    lineview.backgroundColor = [UIColor whiteColor];
    lineview.tag = 5555;
    [ok addSubview:lineview];
    
    xPos = ok.frame.origin.x + ok.frame.size.width ;
    yPos = myTable.frame.origin.y + myTable.frame.size.height;
    width = (self.BaseView.frame.size.width/2) ;
    height = 40.0;
    UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    cancel.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:88.0/255.0 blue:62.0/255.0 alpha:1.0];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(Cancel) forControlEvents:UIControlEventTouchUpInside];
    cancel.tag = 6666;
    [self.BaseView addSubview:cancel];
    

}

-(void)ok
{
    //NSLog(@"%d",self.IndexPath.row);
    [(UIView *)[self viewWithTag:9999] removeFromSuperview];
    [(UIView *)[self viewWithTag:8888] removeFromSuperview];
    [(UITableView *)[self viewWithTag:400] removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(selectedPhoneNumber:)])
    {
        [self.delegate selectedPhoneNumber:[self.phonenumbers objectAtIndex:self.IndexPath.row]];
    }
}
-(void)Cancel
{
    [(UIView *)[self viewWithTag:99] removeFromSuperview];
    [(UIView *)[self viewWithTag:3] removeFromSuperview];
    [(UITableView *)[self viewWithTag:400] removeFromSuperview];
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
