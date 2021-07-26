```go
package log

import (
	"net/http"
	"os"

	"github.com/natefinch/lumberjack"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var SugarLogger *zap.SugaredLogger

func InitLogger() {
	writeSyncer := getLogWriter()
	encoder := getEncoder()
	core := zapcore.NewCore(encoder, writeSyncer, zapcore.DebugLevel)

	logger := zap.New(core, zap.AddCaller())
	SugarLogger = logger.Sugar()
}

func getEncoder() zapcore.Encoder {
	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
	return zapcore.NewConsoleEncoder(encoderConfig)
}

func getLogWriter() zapcore.WriteSyncer {
	lumberJackLogger := &lumberjack.Logger{
		// 日志文件的位置
		Filename: "./k8s-agent.log",
		// 在进行切割之前，日志文件的最大大小（以MB为单位）
		MaxSize: 1,
		// 保留旧文件的最大个数
		MaxBackups: 5,
		// 保留旧文件的最大天数
		MaxAge: 30,
		// 是否压缩/归档旧文件
		Compress: false,
	}
	// return zapcore.AddSync(lumberJackLogger)
	// 日志同时输出到标准控制台
	return zapcore.NewMultiWriteSyncer(zapcore.AddSync(os.Stdout), zapcore.AddSync(lumberJackLogger))
}

func simpleHttpGet(url string) {
	SugarLogger.Debugf("Trying to hit GET request for %s", url)
	resp, err := http.Get(url)
	if err != nil {
		SugarLogger.Errorf("Error fetching URL %s : Error = %s", url, err)
	} else {
		SugarLogger.Infof("Success! statusCode = %s for URL %s", resp.Status, url)
		resp.Body.Close()
	}
}

```
