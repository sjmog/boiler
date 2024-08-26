const fs = require("fs");
const path = require("path");

const uiDir = path.join(__dirname, "..", "app", "javascript", "components", "ui");
const indexPath = path.join(uiDir, "index.js");

// Read all files in the ui directory
const files = fs.readdirSync(uiDir);

// Filter for .js files and exclude index.js
const componentFiles = files.filter(
  (file) => (file.endsWith(".js") || file.endsWith(".jsx")) && file !== "index.js"
);

// Generate export statements
const exportStatements = componentFiles
  .map((file) => {
    const componentName = path.basename(file, ".js");
    return `export * from './${componentName}';`;
  })
  .join("\n");

// Write to index.js
fs.writeFileSync(indexPath, exportStatements);

console.log("Updated app/javascript/components/ui/index.js");
