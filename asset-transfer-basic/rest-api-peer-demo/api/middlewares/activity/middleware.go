package activity

import (
	"errors"

	"stask-api/common/constants"
	"stask-api/common/logging"
	"stask-api/common/response"
	"stask-api/database/mongo/queries"
	"stask-api/utilities/local"

	"github.com/gofiber/fiber/v2"
)

var (
	logger = logging.GetLogger()
)

func Create(ctx *fiber.Ctx) error {
	if err := ctx.Next(); err != nil {
		_ = response.FiberErrorHandler(ctx, err)
		if e := new(response.Error); errors.As(err, &e) && e.Code != fiber.StatusOK {
			return nil
		}
	}
	if ctx.Response().StatusCode() < fiber.StatusOK || ctx.Response().StatusCode() >= fiber.StatusMultipleChoices {
		return nil
	}
	localService := local.New(ctx)
	activity := localService.GetActivity()
	actionType := activity.GetActivityActionType()
	if actionType == constants.ActivityActionTypeUnknown {
		return nil
	}
	if err := queries.NewActivity(ctx.Context()).CreateOne(activity); err != nil {
		logger.Error().Err(err).Str("function", "Create").
			Str("functionInline", "queries.NewActivity(ctx.Context()).CreateOne").Msg("activity-middleware")
		return nil
	}
	return nil
}
