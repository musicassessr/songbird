import type { PageLoad } from './$types';
import { getCurrentUser, fetchUserAttributes } from '@aws-amplify/auth';
import "$lib/Cognito";
import { goto } from '$app/navigation';
import { loadTranslations } from "$lib/stores/store";

export const load = (async ({url}) => {


    let lang = url.searchParams.get('language') ?? "de";
    loadTranslations(lang)
    try {
        const session = await getCurrentUser();
        const userAttributes = await fetchUserAttributes();
        
        session.userId = userAttributes["custom:userId"] ?? ""
        //const tests = 
        goto("/dashboard")
    } catch (error) {
    }

}) satisfies PageLoad;