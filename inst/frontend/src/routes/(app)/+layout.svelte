<script lang="ts">
    import "../../app.css";
    import songbird_logo from "$lib/assets/songbird_logo.png";
    import appConfig from "$lib/app-config.yaml";
    import { translations , loadTranslations} from "$lib/stores/store";
    const SONGBIRD_APP_URL=  import.meta.env.VITE_APP_SONGBIRD_URL ?? appConfig["subdomain"];

</script>

<header>
<a href="{SONGBIRD_APP_URL}">
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
      
            <a href="mailto:sebsilas@gmail.com">sebsilas@gmail.com</a>
          </p>
        
    </div>
</footer>
</div>