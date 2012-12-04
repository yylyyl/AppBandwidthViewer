//
//  iftop.m
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "iftop.h"
#import <SystemConfiguration/SCDynamicStore.h>

@implementation iftop

- (id)init
{
    self = [super init];
    connections = [[NSMutableArray alloc] init];
    running = false;
    return self;
}

- (void)start
{
    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"FindCurrentInterfaceIpMac", NULL, NULL);
    CFPropertyListRef global = SCDynamicStoreCopyValue (storeRef,CFSTR("State:/Network/Global/IPv4"));
    NSString *primaryInterface = [(__bridge NSDictionary *)global valueForKey:@"PrimaryInterface"];
    CFRelease(storeRef);
    
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    //NSString *path = [NSString stringWithFormat:@"%@/Contents/iftop/iftop", appPath];
    NSString *path = @"/Users/yangyiliang/Desktop/iftop/iftop";
    NSArray *args = @[@"-i", primaryInterface, @"-n", @"-N", @"-P"];
    task = [[NSTask alloc] init];
    [task setLaunchPath:path];
    [task setArguments:args];
    [task setEnvironment:[NSDictionary dictionaryWithObject:@"xterm-256color" forKey:@"TERM"]];
    running = true;
    task.terminationHandler = ^(NSTask *task) {
        running = false;
    };
    
    [task launch];
}

- (NSMutableArray *)getConnections
{
    if (!running)
    {
        [self start];
        return connections;
    }
    NSString *str = [NSString stringWithContentsOfFile:@"/tmp/iftop.txt" encoding:NSUTF8StringEncoding error:nil];
    if (str==nil || [str isEqualToString:@""])
    {
        return connections;
    }
    [connections removeAllObjects];
    NSArray *lines = [str componentsSeparatedByString:@"\n"];
    for (NSString *line in lines)
    {
        if ([line isEqualToString:@""])
        {
            break;
        }
        NSString *newline = [[[[[line stringByReplacingOccurrencesOfString:@"  " withString:@" "]
                                stringByReplacingOccurrencesOfString:@"  " withString:@" "]
                               stringByReplacingOccurrencesOfString:@"  " withString:@" "]
                              stringByReplacingOccurrencesOfString:@"  " withString:@" "]
                             stringByReplacingOccurrencesOfString:@"  " withString:@" "]; //turn spaces into a space
        
        NSArray *connection = [newline componentsSeparatedByString:@" "];
        [connections addObject:connection];
    }
    return connections;
}

- (void)exit
{
    //NSLog(@"%@", @"kill iftop");
    [task terminate];
}
@end
