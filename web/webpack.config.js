var path = require('path');
var ExtractTextPlugin = require("extract-text-webpack-plugin")
var webpack = require('webpack');

var client_config = {
  devtool: 'source-map',
  //>>> entry: './app.js',
  entry: "reaxt/client_entry_addition",
  //>>> output: { filename: 'bundle.js' , path: path.join(__dirname, '../priv/static' ) }, 
  output: {
    filename: 'client.[hash].js',
    path: path.join(__dirname, '../priv/static'),
    publicPath: '/public/'
  },
  plugins: [
    new ExtractTextPlugin({ filename: "styles.css" }), new webpack.IgnorePlugin(/vertx/)
  ],
  module: {
    rules: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader',
        options: {
          name: '[name].[ext]',
        },
      },
      {
        test: /.js?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: ['es2015', 'react',
            [
              'jsxz',
              {
                dir: 'tuto.webflow',
              }
            ]
          ],
          plugins: ["transform-object-rest-spread",]
        }
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({ use: "css-loader" })
      }
    ],
  },
}

var server_config = Object.assign(Object.assign({}, client_config), {
  target: "node",
  entry: "reaxt/react_server",
  output: {
    path: path.join(__dirname, '../priv/react_servers'), //typical output on the default directory served by Plug.Static
    filename: 'server.js' //dynamic name for long term caching, or code splitting, use WebPack.file_of(:main) to get it
  },
})

module.exports = [client_config, server_config]