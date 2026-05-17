// =====================================================================================================================
//  ParlourSolitaireAppDelegate.h
// =====================================================================================================================


#import <UIKit/UIKit.h>


@class ParlourSolitaireViewController;


@interface ParlourSolitaireAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow						*_window;
	ParlourSolitaireViewController	*_viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow							*_window;
@property (nonatomic, strong) IBOutlet ParlourSolitaireViewController	*_viewController;

@end

