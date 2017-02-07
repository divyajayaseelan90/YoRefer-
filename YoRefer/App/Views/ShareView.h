//
//  ShareView.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/22/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddContact.h"

@protocol Share <NSObject>

- (void)messageWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel;
- (void)mailWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel;;
- (void)wahtsUpWithContacts:(NSArray *)array referChannel:(NSDictionary *)referChannel;
- (void)twitterShare:(NSArray *)array referChannel:(NSDictionary *)referChannel;
- (void)facebookShare:(NSArray *)array referChannel:(NSDictionary *)referChannel;

@end

@interface ShareView : UIView<Contact>

@property (nonatomic,weak) id <Share>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Share>)delegate referChannel:(NSDictionary *)referChannel;

- (void)getCustomeContact:(NSArray *)array;

@end
