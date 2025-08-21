<template>
  <transition name="oc-fade">
    <article v-if="person && $route.name === 'person'" class="oc-person">
      <oc-header>
        <h3 slot="title">
          <router-link
            v-if="org_uuid"
            :to="`/orgunit/${org_uuid}/${root_uuid}`"
            id="persontitle"
          >
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
            <span v-if="show_nickname && person.nickname" class="oc-person-title">{{
              person.nickname
            }}</span>
            <span v-else class="oc-person-title">{{ person.name }}</span>
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
            <span class="sr-only">Tilbage til enhedsoverblik</span>
          </router-link>
        </h3>
      </oc-header>
      <div class="oc-person-body">
        <dl>
          <dt>Navn</dt>
          <dd v-if="show_nickname && person.nickname">{{ person.nickname }}</dd>
          <dd v-else>{{ person.name }}</dd>

          <template v-if="engagement">
            <dt>{{ engagement.engagement_type.name }}</dt>
            <dd v-if="show_extension_3">{{ engagement.extension_3 }}</dd>
            <dd v-else>{{ engagement.job_function.name }}</dd>
          </template>

          <template v-if="association">
            <dt>Tilknytning</dt>
            <dd>{{ association.association_type.name }}</dd>

            <template v-if="association.substitute.length > 0">
              <dt>Stedfortræder</dt>
              <dd>
                <router-link :to="`/person/${association.substitute[0].uuid}`">
                  <span v-if="show_nickname && association.substitute[0].nickname">{{
                    association.substitute[0].nickname
                  }}</span>
                  <span v-else>{{ association.substitute[0].name }}</span>
                </router-link>
              </dd>
            </template>

            <template v-if="association.dynamic_class">
              <template v-for="dclass in association.dynamic_class">
                <dt :key="dclass.top_level_facet.uuid" class="oc-dynamic-class-title">
                  {{ dclass.top_level_facet.description }}
                </dt>
                <dd :key="dclass.uuid" class="oc-dynamic-class-body">
                  {{ dclass.full_name }}
                </dd>
              </template>
            </template>
          </template>

          <dt>Arbejdsadresse</dt>
          <dd><work-address :uuid="person.uuid" /></dd>
        </dl>

        <address-list v-if="person.addresses" :addresses="person.addresses" />
      </div>
    </article>
  </transition>
</template>

<script>
import Vue from "vue"
import OcHeader from "../layout/Header.vue"
import AddressList from "../address/AddressList.vue"
import EngagementList from "./Engagements.vue"
import WorkAddress from "../address/WorkAddress.vue"
import Store from "../../store.js"
import { convertToBoolean } from "../../helpers"

export default {
  components: {
    OcHeader,
    AddressList,
    EngagementList,
    WorkAddress,
  },
  data: function () {
    return {
      relation_type: this.$store.state.relation_type,
      show_extension_3: convertToBoolean(
        OC_GLOBAL_CONF.VUE_APP_SHOW_EXTENSION_3_VIBORG
      ),
      show_nickname: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_SHOW_NICKNAME),
    }
  },
  computed: {
    person: function () {
      return this.$store.getters.getPerson
    },
    org_uuid: function () {
      if (this.$route.params.orgUnitId) {
        return this.$route.params.orgUnitId
      } else {
        return false
      }
    },
    association: function () {
      if (
        this.relation_type === "association" &&
        this.person.associations &&
        this.$route.params.orgUnitId
      ) {
        return this.person.associations.find((a) => {
          return a.org_unit_uuid === this.$route.params.orgUnitId
        })
      } else if (this.relation_type === "association" && this.person.associations) {
        return this.person.associations[0]
      } else {
        return false
      }
    },
    engagement: function () {
      if (
        this.relation_type === "engagement" &&
        this.person.engagements &&
        this.$route.params.orgUnitId
      ) {
        return this.person.engagements.find((e) => {
          return e.org_unit_uuid === this.$route.params.orgUnitId
        })
      } else if (this.relation_type === "engagement" && this.person.engagements) {
        return this.person.engagements[0]
      } else {
        return false
      }
    },
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
  },
  watch: {
    $route: function (to, from) {
      if (to.params.personId) {
        Vue.nextTick(() => {
          if (to.name === "person") {
            document.getElementById("persontitle").focus()
          }
        })
        if (to.params.personId !== from.params.personId) {
          this.update(to.params.personId)
        }
      }
    },
    person: function () {
      // Check if route already knows about this person's org unit
      // if not, update org unit uuid and redirect
      if (!this.$route.params.orgUnitId) {
        if (this.relation_type === "association") {
          this.$router.push(
            `/person/${this.person.uuid}/${this.person.associations[0].org_unit_uuid}/${this.root_uuid}`
          )
        } else {
          this.$router.push(
            `/person/${this.person.uuid}/${this.person.engagements[0].org_unit_uuid}/${this.root_uuid}`
          )
        }
      }
    },
  },
  methods: {
    update: function (person_uuid) {
      this.$store.dispatch("fetchPerson", person_uuid)
    },
  },
  beforeRouteEnter(to, from, next) {
    Store.dispatch("fetchPerson", to.params.personId).then((person) => {
      // Check if route already knows about this person's org unit
      // if not, update org unit uuid and redirect
      if (!to.params.orgUnitId) {
        if (Store.state.relation_type === "association") {
          to.params.orgUnitId = person.associations[0].org_unit_uuid
        } else {
          to.params.orgUnitId = person.engagements[0].org_unit_uuid
        }
      }
      next()
    })
  },
}
</script>

<style lang="scss">
.oc-person {
  position: fixed;
  top: 0;
  bottom: 0;
  right: 0;
  z-index: 10;
  width: 100%;
  display: flex;
  flex-flow: column nowrap;
  overflow: auto;
  background-color: var(--shade-lightest);
}

.oc-person .oc-header h3 {
  margin: 0;
  padding: 0;
  width: 100%;
}

.oc-person .oc-header h3 a {
  display: flex;
  flex-flow: row nowrap;
  align-items: center;
  padding: 0.75rem 1rem;
}

.oc-person-title {
  flex-grow: 1;
}

.oc-person-body {
  padding: 0 1rem 1rem;
  flex-grow: 1;
  overflow: auto;
}

.oc-person .svg-path {
  fill: var(--primary-color);
}

@media screen and (max-width: 40rem) {
  .oc-person {
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
  .oc-person {
    max-width: 18rem;
    box-shadow: var(--shadow-2);

    .svg-back {
      display: none;
    }
    .svg-close {
      display: inline-block;
      margin-left: 0.5rem;
    }
  }

  .oc-header h3 {
    flex-grow: 1;
  }
}

@media screen and (min-width: 60rem) {
  .oc-person {
    max-width: 23rem;
  }
}

@media print {
  .oc-person {
    position: relative;
    margin-top: 24pt;
  }

  #persontitle {
    border-bottom: solid 1pt #000;
  }

  .svg-close,
  .svg-back {
    display: none !important;
  }
}
</style>
