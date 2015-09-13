defmodule Erlangelist.ArticleEvent do
  def manager_name, do: :article_event

  def start_link do
    res = GenEvent.start_link(name: manager_name)
    if match?({:ok, _}, res), do: install_handlers
    res
  end

  defp install_handlers do
    for event_handler <- Erlangelist.app_env!(:article_event_handlers) do
      GenEvent.add_mon_handler(manager_name, event_handler, nil)
    end
  end

  def visited(article, data) do
    GenEvent.notify(manager_name, {:article_visited, article, data})
  end

  def invalid_article do
    GenEvent.notify(manager_name, :invalid_article)
  end
end