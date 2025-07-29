package local

import (
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Service interface {
	SetExtraBody(value []byte)
	GetExtraBody() string
	GetStatusCode() int
	SetStatusCode(value int)
	SetTokenId(value primitive.ObjectID)
	GetTokenId() primitive.ObjectID
	SetProjectId(value primitive.ObjectID)
	GetProjectId() primitive.ObjectID
	SetUserId(value primitive.ObjectID)
	GetUserId() primitive.ObjectID
	GetUsername() string
	SetUsername(value string)
	SetMemberId(value primitive.ObjectID)
	GetMemberId() primitive.ObjectID
	SetResponseBody(value []byte)
	GetResponseBody() string
}

const (
	KeyTokenId      = "tokenId"
	KeyUser         = "user"
	KeyExtraBody    = "extraBody"
	KeyStatusCode   = "statusCode"
	KeyProjectId    = "projectId"
	KeyMemberId     = "memberId"
	KeyUserId       = "userId"
	KeyUsername     = "username"
	KeyActivity     = "activity"
	KeyResponseBody = "responseBody"
)

type service struct {
	context *fiber.Ctx
}

func New(ctx *fiber.Ctx) Service {
	return &service{context: ctx}
}
