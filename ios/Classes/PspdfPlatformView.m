//
//  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfPlatformView.h"
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"
#import "PspdfkitPlugin.h"
#import "PspdfkitCustomButtonAnnotationToolbar.h"
@import PSPDFKit;
@import PSPDFKitUI;


@interface PspdfPlatformView() <PSPDFViewControllerDelegate>
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic, weak) UIViewController *flutterViewController;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) PSPDFNavigationController *navigationController;
@property (nonatomic) id<NSObject> annotationsAddedObserver;
@property (nonatomic) id<NSObject> annotationsRemovedObserver;
@property (nonatomic) id<NSObject> annotationChangedObserver;
@property (nonatomic) UIView* containerView;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    if (self.containerView == nil) {
        self.containerView = self.navigationController.view ?: [UIView new];
    }
    
    return self.containerView;
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    NSString *name = [NSString stringWithFormat:@"com.pspdfkit.widget.%lld",viewId];
    _platformViewId = viewId;
    _channel = [FlutterMethodChannel methodChannelWithName:name binaryMessenger:messenger];

    _navigationController = [PSPDFNavigationController new];
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UINavigationBarAppearance* appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor colorWithRed:91.0/255.0 green:129.0/255.0 blue:74.0/255.0 alpha:1.0];
    appearance.shadowColor = nil;

    _navigationController.navigationBar.standardAppearance = appearance;
    _navigationController.navigationBar.scrollEdgeAppearance = appearance;
    _navigationController.navigationBar.tintColor = UIColor.blackColor;

    // View controller containment
    _flutterViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (_flutterViewController == nil) {
        NSLog(@"Warning: FlutterViewController is nil. This may lead to view container containment problems with PSPDFViewController since we no longer receive UIKit lifecycle events.");
    }
    [_flutterViewController addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:_flutterViewController];
    
    NSString *documentPath = args[@"document"];
    if (documentPath != nil && [documentPath  isKindOfClass:[NSString class]] && [documentPath length] > 0) {
        NSDictionary *configurationDictionary = [PspdfkitFlutterConverter processConfigurationOptionsDictionaryForPrefix:args[@"configuration"]];

        PSPDFDocument *document = [PspdfkitFlutterHelper documentFromPath:documentPath];
        [PspdfkitFlutterHelper unlockWithPasswordIfNeeded:document dictionary:configurationDictionary];

        BOOL isImageDocument = [PspdfkitFlutterHelper isImageDocument:documentPath];
        PSPDFConfiguration *configuration = [PspdfkitFlutterConverter configuration:configurationDictionary isImageDocument:isImageDocument];

        // Update the configuration to override the default class with our custom one.
        configuration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder * _Nonnull builder) {
            [builder overrideClass:PSPDFAnnotationToolbar.class withClass:PspdfkitCustomButtonAnnotationToolbar.class];
            [builder overrideClass:PSPDFAnnotationToolbar.class withClass:PspdfkitCustomButtonAnnotationToolbar.class];
        }];

        _pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];

        if ((id)configurationDictionary != NSNull.null) {
            NSString *key;

            key = @"leftBarButtonItems";
            if (configurationDictionary[key]) {
                [PspdfkitFlutterHelper setLeftBarButtonItems:configurationDictionary[key] forViewController:_pdfViewController];
            }
            key = @"rightBarButtonItems";
            if (configurationDictionary[key]) {
                [PspdfkitFlutterHelper setRightBarButtonItems:configurationDictionary[key] forViewController:_pdfViewController];
            }
        }

        _pdfViewController.appearanceModeManager.appearanceMode = [PspdfkitFlutterConverter appearanceMode:configurationDictionary];
        _pdfViewController.pageIndex = [PspdfkitFlutterConverter pageIndex:configurationDictionary];
        _pdfViewController.delegate = self;
        _pdfViewController.edgesForExtendedLayout = @[];

        __weak id weakSelf = self;
        self.annotationsAddedObserver = [[NSNotificationCenter defaultCenter] 
            addObserverForName:PSPDFAnnotationsAddedNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
            [PspdfkitPlugin userAnnotationsChanged];
        }];
        self.annotationsRemovedObserver = [[NSNotificationCenter defaultCenter] 
            addObserverForName:PSPDFAnnotationsRemovedNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
            [PspdfkitPlugin userAnnotationsChanged];
        }];
        self.annotationChangedObserver = [[NSNotificationCenter defaultCenter] 
            addObserverForName:PSPDFAnnotationChangedNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
            [PspdfkitPlugin userAnnotationsChanged];
        }];
    } else {
        _pdfViewController = [[PSPDFViewController alloc] init];
    }
    [_navigationController setViewControllers:@[_pdfViewController] animated:NO];

    self = [super init];

    __weak id weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [weakSelf handleMethodCall:call result:result];
    }];

    return self;
}


- (void)dealloc {
    [self cleanup];
}

- (void)cleanup {
    self.pdfViewController.document = nil;
    [self.pdfViewController.view removeFromSuperview];
    [self.pdfViewController removeFromParentViewController];
    [self.navigationController.navigationBar removeFromSuperview];
    [self.navigationController.view removeFromSuperview];
    [self.navigationController removeFromParentViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self.annotationsAddedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.annotationsRemovedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.annotationChangedObserver];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [PspdfkitFlutterHelper processMethodCall:call result:result forViewController:self.pdfViewController];
}

# pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController {
    // Don't hold on to the view controller object after dismissal.
    [self cleanup];
}

@end
