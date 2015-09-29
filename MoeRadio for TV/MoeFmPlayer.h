//
//  MoeFmPlayer.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "API.h"
@class MoeFmPlayer;

@protocol MoeFmPlayerDelegate

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist;
-(void)player:(MoeFmPlayer *)player updatetrackmun:(NSInteger)trackmun;
@optional
- (void)player:(MoeFmPlayer *)player updateProgress:(float)percentage;
- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata;
- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state;

//- (void)player:(MoeFmPlayer *)player readyWithPlaylist:(NSArray *)playlist;


- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error;




@end


@interface MoeFmPlayer : NSObject{
    NSString *saystring;

}

@property (strong, nonatomic) NSArray *playlist;
@property (assign, nonatomic) BOOL allowNetworkAccess;
@property (assign, nonatomic) BOOL voiceOverP;
@property (assign, nonatomic) BOOL highQualityAudio;

- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate;

- (void)start;
- (void)startTrack:(NSUInteger)trackNum;
- (void)pause;
- (void)startOrPause;
- (void)stop;
- (void)next;
- (void)previous; 
- (void)seektotime:(double)time;
@end
