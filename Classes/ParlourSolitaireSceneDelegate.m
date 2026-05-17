// =====================================================================================================================
//  ParlourSolitaireSceneDelegate.m
// =====================================================================================================================


#import "ParlourSolitaireSceneDelegate.h"
#import "ParlourSolitaireViewController.h"


@implementation ParlourSolitaireSceneDelegate
{
	ParlourSolitaireViewController *_viewController;
}

// -------------------------------------------------------------------------------------------------------- scene:willConnectToSession:options

- (void) scene: (UIScene *) scene willConnectToSession: (UISceneSession *) session options: (UISceneConnectionOptions *) connectionOptions
{
	UIWindowScene *windowScene = (UIWindowScene *) scene;

	_viewController = [[ParlourSolitaireViewController alloc] initWithNibName: @"ParlourSolitaireViewController" bundle: nil];

	self.window = [[UIWindow alloc] initWithWindowScene: windowScene];
	self.window.rootViewController = _viewController;
	[self.window makeKeyAndVisible];

	[_viewController createCardTableLayout];
	[_viewController restoreState];
	[_viewController openSplashAfterDelay];
}

// -------------------------------------------------------------------------------------------------------- sceneDidEnterBackground

- (void) sceneDidEnterBackground: (UIScene *) scene
{
	[_viewController saveState];
}

@end
