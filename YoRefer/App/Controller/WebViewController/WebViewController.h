//
//  WebViewController.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/6/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"

@interface WebViewController : BaseViewController

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title refer:(BOOL)isRefer categoryType:(NSString *)categoryType;

@end
