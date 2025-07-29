package logging

import (
	"github.com/gofiber/fiber/v2"

	"stask-api/utilities/local"
)

func LogResponse(ctx *fiber.Ctx) error {
	result := ctx.Next()
	local.New(ctx).SetResponseBody(ctx.Response().Body())
	return result
}
