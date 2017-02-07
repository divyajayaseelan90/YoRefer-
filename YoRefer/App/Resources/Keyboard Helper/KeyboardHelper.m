//
//  KeyboardHelper.m
//  HITPA
//
//  Created by Bathi Babu on 12/21/15.
//  Copyright © 2015 Bathi Babu. All rights reserved.
//

#import "KeyboardHelper.h"
#import <UIKit/UIKit.h>
#import "KeyboardConstants.h"

@implementation KeyboardHelper
{
    CGFloat  height;
    CGFloat shiftForKeyboard;
    CGFloat textFieldKeyboardHeight ;
    CGFloat textviewKeyboardHeight ;
    CGFloat searchBarKeyboardHeight ;
    CGFloat togglekeyboardHeight;
    UITableView *viewTable;
    NSArray *keyboardTypes;
}


+ (KeyboardHelper *)sharedKeyboardHelper
{
    
    static KeyboardHelper *_sharedKeyboardHelper = nil;
    static dispatch_once_t onceToke ;
    dispatch_once(&onceToke, ^{
        
        _sharedKeyboardHelper = [[KeyboardHelper alloc]init];
        
    });
    
    return _sharedKeyboardHelper;
    
}

- (void)cancelNumberPad
{
    [self.AccesoryView endEditing:YES];
    
}
- (void)doneWithNumberPad
{
    [self.AccesoryView endEditing:YES];
}

- (UIKeyboardType)keyValues:(keyBoardType)value
{
    
    UIKeyboardType key;
    
    switch (value)
    {
        case DefaulyKeyboard:
            
            key = UIKeyboardTypeDefault;
            break;
            
        case ASCIIkeyboard:
            key = UIKeyboardTypeASCIICapable;
            break;
            
        case NumbersandPunctuations:
            key = UIKeyboardTypeNumbersAndPunctuation;
            break;
            
        case UrlKeyboard:
            key = UIKeyboardTypeURL;
            break;
            
        case NumberPadKeyboard:
            key = UIKeyboardTypeNumberPad;
            break;
            
        case PhonepadKeyboard:
            key = UIKeyboardTypePhonePad;
            break;
            
        case NamePhoneKeyboard:
            key = UIKeyboardTypeNamePhonePad;
            break;
            
        case EmailKeyboard:
            key = UIKeyboardTypeEmailAddress;
            break;
            
        case DecimalKeyboard:
            key = UIKeyboardTypeDecimalPad;
            break;
            
        case TwitterKeyboard:
            key = UIKeyboardTypeTwitter;
            break;
            
        case WebSearchKeyboard:
            key = UIKeyboardTypeWebSearch;
            break;
            
            
        default:
            break;
    }
    return key;
}

- (void)notificationCenter :(UITableView *)table view:(UIView *)totalView
{
    self.AccesoryView = [[UIView alloc]init];
    self.AccesoryView = totalView;
    viewTable = [[UITableView alloc]init];
    viewTable = table;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}




#pragma With out scrollview with out tableview
-(void)animateTextField:(UITextField*)textField isUp:(BOOL)isUp View:(UIView *)Myview postions:(CGFloat)postions
{
    self.AssigningField = textField;
    self.AccesoryView = Myview;
    if (textField.keyboardType == numberPadKeyboard)
    {
        self.AssigningField.inputAccessoryView = [self tollbar:Myview];
    }
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        togglekeyboardHeight = 352.0;
    }
    else
    {
        togglekeyboardHeight = 224.0;
    }
    
    UIView *setView = Myview;
    // CGPoint textViewRect = [textField.superview convertPoint:textField.center toView:setView];
    CGFloat value = Myview.frame.size.height  - togglekeyboardHeight;
    CGFloat bottomEdge = postions + textField.frame.size.height + 64.0;
    CGRect viewFrame = Myview.frame;
    if (isUp)
    {
        if (value <= bottomEdge || (value - bottomEdge) < 20)
        {
            textFieldKeyboardHeight =   value - bottomEdge;
            
            if(textFieldKeyboardHeight >0)
            {
                
                viewFrame.origin.y -= textFieldKeyboardHeight;
            }
            else if(textFieldKeyboardHeight < 0)
            {
                viewFrame.origin.y += textFieldKeyboardHeight;
            }
        }
        else
        {
            // viewFrame.origin.y += - 50.0;
            
        }
        
    }
    else
    {
        
        if(textFieldKeyboardHeight >0)
        {
            
            
            viewFrame.origin.y += textFieldKeyboardHeight;//([[UIScreen mainScreen]bounds].size.height > 480)?textFieldKeyboardHeight:(textFieldKeyboardHeight - 80.0);
        }
        else if(textFieldKeyboardHeight < 0)
        {
            viewFrame.origin.y -= textFieldKeyboardHeight;//([[UIScreen mainScreen]bounds].size.height > 480)?textFieldKeyboardHeight:(textFieldKeyboardHeight - 80.0);
        }
        else
        {
            //viewFrame.origin.y = 0;
            // textFieldKeyboardHeight =  -30.0;
            // viewFrame.origin.y +=  50.0;
        }
        textFieldKeyboardHeight = 0;
        
    }
    [setView setFrame:viewFrame];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    
    
    
}

-(void)animateTextView:(UITextView*)textView isUp:(BOOL)isUp View:(UIView *)Myview postions:(CGFloat)postions
{
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
            togglekeyboardHeight = 352.0;
    }
    else
    {
        togglekeyboardHeight = 224.0;
        //togglekeyboardHeight = 400.0;
    }
    UIView *setView = Myview;
    self.AccesoryView = Myview;
    //CGPoint textViewRect = [textView convertPoint:textView.frame.origin toView:setView];
    CGFloat value = Myview.frame.size.height - togglekeyboardHeight ;
    if (textView.keyboardType == numberPadKeyboard)
    {
        self.AssigningField.inputAccessoryView = [self tollbar:Myview];
    }
    
    
    CGFloat bottomEdge = postions + textView.frame.size.height ;
    CGRect viewFrame = Myview.frame;
    if (isUp)
    {
        
        
        if (value <= bottomEdge || (value - bottomEdge) < 20)
        {
            textviewKeyboardHeight = value - bottomEdge;
            
            if(textviewKeyboardHeight >0)
            {
                viewFrame.origin.y -=textviewKeyboardHeight;
            }
            else
            {
                viewFrame.origin.y +=textviewKeyboardHeight;
            }
        }
        else
        {
            viewFrame.origin.y = 0.0;
            
        }
        
    }
    else
    {
        if(textviewKeyboardHeight >0)
        {
            viewFrame.origin.y +=textviewKeyboardHeight;
        }
        else if(textviewKeyboardHeight < 0)
        {
            viewFrame.origin.y -=textviewKeyboardHeight;
        }
        else
        {
            //viewFrame.origin.y = 0;
            viewFrame.origin.y +=  0.0;
        }
        textviewKeyboardHeight = 0;
        
    }
    [setView setFrame:viewFrame];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    
    
}

-(void)animateSearchBar:(UISearchBar*)searchBar isUp:(BOOL)isUp View:(UIView *)Myview
{
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        togglekeyboardHeight = 352.0;
    }
    else
    {
        togglekeyboardHeight = 224.0;
    }
    UIView *setView = Myview;
    CGPoint textViewRect = [searchBar convertPoint:searchBar.frame.origin toView:setView];
    CGFloat value = Myview.frame.size.height - togglekeyboardHeight;
    if (searchBar.keyboardType == numberPadKeyboard)
    {
        self.AssigningField.inputAccessoryView = [self tollbar:Myview];
    }
    
    
    CGFloat bottomEdge = textViewRect.y ;
    CGRect viewFrame = Myview.frame;
    if (isUp)
    {
        
        
        if (value <= bottomEdge || value - bottomEdge < 20)
        {
            searchBarKeyboardHeight = value - bottomEdge;
            
            if(searchBarKeyboardHeight >0)
            {
                viewFrame.origin.y -=searchBarKeyboardHeight;
            }
            else
            {
                viewFrame.origin.y +=searchBarKeyboardHeight;
            }
            
            
        }
        else
        {
            viewFrame.origin.y = 0.0;
            
        }
        
    }
    else
    {
        if(searchBarKeyboardHeight >0)
        {
            viewFrame.origin.y +=searchBarKeyboardHeight;
        }
        else if(searchBarKeyboardHeight < 0)
        {
            viewFrame.origin.y -=searchBarKeyboardHeight;
        }
        else
        {
            //viewFrame.origin.y = 0;
        }
        
        searchBarKeyboardHeight = 0;
    }
    [setView setFrame:viewFrame];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    
}


- (UIToolbar *)tollbar:(UIView *)view
{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    return numberToolbar;
}




- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height + 20.0), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width + 20.0), 0.0);
    }
    
    viewTable.contentInset = contentInsets;
    //self.tableView.scrollIndicatorInsets = contentInsets;
    [viewTable scrollToRowAtIndexPath:self.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    viewTable.contentInset = UIEdgeInsetsZero;
    //self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


@end
