//
//  DCPathButton.m
//  DCPathButton
//
//  Created by tang dixi on 30/7/14.
//  Copyright (c) 2014 Tangdxi. All rights reserved.
//

#import "DCPathButton.h"
#import "Configuration.h"


@interface DCPathButton ()<DCPathItemButtonDelegate>
{
    CGFloat xorigin,yorigin;
    
    UIView *subView;
}
#pragma mark - Private Property

@property (strong, nonatomic) UIImage *centerImage;
@property (strong, nonatomic) UIImage *centerHighlightedImage;
@property (strong, nonatomic) UILabel *askLabel;
@property (assign, nonatomic, getter = isBloom) BOOL bloom;

@property (assign, nonatomic) CGSize foldedSize;
@property (assign, nonatomic) CGSize bloomSize;

@property (assign, nonatomic) CGPoint foldCenter;
@property (assign, nonatomic) CGPoint bloomCenter;

@property (assign, nonatomic) CGPoint pathCenterButtonBloomCenter;

@property (assign, nonatomic) CGPoint expandCenter;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton  *askBtn;

@property (strong, nonatomic) UIImageView  *bgImageView;


@property (strong, nonatomic) UIButton *pathCenterButton;
@property (strong, nonatomic) NSMutableArray *itemButtons;

@property (assign, nonatomic) SystemSoundID bloomSound;
@property (assign, nonatomic) SystemSoundID foldSound;
@property (assign, nonatomic) SystemSoundID selectedSound;


@end

@implementation DCPathButton
#pragma mark - Initialization

- (id)initWithCenterImage:(UIImage *)centerImage hilightedImage:(UIImage *)centerHighlightedImage
{
    return [self initWithButtonFrame:CGRectZero CenterImage:centerImage hilightedImage:centerHighlightedImage];
}

- (id)initWithButtonFrame:(CGRect)centerBtnFrame CenterImage:(UIImage *)centerImage hilightedImage:(UIImage *)centerHighlightedImage
{
    if (self = [super init]) {
        
        // Configure center and high light center image
        //
        self.centerImage = centerImage;
        self.centerHighlightedImage = centerHighlightedImage;
        
        // Init button and image array
        //
        self.itemButtonImages = [[NSMutableArray alloc]init];
        self.itemButtonHighlightedImages = [[NSMutableArray alloc]init];
        self.itemButtons = [[NSMutableArray alloc]init];
        
        // Configure views
        //
        if (centerBtnFrame.size.width == 0 && centerBtnFrame.size.height == 0) {
            [self configureViewsLayoutWithButtonSize:self.centerImage.size];
        }
        else {
            [self configureViewsLayoutWithButtonSize:centerBtnFrame.size];
            self.dcButtonCenter = centerBtnFrame.origin;
        }
        
        // Configure sounds
        //
        xorigin=self.frame.origin.x;
        yorigin=self.frame.origin.y;
        NSLog(@"frame=%f %f ",self.frame.origin.x,self.frame.origin.y);
        [self configureSounds];
    }
    return self;
}

- (void)configureViewsLayoutWithButtonSize:(CGSize)centerBtnSize
{
    // Init some property only once
    //
    self.foldedSize = centerBtnSize;
    self.bloomSize = [UIScreen mainScreen].bounds.size;
    
    self.bloom = NO;
    self.bloomRadius = 105.0f;
    
    // Configure the view's center, it will change after the frame folded or bloomed
    //
    self.foldCenter = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height - 25.5f);
    self.bloomCenter = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height / 2);
    
    // Configure the DCPathButton's origin frame
    //
    self.frame = CGRectMake(0, 0, self.foldedSize.width, self.foldedSize.height);
    self.backgroundColor=[UIColor clearColor];
    // Default set the foldCenter as the DCPathButton's center
    //
    self.center = self.foldCenter;
    
    // Configure center button
    //
    _pathCenterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.centerImage.size.width, self.centerImage.size.height)];
    [_pathCenterButton setImage:self.centerImage forState:UIControlStateNormal];
    [_pathCenterButton setImage:self.centerHighlightedImage forState:UIControlStateHighlighted];
    [_pathCenterButton addTarget:self action:@selector(centerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    _pathCenterButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:_pathCenterButton];
    
    
    // Configure bottom view
    //
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, -20, self.bloomSize.width * 2, self.bloomSize.height-29)];
    _bottomView.backgroundColor = [UIColor blackColor];
    _bottomView.alpha = 0.0f;
    
    
    // Make bottomView's touch can delay superView witch like UIScrollView scrolling
    //
    _bottomView.userInteractionEnabled = YES;
    UIGestureRecognizer* tapGesture = [[UIGestureRecognizer alloc] initWithTarget:nil action:nil];
    tapGesture.delegate = self;
    [_bottomView addGestureRecognizer:tapGesture];
    
    
    
    
    
}

- (void)configureSounds
{
    // Configure bloom sound
    //
    NSString *bloomSoundPath = [[NSBundle mainBundle]pathForResource:@"bloom" ofType:@"caf"];
    NSURL *bloomSoundURL = [NSURL fileURLWithPath:bloomSoundPath];
    
    // Configure fold sound
    //
    NSString *foldSoundPath = [[NSBundle mainBundle]pathForResource:@"fold" ofType:@"caf"];
    NSURL *foldSoundURL = [NSURL fileURLWithPath:foldSoundPath];
    
    // Configure selected sound
    //
    NSString *selectedSoundPath = [[NSBundle mainBundle]pathForResource:@"selected" ofType:@"caf"];
    NSURL *selectedSoundURL = [NSURL fileURLWithPath:selectedSoundPath];
    
    if (self.soundsEnable) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)bloomSoundURL, &_bloomSound);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)foldSoundURL, &_foldSound);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)selectedSoundURL, &_selectedSound);
    }
    else {
        AudioServicesDisposeSystemSoundID(_bloomSound);
        AudioServicesDisposeSystemSoundID(_foldSound);
        AudioServicesDisposeSystemSoundID(_selectedSound);
    }
}

#pragma mark - Configure Center Button Images

- (void)setCenterImage:(UIImage *)centerImage
{
    if (!centerImage) {
        NSLog(@"Load center image failed ... ");
        return ;
    }
    _centerImage = centerImage;
}

- (void)setCenterHighlightedImage:(UIImage *)highlightedImage
{
    if (!highlightedImage) {
        NSLog(@"Load highted image failed ... ");
        return ;
    }
    _centerHighlightedImage = highlightedImage;
}

#pragma mark - Configure Button's Center

- (void)setDcButtonCenter:(CGPoint)dcButtonCenter {
    
    _dcButtonCenter = dcButtonCenter;
    
    // reset the DCPathButton's center
    //
    self.center = dcButtonCenter;
}


#pragma mark - Configure Expand Center Point

- (void)setPathCenterButtonBloomCenter:(CGPoint)centerButtonBloomCenter
{
    // Just set the bloom center once
    //
    if (_pathCenterButtonBloomCenter.x == 0) {
        _pathCenterButtonBloomCenter = centerButtonBloomCenter;
    }
    return ;
}

#pragma mark - Configure appearance

- (void)setSoundsEnable:(BOOL)soundsEnable
{
    _soundsEnable = soundsEnable;
    [self configureSounds];
}


#pragma mark - Expand Status

- (BOOL)isBloom
{
    return _bloom;
}

#pragma mark - Center Button Delegate

- (void)centerButtonTapped
{
    self.isBloom? [self pathCenterButtonFold] : [self pathCenterButtonBloom];
}

#pragma mark - Caculate The Item's End Point

- (CGPoint)createEndPointWithRadius:(CGFloat)itemExpandRadius andAngel:(CGFloat)angel
{
    switch (self.bloomDirection) {
        case DCPathButtonBloomTop:
            return CGPointMake(self.pathCenterButtonBloomCenter.x - cosf(angel * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y - sinf(angel * M_PI) * itemExpandRadius);
        case DCPathButtonBloomLeft:
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 0.5) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 0.5) * M_PI) * itemExpandRadius);
        case DCPathButtonBloomBottom:
            return CGPointMake(self.pathCenterButtonBloomCenter.x - cosf((angel + 1) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y - sinf((angel + 1) * M_PI) * itemExpandRadius);
        case DCPathButtonBloomRight:
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 1.5) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 1.5) * M_PI) * itemExpandRadius);
        default:
            break;
    }
}

#pragma mark - Center Button Fold

- (void)pathCenterButtonFold
{
    // Play fold sound
    //
    if (self.soundsEnable) {
        AudioServicesPlaySystemSound(self.foldSound);
    }
    
    // Load item buttons from array
    //
    for (int i = 1; i <= self.itemButtons.count; i++) {
        
        DCPathItemButton *itemButton = self.itemButtons[i - 1];
        
        CGFloat currentAngel = i / ((CGFloat)self.itemButtons.count + 1);
        CGPoint farPoint = [self createEndPointWithRadius:self.bloomRadius + 5.0f andAngel:currentAngel];
        
        
        NSLog(@"farPoint x=%f y=%f",farPoint.x,farPoint.y);
        
        CAAnimationGroup *foldAnimation = [self foldAnimationFromPoint:itemButton.center withFarPoint:farPoint];
        
        [itemButton.layer addAnimation:foldAnimation forKey:@"foldAnimation"];
        itemButton.center = self.pathCenterButtonBloomCenter;
        
    }
    
    [self bringSubviewToFront:self.pathCenterButton];
    
    // Resize the DCPathButton's frame to the foled frame and remove the item buttons
    //
    [self resizeToFoldedFrame];
    
    //    _askBtn.frame=CGRectMake(([COMMON getScreenSize].width-58)/2,subView.frame.origin.y+100, 57, 58);
    _askBtn.alpha=0.0;
    self.askLabel.alpha = 0.0;
    
}
-(IBAction)askAction:(id)sender
{
    [self resizeToFoldedFrame];
    [_delegate itemButtonTappedAtIndex:[sender tag]];
    
}
- (void)resizeToFoldedFrame
{
    
    if (self.centerBtnRotationEnable) {
        [UIView animateWithDuration:0.0618f * 3
                              delay:0.0618f * 2
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _pathCenterButton.transform = CGAffineTransformMakeRotation(0);
                         }
                         completion:nil];
    }
    
    [UIView animateWithDuration:0.1f
                          delay:0.35f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _bottomView.alpha = 0.0f;
                     }
                     completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // Remove the button items from the superview
        //
        [self.itemButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.frame = CGRectMake(xorigin, yorigin, self.foldedSize.width, self.foldedSize.height);
        //self.center = _dcButtonCenter;
        
        self.pathCenterButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self.bottomView removeFromSuperview];
        [self.askBtn removeFromSuperview];
        
        NSLog(@"frame fold=%f %f",self.frame.origin.x,self.frame.origin.y);
        
    });
    
    _bloom = NO;
}

- (CAAnimationGroup *)foldAnimationFromPoint:(CGPoint)endPoint withFarPoint:(CGPoint)farPoint
{
    // 1.Configure rotation animation
    //
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[@(0), @(M_PI), @(M_PI * 2)];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.duration = 0.35f;
    
    // 2.Configure moving animation
    //
    CAKeyframeAnimation *movingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // Create moving path
    //
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, self.pathCenterButtonBloomCenter.x, self.pathCenterButtonBloomCenter.y);
    
    movingAnimation.keyTimes = @[@(0.0f), @(0.75), @(1.0)];
    
    movingAnimation.path = path;
    movingAnimation.duration = 0.35f;
    CGPathRelease(path);
    
    // 3.Merge animation together
    //
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = @[rotationAnimation, movingAnimation];
    animations.duration = 0.35f;
    
    return animations;
}

#pragma mark - Center Button Bloom

- (void)pathCenterButtonBloom
{
    
    // Play bloom sound
    //
    if (self.soundsEnable) {
        AudioServicesPlaySystemSound(self.bloomSound);
    }
    
    // Configure center button bloom
    //
    // 1. Store the current center point to 'centerButtonBloomCenter
    //
    self.pathCenterButtonBloomCenter = self.center;
    
    // 2. Resize the DCPathButton's frame
    //
    self.frame = CGRectMake(0, 0, self.bloomSize.width, self.bloomSize.height);
    self.center = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height / 2);
    
    // [self insertSubview:self.askBtn belowSubview:self.bottomView];
    [self insertSubview:self.bottomView belowSubview:self.pathCenterButton];
    
    // 3. Excute the bottom view alpha animation
    //
    [UIView animateWithDuration:0.0618f * 3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _bottomView.alpha = 0.618f;
                     }
                     completion:nil];
    
    // 4. Excute the center button rotation animation
    //
    //    if (self.centerBtnRotationEnable) {
    //        [UIView animateWithDuration:0.1575f
    //                         animations:^{
    //                             _pathCenterButton.transform = CGAffineTransformMakeRotation(-0.75f * M_PI);
    //                         }];
    //    }
    
    self.pathCenterButton.center = self.pathCenterButtonBloomCenter;
    
    // 5. Excute the bloom animation
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    CGFloat heigth=0,width=0,xOrigin=0;
    NSString *imgName=@"";
    
    if (frame.size.width!=320) {
        heigth=176;
        width=351;
        imgName=@"menu-dial-320px.png";
        xOrigin=(frame.size.width-width)/2;
        
        subView=[[UIView alloc]initWithFrame:CGRectMake(0, yorigin-151-14, frame.size.width, heigth)];
        
    }else
    {
        heigth=151;
        width=302;
        imgName=@"menu-dial.png";
        xOrigin=(frame.size.width-width)/2;
        
        subView=[[UIView alloc]initWithFrame:CGRectMake(0, yorigin-139, frame.size.width, heigth)];
    }
    
    
    subView.backgroundColor=[UIColor clearColor];
    
    
    _bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xOrigin ,0, width, heigth)];
    _bgImageView.image=[UIImage imageNamed:imgName];
    
    [subView addSubview:_bgImageView];
    
    
    [self insertSubview:subView belowSubview:self.pathCenterButton];
    
    _askBtn=[[UIButton alloc]initWithFrame:CGRectMake((frame.size.width-58)/2,subView.frame.origin.y , 57, 58)];
    [_askBtn setImage:[UIImage imageNamed:@"ask.png"] forState:UIControlStateNormal];
    _askBtn.alpha=0.0f;
    [_askBtn setTag:20];
    [_askBtn addTarget:self action:@selector(askAction:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:_askBtn belowSubview:self.pathCenterButton];
    
    self.askLabel = [[UILabel alloc]initWithFrame:CGRectMake((frame.size.width-58)/2, subView.frame.origin.y - 42.0, 58.0,20.0)];
    [self.askLabel setText:@"Ask"];
    self.askLabel.alpha=0.0f;
    [self.askLabel setFont:[[Configuration shareConfiguration] yoReferFontWithSize:14.0]];
    [self.askLabel setTextAlignment:NSTextAlignmentCenter];
    [self.askLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:self.askLabel];
    
    //
    CGFloat basicAngel = 200 / (self.itemButtons.count + 1) ;
    
    for (int i = 1; i <= self.itemButtons.count; i++) {
        
        DCPathItemButton *pathItemButton = self.itemButtons[i -  1];
        
        pathItemButton.delegate = self;
        pathItemButton.tag = i - 1;
        if (frame.size.width!=320){
            if (i == 4)
                pathItemButton.transform = CGAffineTransformMakeTranslation(-2, -33);
            else
                pathItemButton.transform = CGAffineTransformMakeTranslation(1, -35);
            
        }
        else
        {
            pathItemButton.transform = CGAffineTransformMakeTranslation(1, -12);
        }
        
        pathItemButton.alpha = 1.0f;
        
        // 1. Add pathItem button to the view
        //
        CGFloat currentAngel = (basicAngel * i)/190;
        
        pathItemButton.center = self.pathCenterButtonBloomCenter;
       // pathItemButton.backgroundColor = [UIColor blackColor];
        [self insertSubview:pathItemButton belowSubview:self.pathCenterButton];
        
        
        // 2.Excute expand animation
        //
        CGPoint endPoint = [self createEndPointWithRadius:self.bloomRadius andAngel:currentAngel];
        CGPoint farPoint = [self createEndPointWithRadius:self.bloomRadius + 10.0f andAngel:currentAngel];
        CGPoint nearPoint = [self createEndPointWithRadius:self.bloomRadius - 5.0f andAngel:currentAngel];
        
        CAAnimationGroup *bloomAnimation = [self bloomAnimationWithEndPoint:endPoint
                                                                andFarPoint:farPoint
                                                               andNearPoint:nearPoint];
        
        [pathItemButton.layer addAnimation:bloomAnimation forKey:@"bloomAnimation"];
        pathItemButton.center = endPoint;
        
        NSLog(@"dcpathFrame=%f %f",pathItemButton.frame.origin.x,pathItemButton.frame.origin.y);
        
    }
    
    _bloom = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        _askBtn.frame=CGRectMake((frame.size.width-58)/2,subView.frame.origin.y-100, 57, 58);
        _askBtn.alpha=1.0;
        self.askLabel.alpha=1.0;
    }];
}

- (CAAnimationGroup *)bloomAnimationWithEndPoint:(CGPoint)endPoint andFarPoint:(CGPoint)farPoint andNearPoint:(CGPoint)nearPoint
{
    
    // 1.Configure rotation animation
    //
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[@(0.0), @(- M_PI), @(- M_PI * 1.5), @(- M_PI * 2)];
    rotationAnimation.duration = 0.5f;
    rotationAnimation.keyTimes = @[@(0.0), @(0.3), @(0.6), @(1.0)];
    
    // 2.Configure moving animation
    //
    CAKeyframeAnimation *movingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // Create moving path
    //
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.pathCenterButtonBloomCenter.x, self.pathCenterButtonBloomCenter.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, nearPoint.x, nearPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    movingAnimation.path = path;
    movingAnimation.keyTimes = @[@(0.0), @(0.5), @(0.7), @(1.0)];
    movingAnimation.duration = 0.5f;
    CGPathRelease(path);
    
    // 3.Merge two animation together
    //
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = @[movingAnimation, rotationAnimation];
    animations.duration = 0.5f;
    animations.delegate = self;
    
    return animations;
}

#pragma mark - Add PathButton Item

- (void)addPathItems:(NSArray *)pathItemButtons
{
    [self.itemButtons addObjectsFromArray:pathItemButtons];
}

#pragma mark - DCPathButton Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Tap the bottom area, excute the fold animation
    [self pathCenterButtonFold];
}

#pragma mark - DCPathButton Item Delegate

- (void)itemButtonTapped:(DCPathItemButton *)itemButton
{
    if ([_delegate respondsToSelector:@selector(itemButtonTappedAtIndex:)]) {
        
        DCPathItemButton *selectedButton = self.itemButtons[itemButton.tag];
        
        // Play selected sound
        //
        if (self.soundsEnable) {
            AudioServicesPlaySystemSound(self.selectedSound);
        }
        
        // Excute the explode animation when the item is seleted
        //
        [UIView animateWithDuration:0.0618f * 5
                         animations:^{
                             selectedButton.transform = CGAffineTransformMakeScale(3, 3);
                             selectedButton.alpha = 0.0f;
                         }];
        
        // Excute the dismiss animation when the item is unselected
        //
        for (int i = 0; i < self.itemButtons.count; i++) {
            if (i == selectedButton.tag) {
                continue;
            }
            DCPathItemButton *unselectedButton = self.itemButtons[i];
            [UIView animateWithDuration:0.0618f * 2
                             animations:^{
                                 unselectedButton.transform = CGAffineTransformMakeScale(0, 0);
                             }];
        }
        
        // Excute the delegate method
        //
        [_delegate itemButtonTappedAtIndex:itemButton.tag];
        
        // Resize the DCPathButton's frame
        //
        [self resizeToFoldedFrame];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0)
{
    return YES;
}
@end
