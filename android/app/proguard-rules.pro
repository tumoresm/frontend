# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Suppress deprecation warnings for third-party packages
-dontwarn dev.fluttercommunity.plus.device_info.**
-dontwarn com.linusu.flutter_web_auth_2.**

# Keep device info plus classes
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Keep flutter web auth classes
-keep class com.linusu.flutter_web_auth_2.** { *; }

# Suppress warnings about deprecated APIs
-dontwarn android.os.Build$VERSION_CODES
-dontwarn android.os.Build

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes with @Keep annotation
-keep @androidx.annotation.Keep class * {*;}
-keep @com.google.android.gms.common.annotation.KeepName class * {*;}
-keep @javax.annotation.concurrent.GuardedBy class * {*;}

# Keep all enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}