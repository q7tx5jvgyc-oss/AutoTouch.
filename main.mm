#import <UIKit/UIKit.h>

@interface MoustacheManager : NSObject
@end

@implementation MoustacheManager
+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // إذا لم يكن الجهاز مفعل سابقاً، اطلب الرمز
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isActivated"]) {
            [self showLogin];
        }
    });
}

+ (void)showLogin {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Moustache Security" 
                                                                    message:@"أدخل رمز التفعيل (استخدام لمرة واحدة)" 
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *t) { t.secureTextEntry = YES; }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"تفعيل" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *input = alert.textFields.firstObject.text;
        
        // --- منطق التحقق ---
        // هنا يجب أن تتصل بسيرفر (Server) للتأكد أن الرمز لم يُستخدم.
        // بما أننا لا نملك سيرفر حالياً، سنحاكي المنطق:
        
        if ([input isEqualToString:@"CODE123"]) { // رمز تجريبي
            // تم التفعيل بنجاح
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isActivated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            // كود خاطئ أو مستخدم مسبقاً -> كراش متعمد
            [self triggerCrash];
        }
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)triggerCrash {
    // هذه الطريقة تسبب إغلاق التطبيق فوراً (Crash)
    abort(); 
}
@end
