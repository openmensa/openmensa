import { defineConfig } from "vite";
import { ViteImageOptimizer } from "vite-plugin-image-optimizer";
import Rails from "vite-plugin-rails";

export default defineConfig({
  plugins: [
    Rails({
      envVars: { RAILS_ENV: "development" },
    }),
    ViteImageOptimizer(),
  ],
});
