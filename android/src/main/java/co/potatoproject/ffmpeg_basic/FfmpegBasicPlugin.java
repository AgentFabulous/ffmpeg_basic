package co.potatoproject.ffmpeg_basic;

import android.text.TextUtils;
import android.util.Log;

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
public class FfmpegBasicPlugin implements MethodCallHandler {

    private static final String TAG = "FfmpegBasicPlugin";

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "ffmpeg_basic");
        channel.setMethodCallHandler(new FfmpegBasicPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "exec": {
                final String cmd = call.argument("cmd");
                result.success(ffmpegExec(cmd));
                break;
            }
            case "execList": {
                final List<String> cmd = call.argument("cmd");
                if (cmd != null)
                    result.success(ffmpegExecArr(cmd));
                else
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

    private int ffmpegExec(String command) {
        FFmpeg.execute(command);
        return getRetCode();
    }

    private int ffmpegExecArr(List<String> command) {
        FFmpeg.execute(command.toArray(new String[0]));
        return getRetCode();
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
}
