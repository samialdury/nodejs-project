import { type EnveySchema, type InferEnveyConfig, createConfig } from 'envey'
import { z } from 'zod'
import { BaseError } from './base-error.js'

const schema = {
    commitSha: {
        env: 'COMMIT_SHA',
        format: z.string().default('unknown'),
    },
    logLevel: {
        env: 'LOG_LEVEL',
        format: z
            .enum([
                'fatal',
                'error',
                'warn',
                'info',
                'debug',
                'trace',
                'silent',
            ])
            .default('info'),
    },
    projectName: {
        env: 'PROJECT_NAME',
        format: z.string().default('nodejs-project'),
    },
    env: {
        env: 'ENV',
        format: z.enum(['prod', 'dev', 'test']).default('prod'),
    },
} satisfies EnveySchema

export type Config = InferEnveyConfig<typeof schema>

class ConfigError extends BaseError {
    constructor(message: string) {
        super(message, false)
    }
}

export function initConfig(): Config {
    const result = createConfig(z, schema, { validate: true })

    if (!result.success) {
        // eslint-disable-next-line no-console
        console.error(result.error.issues)
        throw new ConfigError('Invalid configuration')
    }

    return result.config
}
