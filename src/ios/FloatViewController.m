//
//  FloatViewController.m
//
//
//  Created by noah on 2022/1/13.
//

#import "FloatViewController.h"
#import <AVKit/AVKit.h>

#import "FloatingWindowPlugin.h"
#import "UIViewController+SupportedOrientations.h"

@interface FloatViewController () <AVPictureInPictureControllerDelegate>

@property(nonatomic,strong) AVPlayer * player;
@property(nonatomic,strong) AVPlayerLayer *playerLayer;
@property(nonatomic,assign) id timeObserverToken;

@property (nonatomic ,strong)   UIWindow *window;
@property (nonatomic ,strong)   UIView *playerView;

@property(nonatomic,strong) NSString * flg;

@property(nonatomic,strong) AVPlayerItem * playerItem;

 

@property(nonatomic,strong) AVPictureInPictureController * picController;

@property(nonatomic,assign) BOOL shouldStartPipWhenPossible;


// pluginCallBack provided via header property; don't redeclare here

@end

static float  paly_times_cur;
static int is_speed;
static const NSString *ItemStatusContext;

static NSString *FWVCAppStateString(UIApplicationState state) {
    switch (state) {
        case UIApplicationStateActive: return @"Active";
        case UIApplicationStateInactive: return @"Inactive";
        case UIApplicationStateBackground: return @"Background";
    }
    return @"Unknown";
}

@implementation FloatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"FloatViewController: viewDidLoad");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)setUpPlayer: (NSString *)video_url  i_times_cur:(float )i_times_cur   i_landscape:(NSInteger )i_landscape  i_is_speed:(NSInteger )i_is_speed
{
    NSLog(@"FloatViewController: setUpPlayer start url=%@ times_cur=%.3f landscape=%ld is_speed=%ld appState=%@", video_url, i_times_cur, (long)i_landscape, (long)i_is_speed, FWVCAppStateString([UIApplication sharedApplication].applicationState));
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    UIView *containerView = nil;
    if (self.hostViewController && self.hostViewController.view.window) {
        containerView = self.hostViewController.view;
        NSLog(@"FloatViewController: using hostViewController.view as container, hostWindow=%@", self.hostViewController.view.window);
    } else {
        // Fallback only when host view is unavailable; primary path is host foreground scene view.
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIViewController *rootVC = [[UIViewController alloc] init];
        if (i_landscape == 1) {
            rootVC.supportedOrientations = UIInterfaceOrientationMaskLandscape;
        } else {
            rootVC.supportedOrientations = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
        }
        _window.rootViewController = rootVC;
        _window.windowLevel = UIWindowLevelNormal;
        [_window makeKeyAndVisible];
        containerView = rootVC.view;
        NSLog(@"FloatViewController: host view unavailable, fallback to internal window=%@", _window);
    }

    //创建uiview对象
    _playerView = [[UIView alloc] init];
    paly_times_cur = i_times_cur;
    if(i_landscape==1){ //横屏
      [self.playerView setFrame:CGRectMake(100,100,175,102)];
    } else {
      [self.playerView setFrame:CGRectMake(100,100,102,175)];
    }
        NSLog(@"FloatViewController: playerView frame=%@", NSStringFromCGRect(self.playerView.frame));
    _playerView.backgroundColor = [UIColor whiteColor];
    [self.playerView setTag:20];
    
    [containerView addSubview:_playerView];
    // 支持自动调整大小，确保 layer 能拿到正确 bounds
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _playerView.translatesAutoresizingMaskIntoConstraints = YES;
     
    
    NSURL *url = [NSURL URLWithString:video_url];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *keys = @[@"playable", @"tracks", @"duration"];

    __weak typeof(self) weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        for (NSString *key in keys) {
            AVKeyValueStatus status = [asset statusOfValueForKey:key error:&error];
            if (status != AVKeyValueStatusLoaded) {
                NSLog(@"FloatViewController: asset key %@ failed to load: %@", key, error);
                return;
            }
            NSLog(@"FloatViewController: asset key %@ loaded", key);
        }

        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        NSLog(@"FloatViewController: videoTracks count = %lu", (unsigned long)videoTracks.count);
        if (videoTracks.count == 0) {
            NSLog(@"FloatViewController: no video tracks, PiP not possible");
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) sself = weakSelf;
            if (!sself) return;

            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            sself.playerItem = playerItem;

            //添加监听
            [sself.playerItem addObserver:sself forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [sself.playerItem addObserver:sself forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

            sself.player = [AVPlayer playerWithPlayerItem:sself.playerItem];
            AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:sself.player];
            layer.videoGravity = AVLayerVideoGravityResizeAspect;
            layer.backgroundColor = [UIColor blackColor].CGColor;
            [sself.playerView.layer addSublayer:layer];
            layer.frame = sself.playerView.bounds;
            layer.needsDisplayOnBoundsChange = YES;
            // 保存引用以便在 PiP 生命周期中控制显示/隐藏
            sself.playerLayer = layer;

            sself.picController = [[AVPictureInPictureController alloc] initWithPlayerLayer:layer];
            sself.picController.delegate = sself;
            [sself.picController addObserver:sself forKeyPath:@"pictureInPicturePossible" options:NSKeyValueObservingOptionNew context:nil];
            is_speed = i_is_speed;
            if(is_speed !=1 ) {
                sself.picController.requiresLinearPlayback = true; //隐藏快进按钮
            }

            NSLog(@"FloatViewController: pic possible = %d, host window active = %d", sself.picController.isPictureInPicturePossible, (sself.hostViewController.view.window != nil));
            NSLog(@"FloatViewController: pip active=%d suspended=%d", sself.picController.isPictureInPictureActive, sself.picController.isPictureInPictureSuspended);

            //给AVPlayerItem添加播放完成通知
            [[NSNotificationCenter defaultCenter] addObserver:sself selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:sself.player.currentItem];
        });
    }];
    
}
 

//监听视频加载回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pictureInPicturePossible"] && object == self.picController) {
        BOOL possible = self.picController.isPictureInPicturePossible;
        NSLog(@"FloatViewController: pic possible changed = %d", possible);
        if (possible && self.shouldStartPipWhenPossible) {
            self.shouldStartPipWhenPossible = NO;
            self.flg = @"show";
            [self.picController startPictureInPicture];
        }
        return;
    }

    AVPlayerItem *playerItem = (AVPlayerItem *)object;

    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSLog(@"FloatViewController: loadedTimeRanges updated, count=%lu", (unsigned long)playerItem.loadedTimeRanges.count);
    }else if ([keyPath isEqualToString:@"status"]){
        NSLog(@"FloatViewController: playerItem status changed=%ld error=%@", (long)playerItem.status, playerItem.error.localizedDescription);
                if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            //NSLog(@"playerItem is ready");
            // 通知 plugin 准备就绪
            [self.pluginCallBack  sendCmd: @"" ];
            // 自动开始播放，这样 PiP 可以正常工作
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player play];
                NSLog(@"FloatViewController: player play issued");
                if (self.shouldStartPipWhenPossible && self.picController.isPictureInPicturePossible) {
                    // 延迟直到播放器已渲染首帧再启动 PiP，避免系统占位黑块
                    __weak typeof(self) weakSelf2 = self;
                    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                        __strong typeof(weakSelf2) sself2 = weakSelf2;
                        if (!sself2) return;
                        Float64 seconds = CMTimeGetSeconds(sself2.player.currentTime);
                        if (seconds > 0) {
                            // 已渲染首帧，移除观察并启动 PiP
                            if (sself2.timeObserverToken) {
                                [sself2.player removeTimeObserver:sself2.timeObserverToken];
                                sself2.timeObserverToken = nil;
                            }
                            sself2.shouldStartPipWhenPossible = NO;
                            sself2.flg = @"show";
                            NSLog(@"FloatViewController: first frame rendered (%.3f), starting PiP", seconds);
                            [sself2.picController startPictureInPicture];
                        }
                    }];
                }
            });
          
        } else{
            NSLog(@"load break");
        }
    }
}


- (void) show {
    NSLog(@"FloatViewController: show called, controllerReady=%d pipPossible=%d pipActive=%d appState=%@", (self.picController != nil), self.picController.isPictureInPicturePossible, self.picController.isPictureInPictureActive, FWVCAppStateString([UIApplication sharedApplication].applicationState));
    if (![AVPictureInPictureController isPictureInPictureSupported]) {
        NSLog(@"picture in picture is not supported on this device");
        return;
    }
    if (!self.picController) {
        self.shouldStartPipWhenPossible = YES;
        NSLog(@"picture controller not ready, waiting for setup");
        return;
    }
    if (self.picController.isPictureInPicturePossible) {
        self.flg = @"show";
        NSLog(@"FloatViewController: startPictureInPicture immediate");
        [self.picController startPictureInPicture];
    }
    else
    {
        self.shouldStartPipWhenPossible = YES;
        NSLog(@"picture is not possible");
    }
    
}

- (void) close{
    NSLog(@"FloatViewController: close called, pipActive=%d", self.picController.isPictureInPictureActive);
    if(self.picController.isPictureInPictureActive){
        self.flg = @"close";
        [self.picController stopPictureInPicture];
        //[self sendCurTimeMsg];
    }
}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
}

//跳转到指定的秒数
-(void)jumptoValue {
    if(paly_times_cur > 0){
     CMTime changedTime = CMTimeMakeWithSeconds( paly_times_cur / 1000, 1);
        [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
         
        }];
    }
 
}

 
 
-(void) sendCurTimeMsg {
    NSLog(@"FloatViewController: sendCurTimeMsg begin");
    [self.player pause];
    [self.player setRate: 0];
    
    CMTime time = self.player.currentTime;
    NSTimeInterval cur_time =  time.value / time.timescale;
    int seconds = ((int)cur_time) * 1000 * 1000; //微秒 
    
    //释放资源（安全移除观察者以避免 KVO 崩溃）
    if (self.playerItem) {
        @try {
            [self.playerItem removeObserver:self forKeyPath:@"status"];
        } @catch (NSException *exception) {}
        @try {
            [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        } @catch (NSException *exception) {}
        [self.playerItem cancelPendingSeeks];
        [self.playerItem.asset cancelLoading];
        self.playerItem = nil;
    }
    if (self.player.currentItem) {
        [self.player.currentItem.asset cancelLoading];
        [self.player.currentItem cancelPendingSeeks];
    }
    if (self.picController) {
        @try {
            [self.picController removeObserver:self forKeyPath:@"pictureInPicturePossible"];
        } @catch (NSException *exception) {}
    }
    // 移除时间观察者（如果存在），防止内存/回调泄漏
    if (self.timeObserverToken) {
        @try {
            [self.player removeTimeObserver:self.timeObserverToken];
        } @catch (NSException *e) {}
        self.timeObserverToken = nil;
    }
    [self.player replaceCurrentItemWithPlayerItem: nil];
    self.player = nil;
    self.picController = nil;
    
    //self.playerView = nil;
    //self.picController = nil;
    
    [self.playerView removeFromSuperview];
    if (self.window) {
        self.window.hidden = YES;
        self.window.rootViewController = nil;
        self.window = nil;
    }
    //[self removeFromParentViewController];
    
    [self.pluginCallBack  sendCmd: [NSString stringWithFormat:@"%d", seconds ]];
    NSLog(@"FloatViewController: sendCurTimeMsg end, seconds=%d", seconds);
   
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"FloatViewController: appDidBecomeActive appState=%@", FWVCAppStateString([UIApplication sharedApplication].applicationState));
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    NSLog(@"FloatViewController: appDidEnterBackground appState=%@", FWVCAppStateString([UIApplication sharedApplication].applicationState));
}

- (void)audioSessionInterrupted:(NSNotification *)notification {
    NSNumber *type = notification.userInfo[AVAudioSessionInterruptionTypeKey];
    NSLog(@"FloatViewController: audioSessionInterrupted type=%@", type);
}

- (void)dealloc {
    // 清理通知与观察者，避免崩溃
    @try {
        if (self.playerItem) {
            [self.playerItem removeObserver:self forKeyPath:@"status"];
            [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        }
    } @catch (NSException *e) {}
    @try {
        if (self.picController) {
            [self.picController removeObserver:self forKeyPath:@"pictureInPicturePossible"];
        }
    } @catch (NSException *e) {}
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException *e) {}
    // 移除周期性时间观察者
    if (self.timeObserverToken) {
        @try {
            [self.player removeTimeObserver:self.timeObserverToken];
        } @catch (NSException *e) {}
        self.timeObserverToken = nil;
    }
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成");
    self.flg = @"show";
    is_speed = 1;
    self.picController.requiresLinearPlayback = false; //显示快进按钮
    [self.pluginCallBack  sendCmd :@"-100" ];// -100: 播放完毕
    
}



#pragma mark - delegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    //UIWindow *firstWindow = [UIApplication sharedApplication].windows.firstObject;
    //[firstWindow addSubview:self.playerView];
    //[self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
    //make.edges.mas_equalTo(firstWindow);
    //}];
}


- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
//开启
    NSLog(@"FloatViewController: pictureInPictureControllerDidStartPictureInPicture");
    // 隐藏应用内的 playerView/层，避免系统显示黑色占位提示
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playerLayer) {
            self.playerLayer.hidden = YES;
        }
        if (self.playerView) {
            self.playerView.hidden = YES;
        }
    });

    [self.player play];
    [self jumptoValue];
   
}


- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    NSLog(@"FloatViewController: failedToStartPiP domain=%@ code=%ld reason=%@ desc=%@", error.domain, (long)error.code, error.localizedFailureReason, error.localizedDescription);
    NSLog(@"FloatViewController: fail context hostWindow=%@ appState=%@", self.hostViewController.view.window, FWVCAppStateString([UIApplication sharedApplication].applicationState));
    // 如果启动失败，确保恢复在应用内显示
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playerLayer) self.playerLayer.hidden = NO;
        if (self.playerView) self.playerView.hidden = NO;
    });
    // 移除时间观察者（如果存在）
    if (self.timeObserverToken) {
        @try {
            [self.player removeTimeObserver:self.timeObserverToken];
        } @catch (NSException *e) {}
        self.timeObserverToken = nil;
    }
}


- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    //停止ing
   NSLog(@"FloatViewController: pictureInPictureControllerWillStopPictureInPicture");
   [self sendCurTimeMsg];
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
//停止
    NSLog(@"FloatViewController: pictureInPictureControllerDidStopPictureInPicture");
 
    
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler
{
    //回到APP
    if([self.flg isEqual:@"show"]){
        
        
    // [self.pluginCallBack  sendCmd :@"-2" ];
        
        CMTime time = self.player.currentTime;
        float f_cur_seconds =  (time.value * 1000 * 0.001  / time.timescale * 1000 * 0.001 );
        float cur_seconds = f_cur_seconds * 1000 * 1000 + 100; //微秒
        long total_time = CMTimeGetSeconds( self.player.currentItem.asset.duration) * 1000 * 1000;
        if(cur_seconds >= total_time ){
            [self.pluginCallBack  sendCmd :@"-3" ];// -3: 当视频播放结束,跳转到答题页
        }
        else{
            [self.pluginCallBack  sendCmd :@"-2" ];// -2: 视频还未播放结束,跳转到视频页
        }
    }
    // 恢复应用内的播放视图显示，并通知系统已恢复 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playerLayer) self.playerLayer.hidden = NO;
        if (self.playerView) self.playerView.hidden = NO;
        if (completionHandler) completionHandler(YES);
    });
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.supportedOrientations != 0) {
        return self.supportedOrientations;
    }
    return UIInterfaceOrientationMaskAll;
}



@end

