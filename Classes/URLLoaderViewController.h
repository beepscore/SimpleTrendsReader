//
//  URLLoaderViewControl.h
//  SimpleTrendsReader
//
//  Created by Chris Adamson on 5/23/08.
//  Copyright 2008 Subsequently and Furthermore, Inc.. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//
#import <UIKit/UIKit.h>


@interface URLLoaderViewController : UIViewController <UIWebViewDelegate> {

	UIActivityIndicatorView *activityIndicator;
	UIWebView *webView;
    NSMutableString *resultsString;
}

@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) IBOutlet UIWebView *webView;
@property(nonatomic,retain)NSMutableString *resultsString;

- (void) handleRefresh:(id)sender;
- (IBAction)handleGoBack:(id)sender;

- (void) handleAuthenticationOKForChallenge: (NSURLAuthenticationChallenge *) aChallenge withUser: (NSString*) username password: (NSString*) password;
- (void) handleAuthenticationCancelForChallenge: (NSURLAuthenticationChallenge *) aChallenge;
@end
