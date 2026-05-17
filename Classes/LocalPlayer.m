// =====================================================================================================================
//  LocalPlayer.m
// =====================================================================================================================


#import <AssertMacros.h>
#import <GameKit/GameKit.h>
#import "LocalPlayer_priv.h"


@implementation LocalPlayer
// ========================================================================================================= LocalPlayer
// --------------------------------------------------------------------------------------------------------- @synthesize

@synthesize playerID = _playerID;
@synthesize displayName = _displayName;
@synthesize authenticated = _authenticated;
@synthesize usingGameCenter = _usingGameCenter;
@synthesize delegate = _delegate;

// ---------------------------------------------------------------------------------------------------------------- init

- (id) init
{
	id		myself = nil;

	if ((self = [super init]))
	{
		_playerID = nil;
		_displayName = nil;
		_authenticated = NO;
		_usingGameCenter = NO;
		_delegate = nil;

		[self authenticateLocalPlayer];

		myself = self;
	}

	return myself;
}

// ------------------------------------------------------------------------------------------ postLocalScore:forCategory

- (void) postLocalScore: (NSInteger) score forCategory: (NSString *) category
{
	NSUserDefaults		*defaults;
	NSDictionary		*storedDictionary;
	NSMutableDictionary	*scoreDictionary;

	defaults = [NSUserDefaults standardUserDefaults];

	if (_playerID)
		storedDictionary = [defaults dictionaryForKey: _playerID];
	else
		storedDictionary = [defaults dictionaryForKey: @"Local"];

	if (storedDictionary)
		scoreDictionary = [NSMutableDictionary dictionaryWithDictionary: storedDictionary];
	else
		scoreDictionary = [NSMutableDictionary dictionaryWithCapacity: 1];

	[scoreDictionary setObject: [NSNumber numberWithInteger: score] forKey: category];

	if (_playerID)
		[defaults setObject: scoreDictionary forKey: _playerID];
	else
		[defaults setObject: scoreDictionary forKey: @"Local"];
	[defaults synchronize];
}

// ------------------------------------------------------------------------------------ postLeaderboardScore:forCategory

- (BOOL) postLeaderboardScore: (NSInteger) score forCategory: (NSString *) category
{
	BOOL		success = NO;

	if (_authenticated == NO)
		return NO;

	if (_usingGameCenter)
	{
		NSUserDefaults		*defaults;
		NSDictionary		*storedDictionary;
		NSMutableDictionary	*scoreDictionary;

		defaults = [NSUserDefaults standardUserDefaults];
		storedDictionary = [defaults dictionaryForKey: _playerID];

		if (storedDictionary)
			scoreDictionary = [NSMutableDictionary dictionaryWithDictionary: storedDictionary];
		else
			scoreDictionary = [NSMutableDictionary dictionaryWithCapacity: 1];
		[scoreDictionary setObject: [NSNumber numberWithInteger: score] forKey: category];

		[defaults setObject: scoreDictionary forKey: _playerID];
		success = [defaults synchronize];

		__weak __typeof(self) weakSelf = self;
		[GKLeaderboard submitScore: (NSInteger) score
						   context: 0
							player: [GKLocalPlayer localPlayer]
					leaderboardIDs: @[category]
				 completionHandler: ^(NSError *error)
		{
			__typeof(self) strongSelf = weakSelf;
			if (error != nil && strongSelf)
			{
				if ([strongSelf->_delegate respondsToSelector: @selector (localPlayer:failedPostScoreForCategory:error:)])
					[strongSelf->_delegate localPlayer: strongSelf failedPostScoreForCategory: category error: error];
			}
		}];
	}
	else
	{
		NSUserDefaults	*defaults;

		defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject: [NSNumber numberWithInteger: score] forKey: category];
		success = [defaults synchronize];
	}

	return success;
}

// -------------------------------------------------------------------------------------- retrieveLocalScore:forCategory

- (BOOL) retrieveLocalScore: (NSInteger *) score forCategory: (NSString *) category
{
	NSUserDefaults	*defaults;
	NSDictionary	*scoreDictionary;
	BOOL			retrieved = NO;

	if (score)
		*score = 0;

	__Require (category, bail);

	defaults = [NSUserDefaults standardUserDefaults];
	if (_playerID)
		scoreDictionary = [defaults dictionaryForKey: _playerID];
	else
		scoreDictionary = [defaults dictionaryForKey: @"Local"];

	if (scoreDictionary)
	{
		NSNumber	*scoreNumber;

		scoreNumber = [scoreDictionary objectForKey: category];
		if (scoreNumber)
		{
			if (score)
				*score = [scoreNumber integerValue];
			retrieved = YES;
		}
	}

bail:

	return retrieved;
}

@end


@implementation LocalPlayer (LocalPlayer_priv)
// ====================================================================================== LocalPlayer (LocalPlayer_priv)
// --------------------------------------------------------------------------------------------- authenticateLocalPlayer

- (void) authenticateLocalPlayer
{
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	__weak GKLocalPlayer *weakPlayer = localPlayer;
	__weak __typeof(self) weakSelf = self;
	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
	{
		GKLocalPlayer *strongPlayer = weakPlayer;
		__typeof(self) strongSelf = weakSelf;
		if (strongPlayer == nil || strongSelf == nil)
			return;

		if (viewController != nil)
		{
			if ([strongSelf->_delegate respondsToSelector: @selector (localPlayer:needsToPresentAuthenticationViewController:)])
				[strongSelf->_delegate localPlayer: strongSelf needsToPresentAuthenticationViewController: viewController];
			return;
		}

		if (strongPlayer.isAuthenticated)
		{
			strongSelf->_playerID = [strongPlayer.gamePlayerID copy];
			strongSelf->_displayName = [strongPlayer.displayName copy];
			strongSelf->_authenticated = YES;
			strongSelf->_usingGameCenter = YES;

			if ([strongSelf->_delegate respondsToSelector: @selector (localPlayerAuthenticated:)])
				[strongSelf->_delegate localPlayerAuthenticated: strongSelf];
		}
		else
		{
			strongSelf->_playerID = nil;
			strongSelf->_displayName = nil;
			strongSelf->_authenticated = YES;
			strongSelf->_usingGameCenter = NO;

			if ([strongSelf->_delegate respondsToSelector: @selector (localPlayer:failedAuthenticationWithError:)])
				[strongSelf->_delegate localPlayer: strongSelf failedAuthenticationWithError: error];
		}
	};
}

@end
