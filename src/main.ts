import { initConfig } from './config.js'
import { initLogger } from './logger.js'

function main(): void {
    const config = initConfig()
    const logger = initLogger(config)

    logger.info('Hello from main()')
}

main()
