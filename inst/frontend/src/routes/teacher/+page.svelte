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

    // Function to update res handlers based on currentView
    const updateDataHandlers = () => {
        const userSessionsData = res[
            `${currentView}_avg_no_practice_session_per_user`
        ].map((userSession, index) => ({
            id: index,
            user_id: userSession.user_id,
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

    onMount(async () => {
        if (data.session?.isAdmin) {
            groupsStats = await getGroupStats();
            res = groupsStats?.group_stats;
            updateDataHandlers();
        }
    });
</script>

<Toaster />

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
                                <td>{row.user_id}</td>
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
                            <Th handler={songStatsDataHandler}>Score</Th>
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
                {@html appConfig["content"].welcomeText}
            </div>
            <br />
            <form
                id="sign-sign_in_section"
                method="POST"
                on:submit|preventDefault={handleSubmit}
            >
                <div class="content-title">Sign In</div>
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
                        placeholder="Username"
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
                        placeholder="Password"
                    />
                </div>
                <button
                    class="btn btn-default action-button shiny-bound-input"
                    id="sign-sign_in_button"
                    type="button submit">Sign In</button
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
