import { pino } from 'pino'

import { config } from './config.js'

export let logger: pino.Logger

export function initLogger(): void {
    const { projectName, logLevel } = config

    logger = pino({
        name: projectName,
        level: logLevel,
    })

    logger.debug('Logger initialized')
}
