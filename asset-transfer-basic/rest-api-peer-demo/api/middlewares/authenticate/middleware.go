package authenticate

import (
	"strings"
	"time"

	"stask-api/common/configure"
	"stask-api/common/response"
	respErr "stask-api/common/response/error"
	"stask-api/database/mongo/models"
	"stask-api/database/mongo/queries"
	jwtTool "stask-api/utilities/jwt"
	"stask-api/utilities/local"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

var cfg = configure.GetConfig()

func RefreshToken(ctx *fiber.Ctx) error {
	tokenString := ctx.Get("Authorization")
	if tokenString == "" {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenRequired})
	}
	if !strings.HasPrefix(tokenString, cfg.TokenType) {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrongFormat})
	}
	tokenString = strings.TrimSpace(strings.TrimPrefix(tokenString, cfg.TokenType))
	payload, err := jwtTool.GetGlobal().ValidateToken(tokenString)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	if !payload.IsRefreshToken() {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	tokenId, err := primitive.ObjectIDFromHex(payload.ID)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	queryOption := queries.NewOptions()
	queryOption.SetOnlyFields("_id", "user_id")
	token, err := queries.NewToken(ctx.Context()).GetById(tokenId, queryOption)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenRevoked})
	}
	queryOption.SetOnlyFields("_id", "oauth_refresh_token")
	user, err := queries.NewUser(ctx.Context()).GetById(token.UserId, queryOption)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: "User not found"})
	}
	localService := local.New(ctx)
	localService.SetUser(*user)
	localService.SetTokenId(tokenId)
	return ctx.Next()
}

func AccessToken(ctx *fiber.Ctx) error {
	tokenString := ctx.Get("Authorization")
	if tokenString == "" {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenRequired})
	}
	if !strings.HasPrefix(tokenString, cfg.TokenType) {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrongFormat})
	}
	token := strings.TrimSpace(strings.TrimPrefix(tokenString, cfg.TokenType))
	payload, err := jwtTool.GetGlobal().ValidateToken(token)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	if !payload.IsAccessToken() {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	tokenId, err := primitive.ObjectIDFromHex(payload.ID)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	opt := queries.NewOptions()
	opt.SetOnlyFields("_id", "user_id")
	tok, err := queries.NewToken(ctx.Context()).GetById(tokenId, opt)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenRevoked})
	}
	opt.SetOnlyFields("_id", "username", "alias", "avatar_url", "oauth_access_token")
	user, err := queries.NewUser(ctx.Context()).GetById(tok.UserId, opt)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: "User not found"})
	}
	local.New(ctx).SetUser(*user)
	return ctx.Next()
}

func PersonalAccessTokenMiddleware(ctx *fiber.Ctx) (err error) {
	tokenString := ctx.Get("Authorization")
	if tokenString == "" {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenRequired})
	}
	if !strings.HasPrefix(tokenString, cfg.TokenType) {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrongFormat})
	}
	token := strings.TrimSpace(strings.TrimPrefix(tokenString, cfg.TokenType))
	pat := new(models.PersonalAccessToken)
	if err = pat.SetIDAndKeyByAccessToken(token); err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenWrong})
	}
	queryOption := queries.NewOptions()
	queryOption.SetOnlyFields("_id", "user_id", "project_id", "username", "member_id", "expired_at")
	pat, err = queries.NewPAT(ctx.Context()).GetByIdAndKey(pat.Id, pat.Key, queryOption)
	if err != nil {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenRevoked})
	}
	if pat.ExpiredAt.Before(time.Now()) {
		return response.NewError(fiber.StatusUnauthorized, response.ErrorOptions{Data: respErr.ErrTokenExpired})
	}
	localService := local.New(ctx)
	localService.SetUserId(pat.UserId)
	localService.SetProjectId(pat.ProjectId)
	localService.SetMemberId(pat.MemberId)
	localService.SetUsername(pat.Username)
	localService.SetUser(models.User{
		Username: pat.Username,
		Id:       pat.UserId,
	})
	return ctx.Next()
}
