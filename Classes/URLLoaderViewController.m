//
//  URLLoaderViewControl.m
//  SimpleTrendsReader
//
//  Created by Chris Adamson on 5/23/08.
//  Copyright 2008 Subsequently and Furthermore, Inc.. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import "URLLoaderViewController.h"
#import "AuthenticationChallengeViewController.h"
#import "CJSONDeserializer.h"

@implementation URLLoaderViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
 */
- (void)loadView {
	[super loadView];
	[activityIndicator stopAnimating];
}


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


- (void)dealloc {
	[super dealloc];
}



-(void) appendTextToView: (NSString*) textToAppend
{
	NSString *oldText = urlContentsView.text;
	urlContentsView.text = [oldText stringByAppendingString: textToAppend];
}

-(void) loadURL {
	NSLog (@"loadURL");
	
	urlContentsView.text = @"";
	
	NSString *urlString = urlFieldView.text;
	NSURL *url = [NSURL URLWithString: urlString];
	NSLog (@"!! loadURL: %@", url);
	
	// only support HTTP for now
	if (! [urlFieldView.text hasPrefix: @"http"]) {
		// TODO: error sheet
		NSLog (@"URL is not http... abort");
		return;
	}
	
	// create request and connection
//START:code.SimpleCocoaURLReader.initconnection
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc]
					initWithRequest:request
					delegate:self];
	[connection release];
	[request release];
//END:code.SimpleCocoaURLReader.initconnection
	[activityIndicator startAnimating];
	
}




// callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog (@"connectionDidReceiveResponse");
}

//START:code.SimpleCocoaURLReader.didreceiveauthenticationchallenge
- (void)connection:(NSURLConnection *)connection
	didReceiveAuthenticationChallenge:
	(NSURLAuthenticationChallenge *)challenge {
	if ([challenge previousFailureCount] != 0) { //<label id="code.SimpleCocoaURLReader.didreceiveauthenticationchallenge.ifcountnotzero"/>
		// if previous failure count > 0, then user/pass was rejected
		NSString *alertMessage = @"Invalid username or password"; //<label id="code.SimpleCocoaURLReader.didreceiveauthenticationchallenge.passwordrejectalertstart"/>
		UIAlertView *authenticationAlert =
		[[UIAlertView alloc] initWithTitle:@"Authentication failed"
				message:alertMessage
				delegate:nil
				cancelButtonTitle:@"OK"
				otherButtonTitles:nil];
		[authenticationAlert show];
		[authenticationAlert release];
		[alertMessage release]; //<label id="code.SimpleCocoaURLReader.didreceiveauthenticationchallenge.passwordrejectalertend"/>
		[activityIndicator stopAnimating];
	} else {
		// show and block for authentication challenge
		AuthenticationChallengeViewController *challengeController = //<label id="code.SimpleCocoaURLReader.didreceiveauthenticationchallenge.showauthenticationchallengestart"/>
		[[AuthenticationChallengeViewController alloc]
				initWithNibName:@"AuthenticationChallengeView"
				bundle:[NSBundle mainBundle]
				loader: self
				challenge: challenge];
		[self presentModalViewController:challengeController
				animated:YES]; //<label id="code.SimpleCocoaURLReader.didreceiveauthenticationchallenge.showauthenticationchallengeend"/>
		[challengeController release];
	}
}
//END:code.SimpleCocoaURLReader.didreceiveauthenticationchallenge


//START:code.SimpleCocoaURLReader.connectiondidreceivedata
- (void)connection:(NSURLConnection *)connection
					didReceiveData:(NSData *)data {
	NSLog (@"connectionDidReceiveData");
	NSString *newText = [[NSString alloc]
				initWithData:data
				encoding:NSUTF8StringEncoding];
	if (newText != NULL) {
		[self appendTextToView:newText];
		[newText release];
	}
}
//END:code.SimpleCocoaURLReader.connectiondidreceivedata

//START:code.SimpleCocoaURLReader.connectionfinishanderror
- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
	[activityIndicator stopAnimating];
}

-(void) connection:(NSURLConnection *)connection
					didFailWithError: (NSError *)error {
	UIAlertView *errorAlert = [[UIAlertView alloc]
			initWithTitle: [error localizedDescription]
			message: [error localizedFailureReason]
			delegate:nil
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	[activityIndicator stopAnimating];
}
//END:code.SimpleCocoaURLReader.connectionfinishanderror


// delegate method to handle user finishing with keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField { 
	if (theTextField == urlFieldView) { 
		[urlFieldView resignFirstResponder]; 
		[self loadURL];
	} 
	return YES; 
}	

- (void) handleLoadPressed: (id) sender {
	[urlFieldView resignFirstResponder]; 
	[self loadURL];
}

//START:code.SimpleCocoaURLReader.handleauthenticationokforchallenge
- (void) handleAuthenticationOKForChallenge:
			(NSURLAuthenticationChallenge *) aChallenge
			withUser: (NSString*) username
			password: (NSString*) password {
	// try to reply to challenge
	NSURLCredential *credential = [[NSURLCredential alloc]
			initWithUser:username
			password:password
			persistence:NSURLCredentialPersistenceForSession];
	[[aChallenge sender] useCredential:credential
			forAuthenticationChallenge:aChallenge];
	[credential release];
	[self dismissModalViewControllerAnimated:YES];
}
//END:code.SimpleCocoaURLReader.handleauthenticationokforchallenge


- (void) handleAuthenticationCancelForChallenge: (NSURLAuthenticationChallenge *) aChallenge {
	[[aChallenge sender] cancelAuthenticationChallenge: aChallenge];
	[self dismissModalViewControllerAnimated:YES];
	[activityIndicator stopAnimating];
}


@end
