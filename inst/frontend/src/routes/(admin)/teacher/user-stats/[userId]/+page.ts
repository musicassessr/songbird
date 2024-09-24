import type { PageLoad } from './$types';
import { loadTranslations } from "$lib/stores/store";
export const load = (async ({url,params}) => {

    let userId = params.userId

    let lang = url.searchParams.get('language') ?? "de";
    loadTranslations(lang)

    return { userId};
}) satisfies PageLoad;