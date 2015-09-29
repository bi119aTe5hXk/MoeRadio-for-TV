//
//  MoeFmAPI.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MoeFmAPI;

@protocol MoeFmAPIDelegate

@optional
- (void)api:(MoeFmAPI *)api readyWithJson:(NSDictionary *)json;
- (void)api:(MoeFmAPI *)api readyWithPlaylist:(NSArray *)playlist;
- (void)api:(MoeFmAPI *)api readyWithImage:(UIImage *)image;
- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error;

@end


@interface MoeFmAPI : NSObject <NSURLConnectionDelegate>{
    
    
}

//@property (nonatomic,retain) GTMOAuthAuthentication *mOAuth1;

@property (assign, nonatomic, readonly)BOOL isBusy;
@property (assign, nonatomic) BOOL allowNetworkAccess;
@property (readonly) BOOL canAuthorize;
- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey 
					 delegate:(NSObject <MoeFmAPIDelegate> *)delegate;

- (BOOL)requestJsonWithURL:(NSString *)urlstr;
- (BOOL)requestImageWithURL:(NSURL *)url;
- (BOOL)requestListenPlaylistWithPage:(NSInteger)page;
- (BOOL)requestListenPlaylistWithURL:(NSString*)urlstr;



- (void)cancelRequest;

@end
