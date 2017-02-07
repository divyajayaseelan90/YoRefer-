//
//  Users.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/20/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Users <NSObject>

@optional

- (void)getReferUserWithDetail:(NSDictionary *)user;

@end

@interface Users : UIView

@property (nonatomic, readwrite) id <Users>delegate;
- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Users>)delegate users:(NSMutableArray *)users;

@end
