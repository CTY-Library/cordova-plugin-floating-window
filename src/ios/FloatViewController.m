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


@property(nonatomic,strong) AVPictureInPictureController * picController;


@property (nonatomic ,strong) FloatingWindowPlugin *pluginCallBack;

@end

static float   paly_times_cur;

@implementation FloatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}

- (void)setUpPlayer: (NSString *)video_url  i_times_cur:(float )i_times_cur   i_landscape:(NSInteger )i_landscape
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    _pluginCallBack = [[FloatingWindowPlugin alloc] init];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
    
    [_window addSubview:_playerView];
    
    
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:video_url]];
    
    self.player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    layer.frame = self.playerView.bounds;
    layer.backgroundColor = [UIColor blueColor].CGColor;
    NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
    [self.playerView.layer addSublayer:layer];

    NSLog(@"---------------%@",NSStringFromCGRect(layer.bounds));

    self.picController = [[AVPictureInPictureController alloc] initWithPlayerLayer:layer];
    self.picController.delegate = self;
    self.picController.requiresLinearPlayback = true; //隐藏快进按钮
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
     CMTime changedTime = CMTimeMakeWithSeconds( paly_times_cur, 1);
        [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
         
        }];
    }
 
}

 
-(void) sendCurTimeMsg {
    [self.player pause];
    
    CMTime time = self.player.currentTime;
    NSTimeInterval cur_time =  time.value / time.timescale;
    int seconds = ((int)cur_time)%(3600*24)%3600%60 * 1000; //毫秒
    [self.pluginCallBack  sendCmd: [NSString stringWithFormat:@"%d", seconds ]];
    
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
    [self jumptoValue];
    [self.player play];
   
}


- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    NSLog(@"%@",error);
}


- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{

}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
//停止
    [self sendCurTimeMsg];
    
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler
{
    //回到APP
    if([self.flg isEqual:@"show"]){
     [self.pluginCallBack  sendCmd :@"-2" ];
    }
}



@end
