package configure

import (
	"fmt"

	"github.com/caarlos0/env/v11"
	"github.com/joho/godotenv"
	"github.com/rs/zerolog/log"
)

var config *Configuration

type Configuration struct {
	Host              string `env:"HOST" envDefault:"0.0.0.0"`
	Port              string `env:"PORT" envDefault:"8218"`
	ConfigOrg1        string `env:"CONFIG_ORG_1" envDefault:"config_org_1.yaml"`
	PaginationMaxItem int64  `env:"PAGINATION_MAX_ITEM" envDefault:"50"`
	APIBodyLimitSize  int    `env:"API_BODY_LIMIT_SIZE" envDefault:"1073741824"`
	Debug             bool   `env:"DEBUG" envDefault:"true"`
	ElasticAPMEnable  bool   `env:"ELASTIC_APM_ENABLE" envDefault:"false"`
}

func (cfg Configuration) ServerAddress() string {
	return fmt.Sprintf("%s:%s", cfg.Host, cfg.Port)
}

func GetConfig() Configuration {
	if config == nil {
		_ = godotenv.Load()
		config = &Configuration{}
		if err := env.Parse(config); err != nil {
			log.Fatal().Err(err).Msg("Get Config Error")
		}
	}
	return *config
}
