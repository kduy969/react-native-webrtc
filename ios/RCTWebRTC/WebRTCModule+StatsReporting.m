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

- (NSTimer *)statsReportingTimer
{
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setStatsReportingTimer:(NSTimer *)statsReportingTimer
{
  objc_setAssociatedObject(self, @selector(statsReportingTimer), statsReportingTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)statsReports
{
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setStatsReports:(NSDictionary *)statsReports
{
  objc_setAssociatedObject(self, @selector(statsReports), statsReports, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
          [result setValue:@{
            @"peerConnectionId": peerConnection.reactTag,
            @"totalSamplesDuration": @(totalSamplesDuration),
            @"totalAudioEnergy": @(totalAudioEnergy),
          } forKey:googTrackId];
        }
      }
      dispatch_group_leave(group);
    }];
  }
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//    if (self.statsReports != nil) {
//      for (NSString* key in result) {
//        NSDictionary* value = [result objectForKey:key];
//        NSDictionary* preValue = [self.statsReports objectForKey:key];
//        double diffDuration = [[value objectForKey:@"totalSamplesDuration"] doubleValue] - [[preValue objectForKey:@"totalSamplesDuration"] doubleValue];
//        double diffEnergy = [[value objectForKey:@"totalAudioEnergy"] doubleValue] - [[preValue objectForKey:@"totalAudioEnergy"] doubleValue];
//        double audioLevel = sqrt(diffEnergy/diffDuration);
//        NSLog(@"audioLevel %f", audioLevel);
//        [self.statsReports setValue:value forKey:key];
//      }
//    } else {
//      self.statsReports = [[NSMutableDictionary alloc] initWithDictionary:result];
//    }
    [self sendEventWithName:kEventStatsReportChanged body:result];
  });
}

@end
