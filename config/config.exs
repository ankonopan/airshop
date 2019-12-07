# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :air_shop, :airfranceklm,
  pool_size: 5,
  pool_max_overflow: 2,
  endpoint: "https://ndc-rct.airfranceklm.com/passenger/distribmgmt/001448v01/EXT",
  api_key: System.fetch_env!("AIR_FRANCE_API_KEY")

config :air_shop, :british_airways,
  pool_size: 5,
  pool_max_overflow: 2,
  endpoint: "https://test.api.ba.com/selling-distribution/AirShopping/V2",
  api_key: System.fetch_env!("BRITISH_AIRWAYS_API_KEY")

config :soap, :globals, version: "1.1"
