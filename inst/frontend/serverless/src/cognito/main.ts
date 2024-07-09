import * as postConfirmation from './postConfirmation'

import * as preSiginup from './preSiginup'

export const handler = async (event) => {
    const { triggerSource } = event
    let targetHandler = null
    if (triggerSource.startsWith('PreSignUp_')) {
        targetHandler = preSiginup.handler

    } else if (triggerSource.startsWith('PostConfirmation_')) {
        targetHandler = postConfirmation.handler
    }
    if (!targetHandler) {
        throw new Error(`could not resolve handler for triggerSource = ${triggerSource}`)
    }

    return await targetHandler(event)
};