package permissions

import (
	"github.com/gofiber/fiber/v2"

	"stask-api/common/response"
	"stask-api/database/mongo/models"
)

func CheckPermission(ctx *fiber.Ctx, action string, project *models.Project, task *models.Task) error {
	return response.NewError(fiber.StatusForbidden, response.ErrorOptions{Data: "No Permission"})
}
