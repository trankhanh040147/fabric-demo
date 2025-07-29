package main

import (
	"os"
	"os/signal"
	"syscall"

	"github.com/bytedance/sonic"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
	_ "go.uber.org/automaxprocs"

	"stask-api/api/routers"
	"stask-api/common/configure"
	"stask-api/common/logging"
	"stask-api/common/request/validator"
	"stask-api/common/response"
	respErr "stask-api/common/response/error"
)

var cfg = configure.GetConfig()

func main() {
	logging.InitLogger()
	validator.InitValidateEngine()
	app := fiber.New(fiber.Config{
		ErrorHandler: response.FiberErrorHandler,
		JSONDecoder:  sonic.Unmarshal,
		JSONEncoder:  sonic.Marshal,
		BodyLimit:    cfg.APIBodyLimitSize,
	})
	addMiddleware(app)
	addV1Route(app)
	handleURLNotFound(app)

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		logging.GetLogger().Info().Msg("ready")
		if err := app.Listen(cfg.ServerAddress()); err != nil {
			logging.GetLogger().Error().Err(err).Str("function", "main").Str("functionInline", "app.Listen").Msg("Can't start server")
		}
		sigChan <- syscall.SIGTERM
	}()
	<-sigChan
	logging.GetLogger().Info().Msg("Shutting down...")
	_ = app.Shutdown()
}

func handleURLNotFound(app *fiber.App) {
	app.Use(func(ctx *fiber.Ctx) error {
		return response.New(ctx, response.Options{Code: fiber.StatusNotFound, Data: respErr.ErrUrlNotFound})
	})
}

func addMiddleware(app *fiber.App) {
	if cfg.ElasticAPMEnable {
	} else {
		recoverConfig := recover.ConfigDefault
		recoverConfig.EnableStackTrace = cfg.Debug
		app.Use(recover.New(recoverConfig))
	}
	app.Use(logging.FiberLoggerMiddleware())
}

func addV1Route(app *fiber.App) {
	route := app.Group("/api/peer-api/v1")
	routers.NewTransaction(route).V1()
}
