const path = require('path')

module.exports = {
  entryPoints: ["application.js"],
  bundle: true,
  sourcemap: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  loader: {
    '.js': 'jsx',
  },
  // Add this configuration for the alias
  alias: {
    '@': path.join(process.cwd(), "app/javascript")
  }
}