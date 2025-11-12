<template>
  <transition name="oc-fade">
    <article
      class="oc-org"
      :class="{ dim: $route.name === 'person' }"
      v-if="org_unit_data && this.$route.name.match(/[orgunit|person]/)"
      :tabindex="$route.query.person ? -1 : 0"
    >
      <oc-header>
        <h2 slot="title">
          <router-link id="orgtitle" :to="`/tree/${org_unit_data.uuid}/${root_uuid}`">
            <svg
              class="svg-back"
              xmlns="http://www.w3.org/2000/svg"
              height="24"
              viewBox="0 0 24 24"
              width="24"
            >
              <path d="M0 0h24v24H0z" fill="none" />
              <path
                class="svg-path"
                d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"
              />
            </svg>
            <span class="oc-org-title">{{ org_unit_data.name }}</span>
            <span class="sr-only">Luk visning af {{ org_unit_data.name }}</span>
            <svg
              class="svg-close"
              xmlns="http://www.w3.org/2000/svg"
              height="24"
              viewBox="0 0 24 24"
              width="24"
            >
              <path d="M0 0h24v24H0z" fill="none" />
              <path
                class="svg-path"
                d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"
              />
            </svg>
          </router-link>
        </h2>
      </oc-header>
      <div class="oc-org-body">
        <address-list :addresses="org_unit_data.addresses" />

        <!-- Engagements -->
        <template v-if="relation_is_engagement_or_both">
          <div class="people-list-wrapper">
            <p class="people-list-heading">Managers</p>
            <manager-list :managers="org_unit_data.managers" />
          </div>

          <div class="people-list-wrapper">
            <p class="people-list-heading">Engagementer</p>

            <person-list
              v-if="org_unit_data.engagements.length"
              :people="org_unit_data.engagements"
            />

            <span v-else class="people-list-empty">Ingen ansatte fundet</span>
          </div>
        </template>

        <!-- Associations -->
        <template v-if="relation_is_association_or_both">
          <div class="people-list-wrapper">
            <p class="people-list-heading">Tilknytninger</p>

            <person-list
              v-if="org_unit_data.associations.length"
              :people="org_unit_data.associations"
            />

            <span v-else class="people-list-empty">Ingen tilknytninger fundet</span>
          </div>
        </template>
      </div>
    </article>
  </transition>
</template>

<script>
import Vue from "vue"
import ManagerList from "../manager/ManagerList.vue"
import PersonList from "../person/PersonList.vue"
import AddressList from "../address/AddressList.vue"
import OcHeader from "../layout/Header.vue"

export default {
  components: {
    ManagerList,
    PersonList,
    AddressList,
    OcHeader,
  },
  computed: {
    org_unit_data: function () {
      return this.$store.getters.getOrgUnitData
    },
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
    relation_is_engagement_or_both() {
      return (
        this.$store.state.relation_type === "engagement" ||
        this.$store.state.relation_type === "both"
      )
    },
    relation_is_association_or_both() {
      return (
        this.$store.state.relation_type === "association" ||
        this.$store.state.relation_type === "both"
      )
    },
  },
  watch: {
    org_unit_data: function (new_data, old_data) {
      Vue.nextTick(() => {
        if (new_data && this.$route.query.target === "orgunit") {
          document.getElementById("orgtitle").focus()
        }
      })
    },
    $route: function (to, from) {
      if (to.params.orgUnitId !== from.params.orgUnitId) {
        this.update(to.params.orgUnitId)
      }
    },
  },
  methods: {
    update: function (org_unit_uuid) {
      this.$store.commit("clearOrgUnitData")
      this.$store.dispatch("fetchOrgUnitData", org_unit_uuid)
    },
  },
  created: function () {
    // Initialise org view from URL params
    if (this.$route.params.orgUnitId) {
      this.update(this.$route.params.orgUnitId)
    }
  },
}
</script>

<style lang="scss">
.oc-org {
  position: fixed;
  top: 0;
  bottom: 0;
  right: 0;
  width: 100%;
  background-color: var(--shade-lightest);
  z-index: 10;
  display: flex;
  flex-flow: column nowrap;
  overflow: hidden;
}

.oc-org.dim > * {
  opacity: 0.5;
}

.oc-org .oc-header h2 {
  margin: 0;
  padding: 0;
  width: 100%;
}

.oc-org .oc-header h2 a {
  display: flex;
  flex-flow: row nowrap;
  align-items: center;
  padding: 0.75rem 1rem;
}

.oc-org-title {
  flex-grow: 1;
}

.oc-org-body {
  padding: 1rem;
  flex-grow: 1;
  overflow: auto;
}

.oc-org .svg-path {
  fill: var(--primary-color);
}

@media screen and (max-width: 40rem) {
  .oc-org {
    .svg-back {
      display: inline-block;
      margin-right: 0.5rem;
    }
    .svg-close {
      display: none;
    }
  }
}

@media screen and (min-width: 40rem) {
  .oc-org {
    width: 23rem;
    box-shadow: var(--shadow-2);

    .svg-back {
      display: none;
    }
    .svg-close {
      display: inline-block;
      margin-left: 0.5rem;
    }
  }

  .oc-header h2 {
    flex-grow: 1;
  }
}

@media screen and (min-width: 60rem) {
  .oc-org {
    width: 28rem;
  }
}

@media screen and (min-width: 80rem) {
  .oc-org {
    width: 35rem;
  }
}

@media print {
  .oc-org {
    position: relative;
    page-break-before: always;
    margin-top: 24pt;
  }

  .oc-org.dim > * {
    opacity: 1 !important;
  }

  #orgtitle {
    border-bottom: solid 1pt #000;
  }

  .svg-close,
  .svg-back {
    display: none !important;
  }
}
</style>
