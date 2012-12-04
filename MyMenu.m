//
//  MyMenu.m
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "MyMenu.h"

@implementation MyMenu

- (void)awakeFromNib
{
    //Create the NSStatusBar and set its length
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //[statusItem setView:menuView];
    //Sets the tooptip for our item
    //[statusItem setToolTip:@"My Custom Menu Item"];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
    
    myCounter = [BandWidthCounter getMe];
    
    noImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Terminal" ofType:@"png"]];
    [noImage setSize:NSMakeSize(24, 24)];
    
    updated = false;
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                             target: self
                                           selector: @selector(updateUI)
                                           userInfo: nil
                                            repeats: YES];
}

- (void)updateUI
{
    NSMutableDictionary *list = [myCounter getList];
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    for (NSString *pid in list)
    {
        NSMutableDictionary *item = [list objectForKey:pid];
        [newList addObject:@[pid, [item objectForKey:@"up"], [item objectForKey:@"down"]]];
    }
    [newList sortUsingFunction:compare context:NULL];
    
    int i = 0, n = 0;
    while (i < [newList count] && n < 4)
    {
        NSArray *app = [newList objectAtIndex:i];
        NSString *pid = [app objectAtIndex:0];
        
        NSRunningApplication *process = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[pid intValue]];
        
        if (process==nil || [process isTerminated])
        {
            i++;
            continue;
        }
        
        if (updated && n==0 && [[app objectAtIndex:1] floatValue]+[[app objectAtIndex:2] floatValue]==0)
        {
            //no update, or the order is not good.
            for (int j=0; j<4; j++)
            {
                NSMenuItem *item = [statusMenu itemAtIndex:n];
                NSString *str = [item title];
                NSArray *parts = [str componentsSeparatedByString:@" "];
                str = [NSString stringWithFormat:@"%@ 0.0 0.0", [parts objectAtIndex:0]];
                item.title = str;
            }
            
            return;
        }
        
        
        NSImage *p_image = [process icon];
        NSString *p_name = [process localizedName];
        [p_image setSize:NSMakeSize(24, 24)];
        
        
        if (p_name==nil)
        {
            p_name = [[[[process executableURL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
            p_image = noImage;
        }
        
        NSMenuItem *item = [statusMenu itemAtIndex:n];
        item.image = p_image;
        item.title = [NSString stringWithFormat:@"%@ %@ %@", p_name,
                                                            [app objectAtIndex:1],
                                                            [app objectAtIndex:2]];
        item.tag = [pid intValue];
        i++;
        n++;
    }
    updated = true;
    [statusMenu update];
}

NSComparisonResult compare(NSArray *a, NSArray *b, void *context) {
    float speed_a = [[a objectAtIndex:1] floatValue] + [[a objectAtIndex:2] floatValue];
    float speed_b = [[b objectAtIndex:1] floatValue] + [[b objectAtIndex:2] floatValue];
    if (speed_a < speed_b)
        return NSOrderedDescending;
    else if (speed_a > speed_b)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}

- (IBAction)itemClicked:(NSMenuItem *)sender {
    NSRunningApplication *process = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[sender tag]];
    [process activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    NSLog(@"%ld", [sender tag]);
}
@end
