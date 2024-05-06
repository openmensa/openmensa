import zopfli from "@gfx/zopfli";
import { rspack } from "@rspack/core";
import CompressionPlugin from "compression-webpack-plugin";
import * as path from "node:path";
import zlib from "node:zlib";
import { RspackManifestPlugin } from "rspack-manifest-plugin";

export default async (env, argv) => {
  const production =
    argv.mode === "production" ||
    process.env.NODE_ENV === "production" ||
    process.env.RAILS_ENV === "production";

  const config = {
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
      assetModuleFilename: "static/[name].[contenthash][ext]",
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
      // Inject jQuery into jquery.autocomplete (and application.mjs)
      new rspack.ProvidePlugin({
        $: "jquery",
        jQuery: "jquery",
      }),
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

  if (production) {
    config.plugins.push(
      new CompressionPlugin({
        filename: "[path][base].gz",
        compressionOptions: {
          numiterations: 15,
        },
        algorithm(input, compressionOptions, callback) {
          return zopfli.gzip(input, compressionOptions, callback);
        },
        threshold: 10240,
        minRatio: 0.8,
      }),
    );
    config.plugins.push(
      new CompressionPlugin({
        filename: "[path][base].br",
        algorithm: "brotliCompress",
        test: /\.(js|css|html|svg)$/,
        compressionOptions: {
          params: {
            [zlib.constants.BROTLI_PARAM_QUALITY]: 11,
          },
        },
        threshold: 10240,
        minRatio: 0.8,
      }),
    );
  }

  return config;
};
