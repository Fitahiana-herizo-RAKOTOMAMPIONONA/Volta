package com.example.volta

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs

class MainActivity : FlutterActivity() {
    private val CHANNEL = "volta/battery_info"
    private val TAG = "VoltaBatteryPlugin"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryStats" -> {
                    try {
                        val data = getBatteryStats()
                        if (data != null) {
                            result.success(data)
                        } else {
                            result.error("UNAVAILABLE", "Battery info not available.", null)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting battery stats", e)
                        result.error("ERROR", "Failed to get battery stats: ${e.message}", null)
                    }
                }
                "getBatteryCapacity" -> {
                    try {
                        val capacity = getBatteryCapacity()
                        result.success(capacity)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting battery capacity", e)
                        result.error("ERROR", "Failed to get battery capacity: ${e.message}", null)
                    }
                }
                "getBatteryTemperature" -> {
                    try {
                        val temperature = getBatteryTemperature()
                        result.success(temperature)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting battery temperature", e)
                        result.error("ERROR", "Failed to get battery temperature: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getBatteryStats(): Map<String, Any>? {
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            applicationContext.registerReceiver(null, ifilter)
        }

        if (batteryStatus == null) {
            Log.w(TAG, "Unable to get battery status")
            return null
        }

        // Tension en mV
        val voltage = batteryStatus.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
        
        // Niveau de batterie (0-100%)
        val level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val batteryPct = if (level >= 0 && scale > 0) {
            (level * 100 / scale.toFloat()).toInt()
        } else {
            -1
        }

        // État de la charge
        val status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        
        // Type de charge
        val chargePlug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)
        val chargingMethod = when (chargePlug) {
            BatteryManager.BATTERY_PLUGGED_USB -> "USB"
            BatteryManager.BATTERY_PLUGGED_AC -> "AC"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "Wireless"
            else -> "Unknown"
        }

        // Santé de la batterie
        val health = batteryStatus.getIntExtra(BatteryManager.EXTRA_HEALTH, -1)
        val healthStatus = when (health) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Unspecified Failure"
            BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
            else -> "Unknown"
        }

        // Température
        val temperature = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
        val temperatureCelsius = if (temperature > 0) temperature / 10.0 else 0.0

        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        
        // Courant instantané (en microampères)
        val currentNowMicroAmp: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
            } catch (e: Exception) {
                Log.w(TAG, "Unable to get current now", e)
                -1
            }
        } else {
            -1
        }

        // Courant moyen (en microampères)
        val currentAvgMicroAmp: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_AVERAGE)
            } catch (e: Exception) {
                Log.w(TAG, "Unable to get current average", e)
                -1
            }
        } else {
            -1
        }

        // Capacité de la batterie
        val capacityMah = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            } catch (e: Exception) {
                Log.w(TAG, "Unable to get battery capacity", e)
                -1
            }
        } else {
            -1
        }

        // Conversion en ampères (valeur absolue pour le courant de charge)
        val currentNowAmp = if (currentNowMicroAmp != Int.MIN_VALUE && currentNowMicroAmp != -1) {
            abs(currentNowMicroAmp) / 1_000_000.0
        } else {
            0.0
        }

        val currentAvgAmp = if (currentAvgMicroAmp != Int.MIN_VALUE && currentAvgMicroAmp != -1) {
            abs(currentAvgMicroAmp) / 1_000_000.0
        } else {
            0.0
        }

        // Puissance approximative en watts = V * I
        val powerNow = if (voltage > 0 && currentNowAmp > 0) {
            voltage / 1000.0 * currentNowAmp
        } else {
            0.0
        }

        val powerAvg = if (voltage > 0 && currentAvgAmp > 0) {
            voltage / 1000.0 * currentAvgAmp
        } else {
            0.0
        }

        // Estimation du temps de charge (très approximative)
        val chargingTimeEstimate = if (isCharging && currentNowAmp > 0 && capacityMah > 0) {
            val remainingCapacity = capacityMah * (100 - batteryPct) / 100.0
            val chargingTimeHours = remainingCapacity / (currentNowAmp * 1000)
            chargingTimeHours
        } else {
            -1.0
        }

        val result = mapOf(
            "voltage" to voltage / 1000.0,  // Conversion en volts
            "current" to currentNowAmp,     // Courant instantané en ampères
            "currentAvg" to currentAvgAmp,  // Courant moyen en ampères
            "power" to powerNow,            // Puissance instantanée en watts
            "powerAvg" to powerAvg,         // Puissance moyenne en watts
            "isCharging" to isCharging,
            "batteryLevel" to batteryPct,
            "chargingMethod" to chargingMethod,
            "batteryHealth" to healthStatus,
            "temperature" to temperatureCelsius,
            "capacity" to capacityMah,
            "chargingTimeEstimate" to chargingTimeEstimate
        )

        Log.d(TAG, "Battery stats: $result")
        return result
    }

    private fun getBatteryCapacity(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            } catch (e: Exception) {
                Log.w(TAG, "Unable to get battery capacity", e)
                -1
            }
        } else {
            -1
        }
    }

    private fun getBatteryTemperature(): Double {
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            applicationContext.registerReceiver(null, ifilter)
        }

        return if (batteryStatus != null) {
            val temperature = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
            if (temperature > 0) temperature / 10.0 else 0.0
        } else {
            0.0
        }
    }
}