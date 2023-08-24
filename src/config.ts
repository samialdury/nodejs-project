import { createConfig, type EnveySchema, type InferEnveyConfig } from 'envey'
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

export let config: Config

export function initConfig(): void {
    config = createConfig(z, schema, { validate: true })
}
