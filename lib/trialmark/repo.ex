defmodule Trialmark.Repo do
  use Ecto.Repo,
    otp_app: :trialmark,
    adapter: Ecto.Adapters.Postgres
end
