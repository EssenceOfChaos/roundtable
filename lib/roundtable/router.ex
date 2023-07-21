defmodule Roundtable.Router do
  alias Roundtable.JSONUtils, as: JSON
  require Logger
  # Bring Plug.Router module into scope
  use Plug.Router

  # Attach the Logger to log incoming requests
  plug(Plug.Logger)

  # Tell Plug to match the incoming request with the defined endpoints
  plug(:match)

  # Once there is a match, parse the response body if the content-type
  # is application/json. The order is important here, as we only want to
  # parse the body if there is a matching route.(Using the Jayson parser)
  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  # Dispatch the connection to the matched handler
  plug(:dispatch)

  # Handler for GET request with "/" path
  get "/" do
    send_resp(conn, 200, "OK")
  end

  # Health Check
  get "/health" do
    case Mongo.command(:mongo, ping: 1) do
      {:ok, _res} -> send_resp(conn, 200, "Success")
      {:error, _err} -> send_resp(conn, 500, "Something went wrong")
    end
  end

  # Get all posts
  get "/posts" do
    # Find all the posts in the database
    posts =
      Mongo.find(:mongo, "posts", %{})
      # For each of the post normalise the id
      |> Enum.map(&JSON.normalize_mongo_id/1)
      # Convert the records to a list
      |> Enum.to_list()
      # Encode the list to a JSON string
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    # Send a 200 OK response with the posts in the body
    |> send_resp(200, posts)
  end

  # Create new post
  post "/post" do
    case conn.body_params do
      %{
        "user" => user,
        "title" => title,
        "description" => description,
        "body" => body,
        "tags" => tags,
        "upvoted" => upvoted,
        "downvoted" => downvoted,
        "imagePreview" => imagePreview,
        "image" => image
      } ->
        case Mongo.insert_one(:mongo, "posts", %{
               "user" => user,
               "title" => title,
               "description" => description,
               "body" => body,
               "tags" => tags,
               "upvoted" => upvoted,
               "downvoted" => downvoted,
               "imagePreview" => imagePreview,
               "image" => image
             }) do
          {:ok, user} ->
            doc = Mongo.find_one(:mongo, "posts", %{_id: user.inserted_id})

            post =
              JSON.normalize_mongo_id(doc)
              |> Jason.encode!()

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, post)

          {:error, _} ->
            send_resp(conn, 500, "Something went wrong")
        end

      _ ->
        send_resp(conn, 400, '')
    end
  end

  # Get a specific post by ID
  get "/post/:id" do
    doc = Mongo.find_one(:mongo, "posts", %{_id: BSON.ObjectId.decode!(id)})

    case doc do
      nil ->
        send_resp(conn, 404, "Not Found")

      %{} ->
        post =
          JSON.normalize_mongo_id(doc)
          |> Jason.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, post)

      {:error, _} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  # Update a post by ID
  put "post/:id" do
    case Mongo.find_one_and_update(
           :mongo,
           "posts",
           %{_id: BSON.ObjectId.decode!(id)},
           %{
             "$set":
               conn.body_params
               |> Map.take([
                 "user",
                 "title",
                 "description",
                 "body",
                 "tags",
                 "upvoted",
                 "downvoted",
                 "imagePreview",
                 "image"
               ])
               |> Enum.into(%{}, fn {key, value} -> {"#{key}", value} end)
           },
           return_document: :after
         ) do
      {:ok, doc} ->
        case doc do
          nil ->
            send_resp(conn, 404, "Not Found")

          _ ->
            post =
              JSON.normalize_mongo_id(doc)
              |> Jason.encode!()

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, post)
        end

      {:error, _} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  # Delete a post by ID
  delete "post/:id" do
    Mongo.delete_one!(:mongo, "posts", %{_id: BSON.ObjectId.decode!(id)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{id: id}))
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
