<script lang="ts">
    import "../../app.css";
    import { goto } from "$app/navigation";
    import { signOut, deleteUser } from "aws-amplify/auth";
    import toast, { Toaster } from "svelte-french-toast";
    import { onMount } from "svelte";
    import { updatePassword } from "aws-amplify/auth";
    import user from "$lib/assets/user.png";
    import progress from "$lib/assets/progress.png";
    import songs from "$lib/assets/songs.png";
    import bird from "$lib/assets/bird.png";
    import Progress from "@bonosoft/sveltekit-progress";
    import appConfig from "$lib/app-config.yaml";
    import Chart from "$lib/components/Chart.svelte";
    import { v4 as uuidv4 } from "uuid";
    import { translations } from "$lib/stores/store";

    const APP_URL = import.meta.env.VITE_APP_APP_URL ?? "";
    const API_BASE_URL = import.meta.env.VITE_APP_API_BASE_URL;
    let tests = [];
    let experiments = [];
    let form;
    let hasExperiments = true;
    let hasTests = true;
    let hasGroups = true;
    let removeAccount = false;
    let groups = [];
    let activeTab = Object.keys(appConfig["content"].tabsToShow[0])[0]; // Default active tab
    let yourItems: any[] = [];

    const getUserGroups = async () => {
        const { userId } = data.session;
        try {
            const url = `${API_BASE_URL}/v2/get-user-groups`;
            const payload = {
                user_id: parseInt(userId),
            };

            const response = await fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            const result = await response.json();
            return result;
        } catch (error) {}
    };

    const handleAddUserToGroup = async (event: any) => {
        const input = new FormData(event.target);
        let loginCode = input.get("login-code");
        const { userId } = data.session;
        try {
            const url = `${API_BASE_URL}/v2/add-user-to-group-with-login-code`;
            const payload = {
                user_id: parseInt(userId),
                login_code: loginCode,
            };
            const response = await fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            const result = await response.json();
            if (result?.message.includes("successfully")) {
                toast.success(result?.message);
                groups = await getUserGroups();
                hasGroups = groups?.length > 0 ? true : false;
                groups = groups.groups;
                form.reset();
            } else {
                toast.error(result?.message);
            }
        } catch (error) {
            if (error instanceof Error) {
                toast.error(error.message);
            }
        }
    };
    const handleUpdatePassword = async (event: any) => {
        const input = new FormData(event.target);
        let newPassword = input.get("new-password");
        let oldPassword = input.get("current-password");
        let confirmNewPassword = input.get("confirm-new-password");
        let passwordsMatch = true;
        passwordsMatch = newPassword === confirmNewPassword;

        if (!passwordsMatch) {
            toast.error("Passwords do not match");
            return;
        }

        try {
            await updatePassword({ oldPassword, newPassword });
            await logoutUser();

            setTimeout(() => {
                goto("/");
                toast.success("Password successfully changed.");
            }, 1000); // Adjust the delay as needed
        } catch (error) {
            if (error instanceof Error) {
                toast.error(error.message);
            }
        }
    };

    const getAvailableTestsandExperiments = async (userId) => {
        const url = `${API_BASE_URL}/v2/get-available-tests-and-experiments`;
        const payload = {
            user_id: parseInt(userId),
            app_name: "singpause",
        };

        try {
            const response = await fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            return result;
        } catch (error) {
            return;
        }
    };

    const selectItems = async (userId) => {
        const url = `${API_BASE_URL}/v2/select-items`;
        const job_id = uuidv4();

        const payload = {
            message: { job_id, userId },
        };

        try {
            const response = await fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return job_id;
        } catch (error) {}
    };

    const getSingItems = async (userId) => {
        const url = `${API_BASE_URL}/v2/get-singpause-items`;
        const payload = {
            user_id: parseInt(userId),
        };
        try {
            const response = await fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            return result["songs"];
        } catch (error) {
            return;
        }
    };

    const appendNewReviewItems = async (
        userId,
        item_id,
        item_bank_id,
        job_id,
    ) => {
        const url = `${API_BASE_URL}/v2/append-review-new-items`;
        const payload = {
            user_id: parseInt(userId),
            item_id: item_id,
            item_bank_id: item_bank_id,
            job_id: job_id,
        };
        try {
            const response = fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
        } catch (error) {
            return;
        }
    };

    onMount(async () => {
        const response = await getAvailableTestsandExperiments(
            data.session.userId,
        );

        groups = await getUserGroups();

        hasExperiments = response?.experiments.length > 0 ? true : false;
        hasTests = response?.tests.length > 0 ? true : false;
        hasGroups = groups?.length > 0 ? true : false;
        groups = groups.groups;
        tests = response.tests;
        experiments = response.experiments;
        yourItems = await getSingItems(data.session.userId);
    });

    const createSessionToken = async (
        prefix = "",
        event = "",
        extraParam = {},
        custom = "",
    ) => {
        const { userId, username } = data.session;
        let job_id;
        const url = `${API_BASE_URL}/create-session-token`;
        const payload = {
            user_id: userId,
            expiration_in_seconds: 600,
        };

        try {
            if (custom == "singpause") {
                toast.loading($translations['loading_msg']);

                job_id = await selectItems(userId);
            } else {
                job_id = uuidv4();

                appendNewReviewItems(
                    userId,
                    extraParam.item_ids,
                    extraParam.item_bank_id,
                    job_id,
                );
            }

            if (
                prefix.length > 0 &&
                JSON.stringify(extraParam) === "{}" &&
                custom == ""
            ) {
                location.href = `${APP_URL}/${prefix}/?session_token=${data.sessionToken["tokens"].idToken?.toString()}&get_review_items=true&get_new_items=true&language=${data.lang}`;
            } else if (JSON.stringify(extraParam) !== "{}") {
                event.target
                    .querySelector(".fa")
                    .classList.add("active-loader");

                location.href = `${APP_URL}/${prefix}/?session_token=${data.sessionToken["tokens"].idToken?.toString()}&job_id=${job_id}&language=${data.lang}`;
            } else if (custom == "singpause") {
                window.location.replace(
                    `${APP_URL}/${prefix}/?session_token=${data.sessionToken["tokens"].idToken?.toString()}&job_id=${job_id}&language=${data.lang}`,
                );
            } else {
                location.href = `${APP_URL}/user-profile?session_token=${data.sessionToken["tokens"].idToken?.toString()}&language=${data.lang}`;
            }
        } catch (error) {
            //event.target.querySelector(".fa").classList.remove("active-loader");
            console.log(error);
        }
    };

    const setActiveTab = (tabName: string) => {
        activeTab = tabName;
    };
    export async function logoutUser() {
        try {
            await signOut();
            toast.dismiss;
            // Redirect to login or home
            goto("/");
        } catch (error) {
            console.error("Error signing out: ", error);
        }
    }

    const handleDeleteUser = async () => {
        try {
            await deleteUser();
            await logoutUser();
            setTimeout(() => {
                goto("/");
                toast.success("Your account has been successfully removed.");
            }, 1000); // Adjust the delay as needed
        } catch (error) {}
    };

    export let data;
</script>

<Toaster />

<div class="wrapper">
    <div
        id="dynamic_ui"
        class="shiny-html-output shiny-bound-output"
        aria-live="polite"
    >
        <div>
            <div class="content-title">
                <div
                    id="sign-signed_in_title"
                    class="shiny-text-output shiny-bound-output"
                    aria-live="polite"
                >
                    {$translations["welcome"]}, {data.session.username}
                </div>
            </div>
            <br />
            <p class="logged_in_message">
                {@html $translations["welcome1"]}
            </p>
            <br />
            <div class="tabbable">
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <!-- svelte-ignore a11y-no-static-element-interactions -->
                <!-- svelte-ignore a11y-missing-attribute -->

                <ul class="nav nav-tabs" data-tabsetid="1719">
                    {#each Object.entries(appConfig["content"].tabsToShow) as [key, value]}
                        <li class={activeTab === key ? "active" : ""}>
                            <a
                                on:click|preventDefault={() => {
                                    setActiveTab(Object.keys(value)[0]);
                                }}
                            >
                                {Object.values(value)[0]}
                            </a>
                        </li>
                    {/each}
                    {#if activeTab != "SongBird"}
                        <li class={activeTab === "Tests" ? "active" : ""}>
                            <a
                                on:click|preventDefault={() => {
                                    createSessionToken(
                                        "singpause-saa",
                                        event,
                                        {},
                                        "singpause",
                                    );
                                }}>{$translations["my_sing_training_button"]}</a
                            >
                        </li>
                        <li class={activeTab === "Your Items" ? "active" : ""}>
                            <a
                                on:click|preventDefault={() =>
                                    setActiveTab("Your Items")}
                                >{$translations["my_singpause_songs_button"]}</a
                            >
                        </li>
                        <!-- {#if hasExperiments}
                            <li
                                class={activeTab === "Experiments"
                                    ? "active"
                                    : ""}
                            >
                                <a
                                    on:click|preventDefault={() =>
                                        setActiveTab("Experiments")}
                                    >Experiments</a
                                >
                            </li>
                        {/if} -->
                        <li
                            class={activeTab === "Your Progress"
                                ? "active"
                                : ""}
                        >
                            <a
                                on:click|preventDefault={() =>
                                    setActiveTab("Your Progress")}
                                >{$translations["your_progress"]}</a
                            >
                        </li>

                        <li
                            class={activeTab === "Account Details"
                                ? "active"
                                : ""}
                        >
                            <a
                                on:click|preventDefault={() =>
                                    setActiveTab("Account Details")}
                                >{$translations["account_details"]}</a
                            >
                        </li>
                    {/if}
                </ul>

                <!-- <ul class="nav nav-tabs" data-tabsetid="1719">
                    <li class={activeTab === "Tests" ? "active" : ""}>
                        <a on:click|preventDefault={() => setActiveTab("Tests")}
                            >Tests</a
                        >
                    </li>
                    {#if hasExperiments}
                        <li class={activeTab === "Experiments" ? "active" : ""}>
                            <a
                                on:click|preventDefault={() =>
                                    setActiveTab("Experiments")}>Experiments</a
                            >
                        </li>
                    {/if}
                    <li class={activeTab === "Your Progress" ? "active" : ""}>
                        <a
                            on:click|preventDefault={() =>
                                setActiveTab("Your Progress")}>Your Progress</a
                        >
                    </li>

                    <li class={activeTab === "Groups" ? "active" : ""}>
                        <a
                            on:click|preventDefault={() =>
                                setActiveTab("Groups")}>Groups</a
                        >
                    </li>

                    <li class={activeTab === "Account Details" ? "active" : ""}>
                        <a
                            on:click|preventDefault={() =>
                                setActiveTab("Account Details")}
                            >Account Details</a
                        >
                    </li>
                </ul> -->

                <div class="tab-content">
                    <div
                        class={activeTab === "Tests"
                            ? "tab-pane active"
                            : "tab-pane"}
                    >
                        <div>
                            {#if tests.length > 0}
                                <h2>{appConfig["content"].testsHeading}</h2>

                                {#each tests as test}
                                    <hr />
                                    <div>
                                        <h3>{test.test_description}</h3>
                                        <br />
                                        <img
                                            src={test.test_image}
                                            height="100"
                                            width="100"
                                            alt={test.test_description}
                                        />
                                        <button
                                            class="btn launch_test buttonload"
                                            type="button"
                                            on:click={createSessionToken(
                                                "singpause-" +
                                                    test.test_name.toLowerCase(),
                                                event,
                                                {},
                                                "singpause",
                                            )}
                                            >Launch Test!
                                            <i
                                                class="fa fa-circle-o-notch fa-spin"
                                            ></i>
                                        </button>
                                        <hr />
                                    </div>
                                {/each}
                            {:else if !hasTests}
                                <p>
                                    Before you can complete out any tests or
                                    experiments, you need to fill out your
                                    profile by answering some demographic
                                    questions.
                                </p>
                                <p>
                                    Click Edit Profile below to fill out your
                                    profile. The questionnaires will take 5-10
                                    minutes.
                                </p>
                                <button
                                    class="btn"
                                    type="button"
                                    on:click={createSessionToken}
                                    >Edit Profile</button
                                >
                            {:else}
                                <br />
                                <div class="animated-background">
                                    <div class="background-masker"></div>
                                </div>
                            {/if}
                        </div>
                    </div>
                    <div
                        class={activeTab === "Your Progress"
                            ? "tab-pane active"
                            : "tab-pane"}
                    >
                        <div>
                            <Chart userId={data.session.userId} />
                        </div>
                    </div>
                    <!-- svelte-ignore a11y-click-events-have-key-events -->
                    <!-- svelte-ignore a11y-missing-attribute -->
                    <!-- svelte-ignore a11y-no-static-element-interactions -->
                    <div
                        class={activeTab === "SongBird"
                            ? "tab-pane active"
                            : "tab-pane"}
                    >
                        <div style="text-align: center;">
                            <table
                                class="singbpause-table"
                                style="margin: 0 auto;"
                            >
                                <tr>
                                    <td>
                                        <a
                                            on:click={() => {
                                                createSessionToken(
                                                    "singpause-saa",
                                                    event,
                                                    {},
                                                    "singpause",
                                                );
                                            }}
                                        >
                                            <h3>
                                                {$translations[
                                                    "my_sing_training_button"
                                                ]}
                                            </h3>

                                            <img
                                                class="singpause-menu"
                                                src={bird}
                                                alt={$translations[
                                                    "my_sing_training_button"
                                                ]}
                                            />
                                        </a>
                                    </td>
                                    <td>
                                        <a
                                            on:click={() => {
                                                setActiveTab("Your Items");
                                            }}
                                        >
                                            <h3>
                                                {$translations[
                                                    "my_singpause_songs_button"
                                                ]}
                                            </h3>
                                            <img
                                                class="singpause-menu"
                                                src={songs}
                                                alt={$translations[
                                                    "my_singpause_songs_button"
                                                ]}
                                            />
                                        </a>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <a
                                            on:click={() =>
                                                setActiveTab("Your Progress")}
                                        >
                                            <h3>
                                                {$translations["your_progress"]}
                                            </h3>

                                            <img
                                                class="singpause-menu"
                                                src={progress}
                                                alt={$translations[
                                                    "your_progress"
                                                ]}
                                            />
                                        </a>
                                    </td>
                                    <td>
                                        <a
                                            on:click={() =>
                                                setActiveTab("Account Details")}
                                        >
                                            <h3>
                                                {$translations[
                                                    "account_details"
                                                ]}
                                            </h3>

                                            <img
                                                class="singpause-menu"
                                                src={user}
                                                alt={$translations[
                                                    "account_details"
                                                ]}
                                            />
                                        </a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div
                        class={activeTab === "Your Items"
                            ? "tab-pane active"
                            : "tab-pane"}
                        style="margin: 0 auto;"
                    >
                        {#if yourItems?.length > 0}
                            {#each yourItems as item}
                                <div>
                                    <br />
                                    <h2>{item.song_name}</h2>

                                    <table class="bottomBorder">
                                        <tr class="topBorder">
                                            <td>
                                                <img
                                                    src={item.image}
                                                    height="50"
                                                    width="50"
                                                    alt={item.song_name}
                                                />
                                            </td>
                                            <td>
                                                <Progress
                                                    progress={item.song_score}
                                                    size="80"
                                                />
                                            </td>
                                            <td>
                                                <button
                                                    class="btn center_valign"
                                                    style="width: 40%;"
                                                    type="button"
                                                    on:click={() => {
                                                        createSessionToken(
                                                            "singpause-singalong",
                                                            event,
                                                            {
                                                                item_bank_name:
                                                                    "singpause_item",
                                                                item_ids:
                                                                    item.item_id,
                                                                item_bank_id: 8,
                                                            },
                                                        );
                                                    }}
                                                    >{$translations[
                                                        "launch_song_along"
                                                    ]}
                                                    <i
                                                        class="fa fa-circle-o-notch fa-spin"
                                                    ></i></button
                                                >
                                                <button
                                                    class="btn center_valign"
                                                    type="button"
                                                    style="width: 40%;"
                                                    on:click={() => {
                                                        createSessionToken(
                                                            "singpause-solo",
                                                            event,
                                                            {
                                                                item_bank_name:
                                                                    "singpause_item",
                                                                item_ids:
                                                                    item.item_id,
                                                                item_bank_id: 8,
                                                            },
                                                        );
                                                    }}
                                                    >{$translations[
                                                        "launch_song_solo"
                                                    ]}
                                                    <i
                                                        class="fa fa-circle-o-notch fa-spin"
                                                    ></i></button
                                                >
                                            </td>
                                        </tr>

                                        {#each item.phrases as phrase, index}
                                            <tr>
                                                <td class="phrase"
                                                    >Phrase #{index + 1}</td
                                                >
                                                <td>
                                                    <Progress
                                                        progress={item.scores[
                                                            index
                                                        ]}
                                                        size="80"
                                                    />
                                                </td>
                                                <td>
                                                    <button
                                                        class="btn_alt center_valign"
                                                        type="button"
                                                        style="width: 40%;"
                                                        on:click={createSessionToken(
                                                            "singpause-singalong",
                                                            event,
                                                            {
                                                                item_bank_name:
                                                                    "singpause_phrase",
                                                                item_ids:
                                                                    phrase,
                                                                item_bank_id: 9,
                                                            },
                                                        )}
                                                        >{$translations[
                                                            "launch_song_along"
                                                        ]}
                                                        <i
                                                            class="fa fa-circle-o-notch fa-spin"
                                                        ></i></button
                                                    >

                                                    <button
                                                        class="btn_alt center_valign"
                                                        type="button"
                                                        style="width: 40%;"
                                                        on:click={createSessionToken(
                                                            "singpause-solo",
                                                            event,
                                                            {
                                                                item_bank_name:
                                                                    "singpause_phrase",
                                                                item_ids:
                                                                    phrase,
                                                                item_bank_id: 9,
                                                            },
                                                        )}
                                                        >{$translations[
                                                            "launch_song_solo"
                                                        ]}
                                                        <i
                                                            class="fa fa-circle-o-notch fa-spin"
                                                        ></i></button
                                                    ></td
                                                >
                                            </tr>
                                        {/each}
                                    </table>
                                </div>
                            {/each}
                        {:else}
                            <br />
                            <div class="animated-background">
                                <div class="background-masker"></div>
                            </div>
                        {/if}
                    </div>

                    <div
                        class={activeTab === "Experiments"
                            ? "tab-pane active"
                            : "tab-pane"}
                    >
                        <div>
                            {#if experiments.length > 0}
                                <h2>
                                    {appConfig["content"].experimentsHeading}
                                </h2>

                                {#each experiments as experiment}
                                    <hr />
                                    <div>
                                        <h3>
                                            {experiment.experiment_description}
                                        </h3>
                                        <br />
                                        <img
                                            src={experiment.image}
                                            height="100"
                                            width="100"
                                            alt={experiment.experiment_description}
                                        />
                                        <button
                                            class="btn launch_test"
                                            type="button"
                                            on:click={createSessionToken(
                                                experiment.experiment_name,
                                                event,
                                            )}>Launch Experiments</button
                                        >
                                        <hr />
                                    </div>
                                {/each}
                            {:else if !hasExperiments}
                                <p>
                                    Before you can complete out any tests or
                                    experiments, you need to fill out your
                                    profile by answering some demographic
                                    questions.
                                </p>
                                <p>
                                    Click Edit Profile below to fill out your
                                    profile. The questionnaires will take 5-10
                                    minutes.
                                </p>
                                <button
                                    class="btn"
                                    type="button"
                                    on:click={createSessionToken}
                                    >Edit Profile</button
                                >
                            {:else}
                                <br />
                                <div class="animated-background">
                                    <div class="background-masker"></div>
                                </div>
                            {/if}
                        </div>
                    </div>

                    <div
                        class={activeTab === "Your Groups"
                            ? "tab-pane active"
                            : "tab-pane"}
                    >
                        <h2>Add to Group</h2>
                        <hr />

                        <form
                            method="POST"
                            on:submit|preventDefault={handleAddUserToGroup}
                            bind:this={form}
                        >
                            <div class="inline-parent">
                                <div class="form-group shiny-input-container">
                                    <label
                                        class="control-label shiny-label-null"
                                        for="login-code"
                                    ></label>
                                    <input
                                        id="login-code"
                                        type="text"
                                        name="login-code"
                                        class="shiny-input-password form-control shiny-bound-input"
                                        value=""
                                        placeholder="Login code"
                                    />
                                </div>
                                <button
                                    type="submit"
                                    class="btn btn-default action-button shiny-bound-input"
                                    >Submit</button
                                >
                            </div>
                        </form>
                        <div>
                            {#if groups.length > 0}
                                <h2>Current Groups</h2>

                                {#each groups as group}
                                    <hr />
                                    <div>
                                        <p>{group.group_name}</p>
                                        <hr />
                                    </div>
                                {/each}
                            {:else if !hasGroups}
                                <p></p>
                            {:else}
                                <br />
                                <div class="animated-background">
                                    <div class="background-masker"></div>
                                </div>
                            {/if}
                        </div>
                    </div>

                    <div
                        class={activeTab === "Account Details"
                            ? "tab-pane active"
                            : "tab-pane"}
                    >
                        <form
                            class="signed-in-form"
                            method="POST"
                            on:submit|preventDefault={handleUpdatePassword}
                        >
                            <div class="form-group shiny-input-container">
                                <label
                                    class="control-label"
                                    id="sign-signed_in_current_password-label"
                                    for="signed_in_current_password"
                                    >{$translations["change_password"]}</label
                                >
                                <input
                                    id="signed_in_current_password"
                                    type="password"
                                    name="current-password"
                                    class="shiny-input-password form-control shiny-bound-input"
                                    value=""
                                    placeholder={$translations[
                                        "current_password"
                                    ]}
                                />
                            </div>
                            <div class="form-group shiny-input-container">
                                <label
                                    class="control-label"
                                    id="sign-signed_in_new_password-label"
                                    for="sign-signed_in_new_password"
                                ></label>
                                <input
                                    id="sign-signed_in_new_password"
                                    type="password"
                                    name="new-password"
                                    class="shiny-input-password form-control shiny-bound-input"
                                    value=""
                                    placeholder={$translations["new_password"]}
                                />
                            </div>
                            <div class="inline-parent">
                                <div class="form-group shiny-input-container">
                                    <label
                                        class="control-label shiny-label-null"
                                        for="sign-signed_in_verify_new_password"
                                        id="sign-signed_in_verify_new_password-label"
                                    ></label>
                                    <input
                                        id="sign-signed_in_verify_new_password"
                                        type="password"
                                        name="confirm-new-password"
                                        class="shiny-input-password form-control shiny-bound-input"
                                        value=""
                                        placeholder={$translations[
                                            "verify_password"
                                        ]}
                                    />
                                </div>
                                <button
                                    type="submit"
                                    class="btn btn-default action-button shiny-bound-input"
                                    >{$translations[
                                        "change_password_button"
                                    ]}</button
                                >
                                <hr />
                                {#if removeAccount}
                                    <button
                                        class="btn btn-default action-button caution-button shiny-bound-input"
                                        id="sign-remove_account_button"
                                        type="button"
                                        on:click|preventDefault={handleDeleteUser}
                                        >Remove Account</button
                                    >

                                    <br />
                                    <hr />
                                {/if}
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div id="signed_in_buttons">
                <button
                    id="sign-sign_out_button"
                    on:click|preventDefault={logoutUser}
                    type="button"
                    class="btn btn-default action-button shiny-bound-input"
                    >{$translations["sign_out"]}</button
                >
            </div>
        </div>
    </div>
</div>
