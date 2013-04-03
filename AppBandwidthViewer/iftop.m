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
    [self start];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 2
                                             target: self
                                           selector: @selector(checkIfInterfaceChanged)
                                           userInfo: nil
                                            repeats: YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    return self;
}

- (void)checkIfInterfaceChanged
{
    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"FindCurrentInterfaceIpMac", NULL, NULL);
    CFPropertyListRef global = SCDynamicStoreCopyValue (storeRef,CFSTR("State:/Network/Global/IPv4"));
    NSString *primaryInterface = [(__bridge NSDictionary *)global valueForKey:@"PrimaryInterface"];
    CFRelease(storeRef);
    
    if (![oldIf isEqualToString:primaryInterface])
    {
        [task terminate];
        //[self start];
    }
}

- (void)start
{
    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"FindCurrentInterfaceIpMac", NULL, NULL);
    CFPropertyListRef global = SCDynamicStoreCopyValue (storeRef,CFSTR("State:/Network/Global/IPv4"));
    NSString *primaryInterface = [(__bridge NSDictionary *)global valueForKey:@"PrimaryInterface"];
    CFRelease(storeRef);
    
    if (!primaryInterface)
    {
        return;
    }
    
    NSLog(@"Interface: %@", primaryInterface);
    
    oldIf = [NSString stringWithString:primaryInterface];
    
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [NSString stringWithFormat:@"%@/Contents/iftop/yyliftop", appPath];
    //NSString *path = @"/Users/yangyiliang/Desktop/iftop/iftop";
    NSArray *args = @[@"-i", primaryInterface, @"-n", @"-N", @"-P"];
    task = [[NSTask alloc] init];
    [task setLaunchPath:path];
    [task setArguments:args];
    [task setStandardOutput:[NSFileHandle fileHandleForWritingAtPath:@"/dev/null"]];
    
    error = [[NSPipe alloc] init];
    [task setStandardError:error];
    
    [task setEnvironment:[NSDictionary dictionaryWithObject:@"xterm" forKey:@"TERM"]];
    running = true;
    task.terminationHandler = ^(NSTask *task) {
        NSLog(@"iftop exit");
        running = false;
        
        NSData *data = [[error fileHandleForReading] readDataToEndOfFile];
        NSString *errStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"Exit:\n%@", errStr);
        
    };
    
    system("/usr/bin/killall yyliftop");
    [task launch];
}

- (NSMutableArray *)getConnections:(bool)refresh
{
    //[pipe fileHandleForReading];
    if (!running)
    {
        NSLog(@"Force start iftop");
        [self start];
        return connections;
    }
    if (!refresh)
    {
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
    NSLog(@"%@", @"kill iftop");
    [task terminate];
}
@end
