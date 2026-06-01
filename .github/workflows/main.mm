#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

static BOOL isAutoTouchRunning = NO;
static NSTimeInterval touchInterval = 1.0;
static dispatch_queue_t autoTouchQueue = nil;

@interface AutotouhMenuWindow : UIWindow
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *menuContainerView;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UILabel *speedStatusLabel;
@end

@implementation AutotouhMenuWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        autoTouchQueue = dispatch_queue_create("com.autotouh.bgqueue", DISPATCH_QUEUE_SERIAL);
        self.windowLevel = UIWindowLevelAlert + 10.0;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = NO;
        [self setupFloatingButton];
        [self setupMenuLayout];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

- (void)setupFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(40, 150, 60, 60);
    self.floatingButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.85];
    self.floatingButton.layer.cornerRadius = 30;
    self.floatingButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.floatingButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.floatingButton.layer.shadowOpacity = 0.5;
    self.floatingButton.layer.shadowRadius = 4;
    
    [self.floatingButton setTitle:@"Menu" forState:UIControlStateNormal];
    [self.floatingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtonPan:)];
    [self.floatingButton addGestureRecognizer:panGesture];
    [self.floatingButton addTarget:self action:@selector(toggleMenuVisibility) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.floatingButton];
}

- (void)handleButtonPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    CGPoint newCenter = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    newCenter.x = MAX(gesture.view.frame.size.width / 2, MIN(screenBounds.size.width - gesture.view.frame.size.width / 2, newCenter.x));
    newCenter.y = MAX(gesture.view.frame.size.height / 2, MIN(screenBounds.size.height - gesture.view.frame.size.height / 2, newCenter.y));
    gesture.view.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)setupMenuLayout {
    self.menuContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 240)];
    self.menuContainerView.center = self.center;
    self.menuContainerView.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:0.95];
    self.menuContainerView.layer.cornerRadius = 16;
    self.menuContainerView.layer.borderWidth = 1.0;
    self.menuContainerView.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:0.5].CGColor;
    self.menuContainerView.hidden = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 25)];
    titleLabel.text = @"Autotouh Tool";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.menuContainerView addSubview:titleLabel];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(20, 60, 110, 45);
    startBtn.backgroundColor = [UIColor systemGreenColor];
    startBtn.layer.cornerRadius = 10;
    [startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startAutoTouchEngine) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainerView addSubview:startBtn];
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBtn.frame = CGRectMake(150, 60, 110, 45);
    stopBtn.backgroundColor = [UIColor systemRedColor];
    stopBtn.layer.cornerRadius = 10;
    [stopBtn setTitle:@"Stop" forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopAutoTouchEngine) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainerView addSubview:stopBtn];
    
    self.speedStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 240, 20)];
    self.speedStatusLabel.text = @"Speed: 1.00s";
    self.speedStatusLabel.textColor = [UIColor lightGrayColor];
    self.speedStatusLabel.font = [UIFont systemFontOfSize:13];
    self.speedStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.menuContainerView addSubview:self.speedStatusLabel];
    
    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(18, 165, 244, 30)];
    self.speedSlider.minimumValue = 0.01;
    self.speedSlider.maximumValue = 3.00;
    self.speedSlider.value = touchInterval;
    [self.speedSlider addTarget:self action:@selector(sliderSpeedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menuContainerView addSubview:self.speedSlider];
    
    [self addSubview:self.menuContainerView];
}

- (void)toggleMenuVisibility {
    self.menuContainerView.hidden = !self.menuContainerView.hidden;
    if (!self.menuContainerView.hidden) {
        self.menuContainerView.center = self.center;
    }
}

- (void)sliderSpeedChanged:(UISlider *)sender {
    touchInterval = sender.value;
    self.speedStatusLabel.text = [NSString stringWithFormat:@"Speed: %.2f s", touchInterval];
}

- (void)startAutoTouchEngine {
    if (isAutoTouchRunning) return;
    isAutoTouchRunning = YES;
    
    dispatch_async(autoTouchQueue, ^{
        while (isAutoTouchRunning) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect screenRect = [UIScreen mainScreen].bounds;
                CGPoint centralPoint = CGPointMake(screenRect.size.width / 2, screenRect.size.height / 2);
                [self executePhysicalTouchAtPoint:centralPoint];
            });
            [NSThread sleepForTimeInterval:touchInterval];
        }
    });
}

- (void)stopAutoTouchEngine {
    isAutoTouchRunning = NO;
}

- (void)executePhysicalTouchAtPoint:(CGPoint)point {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow && window != self) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    if (keyWindow) {
        UIView *targetView = [keyWindow hitTest:point withEvent:nil];
        if (targetView) {
            if ([targetView respondsToSelector:@selector(setHighlighted:)]) {
                [(UIButton *)targetView setHighlighted:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [(UIButton *)targetView setHighlighted:NO];
                });
            }
        }
    }
}

@end

static void __attribute__((constructor)) initializeAutotouhPlugin() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static AutotouhMenuWindow *pluginWindow = nil;
        pluginWindow = [[AutotouhMenuWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
}
