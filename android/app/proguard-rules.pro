# Keep the JavaScript bridge surface intact if/when @JavascriptInterface is used.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
