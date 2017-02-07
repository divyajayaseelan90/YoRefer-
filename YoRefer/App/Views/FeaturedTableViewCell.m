//
//  FeaturedTableViewCell.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 12/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "FeaturedTableViewCell.h"
#import "Configuration.h"
#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "UserManager.h"


NSString * const kFeaturedPopularIdentifier        = @"Popular";
NSString * const kFeaturedFeaturedNearByIdentifier = @"FeaturedNearBy";


@interface FeaturedTableViewCell ()

@end


@implementation FeaturedTableViewCell

@synthesize  delegate = _delegate;

#pragma mark - instancetype
- (instancetype)initWihtIndexPath:(NSIndexPath *)indexPath delegate:(id<Featured>)delegate response:(Featured *)response
{
    
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getIdentifierWithIndexPath:indexPath]];
    
    if (self)
    {
        
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createFeaturedViewWithResponse:response indexPath:indexPath];
        
        
    }
    
    return self;
    
    
}

- (NSString *)getIdentifierWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *indetifier = nil;
    
    switch (indexPath.section) {
        case 0:
            indetifier = kFeaturedPopularIdentifier;
            break;
            
        case 1:
            indetifier = kFeaturedFeaturedNearByIdentifier;
            break;
        default:
            break;
    }
    
    return indetifier;
    
}

#pragma mark -

- (CGRect)bounds
{
    
    return [[UIScreen mainScreen] bounds];
    
}


- (void)createFeaturedViewWithResponse:(Featured *)response indexPath:(NSIndexPath *)indexPath
{
    
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 4.0;
    CGFloat width = frame.size.width;
    CGFloat height = 186.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:view];
    
    width = roundf(view.frame.size.width /2) - 12.0;
    xPos = 8.0;
    height = 180.0;
    UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [firstView setBackgroundColor:[UIColor whiteColor]];
    [firstView.layer setCornerRadius:5.0];
    [firstView.layer setMasksToBounds:YES];
    [view addSubview:firstView];
    [self createViewWithView:firstView response:(Featured *)[response valueForKey:@"begin"] key:@"begin"];
    UITapGestureRecognizer *firstViewGestureRecognizer  =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(firstViewGestureTapped:)];
    [firstView addGestureRecognizer:firstViewGestureRecognizer];
    
    
    xPos = firstView.frame.size.width + 16.0;
    width = roundf(view.frame.size.width /2) - 12.0;
    UIView *lastView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [lastView.layer setCornerRadius:5.0];
    [lastView setBackgroundColor:[UIColor clearColor]];
    [lastView.layer setMasksToBounds:YES];
    [view addSubview:lastView];
    
    UITapGestureRecognizer *lastViewGestureRecognizer  =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lastViewGestureTapped:)];
    [lastView addGestureRecognizer:lastViewGestureRecognizer];
    
    if ([response valueForKey:@"end"]){
        
        [lastView setBackgroundColor:[UIColor whiteColor]];
        [self createViewWithView:lastView response:(Featured *)[response valueForKey:@"end"]key:@"end"];
        
    }
    
    
    
}

- (void)createViewWithView:(UIView *)view response:(Featured *)response key:(NSString *)key
{
    
    CGFloat width = 60.0;
    CGFloat height = 60.0;
    CGFloat xPos = roundf((view.frame.size.width - width)/2);
    CGFloat yPos = 4.0;
    
    
    NSDictionary *dictionary  = response.entity;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    NSArray *array = [[[dictionary objectForKey:@"dp"] objectForKey:@"mediaId"] componentsSeparatedByString:@"/"];
    
    NSString *imageName = [array objectAtIndex:[array count]-1];
    
    
    
    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
    {
        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
        
    }else{
        
        [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[dictionary objectForKey:@"dp"] objectForKey:@"mediaId"]] imageView:imageView];
        
        
        
    }
    
    
    [imageView setBackgroundColor:[UIColor grayColor]];
    [view addSubview:imageView];
    
    xPos = 0.0;
    yPos = imageView.frame.size.height + 8.0;
    height = 72.0;
    width = view.frame.size.width;
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [infoView setBackgroundColor:[UIColor whiteColor]];
    [view addSubview:infoView];
    
    
    //address
    
    NSMutableAttributedString *address = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n",[dictionary objectForKey:@"name"]]];
    if ([name length] >0)
    {
        [name addAttribute:NSFontAttributeName value:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0] range:NSMakeRange(0,name.length)];
        [name addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, name.length)];
        [address appendAttributedString:name];
        
    }
    
    
    NSMutableAttributedString *locality = [[NSMutableAttributedString alloc]initWithString:([dictionary objectForKey:@"locality"])?[dictionary objectForKey:@"locality"]:@""];
    
    if ([locality length] > 0)
    {
        [locality addAttribute:NSFontAttributeName value:[[Configuration shareConfiguration] yoReferBoldFontWithSize:10.0] range:NSMakeRange(0,locality.length)];
        [locality addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, locality.length)];
        [address appendAttributedString:locality];
    }
    
    
    
    xPos = 0.0;
    yPos = 0.0;
    width = infoView.frame.size.width;
    height = 42.0;
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [titleLbl setAttributedText:address];
    [titleLbl setTextAlignment:NSTextAlignmentCenter];
    [titleLbl setNumberOfLines:8];
    //[titleLbl sizeToFit];
    [titleLbl setBackgroundColor:[UIColor whiteColor]];
    [infoView addSubview:titleLbl];
    
    yPos = 40.0;
    height = 1.0;
    UIView *topLineView  =[[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [topLineView setBackgroundColor:[UIColor grayColor]];
    [infoView addSubview:topLineView];
    
    //title
    yPos = topLineView.frame.size.height + topLineView.frame.origin.y;
    height = 30.0;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    if ([[dictionary objectForKey:@"offers"] count]>0) {
        [title setText:[NSString stringWithFormat:@"%@", [[[dictionary objectForKey:@"offers"] objectAtIndex:0] objectForKey:@"message"]]];
    }
    [title setTextColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
    [title setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setBackgroundColor:[UIColor whiteColor]];
    [infoView addSubview:title];
    
    yPos = infoView.frame.size.height - 4.0;
    height = 1.0;
    UIView *bottomLineView  =[[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [bottomLineView setBackgroundColor:[UIColor grayColor]];
    [infoView addSubview:bottomLineView];
    
    
    //option view
    
    yPos = infoView.frame.size.height + infoView.frame.origin.y - 3.0 ;
    xPos = 0.0;
    width = view.frame.size.width;
    height = 37.0;
    UIView * optionView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [optionView setBackgroundColor:[UIColor whiteColor]];
    [view addSubview:optionView];
    
    //viewDetail
    xPos = 4.0;
    yPos = 12.0;
    width = 100.0;
    height = 20.0;
    
    UILabel *viewDetailLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [viewDetailLbl setText:NSLocalizedString(@"View Detail", @"")];
    [viewDetailLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [viewDetailLbl setTextColor:[UIColor blackColor]];
    //[optionView addSubview:viewDetailLbl];
    
    width = round(optionView.frame.size.width /2);
    height = optionView.frame.size.height;
    xPos = 0.0;
    yPos = 0.0;
    UIButton *viewDetailBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [viewDetailBtn setBackgroundColor:[UIColor clearColor]];
    viewDetailBtn.tag = ([key isEqualToString:@"begin"])?40000:50000;
    [viewDetailBtn addTarget:self action:@selector(viewDetailBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[optionView addSubview:viewDetailBtn];
    
    width = 90.0;
    height = 24.0;
    xPos = roundf((optionView.frame.size.width - width)/2);
    yPos = roundf((optionView.frame.size.height - height)/2) + 2.0;
    
    UILabel *referNowLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNowLbl setText:NSLocalizedString(@"Refer Now", @"")];
    [referNowLbl setTextAlignment:NSTextAlignmentCenter];
    [referNowLbl.layer setCornerRadius:10.0];
    [referNowLbl.layer setMasksToBounds:YES];
    [referNowLbl.layer setBorderWidth:2.0];
    [referNowLbl.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [referNowLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
    [referNowLbl setTextColor:[UIColor whiteColor]];
    [referNowLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNowLbl.bounds];
    referNowLbl.layer.shadowColor = [UIColor grayColor].CGColor;
    referNowLbl.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    referNowLbl.layer.shadowOpacity = 0.3f;
    referNowLbl.layer.shadowPath = shadowPath.CGPath;
    
    [optionView addSubview:referNowLbl];
    
    
    width = optionView.frame.size.width;
    height = optionView.frame.size.height;
    xPos = 0.0;
    yPos = 0.0;
    UIButton *referNowBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [referNowBtn setBackgroundColor:[UIColor clearColor]];
    [referNowBtn addTarget:self action:@selector(referNowBtnBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    referNowBtn.tag = ([key isEqualToString:@"begin"])?40000:50000;
    [optionView addSubview:referNowBtn];
    
    
}

#pragma mark - LazyLoading

- (void)loadImageWithUrl:(NSURL *)url imageView:(UIImageView *)imageView
{
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(round(imageView.frame.size.width /2), round(imageView.frame.size.height/2));
    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    NSOperationQueue *queue;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    if ( queue == nil )
    {
        queue = [[NSOperationQueue alloc] init];
    }
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse * resp, NSData     *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(),^
                        {
                            if ( error == nil && data )
                            {
                                UIImage *urlImage = [[UIImage alloc] initWithData:data];
                                imageView.image = urlImage;
                                [activityIndicator stopAnimating];
                                activityIndicator.hidesWhenStopped = YES;
                            }
                        });
     }];
    
}


#pragma mark - button delegate

- (UITableView *)getTableView
{
    //Remove drop view from super view
    id view = [self superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        
        view = [view superview];
    }
    
    
    UITableView *superView = (UITableView *)view;
    
    return superView;
    
}


- (IBAction)viewDetailBtnTapped:(id)sender
{
    
    
    UIButton *button = (UIButton *)sender;
    
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    
    if (button.tag == 40000)
    {
        
        if ([self.delegate respondsToSelector:@selector(getBeginViewDetailWithIndexPath:)])
        {
            [self.delegate getBeginViewDetailWithIndexPath:indexPath];
            
        }
        
    }else if (button.tag == 50000)
    {
        if ([self.delegate respondsToSelector:@selector(getEndViewDetailWithIndexPath:)])
        {
            [self.delegate getEndViewDetailWithIndexPath:indexPath];
            
        }
    }
    
    
    
}

- (IBAction)referNowBtnBtnTapped:(id)sender
{
    
    
    UIButton *button = (UIButton *)sender;
    
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = button.center;
    CGPoint point = [button.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    
    if (button.tag == 40000)
    {
        
        if ([self.delegate respondsToSelector:@selector(getBeginReferNowWithIndexPath:)])
        {
            [self.delegate getBeginReferNowWithIndexPath:indexPath];
            
        }
        
    }else if (button.tag == 50000)
    {
        if ([self.delegate respondsToSelector:@selector(getEndRefrNowWithIndexPath:)])
        {
            [self.delegate getEndRefrNowWithIndexPath:indexPath];
            
        }
    }
    
    
}

#pragma mark  - GestureRecognizer

- (void)firstViewGestureTapped:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    
    if ([self.delegate respondsToSelector:@selector(getBeginIndexPath:)])
    {
        [self.delegate getBeginIndexPath:indexPath];
    }
    
}

- (void)lastViewGestureTapped:(UIGestureRecognizer *)gestureRecognizer
{
    
    UITableView *tableView =  tableView = (UITableView *)self.superview.superview;
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath= [tableView indexPathForRowAtPoint:point];
    
    if ([self.delegate respondsToSelector:@selector(getEndIndexPath:)])
    {
        [self.delegate getEndIndexPath:indexPath];
    }
    
}

#pragma mark - awakeFromNib
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
