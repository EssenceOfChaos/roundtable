import Config

# This file is read at the build time, i.e. before we compile our application and load our dependencies.
# Protip: We can use this to control how our application is compiled.

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
