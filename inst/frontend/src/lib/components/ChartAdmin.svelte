<script>
    // @ts-nocheck

    import { onMount } from "svelte";
    import Chart from "chart.js/auto";
    import { translations, loadTranslations } from "$lib/stores/store";

    export let userData;
    export let reviewMelodies = [];
    export let sessionScoresRhythmic = [];
    export let username = "";

    let hasData = true;
    let rhythmicChart;
    let reviewChart;
    let userStats = "";
    let currentView = "overall";
    let loader = true;
    let showModal = false; // Control modal visibility

    function sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    const closeModal = () => {
        showModal = false;
        const event = new CustomEvent("closeModal");
        dispatchEvent(event);
    };

    const getStats = (userStats, period) => {
        const now = new Date();
        let startDate;
        let translationKey;
        let totalMinutesSpent = 0;
        let totalPracticeSessions = 0;

        switch (period) {
            case "last_week":
                startDate = new Date(now.setDate(now.getDate() - 7));
                translationKey = "last_week_you_practiced";
                break;
            case "last_month":
                startDate = new Date(now.setMonth(now.getMonth() - 1));
                translationKey = "last_month_you_practiced";
                break;
            default:
                startDate = new Date(0); // All time
                translationKey = "overall_you_practiced";
        }

        userStats.forEach((stat) => {
            const statDate = new Date(stat.Date);
            if (statDate >= startDate) {
                totalMinutesSpent += stat.minutes_spent;
                totalPracticeSessions += stat.no_practice_sessions;
            }
        });

        const totalTimeSpent =
            totalMinutesSpent >= 60
                ? `${Math.round(totalMinutesSpent / 60)} ${$translations["hours"]}`
                : `${totalMinutesSpent.toFixed(0)} ${$translations["minutes"]}`;
        return $translations[translationKey]
            .replace("{totalTimeSpent}", totalTimeSpent)
            .replace("{totalPracticeSessions}", totalPracticeSessions);
    };

    const handleViewChange = (event) => {
        currentView = event.target.value;
        userStats = getStats(userData, currentView);
    };

    const createConfig = (data) => {
        return {
            type: "line",
            data: data,
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false,
                        position: "top",
                    },
                },
                scales: {
                    y: {
                        min: 0,
                        max: 10,
                    },
                },
            },
        };
    };

    const populateDropdown = (melodyReviewData) => {
        const dropdown = document.getElementById("melodyReviewDropdown");

        dropdown.innerHTML = "";

        const melodies = melodyReviewData.map((el) => el.phrase_name);

        melodies.forEach((option) => {
            const optionElement = document.createElement("option");
            optionElement.value = option;
            optionElement.textContent = option;
            dropdown.appendChild(optionElement);
        });

        if (melodies.length > 0) {
            dropdown.value = melodies[0];
            const event = new Event("change");
            dropdown.dispatchEvent(event);
        }
    };

    const filterArrayOfArrays = (array, value) => {
        return array.filter((item) => item.phrase_name === value);
    };

    const populateCharts = () => {
        if (rhythmicChart) {
            rhythmicChart.destroy();
        }
        const labelsRhythmic = sessionScoresRhythmic.map((el) => el.Date);
        const rhythmicScores = sessionScoresRhythmic.map((el) => el.score * 10);
        if (labelsRhythmic.length == 0 || rhythmicScores.length == 0) {
            loader = false;
            document.getElementById("rhythmicChartWrapper").style.display =
                "none";
            return;
        }
        const rhythmicData = {
            labels: labelsRhythmic,
            datasets: [
                {
                    label: "My Sing-Training",
                    backgroundColor: "rgb(75, 192, 192)",
                    borderColor: "rgb(75, 192, 192)",
                    data: rhythmicScores,
                },
            ],
        };

        rhythmicChart = new Chart(
            document.getElementById("rhythmicChart"),
            createConfig(rhythmicData),
        );
    };

    const handleDropdownChange = (event) => {
        const selectedValue = event.target.value;
        if (selectedValue == "") {
            return;
        }

        if (reviewChart) {
            reviewChart.destroy();
        }

        const melodyReviewDataFiltered = filterArrayOfArrays(
            reviewMelodies,
            selectedValue,
        );
        const reviewDates = melodyReviewDataFiltered.map((el) => el.Date);
        const reviewScores = melodyReviewDataFiltered.map(
            (el) => el.score * 10,
        );

        if (reviewDates.length == 0 || reviewScores.length == 0) {
            loader = false;
            document.getElementById(
                "reviewMelodiesChartWrapper",
            ).style.display = "none";
            return;
        }
        const compiledDataReview = {
            labels: reviewDates,
            datasets: [
                {
                    label: "Melody Review",
                    backgroundColor: "rgb(200, 150, 255)",
                    borderColor: "rgb(200, 150, 255)",
                    data: reviewScores,
                },
            ],
        };

        reviewChart = new Chart(
            document.getElementById("reviewMelodiesChart"),
            createConfig(compiledDataReview),
        );
    };
    const populateChartsv2 = async () => {
        if (reviewMelodies.length > 0 || sessionScoresRhythmic.length > 0) {
            await sleep(10);
            populateCharts();
            populateDropdown(reviewMelodies);
        } else {
            hasData = false;
        }
    };
</script>

<td
    on:click={() => {
        showModal = true;
        populateChartsv2();
    }}>{username}</td
>

{#if showModal}
    <div class="modal-background" on:click={closeModal}>
        <div class="modal-content" on:click|stopPropagation>
            <div>
                <div
                    id="myProgress"
                    style="display: {reviewMelodies.length > 0 ||
                    sessionScoresRhythmic.length > 0
                        ? 'block'
                        : 'none'};"
                >
                    <br />
                    <div class="view-select-wrapper">
                        <p style="margin: 0;">{userStats}</p>
                        <div class="select-wrapper">
                            <select on:change={handleViewChange}>
                                <option selected value="overall"
                                    >{$translations["overall"]}</option
                                >
                                <option value="last_month"
                                    >{$translations["last_month"]}</option
                                >
                                <option value="last_week"
                                    >{$translations["last_week"]}</option
                                >
                            </select>
                        </div>
                    </div>
                    <div id="rhythmicChartWrapper">
                        <hr />
                        <h3 style="color: #229787;">
                            {@html $translations["my_sing_training_button"]}
                        </h3>
                        <hr />
                        <canvas id="rhythmicChart"></canvas>
                        <hr />
                    </div>

                    <div id="reviewMelodiesChartWrapper">
                        <div class="chart-header">
                            <h3
                                style="margin: 0; text-align: center; color: #229787;"
                            >
                                {@html $translations[
                                    "my_singpause_songs_button"
                                ]}
                            </h3>
                            <div class="select-wrapper">
                                <select
                                    id="melodyReviewDropdown"
                                    on:change={handleDropdownChange}
                                ></select>
                            </div>
                        </div>
                        <hr />
                        <canvas id="reviewMelodiesChart"></canvas>
                        <hr />
                    </div>
                </div>
                {#if !hasData}
                    <p>{$translations["missing_data"]}</p>
                {:else if loader}
                    <div class="animated-background">
                        <div class="background-masker"></div>
                    </div>
                {/if}
            </div>
        </div>
    </div>
{/if}

<style>
    .modal-background {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 1rem;
        box-sizing: border-box;
        z-index: 9999; /* Ensure modal background is on top */
    }

    .modal-content {
        background-color: #fff;
        padding: 2rem;
        border-radius: 0.5rem;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        max-width: 90%;
        width: 800px;
        box-sizing: border-box;
        overflow-y: auto;
        max-height: 90%;
        z-index: 10000; /* Ensure modal content is above modal background */
        position: relative;
    }

    .select-wrapper {
        position: relative;
        display: inline-block;
        width: auto;
    }

    .select-wrapper select {
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        background-color: #f5f5f5;
        border: 1px solid #ccc;
        border-radius: 5px;
        padding: 8px 38px 8px 12px;
        font-size: 16px;
        color: #333;
        cursor: pointer;
    }

    .select-wrapper::after {
        content: "▼";
        position: absolute;
        top: 50%;
        right: 10px;
        transform: translateY(-50%);
        color: #666;
    }

    /* .select-wrapper::before {
        content: "";
        position: absolute;
        pointer-events: none;
    } */

    .select-wrapper select:focus {
        outline: none;
    }

    .view-select-wrapper {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
    }
</style>
