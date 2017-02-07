//
//  LazyLoading.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 14/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LazyLoading : NSObject

- (void)loadImageWithUrl:(NSURL *)url imageView:(UIImageView *)imageView;
+ (LazyLoading *)shareLazyLoading;

@end
