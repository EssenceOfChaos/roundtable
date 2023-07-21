import Config
# This file is read after compilation and configures how the application works at runtime.
# We can read system environment variables (System.get_env/1)  or any external configuration in this file.
require Logger

DotenvParser.load_file(".env")
Logger.debug("Parsing Dotenv file, secret value is #{System.get_env("SECRET_VALUE")}")
