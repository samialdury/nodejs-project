export class BaseError extends Error {
    public isOperational: boolean

    constructor(message: string, isOperational: boolean) {
        super(message)
        this.name = this.constructor.name
        this.isOperational = isOperational
    }
}
