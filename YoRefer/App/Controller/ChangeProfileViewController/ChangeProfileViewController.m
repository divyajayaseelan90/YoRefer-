//
//  ChangeProfileViewController.m
//  YoRefer
//
//  Created by SELMA  on 15/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "ChangeProfileViewController.h"
#import "UserManager.h"
#import "YoReferMedia.h"
#import "YoReferAPI.h"
#import "Utility.h"
#import "Helper.h"
#import "NIDropDown.h"
#import "DocumentDirectory.h"
#import "LazyLoading.h"
#import "UIManager.h"
#import "BBImageManipulator.h"

CGFloat     const kImageWidth               = 80.0;
CGFloat     const kImageHeight              = 80.0;
NSInteger   const profileTag                = 8000;
NSInteger   const backGroundImage           = 90000;
NSInteger   const kLocationAddressTag       = 11000;
NSInteger   const kUpdateProfilePicture     = 12000;
NSInteger   const kNameTag                  = 11023;
NSString *  const kProfile                  = @"Profile";

@interface ChangeProfileViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,Media,UITextFieldDelegate,NIDropDownDelegate,UIScrollViewDelegate>{
    NSString *kPointy, *city, *locality, *name, *dp;
    float lat, lng;
    BOOL singleTapScaled;

}

@property (nonatomic, strong) NIDropDown    * nIDropDown;
@property (strong, nonatomic) UIView  *dropDownViews;
@property (nonatomic, readwrite) BOOL    isRemoveProfileImage,isCancel;
@property (nonatomic,readwrite)  CGFloat               shiftForKeyboard,isPoint;
@property (nonatomic, strong) NSString *referAddress;
@property (nonatomic, readwrite) NSString              *textFieldText;
@property (nonatomic, strong) UIImageView *profileImage;

@end

@implementation ChangeProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Change Profile";
    [self profileView];
    self.isRemoveProfileImage = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:@"locationupdating" object:nil];
    // Do any additional setup after loading the view.
}

- (CGRect)bounds
{
    
    return [[UIScreen mainScreen] bounds];
    
}

- (void)profileView
{
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = [self bounds].size.width;
    CGFloat height = [self bounds].size.height/2;
    UIView *view = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor clearColor]];
    self.tableView.tableHeaderView = view;
    self.tableView.tableFooterView = [UIView new];
    
    //image view
    xPos = 0.0;
    yPos = 0.0;
    width = [self bounds].size.width;
    height = view.frame.size.height/2;
    UIView *imageView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor grayColor]];
    
    yPos = 0.0;
    UIImageView *backGroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    backGroundImg.tag = backGroundImage;
    
    if ([[UserManager shareUserManager] dp] != nil && [[[UserManager shareUserManager] dp] length] > 0)
    {
        
        dp = [[UserManager shareUserManager] dp];
        
        NSArray *arrayBackGround = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
        
        NSString *imageNameBackground = [arrayBackGround objectAtIndex:[arrayBackGround count]-1];
        
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageNameBackground]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:backGroundImg path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageNameBackground]];
            
        }else if ([arrayBackGround count] > 1){
            
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[UserManager shareUserManager] dp]] imageView:backGroundImg];
        }

    }
    
    
    [imageView addSubview:backGroundImg];
    
    [self visualEffectWithImageView:backGroundImg];
    
    
    xPos = imageView.frame.size.width/2-kImageWidth/2;
    yPos = imageView.frame.size.height/4-15;
    width = kImageWidth;
    height = imageView.frame.size.height-yPos;
    
    UIView *profileView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor clearColor]];
    [imageView addSubview:profileView];
    UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
    [profileView addGestureRecognizer:profileGestureRecognizer];
    

    
    //edit label
    xPos = 0.0;
    yPos = profileView.frame.size.height - 30.0;
    width = profileView.frame.size.width;
    height = 30.0;
    UILabel *editLbl=[self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:@"Edit"];
    [profileView addSubview:editLbl];
    
    UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos-10, width, height)];
    [editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [editBtn setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [editBtn.layer setCornerRadius:15.0];
    [editBtn.layer setMasksToBounds:YES];
    [editBtn.layer setBorderWidth:2.0];
    [editBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [editBtn addTarget:self action:@selector(profileViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    [profileView addSubview:editBtn];

    
    
    
    //profile name
    xPos = 20.0;
    yPos = imageView.frame.origin.y + imageView.frame.size.height;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *profileNameView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:profileNameView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = profileNameView.frame.size.width;
    height = profileNameView.frame.size.height;
    UITextField *nameTxtField = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:[NSString stringWithFormat:@"%@",[[[UserManager shareUserManager]name] capitalizedString]]placeHolderText:@"Name"];
    nameTxtField.returnKeyType = UIReturnKeyDone;
    nameTxtField.tag = kNameTag;
    name = [NSString stringWithFormat:@"%@",[[UserManager shareUserManager]name]];
    [profileNameView addSubview:nameTxtField];
    
    xPos = profileNameView.frame.origin.x;
    yPos = profileNameView.frame.origin.y+profileNameView.frame.size.height;
    NSLog(@"%f",yPos);
    width = profileNameView.frame.size.width;
    height = 2.0;
    UIView *lineView1 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView1];
    
    //location
    xPos = 20.0;
    yPos = lineView1.frame.origin.y+lineView1.frame.size.height;
    width = [self bounds].size.width-2*20;
    height = 40.0;
    UIView *locationView = [self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor whiteColor]];
    [view addSubview:locationView];
    
    xPos = 0.0;
    yPos = 0.0;
    width = locationView.frame.size.width;
    height = locationView.frame.size.height;
  
    /*
    UITextField *locationAddress = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:([[UserManager shareUserManager] currentCity] != nil && [[[UserManager shareUserManager] currentCity] length] >0)?[[UserManager shareUserManager] currentCity]:@""placeHolderText:@"Location"];

    locationAddress.returnKeyType = UIReturnKeySearch;

    
    
    if ([[UserManager shareUserManager] currentCity] != nil && [[[UserManager shareUserManager] currentCity] length] >0)
    {
        
        self.referAddress = [[UserManager shareUserManager] currentCity];
        self.textFieldText = [[UserManager shareUserManager] currentCity];
    }
    */
    
    UITextField *locationAddress = [self createTextFieldWithFrame:CGRectMake(xPos, yPos, width, height) text:([[UserManager shareUserManager] city] != nil && [[[UserManager shareUserManager] city] length] >0)?[[UserManager shareUserManager]city]:@""placeHolderText:@"Location"];
    
    locationAddress.returnKeyType = UIReturnKeySearch;

    
    if ([[UserManager shareUserManager] city] != nil && [[[UserManager shareUserManager] city] length] >0)
    {
        
        self.referAddress = [[UserManager shareUserManager] city];
        self.textFieldText = [[UserManager shareUserManager] city];
    }

    
    [locationAddress setTag:kLocationAddressTag];
    [locationAddress setPlaceholder: NSLocalizedString(@"Location", @"")];
    [locationView addSubview:locationAddress];
    
    xPos = locationView.frame.origin.x;
    yPos = locationView.frame.origin.y+locationView.frame.size.height;
    width = locationView.frame.size.width;
    height = 2.0;
    UIView *lineView2 =[self createViewWithFrame:CGRectMake(xPos, yPos, width, height) color:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [view addSubview:lineView2];
    
    xPos = 0.0;
    yPos = 0.0;
    width = kImageWidth;
    height = kImageHeight;
    
    _profileImage=[[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    
    if ([[UserManager shareUserManager] dp] != nil && [[[UserManager shareUserManager] dp] length] > 0)
    {
        
        dp = [[UserManager shareUserManager] dp];
        
        NSArray *array = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
        
        NSString *imageName = [array objectAtIndex:[array count]-1];
        
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
            
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:_profileImage path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
            
        }else if ([array count] > 1){
            
            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:[[UserManager shareUserManager] dp]] imageView:_profileImage];
        }else
        {
            [_profileImage setImage:[UIImage imageNamed:@"icon_userprofile.png"]];
        }
    }else
    {
        [_profileImage setImage:[UIImage imageNamed:@"icon_userprofile.png"]];
    }
    
    [_profileImage.layer setCornerRadius:40.0];
    [_profileImage.layer setMasksToBounds:YES];
    [_profileImage setBackgroundColor:[UIColor clearColor]];
    _profileImage.tag=profileTag;
    [profileView addSubview:_profileImage];
    
    //update button
    xPos = [self bounds].size.width/3;
    yPos = lineView2.frame.origin.y+lineView2.frame.size.height+20.0;
    width = [self bounds].size.width/3;
    height = 40.0;
    UIButton *updateBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    [updateBtn setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [updateBtn.layer setCornerRadius:20.0];
    [updateBtn.layer setMasksToBounds:YES];
    [updateBtn.layer setBorderWidth:2.0];
    [updateBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [updateBtn addTarget:self action:@selector(updateProfileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:updateBtn];
    
    [view addSubview:imageView];

}

-(void)zoomImage:(UITapGestureRecognizer*) gesture{
    NSData *milestoneImageData = UIImagePNGRepresentation(_profileImage.image);
    NSData *noImageData = UIImagePNGRepresentation([UIImage imageNamed:@"no_image"]);
    NSData *loadingImageData = UIImagePNGRepresentation([UIImage imageNamed:@"loading"]);
    if (![milestoneImageData isEqual:noImageData] && ![milestoneImageData isEqual:loadingImageData]) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        BBImageManipulator *controller = [BBImageManipulator loadController:_profileImage.image];
//        [controller setRotatableByButton:YES];
        [controller setZoomable:YES];
        [controller setDoubleTapZoomable:YES];
        [controller setupUIAndGestures];
        [self.view addSubview:controller];
    }
}

- (void)updateLocation
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self locationUpdate];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
}

- (void)locationUpdate:(NSNotification *)notification
{
    [self.dropDownViews removeFromSuperview];
    
    UIView *view = [self.view viewWithTag:kLocationAddressTag];
    
    
    self.referAddress = [[UserManager shareUserManager] currentCity];
    self.textFieldText = [[UserManager shareUserManager] currentCity];
    if ([[UserManager shareUserManager] getLocationService])
    {
        if ([[[notification valueForKey:@"userInfo"] valueForKey:@"locationUpdated"] boolValue])
        {
            if (view.tag == kLocationAddressTag)
            {
                [(UITextField *)view setText:[[UserManager shareUserManager] currentCity]];
                [(UITextField *)view resignFirstResponder];
                
            }
            
        }else
        {
            [self currentLocation];
        }
    }else
    {
        if (view.tag == kLocationAddressTag)
        {
            [(UITextField *)view setText:[[UserManager shareUserManager] currentCity]];
            [(UITextField *)view resignFirstResponder];
            
        }
    }
    [self hideHUD];
}


- (void)visualEffectWithImageView:(UIImageView *)imageView{
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = imageView.bounds;
    [imageView addSubview:visualEffectView];
    
}

- (UIView *)createViewWithFrame:(CGRect)frame color:(UIColor *)color
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:color];
    return view;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    label.text = NSLocalizedString(text, @"");
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 3;
    return label;
    
}

- (UITextField *)createTextFieldWithFrame:(CGRect)frame text:(NSString *)text placeHolderText:(NSString *)placeHolderText
{
    
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    //[textField setReturnKeyType:UIReturnKeyDone];
    textField.delegate = self;
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setPlaceholder:placeHolderText];
    [textField setText:text];
    return textField;
    
}

#pragma mark - Zoom Profile Image

-(BOOL) isImageZoomed {
    
    if ((CGRectGetMaxX(_profileImage.frame) > CGRectGetMaxX(self.view.frame)) || (CGRectGetMaxY(_profileImage.frame) > CGRectGetMaxY(self.view.frame)) || (CGRectGetMinX(_profileImage.frame) < self.view.frame.origin.x) || (CGRectGetMinY(_profileImage.frame) < self.view.frame.origin.y)) {
        return YES;
    }
    return NO;
}

- (void)profileImageTapped:(UITapGestureRecognizer *)gestureRecognizer
{

    if ([self isImageZoomed]) {
        singleTapScaled = YES;
    }
    
    if (!singleTapScaled) {
        // Scaling up by 2 on first double tap
        
        CGFloat scale = 4;
        
        CGFloat xPos = 0.0;
        CGFloat yPos = 0.0;
        CGFloat width = kImageWidth;
        CGFloat height = kImageHeight;
        
        _profileImage.frame = CGRectMake(xPos, yPos+100, width, height);
        
        CGAffineTransform currentTransform = _profileImage.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
        [_profileImage setTransform:newTransform];
        [_profileImage setBackgroundColor:[UIColor greenColor]];
        
        singleTapScaled = YES;
    } else {
        // This executes either on a second double tap or a double tap on a zoomed image.
        // Resetting the Transform and setting the imageView back to original size.
        singleTapScaled = NO;
    }

}


#pragma mark - Action Sheet

- (void)profileViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    UIActionSheet *popup = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(kProfile, @"") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Change Picture",@"Remove Picture", nil];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[YoReferMedia shareMedia]setMediaWithDelegate:self title:@"Select Picture"];
            break;
        case 1:
            alertView(@"Profile", @"Do you want to remove picture?", self, @"Yes", @"No", profileTag);
            break;
            
        default:
            break;
    }
}



#pragma mark - Protocol

- (void)getProfilePicture:(NSMutableDictionary *)profilePicture
{
    
    [(UIImageView *)[self.view viewWithTag:profileTag] setImage:[profilePicture objectForKey:@"image"]];
    
    [(UIImageView *)[self.view viewWithTag:backGroundImage] setImage:[profilePicture objectForKey:@"image"]];
    
    [self visualEffectWithImageView:(UIImageView *)[self.view viewWithTag:backGroundImage]];
    
    
}


#pragma mark - Alert View delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            if (alertView.tag == kUpdateProfilePicture)
            {
                
               // [[UIManager sharedManager]goToMePageWithAnimated:YES];
                [self hideHUD];
                //[self.navigationController popViewControllerAnimated:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"homeprofileupdated" object:self userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"meprofileupdated" object:self userInfo:nil];
               
                
                
            }else
            {
                
                [(UIImageView *)[self.view viewWithTag:profileTag] setImage:[UIImage imageNamed:@"icon_userprofile.png"]];
                
                [(UIImageView *)[self.view viewWithTag:backGroundImage] setImage:nil];
                
                self.isRemoveProfileImage = YES;
                dp = nil;
               
                
            }
           
            
            break;
            
        case 1:
            
            break;
            
        default:
            
            break;
            
    }
}

- (void)setTextBar:(UITextField *)searchbar
{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTapped:)],
                           nil];
    [numberToolbar sizeToFit];
    searchbar.inputAccessoryView = numberToolbar;
    
    
}

- (IBAction)cancelButtonTapped:(id)sender
{
    self.isCancel = YES;
    
    [self.view endEditing:YES];
    
    UIView *view = [self.view viewWithTag:kLocationAddressTag];
    
    if (view.tag == kLocationAddressTag)
    {
        [(UITextField *)view setText:self.referAddress];
    }

    
}

-(void)animateTextField:(UITextField*)textField isUp:(BOOL)isUp
{
    
    if (isUp)
    {
        CGRect textFieldRect =
        [self.view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect =
        [self.view.window convertRect:self.view.bounds fromView:self.view];
        
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator =
        midline - viewRect.origin.y
        - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator =
        (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
        * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        
        UIInterfaceOrientation orientation =    [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            self.shiftForKeyboard = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction) + 40.0;
        }
        else
        {
            self.shiftForKeyboard = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction) + 40.0;
        }
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= self.shiftForKeyboard;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
        for (id navigBar in [self.view subviews])
        {
            if ([navigBar isKindOfClass:[UINavigationBar class]])
            {
                [self.view bringSubviewToFront:navigBar];
            }
        }
        
        
        
    }else
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += self.shiftForKeyboard;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
    }
    
}


#pragma mark - Textfiled delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    [self animateTextField:textField isUp:YES];
    
    //[self setTextBar:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    id view = [self.view superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        
        view = [view superview];
    }
    
    UITableView *superView = (UITableView *)view;
    CGPoint center = textField.center;
    CGPoint point = [textField.superview convertPoint:center toView:superView];
    kPointy = [NSString stringWithFormat:@"%f",point.y];
    
    if ([self.textFieldText length] - 2 == [textField.text length] && [self.textFieldText length] > 0 && [string length] <= 0)
    {
        
        textField.text = @"";
        [self.dropDownViews removeFromSuperview];
        self.nIDropDown = nil;
        
    }
    
    if (textField.tag == kNameTag) {
        
       // name = textField.text;
        
    }else{
        if ([textField.text length] > 3)
        {
            
            CGPoint center = textField.center;
            CGPoint point = [textField.superview convertPoint:center toView:self.view];
            self.isPoint = point.y;
            [self LocationSeacrch:textField];
        }
    }
    
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    if (textField.tag == 11000)
    {
        if ([textField.text length] > 3)
        {
            CGPoint center = textField.center;
            CGPoint point = [textField.superview convertPoint:center toView:self.view];
            self.isPoint = point.y;
            [self LocationSeacrch:textField];
        }
    }
    
    UIView *view = [self.view viewWithTag:kLocationAddressTag];
    
    if (view.tag == kLocationAddressTag)
    {
        [(UITextField *)view setText:self.referAddress];
    }

    
    
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self.dropDownViews removeFromSuperview];
    self.nIDropDown = nil;
    
    [self animateTextField:textField isUp:NO];
    
    if (textField.tag == kNameTag && self.isCancel)
    {
        self.isCancel = NO;
        textField.text = name;
        
        
    }else if (textField.tag == kNameTag){
        
         name = textField.text;
        
    }
    
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
-(void)LocationSeacrch:(UITextField *)textField
{
    
    if ([textField.text length] > 0 && textField.text != nil)
    {
        
        NSString *placeURL=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@&types=(cities)",textField.text,@"AIzaSyBZokl35NK2BIpKpnFB97PIyvlSOKng9E0"];
        
        NSLog(@"placeURl=%@",placeURL);
        
        
        NSURL *url = [NSURL URLWithString:[placeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        dispatch_queue_t imageQueue = dispatch_queue_create("Place Queue",NULL);
        
        dispatch_async(imageQueue, ^{
            
            NSData *getData = [NSData dataWithContentsOfURL:url];
            
            NSString *strResponse;
            strResponse=[[NSString alloc]initWithData:getData encoding:NSStringEncodingConversionAllowLossy];
            
            
            if (!strResponse) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strResponse dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
                
                if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                    
                    [self.dropDownViews removeFromSuperview];
                    self.nIDropDown = nil;
                    if ([[jsonObject valueForKey:@"predictions"] count]) {
                        
                        [self autoSuggestLocationArray:[jsonObject valueForKey:@"predictions"]];
                    }
                }
            });
            
        });
    }else
    {
        
        
        
    }
    
    
}

-(void)autoSuggestLocationArray:(NSMutableArray *)_locationArray
{
    NSArray * arrImage = [[NSArray alloc] init];
    
    if(self.nIDropDown == nil) {
        
        UIView *view = [self.view viewWithTag:kLocationAddressTag];
        self.dropDownViews = [[UIView alloc]initWithFrame:CGRectMake(view.frame.origin.x, self.isPoint + 10.0, view.frame.size.width + 2*20, 230.0)];
        [self.dropDownViews setBackgroundColor:[UIColor clearColor]];
        UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, self.dropDownViews.frame.size.width - 20.0, self.dropDownViews.frame.size.height)];
        CGRect btnFrame=locationBtn.frame;
        [locationBtn setBackgroundColor:[UIColor clearColor]];
        btnFrame.origin.y=0.0;
        btnFrame.origin.x = 0.0;
        btnFrame.size.height=0.0;
        locationBtn.frame=btnFrame;
        locationBtn.backgroundColor=[UIColor clearColor];
        
//        CGFloat f = ([UIScreen mainScreen].bounds.size.height > 480.0)?([UIScreen mainScreen].bounds.size.height > 568.0)?220.0:182.0:66.0;
        
        CGFloat f = 230.0;//([UIScreen mainScreen].bounds.size.height > 480)?164.0:102.0;
        
        self.nIDropDown = [[NIDropDown alloc]showDropDown:locationBtn :f :_locationArray :arrImage :@"down" type:YES];
        self.nIDropDown.delegate = self;
        [self.dropDownViews addSubview:self.nIDropDown];
        [self.view addSubview:self.dropDownViews];
        
        
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}

-(void)rel
{
    self.nIDropDown = nil;
}

- (void)getLoaction:(NSDictionary *)location
{
    
    [self.dropDownViews removeFromSuperview];
    
    UIView *view = [self.view viewWithTag:kLocationAddressTag];
    
    if (view.tag == kLocationAddressTag)
    {
        [(UITextField *)view setText:[location objectForKey:@"description"]];
        [(UITextField *)view resignFirstResponder];
        
    }
    
    self.referAddress = [location objectForKey:@"description"];
    self.textFieldText = [location objectForKey:@"description"];
//    
//    [[UserManager shareUserManager]setReferAddress:[location objectForKey:@"description"]];
//    [[UserManager shareUserManager] setAddress:[location objectForKey:@"description"]];
//    [[UserManager shareUserManager] setCurrentCity:[location objectForKey:@"description"]];
    
    [self getCurrentLatLongFromPlaceId:[location objectForKey:@"place_id"]];
    
    
}

- ( void)getCurrentLatLongFromPlaceId:(NSString *)placeId
{
    
    
    NSString *placeURL=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyBZokl35NK2BIpKpnFB97PIyvlSOKng9E0",placeId];
    
    NSURL *url = [NSURL URLWithString:[placeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    dispatch_queue_t imageQueue = dispatch_queue_create("Place Queue",NULL);
    
    dispatch_async(imageQueue, ^{
        
        NSData *getData = [NSData dataWithContentsOfURL:url];
        
        NSString *strResponse;
        strResponse=[[NSString alloc]initWithData:getData encoding:NSStringEncodingConversionAllowLossy];
        
        if (!strResponse) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strResponse dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
            
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                
//                [[UserManager shareUserManager]setLatitude:[NSString stringWithFormat:@"%@",[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"]]];
//                [[UserManager shareUserManager]setLongitude:[NSString stringWithFormat:@"%@",[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"]]];
//                
                
                NSString  *localCoordinates=[NSString stringWithFormat:@"%.2f,%.2f",[[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"] floatValue],[[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"] floatValue]];
                lat = [[NSString stringWithFormat:@"%@",[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"]] floatValue];
                lng = [[NSString stringWithFormat:@"%@",[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"]] floatValue];
                
                city = [[jsonObject valueForKey:@"result"] valueForKey:@"name"];
                
                [self getAddressFromLocationString:localCoordinates CompletionHandler:^(NSString *address)
                {
                    locality = address;
                    
                }];
            }
            
        });
        
    });
    
    
    
}

-(void)getAddressFromLocationString:(NSString *)_latlonStr CompletionHandler:(void(^)(NSString * address))CompletionHandler
{
    [[YoReferAPI sharedAPI] getLocationDetailWithParma:_latlonStr CompletionHandler:^(NSDictionary *dictionary , NSError * error)
    {
        NSString *address=@"";
        if (dictionary)
        {
            if ([[dictionary valueForKey:@"results"] count]) {
                address=[[[dictionary valueForKey:@"results"] objectAtIndex:0] valueForKey:@"formatted_address"];
            }

            if ([[dictionary valueForKey:@"results"] count] > 0)
            {
                if ([[[[dictionary valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] count] > 7 )
                {
                    
                    // NSString *cityName = [[[[[jsonObject valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] objectAtIndex:4] objectForKey:@"long_name"];
                    
                    NSString *countryName = [[[[[dictionary valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] objectAtIndex:6] objectForKey:@"long_name"];
                    
                    
                    //   [[UserManager shareUserManager] setCurrentCity:cityName];
                    [[UserManager shareUserManager] setCurrentCountry:countryName];
                    
                }
                
                
            }


        }
        CompletionHandler(address);
    }];
    
}


- (IBAction)updateProfileButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
     [self showHUDWithMessage:@""];
    
    if([(UIImageView *)[self.view viewWithTag:backGroundImage] image])
    {
        
        [self updateProfilePicture];
        
    }
    else
    {
        
        [self updateNameAndLocation];
        
    }
    
}

- (void)updateProfilePicture
{
    
    UIImage *scaleImage = [[Helper shareHelper] scaleImage:[(UIImageView *)[self.view viewWithTag:profileTag] image] toSize:CGSizeMake(320.0,320.0)];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
    [param setValue:scaleImage forKey:@"profileImage"];
    
    [[YoReferAPI sharedAPI] uploadImageWithParam:param completionHandler:^(NSDictionary *response , NSError *error)
     {
         [self didReceiveWithImageResponse:response error:error];
         
     }];
    
}

- (void)didReceiveWithImageResponse:(NSDictionary *)response error:(NSError *)error
{
    
   
    
    if (error != nil)
    {
         [self hideHUD];
        
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }
        
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
         [self hideHUD];
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else
    {
      
        dp = [response objectForKey:@"response"];
        
        self.isRemoveProfileImage = YES;
        
        [self updateNameAndLocation];
        
    }
    
    
}


- (void)updateNameAndLocation
{
    NSArray *arrayLatLng = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%f",lat],[NSString stringWithFormat:@"%f",lng], nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:name forKey:@"name"];
    [params setValue:locality forKey:@"locality"];
    [params setValue:arrayLatLng forKey:@"latlong"];
    [params setValue:self.referAddress forKey:@"city"];
    [params setValue:(dp !=nil && [dp length] >0)?dp:@"" forKey:@"dp"];
    
    [[YoReferAPI sharedAPI] changeProfileWithParams:params completionHandler:^(NSDictionary *response ,NSError *error){
        
        [self didReceiveProfileUpdateWithResponse:response error:error];
        
    }];
    
}


- (void)didReceiveProfileUpdateWithResponse:(NSDictionary *)resonse error:(NSError *)error
{
    
    if (error != nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
             [self hideHUD];
            
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            
            
        }
        
    }else if ([[resonse objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
         [self hideHUD];
        
        [[UserManager shareUserManager]logOut];
        
        return;
        
        
    }else if ([[resonse valueForKey:@"code"] isEqualToString:@"1000"]) {
        
        if (dp != nil && [dp length] > 0 && self.isRemoveProfileImage)
        {
            
            NSArray *arrayBackGround = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
            NSString *imageName = [NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],[arrayBackGround objectAtIndex:[arrayBackGround count]-1]] ;
            [[DocumentDirectory shareDirectory] removeImageFromDirectoryWithPath:imageName];
            [[UserManager shareUserManager] setDp:@""];
            
            
        }else  if (self.isRemoveProfileImage)
        {
            
            NSArray *arrayBackGround = [[[UserManager shareUserManager] dp] componentsSeparatedByString:@"/"];
            NSString *imageName = [NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],[arrayBackGround objectAtIndex:[arrayBackGround count]-1]] ;
            [[DocumentDirectory shareDirectory] removeImageFromDirectoryWithPath:imageName];
            [[UserManager shareUserManager] setDp:@""];
            
        
            
        }
        
        [[UserManager shareUserManager] setDp:dp];
        
        [[UserManager shareUserManager] setName:name];
        
        [[UserManager shareUserManager] setCity:self.referAddress];
        
        [[UserManager shareUserManager] setLocality:locality];
        
        [[UserManager shareUserManager] updateUser];
        
        [self deletDataWithLoginId:[[UserManager shareUserManager] number]];
        
        
        alertView([[Configuration shareConfiguration] appName], NSLocalizedString(@"Profile updated successfully", @""), self, @"Ok", nil, kUpdateProfilePicture);
        
        
    }
}

- (void)deletDataWithLoginId:(NSString *)loginId
{
    //refer
    [[CoreData shareData] deleteReferWithLoginId:loginId];
    //ask
    [[CoreData shareData] deleteAskWithLoginId:loginId];
    //feeds
    NSArray *feedData = @[@"300",@"301",@"302"];
    for (int i = 0; i< feedData.count; i++)
    {
        [[CoreData shareData] deleteFeedsWithLoginId:[[UserManager shareUserManager] number]feedsType:feedData[i]];
    }
    
   // [[CoreData shareData] deleteFeedsWithLoginId:loginId];
    //queries
    [[CoreData shareData] deleteQueriesWithLoginId:loginId];
    //festured
    [[CoreData shareData] deleteFeaturedWithLoginId:loginId];
    
}




//    NSURL *url = [NSURL URLWithString:dp];
//    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
//    [(UIImageView *)[self.view viewWithTag:profileTag] setImage:image];
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
