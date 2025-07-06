-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.impl.StaticMDCBinder
# Stripe Terminal SDK
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

-keep class com.fasterxml.jackson.databind.** { *; }
-keepclassmembers class * {
    @com.fasterxml.jackson.annotation.JsonProperty <fields>;
    @com.fasterxml.jackson.annotation.JsonCreator *;
}
-keepattributes *Annotation*
-dontwarn com.fasterxml.jackson.databind.**
-dontwarn java.beans.**

# --- SLF4J (Logging utilisé dans des libs comme Stripe, Jackson, etc.) ---
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Évite l’obfuscation des classes utilisées via réflexion
-keepnames class * {
    @com.fasterxml.jackson.annotation.* <methods>;
}