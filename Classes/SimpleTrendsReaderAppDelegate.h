//
//  SimpleTrendsReaderAppDelegate.h
//  SimpleTrendsReader
//
//  Created by Chris Adamson on 5/23/08.
//  Copyright Subsequently and Furthermore, Inc. 2008. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>

@class URLLoaderViewController;

@interface SimpleTrendsReaderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	URLLoaderViewController *urlLoaderViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) URLLoaderViewController *urlLoaderViewController;

@end

