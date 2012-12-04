//
//  BandWidthCounter.m
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "BandWidthCounter.h"

@implementation BandWidthCounter

static BandWidthCounter *globalSelf;

+ (id)getMe
{
    if (!globalSelf)
    {
        globalSelf = [[self alloc] init];
    }
    return globalSelf;
}

- (id)init
{
    self = [super init];
    myLsof = [[lsof alloc] init];
    myIftop = [[iftop alloc] init];
    apps = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (NSMutableDictionary *)getList
{
    [apps removeAllObjects];
    NSMutableArray *c_lsof = [myLsof getConnections];
    NSMutableArray *c_iftop = [myIftop getConnections];
    
    for (NSArray *line in c_lsof)
    {
        NSString *pid = [line objectAtIndex:0];
        NSString *from = [line objectAtIndex:1];
        NSString *to = [line objectAtIndex:2];
        
        NSMutableDictionary *lineInApps = [apps objectForKey:pid];
        if (lineInApps == nil)
        {
            lineInApps = [[NSMutableDictionary alloc] init];
            [lineInApps setObject:@"0.0" forKey:@"up"];
            [lineInApps setObject:@"0.0" forKey:@"down"];
            [apps setObject:lineInApps forKey:pid];
        }
        for (NSArray *iftop_line in c_iftop)
        {
            NSString *iftop_from = [iftop_line objectAtIndex:0];
            NSString *iftop_to = [iftop_line objectAtIndex:1];
            NSString *iftop_up = [iftop_line objectAtIndex:2];
            NSString *iftop_down = [iftop_line objectAtIndex:3];
            if ([from isEqualToString:iftop_from] && [to isEqualToString:iftop_to])
            {
                NSString *newup = [NSString stringWithFormat:@"%.1f", [(NSString *)[lineInApps objectForKey:@"up"] floatValue] + [iftop_up floatValue]];
                NSString *newdown = [NSString stringWithFormat:@"%.1f", [(NSString *)[lineInApps objectForKey:@"down"] floatValue] + [iftop_down floatValue]];
                [lineInApps setObject:newup forKey:@"up"];
                [lineInApps setObject:newdown forKey:@"down"];
            }
        }
    }
    //NSLog(@"%@", apps);
    return apps;
}

- (void)exit
{
    [myIftop exit];
}
@end
