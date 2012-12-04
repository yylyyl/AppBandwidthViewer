//
//  AppDelegate.h
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BandWidthCounter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BandWidthCounter *myCounter;
}

//@property (assign) IBOutlet NSWindow *window;

@end
