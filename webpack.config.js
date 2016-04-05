var ExtractTextPlugin = require("extract-text-webpack-plugin");
var webpack = require('webpack');

module.exports = {
  entry: {
    "main.js": "./web/static/js/main.js",
    "style.css": "./web/static/less/app.less"
  },
  output: {
    path: "./priv/static/js",
    filename: "[name]",
    chunkFilename: "[id].js"
  },
  module: {
    loaders: [
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("style-loader", "css-loader")
      },
      {
        test: /\.(jsx|js)$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel', // 'babel-loader' is also a legal name to reference
        query: {
          presets: ['react', 'es2015']
        }
      }, 
      {
        test: /\.less$/,
        loader: ExtractTextPlugin.extract("style-loader", "css-loader!less-loader")
      },
      { test: /\.(png|woff|woff2|eot|ttf|svg)$/, loader: 'url-loader?limit=100000' }
    ]
  },
    // Use the plugin to specify the resulting filename (and add needed behavior to the compiler)
  plugins: [
        new ExtractTextPlugin("../css/[name]")
  ]
};