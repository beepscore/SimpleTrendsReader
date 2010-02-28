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
#import "Debug.h"

@implementation URLLoaderViewController

#pragma mark properties
@synthesize webView;
@synthesize activityIndicator;
@synthesize resultsString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}


// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
	[super loadView];  
}


#pragma mark Communicate with web service
- (void)loadURL:(NSURL*)aURL {
	DLog(@"aURL = %@", aURL);
    
	if (NULL != aURL) {
        // create request and connection
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: aURL];
        NSURLConnection *connection = [[NSURLConnection alloc]
                                       initWithRequest:request
                                       delegate:self];
        
        [self.webView loadRequest:request];
        
        [connection release];
        [request release];
    }
}


//- (void)loadWebViewForURL:(NSURL*)aURL {
//	DLog(@"aURL = %@", aURL);
//    
//	if (NULL != aURL) {
//        // create request and connection
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: aURL];
//        NSURLConnection *connection = [[NSURLConnection alloc]
//                                       initWithRequest:request
//                                       delegate:self];
//        
//        [self.webView loadRequest:request];
//        
//        [connection release];
//        [request release];
//    }
//}


#pragma mark -
// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
    resultsString = [[NSMutableString alloc] initWithString:@""];
    NSString *trendsPath =[[NSBundle mainBundle]
                           pathForResource:@"trends" ofType:@"html"];
    
    // ????: ???????????????????????????????????????????????????????????????????
//    NSURL *url = [[NSURL alloc] initFileURLWithPath:trendsPath isDirectory:NO];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:trendsPath];
    DLog(@"url = %@", url);
	[self loadURL:url];
    [url release];
}


#pragma mark -
#pragma mark memory management
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)setView:(UIView *)newView {
    if (nil == newView) {
        self.activityIndicator = nil;
        self.resultsString = nil;
        self.webView = nil;
    }    
    [super setView:newView];
}


- (void)dealloc {
    [activityIndicator release], activityIndicator = nil;
    [resultsString release], resultsString = nil;
    [webView release], webView = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Parse JSON
- (NSDictionary *)dictionaryForJSONString:(NSString *)aJSONString {
    NSData *jsonData = [aJSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    return dictionary;
}


- (NSDictionary *)trendsDictionaryForTrendsJSONString:(NSString *)aTrendsJSONString {
    NSDictionary *outerDictionary = [self dictionaryForJSONString:aTrendsJSONString];
    NSDictionary *trendsDictionary = [outerDictionary objectForKey:@"trends"];
    return trendsDictionary;
}


#pragma mark -
#pragma mark Display Trends
- (void)writeTrendsHTMLFileForDictionary:(NSDictionary *)aTrendsDictionary {
    
    // Ref: http://moodle.extn.washington.edu/mod/forum/discuss.php?d=4675
    
    NSString *trendsTopPath =[[NSBundle mainBundle]
                           pathForResource:@"trends_top" ofType:@"html"];

    
    NSMutableString *trendsHTMLString = [[NSMutableString alloc]
                                         initWithContentsOfFile:trendsTopPath
                                         encoding:NSUTF8StringEncoding
                                         error:NULL];
    
    [trendsHTMLString appendString:@"        <ol>\n"];
    
    for ( NSDictionary* trend in aTrendsDictionary ) {
        
        [trendsHTMLString appendFormat:@"            <li><a href=\"%@\">%@</a></li>\n", 
         [trend objectForKey:@"url"], [trend objectForKey:@"name"]];
    }
    
    [trendsHTMLString appendString:@"        </ol>\n"];
    [trendsHTMLString appendString:@"    </body>\n"];
    [trendsHTMLString appendString:@"</html>\n"];
    
    DLog(@"trendsHTMLString = %@", trendsHTMLString);
    
    NSString *trendsPath =[[NSBundle mainBundle]
                           pathForResource:@"trends" ofType:@"html"];

    [trendsHTMLString writeToFile:trendsPath
                       atomically:YES 
                         encoding:NSUTF8StringEncoding 
                            error:NULL];
    [trendsHTMLString release];
}


#pragma mark -
#pragma mark Callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DLog(@"connectionDidReceiveResponse");
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


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {	
    DLog(@"connectionDidReceiveData");
	NSString *newText = [[NSString alloc]
                         initWithData:data
                         encoding:NSUTF8StringEncoding];
	if (NULL != newText) {
        
        
        // FIXME: sometimes data should go to trendsJSONString, sometimes to trendsHTML
        [self.resultsString appendString:newText];
		[newText release];
	}
}


- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
    DLog(@"resultsString = %@", self.resultsString);
    // TODO:  if we were loading trends
    // NSDictionary *trendsDictionary = [self trendsDictionaryForTrendsJSONString:self.resultsString];
    // [self writeTrendsHTMLFileForDictionary:trendsDictionary];
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
	UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle: [error localizedDescription]
                               message: [error localizedFailureReason]
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	[self.activityIndicator stopAnimating];
}


#pragma mark -
#pragma mark handle UI inputs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return ((interfaceOrientation == UIInterfaceOrientationPortrait)
            || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


- (void) handleRefresh:(id)sender {
    NSURL *url = [[NSURL alloc] initWithString:@"http://search.twitter.com/trends.json"];
	[self loadURL:url];    
    [url release];
}


- (IBAction)handleGoBack:(id)sender {
    [self.webView goBack];    
}


- (void)webViewDidStartLoad:webView {
    [self.activityIndicator startAnimating];
}


- (void)webViewDidFinishLoad:webView {
    [self.activityIndicator stopAnimating];
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
