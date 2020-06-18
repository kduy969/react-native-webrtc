//
//  WebRTCModule+StatsReporting.h
//  RCTWebRTC
//
//  Created by Tuan Luong on 6/10/20.
//

#import "WebRTCModule.h"
#import "LocalAudioAnalyzer.h"

@interface WebRTCModule (StatsReporting)

@property (nonatomic, strong) LocalAudioAnalyzer *localAudioAnalyzer;

-(void)stopStatsReporting;

@end
