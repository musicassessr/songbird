<script lang="ts">
    import "../app.css";
    import songbird_logo from "$lib/assets/songbird_logo.png";
    import appConfig from "$lib/app-config.yaml";
    import { translations , loadTranslations} from "$lib/stores/store";

</script>

<header>
<a href="https://{appConfig["subdomain"]} ">
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