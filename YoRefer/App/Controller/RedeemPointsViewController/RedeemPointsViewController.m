//
//  RedeemPointsViewController.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/8/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "RedeemPointsViewController.h"

@interface RedeemPointsViewController ()

@end

@implementation RedeemPointsViewController

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Redeem Points", nil);
    [self createView];
    // Do any additional setup after loading the view.
}

- (void)createView
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    UIView *viewMain = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height)];
    viewMain.backgroundColor = [UIColor redColor];
    yPos = 0.0;
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    image.image = [UIImage imageNamed:@"icon_screen.png"];
    [viewMain addSubview:image];
    [self.view addSubview:viewMain];
    
   
    
    
    UIView *backgroundColor = [[UIView alloc]initWithFrame:image.frame];
    [backgroundColor setBackgroundColor:[UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.5]];
    [self.view addSubview:backgroundColor];
    
    width = 120.0;
    height = 120.0;
    xPos = roundf((viewMain.frame.size.width - width)/2);
    yPos = roundf((viewMain.frame.size.height - height)/2);
    UIImageView *commingSoonImage = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [commingSoonImage setImage:[UIImage imageNamed:@"coming_soon.png"]];
    [self.view addSubview:commingSoonImage];
    
    
}

- (UIView *)createViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    return view;
    
}

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
