
<script>
  import { invalidateAll } from "$app/navigation";
  import { createEventDispatcher } from "svelte";
  import { onMount } from "svelte";

  const dispatch = createEventDispatcher();

  export let showModal = false;
  export let onConfirm;

  let agreeInformed = false;
  let agreeRecording = false;
  let agreeParticipation = false;

  let showContent = "main"; // 'main', 'freiwilligkeit', 'datenschutz'

  const closeModal = () => {
    showModal = false;
    const event = new CustomEvent("closeModal");
    dispatchEvent(event);
  };

  const handleFormSubmit = (event) => {
    event.preventDefault();
    if (agreeInformed && agreeRecording && agreeParticipation) {
      dispatch("confirm", {
        text: "true",
      });
      closeModal();
    } else {
      alert("Sie müssen allen Bedingungen zustimmen.");
    }
  };

  const showFreiwilligkeit = () => {
    showContent = "freiwilligkeit";
  };

  const showDatenschutz = () => {
    showContent = "datenschutz";
  };

  const showMain = () => {
    showContent = "main";
  };
</script>

{#if showModal}
  <div class="modal-background" on:click={closeModal}>
    <div class="modal-content" on:click|stopPropagation>
      {#if showContent === "main"}
        <h2 class="header">Einverständniserklärung</h2>
        <br />
        <form on:submit={handleFormSubmit}>
          <div class="checkbox-container">
            <input
              type="checkbox"
              id="agreeInformed"
              bind:checked={agreeInformed}
            />
            <label for="agreeInformed">
              Mein Kind und ich sind schriftlich im ausreichenden Maße über das
              Ziel und den Ablauf der Studie informiert worden und haben die
              Informationen zur <span
                class="underline"
                on:click={showFreiwilligkeit}
              >
                Freiwilligkeit
              </span>
              und
              <span class="underline" on:click={showDatenschutz}
                >Datenschutz</span
              > erhalten. Mit der beschriebenen Erhebung und Verarbeitung der Daten,
              welche durch die Nutzung der App SongBird erhoben werden, bin ich einverstanden.
              Mir ist bekannt, dass ich mein Einverständnis zur Speicherung der Daten
              meines Kindes jederzeit widerrufen und eine Löschung aller Daten verlangen
              kann, ohne dass mir daraus Nachteile entstehen.
            </label>

            <input
              type="checkbox"
              id="agreeRecording"
              bind:checked={agreeRecording}
            />
            <label for="agreeRecording">
              Ich bin darüber informiert, dass die Nutzung der App SongBird die
              Verwendung von Kopfhörern und Mikrofon vorsieht und beim
              Sing-Training eine Aufzeichnung der Singstimme stattfindet.
            </label>
          </div>
          <div class="checkbox-container">
            <input
              type="checkbox"
              id="agreeParticipation"
              bind:checked={agreeParticipation}
            />
            <label for="agreeParticipation">
              Ich willige ein, dass mein Kind an der Studie teilnehmen und die
              App SongBird nutzen darf.
            </label>
          </div>
          <button type="submit" class="button">Registrieren</button>
        </form>
      {/if}

      {#if showContent === "freiwilligkeit"}
        <button class="back-button" on:click={showMain}>← Zurück</button>
        <h2 class="header" style="text-align: left;">Freiwilligkeit:</h2>
        <p>
          Die Teilnahme an der Studie ist freiwillig. Sie bzw. Ihre Tochter/Ihr
          Sohn können jederzeit und ohne Angabe von Gründen die Teilnahme an
          dieser Studie beenden, ohne dass Ihnen daraus Nachteile entstehen. Die
          im Rahmen dieser Studie erhobenen, oben beschriebenen Daten und
          persönlichen Mitteilungen werden vertraulich behandelt. So unterliegen
          diejenigen Projektmitarbeiter:innen, die durch direkten Kontakt mit
          Ihnen über personenbezogene Daten verfügen, der Schweigepflicht bzw.
          dem Datengeheimnis. Veröffentlichungen von Studienergebnissen erfolgen
          in anonymisierter Form, d. h. es können keine Daten bestimmten
          Personen zugeordnet werden.
        </p>
      {/if}

      {#if showContent === "datenschutz"}
        <button class="back-button" on:click={showMain}>← Zurück</button>
        <h2 class="header" style="text-align: left;">Datenschutz:</h2>
        <p>
          Die Erhebung aller Daten erfolgt vollständig anonymisiert, d. h. an
          keiner Stelle wird der Name Ihres Kindes erfragt. Antworten,
          Tonaufzeichnungen und Ergebnisse werden unter einem persönlichen
          Codewort gespeichert, das Sie bzw. Ihr Kind selbst anhand einer Regel
          erstellt haben und das außer Ihnen niemand kennt. Das heißt, es ist
          niemandem möglich, die Daten Ihres Kindes mit dessen Namen in
          Verbindung zu bringen. Die Aufzeichnung und Auswertung der Daten
          erfolgt anonymisiert im Hector-Institut für Empirische
          Bildungsforschung der Universität Tübingen sowie an der Hochschule für
          Musik, Theater und Medien Hannover. Die anonymisierten Daten werden
          mindestens 10 Jahre gespeichert. Sie können allerdings, wenn immer Sie
          dies möchten, die Löschung der von Ihrem Kind erhobenen Daten
          verlangen. Dazu müssen Sie uns keinen Namen verraten, sondern nur das
          persönliche Codewort. Für die Erstellung des Codeworts erhalten Sie
          die Anleitung „Wie erstelle ich mein persönliches Codewort?“. Dieses
          Blatt verbleibt bei Ihnen. Bewahren Sie es bitte sorgfältig auf, damit
          Sie ggf. später die Löschung der von Ihrem Kind erhobenen Daten
          verlangen können. Die online-Testungen finden über die
          nicht-kommerzielle digitale open-access-Plattform
          https://singpause.songbird.training statt und alle Daten werden auf
          einem Amazon Elastic Compute Cloud (EC2) Server in Frankfurt
          gespeichert, sodass eine datenschutzgerechte Erhebung und Aufbewahrung
          der Daten über Amazon Web Services (AWS) gewährleistet ist.
        </p>
      {/if}
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
    font-size: 1.6rem;
    line-height: 1.8;
  }

  .tooltip {
    color: orange;
    margin-bottom: 1rem;
    font-size: 1.75rem;
  }

  .header {
    color: orange;
    margin-bottom: 1rem;
    text-align: center;
    font-size: 1.75rem;
  }

  .button {
    background-color: orange;
    color: white;
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 0.5rem;
    cursor: pointer;
    margin-top: 1rem;
    display: block;
    width: 100%;
    font-size: 1.6rem;
  }

  .button:hover {
    background-color: darkorange;
  }

  .checkbox-container {
    margin: 1rem 0;
    display: flex;
    align-items: flex-start;
  }

  .checkbox-container input {
    margin-right: 0.5rem;
    margin-top: 0.2rem;
  }

  @media (max-width: 600px) {
    .modal-content {
      padding: 1rem;
      font-size: 1rem;
    }

    .header {
      font-size: 1.5rem;
    }

    .button {
      padding: 0.5rem;
      font-size: 1rem;
    }
  }

  @media (min-width: 1200px) {
    .modal-content {
      max-width: 1000px;
      font-size: 2rem;
    }

    .underline {
      font-size: 2rem;
    }
    .header {
      font-size: 2.5rem;
    }

    .button {
      font-size: 2rem;
    }
  }

  .underline {
    text-decoration: underline;
    cursor: pointer;
    position: relative;
    /* font-size: 1.6rem; */
  }

  .back-button {
    background: none;
    border: none;
    color: orange;
    cursor: pointer;
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }
</style>
