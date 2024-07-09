import { writable } from 'svelte/store';
import enTranslations from '$lib/translations/en.json';
import deTranslations from '$lib/translations/de.json';



export const translations = writable({});

export const showModal = writable({});
showModal.set(false)
let currentLanguage = 'de';
export async function loadTranslations(lang) {
    if (lang === 'en') {
        translations.set(enTranslations);
    } else if (lang === 'de') {
        translations.set(deTranslations);
    }
}

export function switchLanguage(event) {
    currentLanguage = event.target.value;
    loadTranslations(currentLanguage);
}

// loadTranslations(currentLanguage);
