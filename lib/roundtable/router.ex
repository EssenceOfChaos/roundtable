defmodule Roundtable.Router do
  @moduledoc """
  Roundtable.Router routes incoming requests to the appropriate handler
  """
  require Logger
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  # Handler for GET request with "/" path
  get "/" do
    Roundtable.Controller.index(conn, [])
  end

  # Health Check
  get "/health" do
    Roundtable.Controller.health_check(conn, [])
  end

  # Get all posts
  get "/posts" do
    Roundtable.Controller.get_posts(conn, [])
  end

  # Create new post
  post "/post" do
    Roundtable.Controller.create_post(conn, [])
  end

  # Get a specific post by ID
  get "/post/:id" do
    Roundtable.Controller.get_post(conn, id)
  end

  # Update a post by ID
  put "post/:id" do
    Roundtable.Controller.update_post(conn, id)
  end

  # Delete a post by ID
  delete "post/:id" do
    Roundtable.Controller.delete_post(conn, id)
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
