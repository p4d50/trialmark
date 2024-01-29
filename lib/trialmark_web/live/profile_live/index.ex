defmodule TrialmarkWeb.ProfileLive.Index do
  use TrialmarkWeb, :live_view

  alias Trialmark.Accounts
  alias Trialmark.Profiles
  alias Trialmark.Profiles.Profile

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    profiles = Profiles.list_profiles_by_user_token(user_token)

    {:ok, stream(socket, :profiles, profiles)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:profile, Profiles.get_profile!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Profile")
    |> assign(:profile, %Profile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Profiles")
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info({TrialmarkWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Profiles.get_profile!(id)
    {:ok, _} = Profiles.delete_profile(profile)

    {:noreply, stream_delete(socket, :profiles, profile)}
  end
end
