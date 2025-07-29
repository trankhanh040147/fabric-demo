package serializers

import (
	"stask-api/common/request/validator"
	"stask-api/common/response"

	"github.com/gofiber/fiber/v2"
)

type TransactionCreateBodyValidate struct {
	TransactionId string   `json:"transaction_id" validate:"required"`
	ChaincodeId   string   `json:"chaincode_id" validate:"required"`
	ChaincodeFunc string   `json:"chaincode_func" validate:"required"`
	Args          [][]byte `json:"args" validate:"required"`
}

func (v *TransactionCreateBodyValidate) Validate() error {
	validateEngine := validator.GetValidateEngine()
	if err := validateEngine.Struct(v); err != nil {
		return response.NewError(fiber.StatusBadRequest, response.ErrorOptions{
			Data: validator.ParseValidateError(err),
		})
	}
	return nil
}
