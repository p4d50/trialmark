defmodule TrialmarkWeb.UserSettingsLive do
  use TrialmarkWeb, :live_view

  alias Trialmark.Accounts
  alias Trialmark.Profiles
  alias Trialmark.Profiles.Profile

  def render(assigns) do
    ~H"""
    <.header class="mb-4 text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="mb-4 p-4 shadow border border-gray-200 rounded-md">
      <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New Password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm New Password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
          />
          <:actions>
            <.button>Change Password</.button>
          </:actions>
        </.simple_form>
    </div>

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
            phx-click={JS.push("delete_profile", value: %{id: profile.id}) |> hide("##{id}")}
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
  
  # User email confirmation
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
    password_changeset = Accounts.change_user_password(user)
    {:ok, profiles} = Profiles.list_users_profiles(user)

    socket =
      socket
      |> stream(:profiles, profiles)
      |> assign(:current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:confirm_identity_modal, false)
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

  def handle_event("toggleConfirmIdenty", _params, socket), do: {:noreply, assign(socket, :confirm_identity_modal, true)}

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  # Profile related stuff
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
  def handle_event("delete_profile", %{"id" => id}, socket) do
    {:ok, profile} = Profiles.get_profile(socket.assigns.current_user, id)

    case Profiles.delete_profile(socket.assigns.current_user, profile) do
      {:ok, _} -> {:noreply, stream_delete(socket, :profiles, profile)}
      {:error, :unauthorized} -> {:noreply, put_flash(socket, :error, "You can't delete this profile")}
    end
  end
end
