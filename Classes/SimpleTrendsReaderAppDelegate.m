//
//  SimpleTrendsReaderAppDelegate.m
//  SimpleTrendsReader
//
//  Created by Chris Adamson on 5/23/08.
//  Copyright Subsequently and Furthermore, Inc. 2008. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import "SimpleTrendsReaderAppDelegate.h"
#import "URLLoaderViewController.h"

@implementation SimpleTrendsReaderAppDelegate

@synthesize window, urlLoaderViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	// Override point for customization after app launch
	URLLoaderViewController *aViewController = [[URLLoaderViewController alloc] 
								initWithNibName:@"URLLoaderView" bundle:[NSBundle mainBundle]]; 
	self.urlLoaderViewController = aViewController; 
	[aViewController release]; 
	
	[window addSubview:[urlLoaderViewController view]];
}


- (void)dealloc {
	[urlLoaderViewController release];
	[window release];
	[super dealloc];
}

@end
