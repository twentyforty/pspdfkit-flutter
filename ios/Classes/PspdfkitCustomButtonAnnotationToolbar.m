#import "PspdfkitCustomButtonAnnotationToolbar.h"

@implementation PspdfkitCustomButtonAnnotationToolbar

#pragma mark - Lifecycle

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
        self.tintColor =  UIColor.whiteColor;
        self.editableAnnotationTypes = [NSSet setWithArray:@[PSPDFAnnotationStringHighlight, PSPDFAnnotationStringInk, PSPDFAnnotationStringEraser/*, PSPDFAnnotationStringFreeText*/]];
        self.configurations = @[[[PSPDFAnnotationToolbarConfiguration alloc] initWithAnnotationGroups:@[
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringHighlight]
            ]],
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringInk variant:PSPDFAnnotationVariantStringInkHighlighter configurationBlock:[PSPDFAnnotationGroupItem inkConfigurationBlock]]
            ]],
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringInk variant:PSPDFAnnotationVariantStringInkPen configurationBlock:[PSPDFAnnotationGroupItem inkConfigurationBlock]]
            ]],
        ]]];
        self.standardAppearance = [[UIToolbarAppearance alloc] init];
        [self.standardAppearance configureWithOpaqueBackground];
        self.standardAppearance.shadowColor = nil;

        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            self.standardAppearance.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
            self.tintColor = UIColor.blackColor;
            self.selectedTintColor = UIColor.blackColor;
            self.selectedBackgroundColor = UIColor.whiteColor;
        } else {
            self.standardAppearance.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1.0];
            self.tintColor = UIColor.whiteColor;
            self.selectedTintColor = UIColor.whiteColor;
            self.selectedBackgroundColor = UIColor.blackColor;
        }

        self.supportedToolbarPositions = PSPDFFlexibleToolbarPositionInTopBar;
    }

    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.standardAppearance.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.tintColor = UIColor.blackColor;
        self.selectedTintColor = UIColor.blackColor;
        self.selectedBackgroundColor = UIColor.whiteColor;
    } else {
        self.standardAppearance.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1.0];
        self.tintColor = UIColor.whiteColor;
        self.selectedTintColor = UIColor.whiteColor;
        self.selectedBackgroundColor = UIColor.blackColor;
    }
}

- (UIButton*)doneButton {
    return nil;
}

@end