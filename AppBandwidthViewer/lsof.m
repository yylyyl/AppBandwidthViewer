//
//  lsof.m
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "lsof.h"

@implementation lsof

- (id)init
{
    self = [super init];
    connections = [[NSMutableArray alloc] init];
    return self;
}

- (NSMutableArray *)getConnections
{
    [connections removeAllObjects];
    
    NSString *path = @"/usr/sbin/lsof";
    NSArray *args = @[@"-i", @"-O", @"-T", @"-n", @"-P"];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:path];
    [task setArguments:args];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit];
    
    NSString *lsof = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *lines = [lsof componentsSeparatedByString:@"\n"];
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

        NSArray *parts = [newline componentsSeparatedByString:@" "];
        NSString *pid = [parts objectAtIndex:1];
        
        //NSString *app = [[[NSRunningApplication runningApplicationWithProcessIdentifier:[pid integerValue]] bundleURL] absoluteString];
        
        NSArray *IPs = [[parts objectAtIndex:8] componentsSeparatedByString:@"->"];
        if ([IPs count] < 2)
        {
            //ignore temporary
            //NSArray *connection = @[@"listen", ];
        }
        else
        {
            NSString *from = [IPs objectAtIndex:0];
            NSString *to = [IPs objectAtIndex:1];
            NSArray *connection = @[pid, from, to];
            [connections addObject:connection];
        }
    }
    
    return connections;
}

@end
