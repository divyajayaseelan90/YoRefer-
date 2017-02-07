//
//  Utility.h
//  Finao
//
//  Created by sunilkumar on 15/07/15.
//  Copyright (c) 2015 HighBrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




@interface Utility : NSObject

void alertView(NSString *title, NSString *message, id delegate,NSString *buttonOne,NSString *buttonTwo,int tag);

void showActivity (NSString *message,UIView *view_Add);

void stopActivity(UIView *view);


@end
