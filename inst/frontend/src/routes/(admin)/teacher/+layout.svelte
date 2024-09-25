<script lang="ts">
    import "../../../app.css";
    import songbird_logo from "$lib/assets/songbird_logo.png";
    import appConfig from "$lib/app-config.yaml";
    import { translations , loadTranslations} from "$lib/stores/store";
    const SONGBIRD_APP_URL=  import.meta.env.VITE_APP_SONGBIRD_URL ?? appConfig["subdomain"];
</script>

<header>
<a href="{SONGBIRD_APP_URL}/teacher">
        <div id="header_title">
            <img src="{songbird_logo}">
        </div>
    </a>
</header>
<slot></slot>
<div class="df-layout">

<footer>
    <div id="footer_message">

        <p>
            {$translations["help_contact"]}

            <a href="mailto:songbirdtrainingapp@gmail.com">songbirdtrainingapp@gmail.com</a>.

            {$translations["Give"]}
            <a href="https://docs.google.com/forms/d/e/1FAIpQLSehKWo83CHUVrLvJq_pdHtmqMzgV9_i1V2n2EE-0g_jfBuxyg/viewform?usp=sf_link">
              {$translations["here"]}
            </a>
            {$translations["feedback"]}
        </p>

    </div>
</footer>
</div>
