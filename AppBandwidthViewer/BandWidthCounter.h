//
//  BandWidthCounter.h
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lsof.h"
#import "iftop.h"

@interface BandWidthCounter : NSObject {
    lsof *myLsof;
    iftop *myIftop;
    NSMutableDictionary *apps;
}

+ (id)getMe;
- (NSMutableDictionary *)getList;
- (void)exit;
- (NSString *)getSpeed;
@end
