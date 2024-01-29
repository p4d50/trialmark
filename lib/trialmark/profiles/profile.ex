defmodule Trialmark.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :name, :string
    field :avatar_url, :string

    belongs_to :user, Trialmark.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:name, :avatar_url])
    |> validate_required([:name, :avatar_url])
  end
end
