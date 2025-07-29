package local

import (
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func (s service) SetExtraBody(value []byte) {
	s.context.Locals(KeyExtraBody, value)
}

func (s service) GetExtraBody() string {
	if value, ok := s.context.Locals(KeyExtraBody).([]byte); ok {
		return string(value)
	}
	return "{}"
}

func (s service) GetStatusCode() int {
	if value, ok := s.context.Locals(KeyStatusCode).(int); ok {
		return value
	}
	return fiber.StatusInternalServerError
}

func (s service) SetStatusCode(value int) {
	s.context.Locals(KeyStatusCode, value)
}

func (s service) SetTokenId(value primitive.ObjectID) {
	s.context.Locals(KeyTokenId, value)
}

func (s service) GetTokenId() primitive.ObjectID {
	if value, ok := s.context.Locals(KeyTokenId).(primitive.ObjectID); ok {
		return value
	}
	return primitive.NilObjectID
}

func (s service) SetProjectId(value primitive.ObjectID) {
	s.context.Locals(KeyProjectId, value)
}

func (s service) GetProjectId() primitive.ObjectID {
	if value, ok := s.context.Locals(KeyProjectId).(primitive.ObjectID); ok {
		return value
	}
	return primitive.NilObjectID
}

func (s service) SetMemberId(value primitive.ObjectID) {
	s.context.Locals(KeyMemberId, value)
}

func (s service) GetMemberId() primitive.ObjectID {
	if value, ok := s.context.Locals(KeyMemberId).(primitive.ObjectID); ok {
		return value
	}
	return primitive.NilObjectID
}

func (s service) SetUserId(value primitive.ObjectID) {
	s.context.Locals(KeyUserId, value)
}

func (s service) GetUserId() primitive.ObjectID {
	if value, ok := s.context.Locals(KeyUserId).(primitive.ObjectID); ok {
		return value
	}
	return primitive.NilObjectID
}

func (s service) SetUsername(value string) {
	s.context.Locals(KeyUsername, value)
}

func (s service) GetUsername() string {
	if value, ok := s.context.Locals(KeyUsername).(string); ok {
		return value
	}
	return ""
}

func (s service) SetResponseBody(value []byte) {
	s.context.Locals(KeyResponseBody, value)
}

func (s service) GetResponseBody() string {
	if value, ok := s.context.Locals(KeyResponseBody).([]byte); ok {
		return string(value)
	}
	return "{}"
}
