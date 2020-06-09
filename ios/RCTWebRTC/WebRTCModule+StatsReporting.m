//
//  WebRTCModule+StatsReporting.m
//  RCTWebRTC
//
//  Created by Tuan Luong on 6/9/20.
//

#import <objc/runtime.h>

#import "WebRTCModule.h"

@interface WebRTCModule (StatsReporting)

@property (nonatomic, strong) NSTimer *statsReportingTimer;

@end

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
  }
}

-(void)getStats {
  // TODO try get stats
}

@end
