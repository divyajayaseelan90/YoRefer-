//
//  MapViewController.m
//  YoRefer
//
//  Created by Selma D. Souza on 19/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//
#import "MapViewController.h"
#import "Constant.h"
#import "EntityViewController.h"
#import "ReferNowViewController.h"
#import "Map.h"

NSString    *   const kRadius                    = @"30";
NSString    *   const kRadiusParam               = @"radius";
NSString    *   const mapSearchPlaceHolder       = @"Search places";
NSString    *   const kMapError                  = @"Unable to get carousel";

NSString    *   const kmapSearchPlaceHolder          = @"Search Places, Products or Services";


NSUInteger      const kMapHeaderViewtag          = 60000;
NSUInteger      const kMapSearchBtntag           = 70000;
NSUInteger      const kMapSearchBartag           = 80000;
NSUInteger      const kPinViewTag                = 90000;
NSUInteger      const kBottomViewTag             = 12321;
NSUInteger      const kPageLimit                 = 30;

NSUInteger      const kMapLocationButtonEnableTag    = 13212;
NSUInteger      const kMapLocationButtonDisableTag   = 13213;
NSInteger       const kMapHeaderView                 = 50000;


typedef enum
{
    Offers,
    Search,
    Others
}MapType;

@interface MapViewController ()<MKMapViewDelegate,UISearchBarDelegate,NIDropDownDelegate,Refer, UITextFieldDelegate>

@property (nonatomic, strong)       NSMutableArray              * response;
@property (nonatomic, strong)       NSMutableDictionary         * searchCoordinates;
@property (nonatomic, strong)       NSString                    * searchText,*type,*pinCity,*pinAddress;
@property (nonatomic, strong)       UIView                      * previousView;
@property (nonatomic, strong)       MKMapView                   * mapView;
@property (nonatomic, readwrite)    NSInteger                     currentAnnotation,isPage;
@property (nonatomic, readwrite)    MapType                       mapType;
@property (nonatomic, readwrite)    Map                         * map;
@property (strong, nonatomic)       UIView                      * dropDownView;
@property (nonatomic, strong)       NIDropDown                  * nIDropDown;
@property (nonatomic, readwrite)    BOOL                          isSearch, showMap;
@property (nonatomic ,strong)       NSArray                     * address;
@property (nonatomic ,strong)       NSMutableString             * AddressPass;
@property (nonatomic, strong)       UISearchBar                 * searchBar;
@property (nonatomic, strong)       UIImageView                 * pinImage;
@property (nonatomic, strong)       UIActivityIndicatorView     *activityIndicator;

@property (nonatomic, strong)       UISearchBar                 * searchBar2;
@property (nonatomic, strong)       UITextField *addressTxtField;
@property (nonatomic, strong)       UIView *bottomViewTapped;

@end

@implementation MapViewController
@synthesize delegate = _delegate;
- (instancetype)initWithResponse:(NSMutableArray *)response type:(NSString *)type isCurrentOffers:(BOOL)isCurrentOffers
{
    self = [super init];
    if (self)
    {
        if ([type isEqualToString:@"Others"])
            self.mapType = Others;
        else
            self.mapType = Offers;
        if (isCurrentOffers)
            self.type = @"Location";
        else
            self.type = type;
        self.response = response;
    }
    return self;
}

#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showMap = NO;
    self.isPage = 0;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:[NSArray arrayWithObjects:[self.searchCoordinates objectForKey:kLatitude],[self.searchCoordinates objectForKey:kLongitude], nil] forKey:kLocation];
    self.address = [[UserManager shareUserManager]Path];
    for (int i=0; i<self.address.count; i++)
    {
        if (i == 0)
        {
            self.AddressPass = [NSMutableString stringWithFormat:@"%@",[self.address objectAtIndex:i]];
        }
        else
        {
            self.AddressPass = [NSMutableString stringWithFormat:@"%@,%@",self.AddressPass,[self.address objectAtIndex:i]];
        }
    }
    if (self.mapType == Others)
        [self setCoordinate];
    else
        [self getLocationOffer];
    
    self.tableView.tableFooterView = [UIView new];
    [self mapHeaderView];
    [self bottomView];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:@"locationupdating" object:nil];
}

- (void)bottomView
{
    CGRect frame = [self bounds];
    CGFloat xPos,yPos,width,height;
    xPos = 0.0;
    width = frame.size.width;
    height = 48.0;
    yPos = frame.size.height - (height + 48.0);
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [bottomView setTag:kBottomViewTag];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bottomViewTapped:)];
    [bottomView addGestureRecognizer:gestureRecognizer];
    [self.view addSubview:bottomView];
    xPos = 0.0;
    yPos = 0.0;
    width = bottomView.frame.size.width;
    height = 0.5;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [bottomView addSubview:lineView];
    width = 32.0;
    height = 32.0;
    xPos = 10.0;
    yPos = roundf((bottomView.frame.size.height - height)/2);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [imageView setImage:[UIImage imageNamed:@"icon_menu-up-arrow.png"]];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageView setTintColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
    [bottomView addSubview:imageView];
    xPos = imageView.frame.origin.x + imageView.frame.size.width + 15.0;
    width = frame.size.width - 2 * xPos;
    height = 40.0;
    yPos = roundf((bottomView.frame.size.height - height)/2);
    UILabel *showMap = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [showMap setText: @"Show Map"];
    [showMap setTextColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
    [showMap setFont:[[Configuration shareConfiguration]yoReferFontWithSize:16.0]];
    [bottomView addSubview:showMap];
}


-(void)viewDidLayoutSubviews
{
    CGRect frame  = [self bounds];
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y + 92.0, frame.size.width, frame.size.height - 138.0);
    [self.view layoutIfNeeded];
}


- (void)mapHeaderView
{
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 64.0;
    CGFloat width = frame.size.width;
    CGFloat height = 90.0;
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [searchView setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    [self.view addSubview:searchView];
    
    //===================================
    xPos = 0.0;
    yPos = 0.0;
    width = frame.size.width;
    height = 85.0;
    
    //background View
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = kMapHeaderView;
    [view setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    
    //location view
    xPos = 16.0;
    yPos = 5.0;
    height = round((85.0 - 5)/2) - 10.0;
    width = view.frame.size.width - (xPos * 2);
    
    UIView *locationView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    locationView.backgroundColor = [UIColor clearColor];
    [locationView.layer setBorderWidth:0.6];
    [locationView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [locationView.layer setCornerRadius:5.0];
    [locationView.layer setMasksToBounds:YES];
    [view addSubview:locationView];
    
    
    //downarrow image
    width = 25.0;
    height = 25.0;
    xPos = locationView.frame.size.width - width;
    yPos = round((locationView.frame.size.height - height)/2);
    
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [image setImage:downarraow];
    //    [locationView addSubview:image];
    
    [searchView addSubview:view];
    
    //textfield
    xPos = 0.0;
    yPos = 2.0;
    width = locationView.frame.size.width - image.frame.size.width;
    
    _addressTxtField = [[UITextField alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    _addressTxtField.tag = kMapSearchBartag;
    [_addressTxtField setBackgroundColor:[UIColor clearColor]];
    [_addressTxtField setTextColor:[UIColor whiteColor]];
    [_addressTxtField setReturnKeyType:UIReturnKeySearch];
    [_addressTxtField setDelegate:self];
    [_addressTxtField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [_addressTxtField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_addressTxtField setTextAlignment:NSTextAlignmentCenter];
    [_addressTxtField setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    //    if ([_addressTxtField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
    //        _addressTxtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    //    }else {
    //    }
    [_addressTxtField setText:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@""];
    [locationView addSubview:_addressTxtField];
    
    //======= Second SearchBar ============
    xPos = 16.0;
    yPos = 40.0;
    width = frame.size.width - 2 * xPos;
    height = 40.0;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    self.searchBar.delegate = self;
    self.searchBar.tag = kMapSearchBartag;
    [self.searchBar setPlaceholder:kmapSearchPlaceHolder];
    self.searchBar.userInteractionEnabled = YES;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    [self.searchBar setBarTintColor:[UIColor whiteColor]];
    [self.searchBar setBackgroundColor:[UIColor whiteColor]];
    self.searchBar.layer.cornerRadius = 8.0;
    self.searchBar.layer.masksToBounds = YES;
    [searchView addSubview:self.searchBar];
    
    
    UITextField *searchField;
    NSUInteger numViews = [self.searchBar.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[self.searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
            searchField = [self.searchBar.subviews objectAtIndex:i];
        }
    }
    if(searchField) {
        searchField.textColor = [UIColor redColor];
        //        [searchField setBackground: [UIImage imageNamed:@"yourImage"]];//just add here gray image which you display in quetion
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    
    
    //downarrow button
    xPos = locationView.frame.size.width - image.frame.size.width;
    yPos = 0.0;
    width = 40.0;
    height = 40.0;
    
    UIButton *addressBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [addressBtn setTag:kMapLocationButtonEnableTag];
    [addressBtn setBackgroundColor:[UIColor clearColor]];
    [addressBtn addTarget:self action:@selector(addressBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [searchView addSubview:addressBtn];
    
    //    [self.tableView setTableHeaderView:view];
    
    /*
     if ([self.searchText length] > 0)
     {
     [addressTxtField setText:self.searchText];
     [SearchBarBtn  setHidden:YES];
     [self.searchBar setUserInteractionEnabled:YES];
     
     }else
     {
     [addressTxtField setText:@""];
     [SearchBarBtn  setHidden:YES];
     [self.searchBar setUserInteractionEnabled:YES];
     }
     */
    
    [self reloadTableView];
    
    //    xPos = 0.0;
    //    yPos = 0.0;
    //    width = frame.size.width;
    //    height = 44.0;
    //    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //    [tableHeaderView setBackgroundColor:[UIColor whiteColor]];
    //    self.tableView.tableHeaderView =  tableHeaderView;
    //
    //    xPos = 70.0;
    //    yPos = 0.0;
    //    width = frame.size.width - 2 * xPos;
    //    height = 43.0;
    //    UILabel *showMap = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //    showMap.text = @"Show Map";
    //    showMap.font = [[Configuration shareConfiguration]yoReferFontWithSize:14.0];
    //    [tableHeaderView addSubview:showMap];
    //
    //    xPos = 15.0;
    //    yPos = tableHeaderView.frame.size.height - 0.5;
    //    width = frame.size.width - xPos;
    //    height = 0.5;
    //    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //    [line setBackgroundColor:[UIColor lightGrayColor]];
    //    [tableHeaderView addSubview:line];
    //    UIButton *showMap = [[UIButton alloc]init];
    //    showMap.frame = CGRectMake(xPos, yPos, width, height);
    //    showMap.layer.cornerRadius = 5.0;
    //    [showMap setTitle:@"Show Map" forState:UIControlStateNormal];
    //    [showMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [showMap setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0]];
    //    [tableHeaderView addSubview:showMap];
}

- (IBAction)addressBtnTapped:(id)sender
{
    [self.tableView endEditing:YES];
    UIButton *button = (UIButton *)sender;
    CGRect frame = [[button superview].superview convertRect:[button superview].frame toView:self.view];
    //    [self.homeDetails.homeDetails setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    [self.searchCoordinates setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    
    UIView *view = [self.tableView viewWithTag:kMapHeaderView];
    NSArray *subViews = [[[view subviews] objectAtIndex:0] subviews];
    UITextField *textField = (UITextField *)[subViews objectAtIndex:1];
    if ([textField.text length] > 0 && button.tag == kMapLocationButtonEnableTag)
    {
        textField.text = [textField.text substringToIndex:3];
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                button.tag = kMapLocationButtonDisableTag;
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        button.tag = kMapLocationButtonEnableTag;
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
        if ([[UserManager shareUserManager] getLocationService])
        {
            [(UITextField *)[subViews objectAtIndex:1] setText:[[UserManager shareUserManager] currentCity]];
            //            self.homeDetails.locationText = [[UserManager shareUserManager] currentCity];
            [(UIButton *)[subViews objectAtIndex:2] setHidden:YES];
        }else
        {
            [(UITextField *)[subViews objectAtIndex:1] setText:@""];
            [(UIButton *)[subViews objectAtIndex:2] setHidden:NO];
        }
        
    }
}



- (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setTextColor:[UIColor whiteColor]];
    label.text = NSLocalizedString(text, @"");
    [label setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 4;
    [label sizeToFit];
    return label;
}

- (void)setCoordinate
{
    self.currentAnnotation = 0;
    MKCoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D centre;
    if (self.mapType == Others)
    {
        NSString *currentLatitude;
        if ([[[self.response objectAtIndex:0] valueForKey:kLatitude] isKindOfClass: [NSNumber class]])
            currentLatitude = [NSString stringWithFormat:@"%@",[[self.response objectAtIndex:0] valueForKey:kLatitude]];
        else
            currentLatitude = [[self.response objectAtIndex:0] valueForKey:kLatitude];
        NSString *currentLongitude;
        if ([[[self.response objectAtIndex:0] valueForKey:kLongitude] isKindOfClass: [NSNumber class]])
            currentLongitude = [NSString stringWithFormat:@"%@",[[self.response objectAtIndex:0] valueForKey:kLongitude]];
        else
            currentLongitude = [[self.response objectAtIndex:0] valueForKey:kLongitude];
        centre.latitude = ([currentLatitude length] <= 0)?[[[UserManager shareUserManager] latitude] doubleValue]:[currentLatitude doubleValue];
        centre.longitude = ([currentLongitude length] <= 0)?[[[UserManager shareUserManager] longitude] doubleValue]:[currentLongitude doubleValue];
        double latitude = centre.latitude, longitude = centre.longitude;
        region.center.latitude = latitude;
        region.center.longitude = longitude;
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate = centre;
        point.title = @"sample";
        region.span.longitudeDelta = 0.005f;
        region.span.latitudeDelta =  0.005f;
        [self.mapView addAnnotation:point];
        [self.mapView setRegion:region animated:YES];
    }else
    {
        if([self.response count] !=0)
        {
            Map *map = [self.response objectAtIndex:0];
            CLLocationCoordinate2D upper;
            upper.latitude = [[map.position objectAtIndex:1] doubleValue];
            upper.longitude = [[map.position objectAtIndex:0] doubleValue];
            CLLocationCoordinate2D lower;
            lower.latitude = [[map.position objectAtIndex:1] doubleValue];
            lower.longitude = [[map.position objectAtIndex:0] doubleValue];
            // FIND LIMITS
            for(Map *map in self.response) {
                CLLocationCoordinate2D current;
                current.latitude = [[map.position objectAtIndex:1] doubleValue];
                current.longitude = [[map.position objectAtIndex:0] doubleValue];
                if(current.latitude > upper.latitude) upper.latitude = current.latitude;
                if(current.latitude < lower.latitude) lower.latitude = current.latitude;
                if(current.longitude > upper.longitude) upper.longitude = current.longitude;
                if(current.longitude < lower.longitude) lower.longitude = current.longitude;
            }
            // FIND REGION
            MKCoordinateSpan locationSpan;
            locationSpan.latitudeDelta = 0.02;
            locationSpan.longitudeDelta = 0.02;
            CLLocationCoordinate2D locationCenter;
            locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
            locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
            region = MKCoordinateRegionMake(locationCenter, locationSpan);
            [self.mapView setRegion:region animated:YES];
            [self performSelector:@selector(setAnnotationWithRegion) withObject:nil afterDelay:1.0];
            
            
        }
        else
        {
            centre.latitude = [[self.searchCoordinates objectForKey:kLatitude] doubleValue];
            centre.longitude = [[self.searchCoordinates objectForKey:kLongitude] doubleValue];
            double latitude = centre.latitude, longitude = centre.longitude;
            region.center.latitude = latitude;
            region.center.longitude = longitude;
            MKPointAnnotation *point=[[MKPointAnnotation alloc]init];
            point.coordinate=centre;
            point.title = [self.searchCoordinates objectForKey:kPlace];
            [self.mapView addAnnotation:point];
            region.span.longitudeDelta = 0.05f;
            region.span.latitudeDelta = 0.05f;
            [self.mapView setRegion:region animated:YES];
        }
    }
}

- (void)setAnnotationWithRegion
{
    CLLocationCoordinate2D centre;
    MKCoordinateRegion region = self.mapView.region;
    for (Map *map in self.response)
    {
        centre.latitude = [[map.position objectAtIndex:1] doubleValue];
        centre.longitude = [[map.position objectAtIndex:0] doubleValue];
        double latitude = centre.latitude, longitude = centre.longitude;
        region.center.latitude = latitude;
        region.center.longitude = longitude;
        MKPointAnnotation *point=[[MKPointAnnotation alloc]init];
        point.coordinate=centre;
        point.title = @"sample";
        [self.mapView addAnnotation:point];
    }
    
}


#pragma mark  - TableView datasource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.response.count + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 0)?0.0:136.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.showMap) {
        return self.tableView.frame.size.height;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.previousView = [[UIView alloc]init];
    [self currentLocation];
    self.isSearch = NO;
    CGRect frame = [self bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat width = frame.size.width;
    CGFloat height = self.tableView.frame.size.height - 100.0;
    UIView *mainView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [mainView setBackgroundColor:[UIColor colorWithRed:(63.0/255.0) green:(48.0/255.0) blue:(5.0/255.0) alpha:1.0]];
    
    xPos = 0.0;
    width = frame.size.width;
    height = mainView.frame.size.height;
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    self.mapView.delegate = self;
    if (self.mapType == Others)
    {
        self.mapView.userTrackingMode=NO;
    }
    else
    {
        self.mapView.userTrackingMode=YES;
    }
    self.mapView.userTrackingMode=NO;
    [mainView addSubview:self.mapView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapTapped:)];
    [self.mapView addGestureRecognizer:tap];
    //NSLog(@"%f",self.mapView.frame.size.width - 60.0);
    // NSLog(@"%f",self.mapView.frame.size.height - 30.0);
    xPos = self.mapView.frame.size.width - 40.0;
    yPos = self.mapView.frame.size.height - 60.0;
    width = 30.0;
    height = 30.0;
    UIButton *mapBtn = [[UIButton alloc]init];
    mapBtn.frame = CGRectMake(xPos, yPos, width, height);
    [mapBtn setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0f]];
    [mapBtn setBackgroundImage:locationPin forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(getCurrentLocBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:mapBtn];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
            
        }
    }
    //    CGPoint newPoint = [self.mapView convertCoordinate:self.mapView.centerCoordinate toPointToView:self.view];
    self.pinImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_pin_blue.png"]];
    //    self.pinImage.image = [self.pinImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [self.pinImage setTintColor:[UIColor colorWithRed:(72.0/255.0) green:(167.0/255.0) blue:(244.0/255.0) alpha:1.0]];
    self.pinImage.backgroundColor = [UIColor clearColor];
    self.pinImage.contentMode = UIViewContentModeCenter;
    self.pinImage.center = CGPointMake(self.mapView.center.x, self.mapView.center.y + 104.0);
    //    self.pinImage.layer.shadowColor = [UIColor blackColor].CGColor;
    //    self.pinImage.layer.shadowOffset = CGSizeMake(10, 5);
    //    self.pinImage.layer.shadowRadius = 1.0;
    //    self.pinImage.layer.shadowOpacity = 0.8;
    [self.view addSubview:self.pinImage];
    //[self.pinImage setHidden:YES];
    [self performSelector:@selector(setCoordinate) withObject:nil afterDelay:1.0];
    return mainView;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
    }
    NSArray *subviews = [cell.contentView subviews];
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat height = (indexPath.row == 0)?60.0:136.0;
    CGFloat width = frame.size.width;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    view.tag = indexPath.row;
    [cell.contentView addSubview:view];
    
    if (indexPath.row == 0) {
        //        xPos = 10.0;
        //        yPos = 12.5;
        //        width = 34.0;
        //        height = 35.0;
        //        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        //        imageView.image = (self.showMap)?[UIImage imageNamed:@"icon_menu-up-arrow.png"]:[UIImage imageNamed:@"icon_menu-down-arrow.png"];
        ////        [imageView setTintColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
        //        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        //        [imageView setTintColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
        //        [view addSubview:imageView];
        //
        //        xPos = imageView.frame.origin.x + imageView.frame.size.width + 15.0;
        //        yPos = 0.0;
        //        width = frame.size.width - 2 * xPos;
        //        height = 60.0;
        //        UILabel *showMap = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        //        showMap.text = (self.showMap)?@"Show List":@"Show Map";
        //        showMap.font = [[Configuration shareConfiguration]yoReferFontWithSize:14.0];
        //        [view addSubview:showMap];
        //        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    else
    {
        width = 80.0;
        height = 80.0;
        xPos = 4.0;
        yPos = roundf((view.frame.size.height - height)/2);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [view addSubview:imageView];
        
        Map *map;
        if ([self.response count] > 0 && (self.mapType == Offers || self.mapType == Search))
        {
            map =  (Map *)[self.response objectAtIndex:view.tag - 1];
            
        }else if ([self.response count] >0 && self.mapType == Others)
        {
            if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage] isKindOfClass:[UIImage class]])
            {
                imageView.image = [[self.response objectAtIndex:view.tag - 1] objectForKey:kImage];
                
            }else
            {
                if ([[[self.response objectAtIndex:0] valueForKey:kImage] isKindOfClass:[NSString class]])
                {
                    NSArray *array = [[NSString stringWithFormat:@"%@",[[self.response objectAtIndex:0] valueForKey:kImage]] componentsSeparatedByString:@"/"];
                    NSString *imageName = [array objectAtIndex:[array count]-1];
                    
                    if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && [imageName length] > 0 && [array count] > 1)
                    {
                        [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                    }else
                    {
                        if ([[self.response objectAtIndex:view.tag - 1] isKindOfClass:[Map class]])
                        {
                            [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage]:map.dp] imageView:imageView];
                            
                        }else
                        {
                            if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage] isKindOfClass:[UIImage class]])
                            {
                                imageView.image = [[self.response objectAtIndex:view.tag - 1] objectForKey:kImage];
                                
                            }else
                            {
                                if ([imageName length] > 0)
                                {
                                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage]:map.dp] imageView:imageView];
                                }else
                                {
                                    if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kType] isEqualToString:kPlace])
                                    {
                                        imageView.image = placeImg;
                                        
                                    }else  if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kType] isEqualToString:kProduct])
                                    {
                                        imageView.image = productImg;
                                        
                                    }else  if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kType] isEqualToString:kWeb])
                                    {
                                        imageView.image = webLinkImg;
                                    }else  if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kType] isEqualToString:kService])
                                    {
                                        imageView.image = serviceImg;
                                    }else
                                        imageView.image = noPhotoImg;
                                }
                                
                            }
                            
                        }
                    }
                }
                
            }
        }
        if(map.dp !=nil && [map.dp length] > 0)
        {
            NSArray *array = [[NSString stringWithFormat:@"%@",map.dp] componentsSeparatedByString:@"/"];
            NSString *imageName = [array objectAtIndex:[array count]-1];
            if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
            {
                [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:imageView path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                
            }else
            {
                if ([[self.response objectAtIndex:view.tag - 1] isKindOfClass:[Map class]])
                {
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage]:map.dp] imageView:imageView];
                    
                }else
                {
                    if ([[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage] isKindOfClass:[UIImage class]])
                    {
                        imageView.image = [[self.response objectAtIndex:view.tag - 1] objectForKey:kImage];
                        
                    }else
                    {
                        
                        [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag - 1] objectForKey:kImage]:map.dp] imageView:imageView];
                        
                    }
                }
            }
            
        }else
        {
            if ([map.type isEqualToString:kPlace])
            {
                imageView.image = placeImg;
            }
            else  if ([map.type isEqualToString:kProduct])
            {
                imageView.image = productImg;
                
            }else  if ([map.type isEqualToString:kWeb])
            {
                imageView.image = webLinkImg;
            }
            else  if ([map.type isEqualToString:kService])
            {
                imageView.image = serviceImg;
            }
            else  if ([map.type isEqualToString:kService])
            {
                imageView.image = serviceImg;
            }
            else if ([self.type isEqualToString:@"map"])
                imageView.image = [UIImage imageNamed:@""];
        }
        
        xPos = imageView.frame.size.width + 8.0;
        yPos = 6.0;
        width = view.frame.size.width - (imageView.frame.size.width + 10.0);
        height = 20.0;
        UILabel *categoryName = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [categoryName  setText:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"category"]:[map.entity valueForKey:@"category"]];
        [categoryName setTextColor:(indexPath.row == 1 && self.mapType != Others )?[UIColor blueColor]:[UIColor blackColor]];
        [categoryName setNumberOfLines:0];
        [categoryName sizeToFit];
        [view addSubview:categoryName];
        [categoryName setFont:([self bounds].size.height > 580) ?[[Configuration shareConfiguration] yoReferFontWithSize:15.0]:[[Configuration shareConfiguration] yoReferFontWithSize:11.0]];
        
        xPos = imageView.frame.size.width + 8.0;
        yPos = categoryName.frame.size.height + 10.0;
        width = view.frame.size.width - (imageView.frame.size.width + 20.0);
        height = 20.0;
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [name  setText:(self.mapType == Others)?[[self.response objectAtIndex:0] valueForKey:@"name"]:[map valueForKey:@"name"]];
        [name setFont:([self bounds].size.height > 580) ?[[Configuration shareConfiguration] yoReferBoldFontWithSize:15.0]:[[Configuration shareConfiguration] yoReferBoldFontWithSize:13.0]];
        [name setTextColor:(indexPath.row == 1 && self.mapType != Others)?[UIColor blueColor]:[UIColor blackColor]];
        [name setNumberOfLines:0];
        [name sizeToFit];
        [view addSubview:name];
        
        yPos  = name.frame.origin.y + name.frame.size.height + 4.0;
        UILabel *locality = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [locality setText:(self.mapType == Others)?[[self.response objectAtIndex:0] valueForKey:@"locality"]:map.locality];
        [locality setFont:([self bounds].size.height > 580)?[[Configuration shareConfiguration] yoReferFontWithSize:12.0]:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [locality setNumberOfLines:4];
        //[locality setTextColor:[UIColor lightGrayColor]];
        [locality sizeToFit];
        [locality setTextColor:(indexPath.row == 1 && self.mapType != Others )?[UIColor blueColor]:[UIColor blackColor]];
        [view addSubview:locality];
        
        width = 100.0;
        height = 42.0;
        xPos = view.frame.size.width - width;
        yPos = view.frame.size.height - (height + 6.0);
        UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [view addSubview:   bottomView];
        
        
        height = 38.0;
        width = 100.0;
        xPos = 0.0;
        yPos = round((bottomView.frame.size.height - height)/2);
        UIView *referView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [bottomView addSubview:referView];
        
        UITapGestureRecognizer *referGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(referGestureTapped:)];
        [referView addGestureRecognizer:referGesture];
        
        xPos = referView.frame.size.width;
        UIView *entityView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [bottomView addSubview:entityView];
        
        //    UITapGestureRecognizer *entityGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(entityGestureTapped:)];
        //    [entityView addGestureRecognizer:entityGesture];
        
        
        height = 20.0;
        width = 70.0;
        xPos = 25.0;
        yPos = round((referView.frame.size.height - height)/2) + 16.0;
        UILabel *referNowLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        [referNowLbl setText:NSLocalizedString(@"Refer Now", @"")];
        [referNowLbl setTextAlignment:NSTextAlignmentCenter];
        [referNowLbl.layer setCornerRadius:10.0];
        [referNowLbl.layer setMasksToBounds:YES];
        [referNowLbl.layer setBorderWidth:2.0];
        [referNowLbl.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [referNowLbl setFont:[[Configuration shareConfiguration] yoReferBoldFontWithSize:12.0]];
        [referNowLbl setTextColor:[UIColor whiteColor]];
        [referNowLbl setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(77.0/255.0) blue:(40.0/255.0) alpha:1.0]];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:referNowLbl.bounds];
        //referNowLbl.layer.masksToBounds = NO;
        referNowLbl.layer.shadowColor = [UIColor grayColor].CGColor;
        referNowLbl.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        referNowLbl.layer.shadowOpacity = 0.3f;
        referNowLbl.layer.shadowPath = shadowPath.CGPath;
        [referView addSubview:referNowLbl];
        
        //refer
        width = 100.0;
        height = 15.0;
        xPos = 106.0;
        yPos = bottomView.frame.origin.y + 30.0;//imageView.frame.origin.y + imageView.frame.size.height;
        UILabel *refersLbl = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        NSString *referCount = [NSString stringWithFormat:@"%@ Refers",(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"referCount"]:[map.entity valueForKey:@"referCount"]];
        [refersLbl setText:NSLocalizedString(referCount, @"")];
        [refersLbl setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        [refersLbl setTextColor:(indexPath.row == 1 && self.mapType != Others)?[UIColor blueColor]:[UIColor grayColor]];
        [refersLbl setUserInteractionEnabled:YES];
        [view addSubview:refersLbl];
        
        
        
        /*NSMutableString *string = [[NSMutableString alloc]init];
         [string appendString:(self.mapType == Others)?([[self.response objectAtIndex:view.tag - 1] objectForKey:kName] != nil && [[[self.response objectAtIndex:view.tag - 1] objectForKey:kName] length] > 0)?[[self.response objectAtIndex:view.tag - 1] objectForKey:kName]:@"":map.name];
         [string appendString:[NSString stringWithFormat:@"\n%@",(self.mapType == Others)?[[self.response objectAtIndex:view.tag - 1] objectForKey:kLocality]:(self.mapType == Search && self.isSearch && [self.response count] <=0)?[self.searchCoordinates objectForKey:kPlace]:map.locality]];
         string =  (NSMutableString *)[string stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
         xPos = imageView.frame.origin.x + imageView.frame.size.width + 10.0;
         yPos = 0.0;
         width = view.frame.size.width - xPos - 30.0;
         height = 60.0;
         UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
         label.tag = indexPath.row;
         label.numberOfLines = 0;
         label.text = NSLocalizedString(string, @"");
         label.font = [[Configuration shareConfiguration] yoReferFontWithSize:14.0];
         label.textColor = (indexPath.row == 1)?[UIColor colorWithRed:45/255.0 green:116/255.0 blue:250/255.0 alpha:1.0]:[UIColor blackColor];
         [view addSubview:label];*/
    }
    //[cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)referGestureTapped:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint center = gestureRecognizer.view.center;
    CGPoint point = [gestureRecognizer.view.superview convertPoint:center toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    Map *map = [self.response objectAtIndex:(indexPath.row - 1)];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:15];
    
    if ([(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"type"]:[map.entity valueForKey:@"type"]  isEqualToString:kWeb])
    {
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"category"]:[map.entity valueForKey:@"category"] forKey:kCategory];
        [dictionary setValue:@"Weblink" forKey:kAddress];
        [dictionary setValue:@"" forKey:kMessage];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"name"]:[map.entity valueForKey:@"name"] forKey:kName];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kWebSite]:[map.entity valueForKey:kWebSite] forKey:kWebSite];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kIsEntiyd];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"entityId"]:[map.entity valueForKey:@"entityId"] forKey:kEntityId];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kWeb];
        [dictionary setValue:(self.mapType == Others)?[[self.response objectAtIndex:0] valueForKey:@"message"]:@"" forKey:kMessage];
        
    }else
    {
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"locality"]:[map.entity valueForKey:@"locality"] forKey:kAddress];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"category"]:[map.entity valueForKey:@"category"] forKey:kCategory];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"type"]:[map.entity valueForKey:@"type"] forKey:kCategorytype];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"entityId"]:[map.entity valueForKey:@"entityId"] forKey:@"entityId"];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isentiyd"];
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"name"]:[map.entity valueForKey:@"name"] forKey:kName];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kNewRefer];
        [dictionary setValue:(self.mapType == Others)?[[self.response objectAtIndex:0] valueForKey:@"message"]:@"" forKey:kMessage];
        [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
        
        if ([(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"type"]:[map.entity valueForKey:@"type"]  isEqualToString:kProduct])
        {
            
            [dictionary setValue:(self.mapType == Others)?[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kName]:[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kName] forKey:kFromWhere];
            [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"city"]:[map.entity valueForKey:@"city"] forKey:kCity];
            [dictionary setValue:(self.mapType == Others)?[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kLocality]:[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kLocality] forKey:kLocation];
            [dictionary setValue:(self.mapType == Others)?[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kPhone]:[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kPhone] forKey:kPhone];
            [dictionary setValue:(self.mapType == Others)?[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kWebSite]:[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kWebSite] forKey:kWebSite];
            [dictionary setValue:(self.mapType == Others)?[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kPosition]:[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kPosition] forKey:kPosition];
            
            if ((self.mapType == Others)?[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kPosition]:[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kPosition])
            {
                [dictionary setValue:(self.mapType == Others)?[[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kPosition] objectAtIndex:1]:[[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
                [dictionary setValue:(self.mapType == Others)?[[[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:kPurchasedFrom] valueForKey:kDetail] valueForKey:kPosition] objectAtIndex:0]:[[[[map.entity valueForKey:kPurchasedFrom] valueForKey:kDetail]valueForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
            }
            
        }else
        {
            [dictionary setValue:(self.mapType == Others)?[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"position"] objectAtIndex:1]:[[map.entity valueForKey:@"position"] objectAtIndex:1] forKey:@"latitude"];
            [dictionary setValue:(self.mapType == Others)?[[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"position"] objectAtIndex:0]:[[map.entity valueForKey:@"position"] objectAtIndex:0] forKey:@"longitude"];
            [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"phone"]:[map.entity valueForKey:@"phone"] forKey:kPhone];
            [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"website"]:[map.entity valueForKey:@"website"] forKey:kWebSite];
            [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"city"]:[map.entity valueForKey:@"city"] forKey:kCity];
            [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"locality"]:[map.entity valueForKey:@"locality"] forKey:kLocation];
            
        }
        
        if (self.mapType == Others)
        {
            if ([[self.response objectAtIndex:0] valueForKey:@"image"] != nil && [[[self.response objectAtIndex:0] valueForKey:@"image"] isKindOfClass:[NSString class]] > 0)
                [dictionary setValue:[[self.response objectAtIndex:0] valueForKey:@"image"] forKey:@"referimage"];
            
        }else
        {
            if (map.dp != nil && [map.dp isKindOfClass:[NSString class]] > 0)
                [dictionary setValue:map.dp forKey:@"referimage"];
        }
        [dictionary setValue:(self.mapType == Others)?[[[self.response objectAtIndex:0] valueForKey:@"entity"] valueForKey:@"city"]:[map.entity valueForKey:@"city"] forKey:@"searchtext"];
        
    }
    ReferNowViewController *referVctre = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:self];
    [self.navigationController pushViewController:referVctre animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        //        self.showMap = !self.showMap;
        //
        //        if (!self.showMap) {
        //            [self.mapView removeAnnotations:self.mapView.annotations];
        //            CATransition *transition = [CATransition animation];
        //            transition.type = kCATransitionPush;
        //            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        //            transition.fillMode = kCAFillModeForwards;
        //            transition.duration = 0.5;
        //            transition.subtype = kCATransitionFromTop;
        //            [[self.tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
        //            [self.tableView reloadData];
        //            self.tableView.scrollEnabled = YES;
        //            for (UIView *view in self.view.subviews) {
        //                if ([view isKindOfClass:[UIImageView class]]) {
        //                    [view removeFromSuperview];
        //                }else if (view.tag == kPinViewTag){
        //                    [view removeFromSuperview];
        //                }
        //            }
        //
        //        }
        //        else
        //        {
        //            CATransition *transition = [CATransition animation];
        //            transition.type = kCATransitionPush;
        //            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        //            transition.fillMode = kCAFillModeForwards;
        //            transition.duration = 0.5;
        //            transition.subtype = kCATransitionFromBottom;
        //            [[self.tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
        //            [self.tableView reloadData];
        //            self.tableView.scrollEnabled = NO;
        //        }
    }
    else
    {
        if(self.mapType == Others)
        {
            NSDictionary *map = [self.response objectAtIndex:indexPath.row - 1];
            if ([[map valueForKey:kNewRefer] boolValue])
            {
                if ([[NSString stringWithFormat:@"%@",[map valueForKey:kLatitude]] length] > 0 && [[NSString stringWithFormat:@"%@",[map valueForKey:kLatitude]] length] > 0)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                    NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
                    NSMutableArray *array;
                    if ([categoryArray  count] > 0)
                    {
                        array = [[NSMutableArray alloc]init];
                        for (NSDictionary *dictionary in [categoryArray valueForKey:kPlace])
                        {
                            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
                            [array addObject:places];
                        }
                    }
                    CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
                    [dictionary setValue:category.categoryName forKey:kCategory];
                    [dictionary setValue:category.categoryID forKey:@"categoryid"];
                    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:kAddress];
                    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kLocation];
                    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
                    [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
                    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
                    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
                    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ismaprefer"];
                    [dictionary setValue:@"Place" forKey:kCategorytype];
                    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
                    if ([self.delegate respondsToSelector:@selector(LocationReferWithDetail:)])
                    {
                        [self.delegate LocationReferWithDetail:dictionary];
                    }
                }
            }else
            {
                if ([[map valueForKey:@"isentity"] boolValue])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else
                {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ismap"];
                    [dic setValue:[map objectForKey:kName] forKey:kName];
                    [dic setValue:[map objectForKey:kType] forKey:kType];
                    [dic setValue:[map objectForKey:kCategory] forKey:kCategory];
                    [dic setValue:[map objectForKey:kLocality] forKey:kLocality];
                    [dic setValue:[map objectForKey:kCity] forKey:kCity];
                    [dic setValue:[map objectForKey:kPhone] forKey:kPhone];
                    [dic setValue:[map objectForKey:kPosition] forKey:kPosition];
                    [dic setValue:[map objectForKey:kWeb] forKey:kWeb];
                    [dic setValue:[[self.response objectAtIndex:0] valueForKey:kEntity] forKey:kEntity];
                    [dic setValue:[map objectForKey:kReferCount] forKey:kReferCount];
                    [dic setValue:[map objectForKey:@"mediaCount"] forKey:kMediaCount];
                    [dic setValue:[map objectForKey:@""] forKey:kMediaLinks];
                    [dic setValue:[map valueForKey:@"entityid"] forKey:@"entityid"];
                    [dic setValue:[map objectForKey:kImage] forKey:kMediaId];
                    [dic setValue:[map objectForKey:kLatitude] forKey:kLatitude];
                    [dic setValue:[map objectForKey:kLongitude] forKey:kLongitude];
                    [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ismap"];
                    [dic setValue:[map valueForKey:kMessage] forKey:kMessage];
                    [dic setValue:[map valueForKey:kFromWhere] forKey:kFromWhere];
                    EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:dic];
                    [self.navigationController pushViewController:vctr animated:YES];
                }
            }
        }
        else
        {
            if (self.isSearch && [self.response count] <=0)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setValue:[self.searchCoordinates objectForKey:kLatitude] forKey:kLatitude];
                [dict setValue:[self.searchCoordinates objectForKey:kLongitude] forKey:kLongitude];
                [dict setValue:[self.searchCoordinates objectForKey:kPlace] forKey:kPlace];
                NSString *place = [self.searchCoordinates objectForKey:kPlace];
                NSString *lat  =[self.searchCoordinates objectForKey:kLatitude];
                NSString *lon  =[self.searchCoordinates objectForKey:kLongitude];
                if ([self.delegate respondsToSelector:@selector(getCurrentAddressDetail:)])
                {
                    [self.delegate getCurrentAddressDetail:dict];
                }
                NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
                NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
                NSMutableArray *array;
                if ([categoryArray  count] > 0)
                {
                    array = [[NSMutableArray alloc]init];
                    for (NSDictionary *dictionary in [categoryArray valueForKey:kPlace])
                    {
                        CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
                        [array addObject:places];
                    }
                }
                CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
                [dictionary setValue:category.categoryName forKey:kCategory];
                [dictionary setValue:category.categoryID forKey:@"categoryid"];
                [dictionary setValue:place forKey:kAddress];
                [dictionary setValue:place forKey:kLocation];
                [dictionary setValue:lat forKey:kLatitude];
                [dictionary setValue:lon forKey:kLongitude];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
                [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
                [dictionary setValue:@"Place" forKey:kCategorytype];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ismaprefer"];
                if ([self.delegate respondsToSelector:@selector(LocationReferWithDetail:)])
                {
                    [self.delegate LocationReferWithDetail:dictionary];
                }
                if ([self.type isEqualToString:@"map"])
                {
                    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:self];
                    [self.navigationController pushViewController:vctr animated:YES];
                }else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else
            {
                Map *map = (Map *)[self.response objectAtIndex:indexPath.row - 1];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setValue:[map.entity valueForKey:kName] forKey:kName];
                [dic setValue:[map.entity valueForKey:kCategory] forKey:kCategory];
                [dic setValue:[map.entity valueForKey:@"referCount"] forKey:kReferCount];
                [dic setValue:[map.entity valueForKey:@"mediaCount"] forKey:kMediaCount];
                [dic setValue:[map.entity valueForKey:@"mediaLinks"] forKey:kMediaLinks];
                [dic setValue:map.entityId forKey:@"entityid"];
                [dic setValue:map.type forKey:kType];
                [dic setValue:map.entity forKey:kEntity];
                [dic setValue:map.dp forKey:kMediaId];
                [dic setValue:[map.entity valueForKey:kCity] forKey:kCity];
                if ([map.type  isEqualToString:kProduct])
                {
                    [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kLocation];
                    [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
                    [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
                    [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
                    [dic setValue:[[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
                    [dic setValue:[[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
                    [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCity] forKey:kFromWhere];
                }else
                {
                    [dic setValue:[map.entity objectForKey:kPosition] forKey:kLocation];
                    [dic setValue:[map.entity objectForKey:kLocality] forKey:kLocality];
                    [dic setValue:[map.entity objectForKey:kPhone] forKey:kPhone];
                    [dic setValue:[map.entity objectForKey:kWebSite] forKey:@"web"];
                    [dic setValue:[[map.entity objectForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
                    [dic setValue:[[map.entity objectForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
                }
                [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ismap"];
                EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:dic];
                [self.navigationController pushViewController:vctr animated:YES];
            }
        }
        
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearch == NO) {
        
        if ([self.response count] > 0 && [self.response count]  == (indexPath.row+1) && self.mapType != Search && self.mapType != Others)
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            if(self.mapType == Search)
            {
                [params setValue:[NSArray arrayWithObjects:[self.searchCoordinates objectForKey:kLatitude],[self.searchCoordinates objectForKey:kLongitude], nil] forKey:kLocation];
            }
            else
            {
                [self.searchCoordinates setValue:[[UserManager shareUserManager] latitude] forKey:kLatitude];
                [self.searchCoordinates setValue:[[UserManager shareUserManager] longitude] forKey:kLongitude];
                [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
            }
            [params setValue:kRadius forKey:kRadiusParam];
            self.isPage = self.isPage + 1;
            [params setValue:[NSNumber numberWithInteger:self.isPage] forKey:@"page"];
            [params setValue:[NSNumber numberWithInteger:kPageLimit] forKey:@"limit"];
            [[YoReferAPI sharedAPI] currentLocationOfferWithParams:params completionHandler:^(NSDictionary *response , NSError * error)
             {
                 [self didRecevieNextMapWithResponse:response error:error];
                 
             }];
            
        }

    }
    
}

- (void)didRecevieNextMapWithResponse:(NSDictionary *)response error:(NSError *)error
{
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMapError, @""), nil, @"Ok", nil, 0);
            return;
            
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        
        for (NSDictionary *dictionary in [response objectForKey:@"response"])
        {
            Map *map = [Map MapWithResponse:dictionary];
            [self.response addObject:map];
            self.mapType = Offers;
        }
        self.isSearch = YES;
        //[self setCoordinate];
        [self reloadTableView];
    }
    
    
}

#pragma mark  - Search bar delegate

#pragma mark - Handler
- (void)searchWithText:(NSString *)text
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    if(self.mapType == Search)
    {
        [params setValue:[NSArray arrayWithObjects:[self.searchCoordinates objectForKey:kLatitude],[self.searchCoordinates objectForKey:kLongitude], nil] forKey:kLocation];
    }
    else
    {
        [self.searchCoordinates setValue:[[UserManager shareUserManager] latitude] forKey:kLatitude];
        [self.searchCoordinates setValue:[[UserManager shareUserManager] longitude] forKey:kLongitude];
        [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    }
    [params setValue:kRadius forKey:kRadiusParam];
    [params setValue:[NSNumber numberWithInteger:(self.mapType == Search)?0:self.isPage] forKey:@"page"];
    [params setValue:[NSNumber numberWithInteger:kPageLimit] forKey:@"limit"];
    [params setValue:text forKey:@"query"];
    
    [[YoReferAPI sharedAPI] mapSearchWithParams:params completionHandler:^(NSDictionary *response , NSError * error)
     {
         [self didReceiveLocationOfferWithResponse:response error:error];
         
     }];
    
    
    
    /*
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
     [params setValue:@"5" forKey:@"limit"];
     [params setValue:[[Helper shareHelper] currentTimeWithMilliSecound] forKey:@"before"];
     [params setValue:text forKey:@"query"];
     
     if ([_addressTxtField.text isEqualToString:@""]) {
     [params setValue:[[UserManager shareUserManager] currentCity] forKey:@"city"];
     }
     else
     {
     [params setValue:_addressTxtField.text forKey:@"city"];
     }
     
     [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
     [[YoReferAPI sharedAPI] searchByCategory:params completionHandler:^(NSDictionary * response,NSError * error)
     {
     [self didReceiveLocationOfferWithResponse:response error:error];
     
     }];
     */
}


#pragma mark - Textfiled delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = [[textField superview].superview convertRect:[textField superview].frame toView:self.view];
    
    if (!self.searchCoordinates)
        self.searchCoordinates = [[NSMutableDictionary alloc]init];
    [self.searchCoordinates setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([textField.text length] > 3)
    {
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length] > 3)
    {
        [[LocationManager shareLocationManager] searchCityWithName:textField.text :^(NSMutableArray *locationDetails){
            if ([locationDetails count] > 0)
            {
                self.nIDropDown = nil;
                [self.dropDownView removeFromSuperview];
                [self LocationWithDetails:locationDetails];
            }
        }];
    }else
    {
        self.nIDropDown = nil;
        [self.dropDownView removeFromSuperview];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}


#pragma mark  - Search bar delegate


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (searchBar.tag != kMapSearchBartag) {
        CGRect frame = [[searchBar superview].superview convertRect:[searchBar superview].frame toView:self.view];
        if (!self.searchCoordinates)
            self.searchCoordinates = [[NSMutableDictionary alloc]init];
        [self.searchCoordinates setValue:[NSString stringWithFormat:@"%f",frame.origin.y] forKey:kYPostion];
    }
    else if(searchBar.tag == kMapSearchBartag)
    {
        [self enableDisableCancelWithsearchBar:searchBar Button:YES];
    }
    
}

- (void)enableDisableCancelWithsearchBar:(UISearchBar *)searchBar Button:(BOOL)isCancel
{
    searchBar.showsCancelButton = isCancel;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.tag != kMapSearchBartag) {
        [self.previousView setHidden:YES];
        [searchBar resignFirstResponder];
    }
    else if(searchBar.tag == kMapSearchBartag)
    {
        //        self.mapType = Search;
        [searchBar resignFirstResponder];
        self.isSearch = YES;
        [self searchWithText:searchBar.text];
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchBar.tag != kMapSearchBartag) {
        if ([searchText length] == 0)
        {
            [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        }
    }
    else if(searchBar.tag == kMapSearchBartag)
    {
        if ([searchText length] == 0)
        {
            [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        }
        
    }
    
    
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (searchBar.tag != kMapSearchBartag)
    {
        if ([self.searchText length] - 2 == [searchBar.text length] && [self.searchText length] > 0)
        {
            self.searchText = @"";
            searchBar.text = @"";
            self.nIDropDown = nil;
            [self.dropDownView removeFromSuperview];
        }
        if ([searchBar.text length] > 3)
        {
            [[LocationManager shareLocationManager] searchCityWithName:searchBar.text :^(NSMutableArray *locationDetails){
                if ([locationDetails count] > 0)
                {
                    self.nIDropDown = nil;
                    [self.dropDownView removeFromSuperview];
                    [self LocationWithDetails:locationDetails];
                }
            }];
        }else
        {
            self.nIDropDown = nil;
            [self.dropDownView removeFromSuperview];
        }
        
        return YES;
    }
    else if(searchBar.tag == kMapSearchBartag)
    {
        return YES;
    }
    
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self showHUDWithMessage:NSLocalizedString(@"", nil)];
    
    [searchBar resignFirstResponder];
    [self enableDisableCancelWithsearchBar:searchBar Button:NO];
    searchBar.text = @"";
    self.isSearch = NO;
    
    [self searchWithText:searchBar.text];
}



- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    if (searchBar.tag != kMapSearchBartag)
    {
        [searchBar resignFirstResponder];
        [self.nIDropDown removeFromSuperview];
    }
    else if(searchBar.tag == kMapSearchBartag)
    {
    }
    
}


- (void)updateLocation
{
    [self.tableView endEditing:YES];
    self.nIDropDown = nil;
    [self.dropDownView removeFromSuperview];
    [self locationUpdate];
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
}

- (void)locationUpdate:(NSNotification *)notification
{
    UIView *view = [self.view viewWithTag:kMapSearchBartag];
    if ([[UserManager shareUserManager] getLocationService])
    {
        if ([[[notification valueForKey:@"userInfo"] valueForKey:@"locationUpdated"] boolValue])
        {
            if (view.tag == kMapSearchBartag)
            {
                [(UITextField *)view setText:[[UserManager shareUserManager] currentCity]];
            }
            [self getLocationOffer];
            
        }else
        {
            [self currentLocation];
        }
    }else
    {
        if (view.tag == kMapSearchBartag)
        {
            [(UITextField *)view setText:[[UserManager shareUserManager] currentCity]];
        }
        [self getLocationOffer];
    }
}


#pragma mark - Location search
- (void)LocationWithDetails:(NSMutableArray *)details
{
    if(self.nIDropDown == nil)
    {
        UIView *view = [self.view viewWithTag:kMapSearchBartag];
        CGFloat yPostion = [[self.searchCoordinates valueForKey:kYPostion] floatValue] + 34.0;
        CGFloat changedHeight = [UIScreen mainScreen].bounds.size.height - (view.frame.size.height + 52.0);
        self.dropDownView = [[UIView alloc]initWithFrame:CGRectMake(6.0, yPostion, view.frame.size.width - 30.0, changedHeight)];
        UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(-10.0, 0.0, self.dropDownView.frame.size.width, self.dropDownView.frame.size.height)];
        CGRect btnFrame=locationBtn.frame;
        btnFrame.origin.y=0.0;
        btnFrame.origin.x = 0.0;
        btnFrame.size.height=0.0;
        locationBtn.frame=btnFrame;
        locationBtn.backgroundColor=[UIColor clearColor];
        CGFloat f = changedHeight;//([UIScreen mainScreen].bounds.size.height > 480.0)?([UIScreen mainScreen].bounds.size.height > 568.0)?220.0:171.0:83.0;
        self.nIDropDown = [[NIDropDown alloc]showDropDown:locationBtn :f :details :nil :@"down" type:YES];
        self.nIDropDown.delegate = self;
        [self.dropDownView addSubview:self.nIDropDown];
        [self.view addSubview:self.dropDownView];
    }
}
- (void)getLoaction:(NSDictionary *)location
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    [self.dropDownView removeFromSuperview];
    UIView *view = [self.view viewWithTag:kMapSearchBartag];
    if (view.tag == kMapSearchBartag)
    {
        [(UITextField *)view setText:[location objectForKey:@"description"]];
    }
    self.searchCoordinates = [[NSMutableDictionary alloc]init];
    [self.searchCoordinates setValue:[location objectForKey:@"description"] forKey:@"place"];
    [[UserManager shareUserManager]setReferAddress:[location objectForKey:@"description"]];
    [self getCurrentLatLongFromPlaceId:[location objectForKey:@"place_id"]];
    self.searchText = [location objectForKey:@"description"];
}

- (void)getCurrentLatLongFromPlaceId:(NSString *)placeId
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
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                [self.searchCoordinates setValue:[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"] forKey:@"latitude"];
                [self.searchCoordinates setValue:[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"] forKey:@"longitude"];
                //[self.response removeAllObjects];
                self.mapType = Search;
                // [self.mapView removeAnnotations:[self.mapView annotations]];
                [self getLocationOffer];
            }
        });
        
    });
}

- (void)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=AIzaSyBZokl35NK2BIpKpnFB97PIyvlSOKng9E0",pdblLatitude, pdblLongitude];
    
    // NSLog(@"%@",locationString);
    dispatch_queue_t addressQueue = dispatch_queue_create("Address Queue",NULL);
    dispatch_async(addressQueue, ^{
        NSError* error;
        __block NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[locationString dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
            
            locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            self.pinAddress = ([[jsonObject valueForKey:@"results"] isKindOfClass:[NSArray class]])?[[[jsonObject valueForKey:@"results"] valueForKey:@"formatted_address"] objectAtIndex:0]:@"";
            //            [self.activityIndicator stopAnimating];
            //            [self.activityIndicator removeFromSuperview];
            UILabel *label = (UILabel *)[[[[[self.view viewWithTag:kPinViewTag]subviews]objectAtIndex:0]subviews]objectAtIndex:0];
            label.text = self.pinAddress;
            
            for (NSDictionary *dict in [[[jsonObject valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"]) {
                if ([[[dict valueForKey:@"types"]objectAtIndex:0] isEqualToString:@"locality"]) {
                    self.pinCity = [dict valueForKey:@"long_name"];
                }
            }
            
        });
        
        
    });
    
    //    NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[locationString dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
    //
    //    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    //    self.pinAddress = ([[jsonObject valueForKey:@"results"] isKindOfClass:[NSArray class]])?[[[jsonObject valueForKey:@"results"] valueForKey:@"formatted_address"] objectAtIndex:0]:@"";
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.activityIndicator stopAnimating];
    //        [self.activityIndicator removeFromSuperview];
    //        UILabel *label = (UILabel *)[[[[[self.view viewWithTag:kPinViewTag]subviews]objectAtIndex:0]subviews]objectAtIndex:0];
    //        label.text = self.pinAddress;
    //    });
    
    
}


- (void)getAddressFromLatLonFetched:(NSString *)pdblLatitude withLongitude:(NSString *)pdblLongitude
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&key=AIzaSyBZokl35NK2BIpKpnFB97PIyvlSOKng9E0",pdblLatitude, pdblLongitude];
    
    // NSLog(@"%@",locationString);
    dispatch_queue_t addressQueue = dispatch_queue_create("Address Queue",NULL);
    dispatch_async(addressQueue, ^{
        NSError* error;
        __block NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[locationString dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
            
            locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            self.pinAddress = ([[jsonObject valueForKey:@"results"] isKindOfClass:[NSArray class]])?[[[jsonObject valueForKey:@"results"] valueForKey:@"formatted_address"] objectAtIndex:0]:@"";
            //            [self.activityIndicator stopAnimating];
            //            [self.activityIndicator removeFromSuperview];
            UILabel *label = (UILabel *)[[[[[self.view viewWithTag:kPinViewTag]subviews]objectAtIndex:0]subviews]objectAtIndex:0];
            label.text = self.pinAddress;
            
            for (NSDictionary *dict in [[[jsonObject valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"]) {
                if ([[[dict valueForKey:@"types"]objectAtIndex:0] isEqualToString:@"locality"]) {
                    self.pinCity = [dict valueForKey:@"long_name"];
                }
            }
            
        });
        
        
    });
    
    //    NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[locationString dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
    //
    //    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    //    self.pinAddress = ([[jsonObject valueForKey:@"results"] isKindOfClass:[NSArray class]])?[[[jsonObject valueForKey:@"results"] valueForKey:@"formatted_address"] objectAtIndex:0]:@"";
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.activityIndicator stopAnimating];
    //        [self.activityIndicator removeFromSuperview];
    //        UILabel *label = (UILabel *)[[[[[self.view viewWithTag:kPinViewTag]subviews]objectAtIndex:0]subviews]objectAtIndex:0];
    //        label.text = self.pinAddress;
    //    });
    
}



- (void)addPinView
{
    
    CGFloat xPos = self.pinImage.frame.origin.x - 88.0;
    CGFloat yPos = self.pinImage.frame.origin.y - 95.0;
    CGFloat width = 200.0;
    CGFloat height = 95.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [view setBackgroundColor:[UIColor clearColor]];
    view.tag = kPinViewTag;
    view.layer.cornerRadius = 15.0;
    [self.view addSubview:view];
    
    xPos = 0.0;
    yPos = 0.0;
    width = view.frame.size.width;
    height = 70.0;
    UIView *pinView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    [pinView setBackgroundColor:[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0]];
    pinView.layer.cornerRadius  = 15.0;
    [view addSubview:pinView];
    
    xPos = 5.0;
    yPos = 5.0;
    width = pinView.frame.size.width - 2 * xPos - 40.0;
    height = pinView.frame.size.height - 2 * yPos;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    label.text = @"Getting Address..Please wait!";
    label.numberOfLines = 5;
    label.font = [[Configuration shareConfiguration]yoReferFontWithSize:12.0];
    label.textColor = [UIColor whiteColor];
    [pinView addSubview:label];
    
    xPos = pinView.frame.size.width - 40.0;
    yPos = pinView.frame.size.height/2 - 20.0;
    width = 40.0;
    height = 40.0;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    rightArrow.image = rightArrowImg;
    [pinView addSubview:rightArrow];
    
    //pop up arrow
    xPos = view.frame.size.width/2 - 10.0;
    yPos = pinView.frame.origin.y + pinView.frame.size.height;
    width = 20.0;
    height = 25.0;
    UIImageView *popUpArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    popUpArrow.image = popupDown;
    [view addSubview:popUpArrow];
    
    xPos = 0.0;
    yPos = 0.0;
    width = pinView.frame.size.width;
    height = pinView.frame.size.height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(xPos, yPos, width, height);
    button.tag = kPinViewTag;
    [button addTarget:self action:@selector(mapReferNowBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [pinView addSubview:button];
    
    [self getAddressFromLatLon:self.mapView.centerCoordinate.latitude withLongitude:self.mapView.centerCoordinate.longitude];

//    [self getAddressFromLatLonFetched:[[UserManager shareUserManager] latitude] withLongitude:[[UserManager shareUserManager] longitude]];

    
    /*
    if(self.mapType != Others)
    {
        //[self.addressTxtField setText:@""];
    }
    self.currentAnnotation = 0;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    */

}

#pragma mark - DropDown delegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}
-(void)rel
{
    [self.view endEditing:YES];
    self.nIDropDown = nil;
}

#pragma mark - Map handler
- (void)getLocationOffer
{
    [self showHUDWithMessage:NSLocalizedString(@"", @"")];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    if(self.mapType == Search)
    {
        [params setValue:[NSArray arrayWithObjects:[self.searchCoordinates objectForKey:kLatitude],[self.searchCoordinates objectForKey:kLongitude], nil] forKey:kLocation];
    }
    else
    {
        [self.searchCoordinates setValue:[[UserManager shareUserManager] latitude] forKey:kLatitude];
        [self.searchCoordinates setValue:[[UserManager shareUserManager] longitude] forKey:kLongitude];
        [params setValue:[NSArray arrayWithObjects:[[UserManager shareUserManager] latitude],[[UserManager shareUserManager] longitude], nil] forKey:@"location"];
    }
    [params setValue:kRadius forKey:kRadiusParam];
    [params setValue:[NSNumber numberWithInteger:(self.mapType == Search)?0:self.isPage] forKey:@"page"];
    [params setValue:[NSNumber numberWithInteger:kPageLimit] forKey:@"limit"];
    [[YoReferAPI sharedAPI] currentLocationOfferWithParams:params completionHandler:^(NSDictionary *response , NSError * error)
     {
         [self didReceiveLocationOfferWithResponse:response error:error];
         
     }];
}

- (void)didReceiveLocationOfferWithResponse:(NSDictionary *)response error:(NSError *)error
{
    [self hideHUD];
    if (error !=nil)
    {
        if ([[[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"] length] > 0)
        {
            alertView([[Configuration shareConfiguration] connectionStatus], NSLocalizedString([[error valueForKey:@"userInfo"] objectForKey:@"NSLocalizedDescription"], @""), nil, @"Ok", nil, 0);
            return;
        }else
        {
            alertView([[Configuration shareConfiguration] errorMessage], NSLocalizedString(kMapError, @""), nil, @"Ok", nil, 0);
            return;
        }
    }else if ([[response objectForKeyedSubscript:@"message"] isEqualToString:@"invalid_session_token"])
    {
        [[UserManager shareUserManager]logOut];
        return;
    }else
    {
        self.response = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [response objectForKey:@"response"])
        {
            Map *map = [Map MapWithResponse:dictionary];
            [self.response addObject:map];
            self.mapType = (self.mapType == Search)?Search:Offers;
        }
        
        //[self setCoordinate];
        [self reloadTableView];
    }
}

#pragma mark - Map View Delegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.view endEditing:YES];
    [self.previousView setHidden:YES];
    [UIView animateWithDuration:0.4 animations:^{
        [self.pinImage setHidden:NO];
//        [self.pinImage setFrame:CGRectMake(self.pinImage.frame.origin.x, self.pinImage.frame.origin.y - 20.0, self.pinImage.frame.size.width, self.pinImage.frame.size.height)];
        
    }];
    for (UIView *view in self.view.subviews) {
        if (view.tag == kPinViewTag) {
            [view removeFromSuperview];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.4 animations:^{
        [self.pinImage setHidden:NO];
//        [self.pinImage setFrame:CGRectMake(self.pinImage.frame.origin.x, self.pinImage.frame.origin.y + 20.0, self.pinImage.frame.size.width, self.pinImage.frame.size.height)];
        
    }];
    [self performSelector:@selector(addPinView) withObject:nil afterDelay:0.4];
    
    NSLog(@"%f",self.mapView.centerCoordinate.latitude);
    NSLog(@"%f",self.mapView.centerCoordinate.longitude);
    // [self setCoordinate];
    //[self.mapView addAnnotations:mapView.annotations];
    
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    [annotation description];
    MKAnnotationView *pinView = nil;
    UIImage *pinImage = [[UIImage alloc]init];
    static NSString *defaultPinID = @"";
    if(annotation != self.mapView.userLocation)
    {
        pinView = (MKPinAnnotationView *)[self.mapView  dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
        {
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            BOOL  isBool = NO;
            if ([self.response count] > 0 && [[self.response  objectAtIndex:0] isKindOfClass:[NSDictionary class]])
                isBool = [[[self.response  objectAtIndex:0]valueForKey:@"isCurrentLocation"] boolValue];
            else
                isBool = NO;
            //            if (self.mapType == Search ||isBool)
            //            {
            //                pinImage = currentlocation;
            //            }
            //            else
            //            {
            pinImage = mapPin;
            //}
            pinView.image = pinImage;
            pinView.canShowCallout = YES;
            self.currentAnnotation ++;
            
        }
    }
    else
    {
        //        pinView = [[MKAnnotationView alloc]
        //                   initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        //        pinImage = currentlocation;
        //        pinView.image = pinImage;
    }
    return pinView;
}


- (NSInteger)indexWithlat:(float)lat lng:(float)lng
{
    for (int index = 0; index < [self.response count]; index++)
    {
        
        Map *map = [self.response objectAtIndex:index];
        if ([map isKindOfClass:[Map class]])
        {
            if (lat == [[map.position objectAtIndex:1] floatValue] && lng == [[map.position objectAtIndex:0] floatValue])
            {
                return index;
            }
        }
        
    }
    return 0;
}

//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
//
//    float delay = 0.00;
//
//    for (MKAnnotationView *aV in views) {
//        CGRect endFrame = aV.frame;
//
//        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 430.0, aV.frame.size.width, aV.frame.size.height);
//        delay = delay + 0.5;
//
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDelay:delay];
//        [UIView setAnimationDuration:0.45];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [aV setFrame:endFrame];
//        [UIView commitAnimations];
//    }
//}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view setHidden:YES];
        }else if (view.tag == kPinViewTag){
            [view setHidden:YES];
        }
    }
    
    view.tag = [self indexWithlat:[[view annotation] coordinate].latitude lng:[[view annotation] coordinate].longitude];
    id <MKAnnotation> annotate;
    annotate = [[mapView selectedAnnotations] objectAtIndex:0];
    [mapView deselectAnnotation:view.annotation animated:YES];
    CGSize  calloutSize = CGSizeMake(200.0, 95.0);
    CGFloat xPos = view.frame.origin.x - (calloutSize.width * 0.45f);
    CGFloat yPos = view.frame.origin.y - calloutSize.height;
    CGFloat  width = calloutSize.width;
    CGFloat height = calloutSize.height;
    UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
    //map view
    xPos = 0.0;
    yPos = 0.0;
    width = 200.0;
    height = 70.0;
    UIView *mapListView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    mapListView.backgroundColor=[UIColor colorWithRed:(215.0/255.0) green:(60.0/255.0) blue:(30.0/255.0) alpha:1.0];
    mapListView.layer.cornerRadius = 15.0;
    [calloutView addSubview:mapListView];
    xPos = 0.0;
    yPos = 0.0;
    width = mapListView.frame.size.width;
    height = mapListView.frame.size.height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(xPos, yPos, width, height);
    button.tag = view.tag;
    if ([annotate isKindOfClass:[MKUserLocation class]])
    {
        [button addTarget:self action:@selector(mapReferNowBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        [button addTarget:self action:@selector(mapViewTappedBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [mapListView addSubview:button];
    //image
    xPos = 5.0;
    yPos = 5.0;
    width = 60.0;
    height = 60.0;
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    Map *map;
    if ([self.response count] > 0 && (self.mapType == Offers || self.isSearch))
    {
        map =  (Map *)[self.response objectAtIndex:view.tag];
        
    }else if ([self.response count] >0 && self.mapType == Others)
    {
        if ([[[self.response objectAtIndex:view.tag] objectForKey:kImage] isKindOfClass:[UIImage class]])
        {
            image.image = [[self.response objectAtIndex:view.tag] objectForKey:kImage];
            
        }else
        {
            if ([[[self.response objectAtIndex:0] valueForKey:kImage] isKindOfClass:[NSString class]])
            {
                NSArray *array = [[NSString stringWithFormat:@"%@",[[self.response objectAtIndex:0] valueForKey:kImage]] componentsSeparatedByString:@"/"];
                NSString *imageName = [array objectAtIndex:[array count]-1];
                
                if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]] && [imageName length] > 0 )
                {
                    [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:image path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
                }else
                {
                    if ([[self.response objectAtIndex:view.tag] isKindOfClass:[Map class]])
                    {
                        [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag] objectForKey:kImage]:map.dp] imageView:image];
                        
                    }else
                    {
                        if ([[[self.response objectAtIndex:view.tag] objectForKey:kImage] isKindOfClass:[UIImage class]])
                        {
                            image.image = [[self.response objectAtIndex:view.tag] objectForKey:kImage];
                            
                        }else
                        {
                            if ([imageName length] > 0)
                            {
                                [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag] objectForKey:kImage]:map.dp] imageView:image];
                            }else
                            {
                                if ([[[self.response objectAtIndex:view.tag] objectForKey:kType] isEqualToString:kPlace])
                                {
                                    image.image = placeImg;
                                    
                                }else  if ([[[self.response objectAtIndex:view.tag] objectForKey:kType] isEqualToString:kProduct])
                                {
                                    image.image = productImg;
                                    
                                }else  if ([[[self.response objectAtIndex:view.tag] objectForKey:kType] isEqualToString:kWeb])
                                {
                                    image.image = webLinkImg;
                                }else  if ([[[self.response objectAtIndex:view.tag] objectForKey:kType] isEqualToString:kService])
                                {
                                    image.image = serviceImg;
                                }else
                                    image.image = noPhotoImg;
                            }
                            
                        }
                        
                    }
                }
            }
            
        }
    }
    if(map.dp !=nil && [map.dp length] > 0)
    {
        NSArray *array = [[NSString stringWithFormat:@"%@",map.dp] componentsSeparatedByString:@"/"];
        NSString *imageName = [array objectAtIndex:[array count]-1];
        if ([[DocumentDirectory shareDirectory] fileExistsWithPath:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]])
        {
            [[DocumentDirectory shareDirectory] getImageFromDirectoryWithImage:image path:[NSString stringWithFormat:@"%@/%@",[[UserManager shareUserManager] number],imageName]];
            
        }else
        {
            if ([[self.response objectAtIndex:view.tag] isKindOfClass:[Map class]])
            {
                [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag] objectForKey:kImage]:map.dp] imageView:image];
                
            }else
            {
                if ([[[self.response objectAtIndex:view.tag] objectForKey:kImage] isKindOfClass:[UIImage class]])
                {
                    image.image = [[self.response objectAtIndex:view.tag] objectForKey:kImage];
                    
                }else
                {
                    
                    [[LazyLoading shareLazyLoading] loadImageWithUrl:[NSURL URLWithString:(self.mapType == Others)?[[self.response objectAtIndex:view.tag] objectForKey:kImage]:map.dp] imageView:image];
                    
                }
            }
        }
        
    }else
    {
        if ([map.type isEqualToString:kPlace] && [self.type isEqualToString:@"map"])
        {
            image.image = placeImg;
        }
        else  if ([map.type isEqualToString:kProduct] && [self.type isEqualToString:@"map"])
        {
            image.image = productImg;
            
        }else  if ([map.type isEqualToString:kWeb] && [self.type isEqualToString:@"map"])
        {
            image.image = webLinkImg;
        }
        else  if ([map.type isEqualToString:kService] && [self.type isEqualToString:@"map"])
        {
            image.image = serviceImg;
        }
        else if ([self.type isEqualToString:@"map"])
            image.image = [UIImage imageNamed:@""];
    }
    [image.layer setCornerRadius:10.0];
    [image.layer setMasksToBounds:YES];
    [button addSubview:image];
    //name
    UILabel *name;
    if ([annotate isKindOfClass:[MKUserLocation class]] || self.mapType == Search)
    {
        xPos   = 7.0;
        yPos   = 0.0;
        width  = mapListView.frame.size.width - 40.0;
        height = 10.0;
        if (self.mapType == Search)
        {
            NSString * string = [self.searchCoordinates valueForKey:@"place"];
            name = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:string];
        }
        else
        {
            name = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:[[UserManager shareUserManager] currentAddress]];
        }
        [name setFont:[[Configuration shareConfiguration] yoReferFontWithSize:12.0]];
        xPos = mapListView.frame.size.width - 40.0;
        yPos = mapListView.frame.size.height/2 - 20.0;
        width = 40.0;
        height = 40.0;
        UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        rightArrow.image = rightArrowImg;
        [button addSubview:rightArrow];
    }
    else
    {
        xPos = image.frame.origin.x + image.frame.size.width + 5.0;
        yPos = 0.0;
        width = 105.0;
        height = 10.0;
        NSMutableString *string = [[NSMutableString alloc]init];
        [string appendString:(self.mapType == Others)?([[self.response objectAtIndex:view.tag] objectForKey:kName] != nil && [[[self.response objectAtIndex:view.tag] objectForKey:kName] length] > 0)?[[self.response objectAtIndex:view.tag] objectForKey:kName]:@"":map.name];
        [string appendString:[NSString stringWithFormat:@"\n%@",(self.mapType == Others)?[[self.response objectAtIndex:view.tag] objectForKey:kCategory]:(self.mapType == Search && self.isSearch && [self.response count] <=0)?[self.searchCoordinates objectForKey:kPlace]:map.category]];
        name = [self createLabelWithFrame:CGRectMake(xPos, yPos, width, height) text:string];
        xPos = mapListView.frame.size.width - 40.0;
        yPos = mapListView.frame.size.height/2 - 20.0;
        width = 40.0;
        height = 40.0;
        UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
        rightArrow.image = rightArrowImg;
        [button addSubview:rightArrow];
    }
    //pop up arrow
    xPos = calloutView.frame.size.width/2 - 10.0;
    yPos = mapListView.frame.origin.y + mapListView.frame.size.height;
    width = 20.0;
    height = 25.0;
    UIImageView *popUpArrow = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    popUpArrow.image = popupDown;
    [calloutView addSubview:popUpArrow];
    self.previousView = calloutView;
    [button addSubview:name];
    [view.superview addSubview:calloutView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
    if(self.mapType == Offers)
        [self.previousView setHidden:YES];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    //MKAnnotationViewDragState *state = mkann
    NSTimeInterval delay = 0.0;
    for(MKAnnotationView *view in views) {
        CGRect endFrame = view.frame;
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.mapView.frame.size.height, view.frame.size.width, view.frame.size.height);
        [UIView animateWithDuration:0.05
                              delay:delay
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.frame = endFrame;
                         } completion:nil];
        delay += 0.05;
    }
    
}


#pragma mark - Button delegate
-(void)mapReferNowBtnTapped:(UIButton *)sender
{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
    NSMutableArray *array;
    if ([categoryArray  count] > 0)
    {
        array = [[NSMutableArray alloc]init];
        for (NSDictionary *dictionary in [categoryArray valueForKey:kPlace])
        {
            CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
            [array addObject:places];
        }
    }
    CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
    [dictionary setValue:category.categoryName forKey:kCategory];
    [dictionary setValue:category.categoryID forKey:@"categoryid"];
    if (sender.tag == kPinViewTag) {
        [dictionary setValue:self.pinCity forKey:kCity];
        [dictionary setValue:self.pinCity forKey:@"searchtext"];
        [dictionary setValue:self.pinAddress forKey:kLocation];
        [dictionary setValue:[NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.latitude] forKey:kLatitude];
        [dictionary setValue:[NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.longitude] forKey:kLongitude];
    }
    else
    {
        [dictionary setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] currentCity]:@"" forKey:kCity];
        [dictionary setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] currentCity]:@"" forKey:@"searchtext"];
        [dictionary setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kLocation];
        [dictionary setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
        [dictionary setValue:([[UserManager shareUserManager] isLocation])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
    }
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
    [dictionary setValue:kPlace forKey:kCategorytype];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
    ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:self];
    [self.navigationController pushViewController:vctr animated:YES];
}
- (void)mapViewTappedBtnTapped:(UIButton *)sender
{
    if(self.mapType == Others)
    {
        NSDictionary *map = [self.response objectAtIndex:sender.tag];
        if ([[map valueForKey:kNewRefer] boolValue])
        {
            if ([[NSString stringWithFormat:@"%@",[map valueForKey:kLatitude]] length] > 0 && [[NSString stringWithFormat:@"%@",[map valueForKey:kLatitude]] length] > 0)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                [self.navigationController popViewControllerAnimated:YES];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
                NSMutableArray *array;
                if ([categoryArray  count] > 0)
                {
                    array = [[NSMutableArray alloc]init];
                    for (NSDictionary *dictionary in [categoryArray valueForKey:kPlace])
                    {
                        CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
                        [array addObject:places];
                    }
                }
                CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
                [dictionary setValue:category.categoryName forKey:kCategory];
                [dictionary setValue:category.categoryID forKey:@"categoryid"];
                [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentCity]:@"" forKey:kAddress];
                [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] currentAddress]:@"" forKey:kLocation];
                [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] latitude]:@"" forKey:kLatitude];
                [dictionary setValue:([[UserManager shareUserManager] getLocationService])?[[UserManager shareUserManager] longitude]:@"" forKey:kLongitude];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
                [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ismaprefer"];
                [dictionary setValue:@"Place" forKey:kCategorytype];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
                if ([self.delegate respondsToSelector:@selector(LocationReferWithDetail:)])
                {
                    [self.delegate LocationReferWithDetail:dictionary];
                }
            }
        }else
        {
            if ([[map valueForKey:@"isentity"] boolValue])
            {
                [self.navigationController popViewControllerAnimated:YES];
                
            }else
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ismap"];
                [dic setValue:[map objectForKey:kName] forKey:kName];
                [dic setValue:[map objectForKey:kType] forKey:kType];
                [dic setValue:[map objectForKey:kCategory] forKey:kCategory];
                [dic setValue:[map objectForKey:kLocality] forKey:kLocality];
                [dic setValue:[map objectForKey:kCity] forKey:kCity];
                [dic setValue:[map objectForKey:kPhone] forKey:kPhone];
                [dic setValue:[map objectForKey:kPosition] forKey:kPosition];
                [dic setValue:[map objectForKey:kWeb] forKey:kWeb];
                [dic setValue:[[self.response objectAtIndex:0] valueForKey:kEntity] forKey:kEntity];
                [dic setValue:[map objectForKey:kReferCount] forKey:kReferCount];
                [dic setValue:[map objectForKey:@"mediaCount"] forKey:kMediaCount];
                [dic setValue:[map objectForKey:@""] forKey:kMediaLinks];
                [dic setValue:[map valueForKey:@"entityid"] forKey:@"entityid"];
                [dic setValue:[map objectForKey:kImage] forKey:kMediaId];
                [dic setValue:[map objectForKey:kLatitude] forKey:kLatitude];
                [dic setValue:[map objectForKey:kLongitude] forKey:kLongitude];
                [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ismap"];
                [dic setValue:[map valueForKey:kMessage] forKey:kMessage];
                [dic setValue:[map valueForKey:kFromWhere] forKey:kFromWhere];
                EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:dic];
                [self.navigationController pushViewController:vctr animated:YES];
            }
        }
    }
    else
    {
        if (self.isSearch && [self.response count] <=0)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setValue:[self.searchCoordinates objectForKey:kLatitude] forKey:kLatitude];
            [dict setValue:[self.searchCoordinates objectForKey:kLongitude] forKey:kLongitude];
            [dict setValue:[self.searchCoordinates objectForKey:kPlace] forKey:kPlace];
            NSString *place = [self.searchCoordinates objectForKey:kPlace];
            NSString *lat  =[self.searchCoordinates objectForKey:kLatitude];
            NSString *lon  =[self.searchCoordinates objectForKey:kLongitude];
            if ([self.delegate respondsToSelector:@selector(getCurrentAddressDetail:)])
            {
                [self.delegate getCurrentAddressDetail:dict];
            }
            NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
            NSArray *categoryArray = [[CoreData shareData] getCategoryAskWithLoginId:[[UserManager shareUserManager] number]];
            NSMutableArray *array;
            if ([categoryArray  count] > 0)
            {
                array = [[NSMutableArray alloc]init];
                for (NSDictionary *dictionary in [categoryArray valueForKey:kPlace])
                {
                    CategoryType *places = [CategoryType getPlaceFromResponse:dictionary];
                    [array addObject:places];
                }
            }
            CategoryType *category =  (CategoryType *)[array objectAtIndex:0];
            [dictionary setValue:category.categoryName forKey:kCategory];
            [dictionary setValue:category.categoryID forKey:@"categoryid"];
            [dictionary setValue:place forKey:kAddress];
            [dictionary setValue:place forKey:kLocation];
            [dictionary setValue:lat forKey:kLatitude];
            [dictionary setValue:lon forKey:kLongitude];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kNewRefer];
            [dictionary setValue:[NSNumber numberWithBool:NO] forKey:kIsEntiyd];
            [dictionary setValue:@"Place" forKey:kCategorytype];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:kRefer];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"ismaprefer"];
            if ([self.delegate respondsToSelector:@selector(LocationReferWithDetail:)])
            {
                [self.delegate LocationReferWithDetail:dictionary];
            }
            if ([self.type isEqualToString:@"map"])
            {
                ReferNowViewController *vctr = [[ReferNowViewController alloc]initWithReferDetail:dictionary delegate:self];
                [self.navigationController pushViewController:vctr animated:YES];
            }else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else
        {
            Map *map = (Map *)[self.response objectAtIndex:sender.tag];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[map.entity valueForKey:kName] forKey:kName];
            [dic setValue:[map.entity valueForKey:kCategory] forKey:kCategory];
            [dic setValue:[map.entity valueForKey:@"referCount"] forKey:kReferCount];
            [dic setValue:[map.entity valueForKey:@"mediaCount"] forKey:kMediaCount];
            [dic setValue:[map.entity valueForKey:@"mediaLinks"] forKey:kMediaLinks];
            [dic setValue:map.entityId forKey:@"entityid"];
            [dic setValue:map.type forKey:kType];
            [dic setValue:map.entity forKey:kEntity];
            [dic setValue:map.dp forKey:kMediaId];
            [dic setValue:[map.entity valueForKey:kCity] forKey:kCity];
            if ([map.type  isEqualToString:kProduct])
            {
                [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] forKey:kLocation];
                [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kLocality] forKey:kLocality];
                [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPhone] forKey:kPhone];
                [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kWebSite] forKey:kWeb];
                [dic setValue:[[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
                [dic setValue:[[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
                [dic setValue:[[[map.entity objectForKey:kPurchasedFrom] objectForKey:kDetail] objectForKey:kCity] forKey:kFromWhere];
            }else
            {
                [dic setValue:[map.entity objectForKey:kPosition] forKey:kLocation];
                [dic setValue:[map.entity objectForKey:kLocality] forKey:kLocality];
                [dic setValue:[map.entity objectForKey:kPhone] forKey:kPhone];
                [dic setValue:[map.entity objectForKey:kWebSite] forKey:@"web"];
                [dic setValue:[[map.entity objectForKey:kPosition] objectAtIndex:0] forKey:kLongitude];
                [dic setValue:[[map.entity objectForKey:kPosition] objectAtIndex:1] forKey:kLatitude];
            }
            [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ismap"];
            EntityViewController *vctr = [[EntityViewController alloc]initWithentityDetail:dic];
            [self.navigationController pushViewController:vctr animated:YES];
        }
    }
}

- (void)getCurrentLocBtnTapped:(UIButton *)button
{
    if(self.mapType != Others)
    {
//        [self.addressTxtField setText:@""];
    }
    self.currentAnnotation = 0;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}




- (IBAction)cancelButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    [self.dropDownView removeFromSuperview];
    self.nIDropDown = nil;
    if (self.searchText != nil && [self.searchText length] > 0)
    {
        self.addressTxtField.text = self.searchText;
        
    }
}

#pragma mark -  gesture recognizer

- (void)bottomViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    NSArray *subviews = [(UIView *)[self.view viewWithTag:kBottomViewTag] subviews];
    UILabel *label = (UILabel *)[subviews objectAtIndex:2];
    self.showMap = !self.showMap;
    
    if (!self.showMap) {
        [label setText:@"Show Map"];
        [self.mapView removeAnnotations:self.mapView.annotations];
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionPush;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.fillMode = kCAFillModeForwards;
        transition.duration = 0.5;
        transition.subtype = kCATransitionFromTop;
        [[self.tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
        [self.tableView reloadData];
        self.tableView.scrollEnabled = YES;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }else if (view.tag == kPinViewTag){
                [view removeFromSuperview];
            }
        }
        
    }
    else
    {
        [label setText:@"Show List"];
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionPush;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.fillMode = kCAFillModeForwards;
        transition.duration = 0.5;
        transition.subtype = kCATransitionFromTop;
        [[self.tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
        [self.tableView reloadData];
        self.tableView.scrollEnabled = NO;
    }
    
}

- (void)mapTapped:(UIGestureRecognizer *)sender
{
    [self.previousView setHidden:YES];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view setHidden:NO];
        }else if (view.tag == kPinViewTag){
            [view setHidden:NO];
        }
    }
    
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
#pragma mark - didReceiveMemoryWarning
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
