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

#pragma mark properties
@synthesize trendsString;

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
}


// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
    [activityIndicator stopAnimating];
    self.trendsString = [[NSMutableString alloc] initWithString:@""];
}


#pragma mark -
#pragma mark memory management
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)setView:(UIView *)newView
{
    if (nil == newView) {
        self.trendsString = nil;
    }    
    [super setView:newView];
}


- (void)dealloc {
    [trendsString release], trendsString = nil;
	[super dealloc];
}


#pragma mark -

- (void)appendTextToView: (NSString*) textToAppend
{
	NSString *oldText = urlContentsView.text;
	urlContentsView.text = [oldText stringByAppendingString: textToAppend];
}

#pragma mark Parse JSON
- (NSDictionary *)parseJSONString:(NSString *)aJSONString {
    NSData *jsonData = [aJSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    NSLog(@"%@", dictionary);
    return dictionary;
}

#pragma mark -
#pragma mark Communicate with web service
- (void)loadURL {
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


#pragma mark Callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog (@"connectionDidReceiveResponse");
}

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


- (void)connection:(NSURLConnection *)connection
					didReceiveData:(NSData *)data {
	NSLog (@"connectionDidReceiveData");
	NSString *newText = [[NSString alloc]
				initWithData:data
				encoding:NSUTF8StringEncoding];
	if (newText != NULL) {
		[self appendTextToView:newText];
        [self.trendsString appendString:newText];
		[newText release];
	}
}


- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
	[activityIndicator stopAnimating];
    [self parseJSONString:self.trendsString];
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


#pragma mark -
#pragma mark handle UI inputs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


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


#pragma mark -
#pragma mark Authentication
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


- (void) handleAuthenticationCancelForChallenge: (NSURLAuthenticationChallenge *) aChallenge {
	[[aChallenge sender] cancelAuthenticationChallenge: aChallenge];
	[self dismissModalViewControllerAnimated:YES];
	[activityIndicator stopAnimating];
}


@end
