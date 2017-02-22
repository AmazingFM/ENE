#import "LBLaunchImageAdView.h"
#import "UIImageView+WebCache.h"
#import "UIView+Util.h"
#import "YMPageControl.h"

#import "Config.h"
#import "YMGlobal.h"
#import "YMCommon.h"
#import "YMUtil.h"

#import "PPNetworkHelper.h"
#import "YMUser.h"
#import "YMUserManager.h"
#import "YMDataManager.h"

#import "AppDelegate.h"

#define mainHeight      [[UIScreen mainScreen] bounds].size.height
#define mainWidth       [[UIScreen mainScreen] bounds].size.width

@interface LBLaunchImageAdView() <UIScrollViewDelegate, CAAnimationDelegate>
{
    NSTimer *countDownTimer;
    
    UIScrollView *_mainScrollView;
    
    YMPageControl *_pageControl;
    UIButton *_fineshedBtn;
    int _pageCount;
    UIWindow *_window;
    AdType _adType;
}

@property (strong, nonatomic) NSString *isClick;
@property (nonatomic) BOOL isLogin;

@end

@implementation LBLaunchImageAdView

- (instancetype)initWithWindow:(UIWindow *)window adType:(AdType)adType
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, mainWidth, mainHeight);
        [window makeKeyAndVisible];
        
        _window = window;
        _adType = adType;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString *version=[infoDict objectForKey:@"CFBundleShortVersionString"];
        NSString *key=[NSString stringWithFormat:@"guide_%@", version];

        if (![userDefault boolForKey:key]) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            _mainScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mainWidth, mainHeight)];
            _mainScrollView.backgroundColor=[UIColor clearColor];
            _mainScrollView.delegate=self;
            _mainScrollView.scrollEnabled=YES;
            _mainScrollView.pagingEnabled=YES;
            [self addSubview:_mainScrollView];

            NSArray *imageArray=@[@"image_guide1.png",@"image_guide2.png",@"image_guide3.png"];
            _pageCount=(int)imageArray.count;
            
            float btnWidth=g_screenWidth/2;
            _fineshedBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            _fineshedBtn.frame = CGRectMake((g_screenWidth-btnWidth)/2, mainHeight-90, btnWidth, 35);
            _fineshedBtn.backgroundColor=[UIColor clearColor];
            [_fineshedBtn setTitle:@"立即体验" forState:UIControlStateNormal];
            [_fineshedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_fineshedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            _fineshedBtn.titleLabel.font=[UIFont systemFontOfSize:18];
            _fineshedBtn.layer.cornerRadius=6.0;
            _fineshedBtn.clipsToBounds=YES;
            _fineshedBtn.layer.borderColor=[UIColor whiteColor].CGColor;
            _fineshedBtn.layer.borderWidth=1.0;
            [_fineshedBtn addTarget:self action:@selector(fineshedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

            
            for(int k=0;k<imageArray.count;k++){
                UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(mainWidth*k, 0, mainWidth, mainHeight)];
                imageView.backgroundColor=[UIColor clearColor];
                [imageView setImage:[UIImage imageNamed:imageArray[k]]];
                
                if (k==imageArray.count-1) {
                    imageView.userInteractionEnabled = YES;
                    [imageView addSubview:_fineshedBtn];
                }
                [_mainScrollView addSubview:imageView];
            }
            
            [_mainScrollView setContentSize:CGSizeMake(g_screenWidth*imageArray.count, mainHeight)];
            
            _pageControl = [[YMPageControl alloc]initWithFrame:CGRectMake(0, mainHeight-37, mainWidth, 37)];
            _pageControl.currentPage=0;
            _pageControl.numberOfPages=3;
            _pageControl.backgroundColor=[UIColor clearColor];
            _pageControl.currentPage=0;
            [self addSubview:_pageControl];

            
        } else {
            [self showProgressLine];
        }
        [window addSubview:self];
    }
    return self;
}

-(void)fineshedBtnClicked:(UIButton *)sender
{
    [self finshedLoadGuideView];
}

-(void)finshedLoadGuideView
{
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString*  version=[infoDict objectForKey:@"CFBundleShortVersionString"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:[NSString stringWithFormat:@"guide_%@", version]];
    [userDefault synchronize];
    
    [self showProgressLine];
    _mainScrollView.hidden = YES;
    _fineshedBtn.hidden = YES;
    _pageControl.hidden = YES;
}


#pragma mark UIScrollViewDelegate Methods
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint point=scrollView.contentOffset;
    int pageID=point.x/g_screenWidth;
    _pageControl.currentPage = pageID;
}

- (void)showProgressLine
{
    _adTime = 2;
    //获取启动图片
    CGSize viewSize = _window.bounds.size;
    //横屏请设置成 @"Landscape"
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
        
    }
    UIImage * launchImage = [UIImage imageNamed:launchImageName];
    self.backgroundColor = [UIColor colorWithPatternImage:launchImage];
    if (_adType == FullScreenAdType) {
        self.aDImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainWidth, mainHeight)];
    }else{
        self.aDImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainWidth, mainHeight - mainWidth/3)];
    }
    
    //设置一个图片;
    UIImageView *_view1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, mainHeight/2+50, mainWidth-60, 2)];
    _view1.image = [UIImage imageNamed:@"loading_line.png"];
    //        _view1.backgroundColor = [UIColor blackColor];
    _view1.contentMode = UIViewContentModeScaleToFill;
    
    UIImageView *_view2 = [[UIImageView alloc] initWithFrame:CGRectMake(30, mainHeight/2+50, 30, 30)];
    
    _view2.centerY = _view1.centerY;
    _view2.contentMode = UIViewContentModeScaleToFill;
    _view2.image = [UIImage imageNamed:@"loading_dot.png"];
    
    [self.aDImgView addSubview:_view1];
    [self.aDImgView addSubview:_view2];
    
    //让图片来回移动
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(30, _view1.center.y)];
    translation.toValue = [NSValue valueWithCGPoint:CGPointMake(mainWidth- 30*2, _view1.center.y)];
    translation.duration = 2;//动画持续时间
    translation.repeatCount = HUGE;//动画重复次数
    translation.autoreverses = NO;//是否自动重复
    translation.removedOnCompletion = NO;
    translation.delegate = self;
    
    [_view2.layer addAnimation:translation forKey:@"rotation"];
    [self addSubview:self.aDImgView];
    
    //判断是否登陆
    NSArray *accountAndPassword = [Config getOwnAccountAndPassword];
    if (accountAndPassword) {
        [self backgroundLogin:accountAndPassword];
    } else {
        _isLogin = NO;
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

#pragma mark - 开启关闭动画
- (void)startcloseAnimation{
    [self closeAddImgAnimation];
}

#pragma mark - 关闭动画完成时处理事件
-(void)closeAddImgAnimation
{
    if (countDownTimer==nil) {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    self.hidden = YES;
    self.aDImgView.hidden = YES;
    [self removeFromSuperview];
    
    self.clickBlock(_isLogin);
}

- (void)onTimer {
    if (_adTime == 0) {
        if (countDownTimer!=nil) {
            [countDownTimer invalidate];
            countDownTimer = nil;
        }
        [self startcloseAnimation];
    } else {
        _adTime--;
    }
}


#pragma mark -登录验证
- (void)backgroundLogin:(NSArray *)accountPassword
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    NSString *uuid = [YMDataManager shared].uuid;
    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    
    [YMDataManager shared].reqSeq++;
    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
    
    paramDict[kYM_APPID] = uuid;
    paramDict[kYM_REQSEQ] = reqSeq;
    paramDict[kYM_TIMESTAMP] = currentDate;
    
    NSString *username = accountPassword[0];
    NSString *password = accountPassword[1];
    NSString *remarkCode = accountPassword[2];
    
    paramDict[kYM_USERNAME] = username;
    paramDict[kYM_PASSWORD] = password;
    paramDict[kYM_REMARKCODE] = remarkCode;

    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserLogin"] parameters:paramDict success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                YMUser *model = [YMUser objectWithKeyValues:respDict[kYM_RESPDATA]];
                [YMUserManager sharedInstance].user = model;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMNoticeLoginInIdentifier object:nil userInfo:@{kYM_USERID:model.user_id}];
                
                _isLogin = YES;
                _adTime=0;
                [self onTimer];
            } else if ([resp_id isEqualToString:@"9012"]){
                //密码错误
                _isLogin = NO;
                _adTime=0;
                [self onTimer];
            } else {
                _isLogin = NO;
                _adTime=0;
                [self onTimer];
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(@"提示", resp_desc);
            }
        }
    } failure:^(NSError *error) {
        _isLogin = NO;
        _adTime = 0;
        [self onTimer];
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
    }];
    
}
@end
