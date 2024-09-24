import type { PageLoad } from './$types';
import { getCurrentUser, fetchUserAttributes, fetchAuthSession } from '@aws-amplify/auth';
import "$lib/Cognito";
import { redirect } from '@sveltejs/kit';
import { loadTranslations } from "$lib/stores/store";


export const load = (async ({ url }) => {

    let lang = url.searchParams.get('language') ?? "de";
    loadTranslations(lang)

    try {
        const session = await getCurrentUser();
        const userAttributes = await fetchUserAttributes();

        session.userId = userAttributes["custom:userId"] ?? ""

        const sessionToken = await fetchAuthSession();

        //const tests = 
        return { session, sessionToken, lang };
    } catch (error) {
        throw redirect(307, "/")
    }

}) satisfies PageLoad;