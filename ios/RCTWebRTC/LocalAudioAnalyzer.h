//
//  LocalAudioAnalyzer.h
//  RCTWebRTC
//
//  Created by Tuan Luong on 6/18/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LocalAudioAnalyzer : NSObject<AVAudioRecorderDelegate>

-(void)start:(int)monitorInterval;
-(void)stop;

@end
