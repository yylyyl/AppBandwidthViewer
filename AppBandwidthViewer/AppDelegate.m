//
//  AppDelegate.m
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    myCounter = [BandWidthCounter getMe];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [myCounter exit];
}

@end
