defmodule Roundtable.Exchange.Stocks do
  @moduledoc """
    Stock module retrieves list of stocks from S&P500
  """
  alias NimbleCSV.RFC4180, as: CSV
  require Logger

  defstruct [
    :symbol,
    :price,
    :volume,
    :change,
    :change_percent
  ]

  @api_key "Z8L6LGYIU0JK5GVN"
  @base_url "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol={SYMBOL}&apikey=#{@api_key}"

  @doc """
    Reads into memory the stock data from sp500_companies.csv
  """
  def open_stocks() do
    stocks_csv()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn col ->
      %{
        symbol: :binary.copy(Enum.at(col, 1)),
        name: :binary.copy(Enum.at(col, 2)),
        sector: :binary.copy(Enum.at(col, 4)),
        market_cap: :binary.copy(Enum.at(col, 7))
      }
    end)
    |> Enum.to_list()
  end

  @spec stocks_csv :: binary
  defp stocks_csv() do
    Application.app_dir(:roundtable, "/priv/static/assets/data/sp500_companies.csv")
  end

  def get_quote(symbol) when is_binary(symbol) do
    price_of(symbol)
  end

  defp price_of(stock) do
    uri = String.replace(@base_url, "{SYMBOL}", stock)

    case HTTPoison.get(uri) do
      {:ok, %{status_code: 200, body: body}} -> handle_response(body)
      # 404 Not Found Error
      {:ok, %{status_code: 404}} -> "Not found"
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect(reason)
    end
  end

  defp handle_response(body) do
    tmp = Jason.decode!(body)
    build_struct(tmp["Global Quote"])

    #  |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp build_struct(attrs) do
    formatted_attrs = %{
      symbol: attrs["01. symbol"],
      price: attrs["05. price"],
      volume: attrs["06. volume"],
      change: attrs["09. change"],
      change_percent: attrs["10. change percent"]
    }

    struct(__MODULE__, formatted_attrs)
  end
end
