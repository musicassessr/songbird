<script lang="ts">
    import { onMount } from "svelte";
    import { DataHandler, Datatable, Th } from "@vincjo/datatables";
    import { signIn, signUp } from "@aws-amplify/auth";
    import { goto, invalidateAll } from "$app/navigation";
    import "$lib/Cognito";
    import toast, { Toaster } from "svelte-french-toast";
    import appConfig from "$lib/app-config.yaml";
    let res;
    let groupsStats;
    let currentView = "overall"; // This will control which res set to show
    let userSessionsDataHandler;
    let songStatsDataHandler;
    let userSessionsRows;
    let songStatsDataRows;
    let loader = true;
    let avg_minutes_per_day = 0; // Default value
    let avg_no_practice_sessions = 0; // Default value
    export let data;
    const API_BASE_URL = import.meta.env.VITE_APP_API_BASE_URL;
    import Modal from "$lib/components/Modal.svelte";
    let showModal = false;
    let signUpData = {};
    let form: any;
    import { translations , loadTranslations} from "$lib/stores/store";
    import songbird_icon from "$lib/assets/songbird_icon.png";




    const validateEmail = (email) => {
        // Regular expression to validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    };

    // Function to update res handlers based on currentView
    const updateDataHandlers = () => {
        const userSessionsData = res[
            `${currentView}_avg_no_practice_session_per_user`
        ].map((userSession, index) => ({
            id: index,
            user_id: userSession.user_id,
            username: userSession.username,
            sessions: userSession[`${currentView}_no_practice_sessions`],
        }));

        const songStatsData = res[`${currentView}_song_stats`].map(
            (songStat, index) => ({
                id: index,
                phrase_name: songStat.phrase_name,
                NoTimesPractised: songStat.NoTimesPractised,
                Score: songStat.Score || "N/A", // Handle missing Score with 'N/A'
            }),
        );

        avg_minutes_per_day =
            parseInt(res[`${currentView}_avg_minutes_per_day`] * 100) / 100;
        avg_no_practice_sessions =
            parseInt(res[`${currentView}_avg_no_practice_sessions`] * 100) /
            100;

        userSessionsDataHandler = new DataHandler(userSessionsData, {
            rowsPerPage: 10,
        });
        songStatsDataHandler = new DataHandler(songStatsData, {
            rowsPerPage: 10,
        });

        userSessionsRows = userSessionsDataHandler.getRows();
        songStatsDataRows = songStatsDataHandler.getRows();
    };

    const handleViewChange = (event) => {
        currentView = event.target.value;
        updateDataHandlers();
    };

    const getGroupStats = async () => {
        const url = `${API_BASE_URL}/get-trial-and-session-data`;
        const payload = {
            group_id: 5,
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
            loader = false;
            return result;
        } catch (error) {}
    };

    const handleSubmit = async (event: any) => {
        const data = new FormData(event.target);

        let username = data.get("email");
        let password = data.get("password");
        try {
            const { isSignedIn, nextStep } = await signIn({
                username,
                password,
            });
            invalidateAll();
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
                        "custom:isAdmin": "true",
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

    onMount(async () => {
        if (data.session?.isAdmin) {
            groupsStats = await getGroupStats();
            res = groupsStats?.group_stats;
            updateDataHandlers();
        }
    });
</script>

<Toaster />

<Modal bind:showModal on:confirm={handleSignUp} />

{#if data.session?.isAdmin}
    <div class="container" style="position: relative;">
        {#if groupsStats?.group_stats}
            <br />
            <div class="dropdown-container">
                <select on:change={handleViewChange}>
                    <option value="" disabled selected>Select a view</option>

                    <option value="overall">Overall</option>
                    <option value="last_month">Last Month</option>
                    <option value="last_week">Last Week</option>
                </select>
            </div>
            <hr />

            <p>
                The students have practised an average of {avg_minutes_per_day} minutes
                per day and completed {avg_no_practice_sessions} practice sessions
                {#if currentView !== "overall"}
                    in the {currentView.replace("_", " ")}{/if}.
            </p>
            <!-- User Sessions Table -->

            <hr />
            <h2>User Statistics</h2>
            <br />
            <Datatable
                handler={userSessionsDataHandler}
                search={false}
                rowsPerPage={false}
            >
                <table>
                    <thead>
                        <tr>
                            <Th
                                handler={userSessionsDataHandler}
                                orderBy="user_id">User ID</Th
                            >
                            <Th
                                handler={userSessionsDataHandler}
                                orderBy="sessions">No. Practice Sessions</Th
                            >
                        </tr>
                    </thead>
                    <tbody>
                        {#each $userSessionsRows as row}
                            <tr>
                                <td>
                                    <a
                                        style="color: inherit;"
                                        href={`/teacher/user-stats/${row.user_id}`}
                                    >
                                        {row.username}
                                    </a></td
                                >
                                <td>{row.sessions}</td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </Datatable>

            <!-- Song Stats Table -->
            <hr />
            <h2>Song Statistics</h2>
            <br />
            <Datatable
                handler={songStatsDataHandler}
                search={false}
                rowsPerPage={false}
            >
                <table>
                    <thead>
                        <tr>
                            <Th
                                handler={songStatsDataHandler}
                                orderBy="phrase_name">Phrase Name</Th
                            >
                            <Th
                                handler={songStatsDataHandler}
                                orderBy="NoTimesPractised"
                                >No. Times Practised</Th
                            >
                            <Th handler={songStatsDataHandler} orderBy="Score"
                                >Avg. Score</Th
                            >
                        </tr>
                    </thead>
                    <tbody>
                        {#each $songStatsDataRows as row}
                            <tr>
                                <td>{row.phrase_name}</td>
                                <td>{row.NoTimesPractised}</td>
                                <td>{row.Score}</td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </Datatable>
        {:else if loader}
            <div class="animated-background">
                <div class="background-masker"></div>
            </div>
        {/if}
    </div>
{:else}
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

<style>
    thead {
        background: #fff;
    }
    tbody td {
        padding: 4px 20px;
    }
    tbody tr {
        transition: all, 0.2s;
    }
    tbody tr:hover {
        background: #f5f5f5;
    }

    .dropdown-container {
        color: #333;
        cursor: pointer;
        position: absolute;
        top: 0;
        right: 0;
    }

    p {
        letter-spacing: normal !important;
    }
</style>
