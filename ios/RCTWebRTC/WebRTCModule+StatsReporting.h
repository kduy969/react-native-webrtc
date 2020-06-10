//
//  WebRTCModule+StatsReporting.h
//  RCTWebRTC
//
//  Created by Tuan Luong on 6/10/20.
//

#import "WebRTCModule.h"

@interface WebRTCModule (StatsReporting)

@property (nonatomic, strong) NSTimer *statsReportingTimer;

-(void)stopStatsReporting;

@end
