import { initConfig, config } from './config.js'
import { initLogger, logger } from './logger.js'

function main(): void {
    initConfig()
    initLogger(config)

    logger.info('Hello from main()')
}

main()
