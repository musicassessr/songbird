<script lang="ts">
    import songbird_icon from "$lib/assets/songbird_icon.png";
    import { page } from "$app/stores";
    import { signIn, signUp } from "@aws-amplify/auth";
    import { goto } from "$app/navigation";
    import "$lib/Cognito";
    import toast, { Toaster } from "svelte-french-toast";
    let form: any;
    import { translations } from "$lib/stores/store";

    const groupId = "5";

    import Modal from "$lib/components/Modal.svelte";
    let showModal = false;
    let signUpData = {};

    const validateEmail = (email) => {
        // Regular expression to validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    };

    const handleSubmit = async (event: any) => {
        const data = new FormData(event.target);

        let username = data.get("email");
        let password = data.get("password");
        try {
            toast.loading("", {
                duration: 1000,
            });

            const { isSignedIn, nextStep } = await signIn({
                username,
                password,
            });
            localStorage.setItem("isSelectItems", true);
            goto("/dashboard");
        } catch (error) {
            if (error instanceof Error) {
                if (error?.message.includes("The quota has been exceeded")) {
                    window.localStorage.clear();
                    return;
                }
                toast.error(error.message);
            } else {
                console.log("Unknown error during sign in:", error);
            }
        }
    };

    const handleSignUpButtonClick = (event: any) => {
        event.preventDefault();
        const data = new FormData(event.target);
        signUpData = {
            username: data.get("username"),
            password: data.get("password"),
            email: data.get("email"),
            confirmPassword: data.get("confirm_password"),
        };
        showModal = true;
    };

    const handleSignUp = async () => {
        let { username, password, email, confirmPassword } = signUpData;
        let passwordsMatch = password === confirmPassword;

        if (!passwordsMatch) {
            toast.error("Passwords do not match");
            return;
        }

        if (email !== "") {
            if (!validateEmail(email)) {
                toast.error("Please enter a valid email address");
                return;
            }
        }

        try {
            const { isSignUpComplete, userId, nextStep } = await signUp({
                username,
                password,
                options: {
                    userAttributes: {
                        email,
                        "custom:groupId": groupId,
                    },
                },
            });
            form.reset();
            toast.success("Registered!");
            showModal = false;
        } catch (error) {
            if (error instanceof Error) {
                if (error?.message.includes("The quota has been exceeded")) {
                    window.localStorage.clear();
                    return;
                }
                if (error?.message.includes("already exists")) {
                    toast.error("User already exists");
                    form.reset();
                    return;
                }
                if (error?.message.includes("Invalid username format.")) {
                    toast.error("Invalid username format.");
                    form.reset();
                    return;
                }
                toast.error(error.message);
            } else {
                console.log("Unknown error during sign up:", error);
            }
        }
    };
</script>

<Toaster />
<Modal bind:showModal on:confirm={handleSignUp} />

{#if !$page.data.session}
    <div class="wrapper">
        <div
            id="dynamic_ui"
            class="shiny-html-output shiny-bound-output"
            aria-live="polite"
        >
            <div id="prelogin">
                <p class="logged_out_message2" style="margin-right: 20px;">
                    {@html $translations["welcome2"]}
                </p>
            </div>
            <br />
            <form
                id="sign-sign_in_section"
                method="POST"
                on:submit|preventDefault={handleSubmit}
            >
                <div class="content-title">
                    {$translations["sign_in"]}
                </div>
                <div class="form-group shiny-input-container">
                    <label
                        class="control-label shiny-label-null"
                        for="sign-sign_in_user"
                        id="sign-sign_in_user-label"
                    ></label>
                    <input
                        id="sign-sign_in_user"
                        type="text"
                        name="email"
                        class="shiny-input-text form-control shiny-bound-input"
                        value=""
                        placeholder={$translations["username"]}
                    />
                </div>
                <div class="form-group shiny-input-container">
                    <label
                        class="control-label shiny-label-null"
                        for="sign-sign_in_password"
                        id="sign-sign_in_password-label"
                    ></label>
                    <input
                        id="sign-sign_in_password"
                        name="password"
                        type="password"
                        class="shiny-input-password form-control shiny-bound-input"
                        value=""
                        placeholder={$translations["password"]}
                    />
                </div>
                <button
                    class="btn btn-default action-button shiny-bound-input"
                    id="sign-sign_in_button"
                    type="button submit">{$translations["sign_in"]}</button
                >
            </form>
            <div class="vr-separator">
                <div class="vr-line"></div>
                <!-- svelte-ignore a11y-missing-attribute -->
                <img src={songbird_icon} />
                <div class="vr-line"></div>
            </div>
            <form
                id="sign_up_section"
                method="POST"
                bind:this={form}
                on:submit|preventDefault={handleSignUpButtonClick}
            >
                <div class="content-title-alt">{$translations["sign_up"]}</div>
                <div class="form-group shiny-input-container">
                    <label
                        class="control-label shiny-label-null"
                        for="sign-sign_up_user"
                        id="sign-sign_up_user-label"
                    ></label>
                    <input
                        id="sign-sign_up_user"
                        type="text"
                        class="shiny-input-text form-control shiny-bound-input"
                        name="username"
                        value=""
                        placeholder={$translations["username_sign_up"]}
                    />
                </div>
                <div class="form-group shiny-input-container">
                    <label
                        class="control-label shiny-label-null"
                        for="sign-sign_in_email"
                        id="sign-sign_in_email-label"
                    ></label>
                    <input
                        id="sign-sign_in_email"
                        name="email"
                        type="text"
                        class="shiny-input-email form-control shiny-bound-input"
                        value=""
                        placeholder={$translations["email_sign_up"]}
                    />
                </div>
                <div class="form-group shiny-input-container">
                    <label
                        class="control-label shiny-label-null"
                        for="sign-sign_up_password"
                        id="sign-sign_up_password-label"
                    ></label>
                    <input
                        id="sign-sign_up_password"
                        type="password"
                        name="password"
                        class="shiny-input-password form-control shiny-bound-input"
                        value=""
                        placeholder={$translations["password_sign_up"]}
                    />
                </div>
                <div class="form-group shiny-input-container">
                    <label
                        class="control-label shiny-label-null"
                        for="sign-sign_up_verify_password"
                        id="sign-sign_up_verify_password-label"
                    ></label>
                    <input
                        id="sign-sign_up_verify_password"
                        type="password"
                        name="confirm_password"
                        class="shiny-input-password form-control shiny-bound-input"
                        value=""
                        placeholder={$translations["verify_password_sign_up"]}
                    />
                </div>
                <button
                    class="btn btn-default action-button btn_alt shiny-bound-input"
                    id="sign-sign_up_button"
                    type="button submit">{$translations["sign_up"]}</button
                >
            </form>
        </div>
    </div>
{/if}
