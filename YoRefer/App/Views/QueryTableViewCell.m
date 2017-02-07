//
//  QueryTableViewCell.m
//  YoRefer
//
//  Created by Bhaskar C M on 10/14/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "QueryTableViewCell.h"
#import "QueryNowViewController.h"
#import "Configuration.h"
#import "YoReferUserDefaults.h"
#import "CoreData.h"
#import "UserManager.h"
#import "Helper.h"
#import "Utility.h"
#import "YoReferAPI.h"
#import "CoreData.h"
#import "LocationManager.h"

NSString    *   const   kQueryPlace               = @"Place";
NSString    *   const   kQueryProduct             = @"Product";
NSString    *   const   kQueryService             = @"Service";
NSString    *   const   kQueryAsk                 = @"Ask";
NSUInteger      const   kQueryMessage             = 100000;
NSString    *   const   kQueryMessagePlaceHolder  = @"Please type a short message on what you are looking for ... ";

NSString * const kQueryReuseIdentifier   = @"cellIdentifire";

@implementation QueryTableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<queryTableViewCell>)delegate queryDetail:(NSMutableDictionary *)queryDetail
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kQueryReuseIdentifier];
    if (self)
    {
        self.delegate = delegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self queryCellsWithIndexPath:indexPath queryDetail:queryDetail];
    }
    return self;
}

#pragma mark -
- (void)queryCellsWithIndexPath:(NSIndexPath *)indexPath queryDetail:(NSMutableDictionary *)queryDetail
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 10.0;
    CGFloat yPos = 10.0;
    CGFloat height = 90.0;
    CGFloat width = frame.size.width - 20.0;
    if (indexPath.row == QueryLocation)
    {
        xPos = 10.0;
        yPos = 10.0;
        height = 40.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewMain.tag = QueryLocation;
        viewMain.backgroundColor = [UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        //textFiled
        xPos = 5.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 30.0;
        UITextField *textField = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) queryType:QueryLocation text:[queryDetail valueForKey:kCity]];
        [viewMain addSubview:textField];
        //DownArrow image
        width = 25.0;
        height = 25.0;
        xPos = viewMain.frame.size.width - 30.0;
        yPos = round((viewMain.frame.size.height - height)/2);
        UIImageView *imageDownArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        imageDownArrow.image = downarraow;
        [viewMain addSubview:imageDownArrow];
        //DownArrowButton
        xPos = viewMain.frame.size.width - 40.0;
        yPos = 0.0;
        width = 40.0;
        height = 40.0;
        UIButton *addressBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [addressBtn setTag:13212];
        [addressBtn addTarget:self action:@selector(addressBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [viewMain addSubview:addressBtn];
        //location Button
        //button
        xPos = 0.0;
        yPos = 0.0;
        width = viewMain.frame.size.width;
        height = viewMain.frame.size.height;
        UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [locationBtn setBackgroundColor:[UIColor clearColor]];
        [locationBtn addTarget:self action:@selector(locationBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [viewMain addSubview:locationBtn];
        //enableanddisbale location button
        [locationBtn setHidden:([[UserManager shareUserManager] getLocationService])?YES:NO];
    }else if (indexPath.row == QueryCategoryType)
    {
        xPos = 10.0;
        yPos = 10.0;
        height = 40.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewMain.tag = QueryCategoryType;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        xPos = 0.0;
        yPos = 0.0;
        width = viewMain.frame.size.width/3;
        UIView *viewPlace = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewPlace.backgroundColor = [UIColor clearColor];
        [viewMain addSubview:viewPlace];
        xPos = viewPlace.frame.size.width;
        UIView *viewProduct = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewProduct.backgroundColor = [UIColor clearColor];
        [viewMain addSubview:viewProduct];
        xPos = viewPlace.frame.size.width * 2;
        UIView *viewService = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewService.backgroundColor = [UIColor clearColor];
        [viewMain addSubview:viewService];
        xPos = viewPlace.frame.size.width/2 - 15.0;
        width = viewPlace.frame.size.width/2 + 10.0;
        UILabel *place = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        place.text = kQueryPlace;
        place.textAlignment = NSTextAlignmentLeft;
        place.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        place.textColor = [UIColor blackColor];
        [viewPlace addSubview:place];
        UILabel *product = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        product.text = kQueryProduct;
        product.textAlignment = NSTextAlignmentLeft;
        product.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        product.textColor = [UIColor blackColor];
        [viewProduct addSubview:product];
        UILabel *service = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        service.text = kQueryService;
        service.textAlignment = NSTextAlignmentLeft;
        service.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        service.textColor = [UIColor blackColor];
        [viewService addSubview:service];
        xPos = place.frame.origin.x - 20.0;
        width = 16.0;
        height = 16.0;
        yPos = 13.0;
        UILabel *placeCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        placeCircle.layer.cornerRadius = 8.0;
        placeCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        placeCircle.layer.borderWidth = 1.0;
        placeCircle.layer.masksToBounds = YES;
        [viewPlace addSubview:placeCircle];
        xPos = product.frame.origin.x - 20.0;
        UILabel *productCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        productCircle.layer.cornerRadius = 8.0;
        productCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        productCircle.layer.borderWidth = 1.0;
        productCircle.layer.masksToBounds = YES;
        [viewProduct addSubview:productCircle];
        xPos = service.frame.origin.x - 20.0;
        UILabel *serviceCircle = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        serviceCircle.layer.cornerRadius = 8.0;
        serviceCircle.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        serviceCircle.layer.borderWidth = 1.0;
        serviceCircle.layer.masksToBounds = YES;
        [viewService addSubview:serviceCircle];
        xPos = 5;
        width = 6.0;
        height = 6.0;
        yPos = 5.0;
       UILabel  *placeCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        placeCircleDot.tag = Places;
        placeCircleDot.layer.cornerRadius = 3.0;
        placeCircleDot.layer.masksToBounds = YES;
        placeCircleDot.backgroundColor = [UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f];
        [placeCircle addSubview:placeCircleDot];
       UILabel *productCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        productCircleDot.tag = Product;
        productCircleDot.layer.cornerRadius = 3.0;
        productCircleDot.layer.masksToBounds = YES;
        productCircleDot.backgroundColor = [UIColor clearColor];
        [productCircle addSubview:productCircleDot];
       UILabel* serviceCircleDot = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        serviceCircleDot.tag = Services;
        serviceCircleDot.layer.cornerRadius = 3.0;
        serviceCircleDot.layer.masksToBounds = YES;
        serviceCircleDot.backgroundColor = [UIColor clearColor];
        [serviceCircle addSubview:serviceCircleDot];
        UITapGestureRecognizer *placeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeMark:)];
        [viewPlace addGestureRecognizer:placeGestureRecognizer];
        UITapGestureRecognizer *productGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(productMark:)];
        [viewProduct addGestureRecognizer:productGestureRecognizer];
        UITapGestureRecognizer *serviceGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(serviceMark:)];
        [viewService addGestureRecognizer:serviceGestureRecognizer];
    }else if (indexPath.row == QueryCategory)
    {
        xPos = 10.0;
        yPos = 10.0;
        height = 40.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewMain.tag = QueryCategory;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        xPos = 6.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 30.0;
        UITextField *textCategory = [self createTextFiledWithFrame:CGRectMake(xPos, yPos, width, height) queryType:QueryCategory text:[queryDetail valueForKey:kCategory]];
        [textCategory setUserInteractionEnabled:NO];
        [viewMain addSubview:textCategory];
        xPos = viewMain.frame.size.width - 35.0;
        yPos = 8.0;
        width = 25.0;
        height = 25.0;
        UIImageView *imageDownArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        imageDownArrow.image = downArrowImg;
        [viewMain addSubview:imageDownArrow];
        //button
        UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, viewMain.frame.size.width, viewMain.frame.size.height)];
        [categoryBtn addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [viewMain addSubview:categoryBtn];
    }else if (indexPath.row == QueryMessage)
    {
        xPos = 10.0;
        yPos = 10.0;
        height = 90.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewMain.tag = QueryMessage;
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        xPos = 0.0;
        yPos = 0.0;
        width = viewMain.frame.size.width - 30.0;
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        textView.returnKeyType = UIReturnKeyDone;
        textView.delegate = self;
        textView.text = [self setPlaceHolderWithqueryType:QueryMessage];
        textView.textColor = [UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0];
        textView.font = [[Configuration shareConfiguration] yoReferFontWithSize:15.0];
        [viewMain addSubview:textView];
        height = viewMain.frame.size.height;
        width = 30.0;
        xPos = viewMain.frame.size.width - width;
        yPos = roundf((viewMain.frame.size.height - height)/2);
        UIView *crossView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [crossView setHidden:YES];
        [crossView setBackgroundColor:[UIColor clearColor]];
        [viewMain addSubview:crossView];
        UITapGestureRecognizer *clearGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearGestureTapped:)];
        [crossView addGestureRecognizer:clearGesture];
        width =14.0;
        height = 14.0;
        xPos = 0.0;
        yPos = roundf((crossView.frame.size.height - height)/2);
        UIImageView *crossImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [crossImg setImage:crossIconImg];
        [crossView addSubview:crossImg];
    }else  if (indexPath.row == QueryAsk)
    {
        xPos = 10.0;
        yPos = 10.0;
        height = 90.0;
        width = frame.size.width - 20.0;
        UIView *viewMain = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        viewMain.tag = QueryAsk;
        viewMain.backgroundColor = [UIColor clearColor];
        viewMain.layer.cornerRadius = 5;
        viewMain.layer.masksToBounds = YES;
        [self.contentView addSubview:viewMain];
        yPos = 10.0;
        width = frame.size.width - 20.0;
        height = 45.0;
        xPos = (viewMain.frame.size.width - width)/2;
        UIButton *ask = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [ask setTitle:kQueryAsk forState:UIControlStateNormal];
        [ask addTarget:self action:@selector(askButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [ask setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
        [ask.layer setCornerRadius:20.0];
        [ask.layer setMasksToBounds:YES];
        [ask.layer setBorderWidth:2.0];
        [ask.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        ask.titleLabel.font = [[Configuration shareConfiguration] yoReferBoldFontWithSize:18.0];
        [viewMain addSubview:ask];
    }
}
- (UITextField *)createTextFiledWithFrame:(CGRect)frame queryType:(QueryType)queryType text:(NSString *)text
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:(queryType == QueryLocation)?[UIColor clearColor]:[UIColor whiteColor]];
    [textField setTag:queryType];
    [textField setDelegate:self];
    [textField setAutocorrectionType:UITextAutocorrectionTypeYes];
    [textField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [textField setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [textField.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:0.0];
    [textField.layer setMasksToBounds:YES];
    [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setTextAlignment:(queryType == QueryLocation)?NSTextAlignmentCenter:NSTextAlignmentLeft];
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self setPlaceHolderWithqueryType:queryType] attributes:@{NSForegroundColorAttributeName: (queryType == QueryLocation)?[UIColor whiteColor]:[UIColor lightGrayColor]}];
    }else
    {
    }
    [textField setTextColor:(queryType == QueryLocation)?[UIColor whiteColor]:[UIColor blackColor]];
    [textField setText:text];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 4.0, textField.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftView;
    [textField setKeyboardType:UIKeyboardTypeDefault];
    return textField;
}

- (NSString *)setPlaceHolderWithqueryType:(QueryType)queryType
{
    NSString *string = nil;
    
    switch (queryType) {
        case QueryLocation:
            string = @"Select Location";
            break;
        case QueryMessage:
            string = @"Please type a short message on what you are looking for ... ";
            default:
            break;
    }
    return NSLocalizedString(string, @"");
}


#pragma mark - Textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(TextFieldWithAnimation:textField:)])
    {
        [self.delegate TextFieldWithAnimation:YES textField:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == QueryLocation)
    {
        if ([self.delegate respondsToSelector:@selector(textfieldshouldChangeCharactersWithTextField: string:)])
        {
            [self.delegate textfieldshouldChangeCharactersWithTextField:textField string:string];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(TextFieldWithAnimation:textField:)])
    {
        [self.delegate TextFieldWithAnimation:NO textField:textField];
    }

}

#pragma mark - TextView delegate

- (void)textViewDidEndEditing:(UITextView * _Nonnull)textView
{
    [textView resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(TextViewdWithAnimation:textView:)])
    {
        [self.delegate TextViewdWithAnimation:NO textView:textView];
    }
    [self enableClearButton:YES isClearText:NO];
    if ([textView.text  isEqual: @""])
    {
        textView.text = NSLocalizedString(kQueryMessagePlaceHolder, @"");
        [textView setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]];
        textView.text = @"";
    }
    if ([self.delegate respondsToSelector:@selector(queryWithMessage:)])
    {
        [self.delegate queryWithMessage:([textView.text isEqualToString:kQueryMessagePlaceHolder])?@"":textView.text];
    }
    
}

- (void)textViewDidBeginEditing:(UITextView * _Nonnull)textView
{
    if ([self.delegate respondsToSelector:@selector(TextViewdWithAnimation:textView:)])
    {
        [self.delegate TextViewdWithAnimation:YES textView:textView];
    }
    ([textView.text length] > 0)?[self enableClearButton:NO isClearText:NO]:[self enableClearButton:YES isClearText:NO];
    if ([textView.text isEqualToString:kQueryMessagePlaceHolder])
    {
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView * _Nonnull)textView
{
    if ([textView.text  isEqual: @""])
    {
        textView.text = NSLocalizedString(kQueryMessagePlaceHolder, @"");
        [textView setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]];
    }
    [self enableClearButton:YES isClearText:NO];
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView * _Nonnull)textView
{
    if ([textView.text isEqualToString:kQueryMessagePlaceHolder])
    {
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    [self enableClearButton:NO isClearText:NO];
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        if ([textView.text  isEqual: @""]) {
            textView.text = NSLocalizedString(kQueryMessagePlaceHolder, @"");
            [textView setTextColor:[UIColor colorWithRed:(255.0/255.0) green:(99.0/255.0) blue:(71.0/255.0) alpha:1.0]];
            [self enableClearButton:YES isClearText:NO];
        }
        return NO;
    }
    return YES;
}

- (void)enableClearButton:(BOOL)isEnable isClearText:(BOOL)isClearText
{
    NSArray *subViews = [[[[self getTableView] subviews] objectAtIndex:0] subviews];
    if ([subViews count] > 0)
    {
        for (QueryTableViewCell  * cell in subViews)
        {
            NSArray *cellSubViews = [cell subviews];
            if ([cellSubViews count] > 0)
            {
                NSArray *subView = [[[cell subviews] objectAtIndex:0] subviews];
                if ([subView count] > 0)
                {
                    UIView *view = [subView objectAtIndex:0];
                    
                    if (view.tag == QueryMessage)
                    {
                        NSArray * subViews = [view subviews];
                        if (isClearText)
                            [(UITextView *)[subViews objectAtIndex:0] setText:@""];
                        [(UIView *)[subViews objectAtIndex:1] setHidden:isEnable];
                    }
                    
                }
            }
        }
    }
}

- (UITableView *)getTableView
{
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO)
    {
        view = [view superview];
    }
    UITableView *superView = (UITableView *)view;
    return superView;
}
#pragma mark - Button delegate
- (IBAction)locationBtnTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(enableLocationWithButton:)])
    {
        [self.delegate enableLocationWithButton:(UIButton *)sender];
    }
}
- (IBAction)addressBtnTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(locationSearchWithButton:)])
    {
        [self.delegate locationSearchWithButton:(UIButton *)sender];
    }
}

- (IBAction)categoryButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(categoriesWithButton:)])
    {
        [self.delegate categoriesWithButton:(UIButton *)sender];
    }
}

- (void)clearGestureTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self enableClearButton:YES isClearText:YES];
}

- (IBAction)askButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(postQuery)])
    {
        [self.delegate postQuery];
    }
}

#pragma mark - GestureRecognizer
- (void)placeMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(placeWithSpuerView:)])
    {
        [self.delegate placeWithSpuerView:[gestureRecognizer.view superview]];
    }
}

- (void)productMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(productWithSpuerView:)])
    {
        [self.delegate productWithSpuerView:[gestureRecognizer.view superview]];
    }
}

- (void)serviceMark:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(serviceWithSpuerView:)])
    {
        [self.delegate serviceWithSpuerView:[gestureRecognizer.view superview]];
    }
}


#pragma mark -
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
