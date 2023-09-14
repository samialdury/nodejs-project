<div align="center">

# Node.js project template

[![CI status](https://github.com/samialdury/nodejs-project/actions/workflows/ci.yaml/badge.svg)](https://github.com/samialdury/nodejs-project/actions/workflows/ci.yml)
![license](https://img.shields.io/github/license/samialdury/nodejs-project)

</div>

Node.js project template designed to get you up and running quickly, whether you're building a CLI tool or a web server.

## Usage

This template is included in the [@samialdury/create](https://github.com/samialdury/create) CLI tool and it's the recommended way to use it.

```sh
bunx @samialdury/create nodejs-project
```

You can also create a new GitHub repository from this template directly by clicking [here](https://github.com/new?template_name=nodejs-project&template_owner=samialdury), and then running the following command in the root directory of the repository, replacing `your-project-name` with the name of your project.

```sh
# You should have pnpm installed globally
# prior to running these commands

make install
make prepare name=your-project-name
```

## Stack

- Node.js
- TypeScript
- ESLint
- Prettier
- Docker
- GitHub Actions & GitHub Container Registry

## License

[MIT](LICENSE)
