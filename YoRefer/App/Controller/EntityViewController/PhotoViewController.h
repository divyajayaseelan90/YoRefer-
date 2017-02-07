//
//  PhotoViewController.h
//  YoRefer
//
//  Created by Devendra Rathore on 11/13/16.
//  Copyright © 2016 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"


@interface PhotoViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;


@end
