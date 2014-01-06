//
//  DrawingViewController.m
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 lutan. All rights reserved.
//

#import "DrawingViewController.h"
#import "SipStackUtils.h"
#import "MobClick.h"
#import "Utils.h"

#define ColourButtonStartTag 10000
#define WidthButtonStartTag 100000
#define EraseWidthButtonStartTag 1000000

@interface DrawingViewController (){
    BOOL isShowWidthButton;
    BOOL isShowEraseWidthButton;
    double beginTime;
}

@property (weak, nonatomic) UIButton *penButton;
@property (weak, nonatomic) UIButton *eraseButton;

@property (nonatomic, strong) NSMutableArray *drawings;
@property (weak, nonatomic) UIView *changeColorBar;
@property (weak, nonatomic) UIView *toolBar;
@end

@implementation DrawingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //_drawingView = (HandDrawingView *) self.view;
    beginTime = [[NSDate date] timeIntervalSince1970];
    HandDrawingView *view;
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userData integerForKey:kDoodleLineWidth];
    if ((index < 1) || (index > 5)) {
        [userData setInteger:1 forKey:kDoodleLineWidth];
        [userData synchronize];
    }
    index = [userData integerForKey:kDoodleEraseWidth];
    if ((index < 1) || (index > 5)) {
        [userData setInteger:1 forKey:kDoodleEraseWidth];
        [userData synchronize];
    }
    index = [userData integerForKey:kDoodleLineColor];
    if ((index < 1) || (index > 7) ) {
        [userData setInteger:1 forKey:kDoodleLineColor];
        [userData synchronize];
    }
    
    //change color buttons
    UIView *changeColorBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 45)];
    changeColorBar.backgroundColor = [UIColor colorWithRed:238.0 / 255.0 green:238.0 / 255.0 blue:238.0 / 255.0 alpha:1.0];
    [self.view addSubview:changeColorBar];
    UIView *changeColorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 1)];
    changeColorLineView.backgroundColor = [UIColor colorWithRed:180.0 / 255.0 green:180.0 / 255.0 blue:180.0 / 255.0 alpha:180.0 / 255.0];
    [changeColorBar addSubview:changeColorLineView];
    [self addChangeColorButtonsToView:changeColorBar];
    _changeColorBar = changeColorBar;
    
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
    toolbar.backgroundColor = [UIColor colorWithRed:238.0 / 255.0 green:238.0 / 255.0 blue:238.0 / 255.0 alpha:1.0];
    [self.view addSubview:toolbar];
    UIView *toolLineView = [[UIView alloc] initWithFrame:CGRectMake(0, toolbar.frame.origin.y - 1, 320, 1)];
    toolLineView.backgroundColor = [UIColor colorWithRed:180.0 / 255.0 green:180.0 / 255.0 blue:180.0 / 255.0 alpha:180.0 / 255.0];
    [self.view addSubview:toolLineView];
    [self addToolButtonToView:toolbar];
    _toolBar = toolbar;
    
    if (IS_OS_7_OR_LATER) {
        changeColorBar.frame = CGRectMake(0, 64, 320, 45);
        view = [[HandDrawingView alloc] initWithFrame:CGRectMake(0, 109, self.view.frame.size.width, self.view.frame.size.height - 64 - 90)];
    }
    else{
        changeColorBar.frame = CGRectMake(0, 0, 320, 45);
        view = [[HandDrawingView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 44 - 90)];
        toolbar.frame = CGRectMake(0, self.view.frame.size.height - 90, 320, 44);
        toolLineView.frame = CGRectMake(0, self.view.frame.size.height - 91, 320, 1);
    }
    _drawingView = view;
    _drawingView.delegate = self;
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    [self addCHangeWidthButtonToView:self.view];
    [self addCHangeEraseWidthButtonToView:self.view];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [cancelButton setImage:[UIImage imageNamed:@"arrowLeft.png"]];
    self.navigationItem.leftBarButtonItem = cancelButton;
    if (!IS_OS_7_OR_LATER) {
        UIImage *backButton = [[UIImage imageNamed:@"barButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButton = [[UIImage imageNamed:@"barButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonPressed = [[UIImage imageNamed:@"barButtonBackPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonPressed = [[UIImage imageNamed:@"barButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonDisabled = [[UIImage imageNamed:@"barButtonBackDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonDisabled = [[UIImage imageNamed:@"barButtonDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginEvent:@"handWriting"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endEvent:@"handWriting"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _drawings = nil;
}

- (void)addChangeColorButtonsToView:(UIView *)view
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger colorIndex = [userData integerForKey:kDoodleLineColor];
    for (int i = 1; i < 7; ++i) {
        UIImage *normalImage;
        if (i == colorIndex) {
            normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_color_%d_selected.png", i]];
        }
        else{
            normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_color_%d.png", i]];
        }
        UIButton *colorButton = (UIButton *)[view viewWithTag:ColourButtonStartTag + i];
        if (colorButton == nil) {
            colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [colorButton addTarget:self action:@selector(pressedColorButton:) forControlEvents:UIControlEventTouchUpInside];
            colorButton.frame = CGRectMake(27.5 + (i - 1) * 53 - normalImage.size.width / 2.0, (view.frame.size.height - normalImage.size.width) / 2.0, normalImage.size.width, normalImage.size.height);
            colorButton.tag = ColourButtonStartTag + i;
            [view addSubview:colorButton];
        }
        [colorButton setImage:normalImage forState:UIControlStateNormal];
    }
}

- (void)addToolButtonToView:(UIView *)view
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger colorIndex = [userData integerForKey:kDoodleLineColor];
    UIImage *pen = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_pen_%d_selected.png", colorIndex]];
    UIButton *penButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [penButton addTarget:self action:@selector(pressedPenButton:) forControlEvents:UIControlEventTouchUpInside];
    [penButton setImage:pen forState:UIControlStateNormal];
    penButton.frame = CGRectMake(0, 0, pen.size.width, pen.size.height);
    penButton.center = CGPointMake(28, view.frame.size.height / 2.0);
    [view addSubview:penButton];
    _penButton = penButton;
    
    UIImage *eraser = [UIImage imageNamed:@"doodle_eraser.png"];
    UIButton *eraserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eraserButton addTarget:self action:@selector(pressedEraserButton:) forControlEvents:UIControlEventTouchUpInside];
    [eraserButton setImage:eraser forState:UIControlStateNormal];
    eraserButton.frame = CGRectMake(0, 0, eraser.size.width, eraser.size.height);
    eraserButton.center = CGPointMake(28 + 66, view.frame.size.height / 2.0);
    [view addSubview:eraserButton];
    _eraseButton = eraserButton;
    
    UIImage *undo = [UIImage imageNamed:@"doodle_undo.png"];
    UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [undoButton addTarget:self action:@selector(pressedUndoButton:) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setImage:[UIImage imageNamed:@"doodle_undo_disable.png"] forState:UIControlStateDisabled];
    [undoButton setImage:undo forState:UIControlStateNormal];
    undoButton.frame = CGRectMake(0, 0, undo.size.width, undo.size.height);
    undoButton.center = CGPointMake(28 + 66 * 2, view.frame.size.height / 2.0);
    [view addSubview:undoButton];
    _undoButton = undoButton;
    
    UIImage *trash = [UIImage imageNamed:@"doodle_trash.png"];
    UIButton *trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [trashButton addTarget:self action:@selector(pressedTrashButton:) forControlEvents:UIControlEventTouchUpInside];
    [trashButton setImage:[UIImage imageNamed:@"doodle_trash_disable.png"] forState:UIControlStateDisabled];
    [trashButton setImage:trash forState:UIControlStateNormal];
    trashButton.frame = CGRectMake(0, 0, trash.size.width, trash.size.height);
    trashButton.center = CGPointMake(28 + 66 * 3, view.frame.size.height / 2.0);
    [view addSubview:trashButton];
    _clearAll = trashButton;
    
    UIImage *save = [UIImage imageNamed:@"doodle_download.png"];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setImage:save forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(0, 0, save.size.width, save.size.height);
    saveButton.center = CGPointMake(28 + 66 * 4, view.frame.size.height / 2.0);
    [view addSubview:saveButton];
}

- (void)addCHangeWidthButtonToView:(UIView *)view
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger colorIndex = [userData integerForKey:kDoodleLineWidth];
    for (int i = 1; i < 5; ++i) {
        UIImage *normalImage;
        if (i == colorIndex) {
            normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_width_%d_selected.png", i]];
        }
        else{
            normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_width_%d.png", i]];
        }
        UIButton *widthButton = (UIButton *)[view viewWithTag:WidthButtonStartTag + i];
        if (widthButton == nil) {
            widthButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [widthButton addTarget:self action:@selector(pressedWidthButton:) forControlEvents:UIControlEventTouchUpInside];
            widthButton.frame = CGRectMake(28 - normalImage.size.width / 2.0, (_drawingView.frame.size.height + _drawingView.frame.origin.y + 3), normalImage.size.width, normalImage.size.height);
            widthButton.tag = WidthButtonStartTag + i;
            [view addSubview:widthButton];
            [view bringSubviewToFront:widthButton];
            widthButton.alpha = 0.0;
        }
        [widthButton setImage:normalImage forState:UIControlStateNormal];
    }
}

- (void)addCHangeEraseWidthButtonToView:(UIView *)view
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger colorIndex = [userData integerForKey:kDoodleEraseWidth];
    for (int i = 1; i < 5; ++i) {
        UIImage *normalImage;
        if (i == colorIndex) {
            normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_width_%d_selected.png", i]];
        }
        else{
            normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_width_%d.png", i]];
        }
        UIButton *widthButton = (UIButton *)[view viewWithTag:EraseWidthButtonStartTag + i];
        if (widthButton == nil) {
            widthButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [widthButton addTarget:self action:@selector(pressedEraseWidthButton:) forControlEvents:UIControlEventTouchUpInside];
            widthButton.frame = CGRectMake(28 - normalImage.size.width / 2.0 + 66, (_drawingView.frame.size.height + _drawingView.frame.origin.y + 3), normalImage.size.width, normalImage.size.height);
            widthButton.tag = EraseWidthButtonStartTag + i;
            [view addSubview:widthButton];
            [view bringSubviewToFront:widthButton];
            widthButton.alpha = 0.0;
        }
        [widthButton setImage:normalImage forState:UIControlStateNormal];
    }
}

- (void)showChangeWidthButton:(BOOL)isDrawingWidth
{
    if (isDrawingWidth) {
        if (isShowWidthButton) {
            return;
        }
        isShowWidthButton = YES;
    }
    else{
        if (isShowEraseWidthButton) {
            return;
        }
        isShowEraseWidthButton = YES;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        for (int i = 1; i < 5; ++i) {
            UIButton *button;
            if (isDrawingWidth) {
                button = (UIButton *)[self.view viewWithTag:WidthButtonStartTag + i];
            }
            else{
                button = (UIButton *)[self.view viewWithTag:EraseWidthButtonStartTag + i];
            }
            button.alpha = 1.0;
            CGRect frame = button.frame;
            button.frame = CGRectMake(frame.origin.x, frame.origin.y - 7 - i * (frame.size.height + 5), frame.size.width, frame.size.height);
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideChangeWidthButton:(BOOL)isDrawingWidth
{
    if (isDrawingWidth) {
        if (!isShowWidthButton) {
            return;
        }
        isShowWidthButton = NO;
    }
    else{
        if (!isShowEraseWidthButton) {
            return;
        }
        isShowEraseWidthButton = NO;
    }
    [UIView animateWithDuration:0.2 animations:^{
        for (int i = 1; i < 5; ++i) {
            UIButton *button;
            if (isDrawingWidth) {
                button = (UIButton *)[self.view viewWithTag:WidthButtonStartTag + i];
            }
            else{
                button = (UIButton *)[self.view viewWithTag:EraseWidthButtonStartTag + i];
            }
            button.alpha = 0.0;
            CGRect frame = button.frame;
            button.frame = CGRectMake(frame.origin.x, frame.origin.y + 7 + i * (frame.size.height + 5), frame.size.width, frame.size.height);
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark --HandDrawingDelegate

- (void)handDrawingDidDraw
{
    if (isShowWidthButton) {
        [self hideChangeWidthButton:YES];
    }
    if (isShowEraseWidthButton) {
        [self hideChangeWidthButton:NO];
    }
    _undoButton.enabled = YES;
    _clearAll.enabled = YES;
}

#pragma mark --Button Callback function--
- (void)pressedColorButton:(UIButton *)button
{
    NSInteger tag = button.tag - ColourButtonStartTag;
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setInteger:tag forKey:kDoodleLineColor];
    [userData synchronize];
    [self addChangeColorButtonsToView:_changeColorBar];
    [self updatePenButton];
    [_drawingView changeDrawLineColorTo:tag];
}

- (void)updatePenButton
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger tag = [userData integerForKey:kDoodleLineColor];
    UIImage *pen;
    if ([_drawingView getDrawingMode]) {
        pen = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_pen_%d_selected.png", tag]];
    }
    else{
        pen = [UIImage imageNamed:[NSString stringWithFormat:@"doodle_pen_%d.png", tag]];
    }
    [_penButton setImage:pen forState:UIControlStateNormal];
}

- (void)updateWidthButtons:(BOOL)isDrawingButton
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSInteger tag;
    if (isDrawingButton) {
      tag = [userData integerForKey:kDoodleLineWidth];

    }
    else{
       tag = [userData integerForKey:kDoodleEraseWidth];
    }
    for (int i = 1; i < 5; ++i) {
        UIButton *button;
        if (isDrawingButton) {
            button = (UIButton *)[self.view viewWithTag:WidthButtonStartTag + i];
        }
        else{
            button = (UIButton *)[self.view viewWithTag:EraseWidthButtonStartTag + i];
        }
        if (i == tag) {
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"doodle_width_%d_selected", tag]] forState:UIControlStateNormal];
        }
        else{
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"doodle_width_%d", i]] forState:UIControlStateNormal];
        }
    }
}

- (void)pressedEraseWidthButton:(UIButton *)button
{
    NSInteger tag = button.tag - EraseWidthButtonStartTag;
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setInteger:tag forKey:kDoodleEraseWidth];
    [userData synchronize];
    [self updateWidthButtons:NO];
    [self hideChangeWidthButton:NO];
    [_drawingView changeEraseLineWidthTo:tag];
}

- (void)pressedWidthButton:(UIButton *)button
{
    NSInteger tag = button.tag - WidthButtonStartTag;
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setInteger:tag forKey:kDoodleLineWidth];
    [userData synchronize];
    [self updateWidthButtons:YES];
    [self hideChangeWidthButton:YES];
    [_drawingView changeDrawLineWidthTo:tag];
}

- (void)pressedPenButton:(UIButton *)button
{
    [_drawingView changeToDrawMode];
    [_eraseButton setImage:[UIImage imageNamed:@"doodle_eraser.png"] forState:UIControlStateNormal];
    [self updatePenButton];
    [self hideChangeWidthButton:NO];
    if (!isShowWidthButton) {
        [self showChangeWidthButton:YES];
    }
    else{
        [self hideChangeWidthButton:YES];
    }
}

- (void)pressedEraserButton:(UIButton *)button
{
    [_drawingView changeToEraseMode];
    UIImage *eraser = [UIImage imageNamed:@"doodle_eraser_selected.png"];
    [button setImage:eraser forState:UIControlStateNormal];
    [self updatePenButton];
    [self hideChangeWidthButton:YES];
    [self showChangeWidthButton:NO];
}

- (void)pressedUndoButton:(UIButton *)button
{
    [_drawingView revoke];
    button.enabled = NO;
    [self hideChangeWidthButton:YES];
    [self hideChangeWidthButton:NO];
    _eraseButton.enabled = YES;
    _clearAll.enabled = YES;
}

- (void)pressedTrashButton:(UIButton *)button
{
    [self hideChangeWidthButton:YES];
    [self hideChangeWidthButton:NO];
    [_drawingView clearAll];
    button.enabled = NO;
}

- (void)pressedSaveButton:(UIButton *)button
{
    [self hideChangeWidthButton:YES];
    [self hideChangeWidthButton:NO];
    [self.drawings addObject:[Utils screenshot:_drawingView toSize:CGSizeMake(HistoryImageSize, HistoryImageSize)]];
    UIImage *image = [_drawingView screenshot];
    UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
    
    UIView *flashView = [[UIView alloc] initWithFrame:_drawingView.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:flashView];
    [UIView animateWithDuration:0.2 animations:^{
        flashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [flashView removeFromSuperview];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = _drawingView.frame;
        [self.view addSubview:imageView];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.01, 0.01);
            CGAffineTransform translation;
            if (IS_IPHONE5) {
                translation = CGAffineTransformMakeTranslation(150.0, 258.0);
            }
            else{
                translation = CGAffineTransformMakeTranslation(150.0, 218.0);
            }
            imageView.transform = CGAffineTransformConcat(scaleTransform, translation);
        } completion:^(BOOL finished) {
             [imageView removeFromSuperview];
        }];
    }];
    //[SVStatusHUD showWithImage:nil status:NSLocalizedString(@"PhotoSaved", nil)];
}

- (IBAction)clear:(id)sender
{
    [_drawingView clearAll];
}

- (void)cancel
{
    [[SipStackUtils sharedInstance].messageService sendMessage:kCancelDrawing toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [self cancelFromRemoteParty];
}

- (void)cancelFromRemoteParty
{
    if ([_drawings count] > 0) {
        NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:_drawings];
        DetailHistEvent *imageEvent = [[DetailHistEvent alloc] init];
        imageEvent.remoteParty = [[SipStackUtils sharedInstance] getRemotePartyNumber];
        imageEvent.content = imageData;
        imageEvent.type = kMediaType_Image;
        imageEvent.start = beginTime;
        imageEvent.end = [[NSDate date] timeIntervalSince1970];
        if (_isIncoming) {
            imageEvent.status = kHistoryEventStatus_Incoming;
        }
        else{
            imageEvent.status = kHistoryEventStatus_Outgoing;
        }
        [[DetailHistoryAccessor sharedInstance] addHistEntry:imageEvent];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- getter--
- (NSMutableArray *)drawings
{
    if (_drawings == nil) {
        _drawings = [[NSMutableArray alloc] init];
    }
    return _drawings;
}

- (IBAction)revoke:(UIButton *)sender
{
    [_drawingView revoke];
}

@end
