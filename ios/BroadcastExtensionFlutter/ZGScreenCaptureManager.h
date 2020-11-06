//
//  ZGScreenCaptureManager.h
//  ZegoExpressExample-iOS-OC-Broadcast
//
//  Created by Patrick Fu on 2020/9/21.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGScreenCaptureManager : NSObject

/// Shared instance
+ (instancetype)sharedManager;

/// Invoke this function in [-broadcastStartedWithSetupInfo:]
///
/// @param appGroup Your own app group ID
- (void)startBroadcastWithAppGroup:(NSString *)appGroup sampleHandler:(RPBroadcastSampleHandler *)sampleHandler;

/// Invoke this function in [-broadcastFinished]
- (void)stopBroadcast:(void(^_Nullable)(void))completion;

/// Handles ReplayKit's SampleBuffer, supports receiving video and audio buffer.
///
/// @param sampleBuffer Video or audio buffer returned by ReplayKit
/// @param sampleBufferType Buffer type returned by ReplayKit
- (void)handleSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType;

@end

NS_ASSUME_NONNULL_END
