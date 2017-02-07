//
//  AddContact.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/2/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol Contact <NSObject>

- (void)getCustomeContact:(NSArray *)array;

@end

@interface AddContact : UIView

@property (nonatomic, weak) id<Contact>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame type:(NSString *)type delegate:(id<Contact>)delegate referContact:(NSMutableArray *)referContact;



@end
