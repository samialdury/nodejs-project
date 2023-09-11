import { type EnveySchema, type InferEnveyConfig, createConfig } from 'envey'
import { z } from 'zod'

const schema = {
    commitSha: {
        env: 'COMMIT_SHA',
        format: z.string(),
    },
    logLevel: {
        env: 'LOG_LEVEL',
        format: z.enum([
            'fatal',
            'error',
            'warn',
            'info',
            'debug',
            'trace',
            'silent',
        ]),
    },
    projectName: {
        env: 'PROJECT_NAME',
        format: z.string(),
    },
} satisfies EnveySchema

export type Config = InferEnveyConfig<typeof schema>

export function initConfig(): Config {
    const result = createConfig(z, schema, { validate: true })

    if (!result.success) {
        // eslint-disable-next-line no-console
        console.error(result.error.issues)
        throw new Error('Invalid config')
    }

    return result.config
}
