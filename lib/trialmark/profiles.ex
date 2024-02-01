defmodule Trialmark.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false

  alias Trialmark.Repo
  alias Trialmark.Policy
  alias Trialmark.Accounts
  alias Trialmark.Accounts.User
  alias Trialmark.Profiles.Profile

  @doc """
  Returns the list of profiles associated to user

  ## Example

      iex> list_user_profiles(user)
      {:ok, [%Profile{}, ...]}

  """
  def list_users_profiles(%User{} = user) do
    user = user
    |> Repo.preload(:profiles)
    
    {:ok, user.profiles}
  end

  @doc """
  Returns the list of profiles using user token.

  ## Examples

      iex> list_profiles_by_user_token(token)
      {:ok, [%Profile{}, ...]}

  """
  def list_profiles_by_user_token(token) do
    user = 
      Accounts.get_user_by_session_token(token)
      |> Repo.preload(:profiles)

    case user do
      nil -> {:error, :invalid_token}
      user -> {:ok, user.profiles}
    end
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile(%User{} = current_user, id) do 
    profile = 
      Profile
      |> where(id: ^id)
      |> Repo.one()

    case profile do
      nil -> {:error, :not_found}
      profile ->
        with :ok <- Policy.authorize(:profile_read, current_user, profile), do: {:ok, profile}
    end
  end

  @doc """
  Creates a profile for specific user.

  ## Examples

      iex> create_profile(%{field: value}, %User{})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}, user) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(current_user, profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(current_user, profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%User{} = current_user, %Profile{} = profile, attrs) do
    with :ok <- Policy.authorize(:profile_update, current_user, profile) do
      profile
      |> Profile.changeset(attrs)
      |> Repo.update()
    end
  end

  # TODO: Create delete_profile_by_id

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(current_user, profile)
      {:ok, %Profile{}}

      iex> delete_profile(current_user, profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%User{} = current_user, %Profile{} = profile) do
    with :ok <- Policy.authorize(:profile_delete, current_user, profile), do: Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end
end
