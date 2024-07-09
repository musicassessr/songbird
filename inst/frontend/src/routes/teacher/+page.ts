import type { PageLoad } from './$types';
import { getCurrentUser, fetchUserAttributes, fetchAuthSession } from '@aws-amplify/auth';
import "$lib/Cognito";
import { error, redirect } from '@sveltejs/kit';
import toast, { Toaster } from "svelte-french-toast";
import { invalidate, invalidateAll } from '$app/navigation';


export const load = (async () => {

    try {
        const session = await getCurrentUser();
        const userAttributes = await fetchUserAttributes();
        const userSession = await fetchAuthSession();

        session.userId = userAttributes["custom:userId"] ?? ""
        //const tests = 
        if (userSession.tokens.accessToken.payload["cognito:groups"]?.includes("admin")) {
            session.isAdmin = true
        } else {
            throw new Error("UserNotAuthorized")

        }

        return { session };
    } catch (err) {
        if (err.message == "UserNotAuthorized") {
            window.localStorage.clear();
            toast.error("Not Authorized")
        }

    }

}) satisfies PageLoad;