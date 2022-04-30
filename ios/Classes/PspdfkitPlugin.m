//
//  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitPlugin.h"
#import "PspdfPlatformViewFactory.h"
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"
#import "PspdfkitCustomButtonAnnotationToolbar.h"


@import PSPDFKit;
@import PSPDFKitUI;

static FlutterMethodChannel *channel;

@interface PspdfkitPlugin() <PSPDFViewControllerDelegate>
@property (nonatomic) PSPDFViewController *pdfViewController;
@end

@implementation PspdfkitPlugin

PSPDFSettingKey const PSPDFSettingKeyHybridEnvironment = @"com.pspdfkit.hybrid-environment";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    PspdfPlatformViewFactory *platformViewFactory = [[PspdfPlatformViewFactory alloc] initWithMessenger:[registrar messenger]];
    [registrar registerViewFactory:platformViewFactory withId:@"com.pspdfkit.widget"];

    channel = [FlutterMethodChannel methodChannelWithName:@"com.pspdfkit.global" binaryMessenger:[registrar messenger]];
    PspdfkitPlugin* instance = [[PspdfkitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"frameworkVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:PSPDFKitGlobal.versionNumber]);
    } else if ([@"setLicenseKey" isEqualToString:call.method]) {
        NSString *licenseKey = call.arguments[@"licenseKey"];
        [PSPDFKitGlobal setLicenseKey:licenseKey options:@{PSPDFSettingKeyHybridEnvironment: @"Flutter"}];
    } else if ([@"setLicenseKeys" isEqualToString:call.method]) {
        NSString *iOSLicenseKey = call.arguments[@"iOSLicenseKey"];
        [PSPDFKitGlobal setLicenseKey:iOSLicenseKey options:@{PSPDFSettingKeyHybridEnvironment: @"Flutter"}];
    } else if ([@"getTemporaryDirectory" isEqualToString:call.method]) {
        result([self getTemporaryDirectory]);
    } else {
        [PspdfkitFlutterHelper processMethodCall:call result:result forViewController:self.pdfViewController];
    }
}

- (NSString*)getTemporaryDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

// MARK: - PSPDFViewControllerDelegate

- (void)pdfViewControllerWillDismiss:(PSPDFViewController *)pdfController {
    [channel invokeMethod:@"pdfViewControllerWillDismiss" arguments:nil];
}

- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController {
    // Don't hold on to the view controller object after dismissal.
    self.pdfViewController = nil;
    [channel invokeMethod:@"pdfViewControllerDidDismiss" arguments:nil];
}

- (void)spreadIndexDidChange:(NSNotification *)notification {
    long oldPageIndex = [notification.userInfo[@"PSPDFDocumentViewControllerOldSpreadIndexKey"] longValue];
    long currentPageIndex = [notification.userInfo[@"PSPDFDocumentViewControllerSpreadIndexKey"] longValue];
    NSMutableDictionary *pageIndices = @{@"oldPageIndex": @(oldPageIndex), @"currentPageIndex": @(currentPageIndex)};
    [channel invokeMethod:@"spreadIndexDidChange" arguments:pageIndices];
}

# pragma mark - Annotation notifications

+ (void)userAnnotationAdded {
    [channel invokeMethod:@"userAnnotationAdded" arguments:nil];
}
+ (void)userAnnotationRemoved {
    [channel invokeMethod:@"userAnnotationRemoved" arguments:nil];
}
+ (void)userAnnotationChanged {
    [channel invokeMethod:@"userAnnotationChanged" arguments:nil];
}
@end
