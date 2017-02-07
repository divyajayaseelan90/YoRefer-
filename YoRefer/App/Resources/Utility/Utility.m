//
//  Utility.m
//  Finao
//
//  Created by sunilkumar on 15/07/15.
//  Copyright (c) 2015 HighBrow. All rights reserved.
//

#import "Utility.h"
#import <UIKit/UIKit.h>


@implementation Utility




void alertView(NSString *title, NSString *message, id delegate,NSString *buttonOne,NSString *buttonTwo,int tag)
{
    /* open an alert with OK and Cancel buttons */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:buttonOne
                                          otherButtonTitles:buttonTwo, nil];
    alertView.tag = tag;
    // otherButtonTitles: @"Show Next Tip", @"Disable Tips", nil];
    [alertView show];
    
}

void showActivity (NSString *message,UIView *view_Add)
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *view_main=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, rect.size.width, rect.size.height)];
    view_main.tag=1001;
    //400
    
    UIImage *statusImage = [UIImage imageNamed:@"1.png"];
    UIImageView *activityImageView = [[UIImageView alloc]
                                      initWithImage:statusImage];
    
    activityImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"1.png"],
                                         [UIImage imageNamed:@"2.png"],
                                         [UIImage imageNamed:@"3.png"],
                                         [UIImage imageNamed:@"4.png"],
                                         [UIImage imageNamed:@"5.png"],
                                         [UIImage imageNamed:@"6.png"],
                                         [UIImage imageNamed:@"7.png"],
                                         [UIImage imageNamed:@"8.png"],
                                         nil];
    activityImageView.animationDuration = 0.5;
    activityImageView.frame = CGRectMake(10.0,50.0,35.0,35.0);
    [activityImageView startAnimating];
    
    UILabel *lbl_Message=[[UILabel alloc]init];
    lbl_Message.text=message;
    
    UIView *view_progress;
    view_progress=[[UIView alloc]initWithFrame:CGRectMake(view_main.frame.origin.x+10.0, view_main.frame.size.height/2.0-70.0, view_main.frame.size.width-20.0, 100.0)];
    view_progress.backgroundColor=[UIColor whiteColor];
    view_progress.layer.cornerRadius=5;
    view_progress.layer.masksToBounds=YES;
    
    UILabel *prog_lbl=[[UILabel alloc]initWithFrame:CGRectMake(60.0, 38.0, 260.0, 60.0)];
    [prog_lbl setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
    [prog_lbl setNumberOfLines:5];
    [prog_lbl setTextColor:[UIColor blackColor]];
    [prog_lbl setBackgroundColor:[UIColor clearColor]];
    [prog_lbl setText:message];
    prog_lbl.textAlignment = NSTextAlignmentLeft;
    
    UILabel *header_lbl=[[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, view_main.frame.size.width-20.0, 40.0)];
    [header_lbl setBackgroundColor:[UIColor orangeColor]];
    [header_lbl setFont:[UIFont fontWithName:@"Helvetica Bold" size:18.0]];
    [header_lbl setTextColor:[UIColor whiteColor]];
    [header_lbl setText:@"Yorefer"];
    header_lbl.textAlignment=NSTextAlignmentCenter;
    
    [view_progress addSubview:header_lbl];
    [view_progress addSubview:activityImageView];
    [view_progress addSubview:prog_lbl];
    [view_main setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(8.0/255.0) blue:(8.0/255.0) alpha:0.5f]];
    [view_main addSubview:view_progress];
    [view_Add addSubview:view_main];
    
}

void stopActivity(UIView *view)
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    NSArray *subviews = [view subviews];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    for (UIView *subview in subviews) {
        if((long)subview.tag==1001){
            subview.hidden=YES;
        }
        
        
    }
}




@end
