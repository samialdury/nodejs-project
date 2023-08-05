const { semanticRelease } = require('@samialdury/config')

module.exports = semanticRelease.config({
    message: 'chore(release): v${nextRelease.version}',
})
