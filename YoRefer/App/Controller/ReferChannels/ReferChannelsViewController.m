//
//  ReferChannelsViewController.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ReferChannelsViewController.h"

NSInteger const referChannelRowCount = 5;

@interface ReferChannelsViewController ()

@end

@implementation ReferChannelsViewController

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        
    }
    
    return self;
    
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Refer Channels";
    [self reloadTableView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(236.0/255.0) blue:(198.0/255.0) alpha:1.0f];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark - tableView datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return referChannelRowCount;
    
}


- (ReferChannelsTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ReferChannelsTableViewCell *cell;
    
    if (cell == nil)
    {
        
        cell = [[ReferChannelsTableViewCell alloc]initWithIndexPath:indexPath delegate:self];
        [cell setBackgroundColor:[UIColor clearColor]];
        
    }
    
    return cell;
    
    
}


- (void)selectIndexPath:(NSIndexPath *)indexPath
{

    
    
    
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
