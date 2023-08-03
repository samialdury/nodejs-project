import { initConfig } from './config.js'
import { initLogger, logger } from './logger.js'

function main(): void {
    initConfig()
    initLogger()

    logger.info('Hello from main()')
}

main()
