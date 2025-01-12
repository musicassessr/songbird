<script>
    // @ts-nocheck

    import { onMount } from "svelte";
    import Chart from "chart.js/auto";
    import { translations, loadTranslations } from "$lib/stores/store";
    import { fontString, TAU } from "chart.js/helpers";

    export let userId;
    let hasData = true;
    let aggregatedChart;
    let separateChart;
    let reviewChart;
    let res = null;
    let rhythmicChart;
    let loader = true;
    let userStats = "";
    let currentView = "overall";
    const API_BASE_URL = import.meta.env.VITE_APP_API_BASE_URL;

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
        userStats = getStats(res.user_stats, currentView);
    };

    // Configuration for the graph
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


    // Function to populate the dropdown
    const populateDropdown = (melodyReviewData) => {
        const dropdown = document.getElementById("melodyReviewDropdown");

        // Clear existing options
        dropdown.innerHTML = "";

        const melodies = melodyReviewData.map((el) => el.phrase_name);

        // Create and append new melodies
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

    // Function to filter the array of arrays based on a property value
    const filterArrayOfArrays = (array, value) => {
        return array.filter((item) => item.phrase_name === value);
    };

    const getMyProgressData = async (userId) => {
        const url = `${API_BASE_URL}/get-trial-and-session-data`;
        const payload = { user_id: parseInt(userId) };
        try {
            const response = await fetch(url, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            loader = false;
            return result;
        } catch (error) {
            return;
        }
    };

    // Fetch data
    onMount(async () => {
        res = await getMyProgressData(userId);
        if (
            res?.review_melodies?.length > 0 ||
            res?.session_scores_rhythmic?.length > 0
        ) {
            populateCharts();
            populateDropdown(res.review_melodies);
            userStats = getStats(res.user_stats, currentView);
        } else {
            hasData = false;
        }
    });

    // Populate charts
    const populateCharts = () => {
        if (!res) return;

        if (rhythmicChart) {
            rhythmicChart.destroy();
        }
        const labelsRhythmic = res.session_scores_rhythmic.map((el) => el.Date);
        const rhythmicScores = res.session_scores_rhythmic.map(
            (el) => el.score * 10,
        );

        if (labelsRhythmic.length == 0 || rhythmicScores.length == 0) {
            loader = false;

            document.getElementById("rhythmicChartWrapper").style.display =
                "none";
            return;
        }
        const rhythmicData = {
            labels: labelsRhythmic,
            title: $translations["my_sing_training_button"],
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

    // Event listener for dropdown change
    const handleDropdownChange = (event) => {
        const selectedValue = event.target.value;
        if (selectedValue == "") {
            return;
        }

        if (reviewChart) {
            reviewChart.destroy();
        }

        const melodyReviewDataFiltered = filterArrayOfArrays(
            res.review_melodies,
            selectedValue,
        );
        const reviewDates = melodyReviewDataFiltered.map((el) => el.Date);
        const reviewScores = melodyReviewDataFiltered.map((el) => el.score * 10);

        if (reviewDates.length == 0 || reviewScores.length == 0) {
            loader = false;
            document.getElementById(
                "reviewMelodiesChartWrapper",
            ).style.display = "none";
            return;
        }
        const compiledDataReview = {
            labels: reviewDates,
            title: $translations["my_singpause_songs_button"],
            subtitle: {
                display: true,
                text: selectedValue,
            },
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
</script>

<div>
    <div
        id="myProgress"
        class="container"
        style="display: {res?.review_melodies?.length > 0 ||
        res?.session_scores_rhythmic?.length > 0
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
        </div>
        <canvas id="rhythmicChart"></canvas>
        <hr />
        <div id="reviewMelodiesChartWrapper">
            <div
                style="display: flex; justify-content: space-between; align-items: center;"
            >
                <h3 style="margin: 0; text-align: center;color: #229787;">
                    {@html $translations["my_singpause_songs_button"]}
                </h3>
                <div class="select-wrapper">
                    <select
                        id="melodyReviewDropdown"
                        on:change={handleDropdownChange}
                    >
                        <!-- This will be populated dynamically -->
                    </select>
                </div>
            </div>
            <hr />
            <canvas id="reviewMelodiesChart"></canvas>
            <hr />
        </div>
    </div>
    {#if !hasData}
        <p>
            {$translations["missing_data"]}
        </p>
    {:else if loader}
        <div class="animated-background">
            <div class="background-masker"></div>
        </div>
    {/if}
</div>

<style>
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
