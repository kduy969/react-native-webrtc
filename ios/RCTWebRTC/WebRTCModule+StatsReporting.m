//
//  WebRTCModule+StatsReporting.m
//  RCTWebRTC
//
//  Created by Tuan Luong on 6/9/20.
//

#import <objc/runtime.h>
#import <WebRTC/RTCLegacyStatsReport.h>

#import "WebRTCModule+StatsReporting.h"
#import "WebRTCModule+RTCPeerConnection.h"

@implementation WebRTCModule (StatsReporting)

- (LocalAudioAnalyzer *)localAudioAnalyzer
{
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setLocalAudioAnalyzer:(LocalAudioAnalyzer *)localAudioAnalyzer
{
  objc_setAssociatedObject(self, @selector(localAudioAnalyzer), localAudioAnalyzer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

RCT_EXPORT_METHOD(startStatsReporting:(int)duration) {
  if (self.localAudioAnalyzer == nil) {
    self.localAudioAnalyzer = [[LocalAudioAnalyzer alloc] init];
  }
  [self.localAudioAnalyzer start:duration];
}

RCT_EXPORT_METHOD(stopStatsReporting) {
  [self.localAudioAnalyzer stop];
//  [self sendEventWithName:kEventStatsReportChanged body:result];
}

@end
