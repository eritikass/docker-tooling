import url from "url";
import path from "path";
import fs from "fs/promises";

const startTimeUnixMs = +new Date();

const queryString = process.argv[2];

const parsedQuery = url.parse(`?${queryString}`, true).query;
const pathValue = parsedQuery?.path || "";
const fullPath = path.join("/usr/share/nginx/html", pathValue);
const result = {
  path: pathValue,
  fullPath: fullPath,
  timestamp: new Date().toISOString(),
  runtime_ms: +new Date() - startTimeUnixMs,
  files: {},
};

// list the files in the directory
const dirContents = await fs.readdir(fullPath, {
  withFileTypes: true,
});
const files_tmp = [];
await Promise.all(
  dirContents.map(async (dirContent) => {
    const fileName = dirContent.name;
    const filePath = path.join(fullPath, fileName);
    const isDirectory = dirContent.isDirectory();
    const fileStat = await fs.stat(filePath);
    files_tmp.push({
      name: fileName,
      isDirectory: isDirectory,
      size: isDirectory ? null : fileStat.size,
      createdAt: isDirectory ? null : fileStat.birthtime.toISOString(),
      modified: isDirectory ? null : fileStat.mtime.toISOString(),
      accessed: isDirectory ? null : fileStat.atime.toISOString(),
    });
  })
);

// sort the files by name
files_tmp
  .sort((a, b) => {
    if (a.isDirectory && !b.isDirectory) return -1;
    if (!a.isDirectory && b.isDirectory) return 1;
    return a.name.localeCompare(b.name);
  })
  .forEach((obj) => {
    const fileName = obj.name;
    delete obj.name;

    result.files[fileName] = {
      ...obj,
    };
  });

result.runtime_ms = +new Date() - startTimeUnixMs;

console.log(JSON.stringify(result, null, 2)); // Output to stdout
