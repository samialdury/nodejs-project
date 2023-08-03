import { createConfig, type EnveySchema, type InferEnveyConfig } from 'envey'
import { z } from 'zod'

const schema = {
    nodeEnv: {
        env: 'NODE_ENV',
        format: z.enum(['production', 'test', 'development']),
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
    commitSha: {
        env: 'COMMIT_SHA',
        format: z.string(),
    },
    projectName: {
        env: 'PROJECT_NAME',
        format: z.string(),
    },
} satisfies EnveySchema

export let config: InferEnveyConfig<typeof schema>

export function initConfig(): void {
    config = createConfig(z, schema, { validate: true })
}
