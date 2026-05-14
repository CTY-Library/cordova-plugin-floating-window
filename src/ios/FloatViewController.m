//
//  FloatViewController.m
//
//
//  Created by noah on 2022/1/13.
//

#import "FloatViewController.h"
#import <AVKit/AVKit.h>

#import "FloatingWindowPlugin.h"

@interface FloatViewController () <AVPictureInPictureControllerDelegate>

@property(nonatomic,strong) AVPlayer * player;

@property (nonatomic ,strong)   UIWindow *window;
@property (nonatomic ,strong)   UIView *playerView;

@property(nonatomic,strong) NSString * flg;

@property(nonatomic,strong) AVPlayerItem * playerItem;

 

@property(nonatomic,strong) AVPictureInPictureController * picController;


// pluginCallBack provided via header property; don't redeclare here

@end

static float  paly_times_cur;
static int is_speed;
static const NSString *ItemStatusContext;

@implementation FloatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}

- (void)setUpPlayer: (NSString *)video_url  i_times_cur:(float )i_times_cur   i_landscape:(NSInteger )i_landscape  i_is_speed:(NSInteger )i_is_speed
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // 创建 root view controller 并显示 window，使 player layer 真正加入屏幕层级
    UIViewController *rootVC = [[UIViewController alloc] init];
    _window.rootViewController = rootVC;
    _window.windowLevel = UIWindowLevelNormal + 1;
    [_window makeKeyAndVisible];

    //创建uiview对象
    _playerView = [[UIView alloc] init];
    paly_times_cur = i_times_cur;
    if(i_landscape==1){ //横屏
      [self.playerView setFrame:CGRectMake(100,100,175,102)];
    } else {
      [self.playerView setFrame:CGRectMake(100,100,102,175)];
    }
    _playerView.backgroundColor = [UIColor whiteColor];
    [self.playerView setTag:20];
    
    [rootVC.view addSubview:_playerView];
    // 支持自动调整大小，确保 layer 能拿到正确 bounds
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerView.translatesAutoresizingMaskIntoConstraints = YES;
     
    
    AVAsset *asset = [AVAsset assetWithURL: [NSURL URLWithString:video_url]];
    AVPlayerItem * playerItem = [[AVPlayerItem alloc] initWithAsset:asset  automaticallyLoadedAssetKeys:@[@"duration"]];

    // 保存到 self.playerItem 以便后续移除监听
    self.playerItem = playerItem;

    //添加监听
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];

    AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.backgroundColor = [UIColor blueColor].CGColor;
    [self.playerView.layer addSublayer:layer];
    // 把 layer 的 frame 设置在加入层级后，确保 bounds 已经正确
    layer.frame = self.playerView.bounds;
    layer.needsDisplayOnBoundsChange = YES;
    NSLog(@"playerView bounds: %@", NSStringFromCGRect(self.playerView.bounds));

    self.picController = [[AVPictureInPictureController alloc] initWithPlayerLayer:layer];
    self.picController.delegate = self;
    is_speed = i_is_speed;
    if(is_speed !=1 )
    {
        self.picController.requiresLinearPlayback = true; //隐藏快进按钮
    }
    
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
}
 

//监听视频加载回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;

    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
    }else if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            //NSLog(@"playerItem is ready");
            // 通知 plugin 准备就绪
            [self.pluginCallBack  sendCmd: @"" ];
            // 自动开始播放，这样 PiP 可以正常工作
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player play];
            });
          
        } else{
            NSLog(@"load break");
        }
    }
}


- (void) show {
    if (self.picController.isPictureInPicturePossible) {
        self.flg = @"show";
        [self.picController startPictureInPicture];
    }
    else
    {
        NSLog(@"picture is not possible");
    }
    
}

- (void) close{
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
    [self.player replaceCurrentItemWithPlayerItem: nil];
    self.player = nil;
    
    //self.playerView = nil;
    //self.picController = nil;
    
    [self.playerView removeFromSuperview];
    //[self removeFromParentViewController];
    
    [self.pluginCallBack  sendCmd: [NSString stringWithFormat:@"%d", seconds ]];
   
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
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException *e) {}
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
    
    [self.player play];
    [self jumptoValue];
   
}


- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    NSLog(@"%@",error);
}


- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    //停止ing
   [self sendCurTimeMsg];
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
//停止
 
    
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
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.supportedOrientations != 0) {
        return self.supportedOrientations;
    }
    return UIInterfaceOrientationMaskAll;
}



@end

