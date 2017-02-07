//
//  KeyboardHelper.h
//  HITPA
//
//  Created by Bathi Babu on 12/21/15.
//  Copyright © 2015 Bathi Babu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    
    DefaulyKeyboard,
    ASCIIkeyboard,
    NumbersandPunctuations,
    UrlKeyboard,
    NumberPadKeyboard,
    PhonepadKeyboard,
    NamePhoneKeyboard,
    EmailKeyboard,
    DecimalKeyboard,
    TwitterKeyboard,
    WebSearchKeyboard
    
}keyBoardType;

@interface KeyboardHelper : NSObject <UITextFieldDelegate,UITextViewDelegate,UISearchBarDelegate>

+ (KeyboardHelper *)sharedKeyboardHelper;
-(void)animateTextField:(UITextField*)textField isUp:(BOOL)isUp View:(UIView *)Myview postions:(CGFloat)postions;
-(void)animateTextView:(UITextView*)textView isUp:(BOOL)isUp View:(UIView *)Myview postions:(CGFloat)postions;
-(void)animateSearchBar:(UISearchBar*)searchBar isUp:(BOOL)isUp View:(UIView *)Myview;
- (void)notificationCenter :(UITableView *)table view:(UIView *)totalView;
- (UIKeyboardType)keyValues:(keyBoardType)value;
@property (nonatomic,strong) UITextField *AssigningField;
@property (nonatomic ,strong)UIView *AccesoryView;
@property(nonatomic, strong) NSIndexPath *editingIndexPath;

- (UIToolbar *)tollbar:(UIView *)view;
@end
