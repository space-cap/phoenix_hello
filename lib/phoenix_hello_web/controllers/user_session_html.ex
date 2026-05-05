defmodule PhoenixHelloWeb.UserSessionHTML do
  use PhoenixHelloWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:phoenix_hello, PhoenixHello.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
