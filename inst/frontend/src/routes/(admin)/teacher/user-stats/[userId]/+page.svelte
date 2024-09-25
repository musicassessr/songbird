<script lang="ts">
    import Chart from "$lib/components/Chart.svelte"; // Adjust path based on your project structure

    export let data;
</script>

<div class="wrapper">
    <Chart userId={data.userId} />
</div>