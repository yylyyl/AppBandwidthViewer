//
//  lsof.h
//  AppBandwidthViewer
//
//  Created by yangyiliang on 12-12-4.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lsof : NSObject {
    NSMutableArray *connections;
}

- (id)init;
- (NSMutableArray *)getConnections;
@end
