//
//  MyMenu.h
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BandWidthCounter.h"
#import <sys/proc_info.h>

@interface MyMenu : NSObject <NSMenuDelegate> {
    IBOutlet NSMenu *statusMenu;
    
    /* The other stuff :P */
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    
    NSImage *noImage;
    BandWidthCounter *myCounter;
    bool updated;
    NSTimer *timer;
    bool more;
    bool opened;
}

@property (weak) IBOutlet NSMenu *more_menu;

- (IBAction)itemClicked:(NSMenuItem *)sender;
@end
