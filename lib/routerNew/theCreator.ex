# defmodule Server.TheCreator do
#   @doc false
#   defmacro my_get(path, do: functionContent) do
#     quote do
#       #if path create functionCOntent with path and corresponding code/content
#       if (path == "/") do
#         functionContent
#       end
#     end
#   end

#   defmacro my_error(code, content) do
#     quote do
#       #change default behaviour in error case

#     end
#   end

#   defmacro __using__(opts) do
#     quote do
#       import Server.TheCreator
#       import Plug.Conn
#       # initialize the container of functions to call for each path, or the behaviour in case of error
#       @error_code 404
#       @error_content "Custom error message"
#       @path %{}  #diffrents path who will be called when trigger my_get

#       @before_compile Server.TheCreator
#     end
#   end

#   defmacro __before_compile__(opts) do
#     quote do
#       def init(opts) do
#         opts
#       end

#       def call(conn, opts) do
#         #check in path if path as been created and if not send error
#         IO.inspect(conn)
#         send_resp(conn, 200, "Hello world")
#       end
#     end
#   end
# end
