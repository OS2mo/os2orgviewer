<template>
  <div id="app">
    <transition name="ls-fade">
      <load-screen v-if="first_load" text="Vent et øjeblik mens vi henter data" />
    </transition>
    <oc-header id="oc-global-header">
      <router-link
        slot="preaction"
        to="/"
        class="oc-header-preaction btn"
        :title="`Vis første niveau i ${title}`"
      >
        <img v-if="logo_src" :src="logo_src" alt="" />
        <svg
          class="oc-home-img"
          v-else
          xmlns="http://www.w3.org/2000/svg"
          height="100%"
          viewBox="0 0 24 24"
          width="100%"
        >
          <path d="M0 0h24v24H0z" fill="none" />
          <path
            class="oc-home-img-path"
            d="M22 11V3h-7v3H9V3H2v8h7V8h2v10h4v3h7v-8h-7v3h-2V8h2v3z"
            fill="#000"
          />
        </svg>
        <span class="sr-only">Vis første niveau i {{ title }}</span>
      </router-link>
      <h1 v-if="title" slot="title" class="oc-header-title">
        {{ title }}
      </h1>
      <router-link
        v-if="$route.name !== 'search'"
        slot="postaction"
        :to="'/search'"
        class="oc-header-postaction btn"
      >
        <svg
          class="oc-search-svg"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="black"
          width="30px"
          height="30px"
        >
          <path d="M0 0h24v24H0z" fill="none" />
          <path
            class="oc-search-svg-path"
            d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"
          />
        </svg>
        <span class="sr-only">Åben søgefunktion</span>
      </router-link>
      <button
        v-else
        slot="postaction"
        @click="$router.go(-1)"
        class="oc-header-postaction btn"
      >
        <svg
          class="svg-close"
          xmlns="http://www.w3.org/2000/svg"
          height="24"
          viewBox="0 0 24 24"
          width="24"
        >
          <path d="M0 0h24v24H0z" fill="none" />
          <path
            class="oc-search-svg-path"
            d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"
          />
        </svg>
        <span class="sr-only">Luk søgefunktion</span>
      </button>
    </oc-header>
    <main id="oc-main">
      <router-view id="tree" name="tree"></router-view>
      <router-view id="organisation" name="organisation"></router-view>
      <router-view id="person" name="person"></router-view>
      <router-view id="search" name="search"></router-view>
      <router-view id="error" name="error"></router-view>
    </main>
    <!-- Make a change again with npm orginal test 4 -->
  </div>
</template>

<script>
import OcHeader from "./components/layout/Header.vue"
import LoadScreen from "./components/spinner/Loadscreen.vue"

import Vue from "vue"
import VueHead from "vue-head"

Vue.use(VueHead)

export default {
  name: "App",
  components: {
    OcHeader,
    LoadScreen,
  },
  data: function () {
    return {
      first_load: true,
    }
  },
  computed: {
    is_loading: function () {
      return this.$store.getters.isLoading
    },
    title() {
      return this.$store.state.title
    },
    logo_src() {
      return this.$store.state.logo_path
    },
    global_root_uuid: function () {
      return this.$store.getters.getGlobalRootUuid
    },
    org_unit_hierarchy_uuid: function () {
      return this.$store.getters.getOrgUnitHierarchy
    },
  },
  methods: {
    checkFirstLoad: function () {
      setTimeout(() => {
        if (this.is_loading) {
          this.checkFirstLoad()
        } else {
          this.first_load = false
        }
      }, 1000)
    },
    checkRootOrgUuid: function (root_uuid) {
      try {
        if (!root_uuid) {
          throw new Error("Missing VUE_APP_ROOT_UUID value")
        }
      } catch (err) {
        console.error(err)
      }
    },
    navToRoot: function () {
      window.location = "/"
    },
  },
  mounted: function () {
    this.checkRootOrgUuid(this.global_root_uuid)
    this.checkFirstLoad()
  },

  // TODO: Maybe we should make more use of vuehead, rather than using index.html
  head: {
    link: function () {
      return [{ rel: "icon", href: this.$store.state.favicon_path, undo: false }]
    },
  },
}
</script>

<style lang="scss">
* {
  box-sizing: border-box;
}

html,
body {
  width: 100%;
  height: 100%;
}

body {
  background-color: var(--background-color);
  color: var(--shade-darker);
  padding: 0;
  margin: 0;
  font: var(--font);
}

h1,
h2,
h3 {
  font-weight: normal;
}

a,
a:link,
a:visited {
  text-decoration: none;
  color: var(--primary-color);
  transition: padding 0.3s;
}

a:hover {
  color: var(--shade-darkest);
  background-color: var(--shade-lighter);
  padding: 0 0.5rem;
}

a:active {
  background-color: var(--primary-color);
  color: var(--shade-lightest);
}

a:focus {
  color: var(--shade-darkest);
  background-color: var(--shade-light);
  padding: 0 0.5rem;
  outline: none;
}

button,
a.btn,
a.btn:link,
a.btn:visited,
input[type="submit"] {
  display: block;
  color: var(--primary-color);
  background-color: var(--shade-lightest);
  padding: 0.25rem 0.5rem;
  text-align: center;
  border: none;
  font-size: 1rem;
  font-weight: normal;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  transition: all 0.3s;
}

button:hover,
a.btn:hover,
input[type="submit"]:hover {
  color: var(--shade-darkest);
  box-shadow: var(--shadow-1);
  transform: translate(-0.25rem, -0.25rem);
}

button:active,
a.btn:active,
input[type="submit"]:active {
  background-color: var(--primary-color);
  color: var(--shade-lightest);
}

button:focus,
a.btn:focus,
input[type="submit"]:focus {
  color: var(--shade-darkest);
  box-shadow: var(--shadow-1);
  transform: translate(-0.25rem, -0.25rem);
  outline: none;
}

button.inverse,
a.btn.inverse,
a.btn.inverse:link,
a.btn.inverse:visited,
input[type="submit"].inverse {
  background-color: var(--primary-color);
  color: var(--shade-lightest);
}

button.inverse:hover,
button.inverse:active,
button.inverse:focus,
a.btn.inverse:hover,
a.btn.inverse:active,
a.btn.inverse:focus,
input[type="submit"].inverse:hover,
input[type="submit"].inverse:active,
input[type="submit"].inverse:focus {
  background-color: var(--shade-darker);
}

dt,
.label {
  color: var(--shade-darker);
  font-size: smaller;
}

dd {
  margin: 0 0 1rem;
  padding: 0;
}

hr {
  border: solid 1px var(--shade-lighter);
  border-width: 1px 0 0 0;
  margin: 1.5rem 1rem;
}

.sr-only {
  position: absolute;
  left: -10000px;
  top: auto;
  width: 1px;
  height: 1px;
  overflow: hidden;
}

#app {
  width: 100%;
  height: 100%;
  display: flex;
  flex-flow: column nowrap;
}

#oc-global-header {
  box-shadow: var(--shadow-3);
  flex: 0 0 3rem;
  z-index: 5;
}

a.oc-header-preaction {
  flex: 0 0 auto;
  display: flex !important;
  flex-flow: column nowrap;
  justify-content: center;
  align-items: center;
  padding: 0.5rem 1rem;
}

a.oc-header-preaction img {
  height: 1.75rem;
  width: auto;
}

.oc-home-img {
  height: 2rem;
  width: 2rem;
}

.oc-home-img-path {
  fill: var(--primary-color);
}

.oc-header-title {
  flex: 1 1 auto;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  margin: 0;
  padding: 0;
}

.oc-header-postaction {
  flex: 0 0 auto;
  //align-self: flex-end;
  font-size: 1.5rem !important;
  padding: 0.75rem 1rem !important;
  line-height: 1;

  .oc-search-svg-path {
    fill: var(--primary-color);
  }
}

.oc-header-postaction:hover,
.oc-header-postaction:active,
.oc-header-postaction:focus {
  .oc-search-svg-path {
    fill: var(--shade-darkest);
  }
}

#oc-main {
  height: calc(100% - 3rem);
  flex: 1 0 auto;
}

.oc-fade-enter-active,
.oc-fade-leave-active {
  transition: transform 0.3s;
}

.oc-fade-enter,
.oc-fade-leave-to {
  transform: translateX(100%);
}

//.ls-fade-enter-active,
.ls-fade-leave-active {
  clip-path: circle(100%);
  transition: clip-path 0.5s;
}
//.ls-fade-enter,
.ls-fade-leave-to {
  clip-path: circle(1%);
}

@media print {
  html,
  body {
    width: auto;
    height: auto;
  }

  body {
    font-size: 10pt;
  }

  body,
  #app,
  dt {
    background-color: #fff;
    color: #000;
  }

  #app,
  #oc-main {
    display: block;
    width: auto;
    height: auto;
  }

  a,
  a:link,
  a:visited,
  a.btn,
  button {
    color: #000 !important;
    background-color: #fff !important;
  }

  #oc-global-header {
    box-shadow: none;
    border-bottom: solid 1pt #000;
  }

  a.oc-header-preaction {
    border: solid 1pt #000;
    padding-left: 0 !important;
  }

  hr {
    border-color: black;
  }

  .oc-header-postaction,
  .sr-only {
    display: none !important;
  }
}
</style>
