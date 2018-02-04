Application.put_env(:catalog_api, :secret_key, "1234567890")
Application.put_env(:catalog_api, :username, "test-user")
Application.put_env(:catalog_api, :environment, "dev")
ExUnit.start()
