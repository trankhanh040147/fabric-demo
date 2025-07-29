package routers

import (
	"github.com/gofiber/fiber/v2"

	transactionCtrl "stask-api/api/controllers/transaction"
)

type Transaction interface {
	V1()
}

type transaction struct {
	router fiber.Router
	ctrl   transactionCtrl.Controller
}

func NewTransaction(router fiber.Router) Transaction {
	return &transaction{
		router: router.Group("/transactions"),
		ctrl:   transactionCtrl.New(),
	}
}

func (r *transaction) V1() {
	r.router.Post("/", r.ctrl.Endorse)
}
