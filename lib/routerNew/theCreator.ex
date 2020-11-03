defmodule Server.TheCreator do
  @doc false
  defmacro my_get() do
    quote do
    end
  end

  defmacro my_error(code, content) do
    quote do
    end
  end

  defmacro __using__(opts) do
    quote do
      import Server.TheCreator
      Server.RouterNew

      # initialize the container of functions to call for each path, or the behaviour in case of error

      # Invoke TestCase.__before_compile__/1 before the module is compiled
      @before_compile Server.TheCreator
    end
  end

  defmacro __before_compile__(opts) do
    quote do
      def init(opts) do
        opts
      end

      def call(conn, opts) do
        IO.inspect(conn)
      end
    end
  end
end
