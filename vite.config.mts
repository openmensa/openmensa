import { codecovVitePlugin } from "@codecov/vite-plugin";
import { defineConfig } from "vite";
import FullReload from "vite-plugin-full-reload";
import { ViteImageOptimizer } from "vite-plugin-image-optimizer";
import Ruby from "vite-plugin-ruby";

export default defineConfig({
  plugins: [
    //
    Ruby(),
    FullReload(["app/**/*"]),
    ViteImageOptimizer(),
    codecovVitePlugin({
      enableBundleAnalysis: process.env.GITHUB_ACTIONS !== undefined,
      bundleName: "openmensa",
      oidc: {
        useGitHubOIDC: true,
      },
    }),
  ],
});
