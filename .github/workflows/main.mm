#import <UIKit/UIKit.h>

@interface AutoTouchWindow : UIWindow
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) NSMutableArray *targetCircles;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) float clickSpeed;
@end

@implementation AutoTouchWindow

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // حماية ظهور النافذة فوق التطبيقات والألعاب طوال الوقت
        self.windowLevel = UIWindowLevelAlert + 10.0;
        self.backgroundColor = [UIColor clearColor];
        [self setHidden:NO];
        
        self.isRunning = NO;
        self.clickSpeed = 1.0;
        self.targetCircles = [[NSMutableArray alloc] init];
        
        [self createFloatingButton];
        [self createMenuView];
    }
    return self;
}

// تصميم الزر العائم وإضافة ميزة السحب والتحريك بالإصبع
- (void)createFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(50, 150, 60, 60);
    self.floatingButton.backgroundColor = [UIColor systemBlueColor];
    self.floatingButton.layer.cornerRadius = 30;
    self.floatingButton.layer.shadowOpacity = 0.5;
    self.floatingButton.layer.shadowRadius = 5;
    self.floatingButton.layer.shadowOffset = CGSizeMake(0, 3);
    
    if (@available(iOS 13.0, *)) {
        [self.floatingButton setImage:[UIImage systemImageNamed:@"hand.tap.fill"] forState:UIControlStateNormal];
        self.floatingButton.tintColor = [UIColor whiteColor];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatingButton addGestureRecognizer:panGesture];
    [self.floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.floatingButton];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self];
}

// تصميم لوحة التحكم (السرعة، أزرار التشغيل، إضافة الأهداف)
- (void)createMenuView {
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 320)];
    self.menuView.center = self.center;
    self.menuView.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.95];
    self.menuView.layer.cornerRadius = 20;
    self.menuView.layer.shadowOpacity = 0.4;
    self.menuView.layer.shadowRadius = 15;
    self.menuView.hidden = YES;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 260, 25)];
    titleLabel.text = @"لوحة تحكم الأوتو";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:titleLabel];

    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.toggleButton.frame = CGRectMake(20, 60, 240, 50);
    self.toggleButton.backgroundColor = [UIColor systemGreenColor];
    [self.toggleButton setTitle:@"▶️ تشغيل الأوتو" forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.toggleButton.layer.cornerRadius = 12;
    [self.toggleButton addTarget:self action:@selector(toggleAutoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.toggleButton];

    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 240, 20)];
    self.speedLabel.text = @"سرعة النقر: 1.0 ثانية";
    self.speedLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [self.menuView addSubview:self.speedLabel];

    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 160, 240, 30)];
    self.speedSlider.minimumValue = 0.1;
    self.speedSlider.maximumValue = 5.0;
    self.speedSlider.value = 1.0;
    [self.speedSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:self.speedSlider];

    UIButton *addTargetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    addTargetBtn.frame = CGRectMake(20, 210, 240, 45);
    addTargetBtn.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.1];
    [addTargetBtn setTitle:@"➕ إضافة هدف (نقرة)" forState:UIControlStateNormal];
    [addTargetBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    addTargetBtn.layer.cornerRadius = 10;
    [addTargetBtn addTarget:self action:@selector(addTargetClick) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:addTargetBtn];

    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(20, 270, 240, 30);
    [clearBtn setTitle:@"مسح الأهداف" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearTargetsClick) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:clearBtn];

    [self addSubview:self.menuView];
}

- (void)toggleMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self.menuView.hidden = !self.menuView.hidden;
    }];
}

- (void)sliderChanged:(UISlider *)sender {
    self.clickSpeed = sender.value;
    self.speedLabel.text = [NSString stringWithFormat:@"سرعة النقر: %.1f ثانية", sender.value];
}

- (void)toggleAutoClick {
    self.isRunning = !self.isRunning;
    if (self.isRunning) {
        self.toggleButton.backgroundColor = [UIColor systemRedColor];
        [self.toggleButton setTitle:@"🛑 إيقاف الأوتو" forState:UIControlStateNormal];
        self.floatingButton.backgroundColor = [UIColor systemGreenColor];
    } else {
        self.toggleButton.backgroundColor = [UIColor systemGreenColor];
        [self.toggleButton setTitle:@"▶️ تشغيل الأوتو" forState:UIControlStateNormal];
        self.floatingButton.backgroundColor = [UIColor systemBlueColor];
    }
}

- (void)addTargetClick {
    NSInteger targetNumber = self.targetCircles.count + 1;
    UIView *targetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    targetView.center = CGPointMake(self.center.x, self.center.y + (targetNumber * 10));
    targetView.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.8];
    targetView.layer.cornerRadius = 17.5;
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:targetView.bounds];
    numLabel.text = [NSString stringWithFormat:@"%ld", (long)targetNumber];
    numLabel.textColor = [UIColor whiteColor];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.font = [UIFont boldSystemFontOfSize:14];
    [targetView addSubview:numLabel];
    
    UIPanGestureRecognizer *targetPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [targetView addGestureRecognizer:targetPan];
    
    [self addSubview:targetView];
    [self.targetCircles addObject:targetView];
}

- (void)clearTargetsClick {
    for (UIView *view in self.targetCircles) [view removeFromSuperview];
    [self.targetCircles removeAllObjects];
    if (self.isRunning) [self toggleAutoClick];
}
@end

static void __attribute__((constructor)) initialize(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static AutoTouchWindow *autoWindow = nil;
        autoWindow = [[AutoTouchWindow alloc] init];
    });
}
