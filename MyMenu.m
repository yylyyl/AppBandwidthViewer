//
//  MyMenu.m
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "MyMenu.h"

@implementation MyMenu
@synthesize more_menu;

- (void)awakeFromNib
{
    //Create the NSStatusBar and set its length
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:58];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    //[statusItem setImage:statusImage];
    //[statusItem setAlternateImage:statusHighlightImage];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"0.0KB/s\n0.0KB/s"];
    [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:40] range:NSMakeRange(0, [title length])];
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    [pstyle setAlignment:NSRightTextAlignment];
    [pstyle setMaximumLineHeight:40];
    [title addAttribute:NSParagraphStyleAttributeName value:pstyle range:NSMakeRange(0, [title length])];

    NSImage* destImage = [[NSImage alloc] initWithSize:NSMakeSize(216, 88)];
    [destImage lockFocus];
    [title drawAtPoint:NSMakePoint(202 - [title size].width, -4)];
    [destImage unlockFocus];
    [destImage setSize:NSMakeSize(54, 22)];
    [statusItem setImage:destImage];
    
    [title addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [title length])];
    [title removeAttribute:NSFontAttributeName range:NSMakeRange(0, [title length])];
    [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica-Bold" size:40] range:NSMakeRange(0, [title length])];
    NSImage* destImage2 = [[NSImage alloc] initWithSize:NSMakeSize(216, 88)];
    [destImage2 lockFocus];
    [title drawAtPoint:NSMakePoint(202 - [title size].width, -4)];
    [destImage2 unlockFocus];
    [destImage2 setSize:NSMakeSize(54, 22)];
    [statusItem setAlternateImage:destImage2];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    myCounter = [BandWidthCounter getMe];
    
    noImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Terminal" ofType:@"png"]];
    [noImage setSize:NSMakeSize(24, 24)];
    
    updated = false;
    more = false;
    opened = false;
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                             target: self
                                           selector: @selector(updateUI)
                                           userInfo: nil
                                            repeats: YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    if ([menu isEqualTo:more_menu])
    {
        more = true;
    }
    else
    {
        opened = true;
    }
    [self updateMenu];
}

- (void)menuDidClose:(NSMenu *)menu
{
    if ([menu isEqualTo:more_menu])
    {
        more = false;
    }
    else
    {
        opened = false;
    }
}

- (void)updateUI
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[[BandWidthCounter getMe] getSpeed]];
    [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:40] range:NSMakeRange(0, [title length])];
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    [pstyle setAlignment:NSRightTextAlignment];
    [pstyle setMaximumLineHeight:40];
    [title addAttribute:NSParagraphStyleAttributeName value:pstyle range:NSMakeRange(0, [title length])];
    
    NSImage* destImage = [[NSImage alloc] initWithSize:NSMakeSize(216, 88)];
    [destImage lockFocus];
    [title drawAtPoint:NSMakePoint(202 - [title size].width, -4)];
    [destImage unlockFocus];
    [destImage setSize:NSMakeSize(54, 22)];
    [statusItem setImage:destImage];
    
    [title addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [title length])];
    [title removeAttribute:NSFontAttributeName range:NSMakeRange(0, [title length])];
    [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica-Bold" size:40] range:NSMakeRange(0, [title length])];
    NSImage* destImage2 = [[NSImage alloc] initWithSize:NSMakeSize(216, 88)];
    [destImage2 lockFocus];
    [title drawAtPoint:NSMakePoint(202 - [title size].width, -4)];
    [destImage2 unlockFocus];
    [destImage2 setSize:NSMakeSize(54, 22)];
    [statusItem setAlternateImage:destImage2];

    if (opened)
    {
        [self updateMenu];
    }
}

- (void)updateMenu
{
    NSMutableDictionary *list = [myCounter getList];
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    for (NSString *pid in list)
    {
        NSMutableDictionary *item = [list objectForKey:pid];
        [newList addObject:@[pid, [item objectForKey:@"up"], [item objectForKey:@"down"]]];
    }
    [newList sortUsingFunction:compare context:NULL];
    
    int i = 0, n = 1, m = 0;
    while (i < [newList count])
    {
        if(n > 4 && !more)
            break;
        
        NSArray *app = [newList objectAtIndex:i];
        NSString *pid = [app objectAtIndex:0];
        
        
        NSRunningApplication *process = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[pid intValue]];
        
        /*
        if (updated && n==0 && [[app objectAtIndex:1] floatValue]+[[app objectAtIndex:2] floatValue]==0)
        {
            //no update, or the order is not good.
            for (int j=0; j<4; j++)
            {
                NSMenuItem *item = [statusMenu itemAtIndex:n];
                NSString *str = [item title];
                NSArray *parts = [str componentsSeparatedByString:@" "];
                str = [NSString stringWithFormat:@"%@ 0.0 KB/s 0.0 KB/s", [parts objectAtIndex:0]];
                item.title = str;
            }
            
            return;
        }
        */
        
        NSImage *p_image = [process icon];
        NSString *p_name = [process localizedName];
        [p_image setSize:NSMakeSize(24, 24)];
        
        if (p_name==nil)
        {
            p_name = [[[self pathFromProcessID:[pid intValue]] componentsSeparatedByString:@"/"] lastObject];
            p_image = noImage;
        }
        
        if (p_name==nil || [process isTerminated])
        {
            i++;
            continue;
        }
        
        NSMutableAttributedString *a_p_name = [[NSMutableAttributedString alloc] initWithString:p_name];
        [a_p_name addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [a_p_name length])];
        
        if ([a_p_name size].width>117)
        {
            p_name = [NSString stringWithFormat:@"%@...", [p_name substringFromIndex:[p_name length]-4]];
            a_p_name = [[NSMutableAttributedString alloc] initWithString:p_name];
        }
        
        while([a_p_name size].width<115.2)
        {
            p_name = [p_name stringByAppendingString:@" "];
            a_p_name = [[NSMutableAttributedString alloc] initWithString:p_name];
            [a_p_name addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [a_p_name length])];
        }
        if ([a_p_name size].width>117)
        {
            [a_p_name removeAttribute:NSFontAttributeName range:NSMakeRange([a_p_name length]-1, 1)];
            [a_p_name addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:8] range:NSMakeRange([p_name length]-1, 1)];
        }
        if ([a_p_name size].width>117)
        {
            [a_p_name removeAttribute:NSFontAttributeName range:NSMakeRange([a_p_name length]-1, 1)];
            [a_p_name addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:4] range:NSMakeRange([p_name length]-1, 1)];
        }
        //NSLog(@"%f", [a_p_name size].width);
        //[attriString appendAttributedString:a_p_name];
        
        //set unit
        NSString *up = [app objectAtIndex:1];
        NSString *down = [app objectAtIndex:2];
        if ([up floatValue] > 1024)
            up = [NSString stringWithFormat:@"%.2f MB/s", [up floatValue]/1024];
        else
            up = [NSString stringWithFormat:@"%@ KB/s", up];
        if ([down floatValue] > 1024)
            down = [NSString stringWithFormat:@"%.2f MB/s", [down floatValue]/1024];
        else
            down = [NSString stringWithFormat:@"%@ KB/s", down];
        
        //adjust speed length
        //up
        NSMutableAttributedString *a_up = [[NSMutableAttributedString alloc] initWithString:up];
        [a_up addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [a_up length])];
        while([a_up size].width<60)
        {
            up = [@" " stringByAppendingString:up];
            a_up = [[NSMutableAttributedString alloc] initWithString:up];
            [a_up addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [a_up length])];
        }
        if ([a_up size].width>62)
        {
            [a_up removeAttribute:NSFontAttributeName range:NSMakeRange(0, 1)];
            [a_up addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:8] range:NSMakeRange(0, 1)];
        }
        if ([a_up size].width>62)
        {
            [a_up removeAttribute:NSFontAttributeName range:NSMakeRange(0, 1)];
            [a_up addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:4] range:NSMakeRange(0, 1)];
        }
        //down
        NSMutableAttributedString *a_down = [[NSMutableAttributedString alloc] initWithString:down];
        [a_down addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [a_down length])];
        while([a_down size].width<60)
        {
            down = [@" " stringByAppendingString:down];
            a_down = [[NSMutableAttributedString alloc] initWithString:down];
            [a_down addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [a_down length])];
        }
        if ([a_down size].width>62)
        {
            [a_down removeAttribute:NSFontAttributeName range:NSMakeRange(0, 1)];
            [a_down addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:8] range:NSMakeRange(0, 1)];
        }
        if ([a_down size].width>62)
        {
            [a_down removeAttribute:NSFontAttributeName range:NSMakeRange(0, 1)];
            [a_down addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:4] range:NSMakeRange(0, 1)];
        }
        
        NSMutableAttributedString *a_line = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:@" "];
        [space addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, 1)];
        
        [a_line appendAttributedString:a_p_name];
        [a_line appendAttributedString:space];
        [a_line appendAttributedString:a_up];
        [a_line appendAttributedString:space];
        [a_line appendAttributedString:a_down];
        //[attriString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Monaco" size:12] range:NSMakeRange(19, [attriString length]-1)];
        
        if(n<5)
        {
            NSMenuItem *item = [statusMenu itemAtIndex:n];
            item.image = p_image;
            
            item.attributedTitle = a_line;
            item.tag = [pid intValue];
        }
        else
        {
            long count = [more_menu numberOfItems];
            NSMenuItem *item;
            if (n-4 > count-1)
            {
                item = [[NSMenuItem alloc] init];
                [item setTarget:self];
                [item setAction:@selector(itemClicked:)];
                [more_menu addItem:item];
            }
            else
            {
                item = [more_menu itemAtIndex:n-4];
            }
            item.image = p_image;
            item.attributedTitle = a_line;
            item.tag = [pid intValue];
            m++;
        }
        i++;
        n++;
    } // while
    updated = true;
    if (more)
    {
        long count = [more_menu numberOfItems];
        for (int k=0; k<(count-m)-1; k++)
        {
            //NSLog(@"Remove %ld. %d %d", k+count-1, n, m);
            [more_menu removeItemAtIndex:k+count-1];
        }
        [more_menu update];
    }
    
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
    NSLog(@"Switch to %ld", [sender tag]);
}

- (NSString *)pathFromProcessID:(NSUInteger)pid {
    char pathBuffer [PROC_PIDPATHINFO_MAXSIZE];
    proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
    
    // procargv is actually a data structure.
    // The path is at procargv + sizeof(int)
    NSString *path = [NSString stringWithCString:(pathBuffer)
                                        encoding:NSASCIIStringEncoding];
    
    
    return(path);
}

@end
