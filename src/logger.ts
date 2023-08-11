import { pino } from 'pino'

import type { Config } from './config.js'

export let logger: pino.Logger

export function initLogger(config: Config): void {
    logger = pino({
        name: config.projectName,
        level: config.logLevel,
    })

    logger.debug('Logger initialized')
}
