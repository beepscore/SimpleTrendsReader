//
//  AuthenticationChallengeViewController.m
//  SimpleTrendsReader
//
//  Created by Chris Adamson on 7/12/08.
//  Copyright 2008 Subsequently and Furthermore, Inc.. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import "AuthenticationChallengeViewController.h"
#import "URLLoaderViewController.h"


@implementation AuthenticationChallengeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil loader: (URLLoaderViewController *) aLoader challenge: (NSURLAuthenticationChallenge*) aChallenge {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		loader = aLoader;
		challenge = aChallenge;
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)setView:(UIView *)newView
{
    if (nil == newView) {
    }    
    [super setView:newView];
}


- (void)dealloc {
    
	[super dealloc];
}


-(void) handleAuthenticationOKClicked: (id) sender {
	[loader handleAuthenticationOKForChallenge:challenge
				withUser: usernameField.text
				password: passwordField.text];
}

-(void) handleAuthenticationCancelClicked: (id) sender {
	[loader handleAuthenticationCancelForChallenge:challenge];
}

@end
