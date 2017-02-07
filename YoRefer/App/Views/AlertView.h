//
//  AlertView.h
//  YoRefer
//
//  Created by Bathi Babu on 1/28/16.
//  Copyright © 2016 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Alert <NSObject>
-(void)selectedPhoneNumber:(NSString *)phoneNumber;
@end

@interface AlertView : UIView

@property (nonatomic,weak) id <Alert>delegate;

- (instancetype)initWithViewFrame:(CGRect)frame delegate:(id<Alert>)delegate referChannel:(NSArray *)phoneNumbers;



@end
