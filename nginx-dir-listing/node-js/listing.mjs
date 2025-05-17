import url from "url";
import path from "path";
import fs from "fs/promises";

const startTimeUnixMs = +new Date();

const queryString = process.argv[2];

const parsedQuery = url.parse(`?${queryString}`, true).query;

const pathValue = parsedQuery?.path || "";
const depthValue = parseInt(parsedQuery?.depth || "0", 10) || 0;

const rootPath = "/usr/share/nginx/html";
const fullPath = path.join(rootPath, pathValue);
const result = {
  params: {
    path: pathValue,
    depth: depthValue,
  },
  fullPath: fullPath,
  timestamp: new Date().toISOString(),
  runtime_ms: +new Date() - startTimeUnixMs,
  files: {},
  files_stats: {
    _total_files: 0,
    _total_dirs: 0,
    files_by_extension: {},
  },
};
const files_stats_tmp = {};

async function getDirContents(dirPath, current_depth) {
  // console.log("getDirContents:", dirPath);

  // list the files in the directory
  const dirContents = await fs.readdir(dirPath, {
    withFileTypes: true,
  });
  const files_tmp = [];

  await Promise.all(
    dirContents.map(async (dirContent) => {
      const fileName = dirContent.name;
      const filePath = path.join(dirPath, fileName);
      const isDirectory = dirContent.isDirectory();
      const fileStat = await fs.stat(filePath);

      let dirFiles = undefined;
      let errObj = undefined;
      if (isDirectory) {
        if (fileName === ".git") {
          return; // skip .git directory
        }
        result.files_stats["_total_dirs"]++;
        if (depthValue && current_depth < depthValue) {
          try {
            dirFiles = await getDirContents(filePath, current_depth + 1);
          } catch (err) {
            const errMsg = err?.message || err?.toString() || String(err);
            errObj = {
              message: errMsg,
              filePath,
              code: err?.code || "UNKNOWN",
              stack: err?.stack,
            };
          }
        }
      } else {
        result.files_stats["_total_files"]++;
        // get file extension
        const ext = path.extname(fileName);
        if (ext) {
          if (!files_stats_tmp[ext]) {
            files_stats_tmp[ext] = {
              ext,
              count: 0,
              size: 0,
            };
          }
          files_stats_tmp[ext].count++;
          files_stats_tmp[ext].size += fileStat.size;
        }
      }

      files_tmp.push({
        name: fileName,
        isDirectory: isDirectory,
        size: isDirectory ? null : fileStat?.size,
        createdAt: isDirectory ? null : fileStat?.birthtime?.toISOString(),
        modified: isDirectory ? null : fileStat?.mtime?.toISOString(),
        accessed: isDirectory ? null : fileStat?.atime?.toISOString(),
        _error: errObj,
        // _fullPath: filePath,
        _relativePath: path.relative(rootPath, filePath),
        _depth: depthValue > 0 ? current_depth : undefined,
        files: dirFiles,
      });
    })
  );

  // sort the files by name
  const filesSorted = {};
  files_tmp
    .sort((a, b) => {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.localeCompare(b.name);
    })
    .forEach((obj) => {
      const fileName = obj.name;
      delete obj.name;

      filesSorted[fileName] = {
        ...obj,
      };
    });

  return filesSorted;
}

result.files = await getDirContents(fullPath, 0);

result.files_stats.files_by_extension = Object.values(files_stats_tmp).sort(
  (a, b) => {
    // order by size descending
    if (a.size > b.size) return -1;
    if (a.size < b.size) return 1;
    // order by count descending
    if (a.count > b.count) return -1;
    if (a.count < b.count) return 1;
    return 0;
  }
);

result.runtime_ms = +new Date() - startTimeUnixMs;

console.log(JSON.stringify(result, null, 2)); // Output to stdout
