//
//  ImageViewController.m
//  YoRefer
//
//  Created by Selma D. Souza on 28/07/16.
//  Copyright © 2016 UDVI. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (nonatomic, strong)UIImage *image;
@end

@implementation ImageViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.image = image;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.scrollEnabled = NO;
    [self createImageView];
}

- (void)createImageView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    UIView *mainView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableHeaderView = mainView;
    
    UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imgview setImage:self.image];
    [mainView addSubview:imgview];
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
