package com.example.giant_step_authenticator

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.giant_step_authenticator/python"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "runPython") {
                    val script: String? = call.argument("script")
                    val args: List<String> = call.argument("args") ?: emptyList()

                    if (script == null) {
                        result.error("PYTHON_ERROR", "Script is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val py = Python.getInstance()
                        
                        // Create a Python module from the script
                        // This is the CORRECT way to execute Python code in Chaquopy
                        val module = py.getModule("builtins")
                        val globals = module.callAttr("dict")
                        
                        // Set sys.argv
                        val sysModule = py.getModule("sys")
                        sysModule.put("argv", args.toTypedArray())
                        
                        // Execute the script as a code object
                        val code = module.callAttr("compile", script, "<string>", "exec")
                        module.callAttr("exec", code, globals)
                        
                        result.success("Python script executed successfully")
                    } catch (e: Exception) {
                        result.error("PYTHON_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}