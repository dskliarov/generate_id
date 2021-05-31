import Config

config :logger,
  backends: [:console]

config :id_generator,
  node_id: System.get_env("NODE_ID")

if File.exists?("./config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
