//
//  iftop.h
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iftop : NSObject {
    NSTask *task;
    bool running;
    NSMutableArray *connections;
    NSString *oldIf;
}

- (id)init;
- (NSMutableArray *)getConnections:(bool)refresh;
- (void)exit;
@end
