import { defineConfig } from "vite";
import FullReload from "vite-plugin-full-reload";
import { ViteImageOptimizer } from "vite-plugin-image-optimizer";
import SRI from "vite-plugin-manifest-sri";
import Ruby from "vite-plugin-ruby";

export default defineConfig({
  plugins: [
    //
    Ruby(),
    FullReload(["app/**/*"]),
    ViteImageOptimizer(),
    SRI(),
  ],
});
