package co.potatoproject.ffmpeg_basic;

import android.text.TextUtils;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.arthenica.mobileffmpeg.Config;
import com.arthenica.mobileffmpeg.FFmpeg;

import java.util.List;

import static com.arthenica.mobileffmpeg.FFmpeg.RETURN_CODE_CANCEL;
import static com.arthenica.mobileffmpeg.FFmpeg.RETURN_CODE_SUCCESS;

/**
 * FfmpegBasicPlugin
 */
public class FfmpegBasicPlugin {

    private static final String TAG = "FfmpegBasicPlugin";
    private final NativeStreamHandler mNativeStreamHandler = new NativeStreamHandler();

    private FfmpegBasicPlugin(MethodChannel methodProvider, EventChannel eventChannel) {
        methodProvider.setMethodCallHandler(new MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                switch (call.method) {
                    case "exec": {
                        final String cmd = call.argument("cmd");
                        if (cmd != null)
                            ffmpegExec(cmd);
                        result.success(null);
                        break;
                    }
                    case "execList": {
                        final List<String> cmd = call.argument("cmd");
                        if (cmd != null)
                            ffmpegExecArr(cmd);
                        result.success(null);
                        break;
                    }
                    case "cancel":
                        FFmpeg.cancel();
                        result.success(null);
                        break;
                    case "getExternalLibs":
                        result.success(TextUtils.join(",", Config.getExternalLibraries()));
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });
        eventChannel.setStreamHandler(mNativeStreamHandler);
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel methodProvider = new MethodChannel(registrar.messenger(), "ffmpeg_basic");
        final EventChannel eventChannel = new EventChannel(registrar.view(), "ffmpeg_basic_events");
        new FfmpegBasicPlugin(methodProvider, eventChannel);
    }

    private void ffmpegExec(final String command) {
        new Thread(new Runnable() {
            public void run() {
                FFmpeg.execute(command);
                mNativeStreamHandler.emitData(getRetCode());
            }
        }).start();
    }

    private void ffmpegExecArr(final List<String> command) {
        new Thread(new Runnable() {
            public void run() {
                FFmpeg.execute(command.toArray(new String[0]));
                mNativeStreamHandler.emitData(getRetCode());

            }
        }).start();
    }

    private int getRetCode() {
        int rc = FFmpeg.getLastReturnCode();
        String output = FFmpeg.getLastCommandOutput();
        switch (rc) {
            case RETURN_CODE_SUCCESS:
                Log.i(TAG, "Exec success!");
                break;
            case RETURN_CODE_CANCEL:
                Log.i(TAG, "Exec cancelled.");
                break;
            default:
                Log.i(TAG, String.format("Exec failure!\n%s (%d)", output, rc));
        }
        return rc;
    }

    class NativeStreamHandler implements EventChannel.StreamHandler {

        EventChannel.EventSink eventSink;

        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
            this.eventSink = eventSink;
        }

        void emitData(Object data) {
            if (eventSink != null)
                eventSink.success(data);
        }

        @Override
        public void onCancel(Object o) {

        }
    }
}
