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
        self.standardAppearance.backgroundColor = [UIColor colorWithRed:91.0/255.0 green:129.0/255.0 blue:74.0/255.0 alpha:1.0];
        self.standardAppearance.shadowColor = nil;
        self.tintColor = UIColor.blackColor;
        self.selectedTintColor = UIColor.blackColor;
        self.selectedBackgroundColor = UIColor.whiteColor;
        self.supportedToolbarPositions = PSPDFFlexibleToolbarPositionInTopBar;
    }

    return self;
}

// - (UIButton*)doneButton {
//     return nil;
// }

@end