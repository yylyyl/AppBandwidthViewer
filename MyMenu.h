//
//  MyMenu.h
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BandWidthCounter.h"

@interface MyMenu : NSObject <NSMenuDelegate> {
    IBOutlet NSMenu *statusMenu;
    
    /* The other stuff :P */
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    
    NSImage *noImage;
    BandWidthCounter *myCounter;
    bool updated;
}

@property (weak) IBOutlet NSMenuItem *item_more;

- (IBAction)itemClicked:(NSMenuItem *)sender;
@end
