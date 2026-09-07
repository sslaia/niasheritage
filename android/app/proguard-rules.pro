# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Native methods and JNI preservation
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve Flutter generated plugin registrants
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# SQLite & Drift native bindings
-keep class com.sqflite.** { *; }
-dontwarn com.sqflite.**
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# Keep models and annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Suppress harmless warnings from dependencies
-dontwarn java.awt.**
-dontwarn javax.annotation.**
