//
//  WebRTCModule+StatsReporting.m
//  RCTWebRTC
//
//  Created by Tuan Luong on 6/9/20.
//

#import <objc/runtime.h>
#import <WebRTC/RTCLegacyStatsReport.h>

#import "WebRTCModule+StatsReporting.h"

@implementation WebRTCModule (StatsReporting)

- (NSNumber *)statsReportingTimer
{
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setStatsReportingTimer:(NSNumber *)statsReportingTimer
{
  objc_setAssociatedObject(self, @selector(statsReportingTimer), statsReportingTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

RCT_EXPORT_METHOD(startStatsReporting:(double)duration) {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.statsReportingTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                                target:self
                                                              selector:@selector(getStats)
                                                              userInfo:nil
                                                               repeats:YES];
  });
}

RCT_EXPORT_METHOD(stopStatsReporting) {
  if (self.statsReportingTimer != nil) {
    [self.statsReportingTimer invalidate];
    self.statsReportingTimer = nil;
  }
}

-(void)getStats {
  dispatch_group_t group = dispatch_group_create();
  NSMutableDictionary* result = [NSMutableDictionary new];
  for (NSNumber* key in self.peerConnections) {
    dispatch_group_enter(group);
    RTCPeerConnection* peerConnection = [self.peerConnections objectForKey:key];
    [peerConnection statsForTrack:nil statsOutputLevel:RTCStatsOutputLevelStandard completionHandler:^(NSArray<RTCLegacyStatsReport *> * _Nonnull stats) {
      for (RTCLegacyStatsReport* report in stats) {
        NSString* mediaType = [report.values objectForKey:@"mediaType"];
        if ([mediaType isEqualToString:@"audio"]) {
          double totalSamplesDuration = [[report.values objectForKey:@"totalSamplesDuration"] doubleValue];
          double totalAudioEnergy = [[report.values objectForKey:@"totalAudioEnergy"] doubleValue];
          NSString* googTrackId = [report.values objectForKey:@"googTrackId"];
          if (totalSamplesDuration > 0) {
            double audioLevel = sqrt(totalAudioEnergy / totalSamplesDuration);
            [result setValue:@(audioLevel) forKey:googTrackId];
          }
        }
      }
      dispatch_group_leave(group);
    }];
  }
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    [self sendEventWithName:kEventStatsReportChanged
                       body:@{
                         @"stats": result,
                       }];
  });
}

@end
