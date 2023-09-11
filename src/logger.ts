import { pino } from 'pino'
import type { Config } from './config.js'

export type Logger = pino.Logger

export function initLogger(config: Config): Logger {
    const logger = pino({
        level: config.logLevel,
        name: config.projectName,
    })

    logger.debug('Logger initialized')

    return logger
}
