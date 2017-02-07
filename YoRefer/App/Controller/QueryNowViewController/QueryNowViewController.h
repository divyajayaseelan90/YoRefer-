//
//  QueryNowViewController.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/14/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"

@protocol Query <NSObject>
- (void)askPost;
@end

@interface QueryNowViewController : BaseViewController

@property (nonatomic, weak) id<Query>delegate;

- (instancetype)initWithQueryDetail:(NSMutableDictionary *)queryDetail delegate:(id<Query>)delegate;
- (void)postAskWithParams:(NSMutableDictionary *)params;
- (void)showAnimatedWithTextView:(UITextView *)textView;
- (void)hideAnimatedWithTextView:(UITextView *)textView;

@end
