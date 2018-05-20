defmodule SiteEncrypt.Certifier do
  use Parent.GenServer
  alias SiteEncrypt.{Certbot, Logger}

  def start_link({callback_mod, config}),
    do:
      Parent.GenServer.start_link(
        __MODULE__,
        {callback_mod, config},
        name: name(config.domain)
      )

  defp name(domain), do: SiteEncrypt.Registry.via_tuple({__MODULE__, domain})

  @impl GenServer
  def init({callback_mod, config}) do
    Certbot.init(config)
    if config.run_client? == true, do: start_fetch(callback_mod, config)
    {:ok, %{callback_mod: callback_mod, config: config}}
  end

  @impl GenServer
  def handle_info(:start_fetch, state) do
    start_fetch(state.callback_mod, state.config)
    {:noreply, state}
  end

  def handle_info(other, state), do: super(other, state)

  @impl Parent.GenServer
  def handle_child_terminated(:fetcher, _pid, _reason, state) do
    log(state.config, "certbot finished")
    Process.send_after(self(), :start_fetch, state.config.renew_interval())
    {:noreply, state}
  end

  defp start_fetch(callback_mod, config) do
    unless Parent.GenServer.child?(:fetcher) do
      log(config, "starting certbot")

      Parent.GenServer.start_child(%{
        id: :fetcher,
        start: {Task, :start_link, [fn -> get_certs(callback_mod, config) end]}
      })
    end
  end

  defp get_certs(callback_mod, config) do
    case Certbot.ensure_cert(config) do
      {:error, output} ->
        Logger.log(:error, "error obtaining certificate:\n#{output}")

      {:new_cert, output} ->
        log(config, output)
        log(config, "obtained new certificate, restarting endpoint")

        callback_mod.handle_new_cert(config)

      {:no_change, output} ->
        log(config, output)
        :ok
    end
  end

  defp log(config, output), do: Logger.log(config.log_level, output)
end
