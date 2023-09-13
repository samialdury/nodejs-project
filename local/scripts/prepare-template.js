/**
 * This script is used to prepare the template for a new project.
 * It will replace all occurrences of the default project name with the target project name.
 * It will also reset the version to 0.0.0 and remove all unnecessary files.
 *
 * Usage: node prepare-template.js <project-name>
 *
 * Example: node prepare-template.js my-app
 *
 * * It is safe to delete this file after running it.
 */
import cp from 'child_process'
import fs from 'fs/promises'
import path from 'node:path'

function getDirname() {
    return path.dirname(new URL(import.meta.url).pathname)
}

function getScriptFileName() {
    return path.basename(new URL(import.meta.url).pathname)
}

function getRootDirectory(dirname) {
    return path.join(dirname, '..', '..')
}

async function removeFile(filePath) {
    return fs.rm(filePath)
}

async function fileExists(filePath) {
    try {
        await fs.access(filePath)
        return true
    } catch {
        return false
    }
}

async function removeFileIfExists(filePath) {
    if (await fileExists(filePath)) {
        return removeFile(filePath)
    }
}

async function replaceInFile(filePath, search, replacement) {
    const fileContent = await fs.readFile(filePath, 'utf-8')
    const newContent = fileContent.replace(
        search instanceof RegExp ? search : new RegExp(search, 'g'),
        replacement,
    )
    await fs.writeFile(filePath, newContent, 'utf-8')
}

async function* walkDirGen(dir, ignoredItems) {
    for (const f of await fs.readdir(dir)) {
        const dirPath = path.join(dir, f)
        const isDirectory = (await fs.stat(dirPath)).isDirectory()

        if (ignoredItems.has(dirPath) || ignoredItems.has(f)) {
            continue
        }

        if (isDirectory) {
            yield* walkDirGen(dirPath, ignoredItems)
        } else {
            yield dirPath
        }
    }
}

async function main() {
    const defaultProjectName = 'nodejs-project'
    const targetProjectName = process.argv[2]

    if (!targetProjectName) {
        console.error(
            'Please provide a project name.\n\nUsage: node prepare-template.js <project-name>',
        )
        process.exit(1)
    }

    if (targetProjectName === defaultProjectName) {
        return
    }

    const dirname = getDirname()
    const scriptFileName = getScriptFileName()
    const rootDirectory = getRootDirectory(dirname)

    await Promise.all([
        removeFileIfExists(path.join(rootDirectory, 'LICENSE')),
        removeFileIfExists(path.join(rootDirectory, 'CHANGELOG.md')),
        // Reset version to 0.0.0
        replaceInFile(
            path.join(rootDirectory, 'package.json'),
            /(?<="version": ")\d+\.\d+\.\d+(?=")/,
            '0.0.0',
        ),
        replaceInFile(
            path.join(rootDirectory, 'README.md'),
            /[^]*/,
            `# ${targetProjectName}\n
Created using [nodejs-project](https://github.com/samialdury/nodejs-project) template by [samialdury](https://github.com/samialdury).\n`,
        ),
    ])

    const ignoredItems = new Set([
        '.git',
        '.cache',
        'build',
        'node_modules',
        'pnpm-lock.yaml',
        'README.md',
        scriptFileName,
    ])

    const promises = []
    for await (const filePath of walkDirGen(rootDirectory, ignoredItems)) {
        promises.push(
            replaceInFile(filePath, defaultProjectName, targetProjectName),
        )
    }
    await Promise.all(promises)

    cp.execSync('make format lint', { cwd: rootDirectory })
}

await main()
