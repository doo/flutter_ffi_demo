#import "FlutterFfiDemoPlugin.h"
#if __has_include(<flutter_ffi_demo/flutter_ffi_demo-Swift.h>)
#import <flutter_ffi_demo/flutter_ffi_demo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_ffi_demo-Swift.h"
#endif

@implementation FlutterFfiDemoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterFfiDemoPlugin registerWithRegistrar:registrar];
}
@end
