defmodule Roundtable.Controller do
  import Plug.Conn
  alias Roundtable.JSONUtils, as: JSON

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Roundtable Index Route")
  end

  def health_check(conn, _params) do
    case Mongo.command(:mongo, ping: 1) do
      {:ok, _res} -> send_resp(conn, 200, "Success")
      {:error, _err} -> send_resp(conn, 500, "Something went wrong")
    end
  end

  def get_posts(conn, _params) do
    posts =
      Mongo.find(:mongo, "posts", %{})
      |> Enum.map(&JSON.normalize_mongo_id/1)
      |> Enum.to_list()
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, posts)
  end

  def create_post(conn, _params) do
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

  def get_post(conn, id) do
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

  def update_post(conn, id) do
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

  def delete_post(conn, id) do
    Mongo.delete_one!(:mongo, "posts", %{_id: BSON.ObjectId.decode!(id)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{id: id}))
  end
end
