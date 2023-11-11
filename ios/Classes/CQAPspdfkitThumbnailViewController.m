#import "CQAPspdfkitThumbnailViewController.h"

@implementation PspdfkitCustomViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

@end