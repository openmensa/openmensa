import * as path from "node:path";
import { RspackManifestPlugin } from "rspack-manifest-plugin";

export default {
  entry: {
    application: [
      "./app/javascripts/application.mjs",
      "./app/javascripts/application.scss",
    ],
  },
  output: {
    path: path.resolve("public/assets/packed"),
    publicPath: "/assets/packed/",
    filename: "[name].[contenthash].js",
    assetModuleFilename: "[name]-[contenthash][ext]",
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|svg)$/,
        type: "asset",
      },
      {
        test: /\.(sass|scss)$/,
        use: ["sass-loader"],
        type: "css/auto",
      },
    ],
  },
  plugins: [
    // A manifest is required for the Rails application to generate
    // correct <script> and <link> tags.
    new RspackManifestPlugin({
      fileName: ".manifest.json",
      writeToFileEmit: true,
    }),
  ],
  devServer: {
    proxy: {
      "/": {
        target: "http://localhost:3000",
      },
    },
  },
};
