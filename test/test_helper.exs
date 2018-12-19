Bureaucrat.start(
  writer: Bureaucrat.MarkdownWriter,
  default_path: "docs/api-v1.md",
  paths: [],
  titles: [
    {SecretSantaWeb.API.V1.SessionController, "Session management"},
    {SecretSantaWeb.API.V1.UserController, "User management"}
  ],
  env_var: "DOC"
  )
ExUnit.start(formatters: [ExUnit.CLIFormatter, Bureaucrat.Formatter])

Ecto.Adapters.SQL.Sandbox.mode(SecretSanta.Repo, :manual)
