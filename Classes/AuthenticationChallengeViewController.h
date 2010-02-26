//
//  AuthenticationChallengeViewController.h
//  SimpleTrendsReader
//
//  Created by Chris Adamson on 7/12/08.
//  Copyright 2008 Subsequently and Furthermore, Inc.. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import <UIKit/UIKit.h>
@class URLLoaderViewController;

@interface AuthenticationChallengeViewController : UIViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	URLLoaderViewController *loader;
	NSURLAuthenticationChallenge *challenge;
}

-(void) handleAuthenticationOKClicked: (id) sender;
-(void) handleAuthenticationCancelClicked: (id) sender;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil loader: (URLLoaderViewController *) aLoader challenge: (NSURLAuthenticationChallenge *) aChallenge;

@end
