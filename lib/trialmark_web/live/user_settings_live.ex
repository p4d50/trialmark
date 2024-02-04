defmodule TrialmarkWeb.UserSettingsLive do
  use TrialmarkWeb, :live_view

  alias Trialmark.Accounts
  alias Trialmark.Profiles
  alias Trialmark.Profiles.Profile

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="p-4 shadow border border-gray-200 rounded-md">
      <.header class="mt-4 text-left">
        Account Profiles 
        <:subtitle>Manage your account profiles</:subtitle>
        <:actions>
          <.link patch={~p"/users/settings/profiles/new"}>
            <.button>New Profile</.button>
          </.link>
        </:actions>
      </.header>

      <.table
        id="profiles"
        rows={@streams.profiles}
      >
        <:col :let={{_id, profile}} label="Name"><%= profile.name %></:col>
        <:action :let={{_id, profile}}>
          <div class="sr-only">
            <.link navigate={~p"/profiles/#{profile}"}>Show</.link>
          </div>
          <.link patch={~p"/users/settings/profiles/#{profile}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, profile}}>
          <.link
            phx-click={JS.push("delete", value: %{id: profile.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>

    <.modal 
      :if={@live_action in [:profile_new, :profile_edit]} 
      id="profile-modal" 
      show 
      on_cancel={JS.patch(~p"/users/settings")}
    >
      <.live_component
        module={TrialmarkWeb.ProfileLive.FormComponent}
        current_user={@current_user}
        id={@profile.id || :new}
        title={@page_title}
        action={@live_action}
        profile={@profile}
        patch={~p"/users/settings"}
      />
    </.modal>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    {:ok, profiles} = Profiles.list_users_profiles(user)

    socket =
      socket
      |> stream(:profiles, profiles)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, url, socket) do
    if String.contains?(url, "profiles") do
      {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    else
      {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:profile, nil)
  end

  defp apply_action(socket, :profile_edit, %{"id" => id}) do
    case Profiles.get_profile(socket.assigns.current_user, id) do
      {:ok, profile} ->
        socket
        |> assign(:page_title, "Edit Profile")
        |> assign(:profile, profile)

      {:error, :unauthorized} ->
        socket 
        |> put_flash(:error, "You can't access this profile")
        |> redirect(to: "/users/settings")
    end
  end

  defp apply_action(socket, :profile_new, _params) do
    socket
    |> assign(:page_title, "New Profile")
    |> assign(:current_user, socket.assigns.current_user)
    |> assign(:profile, %Profile{})
  end

  @impl true
  def handle_info({TrialmarkWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end
  
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, profile} = Profiles.get_profile(socket.assigns.current_user, id)

    case Profiles.delete_profile(socket.assigns.current_user, profile) do
      {:ok, _} -> {:noreply, stream_delete(socket, :profiles, profile)}
      {:error, :unauthorized} -> {:noreply, put_flash(socket, :error, "You can't delete this profile")}
    end
  end

  def handle_event("update_user", params, socket) do
    {:noreply, socket}
  end
end
